# Netflix Data Analysis Projects

This repository contains two projects focused on the analysis of Netflix data using ELT (Extract, Load, Transform) techniques and SQL. Each project is designed to help you understand and gain insights from the Netflix dataset, which includes information about shows, movies, genres, and more.

---

## Project 1: ELT Data Analysis of Netflix Data

### Overview

This project demonstrates how to perform ELT (Extract, Load, Transform) operations on a Netflix dataset using SQL. The workflow includes:

- **Database and Table Creation:** Setting up a database and creating a raw data table to store the Netflix dataset.
- **Data Cleaning:** Identifying and handling duplicate records based on `show_id` and `title`.
- **Data Exploration:** Querying the dataset to understand its structure and contents.
- **Genre Extraction:** Using SQL (including recursive CTEs) to parse and analyze the genres associated with each show.

### Key Features

- **Duplicate Detection:** SQL queries to find and handle duplicate entries.
- **Genre Analysis:** Advanced SQL techniques to split and analyze multi-genre fields.
- **Comprehensive Table Design:** The `netflix_raw` table captures all relevant attributes, such as title, director, cast, country, date added, release year, rating, duration, listed genres, and description.

### How to Use

1. **Load the SQL Script:**  
   Use the provided `netflix_data_analysis.sql` file to create the database and tables.
2. **Import Data:**  
   Load your Netflix dataset into the `netflix_raw` table.
3. **Run Analysis Queries:**  
   Execute the included SQL queries to explore and analyze the data.

### Example SQL Operations

- Create and use the database:
  ```sql
  create database netflix_Data_db;
  use netflix_Data_db;
  ```
- Find duplicate show IDs:
  ```sql
  select show_id, COUNT(*) 
  from netflix_raw
  group by show_id 
  having COUNT(*) > 1;
  ```
- Extract and analyze genres using recursive CTEs.

---

## Project 2: Netflix Data Genre Analysis

### Overview

This project focuses on analyzing the genres of Netflix shows and movies. It demonstrates how to extract, transform, and analyze genre information from the dataset using SQL, including the use of recursive CTEs to split and count genres.

### Key Features

- **Genre Extraction:** Splits the `listed_in` column to extract individual genres for each show/movie.
- **Genre Frequency Analysis:** Counts the number of shows/movies in each genre.
- **Advanced SQL Techniques:** Uses recursive CTEs for string splitting and aggregation.

### How to Use

1. **Ensure Data is Loaded:**  
   The `netflix_raw` table should be populated as described in Project 1.
2. **Run Genre Analysis Queries:**  
   Use the provided SQL scripts to create genre tables and perform analysis.

### Example SQL Operation

- Create a genre table using a recursive CTE:
  ```sql
  CREATE TABLE netflix_genre AS
  WITH RECURSIVE cte AS (
      -- Start with full string
      SELECT 
      -- (rest of the recursive CTE logic)
  )
  SELECT * FROM cte;
  ```

---

## Getting Started

### Prerequisites

- MySQL or compatible SQL database system
- Basic knowledge of SQL

### Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/akashsamanta07/DataEngineering.git
   ```
2. Open your SQL client and run the provided SQL scripts.

### Data Source

The Netflix dataset should be in CSV or similar format and can be loaded into the `netflix_raw` table as per the schema.

---

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for improvements or additional analyses.

---

## License

This project is licensed under the MIT License.

---


