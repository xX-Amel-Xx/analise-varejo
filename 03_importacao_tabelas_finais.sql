
/*=============================Importando os arquivos csv de Clientes==========================*/
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/clientes.csv'
INTO TABLE clientes
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(cliente_id, nome_cliente, cidade, uf, segmento, @var_data)
SET data_cadastro = STR_TO_DATE(@var_data, '%d/%m/%Y');

/*=========================Importando os arquivos csv de Produtos==============================*/
USE varejo_analytics;

-- 1. Limpa a tabela
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE produtos;
SET FOREIGN_KEY_CHECKS = 1;

-- 2. Importa com a cláusula IGNORE
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/produtos.csv'
IGNORE INTO TABLE produtos
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(produto_id, produto, categoria, @v_custo, @v_preco)
SET 
  custo_unitario = REPLACE(@v_custo, ',', '.'),
  preco_lista = REPLACE(@v_preco, ',', '.');
  /*porque o arquivo produtos.csv utiliza vírgula (,)
  em vez de ponto (.) nos valores decimais das colunas de custo e preço (por exemplo: 15,90).*/
  
  select *from produtos;

/*===========================Importando os arquivos csv de Vendedores==============================*/
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/vendedores.csv'
INTO TABLE vendedores
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(vendedor_id, vendedor, equipe);

/*=============================Importando os arquivos csv de pedidos===============================*/
USE varejo_analytics;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/pedidos.csv'
IGNORE INTO TABLE pedidos
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(pedido_id, @var_data, cliente_id, vendedor_id, canal, status, forma_pagamento)
SET data_pedido = STR_TO_DATE(@var_data, '%d/%m/%Y');

SELECT COUNT(*) FROM pedidos;
select *from pedidos;

/*=======================Importando os arquivos csv de Itens_pedidos===========================================*/

USE varejo_analytics;

-- 1. Limpa a tabela
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE produtos;
SET FOREIGN_KEY_CHECKS = 1;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Itens_pedidos.csv'
IGNORE INTO TABLE itens_pedido
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(pedido_id, produto_id, quantidade,@v_preco,@v_desconto)
SET 
  preco_unitario = REPLACE(@v_preco, ',', '.'),
  desconto_pct = REPLACE(@v_desconto, ',', '.');
  
SELECT * FROM itens_pedido;