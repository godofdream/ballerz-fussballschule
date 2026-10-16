-- Ballerz Fussballschule D1 schema

CREATE TABLE IF NOT EXISTS products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  price_cents INTEGER NOT NULL,
  image_url TEXT,
  category TEXT,
  active INTEGER DEFAULT 1,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS camps (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  location TEXT NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  price_cents INTEGER NOT NULL,
  member_price_cents INTEGER,
  capacity INTEGER DEFAULT 30,
  spots_left INTEGER DEFAULT 30,
  description TEXT,
  active INTEGER DEFAULT 1,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS registrations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  camp_id INTEGER NOT NULL,
  child_name TEXT NOT NULL,
  child_birthdate TEXT,
  parent_name TEXT NOT NULL,
  parent_email TEXT NOT NULL,
  parent_phone TEXT,
  is_member INTEGER DEFAULT 0,
  stripe_session_id TEXT,
  status TEXT DEFAULT 'pending',
  amount_cents INTEGER,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (camp_id) REFERENCES camps(id)
);

CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  stripe_session_id TEXT UNIQUE,
  customer_email TEXT NOT NULL,
  customer_name TEXT,
  total_cents INTEGER NOT NULL,
  status TEXT DEFAULT 'pending',
  items_json TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS contact_messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  message TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_registrations_camp ON registrations(camp_id);
CREATE INDEX IF NOT EXISTS idx_registrations_email ON registrations(parent_email);
CREATE INDEX IF NOT EXISTS idx_orders_session ON orders(stripe_session_id);

INSERT OR IGNORE INTO camps (slug, title, location, start_date, end_date, price_cents, member_price_cents, description) VALUES
('sommer-offenbach-1', 'Sommercamp Offenbach', 'Offenbach', '2026-06-29', '2026-07-01', 22900, 19900, '3 Tage intensives Training'),
('sommer-offenbach-2', 'Sommercamp Offenbach', 'Offenbach', '2026-07-27', '2026-07-29', 22900, 19900, '3 Tage intensives Training'),
('sommer-diedesfeld', 'Sommercamp Diedesfeld', 'Diedesfeld', '2026-08-05', '2026-08-07', 22900, 19900, 'Standort Weinstrasse'),
('herbst-offenbach', 'Herbstcamp Offenbach', 'Offenbach', '2026-10-05', '2026-10-07', 22900, 19900, '3 Tage intensives Training'),
('herbst-diedesfeld', 'Herbstcamp Diedesfeld', 'Diedesfeld', '2026-10-12', '2026-10-14', 22900, 19900, 'Standort Weinstrasse');

INSERT OR IGNORE INTO products (slug, name, description, price_cents, category) VALUES
('academy-evo-rucksack', 'Academy Evo Rucksack', 'Robuster Trainingsrucksack', 2700, 'Rucksack'),
('draco-hero-bermuda', 'Draco Hero Bermuda Shorts', 'Trainingsshorts', 1600, 'Shorts'),
('jotnar-hose', 'Jotnar Hose', 'Trainings- und Freizeithose', 2600, 'Hose'),
('mesa-hero-shorts', 'Mesa Hero Shorts', 'Leichte Shorts', 1400, 'Shorts'),
('naryn-jacke', 'Naryn Jacke', 'Trainingsjacke', 7000, 'Jacke'),
('rigel-hero-trikot', 'Rigel Hero Trikot', 'Match- und Trainingstrikot', 2800, 'Trikot'),
('shedir-trikot', 'Shedir Trikot', 'Premium Trikot', 3800, 'Trikot'),
('sweatshirt-fraser', 'Sweatshirt FRASER', 'Warm-up Sweatshirt', 6500, 'Sweatshirt'),
('thames-hero-hose', 'Thames Hero Hose', 'Trainingshose', 4400, 'Hose'),
('trikot-wyrm', 'Trikot Wyrm', 'Trikot', 3800, 'Trikot'),
('windbreaker-praia', 'Windbreaker PRAIA HERO', 'Windbreaker', 4000, 'Jacke');
