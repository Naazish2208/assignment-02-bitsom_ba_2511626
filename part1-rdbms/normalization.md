## Anomaly Analysis

Since this single table combines customers, products, and sales reps into every order row, here is how the three anomalies occur using your specific columns:

1. Insert Anomaly
This happens when you want to add new data to the system but can't because an order_id doesn't exist yet.
Example: Your company hires a new sales representative, "Neha Sharma" You want to add her name, email, and office address to the database. However, because this is an "Orders" table, you cannot add Neha to the system until she makes her first sale. You can't have a rep without an order_id.

2. Update Anomaly
This happens when the same information is repeated in many rows, making it hard to keep data consistent.
Example: Suppose you need to change the unit_price of the "Mouse" from Rs. 800 to Rs. 910. If that mouse has been sold 500 times, you must find and update all 500 rows. If you miss even one row, your database will show two different prices for the exact same product, leading to billing errors.

3. Delete Anomaly
This happens when deleting a specific record unintentionally destroys other unrelated, important information.
Example: In Row 13 we can see that Customer C003 is the only person who has ever bought the "Webcam" (product_id: P008). If that customer cancels their order and you delete that row to clean up your data, you don't just lose the order—you also lose all record of the "Webcam," its category, and its price from your entire system.

## Normalization Justification

The manager's position is understandable but ultimately flawed. While a single flat table feels simpler at first glance, it introduces serious data quality problems that compound over time. The orders_flat dataset illustrates this clearly.

Consider Deepak Joshi, who appears across dozens of rows in the flat table. If his office address changes from "Mumbai HQ, Nariman Point" to a new location, every single one of those rows needs to be updated manually. Miss even one, and the database now holds two conflicting addresses for the same person — this is an update anomaly. In the normalized design, his address lives in exactly one row in sales_reps, so a single UPDATE fixes it everywhere instantly.

The same problem applies to products. The Laptop is priced at ₹55,000 and appears in over 40 orders. In the flat table, that price is repeated 40+ times. A price correction means 40+ updates — and any inconsistency means some orders would reference the old price and others the new one, silently corrupting sales reporting. In the normalized design, unit_price lives once in the products table.
Insertion anomalies are equally damaging. In the flat table, you cannot record a new product like a "Monitor" until someone actually places an order for it, because product data has no independent home. Normalization solves this — a product can be added to the products table the moment it enters the catalogue, independent of any order activity.

Finally, the flat table stores redundant data at scale. With 187 orders, customer and product details are duplicated hundreds of times, inflating storage unnecessarily. Normalization is not over-engineering — it is the difference between a database that stays reliable as data grows and one that quietly accumulates errors.
