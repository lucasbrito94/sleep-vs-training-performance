
-- 1. Inspect suspicious sleep values
SELECT
  date,
  sleep_hours
FROM health_metrics
WHERE sleep_hours < 3
ORDER BY sleep_hours ASC;


-- 2. Aggregate total sleep per day (exploratory)
SELECT
  date,
  ROUND(SUM(sleep_hours), 2) AS total_sleep_hours
FROM health_metrics
GROUP BY date
ORDER BY date;


-- 3. Create clean daily sleep view
CREATE VIEW IF NOT EXISTS daily_sleep AS
SELECT
  date,
  ROUND(SUM(sleep_hours), 2) AS total_sleep_hours
FROM health_metrics
GROUP BY date
HAVING SUM(sleep_hours) >= 3;


-- 4. Inspect daily sleep view
SELECT *
FROM daily_sleep
ORDER BY date
LIMIT 10;


-- 5. Categorize sleep duration (exploratory)
SELECT
  date,
  total_sleep_hours,
  CASE
    WHEN total_sleep_hours < 6 THEN 'Low sleep'
    WHEN total_sleep_hours BETWEEN 6 AND 8 THEN 'Adequate sleep'
    ELSE 'High sleep'
  END AS sleep_category
FROM daily_sleep
ORDER BY date
LIMIT 20;


-- 6. Inspect sleep distribution
SELECT
  MIN(total_sleep_hours) AS min_sleep,
  MAX(total_sleep_hours) AS max_sleep,
  ROUND(AVG(total_sleep_hours), 2) AS avg_sleep
FROM daily_sleep;


-- 7. Inspect unrealistic sleep values
SELECT
  date,
  total_sleep_hours
FROM daily_sleep
WHERE total_sleep_hours > 16
ORDER BY total_sleep_hours DESC;


-- 8. Create cleaned daily sleep view
CREATE VIEW IF NOT EXISTS daily_sleep_clean AS
SELECT
  date,
  total_sleep_hours
FROM daily_sleep
WHERE total_sleep_hours BETWEEN 3 AND 16;


-- 9. Inspect cleaned daily sleep sample
SELECT
  date,
  total_sleep_hours
FROM daily_sleep_clean
ORDER BY date
LIMIT 20;


-- 10. Create final sleep features view
CREATE VIEW IF NOT EXISTS sleep_features AS
SELECT
  date,
  total_sleep_hours,
  CASE
    WHEN total_sleep_hours < 6 THEN 'Low sleep'
    WHEN total_sleep_hours BETWEEN 6 AND 8 THEN 'Adequate sleep'
    ELSE 'High sleep'
  END AS sleep_category
FROM daily_sleep_clean;


-- 11. Validate sleep feature distribution
SELECT
  sleep_category,
  COUNT(*) AS days_count,
  ROUND(AVG(total_sleep_hours), 2) AS avg_sleep_hours
FROM sleep_features
GROUP BY sleep_category;


-- 12. Check date coverage of sleep features
SELECT
  MIN(date) AS start_date,
  MAX(date) AS end_date,
  COUNT(*) AS total_days
FROM sleep_features;

-- 13. Inspect raw HEVY workouts
SELECT *
FROM hevy_workouts
LIMIT 10;

SELECT *
FROM health_metrics
LIMIT 10;

-- 14. Aggregate daily workout performance
CREATE VIEW IF NOT EXISTS daily_workouts AS
SELECT
    workout_date AS date,
    COUNT(*) AS total_sets,
    COUNT(DISTINCT exercise_title) AS total_exercises,
    ROUND(SUM(weight_kg * reps), 2) AS total_volume,
    MAX(weight_kg) AS max_weight
FROM hevy_workouts
GROUP BY workout_date;

-- 14.1 Inspect daily workout metrics
SELECT *
FROM daily_workouts
ORDER BY date
LIMIT 10;


-- Fix: create daily sleep categorized view
CREATE VIEW IF NOT EXISTS daily_sleep_categorized AS
SELECT
    date,
    total_sleep_hours,
    CASE
        WHEN total_sleep_hours < 6 THEN 'Low sleep'
        WHEN total_sleep_hours BETWEEN 6 AND 8 THEN 'Adequate sleep'
        ELSE 'High sleep'
    END AS sleep_category
