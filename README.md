# ☕ Coffee Sales Data Warehouse

[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-blue.svg)](https://www.postgresql.org/)
[![Pentaho](https://img.shields.io/badge/Pentaho-DI-orange.svg)](https://www.hitachivantara.com/)

<p align="center">
  <img src="https://github.com/sreypich999/Coffee-Sale-Assignment/blob/main/download.png" alt="PostgreSQL" width="100" height="100"/>
  <img src="https://github.com/sreypich999/Coffee-Sale-Assignment/blob/main/pdi.png" alt="Pentaho" width="80" height="80"/>
  <img src="https://github.com/sreypich999/Coffee-Sale-Assignment/blob/main/logo.png" alt="DrawIO" width="80" height="80"/>
  <img src="https://github.com/sreypich999/Coffee-Sale-Assignment/blob/main/png-clipart-metabase-logo-landscape-tech-companies.png" alt="Metabase" width="100" height="100"/>
</p>

> A comprehensive data warehouse solution for coffee sales analytics using modern ETL and BI tools.

## 📋 Table of Contents
- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Usage](#-usage)
- [Database Schema](#-database-schema)
- [Project Structure](#-project-structure)
- [Team Members](#-team-members)
- [Acknowledgments](#-acknowledgments)

## 🎯 Overview
This team project focuses on building a data warehouse solution for coffee sales analysis. The project includes ETL (Extract, Transform, Load) processes using Pentaho Data Integration (Kettle) to create dimensional models for customers, products, and sales facts. It demonstrates data warehousing concepts through practical implementation of star schema design and interactive dashboard visualization.

## ✨ Features
- **🔄 ETL Pipeline**: Automated data extraction and transformation using Kettle transformations (.ktr files)
- **📊 Dimensional Modeling**:
  - Customer dimension (dimcustomer.ktr)
  - Product dimension (dimproduct.ktr)
  - Sales fact table (Fact_sale1.ktr)
- **📈 Analytics Ready**: Pre-built queries for sales performance, customer segmentation, and product analysis
- **🎨 Interactive Dashboards**: Metabase-powered visualizations for real-time insights
- **🏗️ Star Schema Design**: Optimized for analytical queries and reporting
- **🔗 Data Integration**: Seamless connection between operational data and analytical views

## Database Schema Design

### Schema Architecture Overview
The database follows a **three-layer architecture** typical of data warehousing:

1. **Staging Schema** (`staging`): Raw data landing zone
2. **Core DW Schema** (`core_dw`): Cleaned dimensional model
3. **Data Mart Schema** (`data_mart`): Business-ready views (not implemented yet)

### Staging Layer Tables

#### `staging.sale10` - Raw Sales Transactions
```sql
CREATE TABLE staging.sale10 (
    Coffee_Sale_id INT,              -- Transaction ID
    Size DECIMAL(16,2),              -- Product quantity/size
    Unit_Price DECIMAL(10,2),        -- Price per unit
    Sales DECIMAL(10,2),             -- Total sales amount
    Coffee_Type VARCHAR(50),         -- Type of coffee
    Roast_Type VARCHAR(50),          -- Roast level
    Loyalty_Card VARCHAR(10)         -- Customer loyalty status
);
```

#### `staging.product_coffee10` - Raw Product Catalog
```sql
CREATE TABLE staging.product_coffee10 (
    Product_ID INT,                  -- Product identifier
    Coffee_Type VARCHAR(50),         -- Coffee variety
    Roast_Type VARCHAR(10),          -- Roast type (shorter field)
    Size DECIMAL(16,2),              -- Package size
    Unit_Price DECIMAL(16,2),        -- Standard unit price
    Price_per_100g DECIMAL(16,2),    -- Normalized price metric
    Profit DECIMAL(16,2)             -- Profit margin
);
```

#### `staging.customer12` - Raw Customer Data
```sql
CREATE TABLE staging.customer12 (
    Customer_ID INT,                 -- Customer identifier
    Customer_Name VARCHAR(100),      -- Full name
    Email VARCHAR(100),              -- Contact email
    Phone_Number VARCHAR(20),        -- Contact phone
    Address_Line_1 VARCHAR(100),     -- Primary address
    City VARCHAR(50),                -- City location
    Country VARCHAR(50),             -- Country location
    Postcode VARCHAR(20),            -- Postal code
    Loyalty_Card VARCHAR(10)         -- Loyalty program status
);
```

### Core DW Layer: Dimensional Model

#### `core_dw.dim_customer12` - Customer Dimension
```sql
CREATE TABLE core_dw.dim_customer12 (
    Customer_ID INT PRIMARY KEY,     -- Surrogate key
    Customer_Name VARCHAR(100),
    Email VARCHAR(100),
    Phone_Number VARCHAR(20),
    Address_Line_1 VARCHAR(100),
    City VARCHAR(50),
    Country VARCHAR(50),
    Postcode VARCHAR(20),
    Loyalty_Card VARCHAR(10)
);
```

#### `core_dw.dim_product11` - Product Dimension
```sql
CREATE TABLE core_dw.dim_product11 (
    Product_ID INT PRIMARY KEY,      -- Surrogate key
    Coffee_Type VARCHAR(50),
    Roast_Type VARCHAR(10),
    Size DECIMAL(16,2),
    Unit_Price DECIMAL(16,2),
    Price_per_100g DECIMAL(16,2),
    Profit DECIMAL(16,2)
);
```

#### `core_dw.fact_sale_coffee10` - Sales Fact Table
```sql
CREATE TABLE core_dw.fact_sale_coffee10 (
    Coffee_Sale_id INT PRIMARY KEY,  -- Transaction ID (natural key)
    Product_ID INT,                  -- FK to dim_product11
    Customer_ID INT,                 -- FK to dim_customer12

    -- Measures
    Size DECIMAL(16,2),
    Unit_Price DECIMAL(10,2),
    Sales DECIMAL(10,2),
    Sales_1 DECIMAL(10,2),           -- Calculated: unit_price × size

    -- Degenerate dimensions (kept in fact for direct access)
    Loyalty_Card VARCHAR(10),
    Sale_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Coffee_Type VARCHAR(50),
    Roast_Type VARCHAR(50),

    -- Foreign key constraints
    FOREIGN KEY (Product_ID) REFERENCES core_dw.dim_product11(Product_ID),
    FOREIGN KEY (Customer_ID) REFERENCES core_dw.dim_customer12(Customer_ID)
);
```

### Schema Design Patterns & Rationale

#### Star Schema Implementation
- **Central Fact Table**: `fact_sale_coffee10` contains all sales transactions
- **Dimension Tables**: `dim_customer12` and `dim_product11` provide descriptive attributes
- **Benefits**: Simple queries, fast aggregations, easy to understand

#### Surrogate Keys
- Customer and Product dimensions use integer surrogate keys (`Customer_ID`, `Product_ID`)
- Fact table uses natural key (`Coffee_Sale_id`) as primary key for transaction uniqueness
- Surrogates enable handling of slowly changing dimensions and data quality issues

#### Degenerate Dimensions
- `Loyalty_Card`, `Coffee_Type`, `Roast_Type` stored directly in fact table
- Avoids unnecessary dimension tables for low-cardinality attributes
- Improves query performance for common filters

#### Data Type Choices
- **DECIMAL(16,2)**: High precision for financial calculations (size, prices, profits)
- **VARCHAR**: Flexible text storage with appropriate length limits
- **TIMESTAMP**: Date/time tracking for temporal analysis
- **INT**: Efficient integer keys for joins and indexing

#### Referential Integrity
- Foreign key constraints ensure data consistency
- Cascading not implemented (typical for DW to preserve historical data)
- Allows fact table loading even if dimension updates are pending

### Data Flow & Transformation Logic
1. **Staging → Dimensions**: Direct loads with minimal transformation
2. **Dimensions → Fact**: Lookup operations in ETL to get surrogate keys
3. **Fact Loading**: Combines sales data with dimension references + calculations

### Analytical Query Support
The schema supports complex queries like:
- Geographic analysis (customer city/country aggregations)
- Product performance (coffee type, roast type analysis)
- Customer segmentation (loyalty card analysis)
- Temporal trends (sale_date aggregations)

## 📁 Project Structure
- `Coffee.sql` - Database schema and table creation scripts
- `customers .ktr` - Customer data ETL transformation
- `dimcustomer.ktr` - Customer dimension processing
- `dimproduct.ktr` - Product dimension processing
- `Fact_sale1.ktr` - Sales fact table loading
- `Order.ktr` - Order data processing
- `Products.ktr` - Product data ETL transformation
- `Coffee_Sale_Slide.pdf` - Project presentation slides
- `coffee_Sale.mp4` - Project demonstration video
- `customer (2).pdf` - Customer data documentation
- `Product dashboard.pdf` - Product analytics dashboard
- `Sales dashboard (1).pdf` - Sales performance dashboard

## 🛠️ Tech Stack
- **ETL & Data Integration**: Pentaho Data Integration (Kettle)
- **Database**: PostgreSQL 14+
- **Visualization**: Metabase
- **Diagrams**: DrawIO (diagrams.net)
- **Query Language**: SQL
- **Architecture**: Star Schema Data Warehouse

## 📊 Key Metrics
- Customer segmentation by geography and loyalty status
- Product performance analysis by coffee type and roast
- Sales trend analysis with temporal dimensions
- Profit margin calculations and price optimization

## 📋 Prerequisites
- Pentaho Data Integration (PDI) / Kettle (for ETL)
- DrawIO (for data architecture diagrams)
- Metabase (for dashboard visualization)
- PostgreSQL (database server)
- Java Runtime Environment (JRE)

## 🚀 Installation & Setup
1. **Install Pentaho Data Integration**:
    - Download and install PDI from [Hitachi Vantara Pentaho](https://www.hitachivantara.com/en-us/products/data-management-analytics/pentaho-platform/pentaho-data-integration.html)
    - Ensure Java is properly configured

2. **Install DrawIO**:
    - Download DrawIO desktop application from [diagrams.net](https://www.diagrams.net/) or use the web version
    - Use for creating data flow and architecture diagrams

3. **Install Metabase**:
    - Download and install Metabase from [metabase.com](https://www.metabase.com/)
    - Configure connection to PostgreSQL database

4. **Database Setup**:
    - Install PostgreSQL server from [postgresql.org](https://www.postgresql.org/)
    - Create a new database for the coffee sales data warehouse
    - Run the `Coffee.sql` script to create tables and schema

5. **Configure ETL Jobs**:
    - Open the .ktr files in Spoon (PDI designer)
    - Update PostgreSQL database connection settings in each transformation
    - Configure file paths for input data sources

## 📖 Usage
1. **Run ETL Processes**:
    - Execute transformations in order: customers → products → orders → dimensions → facts
    - Monitor job execution in Spoon

2. **Data Loading**:
    - Ensure source data files are placed in the designated input directories
    - Run the Kettle jobs to populate the data warehouse
3. **Dashboard Access**:
    - Use Metabase to create interactive dashboards connected to PostgreSQL
    - Open the provided PDF dashboard files for static visualizations
    - Connect Metabase to the database for real-time data access

## 👩‍💻 Team Members

> Together we brew insights — powered by collaboration and caffeine ☕🚀

<p align="center">
  <a href="https://github.com/Guardian007-Moon">
    <img src="https://img.shields.io/badge/Guardian007--Moon-0A66C2?style=for-the-badge&logo=github&logoColor=white" alt="Guardian007-Moon"/>
  </a>
  <a href="https://github.com/mengsoklin">
    <img src="https://img.shields.io/badge/mengsoklin-FF4081?style=for-the-badge&logo=github&logoColor=white" alt="mengsoklin"/>
  </a>
  <a href="https://github.com/PiseyVONG">
    <img src="https://img.shields.io/badge/PiseyVONG-FFD700?style=for-the-badge&logo=github&logoColor=white" alt="PiseyVONG"/>
  </a>
  <img src="https://img.shields.io/badge/Vorn%20Seavmey-8A2BE2?style=for-the-badge&logo=github&logoColor=white" alt="Vorn Seavmey"/>
</p>

<p align="center">
  <sub>💡 Building modern data solutions with precision, teamwork, and a shared love for great coffee.</sub>
</p>




## 🙏 Acknowledgments
- Built with modern data warehousing best practices
- Special thanks to the Pentaho and Metabase communities




