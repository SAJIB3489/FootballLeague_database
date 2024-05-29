# MySQL Database design for Football League 

#### Objective: 
Design and implement a database that captures details about football matches, including teams, players, matches, and goals. Use triggers to ``automatically update`` match results and team standings after each match.

**Software Used**
1. MySQL Workbench


#### Project Overview
The ``Bangladesh Football League database`` project was created with a view of effectively managing and automating a football league's record-keeping. ``Teams, Players, Matches, Goals, and Results`` are the five separate tables that include the data for the ``four teams``. Every table has several columns designed to meet particular data needs. Goals and results are automatically updated in the database according to the status of the match, which can be ``Scheduled``, ``In Progress``, or ``Finished``. When a match is finished, the Results table is updated with the new scores and goals. The shift from ``In Progress`` to ``Finished`` denotes the start of a match. Triggers that are dependent on changes in the match status make this automation easier. <br>

This project gives a excellent idea to design a database for the teams. This knowledge and idea could be use in different purpose in future.


![ER Diagram](/image/ER%20Diagram.png)


## Table of Contents

- [Database Schema Design](#database-schema-design)
  - [Teams](#teams)
  - [Players](#players)
  - [Matches](#matches)
  - [Goals](#goals)
  - [Results](#results)
- [Triggers](#triggers)
  - [Trigger to Update Match Results](#trigger-to-update-match-results)
  - [Trigger to Update Team Standings](#trigger-to-update-team-standings)
- [Data Insertion](#data-insertion)
  - [Teams Data](#teams-data)
  - [Players Data](#players-data)
  - [Matches Data](#matches-data)
  - [Goals Data](#goals-data)
  - [Results Data](#results-data)
- [Views](#views)
  - [Last 5 Matches](#last-5-matches)
  - [Top 5 Teams](#top-5-teams)
  - [Top 5 Scorers](#top-5-scorers)
- [Extra Commands](#extra-commands)
- [Acknowledgements](#acknowledgements)


## Database Schema Design

### Teams

```sql
CREATE TABLE Teams (
    team_id INT PRIMARY KEY,
    team_name VARCHAR(50),
    abb VARCHAR(3),
    city VARCHAR(50),
    points VARCHAR(20)
);
```

![Teams](/image/Teams.png)


### Players

```sql
CREATE TABLE Players (
    player_id INT PRIMARY KEY,
    player_name VARCHAR(50),
    team_id INT,
    position VARCHAR(3),
    nationality VARCHAR(50),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);

```

![Players](/image/Players.png)


### Matches

```sql
CREATE TABLE Matches (
    match_id INT PRIMARY KEY AUTO_INCREMENT,
    team1_id INT,
    team2_id INT,
    team1_goals INT,
    team2_goals INT,
    status VARCHAR(50),
    FOREIGN KEY (team1_id) REFERENCES Teams(team_id),
    FOREIGN KEY (team2_id) REFERENCES Teams(team_id)
);

```

![Matches](/image/Matches.png)


### Goals

```sql
CREATE TABLE Goals (
    team_id INT,
    match_id INT PRIMARY KEY AUTO_INCREMENT,
    scoring_player_id INT,
    goal_description VARCHAR(255),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id),
    FOREIGN KEY (scoring_player_id) REFERENCES Players(player_id)
);

```

![Goals](/image/goals.png)


### Results

```sql
CREATE TABLE Results (
    team_id INT PRIMARY KEY,
    points INT,
    wins INT,
    draws INT,
    losses INT,
    goals_for INT,
    goals_against INT,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);

```

![Results](/image/Results.png)


## Triggers

![Trigger idea](/image/Trigger.png)

### Trigger to Update Match Results

```sql
DELIMITER //
CREATE TRIGGER After_Match_Update
AFTER UPDATE ON Matches
FOR EACH ROW
BEGIN
    IF NEW.status = 'Finished' THEN
        UPDATE Matches m
        JOIN (SELECT match_id, team_id, COUNT(*) as goals
              FROM Goals
              GROUP BY match_id, team_id) g
        ON m.match_id = g.match_id
        SET m.team1_goals = CASE WHEN m.team1_id = g.team_id THEN g.goals ELSE m.team1_goals END,
            m.team2_goals = CASE WHEN m.team2_id = g.team_id THEN g.goals ELSE m.team2_goals END
        WHERE m.match_id = NEW.match_id;
    END IF;
END;
//
DELIMITER ;

```


### Trigger to Update Team Standings/ Goal Insertion Trigger

```sql
DELIMITER //
CREATE TRIGGER After_Match_Finish
AFTER UPDATE ON Matches
FOR EACH ROW
BEGIN
    DECLARE team1_points INT DEFAULT 0;
    DECLARE team2_points INT DEFAULT 0;
    DECLARE team1_result VARCHAR(10);
    DECLARE team2_result VARCHAR(10);

    IF NEW.status = 'Finished' THEN
        IF NEW.team1_goals > NEW.team2_goals THEN
            SET team1_points = 3, team2_points = 0;
            SET team1_result = 'win', team2_result = 'loss';
        ELSEIF NEW.team1_goals < NEW.team2_goals THEN
            SET team1_points = 0, team2_points = 3;
            SET team1_result = 'loss', team2_result = 'win';
        ELSE
            SET team1_points = 1, team2_points = 1;
            SET team1_result = 'draw', team2_result = 'draw';
        END IF;

        UPDATE Results
        SET points = points + team1_points,
            wins = wins + (team1_result = 'win'),
            draws = draws + (team1_result = 'draw'),
            losses = losses + (team1_result = 'loss'),
            goals_for = goals_for + NEW.team1_goals,
            goals_against = goals_against + NEW.team2_goals
        WHERE team_id = NEW.team1_id;

        UPDATE Results
        SET points = points + team2_points,
            wins = wins + (team2_result = 'win'),
            draws = draws + (team2_result = 'draw'),
            losses = losses + (team2_result = 'loss'),
            goals_for = goals_for + NEW.team2_goals,
            goals_against = goals_against + NEW.team1_goals
        WHERE team_id = NEW.team2_id;
    END IF;
END;
//
DELIMITER ;

```


## Data Insertion

### Teams Data

```sql
INSERT INTO Teams (team_id, team_name, abb, city, points)
VALUES
    (16782, 'Bangladesh Police FC', 'BPF', 'Mymensingh',0),
    (16049, 'Bashundhara Kings', 'BDK', 'Dhaka',0),
    (16653, 'Brothers Union', 'BSU', 'Dhaka',0),
    (16745, 'Chittagong Abahani Limited', 'CAL', 'Chittagong',0);

```


### Players Data

```sql
INSERT INTO Players (player_id, player_name, team_id, position, nationality)
VALUES
    (1, 'Russel Mahmud Liton', 16782, 'DF', 'Bangladesh'),
    (3, 'Arifur Rahman Raju', 16782, 'FW', 'Bangladesh'),
    (4, 'Mohammad Emon', 16782, 'DF', 'Bangladesh'),
    (5, 'Rabiul Islam', 16782, 'DF', 'Bangladesh'),
    (6, 'Monaem Khan Raju', 16782, 'MF', 'Bangladesh'),
    (7, 'M S Bablu', 16782, 'FW', 'Bangladesh'),
    (26, 'Anisur Rahman Zico', 16049, 'GK', 'Bangladesh'),
    (27, 'Yeasin Arafat', 16049, 'DF', 'Bangladesh'),
    (28, 'Topu Barman', 16049, 'DF', 'Bangladesh'),
    (29, 'Tutul Hossain Badsha', 16049, 'DF', 'Bangladesh'),
    (30, 'Shohel Rana', 16049, 'MF', 'Bangladesh'),
    (31, 'Masuk Mia Jony', 16049, 'MF', 'Bangladesh'),
    (42, 'Md Mojnu Miah', 16653, 'GK', 'Bangladesh'),
    (43, 'Patrick Sylva', 16653, 'MF', 'The Gambia'),
    (44, 'Md Saiful Islam', 16653, 'GK', 'Bangladesh'),
    (45, 'Pape Musa Faye', 16653, 'DF', 'The Gambia'),
    (46, 'Md Showkat Helal Mia', 16653, 'GK', 'Bangladesh'),
    (47, 'Chamir Ullah Rocky', 16653, 'FW', 'Bangladesh'),
    (55, 'Ashraful Islam Rana', 16745, 'GK', 'Bangladesh'),
    (56, 'Raihan Hasan', 16745, 'DF', 'Bangladesh'),
    (57, 'Rashedul Alam Moni', 16745, 'DF', 'Bangladesh'),
    (58, 'Yeasin Khan', 16745, 'DF', 'Bangladesh'),
    (59, 'Nasiruddin Chowdhury', 16745, 'DF', 'Bangladesh'),
    (60, 'Imran Hassan Remon', 16745, 'MF', 'Bangladesh');

```


### Matches Data

```sql
INSERT INTO Matches (match_id, team1_id, team2_id, team1_goals, team2_goals, status)
VALUES
    (1, 16782, 16049, 1, 3, 'Scheduled'),
    (2, 16653, 16745, 2, 0, 'Scheduled'),
    (3, 16782, 16653, 1, 2, 'Scheduled'),
    (4, 16049, 16745, 0, 0, 'Scheduled');

```


### Goals Data

```sql
INSERT INTO Goals (team_id, match_id, scoring_player_id, goal_description)
VALUES
    (16049, 1, 28, 'Goal scored by Bashundhara Kings'),
    (16653, 2, 43, 'Goal scored by Brothers Union'),
    (16653, 3, 46, 'Goal scored by Brothers Union');

```

### Results Data

```sql
INSERT INTO Results (team_id, points, wins, draws, losses, goals_for, goals_against)
VALUES
    (16782, 2, 0, 0, 2, 5, 2),
    (16049, 3, 1, 1, 0, 1, 3),
    (16653, 4, 2, 0, 0, 1, 4),
    (16745, 0, 0, 1, 1, 2, 0);

```


## Views

### Last 5 Matches

```sql
CREATE VIEW Last_5_Matches AS
SELECT m.match_id, m.team1_id, m.team2_id, m.status,
       (SELECT COUNT(*) FROM Goals WHERE match_id = m.match_id AND team_id = m.team1_id) AS team1_goals,
       (SELECT COUNT(*) FROM Goals WHERE match_id = m.match_id AND team_id = m.team2_id) AS team2_goals
FROM Matches m
ORDER BY m.match_id DESC
LIMIT 5;

```

![View last 5 Matches](/image/Last_5_Matches.png)


### Top 5 Teams

```sql
CREATE VIEW Top_5_Teams AS
SELECT team_id, points, wins, draws, losses, goals_for, goals_against, (goals_for - goals_against) AS goal_difference
FROM Results
ORDER BY points DESC, goal_difference DESC
LIMIT 5;

```

![View Top 5 Teams](/image/Top_5_Teams.png)


### Top 5 Scorers

```sql
CREATE VIEW Top_5_Scorers AS
SELECT p.player_id, p.player_name, t.team_name, COUNT(*) AS goals_scored
FROM Goals g
JOIN Players p ON g.scoring_player_id = p.player_id
JOIN Teams t ON g.team_id = t.team_id
GROUP BY p.player_id, p.player_name, t.team_name
ORDER BY goals_scored DESC
LIMIT 5;

```

![View Top 5 Scorers](/image/Top_5_Scorers.png)



## Extra Commands

**Some helpful command note that I used during the project**

1. Drop Trigger
```sql
DROP TRIGGER <Trigger name>;

```

2. Drop Table
```sql
DROP TABLE <Table Name>;

```

3. Check Table Data
```sql
SELECT * FROM <Table Name>;

```
4. Insert Data into a Table
```sql
INSERT INTO <Table Name> (column1, column2, ...)
VALUES (value1, value2, ...);
```
5. Update Data in a Table
```sql
UPDATE <Table Name>
SET column1 = value1, column2 = value2, ...
WHERE condition;
```
6. Delete Data from a Table
```sql
DELETE FROM <Table Name>
WHERE condition;
```
7. Select Data with a Condition
```sql
SELECT * FROM <Table Name>
WHERE condition;
```

## Acknowledgements
This database was designed and implemented as part of a project for a course, and successfully tested without errors. Special thanks to the course lecturer for his guidance and support. I received 5 points out of 5.<br>
**If you get any error feel free to send a email to me, I will assist you.**