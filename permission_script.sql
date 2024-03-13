-- Create the database
CREATE DATABASE dbt;

-- Need to connect to new `dbt` database
-- Create the schema
CREATE SCHEMA data;

-- Create the user
CREATE USER dbt_prod WITH PASSWORD '<PASSWORD>';
ALTER SCHEMA data owner TO dbt_prod;

-- Create a role associated with the user
CREATE ROLE dbt_prod_role;

-- Grant privileges to the role on the schema
GRANT OWNERSHIP ON SCHEMA data TO dbt_prod_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA data TO dbt_prod_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA data TO dbt_prod_role;

-- Grant the role to the user
GRANT dbt_prod_role TO dbt_prod;