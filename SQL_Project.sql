
--Q1:  We want to run an Email Campaigns for customers of Store 2 (First, Last name, and Email address of customers from Store 2)	
Select first_name, last_name, email from customer where store_id = 2;

--Q2:  List of the movies with a rental rate of 0.99$
select film_id, title, description reantal_rate from film where rental_rate = 0.99;

--Q3: Your objective is to show the rental rate and how many movies are in each rental rate categories

select rental_rate, count(film_id) movieCount from film group by rental_rate;
 
--Q4: Which rating do we have the most films in?

select rating, max(t.movieCount) maxCount from (select rating, count(*) movieCount from film group by rating) t;
 

--Q5: Which rating is most prevalent in each store?

select sq.* from (select store_id, rating, count(f.film_id) as movieCount, rank() over (partition by store_id order by count(f.film_id) desc) as Row_Rank from film f join inventory i on f.film_id=i.film_id group by store_id, rating ) sq; --(to get all the ratings)

select sq.* from (select store_id, rating, count(f.film_id) as movieCount, rank() over (partition by store_id order by count(f.film_id) desc) as Row_Rank from film f join inventory i on f.film_id=i.film_id group by store_id, rating ) sq having sq.Row_Rank = 1; --(only the highest)

 
--Q6. We want to mail the customers about the upcoming promotion

select customer_id, first_name, last_name, email from customer where active = TRUE;


--Q7. List of films by Film Name, Category, Language
select f.film_id, title, c.name, l.name from film f left join film_category fc on f.film_id = fc.film_id left join category c on fc.category_id = c.category_id left join language l on f.language_id  = l.language_id limit 10;
 

--Q8. How many times each movie has been rented out?

select f.film_id, f.title, count(rental_id) rentedCount from film f left join inventory i on f.film_id = i.film_id left join rental r on i.inventory_id = r.inventory_id group by f.film_id, f.title order by 3 desc limit 10;
 

--Q9. What is the Revenue per Movie?

select f.film_id, f.title, sum(p.amount) Revenue from film f left join inventory i on f.film_id = i.film_id left join rental r on i.inventory_id = r.inventory_id left join payment p on r.rental_id = p.rental_id group by f.film_id, f.title order by 3 desc limit 10;
 

--Q10: Most Spending Customer so that we can send him/her rewards or debate points
select sq.* from (select c.customer_id, c.first_name, c.last_name, c.email, SUM(p.amount) cutomerSpent, RANK() OVER (ORDER BY SUM(p.amount) desc) AS RowRank FROM customer c left join payment p on c.customer_id = p.customer_id group by c.customer_id, c.first_name, c.last_name, c.email order by 5 desc) sq having sq.RowRank = 1;

 --Q11.  What Store has historically brought the most revenue?
 
select s.store_id, sum(p.amount) StoreRevenue from store s left join inventory i on s.store_id = i.store_id left join rental r on i.inventory_id = r.inventory_id left join payment p on r.rental_id = p.rental_id group by s.store_id;

 
--Q12: .How many rentals do we have for each month?

select count(rental_id) RentalCount, Month(rental_date) Month, year(rental_date) Year from rental group by Month(rental_date), year(rental_date);
 

--Q13: Rentals per Month (such Jan => How much, etc)

select count(rental_id) RentalCount, MonthName(rental_date) Month, year(rental_date) Year from rental group by Month(rental_date), year(rental_date);
 

--Q14 & 15: 
--14.Which date the first movie was rented out?
--15.Which date the last movie was rented out?
select min(date(rental_date)) firstRentalDate, max(date(rental_date)) lastRentalDate from rental;
 

--Q16: For each movie, when was the first time and last time it was rented out?

select f.film_id, f.title, max(r.rental_date) lastRentalDate, min(r.rental_date) firstRentalDate from film f left join inventory i on f.film_id = i.film_id left join rental r on i.inventory_id = r.inventory_id group by f.film_id, f.title limit 10;
 
