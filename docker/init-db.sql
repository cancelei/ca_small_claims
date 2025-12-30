-- Initialize PostgreSQL databases for development and test
-- This script runs when the postgres container is first created

-- Create test database
CREATE DATABASE ca_small_claims_test;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE ca_small_claims_development TO postgres;
GRANT ALL PRIVILEGES ON DATABASE ca_small_claims_test TO postgres;
