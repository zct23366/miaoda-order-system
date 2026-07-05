-- ============================================================
-- SECTION: SCHEMA
-- ============================================================

--
-- PostgreSQL database dump
--


-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS "public";


--
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";


--
-- Name: EXTENSION "pg_graphql"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pg_graphql" IS 'pg_graphql: GraphQL support';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";


--
-- Name: EXTENSION "pgcrypto"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pgcrypto" IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";


--
-- Name: EXTENSION "supabase_vault"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "supabase_vault" IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: generate_order_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."generate_order_number"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.order_number := 'ORD-' || TO_CHAR(now(), 'YYYYMMDD') || '-' || LPAD(FLOOR(random() * 9000 + 1000)::text, 4, '0');
  RETURN NEW;
END;
$$;


--
-- Name: update_order_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."update_order_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: admin_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."admin_config" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "password" "text" DEFAULT 'admin123'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "default_lang" character varying(4) DEFAULT 'zh'::character varying NOT NULL,
    "print_width_mm" integer DEFAULT 50 NOT NULL,
    "print_height_mm" integer DEFAULT 70 NOT NULL,
    "print_auto" boolean DEFAULT false NOT NULL,
    "print_copies" integer DEFAULT 1 NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name_ja" "text",
    "name_en" "text",
    "name_ko" "text"
);


--
-- Name: order_item_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."order_item_options" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_item_id" "uuid",
    "option_id" "uuid",
    "option_name" "text" DEFAULT ''::"text" NOT NULL,
    "quantity" integer DEFAULT 1 NOT NULL,
    "unit_price" numeric(10,2) DEFAULT 0 NOT NULL,
    "subtotal" numeric(10,2) DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."order_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "product_name" "text" NOT NULL,
    "product_price" numeric(10,2) NOT NULL,
    "quantity" integer DEFAULT 1 NOT NULL,
    "subtotal" numeric(10,2) DEFAULT 0 NOT NULL
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_number" "text" NOT NULL,
    "status" "text" DEFAULT 'created'::"text" NOT NULL,
    "payment_method" "text",
    "total_amount" numeric(10,2) DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "customer_lang" "text" DEFAULT 'zh'::"text" NOT NULL
);


--
-- Name: COLUMN "orders"."customer_lang"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "public"."orders"."customer_lang" IS '顾客下单时的界面语言（zh/ja/en/ko）';


--
-- Name: payment_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."payment_config" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "wechat_enabled" boolean DEFAULT true NOT NULL,
    "wechat_qrcode_url" "text",
    "alipay_enabled" boolean DEFAULT true NOT NULL,
    "alipay_qrcode_url" "text",
    "paypay_enabled" boolean DEFAULT false NOT NULL,
    "paypay_qrcode_url" "text",
    "cash_enabled" boolean DEFAULT true NOT NULL,
    "admin_password_hash" "text" DEFAULT 'admin123'::"text" NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "wechat_rate" numeric(10,4) DEFAULT 1 NOT NULL,
    "alipay_rate" numeric(10,4) DEFAULT 1 NOT NULL,
    "paypay_rate" numeric(10,4) DEFAULT 1 NOT NULL,
    "cash_rate" numeric(10,4) DEFAULT 1 NOT NULL
);


--
-- Name: product_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."product_options" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid",
    "name_zh" "text" DEFAULT ''::"text" NOT NULL,
    "name_ja" "text" DEFAULT ''::"text" NOT NULL,
    "name_en" "text" DEFAULT ''::"text" NOT NULL,
    "name_ko" "text" DEFAULT ''::"text" NOT NULL,
    "image_url" "text",
    "price" numeric(10,2) DEFAULT 0 NOT NULL,
    "default_qty" integer DEFAULT 0 NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "enabled" boolean DEFAULT true NOT NULL,
    "deleted_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "category_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "price" numeric(10,2) DEFAULT 0 NOT NULL,
    "image_url" "text",
    "is_available" boolean DEFAULT true NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "detail_sections" "jsonb" DEFAULT '[]'::"jsonb",
    "name_ja" "text",
    "name_en" "text",
    "name_ko" "text",
    "description_ja" "text",
    "description_en" "text",
    "description_ko" "text"
);


--
-- Name: admin_config admin_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'admin_config_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'admin_config'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."admin_config"
    ADD CONSTRAINT "admin_config_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'categories_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_item_options order_item_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_item_options_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_item_options'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_item_options"
    ADD CONSTRAINT "order_item_options_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_items_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_items'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_order_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'orders_order_number_key'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_order_number_key" UNIQUE ("order_number");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'orders_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: payment_config payment_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'payment_config_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'payment_config'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."payment_config"
    ADD CONSTRAINT "payment_config_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_options product_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'product_options_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'product_options'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."product_options"
    ADD CONSTRAINT "product_options_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'products_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "orders_updated_at" BEFORE UPDATE ON "public"."orders" FOR EACH ROW EXECUTE FUNCTION "public"."update_order_updated_at"();


