/*
QUESTION 1:
Level: Simple
Topic: DISTINCT
Task: Create a list of all the different (distinct) replacement costs of the films.
Question: What's the lowest replacement cost?
Answer: 9.99
*/
-- List:
SELECT DISTINCT replacement_cost FROM film;

-- Answer:
SELECT DISTINCT MIN(replacement_cost) FROM film;

-- SITUATION : CORRECT
--------------------------------------------------------------------------------------------
/*
QUESTION 2:
Level: Moderate
Topic: CASE + GROUP BY
Task: Write a query that gives an overview of how many films have replacements costs in the following cost ranges
low: 9.99 - 19.99
medium: 20.00 - 24.99
high: 25.00 - 29.99
Question: How many films have a replacement cost in the "low" group?
Answer: 514
*/
-- Solution 1:
SELECT COUNT(*)
FROM film
WHERE
CASE 
	WHEN replacement_cost > 24.99 THEN 'high' 
	WHEN replacement_cost > 19.99 THEN 'medium'
	WHEN replacement_cost >= 9.99 THEN 'low'
END = 'low';

-- Solution 2:
SELECT COUNT(*),
CASE 
	WHEN replacement_cost > 24.99 THEN 'high' 
	WHEN replacement_cost > 19.99 THEN 'medium'
	--WHEN replacement_cost >= 9.99 THEN 'low'
	ELSE 'low'
END AS category
FROM film
GROUP BY (category);

-- Solution 3:
SELECT COUNT(*)
FROM (
	SELECT title,	
	CASE 
		WHEN replacement_cost > 24.99 THEN 'high' 
		WHEN replacement_cost > 19.99 THEN 'medium'
		ELSE 'low'
	END AS category
	FROM film) t
WHERE t.category = 'low';
--------------------------------------------------------------------------------------------
/*
QUESTION 3:
Level: Moderate
Topic: JOIN
Task: Create a list of the film titles including their title, length, and category name ordered descendingly by length. Filter the results to only the movies in the category 'Drama' or 'Sports'.
Question: In which category is the longest film and how long is it?
Answer: Sports and 184
*/

-- category (category_id, name) -->  film_category(category_id,film_id) --> film(film_id)
SELECT * FROM film;
SELECT * FROM film_category;
SELECT * FROM category;
SELECT DISTINCT name FROM category;

-- List:
SELECT title, length, name
FROM film fi
INNER JOIN film_category fc
ON fi.film_id = fc.film_id
INNER JOIN category ca
ON fc.category_id = ca.category_id
WHERE name = 'Drama' OR name = 'Sports' 
ORDER BY length DESC;

-- Answer:
SELECT title, name, MAX(length)
FROM film fi
INNER JOIN film_category fc
ON fi.film_id = fc.film_id
INNER JOIN category ca
ON fc.category_id = ca.category_id
WHERE name = 'Drama' OR name = 'Sports'
GROUP BY title, name, length
ORDER BY length DESC
LIMIT 1;
--------------------------------------------------------------------------------------------
/*
QUESTION 4:
Level: Moderate
Task: Create an overview of how many movies (titles) there are in each category (name).
Question: Which category (name) is the most common among the films?
Answer: Sports with 74 titles
*/
SELECT name, COUNT(*)
FROM film fi
INNER JOIN film_category fc
ON fi.film_id = fc.film_id
INNER JOIN category ca
ON fc.category_id = ca.category_id
GROUP BY name
ORDER BY COUNT(*) DESC
LIMIT 1;
--------------------------------------------------------------------------------------------
/*
QUESTION 5:
Level: Moderate
Task: Create an overview of the actors' first and last names and in how many movies they appear in.
Question: Which actor is part of most movies??
Answer: Susan Davis with 54 movies
*/
-- actor(actor_id)  -- film_actor(film_id, actor_id)
SELECT * FROM actor;
SELECT * FROM film_actor;

