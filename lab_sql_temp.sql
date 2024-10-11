USE sakila;

# 1. First, create a view that summarizes rental information for each customer.
# The view should include the customer's ID, name, email address,
# and total number of rentals (rental_count).
DROP VIEW IF EXISTS rental_information;
CREATE VIEW rental_information AS
	SELECT customer_id, first_name, last_name, email, COUNT(rental_id) AS rental_count
    FROM customer
    JOIN rental
    USING (customer_id)
    GROUP BY customer_id;

SELECT * FROM sakila.rental_information;

# 2. Create a Temporary Table
# Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
# The Temporary Table should use the rental summary view created in Step 1 to join
# with the payment table and calculate the total amount paid by each customer.
DROP TABLE IF EXISTS total_paid;
CREATE TEMPORARY TABLE total_paid AS
	SELECT customer_id, first_name, last_name, email, rental_count, SUM(amount) AS paid
    FROM sakila.rental_information
    JOIN payment
    USING (customer_id)
    GROUP BY customer_id, first_name, last_name, email,  rental_count;

SELECT * FROM total_paid;

# 3. Create a CTE that joins the rental summary View with the customer payment summary Temporary Table
# created in Step 2.
# The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH overview AS (
    SELECT ri.first_name, ri.last_name, ri.email, ri.rental_count, total_paid.paid
    FROM rental_information AS ri
    JOIN total_paid
    USING (customer_id)
)

# 4. Using the CTE, create the query to generate the final customer summary report,
# which should include: customer name, email, rental_count, total_paid and average_payment_per_rental,
# this last column is a derived column from total_paid and rental_count.
SELECT first_name, last_name, email, rental_count, paid, (paid/rental_count) AS average_payment_per_rental
FROM overview;
