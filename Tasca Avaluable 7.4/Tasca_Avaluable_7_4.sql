-- 1
-- Crear base de dades
CREATE DATABASE banc;
USE banc;

-- Crear taules
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data JSON
);

CREATE TABLE accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data JSON
);

-- Importar les dades
INSERT INTO transactions (data)
VALUES (
    CONVERT(
        LOAD_FILE('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Transactions.json')
        USING utf8mb4
    )
);

INSERT INTO accounts (data)
VALUES (
    CONVERT(
        LOAD_FILE('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Accounts.json')
        USING utf8mb4
    )
);

-- 1.1
SELECT 
    JSON_UNQUOTE(JSON_EXTRACT(jt.txn, '$.amount')) AS amount
FROM transactions,
JSON_TABLE(
    data, 
    '$.transactions[*]' COLUMNS (
        txn JSON PATH '$'
    )
) AS jt;

-- 1.2
SELECT 
    JSON_UNQUOTE(JSON_EXTRACT(jt.txn, '$.txn_id')) AS txn_id,
    JSON_OBJECT(
        'amount', CAST(JSON_EXTRACT(jt.txn, '$.amount') AS UNSIGNED),
        'txn_date', JSON_UNQUOTE(JSON_EXTRACT(jt.txn, '$.txn_date'))
    ) AS txn_data
FROM transactions,
JSON_TABLE(
    data, 
    '$.transactions[*]' COLUMNS (
        txn JSON PATH '$'
    )
) AS jt
WHERE CAST(JSON_EXTRACT(jt.txn, '$.amount') AS DECIMAL(10,2)) > 200;

-- 1.3
SELECT 
    JSON_UNQUOTE(JSON_EXTRACT(jt.txn, '$.txn_id')) AS txn_id,
    JSON_UNQUOTE(JSON_EXTRACT(jt.txn, '$.txn_date')) AS txn_date
FROM transactions,
JSON_TABLE(
    data, 
    '$.transactions[*]' COLUMNS (
        txn JSON PATH '$'
    )
) AS jt
ORDER BY CAST(JSON_UNQUOTE(JSON_EXTRACT(jt.txn, '$.txn_id')) AS UNSIGNED);

-- 1.4
SELECT 
    CAST(JSON_UNQUOTE(JSON_EXTRACT(t.txn, '$.account_id')) AS UNSIGNED) AS account_id,
    CAST(JSON_EXTRACT(t.txn, '$.amount') AS DECIMAL(10,2)) AS amount
FROM transactions AS tr
CROSS JOIN JSON_TABLE(
    tr.data, 
    '$.transactions[*]' COLUMNS (
        txn JSON PATH '$'
    )
) AS t
INNER JOIN accounts AS ac
CROSS JOIN JSON_TABLE(
    ac.data, 
    '$.accounts[*]' COLUMNS (
        acc JSON PATH '$'
    )
) AS a
    ON CAST(JSON_UNQUOTE(JSON_EXTRACT(t.txn, '$.account_id')) AS UNSIGNED) = 
       CAST(JSON_UNQUOTE(JSON_EXTRACT(a.acc, '$.account_id')) AS UNSIGNED)
ORDER BY account_id;

-- 1.5
SELECT 
    CAST(JSON_UNQUOTE(JSON_EXTRACT(jt.txn, '$.account_id')) AS UNSIGNED) AS account_id,
    SUM(CAST(JSON_EXTRACT(jt.txn, '$.amount') AS DECIMAL(10,2))) AS total_amount
FROM transactions AS tr
CROSS JOIN JSON_TABLE(
    tr.data, 
    '$.transactions[*]' COLUMNS (
        txn JSON PATH '$'
    )
) AS jt
GROUP BY CAST(JSON_UNQUOTE(JSON_EXTRACT(jt.txn, '$.account_id')) AS UNSIGNED)
ORDER BY account_id;