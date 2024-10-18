-- 1 Task

SELECT *
FROM   products

-- 2 Task

SELECT *
FROM   products
ORDER BY name asc

-- 3 Task

SELECT *
FROM   courier_actions
ORDER BY courier_id asc, action asc, time desc, order_id limit 1000

-- 4 Task

SELECT name,
       price
FROM   products
ORDER BY price desc limit 5

-- 5 Task

SELECT name as product_name,
       price as product_price
FROM   products
ORDER BY product_price desc limit 5

-- 6 Task

SELECT name,
       length(name) as name_length,
       price
FROM   products
ORDER BY name_length desc limit 1

-- 7 Task

SELECT name,
       upper(split_part(name, ' ', 1)) as first_word,
       price
FROM   products
ORDER BY name asc

-- 8 Task

SELECT name,
       price,
       price::varchar as price_char
FROM   products
ORDER BY name asc

-- 9 Task

SELECT concat('Заказ № ',
              order_id ,
              ' создан ',
              creation_time::date) as order_info
FROM   orders limit 200

-- 10 Task

SELECT courier_id,
       date_part('year', birth_date) as birth_year
FROM   couriers
ORDER BY birth_year desc, courier_id asc

-- 11 Task

SELECT courier_id,
       coalesce(cast(date_part('year', birth_date) as varchar), 'unknown') as birth_year
FROM   couriers
ORDER BY birth_year desc, courier_id asc

-- 12 Task

SELECT product_id,
       name,
       price as old_price,
       (price * 1.05) as new_price
FROM   products
ORDER BY new_price desc, product_id asc

-- 13 Task

SELECT product_id,
       name,
       price as old_price,
       round(price * 1.05, 1) as new_price
FROM   products
ORDER BY new_price desc, product_id asc

-- 14 Task

SELECT product_id,
       name,
       price as old_price,
       case when price > 100 and
                 name != 'икра' then price * 1.05
            else price end as new_price
FROM   products
ORDER BY new_price desc, product_id asc

-- 15 Task

SELECT product_id,
       name,
       price,
       round(price / 1.2 * 0.2 , 2) as tax,
       round(price - round(price / 1.2 * 0.2 , 2), 2) as price_before_tax
FROM   products
ORDER BY price desc, product_id