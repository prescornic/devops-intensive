CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);

INSERT INTO users (name, email)
VALUES
    ('Gabriel', 'gabriel@example.com'),
    ('DevOps User', 'devops@example.com')
ON CONFLICT (email) DO NOTHING;