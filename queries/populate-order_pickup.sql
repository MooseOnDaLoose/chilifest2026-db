BEGIN;

-- 1) Create table if it doesn't exist (UUID PK + workflow fields + data fields)
CREATE TABLE IF NOT EXISTS cheddarup.order_pickup (
                                                   order_pickup_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                                                   payment_id      BIGINT NOT NULL,
                                                   payment_item_id BIGINT NOT NULL,
                                                   tab_member_id   BIGINT NOT NULL,

                                                   customer_name   TEXT,
                                                   customer_email  TEXT,

                                                   item_quantity   INT NOT NULL,
                                                   item_total      NUMERIC(12,2) NOT NULL,
                                                   ticket_number   TEXT,

                                                   item_detail_json JSONB,
                                                   item_tab_json    JSONB,

                                                   payment_status       TEXT,
                                                   payment_total        NUMERIC(12,2),
                                                   payment_refund_total NUMERIC(12,2),
                                                   payment_created_at   TIMESTAMP,

    -- Signature fields
                                                   signature_url TEXT,
                                                   initials_url  TEXT,
                                                   signature_ip  TEXT,
                                                   device_info   TEXT,

    -- Metadata extracted from payments.metadata_exposed
                                                   payment_source TEXT,
                                                   thank_you_page TEXT,
                                                   fee_transparency BOOLEAN,
                                                   uses_payment_intents BOOLEAN,

                                                   card_brand TEXT,
                                                   card_last4 TEXT,
                                                   card_country TEXT,
                                                   card_funding TEXT,
                                                   card_exp_month INT,
                                                   card_exp_year INT,
                                                   card_fingerprint TEXT,
                                                   card_display_brand TEXT,
                                                   card_cvc_check TEXT,
                                                   card_address_postal_code_check TEXT,
                                                   card_three_d_secure_supported BOOLEAN,

                                                   payment_method_id TEXT,
                                                   payment_method_type TEXT,
                                                   livemode BOOLEAN,

                                                   billing_name TEXT,
                                                   billing_email TEXT,
                                                   billing_phone TEXT,
                                                   billing_postal_code TEXT,

    -- Pickup workflow fields (do NOT overwrite these during refresh)
                                                   pickup_status   TEXT DEFAULT 'pending',
                                                   pickup_ready_at TIMESTAMP NULL,
                                                   picked_up_at    TIMESTAMP NULL,
                                                   picked_up_by    TEXT NULL,
                                                   notes           TEXT NULL,

                                                   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2) Ensure required columns exist (safe to re-run)
DO $$
    BEGIN
        -- Add columns if table existed previously without them
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='ticket_number') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN ticket_number TEXT;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='signature_url') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN signature_url TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='initials_url') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN initials_url TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='signature_ip') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN signature_ip TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='device_info') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN device_info TEXT;
        END IF;

        -- Metadata columns
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='payment_source') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN payment_source TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='thank_you_page') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN thank_you_page TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='fee_transparency') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN fee_transparency BOOLEAN;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='uses_payment_intents') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN uses_payment_intents BOOLEAN;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='card_brand') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN card_brand TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='card_last4') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN card_last4 TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='card_country') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN card_country TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='card_funding') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN card_funding TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='card_exp_month') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN card_exp_month INT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='card_exp_year') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN card_exp_year INT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='card_fingerprint') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN card_fingerprint TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='card_display_brand') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN card_display_brand TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='card_cvc_check') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN card_cvc_check TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='card_address_postal_code_check') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN card_address_postal_code_check TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='card_three_d_secure_supported') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN card_three_d_secure_supported BOOLEAN;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='payment_method_id') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN payment_method_id TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='payment_method_type') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN payment_method_type TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='livemode') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN livemode BOOLEAN;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='billing_name') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN billing_name TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='billing_email') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN billing_email TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='billing_phone') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN billing_phone TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='cheddarup' AND table_name='order_pickup' AND column_name='billing_postal_code') THEN
            ALTER TABLE cheddarup.order_pickup ADD COLUMN billing_postal_code TEXT;
        END IF;
    END $$;

-- 3) Ensure unique constraint on payment_item_id (needed for ON CONFLICT upsert)
DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint
            WHERE conname = 'uq_order_pickup_payment_item'
              AND conrelid = 'cheddarup.order_pickup'::regclass
        ) THEN
            ALTER TABLE cheddarup.order_pickup
                ADD CONSTRAINT uq_order_pickup_payment_item UNIQUE (payment_item_id);
        END IF;
    END $$;

