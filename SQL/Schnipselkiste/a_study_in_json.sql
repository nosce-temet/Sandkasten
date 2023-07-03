-- definition der trigger funktion
CREATE OR REPLACE FUNCTION training.fill_changelog()
	returns trigger
	language PLPGSQL
	AS
$$
DECLARE
	oldvalue JSON := (SELECT array_to_json(array_agg(to_jsonb(pre.*)))
		 FROM jsonb_each(to_jsonb(OLD)) AS pre
		 	CROSS JOIN jsonb_each(to_jsonb(NEW)) AS post
		 WHERE pre.key = post.key AND pre.value IS DISTINCT FROM post.value);
BEGIN
	NEW.changelog = jsonb_insert(
		OLD.changelog::jsonb,
		'{log,-1}',
		('{"name":"'||current_user||
		 '","timestamptz":"'||now()||
		 '","old_value":'||oldvalue||'}'
		)::jsonb,
		true
	);
	RETURN NEW;
END;
$$
;
-- old value erklaert
SELECT
	*
	--array_to_json(array_agg(to_jsonb(pre.*)))
FROM jsonb_each('{"spalte1": "gleich", "spalte2": "alt", "spalte3": 1, "spalte4": false}') AS pre
	CROSS JOIN jsonb_each('{"spalte1": "gleich", "spalte2": "neu", "spalte3": 1, "spalte4": true}') AS post
WHERE
	pre.key = post.key
	AND
	pre.value IS DISTINCT FROM post.value
;
-- testtabelle erstellen
CREATE TABLE training.testingJsonLog (
	plausi_id SERIAL PRIMARY KEY,
	plausi_name TEXT DEFAULT current_user,
	zeitstempel TIMESTAMP DEFAULT now(),
	changelog JSON DEFAULT ((
		'{ "log": [{"name":"'||current_user||'","timestamptz":"'||now()||'"}]}')::jsonb),
	bemerkung TEXT
)
;
-- mit testdaten befuellen
INSERT INTO training.testingJsonLog(bemerkung)
VALUES
('test1'),
('test2'),
('test3'),
('test4'),
('test5')
RETURNING *
;
-- json objekt traversieren
SELECT
	changelog -> 'log' -> 0 ->> 'name' AS "Nutzername",
	changelog -> 'log' -> 0 ->> 'timestamptz' AS "Zeitstempel",
	changelog -> 'log' -> 0 -> 'old_value' AS "alter Wert"
FROM training.testingjsonlog
;
-- update trigger erstellen
CREATE TRIGGER testingjsonlog_trigger
	BEFORE UPDATE
	ON training.testingjsonlog
	FOR EACH ROW
	execute PROCEDURE training.fill_changelog()
;
-- trigger test
UPDATE training.testingjsonlog
SET bemerkung = 'fiddlesticks'
WHERE
	plausi_id = 2
RETURNING *
;
SELECT
	plausi_id,
	changelog -> 'log' -> -1 ->> 'name' AS "Nutzername",
	changelog -> 'log' -> -1 ->> 'timestamptz' AS "Zeitstempel",
	changelog -> 'log' -> -1 -> 'old_value' AS "alter Wert"
FROM training.testingjsonlog
;
-- changelog spalte einer existierenden tabelle hinzufuegen
CREATE TEMP TABLE test AS
SELECT *
FROM actor
LIMIT 10
;
SELECT *
FROM test
;
ALTER TABLE test
ADD COLUMN changelog JSON DEFAULT (
	('{ "log": [{"name":"'||current_user||'","timestamptz":"'||now()||'"}]}')::jsonb)
;
