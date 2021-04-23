/*
Date created: June 3, 2019
Created by: Laura Ellis

Description: The SQL queries below perform a series of tasks using the
database 'University'. The scripts assume that 'A_University v07.sql'
has been run creating the following tables:
Course (3 columns, 11 rows)
Enrollment (3 columns, 438 rows)
Faculty (4 columns, 13 rows)
Offering (5 columns, 60 rows)
Student (6 columns, 150 rows)
The following relationships exist between tables:
	Course.CourseNo = Offering.CourseNo
	Student.stdSSN = Enrollment.stdSSN
	Enrollment.OfferNo = Offering.OfferNo
	Offering.FacultySSN = Faculty.FacultySSN
*/

#VERIFICATION OF TABLES BEFORE BEGINNING
#Verify table 'University' is in SQL (Result: 11)
select count(course.crsDesc) from course;
#Verify table 'University' is in SQL (Result: 34)
select sum(course.crsUnits) from course;
#End of verification 

/*Assignment 3.1 Problems
Each problem should be followed sequentially.
Screenshot captures will be indicated by the note #SCREENSHOT 
Problem 2: List course offerings taught by Professor Sylvester 
Jackson (no date restrictions). 
Tables used: 
faculty 
offering
Columns to display (L to R, Ascending by column):
OffYear
CourseNo
OffTerm
Joins:
        faculty.FacSSN = offering.FacSSN
Selects:
faculty.FacFirstName
faculty.FacLastName
*/

SELECT Offering.OffYear, Offering.CourseNo, Offering.OffTerm
FROM Faculty INNER JOIN Offering 
    ON Faculty.FacSSN = Offering.FacSSN
	WHERE Faculty.FacFirstName="Sylvester"
			AND Faculty.FacLastName="Jackson"
ORDER BY Offering.OffYear, Offering.CourseNo, Offering.OffTerm;
#SCREENSHOT
#END OF PROBLEM 2

/*Problem 3: Add "Bobby McGee" to List of students
Bobby McGee’s information:
stdSSN: 609-73-8727
stdFirstName: BOBBY
stdLastName: MCGEE
stdMajor: UNK
stdClass: FRESHMAN
StdGPA: 2.50
StdCity: MORRISTOWN
StdState: NJ
StdZIP: 07960-1111
Because the current database structure does not have a table for address information a new table “stdAddress” is created containing stdCity, stdState, and stdZIP.
 */
    
#BEFORE SCREENSHOT: Show students with unknown major before Bobby McGee is added.
SELECT * FROM student 
	WHERE stdMajor = 'UNK'
ORDER BY stdLastName;

#Add Bobby McGee. This command inserts Bobby’s information into the existing student table.
INSERT INTO Student (stdSSN, stdFirstName, stdLastName, stdMajor, stdClass, stdGPA) VALUES ('609-73-8727', 'BOBBY', 'MCGEE', 'UNK', 'FR', '2.50');

#Store Bobby's address information in new table stdAddress
#Step 1: Create student address table "stdAddress"
CREATE TABLE stdAddress
(stdSSN char (11) not null,
stdCity varchar (20), 
stdState varchar (2),
stdZIP varchar (10));
#Step 2: Add Bobby's address
insert into stdAddress (stdSSN, stdCity, stdState, stdZIP) values ('609-73-8727', 'MORRISTOWN', 'NJ', '07960-1111');

#AFTER SCREENSHOT Show students with unknown major after Bobby McGee is added. Use left join to show all students and
#addresses where available (only Bobby at this point). Join student and stdAddress using stdSSN field.
SELECT Student.*, stdAddress.*
FROM Student LEFT JOIN stdAddress ON Student.stdSSN = stdAddress.stdSSN
WHERE Student.stdMajor='UNK' GROUP BY Student.stdLastName;

#END OF PROBLEM 3

/*Problem 4: Change crsDesc of CourseNo Dat515 from "Data Mining" to "Predictive Analytics"
*/

#BEFORE SCREENSHOT showing DAT515 as Data Mining
SELECT * FROM university.course ORDER BY CourseNo;

#Update course description of course number DAT515
UPDATE Course SET Course.crsDesc = "PREDICTIVE ANALYTICS"
WHERE Course.CourseNo="DAT515" AND Course.crsDesc="DATA MINING";

#AFTER SCREENSHOT showing Dat515 as Predictive Analytics
SELECT * FROM university.course ORDER BY CourseNo;

#END OF PROBLEM 4

/*Problem 5: List faculty (first and last) by number of courses descending
Tables used: Faculty, Offering
Join: faculty and offering tables with field FacSSN
*/
#This command groups faculty by the distinct number of courses they have taught.
SELECT Faculty.FacFirstName AS 'First Name', Faculty.FacLastName AS 'Last Name', Count(DISTINCT Offering.CourseNo) AS 'Number of Courses Taught'
	FROM Offering RIGHT JOIN Faculty ON Offering.FacSSN = Faculty.FacSSN
	GROUP BY Faculty.FacFirstName, Faculty.FacLastName
	ORDER BY Count(DISTINCT Offering.CourseNo) DESC;
#SCREENSHOT showing number of courses taught by teacher.

#END OF PROBLEM 5

