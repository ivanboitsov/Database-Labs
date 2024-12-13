--10.1
--Примените оконные функции к таблице products и с помощью ранжирующих функций упорядочьте 
--все товары по цене — от самых дорогих к самым дешёвым. Добавьте в таблицу следующие колонки:

--Колонку product_number с порядковым номером товара (функция ROW_NUMBER).
--Колонку product_rank с рангом товара с пропусками рангов (функция RANK).
--Колонку product_dense_rank с рангом товара без пропусков рангов (функция DENSE_RANK)

SELECT product_id,
       name,
       price,
       row_number() OVER (ORDER BY price desc) as product_number,
       rank() OVER (ORDER BY price desc) as product_rank,
       dense_rank() OVER (ORDER BY price desc) as product_dense_rank
FROM   products

--10.2
--для каждой записи проставьте цену самого дорогого товара, 
--для каждого товара посчитайте долю его цены в стоимости самого дорогого товара

SELECT product_id,
       name,
       price,
       max(price) OVER () as max_price,
       round(price::decimal/max(price) OVER (), 2) as share_of_max
FROM   products
ORDER BY price desc, product_id

--10.3
--для вычисления максимальной и минимальной цены

SELECT product_id,
       name,
       price,
       max(price) OVER (ORDER BY price desc) as max_price,
       min(price) OVER (ORDER BY price desc) as min_price
FROM   products
ORDER BY price desc, product_id


--10.4
--на основе таблицы orders сформируйте новую таблицу с общим числом заказов по дням
-- поместите полученную таблицу в подзапрос и примените к ней оконную функцию в паре с 
    --агрегирующей функцией SUM для расчёта накопительной суммы числа заказов
--Не забудьте для окна задать инструкцию ORDER BY по дате

SELECT date,
       orders_count,
       sum(orders_count) OVER (ORDER BY date)::integer as orders_cum_count
FROM   (SELECT date(creation_time) as date,
               count(order_id) as orders_count
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY date) t

--10.5
--Для каждого пользователя в таблице user_actions посчитайте порядковый номер каждого заказа
--Для этого примените оконную функцию ROW_NUMBER к колонке с временем заказа

SELECT user_id,
       order_id,
       time,
       row_number() OVER (PARTITION BY user_id
                          ORDER BY time) as order_number
FROM   user_actions
WHERE  order_id not in (SELECT order_id
                        FROM   user_actions
                        WHERE  action = 'cancel_order')
ORDER BY user_id, order_number limit 1000

--10.6
SELECT LAG(column, 1) OVER (PARTITION BY ... ORDER BY ... ROWS/RANGE BETWEEN ...) AS lag_value
FROM table

SELECT LEAD(column, 1) OVER (PARTITION BY ... ORDER BY ... ROWS/RANGE BETWEEN ...) AS lead_value
FROM table

--В качестве первого аргумента у функций LAG и LEAD указывается колонка со значениями, 
--в качестве второго — то, на какое число строк производить смещение (назад и вперёд соответственно). 
--Второй аргумент можно не указывать, по умолчанию его значение равно 1.

--ополните запрос из предыдущего задания и с помощью оконной функции для каждого заказа каждого пользователя рассчитайте, 
--сколько времени прошло с момента предыдущего заказа

SELECT user_id,
       order_id,
       time,
       row_number() OVER (PARTITION BY user_id
                          ORDER BY time) as order_number,
       lag(time, 1) OVER (PARTITION BY user_id
                          ORDER BY time) as time_lag,
       time - lag(time, 1) OVER (PARTITION BY user_id
                                 ORDER BY time) as time_diff
FROM   user_actions
WHERE  order_id not in (SELECT order_id
                        FROM   user_actions
                        WHERE  action = 'cancel_order')
ORDER BY user_id, order_number limit 1000

--10.8
--для каждого пользователя рассчитайте, сколько в среднем времени проходит между его заказами. 
--Посчитайте этот показатель только для тех пользователей, 
--которые за всё время оформили более одного неотмененного заказа

SELECT user_id,
       avg(time_diff)::integer as hours_between_orders
FROM   (SELECT user_id,
               order_id,
               time,
               extract(epoch
        FROM   (time - lag(time, 1)
        OVER (
        PARTITION BY user_id
        ORDER BY time)))/3600 as time_diff
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) t
WHERE  time_diff is not null
GROUP BY user_id
ORDER BY user_id limit 1000

--10.9
--сформируйте новую таблицу с общим числом заказов по дням
--примените к ней оконную функцию в паре с агрегирующей функцией AVG для расчёта скользящего среднего 
--числа заказов.
--Скользящее среднее для каждой записи считайте по трём предыдущим дням

SELECT date,
       orders_count,
       round(avg(orders_count) OVER (rows between 3 preceding and 1 preceding),
             2) as moving_avg
FROM   (SELECT creation_time::date as date,
               count(order_id) as orders_count
        FROM   orders
            INNER JOIN (SELECT order_id
                        FROM   user_actions
                        WHERE  order_id not in (SELECT order_id
                                         FROM   user_actions
                                        WHERE  action = 'cancel_order')) as t using (order_id)
        GROUP BY creation_time::date
        ORDER BY 1) as by_date_count;

