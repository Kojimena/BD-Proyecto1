-- Cantidad de juegos jugados por cada equipo
select team_long_name, count(*) as played
from team
inner join match m on team.team_api_id = m.home_team_api_id or team.team_api_id = m.away_team_api_id
where team_api_id = m.home_team_api_id or team_api_id = m.away_team_api_id
group by team_long_name
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
-- Ejercicio 3
-- select *
-- from apuestas
-- where b365 is not null and bw is not null and iw is not null and lb is not null and ps is not null and wa is not null
-- and sj is not null and wa is not null and vc is not null and gb is not null and bs is not null;

-- Ejercicio 4
select team_long_name, avg((b365 + bw + iw + lb + ps + wa + sj + vc + gb + bs)/10) as promedio
from apuestas
group by team_long_name
order by promedio;

-- Ejercicio 5: Mejores jugadores por liga y temporada

select
p.player_name, pa.attacking_work_rate , pa.deffensive_work_rate, pa.overall_rating from player p
inner join player_atributes pa on p.id = pa.id
where pa.attacking_work_rate LIKE 'high' and pa.deffensive_work_rate LIKE 'high' order by pa.overall_rating desc;

-- Ejercicio 6: Jugadores más veloces

-- Ejercicio 7: Características de los mejores equipos
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
inner join partidos on team_api_id = ganador

--Ejercicio 8  Quiénes son los 3 países líderes según apuestas
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
