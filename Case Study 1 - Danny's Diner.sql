create database danny_project;
use danny_project;
-- This is the solution for 1st case study of the challenge
-- CREATING DATA SET
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),

  ('B', '2021-01-09');

Select *
From members;
Select *
From menu;
Select *
From Sales;

-- SOLUTIONS

-- 1) Total amount spend by each customer

select customer_id, sum(price) Amount_spend
from menu m
join sales s
using(product_id)
group by customer_id;

-- 2 How many dates customer visited the restauraunt

select customer_id,count(distinct order_date) as Cunt
from sales
group by customer_id;

select * from sales;

-- 3. What was the first item from the menu purchased by each customer?

select distinct customer_id,  product_name 
from(
select customer_id,  product_name,
dense_rank() over(partition by customer_id order by order_date) as rnk
from sales s
join menu m
using(product_id)) as t
where rnk=1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select product_id,product_name,cunt from(
select product_id,cunt,product_name,dense_rank() over(order by cunt desc) as rnk
from(
select product_id,count(product_id) as cunt,product_name
from sales s
join menu m
using(product_id)
group by product_id) as t) as t1
where rnk=1;


-- 5. Which item was the most popular for each customer?

select customer_id,product_id,product_name,cunt 
from (
select *, dense_rank() over(partition by customer_id order by cunt desc) rnk 
from
(select customer_id,product_name,product_id,count(product_id) as cunt
from sales s
join menu m
using(product_id)
group by customer_id,product_id
order by customer_id) as t) as t2
where rnk=1;

-- 6. Which item was purchased first by the customer after they became a member?

select customer_id,product_id,product_name,min(order_date) as min_order_date
from(
select me.customer_id,m.product_id,product_name,order_date,join_date
from members me
join sales s
using(customer_id)
join menu m
using(product_id)
where order_date>=join_date) as t
group by customer_id;

-- 7. Which item was purchased just before the customer became a member?

select customer_id,product_id,product_name,order_date
from(
select me.customer_id,m.product_id,product_name,order_date,join_date,dense_rank() over(partition by customer_id order by order_date desc) as rnk
from members me
join sales s
on me.customer_id=s.customer_id and  order_date<join_date
join menu m
using(product_id)
) as t
where rnk=1;

-- 8. What is the total items and amount spent for each member before they became a member?


select me.customer_id,join_date,sum(price) as amount_spend,count(product_id) as total_items
from members me
join sales s
on me.customer_id=s.customer_id and  order_date<join_date
join menu m
using(product_id)
group by customer_id;

select * from menu;
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select customer_id, sum(if (product_name ='sushi', 2* (price*10),price*10))  as points
from sales s
join menu m
using(product_id)
group by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select customer_id,sum(case when order_date between join_date and date_add(join_date,interval 7 day) then  2* (price*10)
else (price*10) end) as Points
from sales s
join members me
using(customer_id)
join menu m
using(product_id)
group by customer_id;


