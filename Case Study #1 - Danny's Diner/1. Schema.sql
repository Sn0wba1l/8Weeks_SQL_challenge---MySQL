DROP TABLE Sales;
DROP TABLE Menu;
DROP TABLE Members;

CREATE TABLE Sales 
(
    Customer_ID VARCHAR(10),
    Order_date DATE,
    Product_ID INTEGER
);

DESCRIBE Sales;

CREATE TABLE Menu 
(
    Product_ID INTEGER,
    Product_name VarChar(20),
    Price Integer,
    PRIMARY KEY (Product_ID)
);

ALTER TABLE Menu 
ADD FOREIGN KEY (Product_ID) REFERENCES Sales(Product_ID) ON DELETE SET NULL;

CREATE TABLE Members 
(
    Customer_ID VarChar(10),
    Join_date date,
    Primary key (Customer_ID)
);

INSERT INTO Sales VALUES ('A', '2021-01-01', 1);
INSERT INTO Sales VALUES ('A', '2021-01-01', 2);
INSERT INTO Sales VALUES ('A', '2021-01-07', 2);
INSERT INTO Sales VALUES ('A', '2021-01-10', 3);
INSERT INTO Sales VALUES ('A', '2021-01-11', 3);
INSERT INTO Sales VALUES ('A', '2021-01-11', 3);
INSERT INTO Sales VALUES ('B', '2021-01-01', 2);
INSERT INTO Sales VALUES ('B', '2021-01-02', 2);
INSERT INTO Sales VALUES ('B', '2021-01-04', 1);
INSERT INTO Sales VALUES ('B', '2021-01-11', 1);
INSERT INTO Sales VALUES ('B', '2021-01-16', 3);
INSERT INTO Sales VALUES ('B', '2021-02-01', 3);
INSERT INTO Sales VALUES ('C', '2021-01-01', 3);
INSERT INTO Sales VALUES ('C', '2021-01-01', 3);
INSERT INTO Sales VALUES ('C', '2021-01-07', 3);

INSERT INTO Menu VALUES (1,'sushi',10);
INSERT INTO Menu VALUES (2,'curry',15);
INSERT INTO Menu VALUES (3,'ramen',12);

INSERT INTO Members VALUES ('A','2021-01-07');
INSERT INTO Members VALUES ('B','2021-01-09');


SELECT * FROM Sales;
