# Retail Sales & Inventory Analytics

End-to-end retail analytics project simulating sales performance, inventory management, supplier KPI tracking, and demand forecasting for a multi-store fashion retailer.

Built to demonstrate skills in SQL, Python (Pandas, Matplotlib), and Power BI — inspired by real procurement and supply chain analysis work at a global fashion retailer.

---

## Project Overview

This project replicates the type of analytical work performed as a Procurement Analyst at a high-volume fashion retail operation — analysing sales trends, optimising inventory levels, evaluating supplier performance, and supporting purchasing decisions with data-driven insights.

The dataset is synthetic but realistic, comprising 8 stores across 7 countries, 8 suppliers across 6 sourcing markets, 33 products across 5 categories, and 3,000 sales transactions across a full retail year.

---

## Key Metrics

| Metric | Value |
|---|---|
| Total Revenue | $1.43M |
| Total Profit | $927K |
| Gross Margin | 65.0% |
| Stores | 8 across 7 countries |
| Suppliers | 8 across 6 markets |
| Products | 33 across 5 categories |
| Period | Aug 2021 – Jul 2022 |

---

## Analysis Included

**SQL**
- Sales KPI overview — revenue, profit, margin, avg order value
- Revenue by product category with contribution %
- Store performance including revenue per sqm
- Monthly and seasonal sales trends
- Top 10 products by revenue
- Supplier performance — spend, lead time, on-time delivery
- Inventory health check — items below reorder point
- Discount impact analysis by discount band
- Demand forecasting base using LAG window functions
- Data quality checks

**Python Dashboard**
- Monthly revenue trend
- Revenue by product category
- Seasonal performance analysis
- Store performance comparison
- Discount impact on revenue
- Top 8 products by revenue
- Inventory health by category
- Supplier spend vs on-time delivery

---

## Dashboard Preview

![Retail Sales Dashboard](dashboard.png)

---

## Tools Used

| Tool | Purpose |
|---|---|
| Python (Pandas, NumPy) | Data manipulation and analysis |
| Matplotlib | Dashboard visualisation |
| SQL (PostgreSQL syntax) | Data querying and transformation |
| Microsoft Power BI | Executive dashboard delivery |
| Git / GitHub | Version control and portfolio |

---

## How to Run

Put all CSV files and retail_dashboard.py in the same folder, then:

    pip install matplotlib pandas
    python retail_dashboard.py

For SQL — load all CSV files into any SQL database and run retail_analysis.sql.

---

## Key Insights

1. Women's Wear is the top-performing category driving the largest share of revenue
2. Istanbul Flagship and Dubai Marina are the highest revenue stores
3. Summer season generates peak revenue driven by seasonal demand
4. Approximately 65% average gross margin maintained across all categories
5. Morocco Style House and Istanbul Textile Co deliver the best on-time performance
6. Several product-store combinations are below reorder point — immediate replenishment required

---

## About

**Oguz Tuncel** — Data Analyst | Business Analyst | Power BI Developer

- LinkedIn: https://linkedin.com/in/oguztuncel
- Email: ogzhantuncell@gmail.com
- Melbourne, VIC, Australia

---

*This project uses synthetic data generated for portfolio purposes. No real commercial data is included.*
