# 💤📊 Sleep vs Training Performance

**Analyzing the Relationship Between Sleep and Strength Training Performance**

---

## 1. Context & Objective

This project combines two personal interests of mine: **data analysis and strength training**.

Sleep plays an important role in recovery and physical performance, but its relationship with day-to-day training performance is not always straightforward.

The objective of this project is to investigate whether **sleep duration is associated with differences in strength training performance**, using real-world personal data collected from **Apple Health** and **HEVY**.

The analysis focuses on three main training metrics:

- Total training volume
- Maximum weight lifted
- Total number of sets

The project also evaluates whether the relationship between sleep and training performance changes depending on the type of workout performed.

The goal is not to establish a causal relationship, but to identify patterns and demonstrate how personal data can be transformed into analytical insights through a complete data workflow.

---

## 2. Data Sources

### 2.1 Apple Health — Sleep Data

- **Source:** Apple Watch / Apple Health
- **Data type:** Sleep sessions
- **Raw format:** XML
- **Main metric:** Total sleep duration per day (hours)

**Processing:**

- Sleep sessions were parsed and normalized using Python
- Multiple sleep sessions were aggregated into daily totals

### 2.2 HEVY — Strength Training Data

- **Source:** HEVY workout tracking app
- **Data type:** Strength training logs
- **Raw format:** CSV

**Main metrics:**

- Total training volume (weight × repetitions)
- Maximum weight lifted per workout day
- Total number of sets
- Training split

Workout types were classified into groups such as:

- Legs
- Push (Chest + Shoulders)
- Pull (Back)
- Arms (Biceps + Triceps)
- Isolated Shoulders

> Raw personal data is not included in this repository.

---

## 3. Methodology

### 3.1 Data Pipeline

The project follows an end-to-end analytical workflow:

```text
Apple Health (XML) ──┐
                     ├── Python (ETL) → SQLite → SQL → CSV → Power BI
HEVY (CSV) ──────────┘

```

- **Python** was used for data ingestion, parsing, cleaning and transformation.
- **SQLite** was used for data storage and analytical querying.
- **SQL** was used for aggregations, feature engineering and analysis.
- **CSV** was used as the data interface between the analytical layer and Power BI.
- **Power BI** was used for visualization and exploratory analysis.

### 3.2 Feature Engineering

The analysis includes:

- Aggregation of sleep sessions into daily sleep duration
- Categorization of sleep duration
- Aggregation of workout data by day
- Calculation of total training volume
- Calculation of maximum weight lifted
- Calculation of total sets
- Classification of workouts into training splits

### 3.3 Analytical Approach

Training performance was analyzed using different levels of granularity:

1. Broader sleep categories
2. More granular sleep-duration ranges
3. Separate analysis by training split

Training splits were considered separately because absolute workload can differ substantially between workout types. Comparing raw training volume from different workout types directly can therefore be misleading.

---

## 4. Analysis & Key Findings

### 4.1 Sleep Duration vs Training Performance

The analysis suggests that training performance was generally lower on training days preceded by shorter sleep.

When workouts were grouped by sleep category, the average training volume was:

| Sleep Category | Training Days | Average Volume | Average Max Weight | Average Sets |
|---|---:|---:|---:|---:|
| Low sleep | 21 | 8,933 | 59.2 kg | 27.2 |
| Adequate sleep | 84 | 10,212 | 75.1 kg | 29.1 |
| High sleep | 10 | 10,365 | 76.0 kg | 30.1 |

The data therefore shows a noticeable difference between **low-sleep days and the other sleep categories**.

However, the relationship is not perfectly linear, and the number of observations in some categories is relatively small.

For this reason, the results should be interpreted as **observed patterns within this dataset**, rather than as evidence that a specific number of hours of sleep universally produces better training performance.

### 4.2 Sleep Duration Ranges

The analysis also examined training performance across more granular sleep-duration ranges.

Observed average training volume:

| Sleep Duration | Training Days | Average Volume |
|---|---:|---:|
| 5–6 hours | 22 | 9,218 |
| 6–7 hours | 66 | 10,352 |
| 7–8 hours | 17 | 9,376 |
| 8–9 hours | 8 | 10,734 |
| 9+ hours | 2 | 8,889 |

The results do **not** support a simple "more sleep always means more performance" relationship.

The 8–9 hour group showed the highest average volume, but it contained only 8 training days, while the 9+ hour group contained only 2 days.

