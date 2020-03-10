/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do.
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court
*/
SELECT name FROM `Facilities` WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? 
4
*/
SELECT COUNT(*) AS count  FROM `Facilities` WHERE membercost = 0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. 
facid   name            membercost  monthlymaintenance
0       Tennis Court 1  5.0         200
1       Tennis Court 2  5.0         200
4       Massage Room 1  9.9         3000
5       Massage Room 2  9.9         3000
6       Squash Court    3.5         80
*/
SELECT facid, name, membercost, monthlymaintenance FROM `Facilities` WHERE membercost > 0 AND membercost < monthlymaintenance*0.2

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
(SELECT * FROM `Facilities` WHERE facid = 1)
UNION ALL
(SELECT * FROM `Facilities` WHERE facid = 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance, IF(monthlymaintenance > 100, "Expensive", "Cheap") AS valuation FROM `Facilities` 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT TOP 1 firstname, surname FROM `Members` ORDER BY memid DESC

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT CONCAT_WS(", ", surname, firstname) AS member, name AS facility FROM
    (SELECT * FROM
        (SELECT facid, name FROM `Facilities` WHERE name LIKE "tennis%") fac
        JOIN
        (SELECT * FROM `Bookings`) boo
    USING(facid)) facboo
    JOIN
    (SELECT * FROM `Members` WHERE firstname NOT LIKE "guest") mem
USING(memid) ORDER BY member

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT F.name as facility, CONCAT_WS(", ", M.surname, M.firstname) AS member, IF(B.memid > 0, B.slots*F.membercost, B.slots*F.guestcost) AS cost 
FROM Bookings B
JOIN Facilities F ON F.facid = B.facid
JOIN Members M ON M.memid = B.memid
WHERE B.starttime LIKE '2012-09-14%' AND IF(B.memid > 0, B.slots*F.membercost, B.slots*F.guestcost) > 30
ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT facility, CONCAT_WS(", ", surname, firstname) AS member, cost FROM
    (SELECT name AS facility, memid, IF(memid > 0, slots*membercost, slots*guestcost) AS cost FROM
        (SELECT facid, memid, slots FROM `Bookings` WHERE starttime LIKE '2012-09-14%') boo
        JOIN
        (SELECT facid, name, membercost, guestcost FROM `Facilities`) fac
    USING(facid)) facboo
    JOIN
    (SELECT memid, firstname, surname FROM `Members`) mem
USING(memid) WHERE cost > 30 ORDER BY cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT * FROM
(SELECT F.name as facility, SUM(IF(B.memid > 0, B.slots*F.membercost, B.slots*F.guestcost)) AS revenue
FROM Bookings B
JOIN Facilities F ON F.facid = B.facid
GROUP BY facility) tbl
WHERE revenue < 1000 ORDER BY `revenue`  ASC