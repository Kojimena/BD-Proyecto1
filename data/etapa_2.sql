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

