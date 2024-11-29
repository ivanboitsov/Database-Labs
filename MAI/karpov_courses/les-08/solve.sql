--Task 1

--Объедините таблицы user_actions и users по ключу user_id
SELECT user_actions.user_id as user_id_left,
       users.user_id as user_id_right,
       order_id,
       time,
       action,
       sex,
       birth_date
FROM   user_actions
    INNER JOIN users using (user_id)
ORDER BY user_id

--Task 2

--посчитать количество уникальных id в объединённой таблице
SELECT count(distinct user_id_left) as users_count
FROM   (SELECT user_actions.user_id as user_id_left,
               users.user_id as user_id_right,
               order_id,
               time,
               action,
               sex,
               birth_date
        FROM   user_actions
            INNER JOIN users using (user_id)
        ORDER BY user_id) as t1

--Task 3

--объедините таблицы user_actions и users по ключу user_id

SELECT user_actions.user_id as user_id_left,
       users.user_id as user_id_right,
       order_id,
       time,
       action,
       sex,
       birth_date
FROM   user_actions
    LEFT JOIN users
        ON user_actions.user_id = users.user_id
ORDER BY user_actions.user_id

--Task 4

--посчитайте количество уникальных id в колонке user_id

SELECT count(distinct user_id_left) as users_count
FROM   (SELECT user_actions.user_id as user_id_left,
               users.user_id as user_id_right
        FROM   user_actions
            LEFT JOIN users
                ON user_actions.user_id = users.user_id
        ORDER BY user_actions.user_id) as t1

--Task 5

--добавьте к запросу оператор WHERE и исключите NULL значения в колонке user_id из правой таблицы

SELECT user_actions.user_id as user_id_left,
       users.user_id as user_id_right,
       order_id,
       time,
       action,
       sex,
       birth_date
FROM   user_actions
    LEFT JOIN users
        ON user_actions.user_id = users.user_id
WHERE  users.user_id is not null
ORDER BY user_actions.user_id

--Task 6

--FULL JOIN объедините по ключу birth_date таблицы

SELECT t1.birth_date as users_birth_date,
       users_count,
       t2.birth_date as couriers_birth_date,
       couriers_count
FROM   (SELECT birth_date,
               count(user_id) as users_count
        FROM   users
        WHERE  birth_date is not null
        GROUP BY birth_date) as t1 full join (SELECT birth_date,
                                             count(courier_id) as couriers_count
                                      FROM   couriers
                                      WHERE  birth_date is not null
                                      GROUP BY birth_date) as t2 using (birth_date)
ORDER BY users_birth_date, couriers_birth_date

-- Task 7

--Операция UNION объединяет записи из двух запросов в один общий результат (объединение множеств).

--Операция EXCEPT возвращает все записи,которые есть в первом запросе,но отсутствуют во втором
--(разница множеств)

--Операция INTERSECT возвращает все записи,которые есть и в первом,и во втором запросе (пересечение множеств).

--При этом по умолчанию эти операции исключают из результата строки-дубликаты. Чтобы дубликаты не исключались 
    --из результата, необходимо после имени операции указать ключевое слово ALL

SELECT count(birth_date) as dates_count
FROM   (SELECT birth_date
        FROM   users
        WHERE  birth_date is not null
        UNION
SELECT birth_date
        FROM   couriers
        WHERE  birth_date is not null) as t1

--Task 8

--Из таблицы users отберите id первых 100 пользователей (просто выберите первые 100 записей, 
    --используя простой LIMIT)
--и с помощью CROSS JOIN объедините их со всеми наименованиями товаров из таблицы products

SELECT user_id,
       name
FROM   (SELECT user_id
        FROM   users limit 100) t1 cross join (SELECT name
                                       FROM   products) t2
ORDER BY user_id, name

--Task 9

--user_actions и orders. В качестве ключа используйте поле order_id

SELECT user_id,
       order_id,
       product_ids
FROM   user_actions
    LEFT JOIN orders using(order_id)
ORDER BY user_id, order_id limit 1000

--Task 10

--объедините таблицы user_actions и orders, но теперь оставьте только уникальные неотменённые заказы

SELECT user_id,
       order_id,
       product_ids
FROM   (SELECT user_id,
               order_id
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) t
    LEFT JOIN orders using(order_id)
ORDER BY user_id, order_id limit 1000

--Task 11

-- сколько в среднем товаров заказывает каждый пользователь

SELECT user_id,
       round(avg(array_length(product_ids, 1)), 2) as avg_order_size
FROM   (SELECT user_id,
               order_id
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) t1
    LEFT JOIN orders using(order_id)
GROUP BY user_id
ORDER BY user_id limit 1000

--Task 12

--информация о стоимости каждого отдельного заказа

SELECT order_id,
       product_id,
       price
FROM   (SELECT order_id,
               product_ids,
               unnest(product_ids) as product_id
        FROM   orders) as t
    LEFT JOIN products using(product_id)
ORDER BY order_id, product_id limit 1000

--Task 13

--рассчитайте суммарную стоимость каждого заказа

SELECT order_id as order_id,
       sum(price) as order_price
FROM   (SELECT unnest_orders.order_id,
               unnest_orders.product_id,
               products.price
        FROM   (SELECT order_id,
                       unnest(product_ids) as product_id
                FROM   orders) as unnest_orders
            LEFT JOIN products using (product_id)) as t1
GROUP BY 1
ORDER BY 1 limit 1000

--Task  14

--На основе объединённой таблицы для каждого пользователя рассчитайте следующие показатели:

--общее число заказов — колонку назовите orders_count
--среднее количество товаров в заказе — avg_order_size
--суммарную стоимость всех покупок — sum_order_value
--среднюю стоимость заказа — avg_order_value
--минимальную стоимость заказа — min_order_value
--максимальную стоимость заказа — max_order_value

SELECT user_id,
       count(order_price) as orders_count,
       round(avg(order_size), 2) as avg_order_size,
       sum(order_price) as sum_order_value,
       round(avg(order_price), 2) as avg_order_value,
       min(order_price) as min_order_value,
       max(order_price) as max_order_value
FROM   (SELECT user_id,
               order_id,
               array_length(product_ids, 1) as order_size
        FROM   (SELECT user_id,
                       order_id
                FROM   user_actions
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t1
            LEFT JOIN orders using(order_id)) t2
    LEFT JOIN (SELECT order_id,
                      sum(price) as order_price
               FROM   (SELECT order_id,
                              product_ids,
                              unnest(product_ids) as product_id
                       FROM   orders
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')) t3
                   LEFT JOIN products using(product_id)
               GROUP BY order_id) t4 using (order_id)
GROUP BY user_id
ORDER BY user_id limit 1000

--Task 15

--По данным таблиц orders, products и user_actions посчитайте ежедневную выручку сервиса. 
--Под выручкой будем понимать стоимость всех реализованных товаров, содержащихся в заказах.


--Вариант верного решения:

SELECT date(creation_time) as date,
       sum(price) as revenue
FROM   (SELECT order_id,
               creation_time,
               product_ids,
               unnest(product_ids) as product_id
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) t1
    LEFT JOIN products using(product_id)
GROUP BY date


--Task 16
--По таблицам courier_actions , orders и products 
--определите 10 самых популярных товаров, доставленных в сентябре 2022 года

SELECT name,
       count(product_id) as times_purchased
FROM   (SELECT order_id,
               product_id,
               name
        FROM   (SELECT DISTINCT order_id,
                                unnest(product_ids) as product_id
                FROM   orders
                    LEFT JOIN courier_actions using (order_id)
                WHERE  action = 'deliver_order'
                   and date_part('month', time) = 9
                   and date_part('year', time) = 2022) t1
            LEFT JOIN products using (product_id)) t2
GROUP BY name
ORDER BY times_purchased desc limit 10

--Task 17

-- посчитайте среднее значение cancel_rate для каждого пола

SELECT coalesce(sex, 'unknown') as sex,
       round(avg(cancel_rate), 3) as avg_cancel_rate
FROM   (SELECT user_id,
        count(order_id) filter (WHERE action = 'create_order') as orders_count,
         round((count(order_id) filter
    (WHERE action = 'cancel_order'))::decimal / (count(order_id) filter (WHERE action = 'create_order')),
                     2) as cancel_rate
        FROM   user_actions
        GROUP BY user_id) as user_cancel_rate
    LEFT JOIN users using (user_id)
GROUP BY sex
ORDER BY sex

--Task 18

--определите id десяти заказов, которые доставляли дольше всего

SELECT order_id
FROM   (SELECT order_id,
               time as delivery_time
        FROM   courier_actions
        WHERE  action = 'deliver_order') as t
    LEFT JOIN orders using (order_id)
ORDER BY delivery_time - creation_time desc limit 10

--Task 19

--Произведите замену списков с id товаров из таблицы orders на списки с наименованиями товаров

--array_agg — это продвинутая агрегирующая функция, которая собирает все значения в указанном 
--столбце в единый список (ARRAY).
--По сути array_agg — это операция, обратная unnest

SELECT order_id,
       array_agg(name) as product_names
FROM   (SELECT order_id,
               unnest(product_ids) as product_id
        FROM   orders) t 
    join products using(product_id)
GROUP BY order_id limit 1000

--Task 20

--Выясните, кто заказывал и доставлял самые большие заказы

with order_id_large_size as (SELECT order_id
                     FROM   orders
                      WHERE  array_length(product_ids, 1) = (SELECT max(array_length(product_ids, 1))
                                                                    FROM   orders))
SELECT DISTINCT order_id,
                user_id,
                date_part('year', age((SELECT max(time)
                       FROM   user_actions), users.birth_date))::integer as user_age, courier_id, 
    date_part('year', age((SELECT max(time)                                                                                                 
    FROM   user_actions), couriers.birth_date))::integer as courier_age
FROM   (SELECT order_id,
               user_id
        FROM   user_actions
        WHERE  order_id in (SELECT *
                            FROM   order_id_large_size)) t1
    LEFT JOIN (SELECT order_id,
                      courier_id
               FROM   courier_actions
               WHERE  order_id in (SELECT *
                                   FROM   order_id_large_size)) t2 using(order_id)
    LEFT JOIN users using(user_id)
    LEFT JOIN couriers using(courier_id)
ORDER BY order_id

--Task 21

--колонку с парами наименований товаров и колонку со значениями, 
--показывающими, сколько раз конкретная пара встретилась в заказах пользователей

SELECT array_sort(array[m.name, n.name]) as pair,
       count(o.order_id) as count_pair
FROM   products m join products n
        ON m.product_id < n.product_id join orders o
        ON m.product_id = any(o.product_ids) and
           n.product_id = any(o.product_ids) and
           o.order_id not in (SELECT order_id
                   FROM   user_actions
                   WHERE  action = 'cancel_order')
GROUP BY m.product_id, n.product_id, m.name, n.name
ORDER BY count_pair desc, pair;