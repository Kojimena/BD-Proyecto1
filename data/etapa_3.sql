-- Etapa 3
-- Mejora de partidos ganados por equipo en las últimas 3 temporadas
with partidos as (
    select ganador, date_game, match.id, match.season
    from (
        select match.id,
               case
                   when (match.home_team_goal - match.away_team_goal) > 0 then home_team_api_id
                   when (match.away_team_goal - match.home_team_goal) > 0 then away_team_api_id
        end as ganador
        from match
         ) victorias
    join match on match.id = victorias.id
    where ganador is not null
    group by ganador, date_game, match.id
)
select
    team_long_name,
    count(*) as cantidad_2014
from partidos
join team on team.team_api_id = partidos.ganador
where partidos.season = '2013/2014'
group by team_long_name

UNION ALL

select
    team_long_name,
    count(*) as cantidad_2015
from partidos
join team on team.team_api_id = partidos.ganador
where partidos.season = '2014/2015'
group by team_long_name

UNION ALL

select
    team_long_name,
    count(*) as cantidad_2016
from partidos
join team on team.team_api_id = partidos.ganador
where partidos.season = '2015/2016'
group by team_long_name

;

with partidos as (
    select ganador, date_game, match.id, match.season
    from (
        select match.id,
               case
                   when (match.home_team_goal - match.away_team_goal) > 0 then home_team_api_id
                   when (match.away_team_goal - match.home_team_goal) > 0 then away_team_api_id
        end as ganador
        from match
         ) victorias
    join match on match.id = victorias.id
    where ganador is not null
    group by ganador, date_game, match.id
), partidos_2016 as (
    select
        team_long_name,
        count(*) as cantidad_2016
    from partidos
    join team on team.team_api_id = partidos.ganador
    where partidos.season = '2015/2016'
    group by team_long_name
), partidos_2015 as (
    select
        team_long_name,
        count(*) as cantidad_2015
    from partidos
    join team on team.team_api_id = partidos.ganador
    where partidos.season = '2014/2015'
    group by team_long_name
), partidos_2014 as (
    select
        team_long_name,
        count(*) as cantidad_2014
    from partidos
    join team on team.team_api_id = partidos.ganador
    where partidos.season = '2013/2014'
    group by team_long_name
)
select
    partidos_2014.team_long_name,
    partidos_2014.cantidad_2014,
    partidos_2015.cantidad_2015,
    partidos_2016.cantidad_2016,
    (partidos_2016.cantidad_2016 - partidos_2014.cantidad_2014) / 2.0 as pendiente
from partidos_2014
join partidos_2015 on partidos_2014.team_long_name = partidos_2015.team_long_name
join partidos_2016 on partidos_2014.team_long_name = partidos_2016.team_long_name
group by partidos_2014.team_long_name, partidos_2014.cantidad_2014, partidos_2015.cantidad_2015, partidos_2016.cantidad_2016
order by pendiente desc, cantidad_2016 desc
limit 10;

-- Mejora de diferencia de goles en las útlimas 3 temporadas

with differencia_goles as (
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
), diferencia_goles_2016 as (
select * from differencia_goles where season = '2015/2016'
), diferencia_goles_2015 as (
select * from differencia_goles where season = '2014/2015'
), diferencia_goles_2014 as (
select * from differencia_goles where season = '2013/2014'
)
select
    diferencia_goles_2014.equipo,
    diferencia_goles_2014.diferencia_de_goles as diferencia_2014,
    diferencia_goles_2015.diferencia_de_goles as diferencia_2015,
    diferencia_goles_2016.diferencia_de_goles as diferencia_2016,
    (diferencia_goles_2016.diferencia_de_goles - diferencia_goles_2014.diferencia_de_goles) / 2.0 as pendiente

from diferencia_goles_2014
join diferencia_goles_2015 on diferencia_goles_2014.equipo = diferencia_goles_2015.equipo
join diferencia_goles_2016 on diferencia_goles_2014.equipo = diferencia_goles_2016.equipo
order by pendiente desc, diferencia_2016 desc
limit 10;
--