FROM daily_sleep_clean;


-- 15. Join daily sleep and daily workout metrics
CREATE VIEW IF NOT EXISTS sleep_workout_analysis AS
SELECT
    w.date,
    s.total_sleep_hours,
    s.sleep_category,
    w.total_sets,
    w.total_exercises,
    w.total_volume,
    w.max_weight
FROM daily_workouts w
LEFT JOIN daily_sleep_categorized s
    ON w.date = s.date;

SELECT * FROM sleep_workout_analysis ORDER BY date LIMIT 10;

SELECT DISTINCT date
FROM daily_workouts
ORDER BY date
LIMIT 5;

SELECT DISTINCT date
FROM daily_sleep_categorized
ORDER BY date
LIMIT 5;

SELECT DISTINCT w.date
FROM daily_workouts w
INNER JOIN daily_sleep_categorized s
    ON w.date = s.date
ORDER BY w.date;


-- 15.2 Final dataset: sleep vs workout (only overlapping days)
CREATE VIEW IF NOT EXISTS sleep_workout_analysis_final AS
SELECT
    w.date,
    s.total_sleep_hours,
    s.sleep_category,
    w.total_sets,
    w.total_exercises,
    w.total_volume,
    w.max_weight
FROM daily_workouts w
INNER JOIN daily_sleep_categorized s
    ON w.date = s.date
WHERE w.date >= '2025-01-01';

SELECT *
FROM sleep_workout_analysis_final
ORDER BY date
LIMIT 15;

-- 16. Compare workout performance by sleep category
SELECT
    sleep_category,
    COUNT(*) AS training_days,
    ROUND(AVG(total_volume), 2) AS avg_volume,
    ROUND(AVG(max_weight), 2) AS avg_max_weight,
    ROUND(AVG(total_sets), 2) AS avg_sets
FROM sleep_workout_analysis_final
GROUP BY sleep_category
ORDER BY avg_volume DESC;


-- 16.1 Sanity check: sleep vs workout dates
SELECT
    w.date AS workout_date,
    s.date AS sleep_date,
    s.total_sleep_hours
FROM daily_workouts w
INNER JOIN daily_sleep_categorized s
    ON w.date = s.date
ORDER BY w.date
LIMIT 10;

-- 17.1 Bucket sleep hours into continuous ranges
SELECT
    CASE
        WHEN total_sleep_hours < 5 THEN '<5h'
        WHEN total_sleep_hours BETWEEN 5 AND 6 THEN '5–6h'
        WHEN total_sleep_hours BETWEEN 6 AND 7 THEN '6–7h'
        WHEN total_sleep_hours BETWEEN 7 AND 8 THEN '7–8h'
        WHEN total_sleep_hours BETWEEN 8 AND 9 THEN '8–9h'
        ELSE '9h+'
    END AS sleep_hours_range,
    COUNT(*) AS training_days,
    ROUND(AVG(total_volume), 2) AS avg_volume,
    ROUND(AVG(max_weight), 2) AS avg_max_weight,
    ROUND(AVG(total_sets), 2) AS avg_sets
FROM sleep_workout_analysis_final
GROUP BY sleep_hours_range
ORDER BY
    CASE sleep_hours_range
        WHEN '<5h' THEN 1
        WHEN '5–6h' THEN 2
        WHEN '6–7h' THEN 3
        WHEN '7–8h' THEN 4
        WHEN '8–9h' THEN 5
        ELSE 6
    END;

-- 17.2 Raw relationship between sleep hours and workout volume
SELECT
    total_sleep_hours,
    total_volume,
    max_weight,
    total_sets
FROM sleep_workout_analysis_final
ORDER BY total_sleep_hours;

-- 18.0.1 List all distinct workout titles
SELECT DISTINCT
    title
FROM hevy_workouts
ORDER BY title;

-- 18.0.2 Count training days per workout title
SELECT
    title,
    COUNT(DISTINCT workout_date) AS training_days
FROM hevy_workouts
GROUP BY title
ORDER BY training_days DESC;

-- 18.0.3 Inspect exercises inside a specific workout type
SELECT DISTINCT
    exercise_title
FROM hevy_workouts
WHERE title = 'A - Costas e triceps'
ORDER BY exercise_title;

