-- 2021-12-04
-- Data model for the comment section of https://mehdix.ir website.

CREATE TABLE IF NOT EXISTS comments (
	-- A unique ID for each comment
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	-- ISO8601 strings with UTC/zulu timezone, try date --iso-8601=seconds --utc
	time TEXT NOT NULL,
	-- Comment author's name
	name TEXT NOT NULL,
	-- Comment author's email
	email TEXT NOT NULL,
	-- The page where the comment belongs to
	page_id TEXT NOT NULL,
	-- The ID of a parent comment
	reply_to TEXT,
	-- Some URL
	website TEXT,
	-- Whether this is a spam (wrong puzzle answer)
	spam INTEGER NOT NULL,
	-- The body of the comment
	message TEXT NOT NULL
);
