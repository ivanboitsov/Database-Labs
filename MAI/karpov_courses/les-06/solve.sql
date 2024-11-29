-- Task 1

-- Посчитайте количество курьеров мужского и женского пола в таблице couriers

SELECT sex, COUNT(DISTINCT courier_id) as couriers_count
FROM couriers
GROUP BY sex 

-- Task 2

-- Посчитайте количество созданных и отменённых заказов в таблице user_actions

SELECT action, COUNT(user_id) as orders_count
FROM user_actions
GROUP BY action 

-- Task 3

-- Используя группировку и функцию DATE_TRUNC, приведите все даты к началу месяца и посчитайте, сколько заказов было сделано в каждом из них.

SELECT DATE_TRUNC('month', creation_time) as month, COUNT(order_id) as orders_count
FROM orders
GROUP BY month
ORDER BY month asc

-- Task 4

-- Используя группировку и функцию DATE_TRUNC, приведите все даты к началу месяца и посчитайте, сколько заказов было сделано и сколько было отменено в каждом из них.

SELECT DATE_TRUNC('month', time) as month, action, COUNT(order_id) as orders_count
FROM user_actions
GROUP BY month, action
ORDER BY month, action

-- Task 5

-- По данным в таблице users посчитайте максимальный порядковый номер месяца среди всех порядковых номеров месяцев рождения 
-- пользователей сервиса. С помощью группировки проведите расчёты отдельно в двух группах — для пользователей мужского и женского пола.

SELECT 
    sex, 
    MAX(DATE_PART('month', birth_date))::integer as max_month
FROM users 
GROUP BY sex

-- Task 6

-- По данным в таблице users посчитайте порядковый номер месяца рождения самого молодого пользователя сервиса. 
-- С помощью группировки проведите расчёты отдельно в двух группах — для пользователей мужского и женского пола.

SELECT 
    sex, 
    DATE_PART('month', max(birth_date))::integer as max_month
FROM users 
GROUP BY sex

-- Task 7

-- Посчитайте максимальный возраст пользователей мужского и женского пола в таблице users. Возраст измерьте числом полных лет.

SELECT 
    sex, 
    MAX(DATE_PART('year', age(current_date, birth_date)))::integer as max_age
FROM users 
GROUP BY sex

-- Task 8

-- Разбейте пользователей из таблицы users на группы по возрасту и посчитайте количество пользователей каждого возраста.

SELECT 
    date_part('year', age(current_date, birth_date))::integer as age,
    count(user_id) as users_count
FROM users 
GROUP BY age
order by age

-- Task 9

-- Вновь разбейте пользователей из таблицы users на группы по возрасту, только теперь добавьте в группировку ещё и пол пользователя. 
-- Затем посчитайте количество пользователей в каждой половозрастной группе.

SELECT 
    date_part('year', age(current_date, birth_date))::integer as age,
    sex,
    count(user_id) as users_count
FROM users 
where birth_date is not null
GROUP BY age, sex
order by age, sex

-- Task 10

-- Посчитайте количество товаров в каждом заказе, примените к этим значениям группировку и рассчитайте количество заказов 
-- в каждой группе за неделю с 29 августа по 4 сентября 2022 года включительно. Для расчётов используйте данные из таблицы orders.

SELECT 
    array_length(product_ids, 1) as order_size,
    count(order_id) as orders_count
FROM orders 
where creation_time >= '2022-08-29' and creation_time < '2022-09-05'
GROUP BY order_size
ORDER BY order_size

-- Task 11

-- Посчитайте количество товаров в каждом заказе, примените к этим значениям группировку и рассчитайте количество заказов в каждой группе. 
-- Учитывайте только заказы, оформленные по будням. В результат включите только те размеры заказов, общее число которых превышает 2000. 
-- Для расчётов используйте данные из таблицы orders.

SELECT 
    array_length(product_ids, 1) as order_size,
    count(order_id) as orders_count
FROM orders 
WHERE DATE_PART('dow', creation_time) in (1, 2, 3, 4, 5)
GROUP BY order_size
HAVING count(order_id) > 2000
ORDER BY order_size

-- Task 12

-- По данным из таблицы user_actions определите пять пользователей, сделавших в августе 2022 года наибольшее количество заказов.

SELECT 
    user_id,
    count(distinct order_id) as created_orders
FROM user_actions 
WHERE 
    action = 'create_order' AND
    date_part('month', time) = 8 AND
    date_part('year', time) = 2022
GROUP BY user_id
ORDER BY created_orders desc, user_id limit 5

-- Task 13

-- А теперь по данным таблицы courier_actions определите курьеров, которые в сентябре 2022 года доставили только по одному заказу.

SELECT 
    courier_id
FROM courier_actions
WHERE 
    action = 'deliver_order' and
    date_part('month', time) = 9 and
    date_part('year', time) = 2022
