"""---------------------------------------------------------------------------
* UNIVERSIDAD DEL VALLE DE GUATEMALA
* FACULTAD DE INGENIERÍA
* DEPARTAMENTO DE CIENCIA DE LA COMPUTACIÓN
* Bases de datos 1
* Ciclo I - 2023
*
------------------------------------------------------------------------------"""
import pandas as pd
import psycopg2
import numpy as np

df_country = pd.read_csv(r"proyecto1/data/Proyecto 1 - Datos/Country.csv")
df_league = pd.read_csv(r"proyecto1/data/Proyecto 1 - Datos/League.csv")
df_player = pd.read_csv(r"proyecto1/data/Proyecto 1 - Datos/Player.csv", usecols=['id','player_api_id', 'player_name', 'player_fifa_api_id', 'birthday'])
df_team = pd.read_csv(r"proyecto1/data/Proyecto 1 - Datos/Team.csv", usecols=['id','team_api_id', 'team_fifa_api_id', 'team_long_name', 'team_short_name'])
df_team_attributes = pd.read_csv(r"proyecto1/data/Proyecto 1 - Datos/Team_Attributes.csv", usecols=['id', 'team_fifa_api_id', 'date', 'buildUpPlaySpeed', 'buildUpPlayPassing', 'chanceCreationPassing', 'chanceCreationCrossing', 'chanceCreationShooting', 'defencePressure', 'defenceAggression']) 
df_player_attributes = pd.read_csv("proyecto1/data/Proyecto 1 - Datos/Player_Attributes.csv", usecols=['id', 'player_fifa_api_id', 'date', 'overall_rating', 'potential', 'attacking_work_rate', 'defensive_work_rate', 'sprint_speed'])
#df_match = pd.read_csv(r"proyecto1/data/Proyecto 1 - Datos/Match.csv", usecols= ['id','country_id','league_id','season','stage','date','match_api_id','home_team_api_id','away_team_api_id','home_team_goal','away_team_goal','B365H','B365D','B365A','BWH','BWD','BWA','IWH','IWD','IWA','LBH','LBD','LBA','PSH','PSD','PSA','WHH','WHD','WHA','SJH','SJD','SJA','VCH','VCD','VCA','GBH','GBD','GBA','BSH','BSD','BSA']) 
df_match = pd.read_csv(r"proyecto1/data/Proyecto 1 - Datos/Match.csv", 
                       usecols=['id','country_id','league_id','season','stage','date','match_api_id',
                                'home_team_api_id','away_team_api_id','home_team_goal','away_team_goal',
                                'home_player_1', 'home_player_2', 'home_player_3', 'home_player_4', 
                                'home_player_5', 'home_player_6', 'home_player_7', 'home_player_8', 
                                'home_player_9', 'home_player_10', 'home_player_11', 'away_player_1', 
                                'away_player_2', 'away_player_3', 'away_player_4', 'away_player_5', 
                                'away_player_6', 'away_player_7', 'away_player_8', 'away_player_9', 
                                'away_player_10', 'away_player_11','foulcommit',
                                'B365H','B365D','B365A','BWH','BWD','BWA','IWH','IWD','IWA',
                                'LBH','LBD','LBA','PSH','PSD','PSA','WHH','WHD','WHA','SJH',
                                'SJD','SJA','VCH','VCD','VCA','GBH','GBD','GBA','BSH','BSD','BSA'])


print ("--------------------------------------------------------------------------------------------------------------")

# cursor
conn = psycopg2.connect(database="fifa_data", user="postgres", password="", host="localhost", port="5432") # Conexión a la base de datos
cur = conn.cursor() # Creación del cursor

