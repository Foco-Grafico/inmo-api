-- Active: 1715728318816@@127.0.0.1@5432
DROP DATABASE IF EXISTS inmo;
CREATE DATABASE inmo;

CREATE SCHEMA IF NOT EXISTS auth;

CREATE SCHEMA IF NOT EXISTS app_config;

CREATE TABLE IF NOT EXISTS app_config.payment_methods (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.targets (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS app_config.organization_types (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS app_config.plans (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    name TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    price NUMERIC NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS app_config.plan_limits (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    plan TEXT NOT NULL REFERENCES app_config.plans(id),
    limit_items NUMERIC NOT NULL,
    org_type TEXT NOT NULL REFERENCES app_config.organization_types(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

INSERT INTO app_config.plans (name, description, price) VALUES ('Basic', 'Free plan', 0);

CREATE TABLE IF NOT EXISTS auth.users (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    token TEXT,
    plan TEXT REFERENCES app_config.plans(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.organizations (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    type TEXT NOT NULL REFERENCES app_config.organization_types(id),
    user_id TEXT NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.orgazation_targets (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    organization TEXT NOT NULL REFERENCES public.organizations(id),
    target TEXT NOT NULL REFERENCES public.targets(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.items (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    organization TEXT NOT NULL REFERENCES public.organizations(id),
    sub_price NUMERIC NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.item_targets (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    item TEXT NOT NULL REFERENCES public.items(id),
    target TEXT NOT NULL REFERENCES public.targets(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.payment_plans (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    item TEXT NOT NULL REFERENCES public.items(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TYPE payment_types AS ENUM ('monthly', 'yearly');

CREATE TABLE IF NOT EXISTS public.payment_plan_details (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    payment_plan TEXT NOT NULL REFERENCES public.payment_plans(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    duration NUMERIC NOT NULL,
    price_per_duration NUMERIC NOT NULL,
    total_price NUMERIC NOT NULL,
    interest_rate NUMERIC NOT NULL,
    type payment_types DEFAULT 'monthly',
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.accept_payment_methods (
    id TEXT NOT NULL PRIMARY KEY DEFAULT (gen_random_uuid()),
    payment_plan_detail TEXT NOT NULL REFERENCES public.payment_plan_details(id),
    payment_method TEXT NOT NULL REFERENCES app_config.payment_methods(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE OR REPLACE FUNCTION auth.create_token(
    password TEXT
)
RETURNS TEXT AS $$
DECLARE
    token TEXT;
BEGIN
    token := crypt(password, gen_salt('bf'));

    RETURN token;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION auth.create_user(
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    password TEXT
) RETURNS VOID AS $$
DECLARE
    token TEXT;
    plan_id TEXT;
BEGIN
    token := auth.create_token(password);

    SELECT id INTO plan_id FROM app_config.plans WHERE name = 'Basic';

    INSERT INTO auth.users (first_name, last_name, email, token, plan)
    VALUES (first_name, last_name, email, token, plan_id);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION auth.resolve_user(
    email TEXT,
    password TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    token TEXT;
BEGIN
    SELECT token INTO token FROM auth.users WHERE email = email;

    RETURN token = crypt(password, token);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION auth.login (
    email TEXT,
    password TEXT
) RETURNS TEXT AS $$
DECLARE
    token TEXT;
BEGIN
    IF auth.resolve_user(email, password) THEN
        RETURN token;
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION auth.update_user(
    id TEXT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    password TEXT
) RETURNS VOID AS $$
DECLARE
    token TEXT;
BEGIN
    token := auth.create_token(password);

    UPDATE auth.users
    SET first_name = first_name,
        last_name = last_name,
        email = email,
        token = token
    WHERE id = id;
END;
$$ LANGUAGE plpgsql;
