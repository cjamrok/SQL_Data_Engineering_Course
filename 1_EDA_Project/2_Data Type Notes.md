# Data Types

- btw link to Luke's repository for this course:
[Luke Git Repo](https://github.com/lukebarousse/SQL_Data_Engineering_Course/tree/main/Projects/2_WH_Mart_Build)

![alt text](<../Images/Data Types_1.png>)

![alt text](<../Images/Data Types_2.png>)

1. Strings
- CHAR(n) = exact number of characters. If your string doesn't match the character defined here, it will cut it off to enforce the number of characters.
VARCHAR(n) = text varies, variable length
Text = long unbounded text that takes up a lot of memory, no length limit

[Data_Types.sql](../Lessons/1.20/Data_Types.sql)

# DDL vs DML vs DQL 
- DQL is what we've been doing - querying
- DML = Data Manipulation Language = update data in existing tables (Insert, Update, Delete)
- DDL = Data Def Language = creating and destroying complete objects with this language. (Create, Drop, Alter). Modify database structure and schema. 
- DCL Data Control Lanugage (not covered in this course)
- TCL Transaction Control Language (not covered in this course)

![alt text](<../Images/Data Pipelining.png>)

## We're going to create and set up our own Motherduck database in the cloud for the course

![alt text](<../Images/Screenshot 2026-08-17 201432.png>)
- Create
![alt text](<../Images/Screenshot 2026-08-17 201835.png>)

![alt text](<../Images/Screenshot 2026-08-17 202635.png>)
### VSCode trick to swap databases before creating/dropping/altering
![VSCode trick to swap schemas](<../Images/Screenshot 2026-08-17 203348.png>)

