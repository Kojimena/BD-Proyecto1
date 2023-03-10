-- Cantidad de juegos jugados por cada equipo
select season, team_long_name, count(*) as played
from team
inner join match m on team.team_api_id = m.home_team_api_id or team.team_api_id = m.away_team_api_id
where team_api_id = m.home_team_api_id or team_api_id = m.away_team_api_id
group by team_long_name, season
order by played desc;

-- goles a favor, gol en contra, diferencia de goles
SELECT
  league.name_league,
  match.season,
  team.team_long_name AS equipo,
  SUM(CASE WHEN match.home_team_api_id = team.team_api_id THEN match.home_team_goal ELSE match.away_team_goal END) AS goles_a_favor,
  SUM(CASE WHEN match.home_team_api_id = team.team_api_id THEN match.away_team_goal ELSE match.home_team_goal END) AS goles_en_contra,
  SUM(CASE WHEN match.home_team_api_id = team.team_api_id THEN match.home_team_goal ELSE match.away_team_goal END) -
    SUM(CASE WHEN match.home_team_api_id = team.team_api_id THEN match.away_team_goal ELSE match.home_team_goal END) AS diferencia_de_goles
FROM match
JOIN team ON match.home_team_api_id = team.team_api_id OR match.away_team_api_id = team.team_api_id
JOIN league ON match.league_id = league.id
GROUP BY league.name_league, match.season, team.team_long_name
ORDER BY league.name_league, match.season, equipo;

-- goles a favor, gol en contra, diferencia de goles. USANDO RANK
with ranking as (
SELECT
  league.name_league,
  match.season,
  team.team_long_name AS equipo,
  SUM(CASE WHEN match.home_team_api_id = team.team_api_id THEN match.home_team_goal ELSE match.away_team_goal END) AS goles_a_favor,
  SUM(CASE WHEN match.home_team_api_id = team.team_api_id THEN match.away_team_goal ELSE match.home_team_goal END) AS goles_en_contra,
  SUM(CASE WHEN match.home_team_api_id = team.team_api_id THEN match.home_team_goal ELSE match.away_team_goal END) -
    SUM(CASE WHEN match.home_team_api_id = team.team_api_id THEN match.away_team_goal ELSE match.home_team_goal END) AS diferencia_de_goles
FROM match
JOIN team ON match.home_team_api_id = team.team_api_id OR match.away_team_api_id = team.team_api_id
JOIN league ON match.league_id = league.id
GROUP BY league.name_league, match.season, team.team_long_name
ORDER BY league.name_league, match.season, equipo
)
select equipo, season, diferencia_de_goles, rank() OVER (
    order by diferencia_de_goles desc
    )
from ranking;

-- Ejercicio 3 Promedio de probabilidades de todas las casas de apuesta por: temporada, liga, equipo
with apuestas as (
select
    name_league,
    season,
    team_long_name,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.b365h else match.b365a END) as b365,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.bwh else match.bwa END) as bw,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.iwh else match.iwa END) as iw,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.lbh else match.lba END) as lb,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.psh else match.psa END) as ps,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.whh else match.wha END) as wa,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.sjh else match.sja END) as sj,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.vch else match.vca END) as vc,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.gbh else match.gba END) as gb,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.bsh else match.bsa END) as bs
from match
join team on team_api_id = match.home_team_api_id or team_api_id = match.away_team_api_id
join league l on match.league_id = l.id
group by name_league, season, team_long_name
order by team_long_name
)
--Ejercicio 3
select *
from apuestas
where b365 is not null or bw is not null or iw is not null or lb is not null or ps is not null or wa is not null or sj is not null or vc is not null or gb is not null or bs is not null
;

-- -- Ejercicio 4
-- select team_long_name, avg((b365 + bw + iw + lb + ps + wa + sj + vc + gb + bs)/10) as promedio
-- from apuestas
-- group by team_long_name
-- order by promedio;