""" # Ingreso de datos de country a Postgres
for i in range(len(df_country.index)):
    fila = df_country.iloc[i].tolist()
    fila[0] = int(fila[0])
    print(fila)
    cur.execute("INSERT INTO country (id, name) VALUES (%s, %s)", fila)
    conn.commit() 

# Ingreso de datos de league a Postgres
for i in range(len(df_league.index)):
    fila = df_league.iloc[i].tolist()
    fila[0] = int(fila[0])
    fila[1] = int(fila[1])
    cur.execute("INSERT INTO league (id,country_id, name_league) VALUES (%s, %s, %s)", fila)
    conn.commit() 

# Ingreso de datos de player a Postgres
for i in range(len(df_player.index)):
    fila = df_player.iloc[i].tolist()
    fila[0] = str(fila[0])
    fila[1] = str(fila[1])
    fila[2] = str(fila[2])
    fila[3] = str(fila[3])
    fila[4] = str(fila[4])
    cur.execute("INSERT INTO player (id,player_api_id, player_name, player_fifa_api_id, birthday) VALUES (%s, %s, %s, %s, %s)", fila)
    conn.commit()

   # Ingreso de datos de team a Postgres
for i in range(len(df_team.index)):
    fila = df_team.iloc[i].tolist()
    try:
        fila[2] = int(fila[2])
    except:
        pass
    # convertir todas las columnas a string
    for j in range(len(fila)):
        fila[j] = str(fila[j])

    if (fila[2] == "nan"):
        continue

    try:
        cur.execute("INSERT INTO team (id,team_api_id,team_fifa_api_id,team_long_name,team_short_name) VALUES (%s, %s, %s, %s, %s)", fila)
    except Exception as e:
        print(f"Error en la fila {i}")
        conn.rollback()
        continue
    else:
        conn.commit() 

# Ingreso de datos de team_attributes a Postgres
for i in range(len(df_team_attributes.index)):
    fila = df_team_attributes.iloc[i].tolist()
    # convertir todas las columnas a string
    for j in range(len(fila)):
        fila[j] = str(fila[j])

    try:
        cur.execute("INSERT INTO team_Atributes VALUES (%s, %s, %s,%s,%s,%s,%s,%s,%s,%s)", fila)
    except Exception as e:
        print(f"Error en la fila {i}")
        print(e)
        conn.rollback()
        continue
    else:
        conn.commit()

# Ingreso de datos de player_attributes a Postgres
for i in range(len(df_player_attributes.index)):
    fila = df_player_attributes.iloc[i].tolist()
    print(fila)
    # convertir todas las columnas a string
    for j in range(len(fila)):
        fila[j] = str(fila[j])
    
    if fila[0] == 'nan':
        continue
    if fila[1] == 'nan':
        continue
    if fila[2] == 'nan':
        continue
    if fila[3] == 'nan':
        continue
    if fila[4] == 'nan':
        continue
    if fila[5] == 'nan':
        continue
    if fila[6] == 'nan':
        continue
    #convertir las columnas 3 y 4 a int
    fila[3] = int(float(fila[3]))
    fila[4] = int(float(fila[4]))


    try:
        cur.execute("INSERT INTO player_Atributes VALUES (%s, %s, %s, %s, %s, %s, %s)", fila)
    except Exception as e:
        print(f"Error en la fila {i}")
        print(e)
        conn.rollback()
        continue
    else:
        conn.commit() """
""" 

# Ingreso de datos de match a Postgres
for i in range(len(df_match.index)):
    fila = df_match.iloc[i].tolist()
    # convertir todas las columnas a string
    for j in range(len(fila)):
        # if any fila is nan then continue
        if fila[j] == 'nan':
            fila[j] = None  # if nan then 0
        # if any fila has numpy int64 then convert to int
        if type(fila[j]) == np.int64:
            fila[j] = int(fila[j])
        # if any fila has numpy float64 then convert to float
        if type(fila[j]) == np.float64:
            fila[j] = float(fila[j])

    for k in range(11, 35):
        try:
            if np.isnan(fila[k]):
                fila[k] = None
            else:
                fila[k] = int(fila[k])
        except:
            pass
    for j in range(35, 63):
        if np.isnan(fila[j]):
            fila[j] = None
    try:
        cur.execute(
            "INSERT INTO match VALUES (%s, %s, %s, %s,%s, %s, %s, %s, %s,%s, %s, %s, %s, %s,%s, %s, %s, %s, %s,%s, %s, %s, %s, %s,%s, %s, %s, %s, %s,%s, %s, %s, %s, %s,%s, %s, %s, %s, %s,%s, %s, %s,%s, %s, %s, %s, %s,%s, %s, %s, %s, %s,%s, %s, %s, %s, %s,%s, %s, %s, %s, %s,%s, %s)",
            fila)
    except Exception as e:
        print(f"Error en la fila {i}: {fila}")
        print(e)
        conn.rollback()
        continue
    else:
        conn.commit() """

# Ingreso de datos de player_attributes a Postgres
for i in range(len(df_player_attributes.index)):
    fila = df_player_attributes.iloc[i].tolist()
    # convertir todas las columnas a string
    for j in range(len(fila)):
        fila[j] = str(fila[j])

    if fila[0] == 'nan':
        continue
    if fila[1] == 'nan':
        continue
    if fila[2] == 'nan':
        continue
    if fila[3] == 'nan':
        continue
    if fila[4] == 'nan':
        continue
    if fila[5] == 'nan':
        continue
    if fila[6] == 'nan':
        continue
    try:
        fila[7] = int(float(fila[7]))
    except Exception as e:
        print(e)
        pass
    # convertir las columnas 3 y 4 a int
    fila[3] = int(float(fila[3]))
    fila[4] = int(float(fila[4]))

    try:
        cur.execute("INSERT INTO player_Atributes VALUES (%s, %s, %s, %s, %s, %s, %s, %s)", fila)
    except Exception as e:
        print(f"Error en la fila {i}")
        print(e)
        conn.rollback()
        continue
    else:
        conn.commit()



cur.close()  # Cierre del cursor


"""create table match(
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
"""

