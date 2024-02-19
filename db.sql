-- SCHEMA

CREATE DATABASE IF NOT EXISTS rinha;

CREATE TABLE IF NOT EXISTS rinha.customers(
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    limit_cents INTEGER NOT NULL,
    balance INTEGER NOT NULL,
);

CREATE TABLE IF NOT EXISTS rinha.transactions(
    id BIGSERIAL NOT NULL PRIMARY KEY,
    customer_id BIGINT NOT NULL,

    CONSTRAINT fk_transactions_customers FOREIGN KEY customer_id REFERENCES rinha.customers(id)
);

CREATE INDEX IF NOT EXISTS ON rinha.transactions(customer_id);


-- ENTRIES

-- (sim, é tudo personagem do LoL)
INSERT INTO rinha.customers(id, name, limit_cents, balance) VALUES 
    (1, 'Lux'         , 100000  , 0),
    (2, 'Ahri'        , 80000   , 0),
    (3, 'Veigar'      , 1000000 , 0),
    (4, 'Heimerdinger', 10000000, 0),
    (5, 'Vex'         , 500000  , 0);


    