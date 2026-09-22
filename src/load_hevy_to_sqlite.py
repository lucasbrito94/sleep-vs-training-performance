print(">>> Script HEVY started")

import pandas as pd
import sqlite3
from pathlib import Path

# Path to raw HEVY export file
BASE_DIR = Path(__file__).resolve().parent.parent

hevy_file_path = BASE_DIR / "data" / "raw" / "hevy_export.csv"
db_path = BASE_DIR / "sleep_strength.db"

# Path to SQLite database
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
db_path = BASE_DIR / "sleep_strength.db"

# Load HEVY CSV
hevy_df = pd.read_csv(hevy_file_path)

# Normalize start_time column as string
hevy_df["start_time"] = hevy_df["start_time"].astype(str).str.strip()

# Map Portuguese month abbreviations to English
month_map = {
    "Jan": "Jan",
    "Fev": "Feb",
    "Mar": "Mar",
    "Abr": "Apr",
    "Mai": "May",
    "Jun": "Jun",
    "Jul": "Jul",
    "Ago": "Aug",
    "Set": "Sep",
    "Out": "Oct",
    "Nov": "Nov",
    "Dez": "Dec",
}

for pt, en in month_map.items():
    hevy_df["start_time"] = hevy_df["start_time"].str.replace(pt, en, regex=False)

# Convert to datetime (robust parsing)
hevy_df["start_time"] = pd.to_datetime(
    hevy_df["start_time"],
    errors="coerce"
)

# Drop rows where datetime could not be parsed
hevy_df = hevy_df.dropna(subset=["start_time"])

# Create workout_date column
hevy_df["workout_date"] = hevy_df["start_time"].dt.date

# Select relevant columns
hevy_df = hevy_df[
    [
        "workout_date",
        "title",
        "exercise_title",
        "set_index",
        "set_type",
        "weight_kg",
        "reps",
        "distance_km",
        "duration_seconds",
        "rpe",
    ]
]

# Connect to SQLite
conn = sqlite3.connect(db_path)

# Write to SQLite
hevy_df.to_sql(
    "hevy_workouts",
    conn,
    if_exists="replace",
    index=False
)

conn.close()

print(">>> Script HEVY finished successfully")
