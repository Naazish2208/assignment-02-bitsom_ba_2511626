// =============================================================================
// mongo_queries.js
// MongoDB operations based on sample_documents.json
// Database: shopdb | Collection: products
// =============================================================================

// OP1: insertMany() — insert all 3 documents from sample_documents.json
// Inserts the Samsung TV (Electronics), Urban Trail Jacket (Clothing), and
// Quaker Organic Oats (Groceries) documents into the products collection.
// ObjectId strings are passed as-is; MongoDB will store them as ObjectId types.
db.products.insertMany([
  {
    category: "Electronics",
    sku: "ELEC-TV-4K-001",
    name: 'Samsung 55" 4K QLED Smart TV',
    brand: "Samsung",
    price: 74999.00,
    currency: "INR",
    stock: 42,
    specifications: {
      display: {
        size_inches: 55,
        resolution: "3840x2160",
        panel_type: "QLED",
        refresh_rate_hz: 120,
        hdr_support: ["HDR10+", "HLG"]
      },
      dimensions: {
        width_cm: 123.5,
        height_cm: 71.4,
        depth_cm: 6.9,
        weight_kg: 17.2
      },
      power: {
        voltage: "100-240V AC",
        frequency_hz: "50/60Hz",
        wattage: 130
      }
    },
    warranty: {
      duration_years: 2,
      type: "Comprehensive",
      provider: "Samsung India"
    },
    ratings: { average: 4.6, count: 1283 },
    created_at: new Date("2024-01-15T08:00:00Z"),
    updated_at: new Date("2025-03-01T12:30:00Z")
  },
  {
    category: "Clothing",
    sku: "CLTH-JKT-WIN-007",
    name: "Urban Trail Men's Quilted Winter Jacket",
    brand: "Urban Trail",
    price: 3499.00,
    currency: "INR",
    stock: 210,
    variants: [
      {
        color: "Navy Blue",
        color_hex: "#1B2A4A",
        sizes_available: [
          { size: "S",  stock: 18 },
          { size: "M",  stock: 35 },
          { size: "L",  stock: 40 },
          { size: "XL", stock: 22 }
        ]
      },
      {
        color: "Jet Black",
        color_hex: "#0A0A0A",
        sizes_available: [
          { size: "S",  stock: 10 },
          { size: "M",  stock: 30 },
          { size: "L",  stock: 28 },
          { size: "XL", stock: 27 }
        ]
      }
    ],
    specifications: {
      fabric: {
        outer: "100% Nylon Ripstop",
        inner_lining: "80% Polyester, 20% Spandex",
        fill: "650-fill Recycled Down"
      },
      features: [
        "Water-resistant DWR coating",
        "Packable into chest pocket",
        "YKK zippers",
        "Adjustable hem drawcord",
        "Fleece-lined collar"
      ],
      fit_type: "Regular Fit",
      season: ["Autumn", "Winter"]
    },
    size_chart: {
      unit: "cm",
      measurements: [
        { size: "S",  chest: 94,  shoulder: 43, length: 68 },
        { size: "M",  chest: 100, shoulder: 45, length: 70 },
        { size: "L",  chest: 106, shoulder: 47, length: 72 },
        { size: "XL", chest: 112, shoulder: 49, length: 74 }
      ]
    },
    ratings: { average: 4.4, count: 587 },
    created_at: new Date("2024-06-10T10:15:00Z"),
    updated_at: new Date("2025-02-20T09:00:00Z")
  },
  {
    category: "Groceries",
    sku: "GROC-OATS-ORG-012",
    name: "Quaker Organic Rolled Oats",
    brand: "Quaker",
    price: 349.00,
    currency: "INR",
    stock: 875,
    packaging: {
      weight_grams: 1000,
      type: "Resealable Pouch",
      recyclable: true
    },
    dates: {
      manufactured_on: new Date("2025-01-10T00:00:00Z"),
      best_before: new Date("2026-01-09T23:59:59Z"),
      shelf_life_days: 365
    },
    storage_instructions: "Store in a cool, dry place. Seal tightly after opening. Consume within 30 days of opening.",
    nutritional_info: {
      serving_size_grams: 40,
      servings_per_pack: 25,
      per_serving: {
        calories_kcal: 148,
        total_fat_g: 2.7,
        saturated_fat_g: 0.5,
        trans_fat_g: 0.0,
        cholesterol_mg: 0,
        sodium_mg: 2,
        total_carbohydrates_g: 25.3,
        dietary_fiber_g: 3.8,
        total_sugars_g: 0.5,
        added_sugars_g: 0.0,
        protein_g: 5.2,
        vitamins_and_minerals: {
          iron_mg: 1.8,
          calcium_mg: 22,
          potassium_mg: 142,
          magnesium_mg: 44
        }
      }
    },
    ingredients: ["Organic Whole Grain Rolled Oats"],
    allergens: {
      contains: ["Gluten"],
      may_contain_traces_of: ["Wheat", "Soy", "Tree Nuts"],
      free_from: ["Dairy", "Eggs", "Peanuts"]
    },
    dietary_flags: {
      vegan: true,
      vegetarian: true,
      gluten_free: false,
      organic: true,
      non_gmo: true,
      kosher: false,
      halal: true
    },
    ratings: { average: 4.8, count: 3140 },
    created_at: new Date("2025-01-12T06:00:00Z"),
    updated_at: new Date("2025-03-05T14:00:00Z")
  }
]);


