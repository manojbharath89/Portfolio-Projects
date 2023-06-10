use marketing_campaign_analysis;

-- Different color segments (categories) provided by the company.
SELECT COUNT(DISTINCT(item_category)) AS categories_count
FROM item;

-- Different Coupon Types that are offered.
SELECT COUNT(DISTINCT(coupon_type)) AS coupontypes_count
FROM coupon_mapping;

-- States where the company is currently delivering its products and services.
SELECT COUNT(DISTINCT(state)) AS states_count
FROM city_data;

-- Different Order Types.
SELECT COUNT(DISTINCT(order_type)) AS ordertypes_count
FROM customer_transaction_data;


-- Standardize Date Format
-- Total number of sales (transactions) happened by Yearly basis
SELECT
	YEAR(CONVERT(VARCHAR, purchase_date, 23)) as date_formatted
FROM customer_transaction_data;

SELECT
    YEAR(CONVERT(VARCHAR, purchase_date, 23)) AS purchase_year,
    COUNT(trans_id) AS Total_Trans
FROM customer_transaction_data
GROUP BY YEAR(CONVERT(VARCHAR, purchase_date, 23));

-- Identify total number of sales (transactions) happened by Quarterly basis
SELECT
	DATEPART(QUARTER, purchase_date) AS purchase_quarter,
    COUNT(trans_id) AS total_trans
FROM customer_transaction_data
GROUP BY DATEPART(QUARTER, purchase_date)
ORDER BY total_trans DESC;

-- Total number of sales (transactions) happened by Yearly and Monthly basis
SELECT
	DATEPART(YEAR, purchase_date) AS purchase_year,
    DATEPART(QUARTER, purchase_date) AS purchase_quarter,
    COUNT(trans_id) as total_trans
FROM customer_transaction_data
GROUP BY DATEPART(YEAR, purchase_date), DATEPART(QUARTER, purchase_date)
ORDER BY purchase_year, purchase_quarter;

-- The total purchase order by product category
SELECT
	ROUND(SUM(ctd.purchasing_amt), 2) AS total_purchase_order,
    item_category
FROM item AS i
INNER JOIN customer_transaction_data AS ctd
ON i.item_id = ctd.item_id
GROUP BY item_category
ORDER BY total_purchase_order DESC;

-- The total purchase order by Yearly and Quarterly basis
SELECT
	ROUND(SUM(ctd.purchasing_amt), 2) AS total_purchase_order,
    YEAR(ctd.purchase_date) AS purchase_year,
    DATEPART(QUARTER, ctd.purchase_date) AS purchase_quarter
FROM item as i
INNER JOIN customer_transaction_data as ctd
ON ctd.item_id = i.item_id
GROUP BY YEAR(ctd.purchase_date), DATEPART(QUARTER, ctd.purchase_date)
ORDER BY total_purchase_order DESC;

-- The total purchase order by Order Type
SELECT
	ROUND(SUM(ctd.purchasing_amt), 2) AS total_purchase_order,
    ctd.order_type
FROM item as i
INNER JOIN customer_transaction_data as ctd
ON ctd.item_id = i.item_id
GROUP BY ctd.order_type
ORDER BY total_purchase_order DESC;

-- The total purchase order by City Tier
SELECT
	ROUND(SUM(ctd.purchasing_amt), 2) AS total_purchase_order,
	cd.city_tier
FROM item AS i
INNER JOIN customer_transaction_data as ctd
ON ctd.item_id = i.item_id
INNER JOIN customer AS c
ON c.customer_id = ctd.cust_id
INNER JOIN city_data AS cd
ON c.city_id = cd.city_id
GROUP BY cd.city_tier
ORDER BY total_purchase_order DESC;


-- Company wants to understand the customer path to conversion as a potential purchaser based on our campaigns.
-- The total number of transactions with campaign coupon vs total number of transactions without campaign coupon.
SELECT
	'Without Coupons' AS CampaignCoupons,
	COUNT(*) AS TotalTransactions FROM customer_transaction_data
