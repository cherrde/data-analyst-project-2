--create records table
CREATE TABLE records
AS
SELECT
    id,
    country_id,
    league_id,
    season,
    date,
    match_api_id,
    home_team_api_id,
    away_team_api_id,
    home_team_goal,
    away_team_goal
FROM
    match;

ALTER TABLE records
    ADD COLUMN draw integer,
        ADD COLUMN winning_team integer,
            ADD COLUMN losing_team integer;

UPDATE
    records
SET
    draw = 1
WHERE
    home_team_goal = away_team_goal;

UPDATE
    records
SET
    winning_team = home_team_api_id,
    losing_team = away_team_api_id
WHERE
    home_team_goal > away_team_goal;

UPDATE
    records
SET
    winning_team = away_team_api_id,
    losing_team = home_team_api_id
WHERE
    home_team_goal < away_team_goal;

--Base Query
SELECT
    tm.team_long_name as "team_name",
    EXTRACT(YEAR FROM ta.date) as "season",
    ta.buildupplayspeed,
    ta.buildupplaydribbling,
    ta.buildupplaydribblingclass,
    ta.buildupplaypassing,
    ta.buildupplaypassingclass,
    ta.buildupplaypositioningclass,
    ta.chancecreationpassing,
    ta.chancecreationpassingclass,
    ta.chancecreationcrossing,
    ta.chancecreationcrossingclass,
    ta.chancecreationshooting,
    ta.chancecreationshootingclass,
    ta.chancecreationpositioningclass,
    ta.defencepressure,
    ta.defencepressureclass,
    ta.defenceaggression,
    ta.defenceaggressionclass,
    ta.defenceteamwidth,
    ta.defenceteamwidthclass,
    ta.defencedefenderlineclass,
		(SELECT
            count(*)
        FROM
            public. "records" rec
        WHERE
            draw = 1
            AND EXTRACT(YEAR FROM rec.date) = EXTRACT(YEAR FROM ta.date)
            AND (rec.home_team_api_id = tm.team_api_id
                OR rec.away_team_api_id = tm.team_api_id)) as "draws",
		(SELECT
                count(rec1.winning_team)
            FROM
                public. "records" rec1
            WHERE
                EXTRACT(YEAR FROM rec1.date) = EXTRACT(YEAR FROM ta.date)
                AND rec1.winning_team = tm.team_api_id) AS "wins",
		(SELECT
                    count(rec2.losing_team)
                FROM
                    public. "records" rec2
                WHERE
                    EXTRACT(YEAR FROM rec2.date) = EXTRACT(YEAR FROM ta.date)
                    AND rec2.losing_team = tm.team_api_id) AS "losses"
    FROM public. "Team" tm
    JOIN public. "team_attributes" ta ON ta.team_api_id = tm.team_api_id;