-- 18.1 Classify workout days by training split
CREATE VIEW IF NOT EXISTS daily_workouts_split AS
SELECT
    workout_date AS date,
    title,
    CASE
        WHEN LOWER(title) LIKE '%costas%' THEN 'Pull'
        WHEN LOWER(title) LIKE '%peito%' THEN 'Push'
        WHEN LOWER(title) LIKE '%ombro%' THEN 'Push'
        WHEN LOWER(title) LIKE '%perna%' THEN 'Legs'
        WHEN LOWER(title) LIKE '%leg%' THEN 'Legs'
        ELSE 'Other'
    END AS training_split,
    COUNT(*) AS total_sets,
    ROUND(SUM(weight_kg * reps), 2) AS total_volume,
    MAX(weight_kg) AS max_weight
FROM hevy_workouts
GROUP BY workout_date, title;


-- 18.2 Refine training split (separating compound vs isolated workouts)
CREATE VIEW IF NOT EXISTS daily_workouts_refined AS
SELECT
    workout_date AS date,
    title,
    CASE
        -- LEGS
        WHEN LOWER(title) LIKE '%perna%' THEN 'Legs'
        WHEN LOWER(title) LIKE '%quadriceps%' THEN 'Legs'
        WHEN LOWER(title) LIKE '%gluteo%' THEN 'Legs'
        WHEN LOWER(title) = 'treino c' THEN 'Legs'

        -- PULL (compound)
        WHEN LOWER(title) LIKE '%costas%' 
             AND LOWER(title) LIKE '%triceps%' THEN 'Pull (Costas + Tríceps)'

        -- PULL (isolated)
        WHEN LOWER(title) = 'costas' THEN 'Pull (Costas)'

        -- PUSH (compound)
        WHEN LOWER(title) LIKE '%peito%' 
             AND LOWER(title) LIKE '%ombro%' THEN 'Push (Peito + Ombro)'

        -- PUSH (isolated)
        WHEN LOWER(title) = 'peito' THEN 'Push (Peito)'
        WHEN LOWER(title) = 'ombro' THEN 'Shoulders (Isolated)'

        -- ARMS
        WHEN LOWER(title) LIKE '%biceps%' 
             AND LOWER(title) LIKE '%triceps%' THEN 'Arms (Bíceps + Tríceps)'

        ELSE 'Other'
    END AS training_split,
    COUNT(*) AS total_sets,
    ROUND(SUM(weight_kg * reps), 2) AS total_volume,
    MAX(weight_kg) AS max_weight
FROM hevy_workouts
GROUP BY workout_date, title;

-- 18.3 Check sample size per refined training split
SELECT
    training_split,
    COUNT(DISTINCT date) AS training_days
FROM daily_workouts_refined
GROUP BY training_split
ORDER BY training_days DESC;

-- 18.4 Sleep vs performance by training split (controlled analysis)
SELECT
    s.sleep_category,
    w.training_split,
    COUNT(*) AS training_days,
    ROUND(AVG(w.total_volume), 2) AS avg_volume,
    ROUND(AVG(w.max_weight), 2) AS avg_max_weight,
    ROUND(AVG(w.total_sets), 2) AS avg_sets
FROM daily_workouts_refined w
INNER JOIN daily_sleep_categorized s
    ON w.date = s.date
WHERE w.training_split IN (
    'Legs',
    'Arms (Bíceps + Tríceps)',
    'Pull (Costas + Tríceps)',
    'Push (Peito + Ombro)'
)
GROUP BY s.sleep_category, w.training_split
ORDER BY w.training_split, avg_volume DESC;

-- 19. Final dataset for visualization
CREATE VIEW IF NOT EXISTS sleep_workout_dashboard AS
SELECT
    w.date,
    w.training_split,
    s.sleep_category,
    s.total_sleep_hours,
    w.total_volume,
    w.max_weight,
    w.total_sets
FROM daily_workouts_refined w
INNER JOIN daily_sleep_categorized s
    ON w.date = s.date
WHERE w.training_split IN (
    'Legs',
    'Arms (Bíceps + Tríceps)',
    'Pull (Costas + Tríceps)',
    'Push (Peito + Ombro)'
);