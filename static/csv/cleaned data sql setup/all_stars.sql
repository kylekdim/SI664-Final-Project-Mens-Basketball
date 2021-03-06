SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS league, all_star, team, team_stat, person_record, coach, team_align, temp_team_align;
SET FOREIGN_KEY_CHECKS=1;

--
-- 2.x league table
--
CREATE TABLE IF NOT EXISTS league (
  league_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  league_abbrev VARCHAR(10) NOT NULL UNIQUE,
  League_name VARCHAR(50) NOT NULL UNIQUE,
  PRIMARY KEY (league_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO league (league_abbrev, league_name) VALUES
  ('NBA', 'National Basketball Association'), ('ABL1', 'American Basketball League'), ('ABA', 'American Basketball Association'), ('NBL', 'National Basketball League'), ('PBLA', 'Professional Basketball League of America'); 


--
-- 2.x person_record table
--

CREATE TABLE IF NOT EXISTS person_record (
  person_record_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  person_id_long VARCHAR(10) NOT NULL UNIQUE,
  first_name VARCHAR(30),
  middle_name VARCHAR(30),
  last_name VARCHAR(30) NOT NULL,
  full_given_name VARCHAR(100),
  name_suffix VARCHAR(5),
  nickname VARCHAR(30),
  pos VARCHAR(10),
  height INTEGER,
  weight INTEGER,
  college VARCHAR(50),
  birthdate VARCHAR(20),
  birth_city VARCHAR(50),
  birth_state VARCHAR(20),
  birth_country VARCHAR(50),
  high_school VARCHAR(50),
  hs_city VARCHAR(50),
  hs_state VARCHAR(20),
  hs_country VARCHAR(30),
  death_date VARCHAR(20),
  race VARCHAR(3),
  PRIMARY KEY (person_record_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE 'basketball_master_cleaned.csv'
INTO TABLE person_record
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ',' ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (person_id_long, first_name, middle_name, last_name, full_given_name, name_suffix, nickname, pos, height, weight, college, birthdate, birth_city, birth_state, birth_country, high_school, hs_city, hs_state, hs_country, death_date, race);

-- --------------------------------------------------------------------------------
-- Create Temp Tables to Create Foreign Keys
-- --------------------------------------------------------------------------------


--
-- 3.x temporary team table
--

CREATE TEMPORARY TABLE temp_team (
  team_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  league_abbrev VARCHAR(10) NOT NULL,
  team_abbrev VARCHAR (10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (team_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE 'team_dedup2.csv'
INTO TABLE temp_team
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ',' ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (league_abbrev, team_abbrev, name);

--
-- 3.x production team table
--

CREATE TABLE IF NOT EXISTS team (
  team_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  league_id INTEGER NOT NULL,
  team_abbrev VARCHAR (10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (team_id),
  FOREIGN KEY (league_id) REFERENCES league(league_id)
  ON DELETE CASCADE ON UPDATE CASCADE
  )
  ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO team
(
  team_id,
  league_id,
  team_abbrev,
  name
)
SELECT tt.team_id, l.league_id, tt.team_abbrev, tt.name
FROM temp_team tt
  LEFT JOIN league l
  ON TRIM(tt.league_abbrev) = TRIM(l.league_abbrev)
WHERE tt.name IS NOT NULL;

--
-- 3.x temporary team_stat table
--

CREATE TEMPORARY TABLE temp_team_stat (
  team_stat_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  team_abbrev VARCHAR(10) NOT NULL,
  year INTEGER NOT NULL,
  home_won INTEGER NOT NULL,
  home_lost INTEGER NOT NULL,
  away_won INTEGER NOT NULL,
  away_lost INTEGER NOT NULL,
  neut_won INTEGER NOT NULL,
  neut_lost INTEGER NOT NULL,
  won INTEGER NOT NULL,
  lost INTEGER NOT NULL,
  games INTEGER NOT NULL,
  PRIMARY KEY (team_stat_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE 'team_stat_cleaned.csv'
INTO TABLE temp_team_stat
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ',' ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (team_abbrev, year, home_won, home_lost, away_won, away_lost, neut_won, neut_lost, won, lost, games);

--
-- 3.x production team_stat table
--

CREATE TABLE IF NOT EXISTS team_stat (
  team_stat_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  team_id INTEGER NOT NULL,
  year INTEGER NOT NULL,
  home_won INTEGER NOT NULL,
  home_lost INTEGER NOT NULL,
  away_won INTEGER NOT NULL,
  away_lost INTEGER NOT NULL,
  neut_won INTEGER NOT NULL,
  neut_lost INTEGER NOT NULL,
  won INTEGER NOT NULL,
  lost INTEGER NOT NULL,
  games INTEGER NOT NULL,
  PRIMARY KEY (team_stat_id),
  FOREIGN KEY (team_id) REFERENCES team(team_id)
  ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO team_stat
(
  team_id,
  year,
  home_won,
  home_lost,
  away_won,
  away_lost,
  neut_won,
  neut_lost,
  won,
  lost,
  games
)
SELECT t.team_id, tts.year, tts.home_won, tts.home_lost, tts.away_won, tts.away_lost, tts.neut_won, tts.neut_lost, tts.won, tts.lost, tts.games
FROM temp_team_stat tts
  LEFT JOIN team t
  ON TRIM(tts.team_abbrev) = TRIM(t.team_abbrev)
WHERE tts.team_stat_id IS NOT NULL;



--
-- 2.x all_star table
--

CREATE TEMPORARY TABLE temp_all_star (
  all_star_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  person_id_long VARCHAR(10) NOT NULL,
  year INTEGER NOT NULL,
  conference VARCHAR(20) NOT NULL,
  league_abbrev VARCHAR(20) NOT NULL,
  games_played INTEGER,
  minutes INTEGER,
  points INTEGER,
  rebounds INTEGER,
  assists INTEGER,
  steals INTEGER,
  blocks INTEGER,
  turnovers INTEGER,
  ft_attempted INTEGER,
  ft_made INTEGER,
  three_attempted INTEGER,
  three_made INTEGER,
  PRIMARY KEY (all_star_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE 'all_star_cleaned.csv'
INTO TABLE temp_all_star
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ',' ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (person_id_long, year, conference, league_abbrev, games_played, minutes, points, rebounds, assists, steals, blocks, turnovers, ft_attempted, ft_made, three_attempted, three_made);

CREATE TABLE IF NOT EXISTS all_star (
  all_star_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  person_record_id INTEGER NOT NULL,
  year INTEGER NOT NULL,
  conference VARCHAR(20),
  league_id INTEGER NOT NULL,
  games_played INTEGER,
  minutes INTEGER,
  points INTEGER,
  rebounds INTEGER,
  assists INTEGER,
  steals INTEGER,
  blocks INTEGER,
  turnovers INTEGER,
  ft_attempted INTEGER,
  ft_made INTEGER,
  three_attempted INTEGER,
  three_made INTEGER,
  PRIMARY KEY (all_star_id),
  FOREIGN KEY (person_record_id) REFERENCES person_record(person_record_id)
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (league_id) REFERENCES league(league_id)
  ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO all_star
(
  all_star_id,
  person_record_id,
  year,
  conference,
  league_id,
  games_played,
  minutes,
  points,
  rebounds,
  assists,
  steals,
  blocks,
  turnovers,
  ft_attempted,
  ft_made,
  three_attempted,
  three_made
)
SELECT tas.all_star_id, pr.person_record_id, tas.year, tas.conference, l.league_id, tas.games_played, tas.minutes, tas.points, tas.rebounds, tas.assists, tas.steals, tas.blocks, tas.turnovers, tas.ft_attempted, tas.ft_made, tas.three_attempted, tas.three_made
FROM temp_all_star tas
LEFT JOIN person_record pr
ON TRIM(tas.person_id_long) = TRIM(pr.person_id_long)
LEFT JOIN league l
ON TRIM(tas.league_abbrev) = TRIM(l.league_abbrev)
WHERE tas.all_star_id IS NOT NULL;


--
-- 2.x draft temp table
--

CREATE TEMPORARY TABLE temp_team_align (
  team_align_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  person_id_long VARCHAR(10) NOT NULL,
  year INTEGER NOT NULL,
  stint INTEGER,
  team_abbrev VARCHAR(3) NOT NULL,
  league_abbrev VARCHAR(10) NOT NULL,
  games_played INTEGER,
  minutes INTEGER,
  points INTEGER,
  assists INTEGER
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE 'basketball_team_align.csv'
INTO TABLE temp_team_align
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ',' ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (person_id_long, year, stint, team_abbrev, league_abbrev, games_played, minutes, points, assists);



--
-- 3.x draft production table
--


CREATE TABLE IF NOT EXISTS team_align (
  team_align_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  person_record_id INTEGER NOT NULL,
  year INTEGER NOT NULL,
  stint INTEGER,
  team_id INTEGER NOT NULL,
  league_id INTEGER NOT NULL,
  games_played INTEGER,
  minutes INTEGER,
  points INTEGER,
  assists INTEGER,
  PRIMARY KEY (team_align_id),
  FOREIGN KEY (team_id) REFERENCES team(team_id)
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (person_record_id) REFERENCES person_record(person_record_id)
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (league_id) REFERENCES league(league_id)
  ON DELETE CASCADE ON UPDATE CASCADE
)

ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO team_align
(
  team_align_id,
  person_record_id,
  year,
  stint,
  team_id,
  league_id,
  games_played,
  minutes,
  points,
  assists
)
SELECT tta.team_align_id, pr.person_record_id, tta.year, tta.stint, t.team_id, l.league_id, tta.games_played, tta.minutes, tta.points, tta.assists
FROM temp_team_align tta
LEFT JOIN person_record pr
ON TRIM(tta.person_id_long) = TRIM(pr.person_id_long)
LEFT JOIN team t
ON TRIM(tta.team_abbrev) = TRIM(t.team_abbrev)
LEFT JOIN league l
ON TRIM(tta.league_abbrev) = TRIM(l.league_abbrev);

--
-- 2.x temp_coach table
--


CREATE TEMPORARY TABLE temp_coach (
  coach_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  person_id_long VARCHAR(10) NOT NULL,
  year INTEGER NOT NULL,
  team_abbrev VARCHAR(20) NOT NULL,
  league_abbrev VARCHAR(20) NOT NULL,
  won INTEGER,
  lost INTEGER,
  PRIMARY KEY (coach_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE 'basketball_coaches_cleaned.csv'
INTO TABLE temp_coach
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ',' ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (person_id_long, year, team_abbrev, league_abbrev, won, lost);


--
-- 3.x production coach table
--

CREATE TABLE IF NOT EXISTS coach (
  coach_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  person_record_id INTEGER NOT NULL,
  year INTEGER NOT NULL,
  team_id INTEGER NOT NULL,
  league_id INTEGER NOT NULL,
  won INTEGER,
  lost INTEGER,
  PRIMARY KEY (coach_id),
  FOREIGN KEY (person_record_id) REFERENCES person_record(person_record_id)
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (team_id) REFERENCES team(team_id)
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (league_id) REFERENCES league(league_id)
  ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO coach
(
  coach_id,
  person_record_id,
  year,
  team_id,
  league_id,
  won,
  lost
)
SELECT tc.coach_id, pr.person_record_id, tc.year, t.team_id, l.league_id, tc.won, tc.lost
FROM temp_coach tc
  LEFT JOIN person_record pr
  ON TRIM(tc.person_id_long) = TRIM(pr.person_id_long)
  LEFT JOIN team t 
  ON TRIM(tc.team_abbrev) = TRIM(t.team_abbrev)
  LEFT JOIN league l
  ON TRIM(tc.league_abbrev) = TRIM(l.league_abbrev);

DROP TEMPORARY TABLE temp_team;
DROP TEMPORARY TABLE temp_team_stat;
DROP TEMPORARY TABLE temp_all_star;
DROP TEMPORARY TABLE temp_team_align;
DROP TEMPORARY TABLE temp_coach;
