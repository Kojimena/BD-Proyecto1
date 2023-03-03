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

-- Ejercicio 4 Promedio de probabilidades de todas las casas de apuesta por: temporada, liga, equipo
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

select *
from apuestas
where b365 is not null and bw is not null and iw is not null and lb is not null and ps is not null and wa is not null
and sj is not null and wa is not null and vc is not null and gb is not null and bs is not null;

-- Ejercicio 5
select team_long_name, avg((b365 + bw + iw + lb + ps + wa + sj + vc + gb + bs)/10) as promedio
from apuestas
group by team_long_name
order by promedio;

-- Mejores jugadores por liga y temporada
select
    player_name,
    season,
    name_league
from match
join league l on l.id = match.league_id
join player on player_fifa_api_id

-- Faltas cometidas
-- <foulcommit><value><event_incident_typefk>641</event_incident_typefk><elapsed>3</elapsed><player2>30853</player2><subtype>advantage</subtype><player1>75489</player1><sortorder>0</sortorder><team>9825</team><n>4</n><type>foulcommit</type><id>2072042</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>3</elapsed><player2>30853</player2><player1>23678</player1><sortorder>1</sortorder><team>9825</team><n>208</n><type>foulcommit</type><id>2072045</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>13</elapsed><player2>196386</player2><player1>30675</player1><sortorder>1</sortorder><team>8455</team><n>213</n><type>foulcommit</type><id>2072104</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>21</elapsed><player2>30627</player2><player1>26005</player1><sortorder>0</sortorder><team>9825</team><n>221</n><type>foulcommit</type><id>2072151</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>30</elapsed><player2>30675</player2><player1>31435</player1><sortorder>0</sortorder><team>9825</team><n>231</n><type>foulcommit</type><id>2072206</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>36</elapsed><player2>31013</player2><player1>30627</player1><sortorder>0</sortorder><team>8455</team><n>236</n><type>foulcommit</type><id>2072242</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>43</event_incident_typefk><elapsed>41</elapsed><player1>212470</player1><sortorder>1</sortorder><team>8455</team><n>241</n><type>foulcommit</type><id>2072271</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>44</elapsed><player2>30679</player2><player1>196386</player1><sortorder>4</sortorder><team>9825</team><n>249</n><type>foulcommit</type><id>2072294</id></value><value><stats><foulscommitted>1</foulscommitted></stats><elapsed_plus>1</elapsed_plus><event_incident_typefk>37</event_incident_typefk><elapsed>45</elapsed><player2>23783</player2><player1>30843</player1><sortorder>1</sortorder><team>9825</team><n>253</n><type>foulcommit</type><id>2072306</id></value><value><stats><foulscommitted>1</foulscommitted></stats><elapsed_plus>1</elapsed_plus><event_incident_typefk>37</event_incident_typefk><elapsed>45</elapsed><player2>196386</player2><player1>51553</player1><sortorder>5</sortorder><team>8455</team><n>254</n><type>foulcommit</type><id>2072311</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>48</elapsed><player2>30679</player2><player1>23678</player1><sortorder>0</sortorder><team>9825</team><n>259</n><type>foulcommit</type><id>2072401</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>49</elapsed><player2>30843</player2><player1>30679</player1><sortorder>2</sortorder><team>8455</team><n>261</n><type>foulcommit</type><id>2072409</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>50</elapsed><player2>30675</player2><player1>30843</player1><sortorder>0</sortorder><team>9825</team><n>263</n><type>foulcommit</type><id>2072417</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>210</event_incident_typefk><elapsed>54</elapsed><subtype>serious_foul</subtype><player1>23783</player1><sortorder>3</sortorder><team>8455</team><n>269</n><type>foulcommit</type><id>2072448</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>63</elapsed><player2>46010</player2><player1>37950</player1><sortorder>0</sortorder><team>9825</team><n>279</n><type>foulcommit</type><id>2072498</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>63</elapsed><player2>30843</player2><player1>23783</player1><sortorder>1</sortorder><team>8455</team><n>275</n><type>foulcommit</type><id>2072499</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>66</elapsed><player2>30853</player2><player1>23678</player1><sortorder>0</sortorder><team>9825</team><n>277</n><type>foulcommit</type><id>2072517</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>69</elapsed><player2>46010</player2><player1>37950</player1><sortorder>1</sortorder><team>9825</team><n>289</n><type>foulcommit</type><id>2072536</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>70</elapsed><player2>26111</player2><player1>31906</player1><sortorder>1</sortorder><team>8455</team><n>285</n><type>foulcommit</type><id>2072544</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>72</elapsed><player2>30843</player2><player1>25925</player1><sortorder>2</sortorder><team>8455</team><n>288</n><type>foulcommit</type><id>2072556</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>75</elapsed><player2>30853</player2><player1>26111</player1><sortorder>1</sortorder><team>9825</team><n>291</n><type>foulcommit</type><id>2072570</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>76</elapsed><player2>30675</player2><player1>27277</player1><sortorder>0</sortorder><team>9825</team><n>290</n><type>foulcommit</type><id>2072576</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>37</event_incident_typefk><elapsed>77</elapsed><player2>46539</player2><player1>32345</player1><sortorder>1</sortorder><team>8455</team><n>295</n><type>foulcommit</type><id>2072584</id></value><value><stats><foulscommitted>1</foulscommitted></stats><event_incident_typefk>210</event_incident_typefk><elapsed>81</elapsed><subtype>serious_foul</subtype><player1>38834</player1><sortorder>2</sortorder><team>8455</team><n>298</n><type>foulcommit</type><id>2072610</id></value></foulcommit>

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

