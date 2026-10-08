
USE varejo_analytics;

-- mês/canal/UF/categoria
select pe.canal,cl.uf,pr.categoria,MONTH(pe.data_pedido) as mês,YEAR(pe.data_pedido) AS ano, SUM(ip.quantidade*ip.preco_unitario) as Receita
from produtos as pr
join itens_pedido as ip
on pr.produto_id=ip.produto_id
join pedidos as pe
on ip.pedido_id=pe.pedido_id
join clientes as cl
on pe.cliente_id=cl.cliente_id
where pe.status='Concluído'
GROUP BY MONTH(pe.data_pedido),YEAR(pe.data_pedido),pe.canal,cl.uf,pr.categoria
ORDER BY MONTH(pe.data_pedido),YEAR(pe.data_pedido),pe.canal,cl.uf,pr.categoria;

-- ticket médio por pedido 

WITH cte_pedido as(
select pe.pedido_id, SUM(ip.quantidade*ip.preco_unitario) as receita
from pedidos as pe
join itens_pedido as ip
on pe.pedido_id=ip.pedido_id
where pe.status='Concluído'
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
join pedidos as pe
on ip.pedido_id=pe.pedido_id
where pe.status='Concluído'
group by  pr.produto_id,pr.produto)
select produto_id, produto, receita, ranking
from  cte_produto where ranking <=10; 

-- margem por categoria
WITH cte as(
select pr.categoria, SUM(
    ip.quantidade * ip.preco_unitario
) as receita,
SUM(ip.quantidade*pr.custo_unitario) as custo,  SUM(ip.quantidade * ip.preco_unitario)- SUM(ip.quantidade * pr.custo_unitario) AS lucro
from produtos as pr
join itens_pedido as ip
on pr.produto_id=ip.produto_id
join pedidos as pe
on ip.pedido_id=pe.pedido_id
where pe.status = 'Concluído'
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
where pe.status = 'Concluído'
group by ve.vendedor
order by receita desc;

--  Receita líquida 
select ip.pedido_id, SUM( ip.quantidade * ip.preco_unitario) as Receita_líquida
from itens_pedido as ip
join pedidos as pe
on ip.pedido_id=pe.pedido_id
where pe.status='Concluído'
group by ip.pedido_id;