-- Ejercicio 5: Mejores jugadores por liga y temporada
with rank_players as (
    select
        l.name_league,
        season,
        p.player_name,
        case
            when pa.attacking_work_rate = 'high' then 3
            when pa.attacking_work_rate = 'medium' then 2
            when pa.attacking_work_rate = 'low' then 1
        end as attacking_work_rate,
        case
            when pa.deffensive_work_rate = 'high' then 3
            when pa.deffensive_work_rate = 'medium' then 2
            when pa.deffensive_work_rate = 'low' then 1
        end as deffensive_work_rate,
        avg(pa.overall_rating) as overall_rating_p,
        avg(pa.potential) as potential_p,
        avg(pa.sprint_speed) as sprint_speed_p,
        row_number() over (partition by l.name_league, season order by avg(pa.overall_rating) desc, attacking_work_rate desc, deffensive_work_rate desc, avg(sprint_speed) desc, avg(potential) desc) as row_num
    from player p
    inner join player_atributes pa on pa.player_fifa_api_id = p.player_fifa_api_id
    inner join match m on p.player_api_id = m.home_player_1 or
                    p.player_api_id = m.home_player_2 or
                    p.player_api_id = m.home_player_3 or
                    p.player_api_id = m.home_player_4 or
            p.player_api_id = m.home_player_5 or
            p.player_api_id = m.home_player_6 or
            p.player_api_id = m.home_player_7 or
            p.player_api_id = m.home_player_8 or
            p.player_api_id = m.home_player_9 or
            p.player_api_id = m.home_player_10 or
            p.player_api_id = m.home_player_11
    inner join league l on m.league_id = l.id
    -- where pa.attacking_work_rate LIKE 'high' or pa.deffensive_work_rate LIKE 'high'
    group by p.player_name, pa.attacking_work_rate, pa.deffensive_work_rate, l.name_league, season
)
select *
from rank_players
where row_num = 1
order by rank_players.name_league, season desc, overall_rating_p desc, attacking_work_rate desc, deffensive_work_rate desc, sprint_speed_p desc, potential_p desc;

-- Ejercicio 6: Jugadores m??s veloces
select
	league.name_league,
  	p.player_name,
    avg(pa.sprint_speed) as avg_speed
    from match m
	JOIN league ON m.league_id = league.id
	JOIN player p on p.player_api_id = m.home_player_1 or
				p.player_api_id = m.home_player_2 or
				p.player_api_id = m.home_player_3 or
				p.player_api_id = m.home_player_4 or
        p.player_api_id = m.home_player_5 or
        p.player_api_id = m.home_player_6 or
        p.player_api_id = m.home_player_7 or
        p.player_api_id = m.home_player_8 or
        p.player_api_id = m.home_player_9 or
        p.player_api_id = m.home_player_10 or
        p.player_api_id = m.home_player_11 or
        p.player_api_id = m.away_player_1 or
        p.player_api_id = m.away_player_2 or
        p.player_api_id = m.away_player_3 or
        p.player_api_id = m.away_player_4 or
        p.player_api_id = m.away_player_5 or
        p.player_api_id = m.away_player_6 or
        p.player_api_id = m.away_player_7 or
        p.player_api_id = m.away_player_8 or
        p.player_api_id = m.away_player_9 or
        p.player_api_id = m.away_player_10 or
        p.player_api_id = m.away_player_11
    JOIN player_atributes pa on pa.player_fifa_api_id = p.player_fifa_api_id
group by name_league, p.player_name
order by avg_speed desc limit 10;


      