SELECT first_name, last_name, COUNT(*) as numb_of_movie
FROM actor ac
INNER JOIN film_actor fa
ON fa.actor_id = ac.actor_id
GROUP BY first_name, last_name
ORDER BY numb_of_movie DESC
LIMIT 1;
--------------------------------------------------------------------------------------------
/*
QUESTION 6:
Level: Moderate
Task: Create an overview of the addresses that are not associated to any customer.
Question: How many addresses are that?
Answer: 4
*/
SELECT * FROM address;
SELECT * FROM customer;

SELECT * FROM address ad
LEFT JOIN customer cu
ON ad.address_id = cu.address_id
WHERE customer_id IS NULL;
--------------------------------------------------------------------------------------------
/*
QUESTION 7:
Level: Moderate
Task: Create the overview of the sales  to determine the from which city (we are interested in the city in which the customer lives, not where the store is) most sales occur.
Question: What city is that and how much is the amount?
Answer: Cape Coral with a total amount of 221.55
*/
SELECT * FROM payment;

-- payment(customer_id, amount) --> customer(address_id, customer_id) --> address(city_id,address_id) --> city(city_id) 
SELECT city, SUM(amount) AS total_of_sales
FROM payment pa
INNER JOIN customer cu
ON pa.customer_id = cu.customer_id
INNER JOIN address ad
ON ad.address_id = cu.address_id
INNER JOIN city ci
ON ci.city_id = ad.city_id
GROUP BY city
ORDER BY total_of_sales DESC
LIMIT 1;
--------------------------------------------------------------------------------------------
/*
QUESTION 8:
Level: Moderate to difficult
Task: Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".
Question: Which country, city has the least sales?
Answer: United States, Tallahassee with a total amount of 50.85.
*/

-- payment(customer_id, amount) --> customer(customer_id ,address_id) --> address(address_id, city_id) --> city(city_id, country_id) --> country(country_id)
SELECT SUM(amount) as total_amount, country || ', ' || city as city_country  
FROM payment pa
INNER JOIN customer cu
ON pa.customer_id = cu.customer_id
INNER JOIN address ad
ON ad.address_id = cu.address_id
INNER JOIN city ci
ON ci.city_id = ad.city_id
INNER JOIN country co
ON co.country_id = ci.country_id
GROUP BY country, city 
ORDER BY total_amount ASC;
--------------------------------------------------------------------------------------------
/*
QUESTION 9:
Topic: Uncorrelated subquery
Level: Difficult
Task: Create a list with the average of the sales amount each staff_id has per customer.
Question: Which staff_id makes on average more revenue per customer?
Answer: staff_id 2 with an average revenue of 56.64 per customer.
*/
-- 1st Way:
SELECT staff_id, AVG(total) 
FROM( 
	SELECT 
	staff_id,
	customer_id,
	SUM(amount) as total
	FROM payment
	GROUP BY staff_id, customer_id)
GROUP BY staff_id;	

-- 2nd Way:
SELECT staff_id, 
COUNT(DISTINCT customer_id) as numb_of_customer,
SUM(amount) as amount,
ROUND(SUM(amount) / COUNT(DISTINCT customer_id), 2) as ratio
FROM payment 
GROUP BY staff_id;

--------------------------------------------------------------------------------------------
/*
QUESTION 10:
Topic: EXTRACT + Uncorrelated subquery
Level: Difficult to very difficult
Task: Create a query that shows average daily revenue of all Sundays.
Question: What is the daily average revenue of all Sundays?
Answer: 1410.65
*/
SELECT * FROM payment;

SELECT ROUND(AVG(amount),2) 
FROM (
	SELECT SUM(amount) as amount,
	DATE(payment_date),
	EXTRACT(DOW FROM payment_date)
	FROM payment
	WHERE EXTRACT(DOW FROM payment_date) = 0
	GROUP BY DATE(payment_date), EXTRACT(DOW FROM payment_date));
