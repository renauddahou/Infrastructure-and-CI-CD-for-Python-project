CREATE TABLE IF NOT EXISTS dogs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name TEXT CHARACTER SET utf16 COLLATE utf16_unicode_ci NOT NULL
);

INSERT INTO dogs (name)
SELECT 'Bruno'
WHERE NOT EXISTS (SELECT * FROM dogs);