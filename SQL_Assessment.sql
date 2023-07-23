USE kpim_retail
GO

select *
from dbo.city

select  *
from dbo.region

select *
from dbo.sub_region

select * 
from dbo.store

select *
from dbo.district

select *
from dbo.ward

SELECT id, code, name, sub_region_id
from dbo.city

select EOMONTH (transaction_date) as end_date_of_month, sum (total_amount) as sales_amount
from dbo.pos_sales_header
group by eomonth (transaction_date)
order by end_date_of_month

-- Cau 1
SELECT *
from dbo.city
where name = N'Hà Nội'

-- Cau 2
SELECT name
FROM dbo.city
WHERE code = 'HTH'

-- Cau 3
-- Calculate the total number of provinces in Vietnam
SELECT COUNT (DISTINCT c.name) AS TotalProvinces
FROM dbo.city c 
JOIN dbo.sub_region sr on c.sub_region_id = sr.id

-- Calculate the number of provinces in "Đồng bằng sông Hồng" and "Đồng bằng sông Cửu Long" areas
WITH ProvincesInAreas AS (
    SELECT COUNT (DISTINCT c.name) AS ProvincesInAreasCount
    FROM dbo.city c 
    JOIN dbo.sub_region sr on c.sub_region_id = sr.id
    WHERE sr.name IN (N'Đồng bằng sông Hồng', N'Đồng bằng sông Cửu Long')
)
SELECT ProvincesInAreasCount, TotalProvinces, 
        (ProvincesInAreasCount * 100.0)/ TotalProvinces AS Percentage
FROM ProvincesInAreas, (
    SELECT COUNT (DISTINCT c.name) AS TotalProvinces
    FROM dbo.city c 
    JOIN dbo.sub_region sr on c.sub_region_id = sr.id
) AS TotalProvinces;

    

-- Cau 4
select count (distinct name)
from dbo.city
where name like N'Quảng%'


-- Cau 5
select c.name, c.id
from dbo.city c
join dbo.sub_region sr on c.sub_region_id = sr.id
where sr.name = N'Đồng bằng sông Hồng'


-- Cau 6
select count (c.name)
from dbo.city c 
join dbo.sub_region sr on sr.id = c.sub_region_id
join dbo.region r on r.id = sr.region_id
where r.name = N'Miền Trung'


-- Cau 7 
SELECT COUNT (s.name) AS NbStores, s.district_id, d.name
FROM dbo.store s 
JOIN dbo.city c on c.id = s.city_id
JOIN dbo.district d on d.id = s.district_id
GROUP BY s.district_id, d.name 
ORDER BY COUNT (s.name) DESC 


-- Cau 8
select count (name), ward_id
from dbo.store
group by ward_id
having count (name) > 10

SELECT COUNT (s.name) AS NbStores, s.ward_id, w.name
FROM dbo.store s 
JOIN dbo.city c on c.id = s.city_id
JOIN dbo.district d on d.id = s.district_id
JOIN dbo.ward w on w.id = s.ward_id
WHERE s.city_id = 24
GROUP BY s.ward_id, w.name 
HAVING COUNT (s.name) >10 


-- Cau 9

select count (id), district_id
from dbo.ward 
group by district_id
order by count (id) desc

select name 
from dbo.district
where id in ('7','14')

select s.district_id, count (distinct s.name)/count (distinct w.id) as Ratio
from dbo.store s, dbo.ward w, dbo.district d 
where d.id = w.district_id
and w.id = s.ward_id
group by s.district_id
order by Ratio desc

WITH TotalStores AS (
    SELECT COUNT (DISTINCT s.name) AS TotalStoresCount
    FROM dbo.store s 
    JOIN dbo.city c on c.id = s.city_id
    JOIN dbo.district d on d.id = s.district_id
    JOIN dbo.ward w on w.id = s.ward_id
    GROUP BY s.city_id, w.id
)
SELECT TotalStoresCount, TotalWards, (TotalStoresCount * 100.0)/ TotalWards AS Ratio, d.name 
FROM dbo.district d, TotalStores,  (
    SELECT COUNT (DISTINCT s.ward_id) AS TotalWards
    FROM dbo.store s 
    JOIN dbo.city c on c.id = s.city_id
    JOIN dbo.district d on d.id = s.district_id
    JOIN dbo.ward w on w.id = s.ward_id
    GROUP BY s.district_id, d.name
) AS TotalWards 
ORDER BY Ratio DESC



-- Cau 10
DECLARE @lat1 FLOAT, @long1 FLOAT;
SELECT @lat1 = latitude, @long1 = longitude
FROM dbo.store
WHERE code = 'VMHNI60';

SELECT TOP 3 code, latitude, longitude,
       dbo.fnc_calc_haversine_distance(@lat1, @long1, latitude, longitude) AS distance
FROM dbo.store
WHERE code != 'VMHNI60'
ORDER BY distance;

-- Short Answer

-- Cau 11
SELECT r.code AS region_code, r.name AS region_name, 
    sr.code AS sub_region_code, sr.name AS sub_region_name, 
    c.id AS city_id, c.code AS city_code, c.name AS city_name
