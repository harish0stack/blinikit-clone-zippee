-- Seed data for Blinkit Clone MVP

INSERT INTO vendors (id, business_name, gstin, status)
VALUES ('00000000-0000-0000-0000-000000000001', 'Blinkit Central Dark Store', '27AABCU9603R1ZM', 'approved')
ON CONFLICT (id) DO UPDATE SET business_name = EXCLUDED.business_name;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('5d625204-618f-5b86-8933-ab22149f4c08', 'Drinks &
Juices', 'cat_drinks', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/diet_coke.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/coke.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/sprite.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/coca_cola.png"]', 'bestseller', 240, 0, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('8345c652-d10a-58ea-b54f-6f9c4aca98b8', 'Chips &
Namkeen', 'cat_chips', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/lays_blue.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/lays_orange.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/kurkure_green.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/kurkure_orange.png"]', 'bestseller', 501, 1, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('4c438b30-3bc0-52ab-a0a5-4936983bc079', 'Vegetables
& Fruits', 'cat_veggies', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/potatoes.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/onions.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/bananas.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/chillies.png"]', 'bestseller', 173, 2, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('82fe39a5-85d6-5672-89b6-dd707fbe05ff', 'Dairy,
Bread & ...', 'cat_dairy', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/amul_butter.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/brownie.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/milk_blue.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/milk_pouch.png"]', 'bestseller', 37, 3, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('de8d3dfd-5b83-5372-8089-bf49ca12bccb', 'Ice
Creams ...', 'cat_icecreams', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/icecream_cup.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/icecream_snack.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/amul_tub.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/icecream_stick.png"]', 'bestseller', 74, 4, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('3dddaf46-c9f2-5d68-b16a-84831d9e1867', 'Bakery &
Biscuits', 'cat_bakery', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/hide_and_seek.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/dark_fantasy_red.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/biscuit_green.png", "https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/dark_fantasy_black.png"]', 'bestseller', 225, 5, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('fbae9094-07f3-58f6-b510-46dade7888fe', 'Vegetables & Fruits', 'gk_veggies', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_7_157_1643443974388.png"]', 'grocery', 0, 6, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('01701030-8643-58ec-8bd6-785ff92c7887', 'Atta,
Rice & Dal', 'gk_atta', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_11_rc-upload-1776240040304-421.png"]', 'grocery', 0, 7, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('6bf19017-8292-5c0a-bd63-d2dbb7e8482b', 'Oil, Ghee
& Masala', 'gk_oil', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_16_0ac12d25-6f57-4a1e-b649-efb308103607.png"]', 'grocery', 0, 8, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('c0bcb555-d941-5f89-a3e9-c258067cdf5b', 'Dairy,
Bread & Eggs', 'gk_dairy', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_17_eb2ba2ce-96fd-43cb-acc0-2a04ff6b810d.png"]', 'grocery', 0, 9, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('a3037341-5f53-5f4a-95ce-b97a17655421', 'Bakery &
Biscuits', 'gk_bakery', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_20_rc-upload-1776829632782-42.png"]', 'grocery', 0, 10, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('74e6d2a1-e530-5bc5-bb15-f042164f441b', 'Dry Fruits
& Cereals', 'gk_dryfruits', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_21_rc-upload-1776375127483-57.png"]', 'grocery', 0, 11, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('da2068bc-345d-55d4-80da-b0e550d2b5ad', 'Chicken,
Meat & Fish', 'gk_chicken', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_18_42badb39-3720-4e49-8e19-980a10367928.png"]', 'grocery', 0, 12, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('668c3e7d-9d8e-56cd-82cc-34b85f5ac04c', 'Kitchenware
& Appliances', 'gk_kitchen', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_22_rc-upload-1786593189552-94.png"]', 'grocery', 0, 13, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Chips &
Namkeen', 'snack_chips', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_12_rc-upload-1776398906000-172.png"]', 'snacks', 0, 14, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('c651a294-a22d-597d-ba23-5cda70a3a687', 'Sweets &
Chocolates', 'snack_sweets', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_13_b91b3590-34ae-4f9b-a53a-6951452fb937.png"]', 'snacks', 0, 15, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Drinks &
Juices', 'snack_drinks', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_16_f2744d52-8878-4353-81e5-e5f17c9584b7.png"]', 'snacks', 0, 16, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('e4cf7cc7-43bb-5a9c-809e-01e7e6a70206', 'Tea,
Coffee & More', 'snack_tea', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_27_rc-upload-1780634830965-699.png"]', 'snacks', 0, 17, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('7669777a-21e0-5e3a-8b50-42e4e483b726', 'Instant
Food', 'snack_instant', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_20_rc-upload-1776398906000-170.png"]', 'snacks', 0, 18, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('bf052a0f-b779-58aa-8c0b-450b97e25f12', 'Sauces &
Spreads', 'snack_sauces', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_14_e29ff4ab-7a96-4b90-b251-0489fa0416a2.png"]', 'snacks', 0, 19, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('04c496f3-af23-59df-8242-09a5349af138', 'Paan
Corner', 'snack_paan', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_16_5a07ab88-349f-4884-aae2-87ec47fed05a.png"]', 'snacks', 0, 20, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO categories (id, name, slug, image_url, section_type, more_count, sort_order, is_active)
VALUES ('066e57fc-b387-5225-836d-2dd93d32b348', 'Ice Creams
& More', 'snack_icecream', '["https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_5_bc94259c-f293-4289-abc5-f4cb0da63270.png"]', 'snacks', 0, 21, TRUE)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  section_type = EXCLUDED.section_type,
  more_count = EXCLUDED.more_count,
  sort_order = EXCLUDED.sort_order;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('0e0cf484-0c0d-5315-b257-efea78c73f23', '00000000-0000-0000-0000-000000000001', '5d625204-618f-5b86-8933-ab22149f4c08', 'Diet Coke Can', '300 ml', 40.0, 38.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('14a8a69d-5e3e-5ee3-a38e-d0423fb88c4a', '0e0cf484-0c0d-5315-b257-efea78c73f23', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/diet_coke.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('e816607d-7b78-5a1d-acd6-b9e65da3a60d', '00000000-0000-0000-0000-000000000001', '5d625204-618f-5b86-8933-ab22149f4c08', 'Coca-Cola Original Taste', '750 ml', 45.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('0d652cc4-bfa4-5960-8c86-c73ff0540f7a', 'e816607d-7b78-5a1d-acd6-b9e65da3a60d', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/coke.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('b82a6e42-90a3-5b20-82fe-7c0003abd9fd', '00000000-0000-0000-0000-000000000001', '5d625204-618f-5b86-8933-ab22149f4c08', 'Sprite Lime Flavored', '750 ml', 45.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('4f38c918-ff0d-58af-993c-1de3c8c68ecc', 'b82a6e42-90a3-5b20-82fe-7c0003abd9fd', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/sprite.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('5107433a-7711-5f9a-8060-d71ede31bdbe', '00000000-0000-0000-0000-000000000001', '5d625204-618f-5b86-8933-ab22149f4c08', 'Coca-Cola Zero Sugar', '300 ml', 40.0, 36.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('4c852b57-930b-5b5c-aeb7-1ad1ef563c5d', '5107433a-7711-5f9a-8060-d71ede31bdbe', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/coca_cola.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('b5f8a504-1e71-5b51-a284-080579e0638c', '00000000-0000-0000-0000-000000000001', '8345c652-d10a-58ea-b54f-6f9c4aca98b8', 'Lay''s India''s Magic Masala', '50 g', 20.0, 20.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('7135fad0-fe40-5542-b908-e9e3a6aee4f6', 'b5f8a504-1e71-5b51-a284-080579e0638c', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/lays_blue.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('8901bd79-bb9b-51b3-9c6b-0e155787c0ae', '00000000-0000-0000-0000-000000000001', '8345c652-d10a-58ea-b54f-6f9c4aca98b8', 'Lay''s Spanish Tomato Tango', '50 g', 20.0, 18.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('3ffc898c-8407-5725-9a75-c7e96cf908bf', '8901bd79-bb9b-51b3-9c6b-0e155787c0ae', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/lays_orange.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('1aec2ab2-7478-5a3c-bca4-a6fae87de359', '00000000-0000-0000-0000-000000000001', '8345c652-d10a-58ea-b54f-6f9c4aca98b8', 'Kurkure Green Chutney Style', '75 g', 20.0, 19.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('da9bdbf3-2312-5087-80a6-febba87e0338', '1aec2ab2-7478-5a3c-bca4-a6fae87de359', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/kurkure_green.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('a8a104e9-3db7-5cb2-9379-d91a42117042', '00000000-0000-0000-0000-000000000001', '8345c652-d10a-58ea-b54f-6f9c4aca98b8', 'Kurkure Masala Munch', '85 g', 20.0, 20.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('48e08659-1299-5db5-ae72-0a5c74865a34', 'a8a104e9-3db7-5cb2-9379-d91a42117042', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/kurkure_orange.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('cf30c002-0526-559a-959e-f262ade32577', '00000000-0000-0000-0000-000000000001', '4c438b30-3bc0-52ab-a0a5-4936983bc079', 'Fresh Potato (Aloo)', '1 kg', 35.0, 28.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('f21f493e-e9be-5329-a2ce-590af34b2703', 'cf30c002-0526-559a-959e-f262ade32577', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/potatoes.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('956527d7-01e0-5e68-8d57-db6a351e4c44', '00000000-0000-0000-0000-000000000001', '4c438b30-3bc0-52ab-a0a5-4936983bc079', 'Fresh Onion (Pyaz)', '1 kg', 45.0, 38.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('1f9e69fb-cfe3-54ef-8330-39f69ede2a9c', '956527d7-01e0-5e68-8d57-db6a351e4c44', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/onions.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('18229e73-ed7a-5ece-8b78-064deab34102', '00000000-0000-0000-0000-000000000001', '4c438b30-3bc0-52ab-a0a5-4936983bc079', 'Robusta Banana', '6 pcs', 40.0, 34.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('1103c4ec-6c73-5b7e-856b-8db678fa829f', '18229e73-ed7a-5ece-8b78-064deab34102', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/bananas.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('cdbcfc9a-4500-5acd-a15e-502cf9ce3bdc', '00000000-0000-0000-0000-000000000001', '4c438b30-3bc0-52ab-a0a5-4936983bc079', 'Fresh Green Chillies', '100 g', 15.0, 12.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('00bd94a2-b378-53a9-a3a6-e095acbbfb48', 'cdbcfc9a-4500-5acd-a15e-502cf9ce3bdc', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/chillies.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('7f83bb02-7b6d-5683-aa95-293ca08335a4', '00000000-0000-0000-0000-000000000001', '82fe39a5-85d6-5672-89b6-dd707fbe05ff', 'Amul Pasteurised Salted Butter', '100 g', 60.0, 58.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('79aeccf1-6866-5ffd-842d-4c3cba2d70ae', '7f83bb02-7b6d-5683-aa95-293ca08335a4', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/amul_butter.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('0b380d13-fc67-500f-954a-40287c8962aa', '00000000-0000-0000-0000-000000000001', '82fe39a5-85d6-5672-89b6-dd707fbe05ff', 'Chocolate Walnut Brownie', '1 pc', 75.0, 65.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('9c290bd6-6105-57a2-b95e-1a4bee857542', '0b380d13-fc67-500f-954a-40287c8962aa', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/brownie.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('72cc9624-2902-5d5a-b1de-1efd69826e51', '00000000-0000-0000-0000-000000000001', '82fe39a5-85d6-5672-89b6-dd707fbe05ff', 'Amul Taaza Toned Milk', '500 ml', 27.0, 27.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('cc1b6bf8-6ff1-50dd-bba7-a5c1bf57c0ad', '72cc9624-2902-5d5a-b1de-1efd69826e51', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/milk_blue.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('ed05a0ee-c6be-5904-ab15-814db3d24674', '00000000-0000-0000-0000-000000000001', '82fe39a5-85d6-5672-89b6-dd707fbe05ff', 'Amul Gold Full Cream Milk', '500 ml', 33.0, 33.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('5a7ea410-4343-5506-9dbc-b906304dc8eb', 'ed05a0ee-c6be-5904-ab15-814db3d24674', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/milk_pouch.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('c584ec89-337f-5b9c-933e-542e1dabe49b', '00000000-0000-0000-0000-000000000001', 'de8d3dfd-5b83-5372-8089-bf49ca12bccb', 'Kwality Walls Vanilla Cup', '100 ml', 25.0, 22.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('e1dcfe0b-7962-559c-afdb-035d00b30141', 'c584ec89-337f-5b9c-933e-542e1dabe49b', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/icecream_cup.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('6b0a91b7-526d-50ff-a8ec-0c77286ca8dd', '00000000-0000-0000-0000-000000000001', 'de8d3dfd-5b83-5372-8089-bf49ca12bccb', 'Choco Feast Ice Cream Bar', '70 ml', 35.0, 30.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('c7e76c6f-c54d-5c32-b919-74adfbb08089', '6b0a91b7-526d-50ff-a8ec-0c77286ca8dd', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/icecream_snack.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('d9b9c7cf-e73e-58f3-a5bd-d5bb3d78c8c5', '00000000-0000-0000-0000-000000000001', 'de8d3dfd-5b83-5372-8089-bf49ca12bccb', 'Amul Vanilla Gold Tub', '500 ml', 120.0, 110.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('374eb482-312b-5747-9245-33a0805921cd', 'd9b9c7cf-e73e-58f3-a5bd-d5bb3d78c8c5', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/amul_tub.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('5404f225-29e2-5f73-b447-7c2899b4fe07', '00000000-0000-0000-0000-000000000001', 'de8d3dfd-5b83-5372-8089-bf49ca12bccb', 'Magnum Classic Chocolate Stick', '80 ml', 90.0, 80.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('4d01bb28-7956-561c-bad8-9c0082557a11', '5404f225-29e2-5f73-b447-7c2899b4fe07', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/icecream_stick.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('85f7b04e-00a5-53a3-99dd-1940fb7ec0cf', '00000000-0000-0000-0000-000000000001', '3dddaf46-c9f2-5d68-b16a-84831d9e1867', 'Parle Hide & Seek Chocolate Chip Biscuits', '120 g', 35.0, 30.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('0b26eb6a-9f13-5e5e-a27b-52af5ce8b082', '85f7b04e-00a5-53a3-99dd-1940fb7ec0cf', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/hide_and_seek.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('8d53ba34-7d54-553a-83f0-d77da069345c', '00000000-0000-0000-0000-000000000001', '3dddaf46-c9f2-5d68-b16a-84831d9e1867', 'Sunfeast Dark Fantasy Choco Fills', '75 g', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('f29de51c-76a2-5b40-983b-e0105caff938', '8d53ba34-7d54-553a-83f0-d77da069345c', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/dark_fantasy_red.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('96aa96f1-41c9-5bdd-a831-bd0965b7c8b7', '00000000-0000-0000-0000-000000000001', '3dddaf46-c9f2-5d68-b16a-84831d9e1867', 'Parle-G Gold Biscuits', '100 g', 15.0, 14.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('20c72aab-c042-5bcd-93cc-d01928e4e8d0', '96aa96f1-41c9-5bdd-a831-bd0965b7c8b7', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/biscuit_green.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('a7fe6ed3-db6d-5c81-9a36-148ad070c8bf', '00000000-0000-0000-0000-000000000001', '3dddaf46-c9f2-5d68-b16a-84831d9e1867', 'Sunfeast Dark Fantasy Bourbon', '150 g', 45.0, 39.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  mrp = EXCLUDED.mrp,
  selling_price = EXCLUDED.selling_price,
  status = EXCLUDED.status;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('946a40ac-3c32-574f-bff7-fb01ecb66bff', 'a7fe6ed3-db6d-5c81-9a36-148ad070c8bf', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/dark_fantasy_black.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('d42dda4f-f168-579f-a39e-0bfe80cf200e', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #1', '1 pack', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('f79eaf47-c686-5991-8747-a06bc12dd4d7', 'd42dda4f-f168-579f-a39e-0bfe80cf200e', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_11_rc-upload-1776240040304-421.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('63eb2212-4608-53b4-9b23-492fa6a003ca', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #2', '1 pack', 50.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('34ea69c5-7129-59b5-90e7-97f6f5192faf', '63eb2212-4608-53b4-9b23-492fa6a003ca', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_12_rc-upload-1776398906000-172.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('1a0fe6ba-bd41-5dd2-93e3-3b4f5c2976d0', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #3', '1 pack', 60.0, 60.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('276b2156-3da2-5928-8707-94cee8345801', '1a0fe6ba-bd41-5dd2-93e3-3b4f5c2976d0', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_13_rc-upload-1780634830965-687.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('b1f4d1a3-0fb0-504e-9406-8fe72fce7a2b', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #4', '1 pack', 70.0, 65.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('a1bbd650-f076-5277-a688-9e4193911e00', 'b1f4d1a3-0fb0-504e-9406-8fe72fce7a2b', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_14_rc-upload-1775727804128-56.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('b56933dd-378b-5328-84dd-f51dd6beb2c4', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #5', '1 pack', 80.0, 70.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('e8140bcd-5221-5ac4-a24a-a9c9816dd515', 'b56933dd-378b-5328-84dd-f51dd6beb2c4', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_16_rc-upload-1782185292662-91.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('41fc910c-b183-5b31-98dd-d0fa7720f813', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #6', '1 pack', 90.0, 90.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('d8ce9836-6ef1-5734-8661-16932312a496', '41fc910c-b183-5b31-98dd-d0fa7720f813', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_17_rc-upload-1776398906000-171.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('eebce0f5-de68-5a87-b4c7-d63757a9418a', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #7', '1 pack', 100.0, 95.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('ab1f8855-7701-5bfc-a58a-10fd020a2b2e', 'eebce0f5-de68-5a87-b4c7-d63757a9418a', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_19_rc-upload-1781075086335-4.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('35084df1-3f85-517c-9dbc-a3ca0f7c8ab6', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #8', '1 pack', 110.0, 100.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('624dec1c-17e5-579d-abee-8211e59b3671', '35084df1-3f85-517c-9dbc-a3ca0f7c8ab6', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_20_rc-upload-1776398906000-170.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('b5d66158-aab9-56ac-bf83-39fd60be4589', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #9', '1 pack', 30.0, 30.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('0bac644a-3843-5346-97d8-04d628e2c6f2', 'b5d66158-aab9-56ac-bf83-39fd60be4589', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_21_rc-upload-1776375127483-57.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('5797ae68-fc2d-523b-ae70-eae6af6ad90f', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #10', '1 pack', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('94348002-79a5-55f0-a064-d033502d81db', '5797ae68-fc2d-523b-ae70-eae6af6ad90f', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_23_rc-upload-1770986393266-460.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('e61b02a1-0e51-52dc-a651-3901eee4b56a', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #11', '1 pack', 50.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('e9035cbd-f198-57b4-8016-1db3c76ac9a6', 'e61b02a1-0e51-52dc-a651-3901eee4b56a', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_24_rc-upload-1776928455745-34.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('bec8c767-3ca9-5970-bab8-fca8428274bb', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #12', '1 pack', 60.0, 60.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('af947c89-e3c8-5f9a-b06d-89a8731f2fec', 'bec8c767-3ca9-5970-bab8-fca8428274bb', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_25_5fbdda4b-5a4c-4ce2-b3ab-9bef244cb74f.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('51ad9e1b-ca2c-5094-b38d-9a738d196c33', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #13', '1 pack', 70.0, 65.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('e0de6cb6-302e-5004-8c1c-f2fad25c812e', '51ad9e1b-ca2c-5094-b38d-9a738d196c33', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_27_rc-upload-1780634830965-699.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('f345781a-1bf7-5772-9497-5363c130760e', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #14', '1 pack', 80.0, 70.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('6aa86942-a947-5584-ac4e-682a77c2f750', 'f345781a-1bf7-5772-9497-5363c130760e', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_2_107_1643445091063.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('c2ac0ecf-f42a-54e7-b1ad-d21321b4399e', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #15', '1 pack', 90.0, 90.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('da1c7d82-7d3f-5d87-95ed-ed12a3e7830c', 'c2ac0ecf-f42a-54e7-b1ad-d21321b4399e', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_3_rc-upload-1700735371138-2.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('abba422c-fc65-50cb-a640-eb3f32f1eca5', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #16', '1 pack', 100.0, 95.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('eaad8330-e76d-571d-b1f8-ed537d4d1bfa', 'abba422c-fc65-50cb-a640-eb3f32f1eca5', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_5_1178_1643445391732.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('0253ed56-0f48-5c40-a933-dd7db8c046e4', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #17', '1 pack', 110.0, 100.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('dd47b701-26f1-54d4-bdfb-5f1680040123', '0253ed56-0f48-5c40-a933-dd7db8c046e4', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_6_156_1643445347481.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('d56b606e-e82e-5d57-9946-9355fc31a085', '00000000-0000-0000-0000-000000000001', 'bf7c4183-15a6-50ad-85b4-b20afc3c227d', 'Crispy Snack Deluxe #18', '1 pack', 30.0, 30.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('8c17d605-8a67-5819-93c1-65a531bfd093', 'd56b606e-e82e-5d57-9946-9355fc31a085', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/chips_and_namkeen/imgi_9_rc-upload-1777353225068-27.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('c7e01f6e-8f1c-5504-862b-3d56b4c13a78', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #1', '1 pack', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('59e12328-d503-5f30-856d-ac53c9f793c6', 'c7e01f6e-8f1c-5504-862b-3d56b4c13a78', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_12_rc-upload-1769601651263-733.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('969cec2c-bf57-5503-a546-9e4c9b8bb9a7', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #2', '1 pack', 50.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('3beac6c6-2f83-5318-935e-de73f07ad481', '969cec2c-bf57-5503-a546-9e4c9b8bb9a7', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_14_6f4bd423-1666-4d23-bf3d-db482be09608.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('019a08bb-4051-58e0-aadc-3645512f3fbe', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #3', '1 pack', 60.0, 60.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('47590da7-0022-58fc-b047-3adcb2748bd0', '019a08bb-4051-58e0-aadc-3645512f3fbe', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_16_f2744d52-8878-4353-81e5-e5f17c9584b7.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('6b07d597-9f3b-5905-9b69-96655c72f657', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #4', '1 pack', 70.0, 65.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('4fc085ab-b70f-5c8d-8afd-62bb44a38f8b', '6b07d597-9f3b-5905-9b69-96655c72f657', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_18_57fff647-590c-4db6-9d8d-fe2863057cab.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('cb858436-1a7d-51af-ae58-c270f60fa10d', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #5', '1 pack', 80.0, 70.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('d081527f-188e-5a52-b3ab-4f4201e1f925', 'cb858436-1a7d-51af-ae58-c270f60fa10d', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_21_c95c7e24-d53d-4114-b19a-0d8dedea65e0.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('c2979d96-1cb5-5eab-a36e-1adf9dd62809', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #6', '1 pack', 90.0, 90.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('7ff7c637-717b-53d7-a3c6-928b330a4ce6', 'c2979d96-1cb5-5eab-a36e-1adf9dd62809', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_23_a5b7e972-ec13-4a69-a033-0d0114f42353.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('5e7ad771-17a7-578b-bc6d-575c17d0727b', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #7', '1 pack', 100.0, 95.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('6fb319dd-670a-5208-8307-31beedea9eb1', '5e7ad771-17a7-578b-bc6d-575c17d0727b', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_25_rc-upload-1782982154430-283.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('f9b5bbfe-f88a-5f99-b407-4f0705bc9676', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #8', '1 pack', 110.0, 100.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('53372138-6d83-599a-9eac-01193b316d87', 'f9b5bbfe-f88a-5f99-b407-4f0705bc9676', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_26_38b50cea-ffb0-4de1-bb06-f9323c85b7ed.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('fb12824b-0247-5f73-b976-a75211990c10', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #9', '1 pack', 30.0, 30.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('37d8c737-4488-537d-a811-34aaecbefaf3', 'fb12824b-0247-5f73-b976-a75211990c10', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_28_81fa88a1-d45a-43dd-9792-cf74b551f9cd.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('a445a7b1-af3d-58f3-aad6-1d9f09d104e3', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #10', '1 pack', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('d6b8a1aa-5df3-5ca8-b309-a2a0e3bb7061', 'a445a7b1-af3d-58f3-aad6-1d9f09d104e3', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_29_rc-upload-1782385751268-11.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('135a22c6-8679-50e4-89c8-83d51c431afc', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #11', '1 pack', 50.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('e2987094-83dc-5fb1-ae3f-6c1a8435dab6', '135a22c6-8679-50e4-89c8-83d51c431afc', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_2_1102_1649432926740.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('066b40d7-f7ad-5837-a032-cdd36a5cf32a', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #12', '1 pack', 60.0, 60.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('185c2303-743b-5dbc-a0a2-63a6aae33413', '066b40d7-f7ad-5837-a032-cdd36a5cf32a', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_30_61879b4f632a4fa09569ae4ee24c0159.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('3b378fb9-81f2-50fa-920c-89f98316cc18', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #13', '1 pack', 70.0, 65.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('cccfc8cf-1f95-5206-ab34-3efcb858c7e6', '3b378fb9-81f2-50fa-920c-89f98316cc18', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_5_1318_1684311395298.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('7da08be3-f347-5a1e-b3ac-cba4dbf521c5', '00000000-0000-0000-0000-000000000001', '9b684530-70f2-53fb-af2d-0b4b19d67cde', 'Refreshing Beverage #14', '1 pack', 80.0, 70.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('4b75effc-193a-58f8-9b66-72e5260ea5c2', '7da08be3-f347-5a1e-b3ac-cba4dbf521c5', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Energy_Drinks_and_juices/imgi_9_1594_1680180957343.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('08601e5c-b714-5074-9c3d-d481943415ed', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #1', '1 pack', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('9b9b78aa-604c-52ef-96bc-e1c0267efee8', '08601e5c-b714-5074-9c3d-d481943415ed', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_12_4ea129f5-d31b-4c96-8825-3680f77f4c5c.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('ddc4baee-95fe-5b3d-8b5d-a8cc00ebda58', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #2', '1 pack', 50.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('a4e57b42-87d2-52f3-9f5b-6ed72c2c5cbb', 'ddc4baee-95fe-5b3d-8b5d-a8cc00ebda58', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_13_0908a205-26bf-4135-969a-9002b302069c.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('494b1c52-52ea-52e0-a518-213c429aa230', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #3', '1 pack', 60.0, 60.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('1bf02060-8cd8-5810-baed-26357bc1b76e', '494b1c52-52ea-52e0-a518-213c429aa230', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_14_e29ff4ab-7a96-4b90-b251-0489fa0416a2.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('a1f2d0ae-68e9-59d0-af29-ab2aa9f1d4ad', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #4', '1 pack', 70.0, 65.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('ead252a6-7349-53e9-b9b1-d5a17ee44c22', 'a1f2d0ae-68e9-59d0-af29-ab2aa9f1d4ad', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_16_rc-upload-1781245059163-746.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('1b52d722-4ade-5b67-b25f-70fbadf7d38a', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #5', '1 pack', 80.0, 70.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('76a6a3bf-3bee-569b-a5bc-b821516130af', '1b52d722-4ade-5b67-b25f-70fbadf7d38a', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_17_6d5e4c9a-0e9a-46e8-8b84-d7cb1f4b5fc7.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('1f3a0a3f-e1e7-5b8f-b0eb-6b601a1928ff', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #6', '1 pack', 90.0, 90.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('dab830ba-e02d-5686-bb8c-8b0cf5fb316b', '1f3a0a3f-e1e7-5b8f-b0eb-6b601a1928ff', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_18_d3dc6f2b-7d67-4e41-8da8-40d08967796e.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('549a1b07-5db9-5add-8ac3-da5586613673', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #7', '1 pack', 100.0, 95.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('2e40d73f-c746-5228-8c11-141a18e9dda4', '549a1b07-5db9-5add-8ac3-da5586613673', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_1_rc-upload-1702463308432-3.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('47888b35-5a7e-5940-8d97-0e01d912e900', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #8', '1 pack', 110.0, 100.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('99cfbb35-16bc-5dc0-9301-139c3b954319', '47888b35-5a7e-5940-8d97-0e01d912e900', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_21_f20bf9d3-fe3b-4339-a25d-c8ce092280e2.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('a82af9ec-5e94-5a3e-a945-7870ee7b7ae0', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #9', '1 pack', 30.0, 30.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('35e5252e-3194-575d-85c3-400fc66c3ae5', 'a82af9ec-5e94-5a3e-a945-7870ee7b7ae0', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_22_4fcbc1fe-5a04-465f-9558-7ea73e9f8b1f.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('b798e577-40fa-5233-96a7-70e2acea1c81', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #10', '1 pack', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('352ab8d4-e576-5ec4-a89b-e515260c5f74', 'b798e577-40fa-5233-96a7-70e2acea1c81', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_23_55b60fb8-ab99-491c-89df-08aa8959f060.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('61317610-f755-542f-9380-196a2a08fdf1', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #11', '1 pack', 50.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('b2681e17-6ebd-57a6-a125-e34a54013b7b', '61317610-f755-542f-9380-196a2a08fdf1', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_24_rc-upload-1781857542047-352.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('cb17382f-acd3-5a06-b4a7-7ca8b158a636', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #12', '1 pack', 60.0, 60.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('8cb297e1-fe22-5ba0-b495-3384c9526c60', 'cb17382f-acd3-5a06-b4a7-7ca8b158a636', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_2_rc-upload-1702734004998-8.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('a231c74d-a2ee-5b89-afdf-a50d0406eeef', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #13', '1 pack', 70.0, 65.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('484ec85a-3280-5e79-adf1-32010ed8be51', 'a231c74d-a2ee-5b89-afdf-a50d0406eeef', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_3_rc-upload-1712577388325-3.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('d2d01737-0a92-5295-8a12-43099365b463', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #14', '1 pack', 80.0, 70.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('4d1d6ddc-ee3b-5183-9e10-b54e2315343a', 'd2d01737-0a92-5295-8a12-43099365b463', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_5_278_1678705041060.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('74b2ed95-be56-588f-9a5c-843370cce27b', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #15', '1 pack', 90.0, 90.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('717f1158-d4dd-5007-90eb-793e84b5d1e2', '74b2ed95-be56-588f-9a5c-843370cce27b', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_6_395_1668582176947.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('2c3d38a3-a7b2-5bab-adf2-5e7fe8029b9a', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #16', '1 pack', 100.0, 95.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('dc7166cc-af68-5bcb-acc5-1f83adcc4c7e', '2c3d38a3-a7b2-5bab-adf2-5e7fe8029b9a', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_7_157_1643443974388.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('8d1accbc-284e-5388-9a56-cbe9f1952845', '00000000-0000-0000-0000-000000000001', 'fbae9094-07f3-58f6-b510-46dade7888fe', 'Fresh Farm Pick #17', '1 pack', 110.0, 100.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('fb7fb20e-0dc3-5c25-93a3-503cea3de580', '8d1accbc-284e-5388-9a56-cbe9f1952845', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/Fresh_Vegetables_Online/imgi_8_66acfb51-c5fe-4718-a200-61efaf773556.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('37f69403-3ef9-5369-b3ef-8159edcc68d4', '00000000-0000-0000-0000-000000000001', 'c0bcb555-d941-5f89-a3e9-c258067cdf5b', 'Farm Fresh Dairy #1', '1 pack', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('de1635b2-b5b1-50b7-bc44-f579d3e4c958', '37f69403-3ef9-5369-b3ef-8159edcc68d4', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_11_1ded64a0-9f20-4a1d-8211-156f221b377b.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('83718c16-d3f3-5e51-be9e-b5773c79609b', '00000000-0000-0000-0000-000000000001', 'c0bcb555-d941-5f89-a3e9-c258067cdf5b', 'Farm Fresh Dairy #2', '1 pack', 50.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('c7869f78-c1a1-52b1-8a90-de67acfa5978', '83718c16-d3f3-5e51-be9e-b5773c79609b', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_13_b91b3590-34ae-4f9b-a53a-6951452fb937.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('4b82d86e-981b-5cc5-935f-217817eaaccc', '00000000-0000-0000-0000-000000000001', 'c0bcb555-d941-5f89-a3e9-c258067cdf5b', 'Farm Fresh Dairy #3', '1 pack', 60.0, 60.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('7da05fda-4d4a-5501-9c80-f0f851cfe90e', '4b82d86e-981b-5cc5-935f-217817eaaccc', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_14_rc-upload-1780632898141-4.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('664e19fb-62ab-5c2a-acbe-8541a156bbd4', '00000000-0000-0000-0000-000000000001', 'c0bcb555-d941-5f89-a3e9-c258067cdf5b', 'Farm Fresh Dairy #4', '1 pack', 70.0, 65.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('a37493cc-cc73-5b81-a584-11c4e0ad76bb', '664e19fb-62ab-5c2a-acbe-8541a156bbd4', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_15_87c1c525-750e-475f-91d1-f155026ddaa1.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('5f2c473a-05a0-50a0-bf21-bd601140f3cc', '00000000-0000-0000-0000-000000000001', 'c0bcb555-d941-5f89-a3e9-c258067cdf5b', 'Farm Fresh Dairy #5', '1 pack', 80.0, 70.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('c28569ef-d68d-5611-bbd4-830574ee0374', '5f2c473a-05a0-50a0-bf21-bd601140f3cc', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_17_eb2ba2ce-96fd-43cb-acc0-2a04ff6b810d.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('16fdf3f1-1830-50e2-ad58-1d56f1fc93fc', '00000000-0000-0000-0000-000000000001', 'c0bcb555-d941-5f89-a3e9-c258067cdf5b', 'Farm Fresh Dairy #6', '1 pack', 90.0, 90.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('f17dd385-47d4-5fa2-ba4b-e0e178ab008b', '16fdf3f1-1830-50e2-ad58-1d56f1fc93fc', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_18_42badb39-3720-4e49-8e19-980a10367928.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('bcf35bbb-0f25-54a4-bddc-c433da0edfc4', '00000000-0000-0000-0000-000000000001', 'c0bcb555-d941-5f89-a3e9-c258067cdf5b', 'Farm Fresh Dairy #7', '1 pack', 100.0, 95.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('0f61f575-c229-5fe3-b40a-5ae58b43afe5', 'bcf35bbb-0f25-54a4-bddc-c433da0edfc4', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_1_rc-upload-1776681742626-372.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('40641a4f-b857-50ba-bbf0-f1d99fa0269a', '00000000-0000-0000-0000-000000000001', 'c0bcb555-d941-5f89-a3e9-c258067cdf5b', 'Farm Fresh Dairy #8', '1 pack', 110.0, 100.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('9d053602-0982-59cb-9eb4-216e45ad296f', '40641a4f-b857-50ba-bbf0-f1d99fa0269a', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_5_bc94259c-f293-4289-abc5-f4cb0da63270.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('90adc286-4dd6-5a1b-95a3-77be56ce549b', '00000000-0000-0000-0000-000000000001', 'c0bcb555-d941-5f89-a3e9-c258067cdf5b', 'Farm Fresh Dairy #9', '1 pack', 30.0, 30.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('a56a7448-3629-5bf9-9cfe-c496d8357b24', '90adc286-4dd6-5a1b-95a3-77be56ce549b', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_6_9f3a7272-e63e-4532-8ad0-832a275b499b.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('16ea6ed3-f00d-570d-9b61-1c6cbff636d1', '00000000-0000-0000-0000-000000000001', 'c0bcb555-d941-5f89-a3e9-c258067cdf5b', 'Farm Fresh Dairy #10', '1 pack', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('a6db930d-3249-519b-9ad9-8252908b704d', '16ea6ed3-f00d-570d-9b61-1c6cbff636d1', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/dairy-bread-eggs/imgi_9_628c97e0-5ed4-425d-a667-1d3bfa6f0bde.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('6ae65d1e-7b27-53e1-9ac6-41efa96c5ec9', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #1', '1 pack', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('cd3f239a-bda3-5a68-bd73-7edf34105217', '6ae65d1e-7b27-53e1-9ac6-41efa96c5ec9', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_11_rc-upload-1785180077784-3.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('019d2677-f325-5566-95c1-6b6cfc316f6d', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #2', '1 pack', 50.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('ae8bd465-78be-5fc2-9820-aff65c236455', '019d2677-f325-5566-95c1-6b6cfc316f6d', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_13_rc-upload-1785296870947-392.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('d6b6e025-d0be-5d57-b20b-f6f630674ed1', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #3', '1 pack', 60.0, 60.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('81bcd153-839b-5592-b3d9-04c5bec165bb', 'd6b6e025-d0be-5d57-b20b-f6f630674ed1', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_15_rc-upload-1776829632782-4.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('cab525d6-4af0-587c-988d-23d140a6d607', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #4', '1 pack', 70.0, 65.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('a91c2032-3f4a-597f-92df-cdb783997d15', 'cab525d6-4af0-587c-988d-23d140a6d607', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_16_0ac12d25-6f57-4a1e-b649-efb308103607.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('84fa2207-e1ed-52ef-a52e-5a979a52c5d6', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #5', '1 pack', 80.0, 70.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('30686717-6683-59a8-bde5-ebdb5cc728aa', '84fa2207-e1ed-52ef-a52e-5a979a52c5d6', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_17_15aa460b-2f64-47cc-82ee-1c8c24115bc2.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('eccb0587-08de-562f-9bbd-c891b19279d9', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #6', '1 pack', 90.0, 90.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('f8757d81-4abc-5ca3-8503-cd8017231564', 'eccb0587-08de-562f-9bbd-c891b19279d9', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_19_rc-upload-1785296870947-450.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('b94ed68d-e017-59ed-a6cd-207e4294b603', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #7', '1 pack', 100.0, 95.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('3a0fe443-abf1-509d-b14b-edc8871ebfbf', 'b94ed68d-e017-59ed-a6cd-207e4294b603', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_20_rc-upload-1776829632782-42.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('384b0a9b-c736-5471-81f2-7ab02abb3704', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #8', '1 pack', 110.0, 100.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('8323f5bf-e20d-550a-9294-fb3a40845108', '384b0a9b-c736-5471-81f2-7ab02abb3704', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_21_rc-upload-1781877106396-96.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('9a0d84de-0b25-5fe2-b29c-8bbd8ae38ee4', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #9', '1 pack', 30.0, 30.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('2811c004-7bc2-5cdd-84ae-3f4a238dd9c2', '9a0d84de-0b25-5fe2-b29c-8bbd8ae38ee4', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_22_rc-upload-1774852204533-125.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('39206c70-9f56-5105-9c27-750594c6d0db', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #10', '1 pack', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('5e12540f-c2bd-5433-9ba1-73a2f10331df', '39206c70-9f56-5105-9c27-750594c6d0db', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_23_a70a8da9-dd45-4e36-9542-91e60b9bf291.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('b9cfc84b-ee15-555b-9d84-000b74413da2', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #11', '1 pack', 50.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('f19301f9-5f59-5afb-99f8-291131b110c9', 'b9cfc84b-ee15-555b-9d84-000b74413da2', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_24_4e75d451-3065-4486-ad45-f5d91ba50933.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('afe3e273-153f-5d6e-8154-7ffb5e6637e1', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #12', '1 pack', 60.0, 60.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('343ee74d-7c97-57ec-9186-858094974291', 'afe3e273-153f-5d6e-8154-7ffb5e6637e1', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_26_rc-upload-1776829632782-26.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('01e1aa68-4d39-577c-abaf-d95e127378d1', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #13', '1 pack', 70.0, 65.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('5d1c8e9b-2fec-56f1-8697-50e20da82db5', '01e1aa68-4d39-577c-abaf-d95e127378d1', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_27_rc-upload-1782099128815-1869.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('96c932a6-4819-5bbc-9a2a-3bcc775fb08b', '00000000-0000-0000-0000-000000000001', 'a3037341-5f53-5f4a-95ce-b97a17655421', 'Crunchy Cookies #14', '1 pack', 80.0, 70.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('b8e4bd18-9a2c-57c9-9324-dc62b9c82bc4', '96c932a6-4819-5bbc-9a2a-3bcc775fb08b', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/biscuits_and_cookies/imgi_9_rc-upload-1785901114272-473.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('0c70a4ef-7ed3-5920-aefa-ef5e57436a54', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #1', '1 pack', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('5b136af0-ca25-571f-9efb-756f947ad0e5', '0c70a4ef-7ed3-5920-aefa-ef5e57436a54', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_10_820cb93e-c555-4dd7-b86a-25b9423129bf.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('7814cf4a-2c9f-5cf3-a7ac-c5a8c9053ab5', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #2', '1 pack', 50.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('430ff2a8-4321-56a8-8e29-1c006919cc68', '7814cf4a-2c9f-5cf3-a7ac-c5a8c9053ab5', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_12_rc-upload-1775545049463-175.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('7f32bfa6-0f3d-5ee9-8414-ec62f0cc9bc2', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #3', '1 pack', 60.0, 60.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('edefa5f1-c491-59da-8e4e-ad972abc2bfe', '7f32bfa6-0f3d-5ee9-8414-ec62f0cc9bc2', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_13_rc-upload-1782790536049-269.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('7aaf3e62-42c5-5049-ae3e-cec5ec2b1be9', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #4', '1 pack', 70.0, 65.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('353c3561-3607-5942-b9ce-eb61f13eac41', '7aaf3e62-42c5-5049-ae3e-cec5ec2b1be9', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_15_rc-upload-1777433855055-179.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('2b028a6b-8825-5141-8578-f25e180638d5', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #5', '1 pack', 80.0, 70.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('c02d1b0f-8d6f-52d7-b34c-80e9c4fc5e95', '2b028a6b-8825-5141-8578-f25e180638d5', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_16_5a07ab88-349f-4884-aae2-87ec47fed05a.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('3493a14c-5125-5526-8d43-76e8cca32110', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #6', '1 pack', 90.0, 90.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('33930a5e-d1ab-5ad0-9074-7d298fc2c35e', '3493a14c-5125-5526-8d43-76e8cca32110', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_17_rc-upload-1786426172675-333.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('b34aa1ef-4f18-5c32-b045-103a86f52dda', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #7', '1 pack', 100.0, 95.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('d1e836d0-0c24-5c1c-a353-50832bf9b4e7', 'b34aa1ef-4f18-5c32-b045-103a86f52dda', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_19_rc-upload-1776321270999-202.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('2c1b21b7-8735-523a-8561-8159b09be723', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #8', '1 pack', 110.0, 100.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('edbb4ba2-2af4-579d-bf19-97482807916c', '2c1b21b7-8735-523a-8561-8159b09be723', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_1_rc-upload-1716287986266-3.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('cffccf5c-1df5-541f-b44c-dbe6cec73593', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #9', '1 pack', 30.0, 30.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('13120283-eef3-5606-af49-fe66e4555faa', 'cffccf5c-1df5-541f-b44c-dbe6cec73593', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_20_rc-upload-1771817802649-314.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('cc80420a-1c84-5333-8ff6-971bfe396538', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #10', '1 pack', 40.0, 35.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('ebb7f5b5-a8a4-5f9a-9030-85700cf46d0d', 'cc80420a-1c84-5333-8ff6-971bfe396538', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_22_rc-upload-1786593189552-94.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('ab2fd183-74a3-5ae9-afae-bc52ed55fc22', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #11', '1 pack', 50.0, 40.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('d8f78f55-03bc-5180-8398-491b32483304', 'ab2fd183-74a3-5ae9-afae-bc52ed55fc22', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_2_rc-upload-1717067945707-3.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('33393ae6-0daa-5cad-9843-f0ef5bbf309d', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #12', '1 pack', 60.0, 60.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('373a146f-2697-5e6f-b308-2621fb8518ec', '33393ae6-0daa-5cad-9843-f0ef5bbf309d', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_3_rc-upload-1717072632680-3.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('cfc0b83c-230c-54d2-bf0b-42e75c7f962a', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #13', '1 pack', 70.0, 65.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('84f63b14-de6b-513c-b540-08e09019a089', 'cfc0b83c-230c-54d2-bf0b-42e75c7f962a', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_4_rc-upload-1717137798882-3.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;


INSERT INTO products (id, vendor_id, category_id, name, unit, mrp, selling_price, stock_qty, status)
VALUES ('f25e1516-7b56-57d2-b9c1-060c713d3a13', '00000000-0000-0000-0000-000000000001', '7669777a-21e0-5e3a-8b50-42e4e483b726', 'Pet Nutrition Pack #14', '1 pack', 80.0, 70.0, 100, 'live')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  selling_price = EXCLUDED.selling_price;


INSERT INTO product_images (id, product_id, webp_url, sort_order, is_primary)
VALUES ('7a75e42e-0cea-5b13-8a6e-056af41ac442', 'f25e1516-7b56-57d2-b9c1-060c713d3a13', 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/product-images/pet_food_and_supplies/imgi_6_rc-upload-1782908605623-163.png', 0, TRUE)
ON CONFLICT (id) DO UPDATE SET webp_url = EXCLUDED.webp_url;
