select team_long_name, count(*) as played
from team
inner join match m on team.team_api_id = m.home_team_api_id or team.team_api_id = m.away_team_api_id
where team_api_id = m.home_team_api_id or team_api_id = m.away_team_api_id
group by team_long_name
order by played desc;

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

