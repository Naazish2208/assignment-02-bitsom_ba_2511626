## ETL Decisions

Decision 1 — Standardising Mixed Date Formats

Problem: The date column in the source data contained three different formats across rows — DD/MM/YYYY (e.g. 29/08/2023), DD-MM-YYYY (e.g. 12-12-2023), and ISO YYYY-MM-DD (e.g. 2023-02-05). Loading these as-is would cause incorrect date parsing or outright failures depending on the SQL engine's assumed default format.

Resolution: All dates were parsed using a format-agnostic date parser (dateutil.parser with dayfirst=True) and uniformly converted to ISO 8601 YYYY-MM-DD before being mapped to date_key (YYYYMMDD integer). This ensures consistent ordering and correct quarter, month, and day_of_week derivations in dim_date.

Decision 2 — Imputing NULL Values in store_city

Problem: 19 rows in the source CSV had NULL in the store_city column. Leaving these NULL would make store-level geographic reporting (e.g. revenue by city or region) incomplete and unreliable.

Resolution: Since store_name was always populated and the store-to-city mapping is fixed (e.g. Chennai Anna → Chennai), the city was deterministically imputed using that mapping. The corrected city values are baked into dim_store, so the fact table never needs to carry or validate city directly — it inherits the clean value through the foreign key join.

Decision 3 — Normalising Inconsistent Category Values

Problem: The category column had five distinct raw values representing only three actual categories: electronics and Electronics were the same category with inconsistent casing, while Grocery and Groceries were the same category with inconsistent naming. This would cause any GROUP BY category query to return duplicate groups and split revenue figures.

Resolution: All five variants were mapped to three canonical values — Electronics, Grocery, and Clothing — before loading into dim_product. Normalisation was applied at the dimension level rather than the fact level, so any future transactions loading into fact_sales inherit the clean category automatically through the product_key foreign key.
