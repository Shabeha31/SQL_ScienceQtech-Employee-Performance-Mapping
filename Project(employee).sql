/* 1.	Create a database named employee, then import data_science_team.csv proj_table.csv 
and emp_record_table.csv into the employee database from the given resources.*/
Create database employee;
use employee;
show tables;

/* 2.	Create an ER diagram for the given employee database.

3.	Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT 
from the employee record table, and make a list of employees and details of their department.*/
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
from emp_record_table
order by EMP_ID, DEPT;

/* 4.	Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is: 
4.1 less than two
4.2 greater than four 
4.3 between two and four */
-- 4.1:
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
from emp_record_table
where EMP_RATING < 2;
-- 4.2:
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
from emp_record_table
where EMP_RATING >4;
-- 4.3:
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
from emp_record_table
where EMP_RATING between 2 and 4;

/* 5.	Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department
 from the employee table and then give the resultant column alias as NAME.*/
select EMP_ID, concat(FIRST_NAME, ' ', LAST_NAME) as NAME , DEPT
from emp_record_table
where DEPT= "FINANCE";

/* 6.	Write a query to list only those employees who have someone reporting to them. Also, show the number of reporters (including the President).*/
select m.EMP_ID, m.FIRST_NAME, m.LAST_NAME, m.DEPT, m.ROLE, m.EMP_RATING, 
count(e.EMP_ID) as 'Reporters_number'
from emp_record_table m
join 
emp_record_table e 
on
 e.MANAGER_ID = m.EMP_ID 
group by m.EMP_ID, m.FIRST_NAME, m.LAST_NAME, m.ROLE, m.DEPT, m.EMP_RATING
order by Reporters_number DESC;
 
 /* 7.	Write a query to list down all the employees from the healthcare and finance departments using union.
 Take data from the employee record table.*/
 select EMP_ID, FIRST_NAME,LAST_NAME,DEPT
 from emp_record_table 
 where DEPT="healthcare"
 union
 select EMP_ID, FIRST_NAME, LAST_NAME, DEPT
 from emp_record_table 
 where DEPT="Finance";
 
 /* 8.	Write a query to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept.
 Also include the respective employee rating along with the max emp rating for the department.*/
 select  EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, EMP_RATING ,
 max(EMP_RATING) over (partition by DEPT) AS Maximum_rating
 FROM emp_record_table
 order by DEPT, Maximum_rating;
 
 /* 9.	Write a query to calculate the minimum and the maximum salary of the employees in each role. Take data from the employee record table.*/
 select  EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT,SALARY,
 MIN(SALARY) over (partition by ROLE) AS Minimum_salary,
 MAX(SALARY) over (partition by ROLE) AS Maximum_salary
 from emp_record_table
 order by ROLE, SALARY;
 
 /* 10.	Write a query to assign ranks to each employee based on their experience. Take data from the employee record table.*/
 select  EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT,EXP,
 dense_rank() over (order by EXP desc) AS emp_ranking
 from emp_record_table;
 
 /* 11.	Write a query to create a view that displays employees in various countries whose salary is more than six thousand.
 Take data from the employee record table.*/
 create view employee_view as 
 select  EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT,EXP,SALARY
 from emp_record_table
 where SALARY>6000;
 select * from employee_view;
 
 /* 12.	Write a nested query to find employees with experience of more than ten years. 
 Take data from the employee record table.*/
 select EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT,EXP 
 from emp_record_table
 where EXP> (
 select 10
 ) ;
 
 /* 13.	Write a query to create a stored procedure to retrieve the details of the employees
 whose experience is more than three years. Take data from the employee record table.*/
DELIMITER $$

CREATE PROCEDURE Get_exp()
BEGIN
    SELECT * 
    FROM emp_record_table
    WHERE EXP > 5;
END$$

DELIMITER ;
 call Get_exp();

 /* 14. Write a query using stored functions in the project table to check
 whether the job profile assigned to each employee in the data science team matches the organization’s set standard. 
 
 The standard being: For an employee with experience less than or equal to 2 years assign 'JUNIOR DATA SCIENTIST',
 For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA SCIENTIST', 
 For an employee with the experience of 5 to 10 years assign 'SENIOR DATA SCIENTIST',
 For an employee with the experience of 10 to 12 years assign 'LEAD DATA SCIENTIST',
 For an employee with the experience of 12 to 16 years assign 'MANAGER'.*/
 
 DELIMITER $$
 create function Get_job_profile(emp_exp int)
 returns varchar (50)
 deterministic
 begin 
	DECLARE Job_title varchar(50);
    
    IF emp_exp<=2 then 
		set job_title = 'JUNIOR DATA SCIENTIST';
    elseif emp_exp >2 and emp_exp<=5 then 
		set job_title = 'ASSOCIATE DATA SCIENTIST';
	elseif emp_exp >5 and emp_exp<=10 then 
		set job_title = 'SENIOR DATA SCIENTIST';
	elseif emp_exp > 10 AND emp_exp <= 12 THEN
        set job_title = 'LEAD DATA SCIENTIST';
    elseif emp_exp > 12 AND emp_exp <= 16 THEN
        set job_title = 'MANAGER';
    else
        set job_title = 'EXPERIENCE OUT OF RANGE';
    END IF;
    return job_title;
END$$
DELIMITER ;
select EMP_ID,FIRST_NAME,LAST_NAME,GENDER,ROLE AS assigned_role, EXP,
Get_job_profile(EXP) as Expected_role,
Case 
	when ROLE = Get_job_profile(EXP) then 'MATCHED'
    else 'Not matched'
    END AS Role_Status
FROM data_science_team;
    
/* 15.	Create an index to improve the cost and performance of the query to find the employee 
whose FIRST_NAME is ‘Eric’ in the employee table after checking the execution plan. 
*/
select * from emp_record_table
where FIRST_NAME= 'Eric';

create INDEX indx_firstname 
ON emp_record_table(FIRST_NAME(4));

EXPLAIN
select * from emp_record_table
where FIRST_NAME= 'Eric';

/* 16.	Write a query to calculate the bonus for all the employees, based on their ratings and salaries 
(Use the formula: 5% of salary * employee rating).*/
select EMP_ID, FIRST_NAME, LAST_NAME, ROLE, SALARY, EMP_RATING,
(0.05 * SALARY * EMP_RATING) as Bonus
from emp_record_table;

/* 17.	Write a query to calculate the average salary distribution based on the continent and country.
Take data from the employee record table.*/
select EMP_ID, FIRST_NAME,LAST_NAME,SALARY,CONTINENT,COUNTRY,
avg(SALARY) over (partition by CONTINENT , COUNTRY) average_emp_salary
from emp_record_table;



 
 
 
 