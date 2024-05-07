-- Active: 1715051780611@@127.0.0.1@5432@inmo@public
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS plans;

CREATE OR REPLACE FUNCTION slug_generator() RETURNS TRIGGER AS $$
BEGIN
    NEW.slug := lower(regexp_replace(NEW.name, '[^a-zA-Z0-9]+', '-', 'g'));

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY DEFAULT (gen_random_uuid()),
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

CREATE TABLE IF NOT EXISTS plans (
    id TEXT PRIMARY KEY DEFAULT (gen_random_uuid()),
    name TEXT NOT NULL,
    price FLOAT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    slug TEXT,
    UNIQUE (slug),
    UNIQUE (name)
);

CREATE TRIGGER generate_slug_for_plans
BEFORE INSERT OR UPDATE ON plans
FOR EACH ROW
WHEN (NEW.name IS NOT NULL)
EXECUTE FUNCTION slug_generator();