-- 4) Helpful indexes (safe to re-run)
CREATE INDEX IF NOT EXISTS ix_order_pickup_ticket_number
    ON cheddarup.order_pickup (ticket_number);

CREATE INDEX IF NOT EXISTS ix_order_pickup_payment_id
    ON cheddarup.order_pickup (payment_id);

CREATE INDEX IF NOT EXISTS ix_order_pickup_pickup_status
    ON cheddarup.order_pickup (pickup_status);

-- 5) Upsert refresh from source tables.
--    - Pull latest completed signature per payment (if multiple)
--    - Extract metadata_exposed JSON into columns
--    - DO NOT overwrite pickup workflow fields
WITH latest_sig AS (
    SELECT DISTINCT ON (payment_id)
        payment_id,
        signature_url,
        initials_url,
        ip,
        device_info
    FROM cheddarup.e_signatures
    WHERE status = 'completed'
    ORDER BY payment_id, created_at DESC
),
     src AS (
         SELECT
             p.id AS payment_id,
             pi.id AS payment_item_id,
             p.tab_member_id,

             tm.name  AS customer_name,
             tm.email AS customer_email,

             pi.quantity AS item_quantity,
             pi.total    AS item_total,
             pi.ticket_number,

             pi.detail::jsonb  AS item_detail_json,
             pi.tab_item::jsonb AS item_tab_json,

             p.status     AS payment_status,
             p.total      AS payment_total,
             p.total_refund AS payment_refund_total,
             p.created_at AS payment_created_at,

             ls.signature_url,
             ls.initials_url,
             ls.ip AS signature_ip,
             ls.device_info,

             -- Cast metadata_exposed to jsonb whether it's jsonb or text
             (p.metadata_exposed::jsonb) AS me
         FROM cheddarup.payments p
                  JOIN cheddarup.payment_items pi
                       ON pi.payment_id = p.id
                  LEFT JOIN cheddarup.tab_members tm
                            ON tm.id = p.tab_member_id
                  LEFT JOIN latest_sig ls
                            ON ls.payment_id = p.id
     )
