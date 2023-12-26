CREATE DATABASE sample;

\c sample;

CREATE ROLE role1 WITH PASSWORD 'postgres' LOGIN;
CREATE ROLE role2 WITH PASSWORD 'postgres' LOGIN;

GRANT postgres TO role1;
GRANT postgres TO role2;
