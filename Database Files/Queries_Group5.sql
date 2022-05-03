-- Query 1
SELECT E.EmployeeID
FROM Employee E
WHERE E.Salary < SOME (
    SELECT P.Product_MRP + P.Applicable_CGST + P.Applicable_SGST
    FROM Product P
    WHERE P.ProductID IN (
	  SELECT PL.ProductID
       FROM Purchase_List PL, Offline_Purchase OP
	  WHERE E.BranchID = OP.BranchID 
		AND OP.PurchaseID = PL.PurchaseID
		AND OP.Date_Of_Purchase >= '2021-09-01' AND OP.Date_Of_Purchase <= '2021-09-30'
    )
);

-- Query 2
SELECT P.ProductID, P.Product_Name, R.Product_Preview
FROM Review R, Product P
WHERE P.ProductID = R.ProductID AND R.Stars = 1 AND R.ProductID IN 
	(SELECT OL.ProductID
	 FROM Order_List OL, OnlineReturn OnR
	 WHERE OL.OrderID = OnR.OrderID AND R.LoginID = OnR.LoginID
);

-- Query 3
UPDATE Employee
SET Employee.Salary = CASE
WHEN ((SELECT SUM(P.Product_MRP)
	FROM Product P
	WHERE P.ProductID IN (SELECT PL.ProductID
		FROM Purchase_List PL, Offline_Purchase OP
        WHERE PL.ProductID = P.ProductID AND PL.PurchaseID = OP.PurchaseID AND OP.BranchID = Employee.BranchID))
	- (SELECT * FROM (SELECT SUM(E2.Salary)
		FROM Employee E2
        WHERE E2.BranchID = Employee.BranchID) AS X)) > 100000 THEN salary * 1.05
ELSE salary * 0.98
END;

-- Query 4
SELECT C.CouponCode, LEAST(C.Discount_Rate * 1000/100, C.Maximum_Discount) AS Discount
FROM Coupon C
WHERE LEAST(C.Discount_Rate * 1000/100, C.Maximum_Discount) = 
	(SELECT MAX(LEAST(C2.Discount_Rate * 1000/100, C2.Maximum_Discount))
	FROM Coupon C2
	WHERE C2.Valid_Till > CURDATE());

-- Query 5
SELECT Q.QuestionID, Q.Question_Statement, A.Answer
FROM QnA Q, Answer A
WHERE Q.QuestionID = A.QuestionID AND A.EmployeeID NOT IN (
    SELECT M.EmployeeID
    FROM Manager M
    GROUP BY M.BranchID
    HAVING MAX(Date_of_Appointment)
);

-- Query 6
SELECT COUNT(*) AS Damaged_Or_Used
FROM (
	SELECT DISTINCT PL.ProductID
	FROM Purchase_List PL
	WHERE PL.PurchaseID IN (
		SELECT DISTINCT PurchaseID
		FROM Offline_Return OfR
		WHERE OfR.Reason_for_Return LIKE '%damaged%' OR OfR.Reason_for_Return LIKE '%used%'
	)
) AS T;

-- Query 7
SELECT Q.QuestionID, Q.Question_Statement
FROM QnA Q, Product P
WHERE Q.ProductID = P.ProductID AND P.Product_type = 'Clothing' AND NOT EXISTS
	(SELECT A.QuestionID
	FROM Answer A
	WHERE A.QuestionID = Q.QuestionID);

-- Query 8
SELECT S.SupplierID, Sp.Supplier_Name
FROM Supplies S, Supplier Sp
WHERE S.SupplierId = Sp.SupplierID AND S.BranchID = 18 AND S.Date_of_Supply >= '2019-01-01' AND S.Date_of_Supply <= '2019-01-31';

-- Query 9
SELECT B.BranchID, S.Barcode
FROM Branch B, Stock S
WHERE B.BranchID = S.BranchID AND EXISTS
	(SELECT EB.Barcode
	FROM Expirable_Barcodes EB
	WHERE EB.Barcode = S.Barcode AND EB.Expiry_date <= '2021-08-01');

-- Query 10
SELECT B.BranchID, SUM(E.Salary) AS Total_Salary
FROM Branch B, Employee E
WHERE E.BranchID = B.BranchID AND NOT EXISTS 
	(SELECT M.EmployeeID
	FROM Manager M
	WHERE M.EmployeeID = E.EmployeeID)
GROUP BY B.BranchID;

-- Query 11
(SELECT OP.CustomerID
FROM Offline_Purchase OP, Purchase_List PL
WHERE OP.PurchaseID = PL.PurchaseID AND EXISTS
	(SELECT P.ProductID
	FROM Product P
	WHERE P.ProductID = PL.ProductID AND P.Product_type = 'Books'))
UNION
(SELECT A.CustomerID
FROM Account A, OnlineOrder OO, Order_List OL
WHERE A.LoginID = OO.LoginID AND OO.OrderId = Ol.OrderID AND EXISTS
	(SELECT P.ProductID
	FROM Product P
	WHERE P.ProductID = OL.ProductID AND P.Product_type = 'Books'));

-- Query 12
SELECT A.LoginID
FROM Account A
Where A.Bazaar_coins <
	(SELECT SUM(P.Product_MRP * C.Quantity)
	FROM Product P, Cart C
	WHERE C.LoginID = A.LoginID AND C.ProductID = P.ProductID);

-- Query 13
SELECT DISTINCT R.Product_Preview
FROM Review R, Product P
WHERE P.ProductID = R.ProductID AND R.Stars = 1 AND P.Product_Name = 'Lettuce - Sea / Sea Asparagus';

-- Query 14
SELECT P.ProductID, P.Product_Name
FROM Product P
WHERE P.Product_Name LIKE '%Bread%';

-- Query 15
CREATE VIEW wishlist_Product_details AS
SELECT wishlist.loginID, wishlist.ProductID, Product.Product_Name, Product_type, Product_MRP
FROM wishlist, Product
WHERE wishlist.ProductID = Product.ProductID;

select * from wishlist_Product_details;

-- Query 16
CREATE VIEW List_ids_with_coupon_details AS
SELECT available_coupon.LoginID, coupon.CouponCode, coupon.Valid_Till, coupon.Discount_Rate, coupon.Maximum_Discount
FROM coupon, available_coupon
WHERE coupon.CouponCode = available_coupon.CouponCode;

select * from List_ids_with_coupon_details;