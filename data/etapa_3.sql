select *
from match
where date_game > '2010-01-01'::date;

-- Cantidad de juegos ganados
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
    -- calcular la pendiente de la cantidad de partidos ganados
    (partidos_2016.cantidad_2016 - partidos_2014.cantidad_2014) / 2.0 as pendiente
from partidos_2014
join partidos_2015 on partidos_2014.team_long_name = partidos_2015.team_long_name
join partidos_2016 on partidos_2014.team_long_name = partidos_2016.team_long_name
group by partidos_2014.team_long_name, partidos_2014.cantidad_2014, partidos_2015.cantidad_2015, partidos_2016.cantidad_2016
order by pendiente desc, cantidad_2016 desc
limit 10;