Therefore, the more defensible interpretation is that **short sleep was associated with lower average training performance in this dataset, while the relationship among higher sleep durations was less consistent**.

### 4.3 Impact of Sleep by Training Split

Training type was analyzed separately because absolute training volume varies substantially between different workouts.

For example, comparing a leg workout directly with an arm workout could create misleading conclusions because the exercises, loads and total workload are inherently different.

The analysis therefore considered training splits such as:

- Legs
- Push
- Pull
- Arms
- Isolated Shoulders

The results suggest that the relationship between sleep and performance **can vary depending on the training session**.

However, several training/sleep combinations contain relatively few observations. Therefore, these differences should be treated as **exploratory patterns rather than statistically established effects**.

> **Context matters when comparing performance metrics.**

### 4.4 General Observations

The main observations from the analysis are:

- Shorter sleep was associated with lower average training volume in this dataset.
- Maximum weight and total sets followed a similar general pattern.
- The relationship between sleep and performance was not strictly linear.
- Training type is an important contextual variable when analyzing performance.
- Small sample sizes can strongly influence averages and must be considered when interpreting results.
- The data supports further investigation rather than a universal conclusion about an "optimal" amount of sleep.

---

## 5. Limitations

### Single-Subject Dataset

All observations come from one individual.

Therefore, the results cannot be generalized to the broader population.

### Observational Analysis

The project observes naturally occurring sleep and training patterns.

It does not use a controlled experiment, meaning that **causal relationships cannot be established**.

### Confounding Variables

Several factors may influence training performance but were not controlled for, including:

- Nutrition
- Stress
- Training periodization
- Exercise selection
- Recovery strategies
- Daily activity
- Motivation
- Other physiological variables

### Sample Size

Some combinations of sleep category and training type contain relatively few observations.

This makes their averages more sensitive to individual sessions and reduces confidence in strong conclusions.

### Training Workload

Training volume and maximum weight depend heavily on the type of workout.

Although training splits were introduced to reduce this problem, other differences between individual sessions may still remain.

---

## 6. Next Steps

Possible improvements for future versions of the project include:

- Incorporating HRV as an additional recovery indicator
- Incorporating resting heart rate
- Including additional Apple Health metrics
- Analyzing sleep consistency rather than only sleep duration
- Applying correlation and regression analysis
- Controlling for training type and workload more systematically
- Analyzing performance trends over different training phases
- Extending the dataset over a longer period
- Automating the ETL pipeline
- Automating dashboard updates

A future version could also investigate whether **sleep consistency** is more strongly associated with training performance than sleep duration alone.

---

## 7. Tools & Technologies

- Python
  - pandas
  - sqlite3
  - xml.etree.ElementTree
- SQL
- SQLite
- Power BI
- Git
- GitHub
- Visual Studio Code

---

## 8. Project Structure

```text
sleep-strength/
├── sql/
│   └── health_queries.sql
├── src/
│   ├── convert_health.py
│   ├── export_dashboard_csv.py
│   ├── load_hevy_to_sqlite.py
│   └── load_to_sqlite.py
├── .gitignore
└── README.md
```

Raw personal data and the SQLite database are intentionally excluded from the public repository.

---

## 9. Conclusion

This project demonstrates a complete data analytics workflow using real-world personal data.

The project combines:

**Data ingestion → ETL → Data modeling → SQL analysis → Feature engineering → Visualization → Interpretation**

The analysis found a noticeable difference in average training performance between days preceded by shorter sleep and days with higher sleep duration.

At the same time, the results demonstrate why data analysis requires context and methodological caution. Training type, sample size and uncontrolled variables can substantially affect the observed results.

Rather than attempting to establish a universal relationship between sleep and strength performance, this project demonstrates how personal data can be transformed into **structured, reproducible and critically interpreted analytical insights**.

The project also serves as a practical demonstration of skills in:

- Data cleaning
- ETL
- SQL
- SQLite
- Python
- Data modeling
- Exploratory analysis
- Power BI
- Data storytelling
- Analytical reasoning

---

## 10. Repository Notes

The repository contains the analytical code and documentation required to understand the project workflow.

Personal raw datasets and the SQLite database are intentionally excluded to protect private data.

The project is therefore presented as a **portfolio case study**, focusing on the analytical process, methodology and insights rather than exposing the underlying personal records.