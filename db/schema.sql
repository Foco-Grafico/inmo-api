-- Active: 1715051780611@@127.0.0.1@5432@inmo@public
DROP TABLE IF EXISTS users;

CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY DEFAULT (UUID()),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    token TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    token_expiration_time TIMESTAMP NOT NULL,
    location TEXT NOT NULL,
    UNIQUE (email),
    UNIQUE (token)
);