--
-- Name: orders set_order_number; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "set_order_number" BEFORE INSERT ON "public"."orders" FOR EACH ROW WHEN ((("new"."order_number" IS NULL) OR ("new"."order_number" = ''::"text"))) EXECUTE FUNCTION "public"."generate_order_number"();


--
-- Name: order_item_options order_item_options_option_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_item_options_option_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_item_options'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_item_options"
    ADD CONSTRAINT "order_item_options_option_id_fkey" FOREIGN KEY ("option_id") REFERENCES "public"."product_options"("id") ON DELETE SET NULL;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_item_options order_item_options_order_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_item_options_order_item_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_item_options'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_item_options"
    ADD CONSTRAINT "order_item_options_order_item_id_fkey" FOREIGN KEY ("order_item_id") REFERENCES "public"."order_items"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_items_order_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_items'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_items_product_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_items'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_options product_options_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'product_options_product_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'product_options'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."product_options"
    ADD CONSTRAINT "product_options_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'products_category_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: admin_config; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."admin_config" ENABLE ROW LEVEL SECURITY;

--
-- Name: categories anon_delete_categories; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_delete_categories'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_delete_categories" ON "public"."categories" FOR DELETE TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders anon_delete_orders; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_delete_orders'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_delete_orders" ON "public"."orders" FOR DELETE TO "anon" USING (false);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products anon_delete_products; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_delete_products'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_delete_products" ON "public"."products" FOR DELETE TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories anon_insert_categories; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_insert_categories'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_insert_categories" ON "public"."categories" FOR INSERT TO "anon" WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_item_options anon_insert_order_item_options; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_insert_order_item_options'
      AND n.nspname = 'public'
      AND c.relname = 'order_item_options'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_insert_order_item_options" ON "public"."order_item_options" FOR INSERT WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_items anon_insert_order_items; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_insert_order_items'
      AND n.nspname = 'public'
      AND c.relname = 'order_items'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_insert_order_items" ON "public"."order_items" FOR INSERT TO "anon" WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders anon_insert_orders; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_insert_orders'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_insert_orders" ON "public"."orders" FOR INSERT TO "anon" WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: payment_config anon_insert_payment_config; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_insert_payment_config'
      AND n.nspname = 'public'
      AND c.relname = 'payment_config'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_insert_payment_config" ON "public"."payment_config" FOR INSERT TO "anon" WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products anon_insert_products; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_insert_products'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_insert_products" ON "public"."products" FOR INSERT TO "anon" WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_item_options anon_read_order_item_options; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_read_order_item_options'
      AND n.nspname = 'public'
      AND c.relname = 'order_item_options'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_read_order_item_options" ON "public"."order_item_options" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_options anon_read_product_options; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_read_product_options'
      AND n.nspname = 'public'
      AND c.relname = 'product_options'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_read_product_options" ON "public"."product_options" FOR SELECT USING ((("deleted_at" IS NULL) AND ("enabled" = true)));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: admin_config anon_select_admin_config; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_select_admin_config'
      AND n.nspname = 'public'
      AND c.relname = 'admin_config'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_select_admin_config" ON "public"."admin_config" FOR SELECT TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories anon_select_categories; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_select_categories'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_select_categories" ON "public"."categories" FOR SELECT TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_items anon_select_order_items; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_select_order_items'
      AND n.nspname = 'public'
      AND c.relname = 'order_items'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_select_order_items" ON "public"."order_items" FOR SELECT TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders anon_select_orders; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_select_orders'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_select_orders" ON "public"."orders" FOR SELECT TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: payment_config anon_select_payment_config; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_select_payment_config'
      AND n.nspname = 'public'
      AND c.relname = 'payment_config'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_select_payment_config" ON "public"."payment_config" FOR SELECT TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products anon_select_products; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_select_products'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_select_products" ON "public"."products" FOR SELECT TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: admin_config anon_update_admin_config; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_update_admin_config'
      AND n.nspname = 'public'
      AND c.relname = 'admin_config'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_update_admin_config" ON "public"."admin_config" FOR UPDATE TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories anon_update_categories; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_update_categories'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_update_categories" ON "public"."categories" FOR UPDATE TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_items anon_update_order_items; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_update_order_items'
      AND n.nspname = 'public'
      AND c.relname = 'order_items'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_update_order_items" ON "public"."order_items" FOR UPDATE TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders anon_update_orders; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_update_orders'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_update_orders" ON "public"."orders" FOR UPDATE TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: payment_config anon_update_payment_config; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_update_payment_config'
      AND n.nspname = 'public'
      AND c.relname = 'payment_config'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_update_payment_config" ON "public"."payment_config" FOR UPDATE TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products anon_update_products; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_update_products'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "anon_update_products" ON "public"."products" FOR UPDATE TO "anon" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: admin_config authenticated_all_admin_config; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'authenticated_all_admin_config'
      AND n.nspname = 'public'
      AND c.relname = 'admin_config'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "authenticated_all_admin_config" ON "public"."admin_config" TO "authenticated" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_items authenticated_all_order_items; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'authenticated_all_order_items'
      AND n.nspname = 'public'
      AND c.relname = 'order_items'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "authenticated_all_order_items" ON "public"."order_items" TO "authenticated" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders authenticated_all_orders; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'authenticated_all_orders'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "authenticated_all_orders" ON "public"."orders" TO "authenticated" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: payment_config authenticated_all_payment_config; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'authenticated_all_payment_config'
      AND n.nspname = 'public'
      AND c.relname = 'payment_config'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "authenticated_all_payment_config" ON "public"."payment_config" TO "authenticated" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories authenticated_select_categories; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'authenticated_select_categories'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "authenticated_select_categories" ON "public"."categories" FOR SELECT TO "authenticated" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products authenticated_select_products; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'authenticated_select_products'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "authenticated_select_products" ON "public"."products" FOR SELECT TO "authenticated" USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."categories" ENABLE ROW LEVEL SECURITY;

