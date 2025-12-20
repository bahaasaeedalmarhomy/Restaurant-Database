# Restaurant Analytics App

A Flask + Streamlit application for visualizing restaurant database analytics.

## Features

- **Dashboard Overview**: Key metrics and day-of-week analysis
- **Menu Analytics**: Performance metrics, profit analysis, and daily top items
- **Customer Analytics**: Loyalty tiers and retention analysis
- **Staff Performance**: Sales and order metrics by staff member
- **Revenue Trends**: Monthly and hourly revenue analysis
- **Custom Query**: Execute custom SQL queries with export functionality

## Prerequisites

- Python 3.8+
- SQL Server with RestaurantDB database
- ODBC Driver 17 for SQL Server

## Installation

1. Navigate to the app directory:
   ```bash
   cd app
   ```

2. Create a virtual environment (recommended):
   ```bash
   python -m venv venv
   venv\Scripts\activate  # Windows
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Configure database connection:
   ```bash
   copy .env.example .env
   # Edit .env with your database settings
   ```

## Running the Application

### Start the Flask API Server

```bash
python flask_api.py
```

The API will be available at `http://localhost:5000`

### Start the Streamlit Dashboard

In a new terminal:

```bash
streamlit run streamlit_app.py
```

The dashboard will open in your browser at `http://localhost:8501`

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/health` | GET | Health check |
| `/api/queries` | GET | List available queries |
| `/api/query/<query_id>` | GET | Execute a predefined query |
| `/api/dashboard/summary` | GET | Get dashboard summary stats |
| `/api/custom-query` | POST | Execute custom SQL (SELECT only) |

## Available Analytics Queries

- **top_menu_items_daily**: Top 5 selling items for a specific date
- **menu_item_performance**: Complete menu item performance breakdown
- **customer_loyalty**: Customer segmentation by loyalty tier
- **staff_performance**: Staff sales and order metrics
- **monthly_trends**: Monthly revenue and order trends
- **profit_analysis**: Menu item profit margins
- **hourly_orders**: Hourly order distribution
- **weekday_analysis**: Day of week order patterns
- **table_utilization**: Table reservation statistics
- **customer_retention**: Monthly customer retention rates

## Project Structure

```
app/
├── flask_api.py       # Flask backend API
├── streamlit_app.py   # Streamlit frontend dashboard
├── queries.py         # SQL query definitions
├── config.py          # Database configuration
├── requirements.txt   # Python dependencies
├── .env.example       # Environment variables template
└── README.md          # This file
```

## Screenshots

The dashboard provides interactive visualizations including:
- Bar charts for revenue and orders
- Pie charts for category distribution
- Line charts for trends over time
- Scatter plots for performance analysis
- Data tables with export functionality
