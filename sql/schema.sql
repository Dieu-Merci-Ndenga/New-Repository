-- Minimal SQLite schema for storing repositories and basic index data

BEGIN TRANSACTION;

CREATE TABLE repositories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  path TEXT NOT NULL UNIQUE,
  name TEXT,
  default_branch TEXT
);

CREATE TABLE authors (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  email TEXT
);

CREATE TABLE commits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  repo_id INTEGER NOT NULL REFERENCES repositories(id),
  hash TEXT NOT NULL UNIQUE,
  message TEXT,
  author_id INTEGER REFERENCES authors(id),
  timestamp TEXT
);

CREATE TABLE branches (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  repo_id INTEGER NOT NULL REFERENCES repositories(id),
  name TEXT,
  target_hash TEXT
);

CREATE TABLE files (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  path TEXT NOT NULL UNIQUE
);

CREATE TABLE commit_files (
  commit_id INTEGER NOT NULL REFERENCES commits(id),
  file_id INTEGER NOT NULL REFERENCES files(id),
  additions INTEGER DEFAULT 0,
  deletions INTEGER DEFAULT 0,
  PRIMARY KEY(commit_id, file_id)
);

COMMIT;
