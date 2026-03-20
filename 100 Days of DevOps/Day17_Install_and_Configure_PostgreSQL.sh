# !/bin/bash

ssh peter@stdb01
sudo su -

# Access the PostgreSQL Prompt
su - postgres
psql

# Create the User and Database
CREATE USER kodekloud_rin WITH PASSWORD 'GyQkFRVNr3';
CREATE DATABASE kodekloud_db10;
GRANT ALL PRIVILEGES ON DATABASE kodekloud_db10 TO kodekloud_rin;

# Verify and Exit
\l
\du
\q
