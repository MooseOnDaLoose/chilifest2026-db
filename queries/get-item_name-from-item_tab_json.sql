ALTER TABLE cheddarup.order_pickup
    ADD COLUMN IF NOT EXISTS item_name TEXT;

UPDATE cheddarup.order_pickup
SET item_name = item_tab_json ->> 'name'
WHERE item_tab_json IS NOT NULL;