FROM dbo.city c 
JOIN dbo.sub_region sr ON sr.id = c.sub_region_id
JOIN dbo.region r ON r.id = sr.region_id 
WHERE r.code = 'MB'
ORDER BY sub_region_code ASC, region_name ASC, city_name ASC

--Cau 12
select TOP (100) *
from dbo.customer 

select TOP (100) *
from dbo.pos_sales_header

select TOP (100) *
from dbo.pos_sales_line

select TOP (100) *
from dbo.purchase_header

SELECT DISTINCT c.id AS id, c.code AS code, c.full_name AS full_name, c.first_name AS first_name, SUM (h.total_amount) AS total_amount
FROM dbo.customer c
JOIN dbo.pos_sales_header h ON c.id = h.customer_id
JOIN dbo.store s ON s.id = h.store_id
WHERE s.district_id = '1'
AND total_amount > 10000000
AND h.transaction_date >= '2020-10-01' AND h.transaction_date <= '2020-10-20'
GROUP BY c.id, c.code, c.full_name, c.first_name
ORDER BY total_amount DESC, c.full_name ASC


-- Cau 13 -- CASE WHEN 
SELECT s.document_code, s.store_id, st.code, st.name, s.transaction_date, c.id, c.full_name,
    c.first_name, SUM (s.total_amount) AS total_amount,
    CASE WHEN 0.5 * SUM (s.total_amount) >= 1000000 THEN 1000000 ELSE 0.5 * SUM (s.total_amount) END AS promotion_amount
FROM dbo.pos_sales_header s 
JOIN dbo.customer c ON c.id = s.customer_id
JOIN dbo.store st ON s.store_id = st.id
WHERE s.transaction_date BETWEEN '2020-08-31' AND '2020-09-06'
AND s.document_code IN ('SO-VMHNI4-202009034389708', 'SO-VMHNI109-202008316193214', 
        'SO-VMHNI51-202008316193066', 'SO-VMHNI64-202008316193112', 'SO-VMHNI48-202009016193491')
GROUP BY c.id, c.full_name, s.document_code, s.store_id, st.code, st.name, s.transaction_date, c.first_name
ORDER BY promotion_amount DESC 


-- Cau 14
SELECT p.id AS product_sku_id, l.customer_id, SUM (l.unit_price * l.quantity) AS purchase_amount,
    SUM (l.quantity) AS quantity, COUNT (*) AS nb_purchases, AVG (l.quantity) AS avg_quantity_per_purchases
FROM dbo.pos_sales_line l 
JOIN dbo.product_sku p ON l.product_sku_id = p.id
WHERE p.name = N'Cháo Yến Mạch, Chà Là Và Hồ Đào | Herritage Mill, Úc (320 G)'
AND YEAR (l.transaction_date) = 2020
GROUP BY l.customer_id, p.id
ORDER BY l.customer_id ASC

-- Cau 15
SELECT TOP (20) YEAR (l.transaction_date) AS year, p.id AS product_sku_id, p.code, p.name, p.country, p.brand, l.unit_price, 
    SUM (l.quantity) AS quantity, RANK () OVER (PARTITION BY YEAR (l.transaction_date) ORDER BY SUM (l.unit_price*quantity) DESC) AS rk
FROM dbo.product_sku p 
JOIN dbo.pos_sales_line l ON l.product_sku_id = p.id
JOIN dbo.product_subcategory s ON s.id = p.product_subcategory_id
JOIN dbo.product_category c ON c.id = s.product_category_id
WHERE p.product_subcategory_id = 19
AND YEAR (l.transaction_date) IN ('2019', '2020')
AND (p.name LIKE '%Mì%' OR p.name LIKE '%Mỳ%')
GROUP BY p.id, p.code, p.name, p.country, p.brand, l.unit_price, YEAR (l.transaction_date)
ORDER BY YEAR (l.transaction_date) DESC, rk ASC


-- Cau 16
SELECT s.day_work, s.store_id, st.name, s.shift_name, s.sales_person_id, p.code, p.full_name, p.first_name, p.gender
FROM dbo.emp_shift_schedule s 
JOIN dbo.sales_person p ON p.id = s.sales_person_id
JOIN dbo.store st ON st.id = s.store_id
WHERE s.shift_name = N'Chiều'
AND st.name = N'VM+ HNI Cụm 6 Xã Sen Chiểu'
AND s.day_work = '2020-06-13'

-- Cau 17


-- Cau 18


-- Cau 19


-- Cau 20
SELECT TOP (3) h.store_id, s.code AS store_code, s.name AS store_name, SUM (h.total_line_amount) AS sales_amount_10_2020
FROM dbo.store s 
JOIN dbo.pos_sales_header h ON s.id = h.store_id
WHERE h.transaction_date BETWEEN '2020-10-01' AND '2020-10-31'
AND s.city_id = 24
GROUP BY h.store_id, s.code, s.name 
ORDER BY sales_amount_10_2020


