-- Etapa 3
-- 1. Mejora de partidos ganados por equipo en las últimas 3 temporadas

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

-- 2. Mejora de diferencia de goles en las útlimas 3 temporadas

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

-- 3. Equipos con los mejores aumentos de atributos en las últimas 3 temporadas
with atributes_2014 as (
    select *
    from team_atributes
    -- 2013/2014: 17 ago 2013 – 18 may 2014
    where date_reg >= '2013-08-17' and date_reg <= '2014-05-18'
), atributes_2015 as (
    select *
    from team_atributes
    -- 2014/2015: 24 ago 2014 – 24 may 2015
    where date_reg >= '2014-08-24' and date_reg <= '2015-05-24'
), atributes_2016 as (
    select *
    from team_atributes
    -- 2015/2016: 22 ago 2015 – 15 may 2016
    where date_reg >= '2015-08-22' and date_reg <= '2016-05-15'
)

select
    team_long_name,
    atributes_2016.buildUpPlaySpeed - atributes_2014.buildUpPlaySpeed as buildUpPlaySpeed,
    atributes_2016.buildUpPlayPassing - atributes_2014.buildUpPlayPassing as buildUpPlayPassing,
    atributes_2016.chanceCreationPassing - atributes_2014.chanceCreationPassing as chanceCreationPassing,
    atributes_2016.chanceCreationCrossing - atributes_2014.chanceCreationCrossing as chanceCreationCrossing,
    atributes_2016.chanceCreationShooting - atributes_2014.chanceCreationShooting as chanceCreationShooting,
    atributes_2016.defencePressure - atributes_2014.defencePressure as defencePressure,
    atributes_2016.defenceAggression - atributes_2014.defenceAggression as defenceAggression
from atributes_2014
join atributes_2015 on atributes_2014.team_fifa_api_id = atributes_2015.team_fifa_api_id
join atributes_2016 on atributes_2014.team_fifa_api_id= atributes_2016.team_fifa_api_id
join team on team.team_fifa_api_id = atributes_2014.team_fifa_api_id
order by defenceAggression desc, defencePressure desc, buildUpPlaySpeed desc, chanceCreationPassing desc, buildUpPlayPassing desc, chanceCreationCrossing desc, chanceCreationShooting desc
limit 10;

-- 4. Equipos con jugadores más jovenes
WITH jugadores AS (
    SELECT
        p.player_name,
        p.birthday,
        team.team_long_name,
        match.season
    FROM player p
    JOIN match ON p.player_api_id = match.home_player_1 OR
                  p.player_api_id = match.home_player_2 OR
                  p.player_api_id = match.home_player_3 OR
                  p.player_api_id = match.home_player_4 OR
                  p.player_api_id = match.home_player_5 OR
                  p.player_api_id = match.home_player_6 OR
                  p.player_api_id = match.home_player_7 OR
                  p.player_api_id = match.home_player_8 OR
                  p.player_api_id = match.home_player_9 OR
                  p.player_api_id = match.home_player_10 OR
                  p.player_api_id = match.home_player_11
    JOIN team ON match.home_team_api_id = team.team_api_id
    where match.season in ('2015/2016', '2014/2015', '2013/2014')
    GROUP BY p.player_name, team.team_long_name, match.season, p.birthday 
)
SELECT
    team_long_name,
    COUNT(*) AS jugadores_menores_28
FROM jugadores
WHERE DATE_PART('year', CURRENT_DATE) - DATE_PART('year', birthday) < 28
GROUP BY team_long_name
HAVING COUNT(*) > 0
order by jugadores_menores_28 desc;

-- 5. Equipos con mejores jugadores
SELECT 
    team.team_long_name, 
    AVG(pa.potential) as avg_potential, 
    AVG(pa.overall_rating) as avg_rating
FROM match 
JOIN team ON match.home_team_api_id = team.team_api_id 
JOIN player p ON p.player_api_id IN (
            match.home_player_1, 
            match.home_player_2, 
            match.home_player_3, 
            match.home_player_4, 
            match.home_player_5, 
            match.home_player_6, 
            match.home_player_7, 
            match.home_player_8, 
            match.home_player_9, 
            match.home_player_10, 
            match.home_player_11)
JOIN player_atributes pa ON pa.player_fifa_api_id = p.player_fifa_api_id
WHERE match.season IN ('2015/2016', '2014/2015', '2013/2014')
GROUP BY team.team_long_name
ORDER BY avg_potential DESC, avg_rating DESC
limit 10;

-- 6. Equipos con mejora en cuanto a apuestas
with apuestas as (
    select
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
), apuestas_2016 as(
    select
        season,
        team_long_name,
        avg((coalesce(b365, 0) + coalesce(bw, 0) + coalesce(iw, 0) + coalesce(lb, 0) + coalesce(ps, 0) + coalesce(wa, 0) + coalesce(sj, 0) + coalesce(vc, 0) + coalesce(gb, 0) + coalesce(bs, 0)) / 10) as avg_apuesta
    from apuestas
    where season = '2015/2016'
    group by team_long_name, season
), apuestas_2015 as(
    select
        season,
        team_long_name,
        avg((coalesce(b365, 0) + coalesce(bw, 0) + coalesce(iw, 0) + coalesce(lb, 0) + coalesce(ps, 0) + coalesce(wa, 0) + coalesce(sj, 0) + coalesce(vc, 0) + coalesce(gb, 0) + coalesce(bs, 0)) / 10) as avg_apuesta
    from apuestas
    where season = '2014/2015'
    group by team_long_name, season
), apuestas_2014 as(
    select
        season,
        team_long_name,
        avg((coalesce(b365, 0) + coalesce(bw, 0) + coalesce(iw, 0) + coalesce(lb, 0) + coalesce(ps, 0) + coalesce(wa, 0) + coalesce(sj, 0) + coalesce(vc, 0) + coalesce(gb, 0) + coalesce(bs, 0)) / 10) as avg_apuesta
    from apuestas
    where season = '2013/2014'
    group by team_long_name, season
)

select
    apuestas_2016.team_long_name,
    apuestas_2016.avg_apuesta,
    apuestas_2015.avg_apuesta,
    apuestas_2014.avg_apuesta,
    (apuestas_2014.avg_apuesta - apuestas_2016.avg_apuesta)/2.0 as pendiente
from apuestas_2016
join apuestas_2015 on apuestas_2016.team_long_name = apuestas_2015.team_long_name
join apuestas_2014 on apuestas_2016.team_long_name = apuestas_2014.team_long_name
where apuestas_2016.avg_apuesta != 0 and apuestas_2014.avg_apuesta != 0
order by pendiente desc, apuestas_2016.avg_apuesta
limit 10;


-- 7. Mejores equipos en las últimas 3 temporadas
with mejores_equipos as (
    select
        ganador,
        count(*) as victorias_totales
    from (
        select match.id,
               case
                   when (match.home_team_goal - match.away_team_goal) > 0 then home_team_api_id
                   when (match.away_team_goal - match.home_team_goal) > 0 then away_team_api_id
        end as ganador
        from match
        where season in ('2013/2014', '2014/2015', '2015/2016')
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
order by victorias_totales desc limit 10;