-- ==================================================
-- xxxxxxxxxxxxx NAME: MD SAJIB PRAMANIC xxxxxxxxxxxx

-- Note: I selected the BangladeshFootballLeague as a Default Schema
-- ==================================================






-- =====Step 1: Database Schema Design=============




/*
1. SQL command to create a database named FootballLeague.
*/
-- Command below
CREATE DATABASE BangladeshFootballLeague;

/*
2. SQL command to create a table named Teams and define the data type.
*/
-- Command below
CREATE TABLE Teams (
    team_id INT PRIMARY KEY,  /*team_id is PK */
    team_name VARCHAR(50),
    abb VARCHAR(3),
    city VARCHAR(50),
    points VARCHAR(20)
);

-- Check Them
SELECT *
FROM Teams;


/*
3. SQL command to create a table named Players and define the data type.
*/
-- Command below
CREATE TABLE Players (
    player_id INT PRIMARY KEY,  /*player_id is PK */
    player_name VARCHAR(50),
    team_id INT,
    position VARCHAR(3),
    nationality VARCHAR(50),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);

-- Check Them
SELECT *
FROM Players;

/*
4. SQL command to create a table named Matches and define the data type.
*/
-- Command below
CREATE TABLE Matches (
    match_id INT PRIMARY KEY AUTO_INCREMENT,  /*match_id is PK */
    team1_id INT,
    team2_id INT,
    team1_goals INT,
    team2_goals INT,
    status VARCHAR(50),
    FOREIGN KEY (team1_id) REFERENCES Teams(team_id),
    FOREIGN KEY (team2_id) REFERENCES Teams(team_id)
);

-- Check Them
SELECT *
FROM Matches;

/*
5. SQL command to create a table named Goals and define the data type.
*/
-- Command below
CREATE TABLE Goals (
    team_id INT,
    match_id INT PRIMARY KEY AUTO_INCREMENT,
    scoring_player_id INT, 
    goal_description VARCHAR(255),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id),
    FOREIGN KEY (scoring_player_id) REFERENCES Players(player_id) -- Foreign key constraint for the scoring player
);

-- Check Them
SELECT *
FROM Goals;


/*
6. SQL command to create a table named Results and define the data type.
*/
-- Command below
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

-- Check Them
SELECT *
FROM Results;


-- =====Step 2: Implementing Triggers=============



/*
7. SQL command to Trigger to Update Match Results.
*/
-- Command below

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

-- Check them
SHOW CREATE TRIGGER After_Match_Update;


/*
8. SQL command to Trigger to Update Team Standings in Results Table.
*/
-- Command below
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
        -- Determine points and result based on goals
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

        -- Update Results for team1
        UPDATE Results
        SET points = points + team1_points,
            wins = wins + (team1_result = 'win'),
            draws = draws + (team1_result = 'draw'),
            losses = losses + (team1_result = 'loss'),
            goals_for = goals_for + NEW.team1_goals,
            goals_against = goals_against + NEW.team2_goals
        WHERE team_id = NEW.team1_id;

        -- Update Results for team2
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

-- Check them
SHOW CREATE TRIGGER After_Match_Finish;





-- =====Step 3: Inserting data to tables:=============



/*
9. SQL command to insert the data in to the table named Teams.
*/
-- Command below
INSERT INTO Teams (team_id, team_name, abb, city, points)
VALUES
    (16782, 'Bangladesh Police FC', 'BPF', 'Mymensingh',0), -- A
    (16049, 'Bashundhara Kings', 'BDK', 'Dhaka',0), -- B
    (16653, 'Brothers Union', 'BSU', 'Dhaka',0), -- C
    (16745, 'Chittagong Abahani Limited', 'CAL', 'Chittagong',0); -- D
    
  -- Check Them
SELECT *
FROM Teams;  


/*
10. SQL command to insert the data in to the table named Players.
*/
-- Command below

INSERT INTO Players (player_id, player_name, team_id, position, nationality)
VALUES
    -- Bangladesh Police FC
    (1, 'Russel Mahmud Liton', 16782, 'DF', 'Bangladesh'),
    (3, 'Arifur Rahman Raju', 16782, 'FW', 'Bangladesh'),
    (4, 'Mohammad Emon', 16782, 'DF', 'Bangladesh'),
    (5, 'Rabiul Islam', 16782, 'DF', 'Bangladesh'),
    (6, 'Monaem Khan Raju', 16782, 'MF', 'Bangladesh'),
    (7, 'M S Bablu', 16782, 'FW', 'Bangladesh'),

    -- Bashundhara Kings
    (26, 'Anisur Rahman Zico', 16049, 'GK', 'Bangladesh'),
    (27, 'Yeasin Arafat', 16049, 'DF', 'Bangladesh'),
    (28, 'Topu Barman', 16049, 'DF', 'Bangladesh'),
    (29, 'Tutul Hossain Badsha', 16049, 'DF', 'Bangladesh'),
    (30, 'Shohel Rana', 16049, 'MF', 'Bangladesh'),
    (31, 'Masuk Mia Jony', 16049, 'MF', 'Bangladesh'),
    
    -- Brothers Union
    (42, 'Md Mojnu Miah', 16653, 'GK', 'Bangladesh'),
    (43, 'Patrick Sylva', 16653, 'MF', 'The Gambia'),
    (44, 'Md Saiful Islam', 16653, 'GK', 'Bangladesh'),
    (45, 'Pape Musa Faye', 16653, 'DF', 'The Gambia'),
    (46, 'Md Showkat Helal Mia', 16653, 'GK', 'Bangladesh'),
    (47, 'Chamir Ullah Rocky', 16653, 'FW', 'Bangladesh'),

    -- Chittagong Abahani Limited
    (55, 'Ashraful Islam Rana', 16745, 'GK', 'Bangladesh'),
    (56, 'Raihan Hasan', 16745, 'DF', 'Bangladesh'),
    (57, 'Rashedul Alam Moni', 16745, 'DF', 'Bangladesh'),
    (58, 'Yeasin Khan', 16745, 'DF', 'Bangladesh'),
    (59, 'Nasiruddin Chowdhury', 16745, 'DF', 'Bangladesh'),
    (60, 'Imran Hassan Remon', 16745, 'MF', 'Bangladesh');
   
