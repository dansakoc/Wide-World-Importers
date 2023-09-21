

--- Explore the tables to use

Select*
From [Sales].[Customers]

Select*
From [Sales].[OrderLines]


Select*
From [Sales].[InvoiceLines]


Select*
From [Sales].[Invoices]

Select*
From [Sales].[Orders]


--- Counting some rows

Select count(*)
From [Sales].[Customers]

Select count(*)
From [Sales].[OrderLines]




--- Check for missing data in the column PickingCompletedWhen

Select count(PickingCompletedWhen)
From [Sales].[OrderLines]


Select count(*) - count(PickingCompletedWhen) AS missing
From [Sales].[OrderLines]



--- Select maximujm quantity order 
Select min(Quantity) AS minquantity
From [Sales].[OrderLines]



--- Select mininimum  quantity

Select max(Quantity) AS minquantity
From [Sales].[OrderLines]


--- Average  price 

Select AVG(UnitPrice)  AS AveragePrice
From [Sales].[InvoiceLines]



--- Average pprofit

Select AVG(LineProfit) AS AverageProfit
From [Sales].[InvoiceLines]



--- Count the number of products in the description column

Select Description,count(*) TotalProduct
From [Sales].[InvoiceLines]
group by Description
order by  TotalProduct DESC 



--- Select the product  Developer 

Select Description, Quantity,UnitPrice, LineProfit
From [Sales].[InvoiceLines]
where  Description like 'DEV%'



--- Total quantity ordered by each customer in 2013

Select so.CustomerID, sc.CustomerName,sum(Quantity) as totalquantity
From [Sales].[Orders] as so
Left join  [Sales].[Customers] as sc
on so.CustomerID = sc.CustomerID
Left join [Sales].[OrderLines] as  sol
On so.OrderID = sol.OrderID
Where OrderDate in ('2013')
Group by so.CustomerID, sc.CustomerName
Order by totalquantity DESC



--- Average quatity ordered in 2013

with data1 AS (Select so.CustomerID, sc.CustomerName,count(Quantity) as totalquantity
From [Sales].[Orders] as so
Left join  [Sales].[Customers] as sc
on so.CustomerID = sc.CustomerID
Left join [Sales].[OrderLines] as  sol
On so.OrderID = sol.OrderID
Where OrderDate in ('2013')
Group by so.CustomerID, sc.CustomerName)

Select  Avg(totalquantity) as Avgquantity
from data1

--- rank the company by profit inn 2013

Select so.CustomerID, sc.CustomerName ,sum(sil.LineProfit) as totalprofit,
dense_rank()Over (partition by so.CustomerID Order by sil.LineProfit) as Custprofit
From [Sales].[Orders] as so
Inner join  [Sales].[Invoices] as si
on so.CustomerID = si.CustomerID
Inner join [Sales].[Customers] as sc
on so.CustomerID = sc.CustomerID
inner join [Sales].[InvoiceLines] as  sil
On si.invoiceID = sil.InvoiceID
Where OrderDate in ('2013')
 Group by so.CustomerID, sc.CustomerName,sil.LineProfit
Order by totalprofit DESC;



--- Compare the profit to the previous profit

Select  so.CustomerID,  sc.CustomerName ,so.OrderDate,sil.LineProfit,
lag(sil.LineProfit)Over (partition by so.CustomerID,so.OrderDate Order by so.OrderDate ) as previousprofit,
sil.LineProfit - lag(sil.LineProfit)Over (partition by so.CustomerID,so.OrderDate Order by so.OrderDate) Profitdifference
From [Sales].[Orders] as so
Inner join  [Sales].[Invoices] as si
on so.CustomerID = si.CustomerID
Inner join [Sales].[Customers] as sc
on so.CustomerID = sc.CustomerID
inner join [Sales].[InvoiceLines] as  sil
On si.invoiceID = sil.InvoiceID
 Where OrderDate in ('2013')
 Group by so.CustomerID, sc.CustomerName,sil.LineProfit, OrderDate;



-- Show the product with highest profit overall

Select Description, LineProfit,
First_value(LineProfit)Over (order by LineProfit DESC) as highestprofit
From [Sales].[InvoiceLines]
 Group by  Description,  LineProfit
Order by  LineProfit  DESC;


---Show the product with highest profit in 2013

Select sil.Description,sil.LineProfit,
First_value( sil.LineProfit)Over (order by sil.LineProfit DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) as highestprofit
from  [Sales].[Invoices] as si
inner join [Sales].[InvoiceLines] as  sil
On si.invoiceID = sil.InvoiceID
Where InvoiceDate in ('2013')
 Group by sil.Description, sil.LineProfit
Order by sil.LineProfit DESC;



 --- Total sales in 2013

Select so.CustomerID, sc.CustomerName ,sil.Description,  so.OrderDate,  sil.Quantity , sil.UnitPrice ,  (sil.Quantity *  sil.UnitPrice ) as totalsales
From [Sales].[Orders] as so
Inner join  [Sales].[Invoices] as si
on so.CustomerID = si.CustomerID
Inner join [Sales].[Customers] as sc
on so.CustomerID = sc.CustomerID
inner join [Sales].[InvoiceLines] as  sil
On si.invoiceID = sil.InvoiceID
Where 
1=1 and OrderDate BETWEEN '2013-01-01' AND '2013-12-31'
Group by so.CustomerID, sc.CustomerName,sil.Description,sil.LineProfit, sil.Quantity,sil.UnitPrice, so.OrderDate
Order by totalsales DESC;



