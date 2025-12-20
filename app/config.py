"""
Database configuration for Restaurant Analytics App
"""
import os
from dotenv import load_dotenv

load_dotenv()

# SQL Server connection settings
DB_CONFIG = {
    'server': os.getenv('DB_SERVER', 'localhost'),
    'database': os.getenv('DB_NAME', 'RestaurantDB'),
    'driver': os.getenv('DB_DRIVER', 'ODBC Driver 17 for SQL Server'),
    # For Windows Authentication, leave username/password empty
    'username': os.getenv('DB_USERNAME', ''),
    'password': os.getenv('DB_PASSWORD', ''),
}

def get_connection_string():
    """Generate pyodbc connection string"""
    if DB_CONFIG['username'] and DB_CONFIG['password']:
        # SQL Server Authentication
        return (
            f"DRIVER={{{DB_CONFIG['driver']}}};"
            f"SERVER={DB_CONFIG['server']};"
            f"DATABASE={DB_CONFIG['database']};"
            f"UID={DB_CONFIG['username']};"
            f"PWD={DB_CONFIG['password']}"
        )
    else:
        # Windows Authentication
        return (
            f"DRIVER={{{DB_CONFIG['driver']}}};"
            f"SERVER={DB_CONFIG['server']};"
            f"DATABASE={DB_CONFIG['database']};"
            f"Trusted_Connection=yes"
        )
