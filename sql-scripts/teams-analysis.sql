/*
Project: League of Legends Worlds Performance Analysis (2011-2022)
Dataset: Worlds Match Stats
Description: End-to-end SQL script to clean historical team names, identify World Champions, 
and calculate team win efficiency (Titles vs. Participations).
*/

-- ==============================================================================
-- 1. NORMALIZE TEAM NAMES & CALCULATE PARTICIPATIONS
-- ==============================================================================
-- Esports teams frequently change names/sponsors. We unify historical names 
-- to ensure accurate participation counts (e.g., SK Telecom T1 and T1 are the same team).

WITH AllTeams AS (
    -- Extract and clean Blue side teams
    SELECT season, 
        CASE 
            WHEN blue_team IN ('SK_Telecom_T1', 'T1') THEN 'T1'
            WHEN blue_team IN ('Moscow_Five', 'Gambit_Gaming', 'Gambit_Esports') THEN 'Gambit_Esports'
            WHEN blue_team IN ('Royal_Club', 'Royal_Never_Give_Up') THEN 'Royal_Never_Give_Up'
            WHEN blue_team IN ('Samsung_White', 'Samsung_Blue', 'Samsung_Galaxy') THEN 'Samsung_Galaxy'
            WHEN blue_team IN ('Counter_Logic_Gaming_Europe', 'Counter_Logic_Gaming') THEN 'Counter_Logic_Gaming'
            ELSE blue_team 
        END AS team
    FROM matchs_stats
    UNION
    -- Extract and clean Red side teams
    SELECT season, 
        CASE 
            WHEN red_team IN ('SK_Telecom_T1', 'T1') THEN 'T1'
            WHEN red_team IN ('Moscow_Five', 'Gambit_Gaming', 'Gambit_Esports') THEN 'Gambit_Esports'
            WHEN red_team IN ('Royal_Club', 'Royal_Never_Give_Up') THEN 'Royal_Never_Give_Up'
            WHEN red_team IN ('Samsung_White', 'Samsung_Blue', 'Samsung_Galaxy') THEN 'Samsung_Galaxy'
            WHEN red_team IN ('Counter_Logic_Gaming_Europe', 'Counter_Logic_Gaming') THEN 'Counter_Logic_Gaming'
            ELSE red_team 
        END AS team
    FROM matchs_stats
),
Participations AS (
    -- Count how many distinct seasons each team participated in
    SELECT team, COUNT(DISTINCT season) AS total_participations
    FROM AllTeams
    GROUP BY team
),

-- ==============================================================================
-- 2. IDENTIFY THE WORLD CHAMPION FOR EACH SEASON
-- ==============================================================================
-- Champions are determined by the team that won the most games on the final day 
-- of the tournament (since Finals are Best-of-5 matches).

FinalDay AS (
    SELECT season, MAX(date) AS final_date
    FROM matchs_stats 
    WHERE event = 'Main' 
    GROUP BY season
),
WinsOnFinalDay AS (
    SELECT m.season, m.winner, COUNT(*) as games_won
    FROM matchs_stats m
    JOIN FinalDay f ON m.season = f.season AND m.date = f.final_date
    WHERE m.event = 'Main'
    GROUP BY m.season, m.winner
),
RankedWinners AS (
    -- Unify winner names and rank them to find the true champion
    SELECT season, 
        CASE 
            WHEN winner IN ('SK_Telecom_T1', 'T1') THEN 'T1'
            WHEN winner IN ('Moscow_Five', 'Gambit_Gaming', 'Gambit_Esports') THEN 'Gambit_Esports'
            WHEN winner IN ('Royal_Club', 'Royal_Never_Give_Up') THEN 'Royal_Never_Give_Up'
            WHEN winner IN ('Samsung_White', 'Samsung_Blue', 'Samsung_Galaxy') THEN 'Samsung_Galaxy'
            WHEN winner IN ('Counter_Logic_Gaming_Europe', 'Counter_Logic_Gaming') THEN 'Counter_Logic_Gaming'
            ELSE winner 
        END AS winner, 
        ROW_NUMBER() OVER(PARTITION BY season ORDER BY games_won DESC) as rn
    FROM WinsOnFinalDay
),
Champions AS (
    SELECT season, winner AS team 
    FROM RankedWinners 
    WHERE rn = 1
),
Titles AS (
    -- Count total titles per team
    SELECT team, COUNT(season) AS total_titles 
    FROM Champions 
    GROUP BY team
)

-- ==============================================================================
-- 3. FINAL OUTPUT: TITLES VS. PARTICIPATIONS (WIN EFFICIENCY)
-- ==============================================================================

SELECT 
    t.team,
    p.total_participations,
    t.total_titles,
    -- Calculate win efficiency: (Titles / Participations) * 100
    ROUND((CAST(t.total_titles AS FLOAT) / p.total_participations) * 100, 1) AS win_efficiency_percentage
FROM 
    Titles t
JOIN 
    Participations p ON t.team = p.team
ORDER BY 
    win_efficiency_percentage DESC, t.total_titles DESC;