WHERE campaign_id IS NULL
UNION ALL
SELECT 'With Coupons' AS CampaignCoupons,
COUNT(*) AS TotalTransactions FROM customer_transaction_data
WHERE campaign_id IS NOT NULL;

-- The number of customers with first purchase done with or without campaign coupons .
SELECT
	COUNT(coupon_id) AS TotalCustomersFirstPurchaseWcoupon,
	COUNT(*) - COUNT(coupon_id) AS TotalCustomersFirstPurchaseWithoutcoupon
FROM customer_transaction_data
WHERE trans_id IN (SELECT
						FIRST_VALUE(trans_id) OVER(PARTITION BY cust_id ORDER BY purchase_date RANGE BETWEEN
						UNBOUNDED PRECEDING AND
						UNBOUNDED FOLLOWING) AS trans_id
					FROM customer_transaction_data);

-- The impact of campaigns on users.
-- The total number of unique users making purchases with or without campaign coupons.
SELECT
	'Without Coupons' AS CampaignCoupons,
	COUNT(DISTINCT cust_id) AS UniqueUsers FROM customer_transaction_data
WHERE campaign_id IS NULL
UNION ALL
SELECT
	'With Coupons' AS CampaignCoupons,
	COUNT(DISTINCT cust_id) AS UniqueUsers FROM customer_transaction_data
WHERE campaign_id IS NOT NULL;

-- The purchase amount with campaign coupons vs normal coupons vs no coupons. The order based on the amount:
SELECT
	'Normal Coupons' AS CampaignCoupons,
	SUM(purchasing_amt) AS TotalPurchase FROM customer_transaction_data
WHERE campaign_id IS NULL AND coupon_id IS NOT NULL
UNION ALL
SELECT
	'Campaign Coupons' AS CampaignCoupons,
	SUM(purchasing_amt) AS TotalPurchase FROM customer_transaction_data
WHERE campaign_id IS NOT NULL
UNION ALL
SELECT
	'No Coupons' AS CampaignCoupons,
	SUM(purchasing_amt) AS TotalPurchase FROM customer_transaction_data
WHERE coupon_id IS NULL;

/* Based on the above analysis, we can definitely say that campaigns are effective in bringing more customers as well as being able to convert them.
People are buying our product more with the help of coupons provided to them so overall it’s a success. */

-- Marketing team is interested in understanding the growth and decline pattern of the company in terms of new leads or sales amount by the customers.
-- The total growth on a year-over-year basis based on quantity of paint that's sold.
SELECT *
FROM (SELECT
		year_purchase, Total_Quantity AS Total_Quantity_2022, 
		LAG(Total_Quantity) OVER(ORDER BY year_purchase) AS pastoffset_1,
		LAG(Total_Quantity,2) OVER(ORDER BY year_purchase) AS pastoffset_2,
		LAG(Total_Quantity,3) OVER(ORDER BY year_purchase) AS pastoffset_3
FROM(SELECT
		DATEPART(YEAR, purchase_date) AS year_purchase,
		SUM(Quantity) AS Total_Quantity 
	FROM customer_transaction_data
	WHERE DATEPART(YEAR, purchase_date) < 2023
	GROUP BY DATEPART(YEAR, purchase_date)) AS T) AS T
WHERE year_purchase = 2022;

-- The total growth on a year-over-year basis based on amount of paint that's sold.
SELECT *
FROM (
SELECT
	year_purchase, Total_Quantity AS Total_Quantity_2022, 
	LAG(Total_Quantity) OVER(ORDER BY year_purchase) AS pastoffset_1,
	LAG(Total_Quantity,2) OVER(ORDER BY year_purchase) AS pastoffset_2,
	LAG(Total_Quantity,3) OVER(ORDER BY year_purchase) AS pastoffset_3
FROM(
SELECT
	DATEPART(YEAR, purchase_date) AS year_purchase,
	SUM(Quantity) AS Total_Quantity 
FROM customer_transaction_data
  WHERE DATEPART(YEAR, purchase_date) < 2023
GROUP BY DATEPART(YEAR, purchase_date)) AS T) AS T
WHERE year_purchase = 2022;

