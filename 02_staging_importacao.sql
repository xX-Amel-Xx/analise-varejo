USE varejo_analytics;

CREATE TABLE stg_clientes (
    cliente_id INT,
    nome_cliente VARCHAR(100),
    cidade VARCHAR(100),
    uf CHAR(2),
    segmento VARCHAR(50),
    data_cadastro VARCHAR(20)
);

CREATE TABLE stg_produtos (
    produto_id INT,
    produto VARCHAR(100),
    categoria VARCHAR(50),
    custo_unitario VARCHAR(30),
    preco_lista VARCHAR(30)
);

CREATE TABLE stg_vendedores (
    vendedor_id INT,
    vendedor VARCHAR(100),
    equipe VARCHAR(50)
);

CREATE TABLE stg_pedidos (
    pedido_id INT,
    data_pedido VARCHAR(20),
    cliente_id INT,
    vendedor_id INT,
    canal VARCHAR(30),
    status VARCHAR(30),
    forma_pagamento VARCHAR(30)
);

CREATE TABLE stg_itens_pedido (
    pedido_id INT,
    produto_id INT,
    quantidade INT,
    preco_unitario VARCHAR(30),
    desconto_pct VARCHAR(30)
);
-- 2. Importação dos CSVs
----- STG CLIENTES
USE varejo_analytics;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/clientes.csv'
INTO TABLE stg_clientes
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(cliente_id, nome_cliente, cidade, uf, segmento, data_cadastro);


----- STG PRODUTOS

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/produtos.csv'
IGNORE INTO TABLE stg_produtos
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(produto_id, produto, categoria, @v_custo, @v_preco);
select *from stg_produtos;

----- STG VENDEDORES

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/vendedores.csv'
INTO TABLE stg_vendedores
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(vendedor_id, vendedor, equipe);


----- STG PEDIDOS

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/pedidos.csv'
INTO TABLE stg_pedidos
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(pedido_id, data_pedido, cliente_id, vendedor_id, canal, status, forma_pagamento);

----- STG ITENS PEDIDO

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Itens_pedidos.csv'
IGNORE INTO TABLE stg_itens_pedido
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(pedido_id, produto_id, quantidade, preco_unitario, desconto_pct);
select *from stg_itens_pedido;

----- CONFERIR QUANTIDADE DE REGISTROS

SELECT 'stg_clientes' AS tabela, COUNT(*) AS quantidade
FROM stg_clientes

UNION ALL

SELECT 'stg_produtos', COUNT(*)
FROM stg_produtos

UNION ALL

SELECT 'stg_vendedores', COUNT(*)
FROM stg_vendedores

UNION ALL

SELECT 'stg_pedidos', COUNT(*)
FROM stg_pedidos

UNION ALL

SELECT 'stg_itens_pedido', COUNT(*)
FROM stg_itens_pedido;