--
-- Name: order_item_options; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."order_item_options" ENABLE ROW LEVEL SECURITY;

--
-- Name: order_items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."order_items" ENABLE ROW LEVEL SECURITY;

--
-- Name: orders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."orders" ENABLE ROW LEVEL SECURITY;

--
-- Name: payment_config; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."payment_config" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_options; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."product_options" ENABLE ROW LEVEL SECURITY;

--
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;

--
-- Name: order_item_options service_all_order_item_options; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'service_all_order_item_options'
      AND n.nspname = 'public'
      AND c.relname = 'order_item_options'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "service_all_order_item_options" ON "public"."order_item_options" USING (true) WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_options service_all_product_options; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'service_all_product_options'
      AND n.nspname = 'public'
      AND c.relname = 'product_options'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "service_all_product_options" ON "public"."product_options" USING (true) WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- PostgreSQL database dump complete
--




-- ============================================================
-- SECTION: DIFF FILTER OBJECTS
-- ============================================================
-- Objects that match diff-filter.json but cannot be represented
-- precisely by pg_dump --filter.

-- policy: anon_delete_menu_images on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_delete_menu_images'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY anon_delete_menu_images ON storage.objects AS PERMISSIVE FOR DELETE TO anon USING ((bucket_id = ''menu-images''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: anon_delete_payment_qrcodes on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_delete_payment_qrcodes'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY anon_delete_payment_qrcodes ON storage.objects AS PERMISSIVE FOR DELETE TO anon USING ((bucket_id = ''payment-qrcodes''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: anon_update_menu_images on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_update_menu_images'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY anon_update_menu_images ON storage.objects AS PERMISSIVE FOR UPDATE TO anon USING ((bucket_id = ''menu-images''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: anon_update_payment_qrcodes on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_update_payment_qrcodes'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY anon_update_payment_qrcodes ON storage.objects AS PERMISSIVE FOR UPDATE TO anon USING ((bucket_id = ''payment-qrcodes''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: anon_upload_menu_images on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_upload_menu_images'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY anon_upload_menu_images ON storage.objects AS PERMISSIVE FOR INSERT TO anon WITH CHECK ((bucket_id = ''menu-images''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: anon_upload_payment_qrcodes on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'anon_upload_payment_qrcodes'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY anon_upload_payment_qrcodes ON storage.objects AS PERMISSIVE FOR INSERT TO anon WITH CHECK ((bucket_id = ''payment-qrcodes''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: public_read_menu_images on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'public_read_menu_images'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY public_read_menu_images ON storage.objects AS PERMISSIVE FOR SELECT TO anon USING ((bucket_id = ''menu-images''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: public_read_payment_qrcodes on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'public_read_payment_qrcodes'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY public_read_payment_qrcodes ON storage.objects AS PERMISSIVE FOR SELECT TO anon USING ((bucket_id = ''payment-qrcodes''::text));';
  END IF;
END
$pg_schema_restore$;
-- publication table: supabase_realtime -> public.orders
DO $pg_schema_restore$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') AND NOT EXISTS (
    SELECT 1 FROM pg_publication_rel pr
    JOIN pg_publication p ON p.oid = pr.prpubid
    WHERE p.pubname = 'supabase_realtime'
      AND pr.prrelid = to_regclass('public.orders')
  ) THEN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;';
  END IF;
END
$pg_schema_restore$;

-- ============================================================
-- SECTION: STORAGE BUCKETS DATA
-- ============================================================

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('menu-images', 'menu-images', NULL, '2026-06-30 04:40:06.328167+00', '2026-06-30 04:40:06.328167+00', 'true', 'false', NULL, NULL, NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";
INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('payment-qrcodes', 'payment-qrcodes', NULL, '2026-06-30 04:40:06.328167+00', '2026-06-30 04:40:06.328167+00', 'true', 'false', NULL, NULL, NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";
