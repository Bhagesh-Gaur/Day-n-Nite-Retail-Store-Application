CREATE EVENT remove_expired_products
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY)
DO
DELETE FROM Stock
WHERE Stock.Barcode IN (
		SELECT EB.Barcode
FROM Expirable_Barcodes EB
        	WHERE EB.Expiry_date < CURDATE()
	);

CREATE TRIGGER update_stock_after_purchase
AFTER INSERT
ON Purchase_List FOR EACH ROW
	UPDATE Stock
    	SET Stock.Quantity = Stock.Quantity - NEW.Quantity
    	WHERE Stock.BranchID IN (
		SELECT OP.BranchID
        	FROM Offline_Purchase OP
        	WHERE OP.PurchaseID = NEW.PurchaseID
	);
