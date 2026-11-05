# League of Legends Worlds Performance Analysis (2011-2022)

## 📌 Project Overview
This project analyzes historical League of Legends World Championship data to determine team dominance, participation rates, and "win efficiency" (how often a team wins when they attend). It answers key esports questions: *Which team has won the most?* and *Which team was a one-hit wonder?*

## 📊 Dataset
The dataset contains match and player statistics from the World Championship events from Season 1 (2011) to Season 12 (2022). 

## 🛠️ Tools & Technologies
*   **SQL (SQLite via DBeaver):** Data cleaning, entity normalization, and advanced querying (CTEs, Window Functions).
*   **Tableau:** Interactive data visualization and dashboard design.

## ⚙️ Methodology
1.  **Data Normalization:** Esports teams frequently change names or sponsors. I used SQL `CASE WHEN` statements to unify historical team names (e.g., *SK Telecom T1* and *T1*; *Samsung White*, *Samsung Blue*, and *Samsung Galaxy*).
2.  **Champion Identification:** Since finals are Best-of-5 (Bo5), identifying the champion required finding the team with the most game wins on the final day of each season.
3.  **Participation vs. Efficiency:** Calculated the total number of distinct seasons a team participated in vs. their total titles won, to calculate a "Win Efficiency Percentage".

## 💡 Key Insights
*   **T1 (formerly SK Telecom T1) is the undisputed king:** They have the highest number of World Titles (3) and have maintained high participation over the years (7 appearances in the dataset). Faker is the only player present in all 3 of their championship rosters.
*   **Samsung Galaxy is the most efficient:** They attended 4 times and won 2 titles (50% win efficiency).
*   **Fnatic is the most persistent but least efficient:** They hold the record for most participations (10 times) but only secured 1 title (10% efficiency).
*   **One-Hit Wonders:** Teams like DRX and FunPlus Phoenix attended only twice and won once, showing they peak at the right moment.

## 📂 Repository Structure
*   `lol_worlds_analysis.sql`: The complete SQL script showing data normalization, champion identification, and efficiency calculations.
*   `team_titles.csv`: The cleaned dataset exported from SQL, containing team participations and titles.
*   `lol-worlds-dashboard.twbx`: The packaged Tableau workbook.
*   `lol-worlds-dashboard.pdf`: A static PDF export of the final dashboard.

## 🖼️ Dashboard Preview
*(You can view the full dashboard in the `lol-worlds-dashboard.pdf` file)*
*   **Bar Chart:** Total World Titles by Team (T1 dominating).
*   **Scatter Plot:** Participation vs. Win Efficiency (highlighting T1's dominance and Samsung's efficiency).
