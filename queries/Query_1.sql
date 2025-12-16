CREATE TABLE order_pickup (
                              order_pickup_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

                              payment_id           BIGINT NOT NULL,
                              payment_item_id      BIGINT NOT NULL,
                              tab_member_id        BIGINT NOT NULL,

                              customer_name        TEXT,
                              customer_email       TEXT,

                              item_quantity        INT NOT NULL,
                              item_total           NUMERIC(12,2) NOT NULL,
                              item_detail_json     JSONB,
                              item_tab_json        JSONB,

                              payment_status       TEXT,
                              payment_total        NUMERIC(12,2),
                              payment_refund_total NUMERIC(12,2),
                              payment_created_at   TIMESTAMP,

                              pickup_status        TEXT DEFAULT 'pending',
                              pickup_ready_at      TIMESTAMP,
                              picked_up_at         TIMESTAMP,
                              picked_up_by         TEXT,
                              notes                TEXT,

                              created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