--10.10
--тех курьеров, которые доставили в сентябре 2022 года заказов больше, чем в среднем все курьеры

SELECT courier_id,
       delivered_orders,
       round(avg(delivered_orders) OVER(), 2) as avg_delivered_orders,
       case when delivered_orders > round(avg(delivered_orders) OVER(), 2) then '1'
            else '0' end as is_above_avg
FROM   (SELECT courier_id,
               count(order_id) as delivered_orders
        FROM   courier_actions
        WHERE  action = 'deliver_order'
           and date_part('month', time) = 9
           and date_part('year', time) = 2022
        GROUP BY courier_id
        ORDER BY courier_id) as t1

--10.11
--По данным таблицы user_actions посчитайте число первых и повторных заказов на каждую дату

SELECT time::date as date,
       order_type,
       count(order_id) as orders_count
FROM   (SELECT user_id,
               order_id,
               time,
               case when time = min(time) OVER (PARTITION BY user_id) then 'Первый'
                    else 'Повторный' end as order_type
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) t
GROUP BY date, order_type
ORDER BY date, order_type

--10.12
--К запросу, полученному на предыдущем шаге, примените оконную функцию и
--для каждого дня посчитайте долю первых и повторных заказов

SELECT date,
       order_type,
       orders_count,
       round(orders_count / sum(orders_count) OVER (PARTITION BY date),
             2) as orders_share
