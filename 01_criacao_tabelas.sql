CREATE DATABASE varejo_analytics;
USE varejo_analytics;
SELECT DATABASE();

CREATE TABLE clientes (
    cliente_id INT PRIMARY KEY,
    nome_cliente VARCHAR(100),
    cidade VARCHAR(100),
    uf CHAR(2),
    segmento VARCHAR(50),
    data_cadastro DATE
);

CREATE TABLE produtos (
    produto_id INT PRIMARY KEY,
    produto VARCHAR(100),
    categoria VARCHAR(50),
    custo_unitario DECIMAL(10,2),
    preco_lista DECIMAL(10,2)
);

CREATE TABLE vendedores (
    vendedor_id INT PRIMARY KEY,
    vendedor VARCHAR(100),
    equipe VARCHAR(50)
);

CREATE TABLE pedidos (
    pedido_id INT PRIMARY KEY,
    data_pedido DATE,
    cliente_id INT,
    vendedor_id INT,
    canal VARCHAR(30),
    status VARCHAR(30),
    forma_pagamento VARCHAR(30),

    FOREIGN KEY (cliente_id)
        REFERENCES clientes(cliente_id),

    FOREIGN KEY (vendedor_id)
        REFERENCES vendedores(vendedor_id)
);

CREATE TABLE itens_pedido (
    pedido_id INT,
    produto_id INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    desconto_pct DECIMAL(5,2),

    FOREIGN KEY (pedido_id)
        REFERENCES pedidos(pedido_id),

    FOREIGN KEY (produto_id)
        REFERENCES produtos(produto_id)
);
SELECT COUNT(*) FROM pedidos;

----- mês/canal/UF/categoria
select pe.canal,cl.uf,pr.categoria,MONTH(pe.data_pedido) as mês, SUM(ip.quantidade*ip.preco_unitario) as Receita
from produtos as pr
join itens_pedido as ip
on pr.produto_id=ip.produto_id
join pedidos as pe
on ip.pedido_id=pe.pedido_id
join clientes as cl
on pe.cliente_id=cl.cliente_id
GROUP BY MONTH(pe.data_pedido),pe.canal,cl.uf,pr.categoria
ORDER BY MONTH(pe.data_pedido),pe.canal,cl.uf,pr.categoria;

-- ticket médio por pedido 

WITH cte_pedido as(
select pe.pedido_id, SUM(ip.quantidade*ip.preco_unitario) as receita
from pedidos as pe
join itens_pedido as ip
on pe.pedido_id=ip.pedido_id
group by pe.pedido_id)
SELECT
    SUM(receita) / COUNT(pedido_id) AS ticket_medio
FROM cte_pedido;

-- top 10 produtos
WITH cte_produto as (
select pr.produto_id, pr.produto, SUM(ip.quantidade*ip.preco_unitario) as receita,
row_number() over(order by SUM(ip.quantidade*ip.preco_unitario) desc)  as ranking
from produtos as pr 
join itens_pedido as ip
on pr.produto_id=ip.produto_id
group by  pr.produto_id,pr.produto)
select produto_id, produto, receita, ranking
from  cte_produto where ranking <=10; 

-- margem por categoria
WITH cte as(
select pr.categoria, SUM(
    ip.quantidade * ip.preco_unitario
    * (1 - ip.desconto_pct / 100)
) as receita,
SUM(ip.quantidade*pr.custo_unitario) as custo,  SUM(ip.quantidade * ip.preco_unitario * (1 - ip.desconto_pct / 100))- SUM(ip.quantidade * pr.custo_unitario) AS lucro
from produtos as pr
join itens_pedido as ip
on pr.produto_id=ip.produto_id
group by pr.categoria),
cte_analise as (
select categoria, receita, custo,lucro / NULLIF(receita, 0) * 100 AS margem from cte
)
select categoria,margem from cte_analise;

-- Clientes recorrentes 
select pe.cliente_id, cl.nome_cliente, count(pe.pedido_id) as quantidade_pedidos
from pedidos as pe
join clientes as cl
on pe.cliente_id=cl.cliente_id
group by pe.cliente_id,cl.nome_cliente
having  count(pe.pedido_id)>1;

select*from pedidos;

 -- taxa de cancelamento/devolução;

select
    COUNT(pedido_id) as total_pedidos,
    SUM(case
        WHEN status = 'Cancelado' then 1
        else 0
    end) as pedidos_cancelados,
    SUM(case
        when status = 'Devolvido' then 1
        else 0
    end) as pedidos_devolvidos,
    SUM(case
        when status = 'Cancelado' then 1
        else 0
    end) * 100.0 / NULLIF(COUNT(pedido_id), 0)
        as taxa_cancelamento,
    SUM(case
        when status = 'Devolvido' then 1
        else 0
    end) * 100.0 / NULLIF(COUNT(pedido_id), 0)
		as taxa_devolucao
from pedidos;

-- vendedores por receita.
select ve.vendedor, SUM(ip.quantidade*ip.preco_unitario) as receita
from vendedores as ve
join pedidos as pe
on ve.vendedor_id=pe.vendedor_id
join itens_pedido as ip
on pe.pedido_id=ip.pedido_id
group by ve.vendedor
order by receita;
