"""
Streamlit Dashboard for Restaurant Analytics
"""
import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import requests
from datetime import datetime, date

# Configuration
API_BASE_URL = "http://localhost:5000/api"

st.set_page_config(
    page_title="Restaurant Analytics Dashboard",
    page_icon="🍽️",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        font-weight: bold;
        color: #1f77b4;
        text-align: center;
        margin-bottom: 2rem;
    }
    .metric-card {
        background-color: #f0f2f6;
        padding: 1rem;
        border-radius: 0.5rem;
        text-align: center;
    }
    .stMetric {
        background-color: #f8f9fa;
        padding: 1rem;
        border-radius: 0.5rem;
    }
    /* Fix metric text visibility */
    .stMetric label {
        color: #31333F !important;
    }
    .stMetric [data-testid="stMetricValue"] {
        color: #0e1117 !important;
    }
    .stMetric [data-testid="stMetricDelta"] {
        color: #31333F !important;
    }
</style>
""", unsafe_allow_html=True)

def fetch_api(endpoint, params=None):
    """Fetch data from Flask API"""
    try:
        response = requests.get(f"{API_BASE_URL}/{endpoint}", params=params, timeout=30)
        if response.status_code == 200:
            return response.json(), None
        return None, response.json().get('error', 'Unknown error')
    except requests.exceptions.ConnectionError:
        return None, "Cannot connect to API. Make sure Flask server is running."
    except Exception as e:
        return None, str(e)

def check_api_health():
    """Check if API is available"""
    data, error = fetch_api("health")
    return data is not None and data.get('status') == 'healthy'

# Sidebar
st.sidebar.markdown("## 🍽️ Restaurant Analytics")
st.sidebar.markdown("---")

# API Status
api_healthy = check_api_health()
if api_healthy:
    st.sidebar.success("✅ API Connected")
else:
    st.sidebar.error("❌ API Disconnected")
    st.sidebar.info("Run: `python flask_api.py`")

# Navigation
page = st.sidebar.selectbox(
    "Select Dashboard",
    ["📊 Overview", "🍔 Menu Analytics", "👥 Customer Analytics", 
     "👨‍💼 Staff Performance", "📈 Revenue Trends", "🔍 Custom Query"]
)

st.sidebar.markdown("---")
st.sidebar.markdown("### Quick Stats")

# Main content
st.markdown('<h1 class="main-header">🍽️ Restaurant Analytics Dashboard</h1>', unsafe_allow_html=True)

if not api_healthy:
    st.error("⚠️ Cannot connect to the Flask API. Please ensure the API server is running.")
    st.code("cd app && python flask_api.py", language="bash")
    st.stop()

# Overview Page
if page == "📊 Overview":
    st.header("Dashboard Overview")
    
    # Fetch summary data
    summary, error = fetch_api("dashboard/summary")
    
    if summary:
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            revenue = summary.get('revenue', {})
            st.metric(
                "Total Revenue",
                f"${revenue.get('TotalRevenue', 0):,.2f}" if revenue.get('TotalRevenue') else "$0.00",
                help="Total revenue from paid orders"
            )
        
        with col2:
            st.metric(
                "Total Orders",
                f"{summary.get('revenue', {}).get('TotalOrders', 0):,}",
                help="Total number of orders"
            )
        
        with col3:
            st.metric(
                "Total Customers",
                f"{summary.get('customers', {}).get('TotalCustomers', 0):,}",
                help="Total registered customers"
            )
        
        with col4:
            st.metric(
                "Menu Items",
                f"{summary.get('menu_items', {}).get('TotalMenuItems', 0):,}",
                help="Available menu items"
            )
    
    st.markdown("---")
    
    # Day of Week Analysis
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("📅 Orders by Day of Week")
        data, error = fetch_api("query/weekday_analysis")
        if data and 'data' in data:
            df = pd.DataFrame(data['data'])
            if not df.empty:
                fig = px.bar(
                    df, x='DayOfWeek', y='TotalOrders',
                    color='TotalRevenue',
                    title="Orders by Day of Week",
                    labels={'TotalOrders': 'Total Orders', 'DayOfWeek': 'Day'}
                )
                st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        st.subheader("💰 Revenue by Day of Week")
        if data and 'data' in data:
            df = pd.DataFrame(data['data'])
            if not df.empty:
                fig = px.pie(
                    df, values='TotalRevenue', names='DayOfWeek',
                    title="Revenue Distribution by Day"
                )
                st.plotly_chart(fig, use_container_width=True)

# Menu Analytics Page
elif page == "🍔 Menu Analytics":
    st.header("Menu Item Analytics")
    
    tab1, tab2, tab3 = st.tabs(["📊 Performance", "💵 Profit Analysis", "📅 Daily Top Items"])
    
    with tab1:
        st.subheader("Menu Item Performance")
        data, error = fetch_api("query/menu_item_performance")
        
        if error:
            st.error(f"Error: {error}")
        elif data and 'data' in data:
            df = pd.DataFrame(data['data'])
            
            if not df.empty:
                col1, col2 = st.columns(2)
                
                with col1:
                    # Top items by revenue
                    fig = px.bar(
                        df.head(10), x='Name', y='TotalRevenue',
                        color='Category',
                        title="Top 10 Menu Items by Revenue"
                    )
                    fig.update_layout(xaxis_tickangle=-45)
                    st.plotly_chart(fig, use_container_width=True)
                
                with col2:
                    # Revenue by category
                    category_df = df.groupby('Category').agg({
                        'TotalRevenue': 'sum',
                        'TimesSold': 'sum'
                    }).reset_index()
                    
                    fig = px.pie(
                        category_df, values='TotalRevenue', names='Category',
                        title="Revenue by Category"
                    )
                    st.plotly_chart(fig, use_container_width=True)
                
                # Data table
                st.subheader("📋 Detailed Data")
                st.dataframe(df, use_container_width=True)
    
    with tab2:
        st.subheader("Profit Margin Analysis")
        data, error = fetch_api("query/profit_analysis")
        
        if error:
            st.error(f"Error: {error}")
        elif data and 'data' in data:
            df = pd.DataFrame(data['data'])
            
            if not df.empty:
                col1, col2 = st.columns(2)
                
                with col1:
                    fig = px.scatter(
                        df, x='ProfitMargin', y='TotalProfit',
                        size='TimesSold', hover_name='MenuItem',
                        color='ProfitMargin',
                        title="Profit Margin vs Total Profit"
                    )
                    st.plotly_chart(fig, use_container_width=True)
                
                with col2:
                    fig = px.bar(
                        df.head(10), x='MenuItem', y='ProfitPerUnit',
                        color='ProfitMargin',
                        title="Top 10 Items by Profit Per Unit"
                    )
                    fig.update_layout(xaxis_tickangle=-45)
                    st.plotly_chart(fig, use_container_width=True)
                
                st.dataframe(df, use_container_width=True)
    
    with tab3:
        st.subheader("Daily Top Selling Items")
        selected_date = st.date_input("Select Date", date(2025, 12, 1))
        
        data, error = fetch_api("query/top_menu_items_daily", {"date": selected_date.strftime("%Y-%m-%d")})
        
        if error:
            st.error(f"Error: {error}")
        elif data and 'data' in data:
            df = pd.DataFrame(data['data'])
            
            if not df.empty:
                fig = px.bar(
                    df, x='MenuItem', y='Revenue',
                    color='TotalQuantity',
                    title=f"Top 5 Items on {selected_date}"
                )
                st.plotly_chart(fig, use_container_width=True)
                st.dataframe(df, use_container_width=True)
            else:
                st.info("No data available for the selected date.")

# Customer Analytics Page
elif page == "👥 Customer Analytics":
    st.header("Customer Analytics")
    
    tab1, tab2 = st.tabs(["🏆 Loyalty Tiers", "📈 Retention"])
    
    with tab1:
        st.subheader("Customer Loyalty Analysis")
        data, error = fetch_api("query/customer_loyalty")
        
        if error:
            st.error(f"Error: {error}")
        elif data and 'data' in data:
            df = pd.DataFrame(data['data'])
            
            if not df.empty:
                col1, col2 = st.columns(2)
                
                with col1:
                    # Loyalty tier distribution
                    tier_df = df['LoyaltyTier'].value_counts().reset_index()
                    tier_df.columns = ['Tier', 'Count']
                    
                    colors = {'VIP': '#FFD700', 'Gold': '#FFA500', 'Silver': '#C0C0C0', 'Bronze': '#CD7F32'}
                    fig = px.pie(
                        tier_df, values='Count', names='Tier',
                        title="Customer Loyalty Distribution",
                        color='Tier',
                        color_discrete_map=colors
                    )
                    st.plotly_chart(fig, use_container_width=True)
                
                with col2:
                    # Top spenders
                    fig = px.bar(
                        df.head(10), x='CustomerName', y='TotalSpent',
                        color='LoyaltyTier',
                        title="Top 10 Customers by Spending"
                    )
                    fig.update_layout(xaxis_tickangle=-45)
                    st.plotly_chart(fig, use_container_width=True)
                
                # Scatter plot
                fig = px.scatter(
                    df, x='TotalOrders', y='TotalSpent',
                    color='LoyaltyTier', size='AvgOrderValue',
                    hover_name='CustomerName',
                    title="Orders vs Spending by Customer"
                )
                st.plotly_chart(fig, use_container_width=True)
                
                st.subheader("📋 Customer Details")
                st.dataframe(df, use_container_width=True)
    
    with tab2:
        st.subheader("Customer Retention Analysis")
        data, error = fetch_api("query/customer_retention")
        
        if error:
            st.error(f"Error: {error}")
        elif data and 'data' in data:
            df = pd.DataFrame(data['data'])
            
            if not df.empty:
                df['Period'] = df['Year'].astype(str) + '-' + df['Month'].astype(str).str.zfill(2)
                
                fig = go.Figure()
                fig.add_trace(go.Scatter(
                    x=df['Period'], y=df['TotalCustomers'],
                    mode='lines+markers', name='Total Customers'
                ))
                fig.add_trace(go.Scatter(
                    x=df['Period'], y=df['ReturnedCustomers'],
                    mode='lines+markers', name='Returned Customers'
                ))
                fig.update_layout(title="Monthly Customer Retention")
                st.plotly_chart(fig, use_container_width=True)
                
                fig = px.line(
                    df, x='Period', y='RetentionRate',
                    title="Retention Rate Over Time",
                    markers=True
                )
                st.plotly_chart(fig, use_container_width=True)

# Staff Performance Page
elif page == "👨‍💼 Staff Performance":
    st.header("Staff Performance Analytics")
    
    data, error = fetch_api("query/staff_performance")
    
    if error:
        st.error(f"Error: {error}")
    elif data and 'data' in data:
        df = pd.DataFrame(data['data'])
        
        if not df.empty:
            col1, col2 = st.columns(2)
            
            with col1:
                fig = px.bar(
                    df, x='StaffName', y='TotalSales',
                    color='RoleName',
                    title="Total Sales by Staff"
                )
                fig.update_layout(xaxis_tickangle=-45)
                st.plotly_chart(fig, use_container_width=True)
            
            with col2:
                fig = px.bar(
                    df, x='StaffName', y='OrdersHandled',
                    color='RoleName',
                    title="Orders Handled by Staff"
                )
                fig.update_layout(xaxis_tickangle=-45)
                st.plotly_chart(fig, use_container_width=True)
            
            # Performance metrics
            fig = px.scatter(
                df, x='AvgOrdersPerDay', y='AvgOrderValue',
                size='TotalSales', color='RoleName',
                hover_name='StaffName',
                title="Performance: Avg Orders/Day vs Avg Order Value"
            )
            st.plotly_chart(fig, use_container_width=True)
            
            st.subheader("📋 Staff Details")
            st.dataframe(df, use_container_width=True)

# Revenue Trends Page
elif page == "📈 Revenue Trends":
    st.header("Revenue Trends Analysis")
    
    tab1, tab2 = st.tabs(["📅 Monthly Trends", "⏰ Hourly Analysis"])
    
    with tab1:
        st.subheader("Monthly Revenue Trends")
        year = st.selectbox("Select Year", [2024, 2025], index=0)
        
        data, error = fetch_api("query/monthly_trends", {"year": year})
        
        if error:
            st.error(f"Error: {error}")
        elif data and 'data' in data:
            df = pd.DataFrame(data['data'])
            
            if not df.empty:
                col1, col2 = st.columns(2)
                
                with col1:
                    fig = px.line(
                        df, x='MonthName', y='Revenue',
                        title=f"Monthly Revenue - {year}",
                        markers=True
                    )
                    st.plotly_chart(fig, use_container_width=True)
                
                with col2:
                    fig = px.bar(
                        df, x='MonthName', y='TotalOrders',
                        color='UniqueCustomers',
                        title=f"Monthly Orders - {year}"
                    )
                    st.plotly_chart(fig, use_container_width=True)
                
                # Order type breakdown
                order_types = df[['MonthName', 'DineInOrders', 'TakeoutOrders', 'DeliveryOrders']].melt(
                    id_vars=['MonthName'],
                    var_name='OrderType',
                    value_name='Count'
                )
                
                fig = px.bar(
                    order_types, x='MonthName', y='Count',
                    color='OrderType', barmode='group',
                    title="Order Types by Month"
                )
                st.plotly_chart(fig, use_container_width=True)
                
                st.dataframe(df, use_container_width=True)
    
    with tab2:
        st.subheader("Hourly Order Distribution")
        selected_date = st.date_input("Select Date for Hourly Analysis", date(2024, 12, 31), key="hourly_date")
        
        data, error = fetch_api("query/hourly_orders", {"date": selected_date.strftime("%Y-%m-%d")})
        
        if error:
            st.error(f"Error: {error}")
        elif data and 'data' in data:
            df = pd.DataFrame(data['data'])
            
            if not df.empty:
                fig = px.bar(
                    df, x='Hour', y='OrderCount',
                    color='Revenue',
                    title=f"Hourly Orders on {selected_date}"
                )
                fig.update_xaxes(tickmode='linear', tick0=0, dtick=1)
                st.plotly_chart(fig, use_container_width=True)
                
                col1, col2 = st.columns(2)
                with col1:
                    st.metric("Peak Hour", f"{df.loc[df['OrderCount'].idxmax(), 'Hour']}:00")
                with col2:
                    st.metric("Total Daily Revenue", f"${df['Revenue'].sum():,.2f}")
            else:
                st.info("No data available for the selected date.")

# Custom Query Page
elif page == "🔍 Custom Query":
    st.header("Custom SQL Query")
    
    st.warning("⚠️ Only SELECT queries are allowed for security reasons.")
    
    # Sample queries
    st.subheader("📝 Sample Queries")
    sample_queries = {
        "All Customers": "SELECT * FROM CUSTOMERS",
        "All Orders": "SELECT TOP 100 * FROM ORDERS ORDER BY OrderDateTime DESC",
        "Menu Items with Categories": """
            SELECT mi.Name, mi.Price, mc.Name AS Category
            FROM MENUITEMS mi
            JOIN MENUCATEGORIES mc ON mi.CategoryID = mc.CategoryID
        """,
        "Recent Orders with Details": """
            SELECT TOP 50
                o.OrderID, c.FirstName + ' ' + c.LastName AS Customer,
                o.OrderType, o.TotalAmount, o.OrderDateTime, o.PaymentStatus
            FROM ORDERS o
            JOIN CUSTOMERS c ON o.CustomerID = c.CustomerID
            ORDER BY o.OrderDateTime DESC
        """
    }
    
    selected_sample = st.selectbox("Choose a sample query:", ["Custom"] + list(sample_queries.keys()))
    
    if selected_sample == "Custom":
        query = st.text_area("Enter your SQL query:", height=150)
    else:
        query = st.text_area("Enter your SQL query:", value=sample_queries[selected_sample], height=150)
    
    if st.button("🚀 Execute Query"):
        if query.strip():
            try:
                response = requests.post(
                    f"{API_BASE_URL}/custom-query",
                    json={"query": query},
                    timeout=30
                )
                
                if response.status_code == 200:
                    result = response.json()
                    st.success(f"✅ Query executed successfully! ({result['row_count']} rows)")
                    
                    if result['data']:
                        df = pd.DataFrame(result['data'])
                        st.dataframe(df, use_container_width=True)
                        
                        # Download button
                        csv = df.to_csv(index=False)
                        st.download_button(
                            label="📥 Download as CSV",
                            data=csv,
                            file_name="query_results.csv",
                            mime="text/csv"
                        )
                else:
                    st.error(f"❌ Error: {response.json().get('error', 'Unknown error')}")
            except Exception as e:
                st.error(f"❌ Error: {str(e)}")
        else:
            st.warning("Please enter a query.")

# Footer
st.markdown("---")
st.markdown(
    """
    <div style='text-align: center; color: #666;'>
        <p>Restaurant Analytics Dashboard | Built with Streamlit & Flask</p>
    </div>
    """,
    unsafe_allow_html=True
)