--Q17: What is the Last Rental Date of every customer?
select c.customer_id, c.first_name, min(rental_date) firstRentalDate, max(rental_date) lastRentalDate from customer c left join rental r on r.customer_id = c.customer_id group by c.customer_id, c.first_name limit 10;
 

--Q18: .What is our Revenue Per Month?
select monthname(rental_date), sum(amount) RevenuePerMonth from rental r left join payment p on r.rental_id = p.rental_id group by monthname(rental_date);
 

--Q19: How many distinct Renters do we have per month?

select MONTHNAme(rental_date) RentalMonth, year(rental_date) RentYear, count(distinct customer_Id) from rental group by monthName(rental_date), year(rental_date);
 

--Q20: Show the Number of Distinct Film Rented Each Month

select monthname(rental_date) RentalMonth, year(rental_date) RentalYear, count(distinct f.film_id) DistinctFilmsRented from rental r left join inventory i on r.inventory_id = i.inventory_id left join film f on i.film_id = f.film_id group by monthname(rental_date), year(rental_date) order by 2 desc;
 

--Q21: Number of Rentals in Comedy, Sports, and Family
select count(distinct rental_id) NumRentals, c.name from rental r left join inventory i on r.inventory_id = i.inventory_id left join film f on i.film_id = f.film_id left join film_category fc on f.film_id = fc.film_id left join category c on fc.category_id = c.category_id group by c.name order by 1 desc;

select count(distinct rental_id) NumRentals, c.name from rental r left join inventory i on r.inventory_id = i.inventory_id left join film f on i.film_id = f.film_id left join film_category fc on f.film_id = fc.film_id left join category c on fc.category_id = c.category_id where c.name in ('Sports','Comedy','Family') group by c.name order by 2 desc; 

 
--Q22: Users who have been rented at least 3 times

select r.customer_id, c.first_name, c.last_name, count(r.rental_id) NumOfRentals from rental r left join customer c on r.customer_id = c.customer_id group by r.customer_id,  c.first_name, c.last_name having count(r.rental_id)>=3;
 

--Q23: How much revenue has one single store made over PG13 and R-rated films?

select  s.store_id,f.rating,sum(amount) from store s left join inventory i on s.store_id = i.store_id left join film f on i.film_id = f.film_id left join rental r on i.inventory_id = r.inventory_id left join payment p on r.rental_id = p.rental_id group by s.store_id, f.rating;

select  s.store_id,f.rating,sum(amount) from store s left join inventory i on s.store_id = i.store_id left join film f on i.film_id = f.film_id left join rental r on i.inventory_id = r.inventory_id left join payment p on r.rental_id = p.rental_id where rating in ('PG-13','R') group by s.store_id, f.rating;

 
 --Q24: Active User where active = 1

select * from customer where active = 1;
 

--Q25: Reward Users: who has rented at least 30 times

select r.customer_id, c.first_name, c.last_name, c.email, count(r.rental_id) NumOfRentals from rental r left join customer c on r.customer_id = c.customer_id group by r.customer_id,  c.first_name, c.last_name, c.email having count(r.rental_id)>=30;

 

--Q26: Reward Users who are also active

select r.customer_id, c.first_name, c.last_name, c.email, count(r.rental_id) NumOfRentals from rental r left join customer c on r.customer_id = c.customer_id where c.active = 1 group by r.customer_id,  c.first_name, c.last_name, c.email having count(r.rental_id)>=30;
 

--Q27: All Rewards Users with Phone

select r.customer_id, c.first_name, c.last_name, c.email, a.phone, count(r.rental_id) NumOfRentals from rental r left join customer c on r.customer_id = c.customer_id left join address a on c.address_id = a.address_id where c.active = 1 and a.phone is not NULL group by r.customer_id,  c.first_name, c.last_name, c.email having count(r.rental_id)>=30;
 





