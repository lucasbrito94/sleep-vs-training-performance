import sqlite3
import pandas as pd
from pathlib import Path

# -------------------------------------------------
# Project base path
# This ensures paths work regardless of where
# the script is executed from
# -------------------------------------------------
BASE_PATH = Path(__file__).resolve().parents[1]

# -------------------------------------------------
# Input CSV (processed health data)
# -------------------------------------------------
CSV_PATH = BASE_PATH / "data" / "processed" / "health_metrics.csv"

# -------------------------------------------------
# SQLite database path (will be created if it doesn't exist)
# -------------------------------------------------
DB_PATH = BASE_PATH / "sleep_strength.db"

# -------------------------------------------------
# Connect to SQLite database
# -------------------------------------------------
conn = sqlite3.connect(DB_PATH)

# -------------------------------------------------
# Load CSV into a Pandas DataFrame
# -------------------------------------------------
df = pd.read_csv(CSV_PATH)

# -------------------------------------------------
# Write DataFrame to SQLite table
# If the table already exists, it will be replaced
# -------------------------------------------------
df.to_sql(
    name="health_metrics",
    con=conn,
    if_exists="replace",
    index=False
)

# -------------------------------------------------
# Close database connection
# -------------------------------------------------
conn.close()

print("SQLite database created successfully!")
print("Table 'health_metrics' loaded into database:")
print(DB_PATH)