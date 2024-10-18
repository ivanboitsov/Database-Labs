-- 1 Task

SELECT *
FROM   products
WHERE  price <= 100
ORDER BY product_id asc

-- 2 Task

SELECT user_id
FROM   users
WHERE  sex = 'female'
ORDER BY user_id asc limit 1000

-- 3 Task

SELECT user_id,
       order_id,
       time
FROM   user_actions
WHERE  time > '2022-09-06'
   and action = 'create_order'
ORDER BY order_id asc

-- 4 Task

SELECT product_id,
       name,
       price as old_price,
       price * 0.8 as new_price
FROM   products
WHERE  price * 0.8 > 100
ORDER BY product_id 

-- 5 Task

SELECT product_id,
       name
FROM   products
WHERE  'чай' = split_part(name, ' ', 1)
    or length(name) = 5
ORDER BY product_id

-- 6 Task

SELECT product_id,
       name
FROM   products
WHERE  name like '%чай%'
    or name = '_чай'
ORDER BY product_id

-- 7 Task

SELECT product_id,
       name
FROM   products
WHERE  name like 'с%'
   and not name like '% %'
ORDER BY product_id

-- 8 Task

SELECT product_id,
       name,
       price,
       cast('25%' as varchar) as discount,
       price * 0.75 as new_price
FROM   products
WHERE  price >= 60
   and not name like 'чайный гриб'
   and name like 'чай%'
ORDER BY product_id

-- 9 Task

SELECT *
FROM   user_actions
WHERE  user_id in (170, 200, 230)
   and time between '2022-08-25'
   and '2022-09-05'
ORDER BY order_id desc

-- 10 Task

SELECT birth_date,
       courier_id,
       sex
FROM   couriers
WHERE  birth_date is null
ORDER BY courier_id asc

-- 11 Task

SELECT user_id,
       birth_date
FROM   users
WHERE  birth_date is not null
   and sex = 'male'
ORDER BY birth_date desc limit 50

-- 12 Task

SELECT order_id,
       time
FROM   courier_actions
WHERE  courier_id = 100
   and action = 'deliver_order'
ORDER BY order_id desc limit 10

-- 13 Task

SELECT order_id
FROM   user_actions
WHERE  action = 'create_order'
   and time between '2022-08-01'
   and '2022-09-01'
ORDER BY order_id asc

-- 14 Task

SELECT courier_id
FROM   couriers
WHERE  birth_date is not null
   and birth_date >= '1990-01-01'
   and birth_date <= '1996-01-01'
ORDER BY courier_id asc

-- 15 Task

SELECT *
FROM   user_actions
WHERE  action = 'cancel_order'
   and time between '2022-08-01'
   and '2022-09-01'
   and date_part('dow', time) = 3
   and date_part('hour', time) >= 12
   and date_part('hour', time) < 16
ORDER BY order_id desc

-- 16 Task

SELECT product_id,
       name,
       price,
       case when name = 'сахар' or
                 name = 'сухарики' or
                 name = 'сушки' or
                 name = 'семечки' or
                 name = 'масло льняное' or
                 name = 'виноград' or
                 name = 'масло оливковое' or
                 name = 'арбуз' or
                 name = 'батон' or
                 name = 'йогурт' or
                 name = 'сливки' or
                 name = 'гречка' or
                 name = 'овсянка' or
                 name = 'макароны' or
                 name = 'баранина' or
                 name = 'апельсины' or
                 name = 'бублики' or
                 name = 'хлеб' or
                 name = 'горох' or
                 name = 'сметана' or
                 name = 'рыба копченая' or
                 name = 'мука' or
                 name = 'шпроты' or
                 name = 'сосиски' or
                 name = 'свинина' or
                 name = 'рис' or
                 name = 'масло кунжутное' or
                 name = 'сгущенка' or
                 name = 'ананас' or
                 name = 'говядина' or
                 name = 'соль' or
                 name = 'рыба вяленая' or
                 name = 'масло подсолнечное' or
                 name = 'яблоки' or
                 name = 'груши' or
                 name = 'лепешка' or
                 name = 'молоко' or
                 name = 'курица' or
                 name = 'лаваш' or
                 name = 'вафли' or
                 name = 'мандарины'then round(price/110*10, 2)
            else round(price/120*20, 2) end as tax,
       case when name = 'сахар' or
                 name = 'сухарики' or
                 name = 'сушки' or
                 name = 'семечки' or
                 name = 'масло льняное' or
                 name = 'виноград' or
                 name = 'масло оливковое' or
                 name = 'арбуз' or
                 name = 'батон' or
                 name = 'йогурт' or
                 name = 'сливки' or
                 name = 'гречка' or
                 name = 'овсянка' or
                 name = 'макароны' or
                 name = 'баранина' or
                 name = 'апельсины' or
                 name = 'бублики' or
                 name = 'хлеб' or
                 name = 'горох' or
                 name = 'сметана' or
                 name = 'рыба копченая' or
                 name = 'мука' or
                 name = 'шпроты' or
                 name = 'сосиски' or
                 name = 'свинина' or
                 name = 'рис' or
                 name = 'масло кунжутное' or
                 name = 'сгущенка' or
                 name = 'ананас' or
                 name = 'говядина' or
                 name = 'соль' or
                 name = 'рыба вяленая' or
                 name = 'масло подсолнечное' or
                 name = 'яблоки' or
                 name = 'груши' or
                 name = 'лепешка' or
                 name = 'молоко' or
                 name = 'курица' or
                 name = 'лаваш' or
                 name = 'вафли' or
                 name = 'мандарины'then round(price - price/110*10, 2)
            else round(price - price/120*20, 2) end as price_before_tax
FROM   products
ORDER BY price_before_tax desc, product_id