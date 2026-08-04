# Customer Segmentation Using R

## Project Overview

This project uses customer transaction data to group customers based on their purchasing behaviour.

The project uses RFM analysis:

- **Recency**: How recently a customer made a purchase
- **Frequency**: How often a customer made a purchase
- **Monetary**: How much a customer spent

K-means clustering was used to divide customers into four groups.

## Customer Groups

1. **Inactive Customers**
   - Have not purchased recently
   - Purchase less often
   - Spend less

2. **Occasional Customers**
   - Purchased recently
   - Purchase occasionally
   - Have lower spending

3. **Regular Customers**
   - Purchase more often
   - Have moderate spending

4. **High-Value Customers**
   - Purchase frequently
   - Spend the most
   - Are important customers for the business

## Tools Used

- R
- Visual Studio Code
- K-means Clustering

## Project Structure

```text
Customer-Segmentation-Using-R/
│
├── data/
│   ├── Copy of Online Retail.csv
│   └── customer_segments.csv
│
├── scripts/
│   └── 01_data_exploration.R
│
├── visuals/
│   ├── customer_groups.png
│   └── recency_vs_monetary.png
│
└── README.md