import sqlite3
import pandas as pd
from pathlib import Path

# Base directory
BASE_DIR = Path(__file__).resolve().parent.parent

# Database path
db_path = BASE_DIR / "sleep_strength.db"

# Output CSV path
output_path = BASE_DIR / "data" / "processed" / "sleep_workout_dashboard.csv"

# Connect to SQLite
conn = sqlite3.connect(db_path)

# Query final dashboard view
query = """
SELECT *
FROM sleep_workout_dashboard
"""

df = pd.read_sql(query, conn)

conn.close()

# Save CSV
df.to_csv(output_path, index=False)

print("CSV exportado com sucesso!")
print(output_path)