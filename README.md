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

![Teams](/image/Players.png)