/*Problem 6: List faculty (FacRank - FacLastName) by number of classes taught
Tables: Faculty, Offering
Join: faculty and offering tables with field FacSSN
*/
SELECT CONCAT(Faculty.FacRank, ' - ', Faculty.FacLastName) AS 'Faculty Rank and Last Name', Count(Offering.CourseNo) AS 'Number of Classes'
	FROM Offering RIGHT JOIN Faculty ON Offering.FacSSN = Faculty.FacSSN
	GROUP BY Faculty.FacFirstName, Faculty.FacLastName
	ORDER BY Count(Offering.CourseNo) DESC;
#SCREENSHOT showing number of classes taught by each teacher. Courses are taught multiple times in individual classes.

#END OF PROBLEM 6

/*Problem 7: Remove all offerings of DAT480 for Fall of 2018
Table: Offering
*/

#BEFORE SCREENSHOT showing DAT480 courses including Fall of 2018
SELECT Offering.*
FROM Offering
WHERE Offering.CourseNo="DAT480" 
ORDER BY Offering.OfferNo;

DELETE Offering.*
FROM Offering
WHERE Offering.CourseNo="DAT480" AND Offering.OffTerm="Fall" AND Offering.OffYear=2018;

#SCREENSHOT showing DAT480 courses after removal of Fall of 2018
SELECT Offering.*
FROM Offering
WHERE Offering.CourseNo="DAT480" 
ORDER BY Offering.OfferNo;

#END OF PROBLEM 7

/*Problem 8: List course number, course description, term and year offered, faculty first and last for future years. Do not include this year.
Tables: Course, Offering, Faculty
Joins: Course.CourseNo=Offering.CourseNO, and Offering.FacSSN=Faculty.FacSSN
Order from soonest to latest (next year to future years)
All future years are years > now
*/
SELECT Course.CourseNo, Course.crsDesc, Offering.OffTerm, Offering.OffYear, Faculty.FacFirstName, Faculty.FacLastName
FROM (Course INNER JOIN Offering ON Course.CourseNo = Offering.CourseNo) INNER JOIN Faculty ON Offering.FacSSN = Faculty.FacSSN
WHERE Offering.OffYear>Year(Now()) 
ORDER BY Offering.OffYear, Offering.OffTerm, Faculty.FacLastName, Faculty.FacFirstName;
#SCREENSHOT showing future courses

#END OF PROBLEM 8

/*Problem 9: List total number of credit hours taken in 2016 by IS majors.
Tables: Course, Offering, Student
Joins: Course.CourseNo = Offering.CourseNo, Student.stdSSN = Enrollment.stdSSN, Offering.OfferNo = Enrollment.OfferNo
*/
SELECT CONCAT (course.courseNo, ' - ', Course.crsDesc) AS 'Course Number and Description', Sum(Course.CrsUnits) AS 'Number of Credit-hours'
FROM (Course INNER JOIN Offering ON Course.CourseNo = Offering.CourseNo) INNER JOIN 
	(Student INNER JOIN Enrollment ON Student.stdSSN = Enrollment.stdSSN) ON Offering.OfferNo = Enrollment.OfferNo
WHERE (Student.stdMajor="IS") AND (Offering.OffYear=2016)
GROUP BY course.CourseNo
ORDER BY Sum(Course.CrsUnits) DESC;
#SCREENSHOT of Course Number & Description concatenated, number of credit hours

#END OF PROBLEM 9

/*Problem 10: List stdSSN, stdFirstName, stdLastName, stdMajor, stdGPA, Course No, CrsDesc, CrsUnits, OffTerm, OffYear, FacultyFirstName, FacultyLastName)
Tables: Student, Course, Offering, Faculty, Enrollment
Joins: Student.stdSSN = Enrollment.stdSSN, Enrollment.OfferNo = Offering.OfferNo, Offering.CourseNo = Course.CourseNo, Faculty.FacSSN = Offering.FacSSN
*/
#USE TO POPULATE SPREADSHEET
SELECT Student.stdSSN, Student.stdFirstName, Student.stdLastName, Student.stdMajor, Student.stdGPA, Course.CourseNo, Course.crsDesc, Course.CrsUnits, Offering.OffTerm, Offering.OffYear, Faculty.FacFirstName, Faculty.FacLastName
FROM Faculty INNER JOIN (((Student INNER JOIN Enrollment ON Student.stdSSN = Enrollment.stdSSN) INNER JOIN Offering ON Enrollment.OfferNo = Offering.OfferNo) INNER JOIN Course ON Offering.CourseNo = Course.CourseNo) ON Faculty.FacSSN = Offering.FacSSN
ORDER BY Student.stdSSN;

#OTHER COUNTS
#Number of students enrolled by course and term.
SELECT Course.CourseNo, Course.crsDesc, Offering.OffYear, Offering.OffTerm, Count(Enrollment.stdSSN) AS 'Students Enrolled'
FROM (Enrollment INNER JOIN Offering ON Enrollment.OfferNo = Offering.OfferNo) INNER JOIN Course ON Offering.CourseNo = Course.CourseNo
GROUP BY Course.CourseNo, Course.crsDesc, Offering.OffYear, Offering.OffTerm;

#Number student enrollments by Term Year
SELECT Offering.OffYear, Count(Student.stdSSN) AS CountOfstdSSN
FROM (Enrollment INNER JOIN Student ON Enrollment.stdSSN = Student.stdSSN) INNER JOIN Offering ON Enrollment.OfferNo = Offering.OfferNo
GROUP BY Offering.OffYear;

#END OF PROBLEM 10