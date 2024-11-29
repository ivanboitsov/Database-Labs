--Task 1

--рассчитайте среднее число заказов всех пользователей

SELECT round(avg(orders_count), 2) as orders_avg
FROM   (SELECT user_id,
               count(order_id) as orders_count
        FROM   user_actions
        WHERE  action = 'create_order'
        GROUP BY user_id) as t1

--Task 2

--рассчитайте среднее число заказов всех пользователей

with t1 as (SELECT user_id,
                   count(order_id) as orders_count
            FROM   user_actions
            WHERE  action = 'create_order'
            GROUP BY user_id)
SELECT round(avg(orders_count), 2) as orders_avg
FROM   t1

--Task 3

--информацию о всех товарах кроме самого дешёвого

SELECT product_id,
       name,
       price
FROM   products
WHERE  price != (SELECT min(price)
                 FROM   products)
ORDER BY product_id desc


--Task 4

--информацию о товарах в таблице products, 
--цена на которые превышает среднюю цену всех товаров на 20 рублей и более
SELECT product_id,
       name,
       price
FROM   products
WHERE  price >= (SELECT avg(price)
                 FROM   products) + 20
ORDER BY product_id desc

--Task 5

--количество уникальных клиентов в таблице user_actions, 
--сделавших за последнюю неделю хотя бы один заказ
SELECT count(distinct user_id) as users_count
FROM   user_actions
WHERE  action = 'create_order'
   and time >= (SELECT max(time)
             FROM   user_actions) - interval '1 week'

--Task 6

--возраст самого молодого курьера мужского пола в таблице couriers, 
--но в этот раз при расчётах в качестве первой даты используйте последнюю 
--дату из таблицы courier_actions
    
SELECT min(age((SELECT max(time) :: date
                FROM   courier_actions), birth_date)) :: varchar as min_age
FROM   couriers
WHERE  sex = 'male'

--Task 7

--отберите все заказы, которые не были отменены пользователями

    SELECT order_id
FROM   orders
WHERE  order_id not in (SELECT order_id
                        FROM   user_actions
                        WHERE  action = 'cancel_order')
ORDER BY order_id limit 1000

--Task 8

--сколько заказов сделал каждый пользователь
--среднее число заказов всех пользователей
--(отклонение числа заказов от среднего значения) число заказов «минус» округлённое среднее значение

with t1 as (SELECT user_id,
                   count(order_id) as orders_count
            FROM   user_actions
            WHERE  action = 'create_order'
            GROUP BY user_id)
SELECT user_id,
       orders_count,
       round((SELECT avg(orders_count)
       FROM   t1), 2) as orders_avg, orders_count - round((SELECT avg(orders_count)
                                                    FROM   t1), 2) as orders_diff
FROM   t1
ORDER BY user_id limit 1000

--Task 9

with t1 as (SELECT user_id,
                   count(order_id) as orders_count
            FROM   user_actions
            WHERE  action = 'create_order'
            GROUP BY user_id)
SELECT user_id,
       orders_count,
       round((SELECT avg(orders_count)
       FROM   t1), 2) as orders_avg, orders_count - round((SELECT avg(orders_count)
                                                    FROM   t1), 2) as orders_diff
FROM   t1
ORDER BY user_id limit 1000

--Task 10 

--заказы, которые были приняты курьерами, но не были созданы пользователями

SELECT count(distinct order_id) as orders_count
FROM   courier_actions
WHERE  order_id not in (SELECT order_id
                        FROM   user_actions)

--Task 11

--приняты курьерами, но не были доставлены пользователям

SELECT count(order_id) as orders_count
FROM   courier_actions
WHERE  order_id not in (SELECT order_id
                        FROM   courier_actions
                        WHERE  action = 'deliver_order')

--Task 12

--отменены пользователями, но при этом всё равно были доставлены

SELECT count(distinct order_id) as orders_canceled,
       count(order_id) filter (WHERE action = 'deliver_order') as orders_canceled_and_delivered
FROM   courier_actions
WHERE  order_id in (SELECT order_id
                    FROM   user_actions
                    WHERE  action = 'cancel_order')


--Task 13

--число недоставленных заказов и среди них посчитайте 
--количество отменённых заказов и количество заказов, которые не были отменены 

SELECT count(distinct order_id) as orders_undelivered,
       count(order_id) filter (WHERE action = 'cancel_order') as orders_canceled,
       count(distinct order_id) - count(order_id) filter (WHERE action = 'cancel_order') 
    as orders_in_process