GROUP BY courier_id having count(action) = 1
ORDER BY courier_id

-- Task 14

-- Из таблицы user_actions отберите пользователей, у которых последний заказ был создан до 8 сентября 2022 года.

SELECT user_id 
FROM user_actions
WHERE
    action = 'create_order'
GROUP BY user_id having max(time) < '2022-09-08'
ORDER BY user_id

-- Task 15

-- Разбейте заказы из таблицы orders на 3 группы в зависимости от количества товаров, попавших в заказ:
-- Малый (от 1 до 3 товаров);
-- Средний (от 4 до 6 товаров);
-- Большой (7 и более товаров).
-- Посчитайте число заказов, попавших в каждую группу. Группы назовите соответственно «Малый», «Средний», «Большой» (без кавычек).

SELECT 
    case
    when array_length(product_ids, 1) > 3 and array_length(product_ids, 1) < 7 then 'Средний'
    when array_length(product_ids, 1) >= 7 then 'Большой'
    else 'Малый' end as order_size,
    count(order_id) as orders_count
FROM orders
GROUP BY order_size
ORDER BY orders_count

-- Task 16

-- Разбейте пользователей из таблицы users на 4 возрастные группы:
-- от 18 до 24 лет;
-- от 25 до 29 лет;
-- от 30 до 35 лет;
-- старше 36.
-- Посчитайте число пользователей, попавших в каждую возрастную группу. Группы назовите соответственно «18-24», «25-29», «30-35», «36+» (без кавычек).
-- В расчётах не учитывайте пользователей, у которых не указана дата рождения. Как и в прошлых задачах, в качестве возраста учитывайте число полных лет.

SELECT 
    case
    when date_part('year', age(birth_date))::integer > 17 and date_part('year', age(birth_date))::integer < 25 then '18-24'
    when date_part('year', age(birth_date))::integer > 24 and date_part('year', age(birth_date))::integer < 30 then '25-29'
    when date_part('year', age(birth_date))::integer > 29 and date_part('year', age(birth_date))::integer < 36 then '30-35'
    else '36+'
    end as group_age,
    count(user_id) as users_count
FROM users 
WHERE birth_date is not null
GROUP BY group_age
ORDER BY group_age

-- Task 17

-- По данным из таблицы orders рассчитайте средний размер заказа по выходным и будням.


SELECT 
    case
    when date_part('dow', creation_time) in (2, 3, 4, 5 ,6) then 'weekdays'
    else 'weekend'
    end as week_part,
    round(avg(ARRAY_LENGTH(product_ids, 1)), 2) as avg_order_size
FROM orders
GROUP BY week_part
ORDER BY avg_order_size

-- Task 18

-- Для каждого пользователя в таблице user_actions посчитайте общее количество оформленных заказов и долю отменённых заказов.

SELECT
    user_id,
    round(count(DISTINCT order_id) filter 
    (where action = 'cancel_order')::decimal / count(DISTINCT order_id), 2) as cancel_rate,
    count(DISTINCT order_id) as orders_count
FROM user_actions 
GROUP BY user_id having round(count(DISTINCT order_id) filter
    (where action = 'cancel_order')::decimal/count(DISTINCT order_id), 2) >= 0.5 and
    count(DISTINCT order_id) > 3
ORDER BY user_id

-- Task 19

-- Для каждого дня недели в таблице user_actions посчитайте:
-- Общее количество оформленных заказов.
-- Общее количество отменённых заказов.
--Общее количество неотменённых заказов (т.е. доставленных).
-- Долю неотменённых заказов в общем числе заказов (success rate).
-- Новые колонки назовите соответственно created_orders, canceled_orders, actual_orders и success_rate. Колонку с долей неотменённых заказов округлите до трёх знаков после запятой.
--Все расчёты проводите за период с 24 августа по 6 сентября 2022 года включительно, чтобы во временной интервал попало равное количество разных дней недели

SELECT
    date_part('isodow', time)::int as weekday_number,
    to_char(time, 'Dy') as weekday,
    count(order_id) FILTER(WHERE action = 'create_order') as created_orders,
    count(order_id) FILTER(WHERE action = 'cancel_order') as canceled_orders,
    count(order_id) FILTER(WHERE action = 'create_order') - count(order_id) FILTER(WHERE action = 'cancel_order') as actual_orders,
    round((count(order_id) FILTER(WHERE action = 'create_order') - count(order_id) FILTER(WHERE action = 'cancel_order'))::decimal / 
    (count(order_id) FILTER(WHERE action = 'create_order'))::decimal, 3) as success_rate
FROM user_actions
WHERE time >= '2022-08-24' and time < '2022-09-07'
GROUP BY weekday_number, weekday
ORDER BY weekday_number