/*TRANSfORM PRODUCT DATA
Date created: June 26, 2019

This script assumes you are using database: group_1_business with tables: 2012_product_data_students, 2013_product_data_students, 2014_product_data_students, business_unit, and product_bu
	(Create schema: create schema group_1_business;  Run SQL script Week_6_business_units, import product data files)

This script will transform product data from 2012 through 2014 and create a table to export G1_Output
*/

#Specify database to use
USE group_1_business;

#Create table Product_Data
create table Product_Data
(Year int (4), 
Month int (2), 
Region varchar (15), 
Product varchar (30), 
Per_Unit_Price int (11), 
Quantity int (11), 
Order_Total int (11));

#Transform product data and put in G1_Output

#Change 2012 fields 'Order Total' to Order_Total and 'Per-Unit Price' to Per_Unit_Price
ALTER TABLE `group_1_business`.`2012_product_data_students` 
CHANGE COLUMN `Order Total` `Order_Total` INT(11),
CHANGE COLUMN `Per-Unit Price` `Per_Unit_Price` INT(11);

#Transform and append 2012 product data to g1_transform
INSERT INTO Product_Data (Month, Region, Product, Quantity, Order_Total, Year, Per_Unit_Price)
SELECT 2012_product_data_students.Month, 
Region, 
Product, 
Quantity, 
Order_Total, 
2012, 
Per_Unit_Price
FROM (Business_unit INNER JOIN Product_bu ON Business_unit.BU_Name = Product_bu.BU_Name) 
INNER JOIN 2012_product_data_students ON Product_bu.Product_Name = 2012_product_data_students.Product
WHERE (BU_Designation="Growth" Or BU_Designation="Mature") AND (Prod_BU_Year=2012);

#Change 2013 field 'per-Unit Price' to Per_Unit_Price
ALTER TABLE `group_1_business`.`2013_product_data_students` 
CHANGE COLUMN `Per-Unit Price` `Per_Unit_Price` INT(11);

#Transform and append 2013 product data to g1_transform
#Quantity = Quantity_1 + Quantity_2, Order_Total = (Quantity_1 + Quantity_2)*Per_Unit_Price
INSERT INTO Product_Data (Month, Region, Product, Per_Unit_Price, Quantity, Order_Total, Year)
SELECT Month, 
2013_product_data_students. Region, 
Product, 
Per_Unit_Price, 
Quantity_1+Quantity_2, (
Quantity_1+Quantity_2)*Per_Unit_Price, 
2013
FROM Business_unit INNER JOIN (2013_product_data_students INNER JOIN Product_bu ON 2013_product_data_students.Product = Product_bu.Product_Name) ON Business_unit.BU_Name = Product_bu.BU_Name
WHERE ((BU_Designation="Growth" Or BU_Designation="Mature") AND (Prod_BU_Year=2013));

#Change 2014 fields 'per-Unit Price' to Per_Unit_Price, 'Order Subtotal' to Order_Subtotal, and 'Quantity Discount' to Quantity_Discount
ALTER TABLE `group_1_business`.`2014_product_data_students` 
CHANGE COLUMN `Per-Unit Price` `Per_Unit_Price` INT(11),
CHANGE COLUMN `Order Subtotal` `Order_Subtotal` INT(11),
CHANGE COLUMN `Quantity Discount` `Quantity_Discount` INT(11);

#Transform and append 2014 product data to g1_transform
#Order_Total = Order_Subtotal - Quantity_Discount
INSERT INTO Product_Data (Month, Region, Product, Per_Unit_Price, Quantity, Order_Total, Year)
SELECT Month, 
Region, 
Product, 
Per_Unit_Price, 
Quantity, 
Order_Subtotal-quantity_discount, 
2014
FROM Business_unit INNER JOIN (2014_product_data_students INNER JOIN Product_bu ON 2014_product_data_students.Product = Product_bu.Product_Name) ON Business_unit.BU_Name = Product_bu.BU_Name
WHERE ((BU_Designation)="growth" Or (BU_Designation)="mature") AND (Prod_BU_Year=2014);

#Sum Quantity and Order Total in G1_transform
CREATE TABLE G1_transform
SELECT BU_Designation, 
Product_bu.BU_Name, 
Product, 
Region, 
Year, 
Month, 
Sum(Quantity) AS 'Sum_of_Quantity', 
Sum(Order_Total) AS 'Sum_of_Order_Total'
FROM (Business_unit INNER JOIN Product_bu ON Business_unit.BU_Name = Product_bu.BU_Name) INNER JOIN Product_Data ON (Product_Data.Year = Product_bu.Prod_BU_Year) AND (Product_bu.Product_Name = Product_Data.Product)
GROUP BY BU_Designation, 
BU_Name, 
Product, 
Region, 
Year, 
Month;

#Prepare data for export in table G1_export, order ascending left to right
CREATE TABLE G1_export
SELECT CONCAT(BU_Designation,',',BU_Name,',',Product,',',Region,',',Year,',',Month,',',Sum_of_Quantity,',',Sum_of_Order_Total) AS 'UPDATE_COLUMN_NAMES_HERE'
FROM G1_transform
ORDER BY BU_Designation, BU_Name, Product, Region, Year, Month;

#Headers were added to the export file in Excel.

#END OF SCRIPT

/*
Export using command prompt
Command prompts:
Change directory: cd C:\Program Files\MySQL\MySQL Workbench 8.0 CE

PROMPT:	C:\Program Files\MySQL\MySQL Workbench 8.0 CE>
COMMAND:    mysql.exe 
		-h ENTER AZURE DATABASE HERE -P 3306 
		-u ENTER AZURE USER HERE -p -e "SELECT * FROM group_1_business.g1_export"
		> "c:\Documents\G1_Output_Final.csv"
*/

