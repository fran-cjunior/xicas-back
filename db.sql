-- Create table for administrators
CREATE TABLE admins (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL, -- Password hash for security
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create table for products
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    barcode TEXT,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    cost NUMERIC(10, 2) NOT NULL,
    quantity NUMERIC(10, 2) NOT NULL,
    image TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create table for sales
CREATE TABLE sales (
  id SERIAL PRIMARY KEY,
  saler_id INTEGER REFERENCES admins(id),
  products JSONB NOT NULL DEFAULT '[]',
  payment_types JSONB NOT NULL DEFAULT '{"money": 0, "pix": 0, "debit": 0, "credit": 0, "other": 0}',
  general_discount FLOAT NOT NULL DEFAULT 0,
  sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CREATE TABLE sales (
--     id SERIAL PRIMARY KEY,
--     product_id INT NOT NULL,
--     quantity INT NOT NULL,
--     total NUMERIC(10, 2) NOT NULL,
--     admin_id INT,
--     sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     CONSTRAINT fk_product_sale FOREIGN KEY (product_id) REFERENCES products (id),
--     CONSTRAINT fk_admin_sale FOREIGN KEY (admin_id) REFERENCES admins (id)
-- );

CREATE FUNCTION update_product_quantity_on_sale() RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET quantity = quantity - NEW.quantity, updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_sale_insert
AFTER INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION update_product_quantity_on_sale();