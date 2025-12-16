ALTER TABLE cheddarup.order_pickup
    ALTER COLUMN order_pickup_id
        SET DEFAULT gen_random_uuid();