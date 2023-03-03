--create database fifa_data;

drop table player_Atributes;
drop table player;
drop table match;
alter table player add constraint player_api_id_u unique (player_api_id);
alter table player drop constraint player_api_id_u;
alter table player
    alter column player_name type varchar(50);

drop table team;
create table team(
    id varchar(30),
    team_api_id varchar(30) unique ,
    team_fifa_api_id varchar(30) unique ,
    team_long_name varchar(30),
    team_short_name varchar(30),
    primary key (id, team_api_id, team_fifa_api_id)
);

create table player(
    id varchar(30),
    player_api_id varchar(30),
    player_name varchar(30),
    player_fifa_api_id varchar(30) unique,
    birthday date,
    primary key (id, player_api_id, player_fifa_api_id)
);

create table team_Atributes(
    id varchar(30) primary key,
    team_fifa_api_id VARCHAR(30),
    date_reg date,
    buildUpPlaySpeed integer,
    buildUpPlayPassing integer,
    chanceCreationPassing integer,
    chanceCreationCrossing integer,
    chanceCreationShooting integer,
    defencePressure integer,
    defenceAggression integer,
    foreign key (team_fifa_api_id) REFERENCES team(team_fifa_api_id)
);

create table player_Atributes(
    id varchar(30) primary key,
    player_fifa_api_id varchar(30),
    date_reg date,
    overall_rating integer,
    potential integer,
    attacking_work_rate varchar(30),
    deffensive_work_rate varchar(30),
    foreign key (player_fifa_api_id) references player(player_fifa_api_id)
);

create table country(
    id varchar(30) primary key,
    name varchar(30)
);

create table league(
    id varchar(30) primary key,
    country_id varchar(30),
    name_league varchar(30),
    foreign key (country_id) references country(id)

);
-- home_player_1	home_player_2	home_player_3	home_player_4	home_player_5	home_player_6	home_player_7	home_player_8	home_player_9	home_player_10	home_player_11	away_player_1	away_player_2	away_player_3	away_player_4	away_player_5	away_player_6	away_player_7	away_player_8	away_player_9	away_player_10	away_player_11
create table match(
    id varchar(30) primary key,
    country_id varchar(30),
    league_id varchar(30),
    season varchar(30),
    stage integer,
    date_game date,
    match_api_id varchar(30),
    home_team_api_id varchar(30),
    away_team_api_id varchar(30),
    home_team_goal integer,
    away_team_goal integer,

    home_player_1 varchar(30),
    home_player_2 varchar(30),
    home_player_3 varchar(30),
    home_player_4 varchar(30),
    home_player_5 varchar(30),
    home_player_6 varchar(30),
    home_player_7 varchar(30),
    home_player_8 varchar(30),
    home_player_9 varchar(30),
    home_player_10 varchar(30),
    home_player_11 varchar(30),
    away_player_1 varchar(30),
    away_player_2 varchar(30),
    away_player_3 varchar(30),
    away_player_4 varchar(30),
    away_player_5 varchar(30),
    away_player_6 varchar(30),
    away_player_7 varchar(30),
    away_player_8 varchar(30),
    away_player_9 varchar(30),
    away_player_10 varchar(30),
    away_player_11 varchar(30),

    foul_commit varchar(999999),

    B365H float,
    B365D float,
    B365A float,
    BWH float,
    BWD float,
    BWA float,
    IWH float,
    IWD float,
    IWA float,
    LBH float,
    LBD float,
    LBA float,
    PSH float,
    PSD float,
    PSA float,
    WHH float,
    WHD float,
    WHA float,
    SJH float,
    SJD float,
    SJA float,
    VCH float,
    VCD float,
    VCA float,
    GBH float,
    GBD float,
    GBA float,
    BSH float,
    BSD float,
    BSA float,

    foreign key (country_id) references country(id),
    foreign key (league_id) references league(id),
    foreign key (home_team_api_id) references team(team_api_id),
    foreign key (away_team_api_id) references team(team_api_id),

    FOREIGN KEY (home_player_1) REFERENCES player(player_api_id),
    FOREIGN KEY (home_player_2) REFERENCES player(player_api_id),
    FOREIGN KEY (home_player_3) REFERENCES player(player_api_id),
    FOREIGN KEY (home_player_4) REFERENCES player(player_api_id),
    FOREIGN KEY (home_player_5) REFERENCES player(player_api_id),
    FOREIGN KEY (home_player_6) REFERENCES player(player_api_id),
    FOREIGN KEY (home_player_7) REFERENCES player(player_api_id),
    FOREIGN KEY (home_player_8) REFERENCES player(player_api_id),
    FOREIGN KEY (home_player_9) REFERENCES player(player_api_id),
    FOREIGN KEY (home_player_10) REFERENCES player(player_api_id),
    FOREIGN KEY (home_player_11) REFERENCES player(player_api_id),
    FOREIGN KEY (away_player_1) REFERENCES player(player_api_id),
    FOREIGN KEY (away_player_2) REFERENCES player(player_api_id),
    FOREIGN KEY (away_player_3) REFERENCES player(player_api_id),
    FOREIGN KEY (away_player_4) REFERENCES player(player_api_id),
    FOREIGN KEY (away_player_5) REFERENCES player(player_api_id),
    FOREIGN KEY (away_player_6) REFERENCES player(player_api_id),
    FOREIGN KEY (away_player_7) REFERENCES player(player_api_id),
    FOREIGN KEY (away_player_8) REFERENCES player(player_api_id),
    FOREIGN KEY (away_player_9) REFERENCES player(player_api_id),
    FOREIGN KEY (away_player_10) REFERENCES player(player_api_id),
    FOREIGN KEY (away_player_11) REFERENCES player(player_api_id)
);