--- Total sales between 2013-01-01 AND 2016-12-31

Select so.CustomerID, sc.CustomerName ,sil.Description,  so.OrderDate,  sil.Quantity , sil.UnitPrice ,  (sil.Quantity *  sil.UnitPrice ) as totalsales
From [Sales].[Orders] as so
Inner join  [Sales].[Invoices] as si
on so.CustomerID = si.CustomerID
Inner join [Sales].[Customers] as sc
on so.CustomerID = sc.CustomerID
inner join [Sales].[InvoiceLines] as  sil
On si.invoiceID = sil.InvoiceID
Where 
1=1 and OrderDate BETWEEN '2013-01-01' AND '2016-12-31'
Group by so.CustomerID, sc.CustomerName,sil.Description,sil.LineProfit, sil.Quantity,sil.UnitPrice, so.OrderDate
Order by totalsales DESC;



---- Create a profit Margin Ratio
WITH salesdata AS ( Select so.CustomerID, sc.CustomerName ,sil.Description,  so.OrderDate,  sil.Quantity , sil.UnitPrice ,  (sil.Quantity *  sil.UnitPrice ) as totalsales,
sil.LineProfit
From [Sales].[Orders] as so
Inner join  [Sales].[Invoices] as si
on so.CustomerID = si.CustomerID
Inner join [Sales].[Customers] as sc
on so.CustomerID = sc.CustomerID
inner join [Sales].[InvoiceLines] as  sil
On si.invoiceID = sil.InvoiceID
Where 
1=1 and OrderDate BETWEEN '2013-01-01' AND '2016-12-31'
Group by so.CustomerID, sc.CustomerName,sil.Description,sil.LineProfit, sil.Quantity,sil.UnitPrice, so.OrderDate)

Select OrderDate, totalsales, LineProfit, ROUND((LineProfit)/(totalsales),2)  as profitMargin 
FROM salesdata
group by totalsales,LineProfit, OrderDate
ORDER BY profitMargin DESC



--- Create TEMP TABLE

DROP TABLE IF EXISTS salestable 

CREATE TABLE salestable 
(CustomerID INT,
customerName varchar(250),
Description   nvarchar(250),
OrderDate datetime,
 Quantity numeric,
 UnitPrice numeric,
 totalsales numeric
 )
 INSERT INTO  salestable 
 Select so.CustomerID, sc.CustomerName ,sil.Description,  so.OrderDate,  sil.Quantity , sil.UnitPrice ,  (sil.Quantity *  sil.UnitPrice ) as totalsales
From [Sales].[Orders] as so
Inner join  [Sales].[Invoices] as si
on so.CustomerID = si.CustomerID
Inner join [Sales].[Customers] as sc
on so.CustomerID = sc.CustomerID
inner join [Sales].[InvoiceLines] as  sil
On si.invoiceID = sil.InvoiceID
Where 
1=1 and OrderDate BETWEEN '2013-01-01' AND '2016-12-31'
Group by so.CustomerID, sc.CustomerName,sil.Description,sil.LineProfit, sil.Quantity,sil.UnitPrice, so.OrderDate

Select*
FROM salestable 
where OrderDate in ('2016')




--- Use case when to group the price in category

Select so.CustomerID, sc.CustomerName ,sil.Description,  so.OrderDate,  sil.Quantity , sil.UnitPrice ,  (sil.Quantity *  sil.UnitPrice ) as totalsales,
case when sil.Quantity *  sil.UnitPrice > 10000 then 'higher Sales'
   when  sil.Quantity *  sil.UnitPrice > 5000  then 'medium'
   else 'lower Sales' End 'sales Categories'
From [Sales].[Orders] as so
Inner join  [Sales].[Invoices] as si
on so.CustomerID = si.CustomerID
Inner join [Sales].[Customers] as sc
on so.CustomerID = sc.CustomerID
inner join [Sales].[InvoiceLines] as  sil
On si.invoiceID = sil.InvoiceID
Where 
1=1
and OrderDate BETWEEN '2013-01-01' AND '2013-12-31'
Group by so.CustomerID, sc.CustomerName,sil.Description,sil.LineProfit, sil.Quantity,sil.UnitPrice, so.OrderDate
Order by totalsales DESC 




--- Create view

Create View pricecategory as 
Select so.CustomerID, sc.CustomerName ,sil.Description,  so.OrderDate,  sil.Quantity , sil.UnitPrice ,  (sil.Quantity *  sil.UnitPrice ) as totalsales,
case when sil.Quantity *  sil.UnitPrice > 10000 then 'higher Sales'
   when  sil.Quantity *  sil.UnitPrice > 5000  then 'medium'
   else 'lower Sales' End 'sales Categories'
From [Sales].[Orders] as so
Inner join  [Sales].[Invoices] as si
on so.CustomerID = si.CustomerID
Inner join [Sales].[Customers] as sc
on so.CustomerID = sc.CustomerID
inner join [Sales].[InvoiceLines] as  sil
On si.invoiceID = sil.InvoiceID
Where 
1=1
and OrderDate BETWEEN '2013-01-01' AND '2013-12-31'
Group by so.CustomerID, sc.CustomerName,sil.Description,sil.LineProfit, sil.Quantity,sil.UnitPrice, so.OrderDate
--- Order by totalsales DESC 

Select*
FROM pricecategory

