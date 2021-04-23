CREATE TABLE growth
SELECT Business_unit.BU_Designation, Business_unit.BU_Name, Product_Data.Product, Product_Data.Year, Sum(Product_Data.Quantity) AS 'Sum_of_Quantity', Sum(Product_Data.Order_Total) AS 'Sum_of_Order_Total'
FROM (Business_unit INNER JOIN Product_bu ON Business_unit.BU_Name = Product_bu.BU_Name) INNER JOIN Product_Data ON (Product_Data.Year = Product_bu.Prod_BU_Year) AND (Product_bu.Product_Name = Product_Data.Product)
WHERE (Business_unit.BU_Designation)="growth"
GROUP BY Business_unit.BU_Designation, Business_unit.BU_Name, Product_Data.Product, Product_Data.Year;

SELECT * FROM growth;
#Create Growth Calculation Table
create table growth_calc
(
BU_Name varchar(15), 
product varchar(30), 
2012_Quantity int, 
2013_Quantity int, 
2014_Quantity int, 
2012_OrderTotal int,
2013_OrderTotal int,
2014_OrderTotal int,
Quantity_Growth_2012_to_2013 dec(6,2), 
Quantity_Growth_2013_to_2014 dec(6,2),
OrderTotal_Growth_2012_to_2013 dec(6,2), 
OrderTotal_Growth_2013_to_2014 dec(6,2));

INSERT INTO growth_calc
	(BU_Name, product, 2012_Quantity, 2013_Quantity, 2014_Quantity, 2012_OrderTotal, 2013_OrderTotal, 2014_OrderTotal)
VALUE
    ('Energy','Purple Pain',732,943,964,254736,344195,334792),
    ('Energy','Red Hot Chili Peppers',664,1515,1354,285520,657510,534560),
    ('On the go','Blue Rock Candy',781,1147,914,363946,560883,444002),
    ('On the go','Pink Bubble Gum',829,979,1483,263622,311322,452497),
    ('Snack','Crocodile Tears',970,1424,1572,273540,417232,426126);
    
UPDATE growth_calc 
SET Growth_calc.Quantity_Growth_2012_to_2013 = ((2013_quantity-2012_quantity)/2012_quantity), 
Growth_calc.Quantity_Growth_2013_to_2014 = ((2014_quantity-2013_quantity)/2013_quantity), 
Growth_calc.OrderTotal_Growth_2012_to_2013 = ((2013_ordertotal-2012_ordertotal)/2012_ordertotal), 
Growth_calc.OrderTotal_Growth_2013_to_2014 = ((2014_ordertotal-2013_ordertotal)/2013_ordertotal);

SELECT * FROM growth_calc;