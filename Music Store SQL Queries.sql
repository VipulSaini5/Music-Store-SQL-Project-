/* Q1 : Who is the senior most employee based on job title. */

SELECT * FROM Employee
ORDER BY Levels DESC
LIMIT 1;

/* Q2 : Which countries have the most Invoices. */

SELECT COUNT(*) AS Number, Billing_Country 
FROM Invoice
GROUP BY Billing_Country
ORDER BY Number DESC;

/* Q3 : What are top 3 values of total invoice. */

SELECT Total FROM Inoice
ORDER BY Total DESC
LIMIT 3;

/* Q4 : Which city has the best customers? We would like to throw a promotional Music Festival in the city 
		we made the most money. Write a query that returns one city that has the highest sum of invoice totals.
		Return both the city name & sum of all invoice totals. */

SELECT Billing_City, SUM(Total) AS Invoice_Total 
FROM Inoice
GROUP BY Billing_City 
ORDER BY Invoice_Total DESC;

/* Q5 : Who is the best customer? The customer who has spent the most money will be declared the best customer. 
		Write a query that returns the person who has spent the most money. */

SELECT Customer.Customer_ID, Customer.First_Name, Customer.Last_Name, SUM(Invoice.Total) AS Total 
FROM Customer
JOIN Invoice ON Customer.Customer_ID = Invoice.Customer_ID
GROUP BY Customer.Customer_ID 
ORDER BY Total DESC 
LIMIT 1;

/* Q6 : Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
		Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT Email, First_Name, Last_Name
FROM Customer
JOIN Invoice ON Customer.Customer_ID = Invoice.Customer_ID
JOIN Invoice_Line ON Invoice.Invoice_ID = Invoice_Line.Invoice_ID 
WHERE Track_ID IN(
	SELECT Track_ID FROM Track
	JOIN Genre ON Track.Genre_ID = Genre.Genre_ID 
	WHERE Genre.Name LIKE 'Rock'
)
ORDER BY Email;

/* Q7 : Let's invite the artists who have written the most rock music in our dataset. 
		Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT Artist.Artist_ID, Artist.Name, COUNT(Artist.Artist_ID) AS Number_of_Song
FROM Track 
JOIN Album ON Album.Album_ID = Track.Album_ID 
JOIN Artist ON Artist.Artist_ID = Album.Artist_ID 
JOIN Genre ON Genre.Genre_ID = Track.Genre_ID 
WHERE Genre.Name LIKE 'Rock'
GROUP BY Artist.Artist_ID 
ORDER BY Number_of_Song DESC
LIMIT 10 ;

/* Q8 : Return all the track names that have a song length longer than the average song length. Return the Name 
		and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT Name, Milliseconds
FROM Track 
WHERE Milliseconds > (
	SELECT AVG(Milliseconds) AS Avg_Length_Track
	FROM Track )
ORDER BY Milliseconds DESC ;

/* Q9 : Find how much amount spent by each customer on artists? Write a query to return customer name, 
		artist name and total spent. */

WITH Best_Selling_Artist AS (
	SELECT Artist.Artist_ID AS Artist_ID, Artist.Name AS Artist_Name, 
	SUM(Invoice_Line.Unit_Price*Invoice_Line.Quantity) AS Total_Sales
	FROM Invoice_Line
	JOIN Track ON Track.Track_ID = Invoice_Line.Track_ID
	JOIN Album ON Album.Album_ID = Track.Album_ID
	JOIN Artist ON Artist.Artist_ID = Album.Artist_ID
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT C.Customer_ID, C.First_Name, C.Last_Name, BSA.Artist_Name, 
SUM(Il.Unit_Price*Il.Quantity) AS Amount_Spent
FROM Invoice I
JOIN Customer C ON C.Customer_ID = I.Customer_ID
JOIN Invoice_Line Il ON Il.Invoice_ID = I.Invoice_ID
JOIN Track T ON T.Track_ID = Il.Track_ID
JOIN Album ALB ON ALB.Album_ID = T.Album_ID
JOIN Best_Selling_Artist BSA ON BSA.Artist_ID = ALB.Artist_ID
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q10 : We want to find out the most popular music Genre for each country. We determine the most popular genre
		 as the genre with the highest amount of purchases. Write a query that returns each country along with
		 the top Genre. For countries where the maximum number of purchases is shared return all Genres. */

WITH RECURSIVE
	Sales_Per_Country AS(
		SELECT COUNT(*) AS Purchases_Per_Genre, Customer.Country, Genre.Name, Genre.Genre_ID
		FROM Invoice_Line
		JOIN Invoice ON Invoice.Invoice_ID = Invoice_Line.Invoice_ID
		JOIN Customer ON Customer.Customer_ID = Invoice.Customer_ID
		JOIN Track ON Track.Track_ID = Invoice_Line.Track_ID
		JOIN Genre ON Genre.Genre_ID = Track.Genre_ID
		GROUP BY 2,3,4
		ORDER BY 2
	),
	Max_Genre_Per_Country AS (SELECT MAX(Purchases_Per_Genre) AS Max_Genre_Number, Country
		FROM Sales_Per_Country
		GROUP BY 2
		ORDER BY 2)

SELECT Sales_Per_Country.* 
FROM Sales_Per_Country
JOIN Max_Genre_Per_Country ON Sales_Per_Country.Country = Max_Genre_Per_Country.Country
WHERE Sales_Per_Country.Purchases_Per_Genre = Max_Genre_Per_Country.Max_Genre_Number;



