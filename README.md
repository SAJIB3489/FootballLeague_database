# Database design for football league


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