-- Customers that's acquired [New + Repeated]
SELECT *
FROM (
SELECT
	year_purchase,
	NewUsers AS NewUsers_2022, 
	LAG(NewUsers) OVER(ORDER BY year_purchase) AS pastoffset_1,
	LAG(NewUsers,2) OVER(ORDER BY year_purchase) AS pastoffset_2,
	LAG(NewUsers,3) OVER(ORDER BY year_purchase) AS pastoffset_3
FROM(
SELECT
	DATEPART(YEAR, purchase_date) AS year_purchase,
	COUNT(DISTINCT Cust_Id) AS NewUsers
FROM customer_transaction_data
  WHERE DATEPART(YEAR, purchase_date) < 2023
GROUP BY DATEPART(YEAR, purchase_date)) AS T) AS T
WHERE year_purchase = 2022;


-- Segregate the above by order_type and select from the below options based on a number of customers.
SELECT *
FROM (
SELECT
	year_purchase,
	order_type,
	NewUsers AS NewUsers_2022, 
	LAG(NewUsers) OVER(PARTITION BY order_type ORDER BY year_purchase) AS pastoffset_1,
	LAG(NewUsers,2) OVER(PARTITION BY order_type ORDER BY year_purchase) AS pastoffset_2,
	LAG(NewUsers,3) OVER(PARTITION BY order_type ORDER BY year_purchase) AS pastoffset_3
FROM(
SELECT
	DATEPART(YEAR, purchase_date) AS year_purchase,
	order_type,
	COUNT(DISTINCT Cust_Id) AS NewUsers
FROM customer_transaction_data
WHERE DATEPART(YEAR, purchase_date) < 2023
GROUP BY DATEPART(YEAR, purchase_date), order_type) AS T) AS T
WHERE year_purchase = 2022;

/* Based on the above results, we can see that the overall growth has declined in the past 1 year compared to recent years.
It's very apparent from total quantities sold, total sales as well as customers acquired. */

-- The total decline, if any, within the total sales amount on a year-over-year basis.
-- Comment on whether we need to launch a campaign for the consumers based on the recent pattern.
SELECT *
FROM (
	SELECT
		year_purchase,
		Total_Purchase,
		Total_Purchase - LAG(Total_Purchase) OVER(ORDER BY year_purchase) AS Profit_Loss_W_PreviousYear
	FROM(
	SELECT
		DATEPART(YEAR, purchase_date) AS year_purchase,
		SUM(purchasing_amt) AS Total_Purchase
	FROM customer_transaction_data
	WHERE DATEPART(YEAR, purchase_date) < 2023
	GROUP BY DATEPART(YEAR, purchase_date)) AS T) AS T;


-- Distinct Campaign Types 
SELECT DISTINCT campaign_type FROM campaign;

/* A market basket analysis is defined as a customer’s overall buying pattern of different sets of products.
Essentially, the marketing team wants to understand customer purchasing patterns.
Their proposal is if they promote the products in their next campaign, which are bought a couple of times together, then this will increase the revenue for the company. */

-- The dates when the same customer has purchased some product from the company outlets.
SELECT
	C1.cust_id,
	C1.purchase_date AS PurchaseDate1,
	C2.purchase_date AS PurchaseDate
FROM customer_transaction_data AS C1
FULL OUTER JOIN customer_transaction_data AS C2
ON C1.cust_id = C2.cust_id WHERE C1.trans_id != C2.trans_id AND C1.order_type = C2.order_type AND C1.item_id != C2.item_id;

-- The same combination of products coming at least thrice sorted in descending order of their appearance.
SELECT
	CONCAT(C1.item_id, ',', C2.item_id) AS Item_Combination,
    COUNT(*) AS TotalTransaction,
    C1.order_type AS Sector
FROM customer_transaction_data AS C1
INNER JOIN customer_transaction_data AS C2
ON C1.cust_Id = C2.cust_Id
WHERE C1.trans_id != C2.trans_id 
	AND C1.order_type = C2.order_type
	AND C1.item_id != C2.item_id
GROUP BY CONCAT(C1.item_id, ',', C2.item_id), C1.order_type
HAVING COUNT(*) >= 3
ORDER BY COUNT(*) DESC;