-- Task 1

SELECT sex, COUNT(DISTINCT courier_id) as couriers_count
FROM couriers
GROUP BY sex 

-- Task 2

SELECT action, COUNT(user_id) as orders_count
FROM user_actions
GROUP BY action 

-- Task 3

SELECT DATE_TRUNC('month', creation_time) as month, COUNT(order_id) as orders_count
FROM orders
GROUP BY month
ORDER BY month asc

-- Task 4

SELECT DATE_TRUNC('month', time) as month, action, COUNT(order_id) as orders_count
FROM user_actions
GROUP BY month, action
ORDER BY month, action

-- Task 5

SELECT 
    sex, 
    MAX(DATE_PART('month', birth_date))::integer as max_month
FROM users 
GROUP BY sex

-- Task 6

SELECT 
    sex, 
    DATE_PART('month', max(birth_date))::integer as max_month
FROM users 
GROUP BY sex

-- Task 7

SELECT 
    sex, 
    MAX(DATE_PART('year', age(current_date, birth_date)))::integer as max_age
FROM users 
GROUP BY sex

-- Task 8

SELECT 
    date_part('year', age(current_date, birth_date))::integer as age,
    count(user_id) as users_count
FROM users 
GROUP BY age
order by age

-- Task 9

SELECT 
    date_part('year', age(current_date, birth_date))::integer as age,
    sex,
    count(user_id) as users_count
FROM users 
where birth_date is not null
GROUP BY age, sex
order by age, sex

-- Task 10

SELECT 
    array_length(product_ids, 1) as order_size,
    count(order_id) as orders_count
FROM orders 
where creation_time >= '2022-08-29' and creation_time < '2022-09-05'
GROUP BY order_size
ORDER BY order_size

-- Task 11

SELECT 
    array_length(product_ids, 1) as order_size,
    count(order_id) as orders_count
FROM orders 
WHERE DATE_PART('dow', creation_time) in (1, 2, 3, 4, 5)
GROUP BY order_size
HAVING count(order_id) > 2000
ORDER BY order_size

-- Task 12

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

SELECT user_id 
FROM user_actions
WHERE
    action = 'create_order'
GROUP BY user_id having max(time) < '2022-09-08'
ORDER BY user_id

-- Task 15

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