FROM   (SELECT time::date as date,
               order_type,
               count(order_id) as orders_count
        FROM   (SELECT user_id,
                       order_id,
                       time,
                       case when time = min(time) OVER (PARTITION BY user_id) then 'Первый'
                            else 'Повторный' end as order_type
                FROM   user_actions
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t
        GROUP BY date, order_type) t
ORDER BY date, order_type

--10.13
--среднюю цену всех товаров. Колонку с этим значением назовите avg_price.

--Затем с помощью оконной функции и оператора FILTER в отдельной колонке 
--рассчитайте среднюю цену товаров без учёта самого дорогого.

SELECT product_id,
       name,
       price,
       round(avg(price) OVER (), 2) as avg_price,
       round(avg(price) filter (WHERE price != (SELECT max(price)
                                         FROM   products))
OVER (), 2) as avg_price_filtered
FROM   products
ORDER BY price desc, product_id

--Оконка внутри ROUND, т.к. "round is not a window function nor an aggregate function"

--10.14
--Для каждой записи в таблице user_actions с помощью оконных функций и предложения FILTER посчитайте,
--сколько заказов сделал и сколько отменил каждый пользователь на момент совершения нового действия.

--Иными словами, для каждого пользователя в каждый момент времени посчитайте две накопительные суммы — 
--числа оформленных и числа отменённых заказов
--На основе этих двух колонок для каждой записи пользователя посчитайте показатель cancel_rate, 
--т.е. долю отменённых заказов в общем количестве оформленных заказов. Значения показателя 
--округлите до двух знаков после запятой

SELECT user_id,
       order_id,	
       action,
       time,
       COUNT(order_id) filter (WHERE action != 'cancel_order') OVER (PARTITION BY user_id ORDER BY time)  AS created_orders,
       COUNT(order_id) filter (WHERE action = 'cancel_order') OVER (PARTITION BY user_id ORDER BY time)  AS canceled_orders,
       round((COUNT(order_id) filter (WHERE action = 'cancel_order') OVER (PARTITION BY user_id ORDER BY time))::decimal / 
       (COUNT(order_id) filter (WHERE action != 'cancel_order') OVER (PARTITION BY user_id ORDER BY time)), 2) as cancel_rate
FROM user_actions
ORDER BY user_id, order_id, time
LIMIT 1000

--10.15
--Из таблицы courier_actions отберите топ 10% курьеров по количеству доставленных за всё время заказов

SELECT courier_id,
       orders_count,
       row_number() OVER (ORDER BY orders_count desc, courier_id) as courier_rank 
    FROM(SELECT courier_id,                                                                                       
    count(order_id) as orders_count                                                                               
    FROM   courier_actions                                                                                
    WHERE  action = 'deliver_order'                                                                               
    GROUP BY courier_id) t1 limit round((SELECT count(distinct courier_id)                                     
    FROM   courier_actions)*0.1)

--10.16
--С помощью оконной функции отберите из таблицы courier_actions всех курьеров, которые работают в нашей компании 10 и более дней. Также рассчитайте, сколько заказов они уже успели доставить за всё время работы.
--Будем считать, что наш сервис предлагает самые выгодные условия труда и поэтому за весь анализируемый период ни один курьер не уволился из компании. Возможные перерывы между сменами не учитывайте — для нас важна только разница во времени между первым действием курьера и текущей отметкой времени.
--Текущей отметкой времени, относительно которой необходимо рассчитывать продолжительность работы курьера, считайте время последнего действия в таблице courier_actions. Учитывайте только целые дни, прошедшие с момента первого выхода курьера на работу (часы и минуты не учитывайте).
--В результат включите три колонки: id курьера, продолжительность работы в днях и число доставленных заказов.
--Две новые колонки назовите соответственно days_employed и delivered_orders.
--Результат отсортируйте сначала по убыванию количества отработанных дней, затем по возрастанию id курьера.

SELECT courier_id,
       date_part ('day', last_date - first_date)::int as days_employed,
       delivered_orders FROM(SELECT courier_id,
                             count (order_id) filter (WHERE action = 'deliver_order') as delivered_orders,
                             min (time) as first_date,
                             (SELECT max(time)
                       FROM   courier_actions) as last_date
                      FROM   courier_actions
                      GROUP BY courier_id) t
WHERE  date_part ('day', last_date - first_date) >= 10
ORDER BY days_employed desc, courier_id;

--10.17
--На основе информации в таблицах orders и products рассчитайте стоимость каждого заказа, ежедневную выручку сервиса и долю стоимости каждого заказа в ежедневной выручке, выраженную в процентах.
--В результат включите следующие колонки: id заказа, время создания заказа, стоимость заказа, выручку за день, в который был совершён заказ, а также долю стоимости заказа в выручке за день, выраженную в процентах.
--При расчёте долей округляйте их до трёх знаков после запятой.
--Результат отсортируйте сначала по убыванию даты совершения заказа (именно даты, а не времени), потом по убыванию доли заказа в выручке за день, затем по возрастанию id заказа.
--При проведении расчётов отменённые заказы не учитывайте.

SELECT order_id,
       creation_time,
       order_price,
       sum(order_price) OVER(PARTITION BY date(creation_time)) as daily_revenue,
       round(100 * order_price::decimal / sum(order_price) OVER(PARTITION BY date(creation_time)),
             3) as percentage_of_daily_revenue
FROM   (SELECT order_id,
               creation_time,
               sum(price) as order_price
        FROM   (SELECT order_id,
                       creation_time,
                       product_ids,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t3
            LEFT JOIN products using(product_id)
        GROUP BY order_id, creation_time) t
ORDER BY date(creation_time) desc, percentage_of_daily_revenue desc, order_id

--10.18
--На основе информации в таблицах orders и products рассчитайте ежедневную выручку сервиса и отразите её в колонке daily_revenue.
--Затем с помощью оконных функций и функций смещения посчитайте ежедневный прирост выручки.
--Прирост выручки отразите как в абсолютных значениях, так и в % относительно предыдущего дня.
--Колонку с абсолютным приростом назовите revenue_growth_abs, а колонку с относительным — revenue_growth_percentage.
--Для самого первого дня укажите прирост равным 0 в обеих колонках. При проведении расчётов отменённые заказы не учитывайте.
--Результат отсортируйте по колонке с датами по возрастанию.
--Метрики daily_revenue, revenue_growth_abs, revenue_growth_percentage округлите до одного знака при помощи ROUND().

SELECT date,
       sum (price) as daily_revenue,
       coalesce (round (sum (price) - lag (sum (price), 1) OVER (ORDER BY date), 1), 0) as revenue_growth_abs,
       coalesce (round (100*sum (price)::decimal / lag (sum (price), 1) OVER (ORDER BY date) - 100, 1), 0) as revenue_growth_percentage
FROM   (SELECT order_id,
               creation_time::date as date,
               unnest(product_ids) as product_id
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) t1
    LEFT JOIN products using(product_id)
GROUP BY date
ORDER BY date;

--10.19
--С помощью оконной функции рассчитайте медианную стоимость всех заказов из таблицы orders, оформленных в нашем сервисе.
--В качестве результата выведите одно число.
--Колонку с ним назовите median_price. Отменённые заказы не учитывайте.
--Запрос должен учитывать два возможных сценария: для чётного и нечётного числа заказов. Встроенные функции для расчёта квантилей применять нельзя.

WITH 
main_table AS (SELECT order_id, SUM (price) AS order_price, ROW_NUMBER () OVER (ORDER BY SUM (price)) AS row_number
               FROM (SELECT order_id, unnest(product_ids) as product_id
                     FROM orders
                     WHERE  order_id not in (SELECT order_id
                                             FROM   user_actions
                                             WHERE  action = 'cancel_order')) t1
               LEFT JOIN products using (product_id)
               GROUP BY order_id
),
first_50 AS (SELECT order_price, row_number
             FROM main_table
             LIMIT (SELECT MAX(row_number)/2
                    FROM main_table)
),
last_50 AS (SELECT order_price, row_number
            FROM main_table
            OFFSET (SELECT MAX(row_number)/2
                    FROM main_table)
)

SELECT CASE
       WHEN MOD(MAX (row_number), 2) = 0 THEN ((SELECT MAX(order_price) FROM first_50) + (SELECT MIN(order_price) FROM last_50))/2
       ELSE (SELECT MAX(order_price) FROM main_table WHERE row_number = (SELECT MAX (row_number)/2+1 FROM main_table))
       END AS median_price
FROM main_table;