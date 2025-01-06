use case_study;

select * from customer;
select * from bike;
select * from rental;
select * from membership_type;
select * from membership;

--  how many bikes the shop owns by category.

		select category,count(id) as "no_of_bikes" from bike  group by category having count(id)>2;
        
-- customer names with the total number of memberships purchased by each

		select name,count(m.id)as "no._of_membership"from membership m
        join customer c on m.customer_id=c.id
        group by name,m.customer_id;
        
		/* display its ID, category, old price per hour (call this column 
		old_price_per_hour ), discounted price per hour (call it new_price_per_hour ), old
		price per day (call it old_price_per_day ), and discounted price per day (call it
		new_price_per_day ).

		Electric bikes should have a 10% discount for hourly rentals and a 20%
		discount for daily rentals. Mountain bikes should have a 20% discount for
		hourly rentals and a 50% discount for daily rentals. All other bikes should
		have a 50% discount for all types of rentals.*/
        
			select id,category,price_per_hour,
					case when category = 'electric' then  price_per_hour-0.1*price_per_hour 
						when category = 'mountain bike' then price_per_hour-0.2*price_per_hour 
                        else price_per_hour-0.5*price_per_hour 
                    end as "new_price_per_hour",
                    price_per_day,
                    case when category = 'electric' then price_per_day-0.2*price_per_day
						when category = 'mountain bike' then price_per_day-0.5*price_per_day
                        else price_per_day-0.5*price_per_day 
                    end as "new_price_per_day"
			from bike;
            
-- Display the number of available bikes (call this column available_bikes_count ) and 
-- the number of rented bikes (call this column rented_bikes_count ) by bike category.

		select category,sum(case when 
						status = 'available' then 1 else 0
				end) as "available_count",
                sum(case when 
						status = 'rented' then 1 else 0
				end) as "rented_count"
		from bike
        group by category;

-- Display the total revenue from rentals for each month, the total for each
-- year, and the total across all the years. Do not take memberships into
-- account. There should be 3 columns: year , month , and revenue

		with rev as (select year(start_timestamp) as "year",
				month(start_timestamp) as 'month',
                sum(total_paid) as "revenue"
				
		from rental
        group by year(start_timestamp),
				month(start_timestamp)),
                
			total_rev as (select distinct year,month = null as "month",sum(revenue) over(partition by year)  as "month_revenue"from rev),
            
            all_over_rev as (select distinct year=null,month = null ,sum(month_revenue) over()  from total_rev)
    select * from rev
    union all 
    select * from total_rev
    union all 
    select * from all_over_rev
    order by year;
    
    
			select extract(year from start_timestamp) as year
			, extract(month from start_timestamp) as month
			, sum(total_paid) as revenue
			from rental
			group by year, month with rollup;
		
/*	Display the year, the month, the name of the membership type (call this
	column membership_type_name ), and the total revenue (call this column 
	total_revenue ) for every combination of year, month, and membership type.
	Sort the results by year, month, and name of membership type.	*/
    
			select year(start_date) as 'year',
					month(start_date) as 'month',
					name,
					sum(total_paid) as "revenue"
			from membership m1
			join membership_type  m2 on m1.membership_type_id = m2.id
			group by year(start_date),month(start_date),name
			order by year(start_date),month(start_date),name;
		
/*	Display the total revenue from memberships purchased in 2023 for each
	combination of month and membership type. Generate subtotals and
	grand totals for all possible combinations. There should be 3 columns: 
	membership_type_name , month , and total_revenue .	*/
    

			select 
					month(start_date) as 'month',
					name,
					sum(total_paid) as "revenue"
			from membership m1
			join membership_type  m2 on m1.membership_type_id = m2.id
            where year(start_date) = 2023
			group by month(start_date),name with rollup
			order by  month(start_date) desc,name desc;
            
/*	Categorize customers based on their rental history as follows:
	Customers who have had more than 10 rentals are categorized as 'more
	than 10' .
	Customers who have had 5 to 10 rentals (inclusive) are categorized as 
	'between 5 and 10' .
	Customers who have had fewer than 5 rentals should be categorized as
	'fewer than 5' .
			Calculate the number of customers in each category. Display two columns: 
			rental_count_category (the rental count category) and customer_count (the
			number of customers in each category).	*/
            
	with cust as (select customer_id,count(r.id),
			case when count(r.id)<5 then 'Fewer than 5'
				when count(r.id)>=5 and count(r.id)<=10 then '5 to 10'
                when count(r.id)>10 then 'more than 10'
			end as 'rental_count'
		from rental r 
    join bike b on r.bike_id=b.id
    group by customer_id)
    
    select rental_count,count(customer_id) from cust
    group by rental_count;
    
    
    


    
    
                
		
			


