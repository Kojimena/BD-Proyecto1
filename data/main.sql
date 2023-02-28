--create database fifa_data;

drop table player_Atributes;
drop table player;

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
    foreign key (away_team_api_id) references team(team_api_id)
);