-- Check Them
SELECT *
FROM Players;





-- =====Simulating Match Rounds=============


/*
11. SQL command to insert the data in to the table named Matches.
*/
-- Command below 
-- Initial status of 'Scheduled':

INSERT INTO Matches (match_id, team1_id, team2_id, team1_goals, team2_goals, status)
VALUES
    (1, 16782, 16049, 1, 3, 'Scheduled'), -- Team A vs. Team B
    (2, 16653, 16745, 2, 0, 'Scheduled'), -- Team C vs. Team D
    (3, 16782, 16653, 1, 2, 'Scheduled'), -- Team A vs. Team C
    (4, 16049, 16745, 0, 0, 'Scheduled'); -- Team B vs. Team D
  
  -- Check Them
SELECT *
FROM Matches;


/*
12. SQL command to update the data in to the table named Matches.
*/
-- Command below 
-- Matches started, status 'In Progress'

UPDATE Matches SET status = 'In Progress'
WHERE match_id IN (1, 2, 3, 4);

-- Check Them
SELECT *
FROM Matches;


/*
13. SQL command to Adding Goals in to the table named Goals.
*/
-- Command below
INSERT INTO Goals (team_id, match_id, scoring_player_id, goal_description)
VALUES
    (16049, 1, 28, 'Goal scored by Bashundhara Kings'),
    (16653, 2, 43, 'Goal scored by Brothers Union'),
    (16653, 3, 46, 'Goal scored by Brothers Union');
  
  -- Check Them
SELECT *
FROM Goals;  

/*
14. SQL command to insert the data in to the table named Results Manually. (Optional)
*/
-- Command below
INSERT INTO Results (team_id, points, wins, draws, losses, goals_for, goals_against)
VALUES
    (16782, 2, 0, 0, 2, 5, 2),
    (16049, 3, 1, 1, 0, 1, 3),
    (16653, 4, 2, 0, 0, 1, 4),
    (16745, 0, 0, 1, 1, 2, 0);
    
-- Check Them
SELECT *
FROM Results;





-- =====Completing the Match and Triggering Results Update=============


/*
15. SQL command to update the data in to the table named Matches.
*/
-- Command below 
-- Matches Finished, status 'Finished'

UPDATE Matches
SET status = 'Finished'
WHERE match_id IN (1, 2, 3, 4);

-- Check Them
SELECT *
FROM Matches;





-- =====Step 4: Creating Views ========================


/*
16. SQL command to create a view for Last 5 Matches.
*/
-- Command below 

CREATE VIEW Last_5_Matches AS
SELECT m.match_id, m.team1_id, m.team2_id, m.status,
       (SELECT COUNT(*) FROM Goals WHERE match_id = m.match_id AND team_id = m.team1_id) AS team1_goals,
       (SELECT COUNT(*) FROM Goals WHERE match_id = m.match_id AND team_id = m.team2_id) AS team2_goals
FROM Matches m
ORDER BY m.match_id DESC
LIMIT 5;


-- Check the VIEW
SELECT *
FROM Last_5_Matches;


/*
17. SQL command to create a view for Top 5 Teams.
*/
-- Command below 

CREATE VIEW Top_5_Teams AS
SELECT team_id, points, wins, draws, losses, goals_for, goals_against, (goals_for - goals_against) AS goal_difference
FROM Results
ORDER BY points DESC, goal_difference DESC
LIMIT 5;

-- Check the VIEW
SELECT *
FROM Top_5_Teams;


/*
18. SQL command to create a view for Top 5 Scorers View.
It will show Top 5 goal scorers player according to the given instruction in your question. (player who scored)
*/
-- Command below 

CREATE VIEW Top_5_Scorers AS
SELECT p.player_id, p.player_name, t.team_name, COUNT(*) AS goals_scored
FROM Goals g
JOIN Players p ON g.scoring_player_id = p.player_id
JOIN Teams t ON g.team_id = t.team_id
GROUP BY p.player_id, p.player_name, t.team_name
ORDER BY goals_scored DESC
LIMIT 5;



-- Check the VIEW
SELECT *
FROM Top_5_Scorers;






-- =====EXTRA COMMAND =============

/*
-- Some Command


1. Drop Trigger 
DROP Trigger <Trigger name>;

2. Drop Table
DROP Table <Table Name>;

3. Check Table Data
SELECT *
FROM <Table Name>;

4. Insert Data into a Table
INSERT INTO <Table Name> (column1, column2, ...)
VALUES (value1, value2, ...);

5. Update Data in a Table
UPDATE <Table Name>
SET column1 = value1, column2 = value2, ...
WHERE condition;

6. Delete Data from a Table
DELETE FROM <Table Name>
WHERE condition;

7. Select Data with a Condition
SELECT *
FROM <Table Name>
WHERE condition;


--I have tested the full database and command several times, it runs successfully and there is no error.

--=================THANK YOU SO MUCH=============
*/