FROM   user_actions
WHERE  order_id in (SELECT order_id
                    FROM   courier_actions
                    WHERE  order_id not in (SELECT order_id
                                            FROM   courier_actions
                                            WHERE  action = 'deliver_order'))

--Task 14

--пользователей мужского пола,которые старше всех пользователей женского пола

SELECT user_id,
       birth_date
FROM   users
WHERE  sex = 'male'
   and birth_date < (SELECT min(birth_date)
                  FROM   users
                  WHERE  sex = 'female')

--Task 15

--id и содержимое 100 последних доставленных заказов

SELECT order_id,
       product_ids
FROM   orders
WHERE  order_id in (SELECT order_id
                    FROM   courier_actions
                    WHERE  action = 'deliver_order'
                    ORDER BY time desc limit 100)
ORDER BY order_id

--Task 16

--в сентябре 2022 года доставили 30 и более заказов

SELECT courier_id,
       birth_date,
       sex
FROM   couriers
WHERE  courier_id in (SELECT courier_id
                      FROM   courier_actions
                      WHERE  action = 'deliver_order'
                         and date_part('month', time) = '09'
                         and date_part('year', time) = '2022'
                      GROUP BY courier_id having count(distinct order_id) >= 30)
ORDER BY courier_id

--Task 17

--средний размер заказов, отменённых пользователями мужского пола

SELECT round(avg(array_length(product_ids, 1)), 3) as avg_order_size
FROM   orders
WHERE  order_id in (SELECT order_id
                    FROM   user_actions
                    WHERE  action = 'cancel_order'
                       and user_id in (SELECT user_id
                                    FROM   users
                                    WHERE  sex = 'male'))

--Task 18

--Посчитайте возраст каждого пользователя в таблице users.
--Возраст измерьте числом полных лет, как мы делали в прошлых уроках. 
--Возраст считайте относительно последней даты в таблице user_actions.
--Для тех пользователей, у которых в таблице users не указана дата рождения, 
--укажите среднее значение возраста всех остальных пользователей, округлённое до целого числа

with users_age as (SELECT user_id,
                          date_part('year', age((SELECT max(time)
                                          FROM   user_actions), birth_date)) as age
                   FROM   users)
SELECT user_id,
       coalesce(age, (SELECT round(avg(age))
               FROM   users_age))::integer as age
FROM   users_age
ORDER BY user_id

--Task 19

--Для каждого заказа, в котором больше 5 товаров, рассчитайте время, затраченное на его доставку.
--В расчётах учитывайте только неотменённые заказы. 
--Время, затраченное на доставку, выразите в минутах, округлив значения до целого числа
    
SELECT order_id,
       min(time) as time_accepted,
       max(time) as time_delivered,
       (extract(epoch FROM   max(time) - min(time))/60)::integer as delivery_time
FROM   courier_actions
WHERE  order_id in (SELECT order_id
                    FROM   orders
                    WHERE  array_length(product_ids, 1) > 5)
   and order_id not in (SELECT order_id
                     FROM   user_actions
                     WHERE  action = 'cancel_order')
GROUP BY order_id
ORDER BY order_id

--Task 20

--Для каждой даты в таблице user_actions посчитайте количество первых заказов, совершённых пользователями.
--Первыми заказами будем считать заказы, которые пользователи сделали в нашем сервисе впервые. 
--В расчётах учитывайте только неотменённые заказы

SELECT date,
       count(user_id) as first_orders
FROM   (SELECT user_id,
               date(min(time)) as date
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY user_id) as t1
GROUP BY date
ORDER BY date

--Task 21

--Функция unnest предназначена для разворачивания массивов и превращения их в набор строк
SELECT creation_time,
       order_id,
       product_ids,
       unnest(product_ids) as product_id
FROM   orders limit 100

--Task 22

--определите 10 самых популярных товаров 
    
SELECT * FROM(SELECT unnest(product_ids) as product_id,
                     count(*) as times_purchased
              FROM   orders
              WHERE  order_id not in (SELECT order_id
                                      FROM   user_actions
                                      WHERE  action = 'cancel_order')
              GROUP BY product_id
              ORDER BY times_purchased desc limit 10) as t1
ORDER BY product_id

--Task 23

--выведите id и содержимое заказов, которые включают хотя бы один из пяти самых дорогих товаров

with top_products as (SELECT product_id
                      FROM   products
                      ORDER BY price desc limit 5), unnest as (SELECT order_id,
                                                product_ids,
                                                unnest(product_ids) as product_id
                                         FROM   orders)
SELECT DISTINCT order_id,
                product_ids
FROM   unnest
WHERE  product_id in (SELECT *
                      FROM   top_products)
ORDER BY order_id
