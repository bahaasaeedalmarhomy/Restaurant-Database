"""
Flask API Backend for Restaurant Analytics
"""
from flask import Flask, jsonify, request
from flask_cors import CORS
import pyodbc
import pandas as pd
from config import get_connection_string
from queries import QUERIES

app = Flask(__name__)
CORS(app)

def get_db_connection():
    """Create database connection"""
    try:
        conn = pyodbc.connect(get_connection_string())
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        return None

def execute_query(query, params=None):
    """Execute a query and return results as a list of dictionaries"""
    conn = get_db_connection()
    if not conn:
        return None, "Database connection failed"
    
    try:
        # Replace named parameters with ? placeholders for pyodbc
        sql = query
        param_values = []
        
        if params:
            for key, value in params.items():
                sql = sql.replace(f":{key}", "?")
                param_values.append(value)
        
        df = pd.read_sql_query(sql, conn, params=param_values if param_values else None)
        conn.close()
        return df.to_dict(orient='records'), None
    except Exception as e:
        conn.close()
        return None, str(e)

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    conn = get_db_connection()
    if conn:
        conn.close()
        return jsonify({"status": "healthy", "database": "connected"})
    return jsonify({"status": "unhealthy", "database": "disconnected"}), 500

@app.route('/api/queries', methods=['GET'])
def list_queries():
    """List all available queries"""
    query_list = []
    for key, value in QUERIES.items():
        query_list.append({
            "id": key,
            "name": value["name"],
            "description": value["description"],
            "params": value["params"]
        })
    return jsonify(query_list)

@app.route('/api/query/<query_id>', methods=['GET'])
def run_query(query_id):
    """Execute a specific query"""
    if query_id not in QUERIES:
        return jsonify({"error": "Query not found"}), 404
    
    query_info = QUERIES[query_id]
    params = {}
    
    # Get parameters from query string
    for param in query_info["params"]:
        value = request.args.get(param)
        if value:
            params[param] = value
        else:
            return jsonify({"error": f"Missing required parameter: {param}"}), 400
    
    results, error = execute_query(query_info["query"], params)
    
    if error:
        return jsonify({"error": error}), 500
    
    return jsonify({
        "query_id": query_id,
        "name": query_info["name"],
        "description": query_info["description"],
        "data": results,
        "row_count": len(results)
    })

@app.route('/api/custom-query', methods=['POST'])
def custom_query():
    """Execute a custom SQL query (read-only)"""
    data = request.get_json()
    
    if not data or 'query' not in data:
        return jsonify({"error": "Query is required"}), 400
    
    query = data['query'].strip()
    
    # Basic security: only allow SELECT statements
    if not query.upper().startswith('SELECT'):
        return jsonify({"error": "Only SELECT queries are allowed"}), 403
    
    # Block dangerous keywords
    dangerous_keywords = ['DROP', 'DELETE', 'UPDATE', 'INSERT', 'TRUNCATE', 'ALTER', 'CREATE', 'EXEC', 'EXECUTE']
    query_upper = query.upper()
    for keyword in dangerous_keywords:
        if keyword in query_upper:
            return jsonify({"error": f"Query contains forbidden keyword: {keyword}"}), 403
    
    results, error = execute_query(query)
    
    if error:
        return jsonify({"error": error}), 500
    
    return jsonify({
        "data": results,
        "row_count": len(results)
    })

@app.route('/api/dashboard/summary', methods=['GET'])
def dashboard_summary():
    """Get summary statistics for dashboard"""
    summaries = {}
    
    # Total revenue
    revenue_query = """
        SELECT SUM(TotalAmount) AS TotalRevenue, COUNT(*) AS TotalOrders
        FROM ORDERS WHERE PaymentStatus = 'Paid'
    """
    results, _ = execute_query(revenue_query)
    if results:
        summaries['revenue'] = results[0]
    
    # Total customers
    customer_query = "SELECT COUNT(*) AS TotalCustomers FROM CUSTOMERS"
    results, _ = execute_query(customer_query)
    if results:
        summaries['customers'] = results[0]
    
    # Menu items count
    menu_query = "SELECT COUNT(*) AS TotalMenuItems FROM MENUITEMS WHERE Available = 1"
    results, _ = execute_query(menu_query)
    if results:
        summaries['menu_items'] = results[0]
    
    # Staff count
    staff_query = "SELECT COUNT(*) AS TotalStaff FROM STAFF"
    results, _ = execute_query(staff_query)
    if results:
        summaries['staff'] = results[0]
    
    return jsonify(summaries)

if __name__ == '__main__':
    print("Starting Flask API server...")
    print("API available at: http://localhost:5000")
    app.run(debug=True, port=5000)
