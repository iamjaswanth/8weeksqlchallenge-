-- What is the total amount each customer spent at the restaurant?
select customer_id,sum(price) as Amount_Spent
       from dannys_diner.sales 
       inner join 
       dannys_diner.menu on sales.product_id = menu.product_id 
       group by customer_id
       order by Amount_Spent desc
       
-- How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date) as visted_days 
       from dannys_diner.sales 
       group by customer_id 
       order by visted_days desc

--What was the first item from the menu purchased by each customer?
with CTE as (
select customer_id,order_date,product_name,
       RANK() OVER(PARTITION BY customer_id
       ORDER BY order_date) AS ranking
  from dannys_diner.sales
  inner join
  dannys_diner.menu on sales.product_id = menu.product_id)
  select DISTINCT customer_id,product_name from CTE where ranking = 1
  
  
--What is the most purchased item on the menu and how many times was it purchased by all customers?

select product_name,count(customer_id) as purchases 
       from dannys_diner.sales 
       inner join dannys_diner.menu 
       on sales.product_id = menu.product_id
       group by product_name 
       order by purchases desc 
       limit 1
       
--Which item was the most popular for each customer?
with cte as (
select customer_id,product_name,count(customer_id) as item_quantity, 
       RANK() OVER (PARTITION BY customer_id
      ORDER BY COUNT(customer_id) DESC) AS item_rank
       from dannys_diner.sales 
       inner join dannys_diner.menu 
       on sales.product_id = menu.product_id 
       group by customer_id,product_name
) select customer_id,product_name,item_quantity from cte where item_rank = 1


-- Which item was purchased first by the customer after they became a member?
with cte as (
select sales.customer_id,
       sales.order_date,
       sales.product_id,
       members.join_date,
       RANK() over (partition by sales.customer_id order by sales.order_date) as rankin
       from dannys_diner.sales 
       inner join dannys_diner.members 
       on 
       sales.customer_id = members.customer_id
       where sales.order_date >= members.join_date)
       
       select customer_id,order_date,rankin,menu.product_name from cte 
       inner join dannys_diner.menu 
       on 
       cte.product_id = menu.product_id
       where rankin = 1

--Which item was purchased just before the customer became a member?   
with cte as (
select sales.customer_id,
       sales.order_date,
       sales.product_id,
       members.join_date,
       RANK() over (partition by sales.customer_id order by sales.order_date desc) as rankin
       from dannys_diner.sales 
       inner join dannys_diner.members 
       on 
       sales.customer_id = members.customer_id
       where sales.order_date < members.join_date)
       select customer_id,order_date,rankin,menu.product_name from cte 
       inner join dannys_diner.menu 
       on 
       cte.product_id = menu.product_id
       where rankin = 1
       order by order_date


--What is the total items and amount spent for each member before they became a member?

select sales.customer_id,
       count(distinct sales.product_id) as total_products ,
       sum(menu.price) as amount_spent
       from dannys_diner.sales 
       inner join dannys_diner.menu on sales.product_id = menu.product_id 
       inner join dannys_diner.members on sales.customer_id = members.customer_id
       where sales.order_date < members.join_date
       group by 1
       
--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte as (
 SELECT *, 
    CASE
        WHEN product_id = 1 THEN price * 20
        ELSE price * 10
        END AS points
 FROM dannys_diner.menu)

select sales.customer_id,sum(points) from cte inner join dannys_diner.sales on sales.product_id = cte.product_id group by 1
       

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?     
with cte as (
SELECT *, join_date+6 as valid_date,(date_trunc('month', join_date) + interval '1 month - 1 day')::date as end_of_month from dannys_diner.members)
SELECT cte.customer_id, sales.order_date, cte.join_date, 
 cte.valid_date, cte.end_of_month, menu.product_name, menu.price,
SUM(CASE
  WHEN menu.product_name = 'sushi' THEN 2 * 10 * menu.price
  WHEN sales.order_date BETWEEN cte.join_date AND cte.valid_date THEN 2 * 10 * menu.price
  ELSE 10 * menu.price
  END) AS points
from cte
inner join dannys_diner.sales 
on cte.customer_id = sales.customer_id
inner join dannys_diner.members 
on cte.customer_id = members.customer_id
inner join dannys_diner.menu
on sales.product_id = menu.product_id
GROUP BY cte.customer_id, sales.order_date, cte.join_date, cte.valid_date, cte.end_of_month, menu.product_name, menu.price
order by price desc


