// -----------------------------------------------------------------------------
// OP2: find() — retrieve all Electronics products with price > 20000
// Filters by category "Electronics" AND price greater than 20000 INR.
// Projection returns only the key commercial fields; _id is included by default.
// -----------------------------------------------------------------------------
db.products.find(
  {
    category: "Electronics",
    price: { $gt: 20000 }
  },
  {
    name: 1,
    brand: 1,
    sku: 1,
    price: 1,
    currency: 1,
    stock: 1,
    "ratings.average": 1
  }
);


// -----------------------------------------------------------------------------
// OP3: find() — retrieve all Groceries expiring before 2026-01-01
// Targets the nested field dates.best_before with a $lt date comparison.
// Note: the Quaker Oats document has a best_before of 2026-01-09, so it will
// NOT appear in results — this query is intentionally strict to demonstrate
// correct date filtering on nested date fields.
// To instead catch items expiring before end of 2026, change the date below
// to new Date("2027-01-01T00:00:00Z").
// -----------------------------------------------------------------------------
db.products.find(
  {
    category: "Groceries",
    "dates.best_before": { $lt: new Date("2026-01-01T00:00:00Z") }
  },
  {
    name: 1,
    sku: 1,
    "dates.best_before": 1,
    "dates.shelf_life_days": 1,
    stock: 1
  }
);


// -----------------------------------------------------------------------------
// OP4: updateOne() — add a "discount_percent" field to a specific product
// Targets the Samsung TV by its SKU (a stable, human-readable unique key).
// $set adds the new field without touching any other existing fields.
// Also bumps updated_at to reflect the time of this change.
// -----------------------------------------------------------------------------
db.products.updateOne(
  { sku: "ELEC-TV-4K-001" },
  {
    $set: {
      discount_percent: 10,
      updated_at: new Date()
    }
  }
);


// -----------------------------------------------------------------------------
// OP5: createIndex() — create an index on the category field
//
// WHY: Nearly every query in this collection filters by `category` (e.g. OP2
// and OP3 above). Without an index, MongoDB performs a full collection scan
// (COLLSCAN) for every such query — O(n) cost that grows as the catalogue
// scales to thousands of SKUs. A single-field ascending index on `category`
// lets MongoDB use an index scan (IXSCAN), dramatically reducing the number
// of documents examined and improving read latency across all category-scoped
// queries. The `background: true` option (pre-4.2 style, kept for broad
// compatibility) builds the index without blocking other read/write operations.
// -----------------------------------------------------------------------------
db.products.createIndex(
  { category: 1 },           // 1 = ascending; sufficient for equality & sort
  {
    name: "idx_category_asc",
    background: true          // non-blocking build; ignored in MongoDB 4.2+ (always background)
  }
);

// Verify the index was created:
db.products.getIndexes();