INSERT INTO cheddarup.order_pickup (
    payment_id,
    payment_item_id,
    tab_member_id,
    customer_name,
    customer_email,
    item_quantity,
    item_total,
    ticket_number,
    item_detail_json,
    item_tab_json,
    payment_status,
    payment_total,
    payment_refund_total,
    payment_created_at,
    signature_url,
    initials_url,
    signature_ip,
    device_info,

    payment_source,
    thank_you_page,
    fee_transparency,
    uses_payment_intents,

    card_brand,
    card_last4,
    card_country,
    card_funding,
    card_exp_month,
    card_exp_year,
    card_fingerprint,
    card_display_brand,
    card_cvc_check,
    card_address_postal_code_check,
    card_three_d_secure_supported,

    payment_method_id,
    payment_method_type,
    livemode,

    billing_name,
    billing_email,
    billing_phone,
    billing_postal_code
)
SELECT
    s.payment_id,
    s.payment_item_id,
    s.tab_member_id,
    s.customer_name,
    s.customer_email,
    s.item_quantity,
    s.item_total,
    s.ticket_number,
    s.item_detail_json,
    s.item_tab_json,
    s.payment_status,
    s.payment_total,
    s.payment_refund_total,
    s.payment_created_at,
    s.signature_url,
    s.initials_url,
    s.signature_ip,
    s.device_info,

    -- analytics
    s.me #>> '{analytics,paymentSource}'                                   AS payment_source,
    s.me #>> '{analytics,thankYouPage}'                                   AS thank_you_page,
    NULLIF(s.me #>> '{analytics,feeTransparency}', '')::boolean           AS fee_transparency,
    NULLIF(s.me #>> '{analytics,pointOfSale,usesPaymentIntents}', '')::boolean AS uses_payment_intents,

    -- card fields (prefer intentPaymentMethod.card, fallback to top-level source)
    COALESCE(s.me #>> '{intentPaymentMethod,card,brand}',   s.me #>> '{source,brand}')   AS card_brand,
    COALESCE(s.me #>> '{intentPaymentMethod,card,last4}',   s.me #>> '{source,last4}')   AS card_last4,
    COALESCE(s.me #>> '{intentPaymentMethod,card,country}', s.me #>> '{source,country}') AS card_country,
    COALESCE(s.me #>> '{intentPaymentMethod,card,funding}', s.me #>> '{source,funding}') AS card_funding,
    NULLIF(s.me #>> '{intentPaymentMethod,card,exp_month}', '')::int                    AS card_exp_month,
    COALESCE(
            NULLIF(s.me #>> '{intentPaymentMethod,card,exp_year}', '')::int,
            NULLIF(s.me #>> '{source,exp_year}', '')::int
    ) AS card_exp_year,
    s.me #>> '{intentPaymentMethod,card,fingerprint}'                     AS card_fingerprint,
    s.me #>> '{intentPaymentMethod,card,display_brand}'                   AS card_display_brand,
    s.me #>> '{intentPaymentMethod,card,checks,cvc_check}'                AS card_cvc_check,
    s.me #>> '{intentPaymentMethod,card,checks,address_postal_code_check}'AS card_address_postal_code_check,
    NULLIF(s.me #>> '{intentPaymentMethod,card,three_d_secure_usage,supported}', '')::boolean AS card_three_d_secure_supported,

    -- payment method identity
    s.me #>> '{intentPaymentMethod,id}'        AS payment_method_id,
    s.me #>> '{intentPaymentMethod,type}'      AS payment_method_type,
    NULLIF(s.me #>> '{intentPaymentMethod,livemode}', '')::boolean AS livemode,

    -- billing details
    s.me #>> '{intentPaymentMethod,billing_details,name}'                    AS billing_name,
    s.me #>> '{intentPaymentMethod,billing_details,email}'                   AS billing_email,
    s.me #>> '{intentPaymentMethod,billing_details,phone}'                   AS billing_phone,
    s.me #>> '{intentPaymentMethod,billing_details,address,postal_code}'     AS billing_postal_code
FROM src s
-- Optional filter: only bring in certain payment statuses
-- WHERE s.payment_status IN ('available','completed')
ON CONFLICT (payment_item_id) DO UPDATE
    SET
        payment_id           = EXCLUDED.payment_id,
        tab_member_id        = EXCLUDED.tab_member_id,
        customer_name        = EXCLUDED.customer_name,
        customer_email       = EXCLUDED.customer_email,

        item_quantity        = EXCLUDED.item_quantity,
        item_total           = EXCLUDED.item_total,
        ticket_number        = EXCLUDED.ticket_number,
        item_detail_json     = EXCLUDED.item_detail_json,
        item_tab_json        = EXCLUDED.item_tab_json,

        payment_status       = EXCLUDED.payment_status,
        payment_total        = EXCLUDED.payment_total,
        payment_refund_total = EXCLUDED.payment_refund_total,
        payment_created_at   = EXCLUDED.payment_created_at,

        signature_url        = EXCLUDED.signature_url,
        initials_url         = EXCLUDED.initials_url,
        signature_ip         = EXCLUDED.signature_ip,
        device_info          = EXCLUDED.device_info,

        payment_source       = EXCLUDED.payment_source,
        thank_you_page       = EXCLUDED.thank_you_page,
        fee_transparency     = EXCLUDED.fee_transparency,
        uses_payment_intents = EXCLUDED.uses_payment_intents,

        card_brand           = EXCLUDED.card_brand,
        card_last4           = EXCLUDED.card_last4,
        card_country         = EXCLUDED.card_country,
        card_funding         = EXCLUDED.card_funding,
        card_exp_month       = EXCLUDED.card_exp_month,
        card_exp_year        = EXCLUDED.card_exp_year,
        card_fingerprint     = EXCLUDED.card_fingerprint,
        card_display_brand   = EXCLUDED.card_display_brand,
        card_cvc_check       = EXCLUDED.card_cvc_check,
        card_address_postal_code_check = EXCLUDED.card_address_postal_code_check,
        card_three_d_secure_supported  = EXCLUDED.card_three_d_secure_supported,

        payment_method_id    = EXCLUDED.payment_method_id,
        payment_method_type  = EXCLUDED.payment_method_type,
        livemode             = EXCLUDED.livemode,

        billing_name         = EXCLUDED.billing_name,
        billing_email        = EXCLUDED.billing_email,
        billing_phone        = EXCLUDED.billing_phone,
        billing_postal_code  = EXCLUDED.billing_postal_code;

-- 6) Delete rows where item_tab_json is "empty"
DELETE FROM cheddarup.order_pickup
WHERE item_tab_json IS NULL
   OR item_tab_json = '{}'::jsonb;

COMMIT;