-- Ejercicio 7: Caracter??sticas de los mejores equipos
with mejores_equipos as (
    select ganador, count(*) as victorias_totales
    from (
        select match.id,
               case
                   when (match.home_team_goal - match.away_team_goal) > 0 then home_team_api_id
                   when (match.away_team_goal - match.home_team_goal) > 0 then away_team_api_id
        end as ganador
        from match
         ) victorias
    where ganador is not null
    group by ganador
    order by victorias_totales desc
)
select
    team_long_name,
    victorias_totales,
    avg(ta.buildupplayspeed) as buildup_play_speed,
    avg(buildupplaypassing) as buildup_play_passing,
    avg(chancecreationpassing) as chance_creation_passing,
    avg(chancecreationcrossing) as chance_creation_crossing,
    avg(chancecreationshooting) as chance_creation_shooting,
    avg(defencepressure) as defense_pressure,
    avg(defenceaggression) as defense_agression
from team
join mejores_equipos on team_api_id = ganador
join team_atributes ta on team.team_fifa_api_id = ta.team_fifa_api_id
group by team_long_name, victorias_totales
order by victorias_totales desc limit 5;

-- Cantidad de juegos ganados
with partidos as (
    select ganador, count(*) as victorias_t
    from (
        select match.id,
               case
                   when (match.home_team_goal - match.away_team_goal) > 0 then home_team_api_id
                   when (match.away_team_goal - match.home_team_goal) > 0 then away_team_api_id
        end as ganador
        from match
         ) victorias
    where ganador is not null
    group by ganador
    order by victorias_t desc
)
select team_long_name, victorias_t
from team
inner join partidos on team_api_id = ganador;

--Ejercicio 8  Qui??nes son los 3 pa??ses l??deres seg??n apuestas
with apuestas as (
select
    name_league,
    c.name as country,
    season,
    team_long_name,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.b365h else match.b365a END) as b365,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.bwh else match.bwa END) as bw,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.iwh else match.iwa END) as iw,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.lbh else match.lba END) as lb,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.psh else match.psa END) as ps,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.whh else match.wha END) as wa,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.sjh else match.sja END) as sj,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.vch else match.vca END) as vc,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.gbh else match.gba END) as gb,
    avg(case when match.home_team_api_id = team.team_api_id THEN match.bsh else match.bsa END) as bs
from match
join team on team_api_id = match.home_team_api_id or team_api_id = match.away_team_api_id
join league l on match.league_id = l.id
join country c  on match.country_id = c.id
where
    b365h is not null and b365a is not null and
    bwh is not null and bwa is not null and
    iwh is not null and iwa is not null and
    lbh is not null and lba is not null and
    psh is not null and psa is not null and
    whh is not null and wha is not null and
    sjh is not null and sja is not null and
    vch is not null and vca is not null and
    gbh is not null and gba is not null and
    bsh is not null and bsa is not null

group by c.name, name_league, season, team_long_name
order by team_long_name
) 
select country, avg((b365 + bw + iw + lb + ps + wa + sj + vc + gb + bs)/10) as promedio
from apuestas
group by country
order by promedio
limit 5;

--Ejercicio 8 Qui??nes son los 3 pa??ses l??deres seg??n estad??sticas
with paises as (
    select
        team_long_name,
        team_api_id,
        team_fifa_api_id,
        m.country_id

    from team
    join match m on team.team_api_id = m.away_team_api_id
)
select c.name, avg(ta.buildupplayspeed) as buildup_play_speed,
    avg(ta.buildupplaypassing) as buildup_play_passing,
    avg(ta.chancecreationpassing) as chance_creation_passing,
    avg(ta.chancecreationcrossing) as chance_creation_crossing,
    avg(ta.chancecreationshooting) as chance_creation_shooting,
    avg(ta.defencepressure) as defense_pressure,
    avg(ta.defenceaggression) as defense_agression

from paises p
join team_atributes ta on p.team_fifa_api_id = ta.team_fifa_api_id
join country c on p.country_id = c.id
group by c.name
order by buildup_play_speed desc,
        buildup_play_passing desc,
        chance_creation_passing desc,
        chance_creation_crossing desc ,
        chance_creation_shooting desc ,
        defense_pressure desc, defense_agression desc
;

