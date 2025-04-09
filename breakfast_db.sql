--===================
-- Initialize Tables
--------------------

-- Clear old:
DROP TABLE IF EXISTS demo;
DROP TABLE IF EXISTS USER;
DROP TABLE IF EXISTS UNIT;
DROP TABLE IF EXISTS USER_PERMS;
DROP TABLE IF EXISTS REGION;
DROP TABLE IF EXISTS BLOG_REVIEW;
DROP TABLE IF EXISTS BLOG;
DROP TABLE IF EXISTS RECIPE;
DROP TABLE IF EXISTS BLOG_INGREDIENT;
DROP TABLE IF EXISTS BLOG_INGREDIENT_ALT;
DROP TABLE IF EXISTS INGREDIENT;

DROP TRIGGER IF EXISTS enforce_blog_perm_validity;
DROP TRIGGER IF EXISTS preserve_blog_perm_validity;

-- Create the tables:

CREATE TABLE USER (
    id INT PRIMARY KEY,
  	username VARCHAR(25) UNIQUE NOT NULL,
  	password VARCHAR(20) NOT NULL,
    email VARCHAR(45) UNIQUE
);

CREATE TABLE USER_PERMS (
    uid INT,
    perm_lvl INT CHECK (perm_lvl IN (-1, 1)),  
  	-- lvl -1:     viewer only (violator)
  	-- not listed: view + post (normal user)
  	-- lvl 1:      view + post + approve posts (mod)
  
  	PRIMARY KEY (uid),
    FOREIGN KEY (uid) REFERENCES USER(id)
);

CREATE TABLE REGION (
  code VARCHAR(5) PRIMARY KEY,
  name VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE UNIT (
  name VARCHAR(20) PRIMARY KEY
);

CREATE TABLE INGREDIENT (
  id INT PRIMARY KEY,
  name VARCHAR(30)
);
 

CREATE TABLE BLOG (
  	id INT PRIMARY KEY,
  
  	recipe_id INT NOT NULL,
  	author_id INT NOT NULL,
  	region_id VARCHAR(5),
  
  	mod_id INT, -- if null, not approved yet for viewing
  	title VARCHAR(20) NOT NULL, 
  	INSTRUCTS TEXT NOT NULL, 
  
  	prep_time TIME,
  	difficulty_lvl INT NOT NULL check (difficulty_lvl BETWEEN 1 AND 5),
  
  	UNIQUE (recipe_id, region_id, author_id),
  	
  	FOREIGN KEY (recipe_id) REFERENCES RECIPE(id),
  	FOREIGN KEY (author_id) REFERENCES USER(id),
  	FOREIGN KEY (region_id) REFERENCES REGION(code),
  	FOREIGN KEY (mod_id) REFERENCES USER(id)
);

CREATE TABLE BLOG_REVIEW (
	blog_id INT, 
    reviewer_id INT,
   
   comment TEXT,
   rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
   
   PRIMARY KEY (blog_id, reviewer_id),
   FOREIGN KEY (blog_id) REFERENCES BLOG(id),
   FOREIGN KEY (reviewer_id) REFERENCES USER(id)
);

-- https://www.sqlitetutorial.net/sqlite-trigger/
CREATE TRIGGER enforce_blog_perm_validity
    BEFORE INSERT ON BLOG
    FOR EACH ROW
BEGIN
    -- Check if mod_id has sufficient permissions
    SELECT RAISE(ABORT, 'Invalid BLOG mod_id: Invalid or insufficient permissions (INSERT).')
    WHERE NEW.mod_id IS NOT NULL
    AND (SELECT perm_lvl FROM USER_PERMS WHERE uid = NEW.mod_id) <= 0;

    -- Check if author_id has sufficient permissions
    SELECT RAISE(ABORT, 'Invalid BLOG author_id: Invalid or insufficient permissions. (INSERT)')
    WHERE (SELECT perm_lvl FROM USER_PERMS WHERE uid = NEW.author_id) < 0;
END;

CREATE TRIGGER preserve_blog_perm_validity
    BEFORE UPDATE ON BLOG
    FOR EACH ROW
BEGIN
    -- Check if mod_id has sufficient permissions
    SELECT RAISE(ABORT, 'Invalid BLOG mod_id: Invalid or insufficient permissions. (UPDATE)')
    WHERE NEW.mod_id IS NOT NULL
    AND (SELECT perm_lvl FROM USER_PERMS WHERE uid = NEW.mod_id) <= 0;

    -- Check if author_id has sufficient permissions
    SELECT RAISE(ABORT, 'Invalid BLOG author_id: Invalid or insufficient permissions (UPDATE).')
    WHERE (SELECT perm_lvl FROM USER_PERMS WHERE uid = NEW.author_id) < 0;
END;
--

CREATE TABLE RECIPE (
	id INT PRIMARY KEY, 
  
  	name VARCHAR(20) UNIQUE NOT NULL, 
  	description TEXT
);


CREATE TABLE BLOG_INGREDIENT (
	blog_id INT, 
  	ingredient_id INT,
  
  	quantity REAL, 
    unit VARCHAR(20),
  
  	PRIMARY KEY (blog_id, ingredient_id),
  
  	FOREIGN KEY (unit) REFERENCES UNIT(name),
  	FOREIGN KEY (blog_id) REFERENCES BLOG(id),
  	FOREIGN KEY (ingredient_id) REFERENCES INGREDIENT(id)
);

CREATE TABLE BLOG_INGREDIENT_ALT (
	blog_id INT,
  	standard_ingredient_id INT,
  	alt_ingredient_id INT,
  
  	quantity REAL, 
    unit VARCHAR(20),
  
  	PRIMARY KEY (blog_id, standard_ingredient_id, alt_ingredient_id),
  
  	FOREIGN KEY (unit) REFERENCES UNIT(name),
  	FOREIGN KEY (blog_id) REFERENCES BLOG(id),
  	FOREIGN KEY (standard_ingredient_id) REFERENCES INGREDIENT(id),
  	FOREIGN KEY (alt_ingredient_id) REFERENCES INGREDIENT(id)
); 

--===================
-- Fill tables with sample data
--------------------

-- Provide accepted units
INSERT INTO UNIT (name) VALUES
('cup'),
('spoon'),
('tablespoon'),
('gram')
;

-- Fill regions table:
INSERT INTO REGION (code, name) VALUES
('NA', 'North America'),
('EU', 'Europe'),
('AS', 'Asia'),
('SA', 'South America'),
('AF', 'Africa'),
('IN', 'India'),
('MENA', 'Middle East'),
('MEDIT', 'Mediterranean'),
('CAR', 'Caribbean'),
('MX', 'Mexico'),
('JO', 'Jordan'),
('TUR', 'Turkiye')
;

-- Create new users:
INSERT INTO USER (id, username, password, email) VALUES
(1, 'teacupTaster', 'pass123', 'king@breakfast.com'),
(2, 'earlyBird', 'bird123', 'bird@morning.com'),
(3, 'hashbrownHero', 'toast456', NULL),
(4, 'EggMaster', 'eggy789', 'master@egg.com')
;

-- Assign users as mods/violators: 
INSERT INTO USER_PERMS (uid, perm_lvl) VALUES
(3, -1),
(4, 1)
;

-- Add ingredients
INSERT INTO INGREDIENT (id, name) VALUES 
(1, 'Egg'),
(2, 'Soy sauce'),
(3, 'Vegetable oil'),
(4, 'Olive oil'),
(5, 'Potato'),
(6, 'Salt'),
(7, 'Water'),
(8, 'Onion'),
(9, 'Bell pepper'),
(10, 'Chili powder'),
(11, 'Cumin'),
(12, 'Paprika'),
(13, 'Parsley'),
(14, 'Garlic'),
(15, 'Chia seeds'),
(16, 'Milk'),
(17, 'Lox'),
(18, 'Avocado'),
(19, 'Bagel'),
(20, 'Spinach'),
(21, 'Banana'),
(22, 'Honey'),
(23, 'Flaxseeds'),
(24, 'Tortilla wrap'),
(25, 'Tomato paste'),
(26, 'Simit'),
(27, 'Eggplant'),
(28, 'Chicken breast'),
(29, 'Fig'),
(30, 'Cucumber'),
(31, 'Olives'),
(32, 'Feta cheese'),
(33, 'Ground chickpeas'),
(34, 'Almond milk'),
(35, 'Whole wheat bagel'),
(36, 'Maple syrup'),
(37, 'Sweet potatoes'),
(38, 'Pita bread'),
(39, 'Zucchini'),
(40, 'Black beans')
;

-- Add recipes
INSERT INTO RECIPE (id, name, description) VALUES 
(1, 'Rolled Omelet', 'Dish made by rolling layers of seasoned eggs.'),
(2, 'Boiled egg', 'Simple and nutritious breakfast item made by cooking an egg in its shell in boiling water. Can be prepared soft-boiled or hard-boiled.'),
(3, 'Shakshuka', 'Middle Eastern and North African dish made by poaching eggs in a sauce of tomatoes, peppers, and onions, seasoned with spices like cumin and paprika. This savory and aromatic dish is often served for breakfast or brunch, accompanied by bread for dipping.'),
(4, 'Chia pudding', 'Healthy and versatile dish made by soaking chia seeds in liquid, such as milk or a plant-based alternative, until they form a gel-like consistency. Often sweetened and flavored with ingredients like vanilla, honey, or fruit, chia pudding is typically served as a nutritious breakfast or dessert.'),
(5, 'Salmon bagel', 'Breakfast or brunch dish made by layering smoked salmon on a sliced and toasted bagel, typically spread with cream cheese. Often garnished with toppings such as capers, red onions, & fresh dill, this savory meal combines creamy, smoky, & tangy flavors.'),
(6, 'Energy smoothie', 'Nutritious drink made by blending fruits, vegetables, and other ingredients like yogurt, milk, or a plant-based alternative. Often enhanced with protein powder, nuts, seeds, or greens for an extra boost, this smoothie is designed to provide sustained energy and essential nutrients, making it a popular choice for breakfast or a post-workout snack.'),
(7, 'Breakfast burrito', 'Flour tortilla wrapped around a filling of scrambled eggs, cheese, and other ingredients such as sausage, potatoes, beans, and vegetables. Often served with salsa, sour cream, or avocado, this savory and customizable dish is perfect for a quick and satisfying breakfast.'),
(8, 'Menmen', 'Traditional Turkish dish made by cooking scrambled eggs with tomatoes, green peppers, and onions, seasoned with spices like paprika and pepper. Often enjoyed for breakfast or brunch, this savory and flavorful dish is typically served with bread for dipping.'),
(9, 'Mezze', 'A selection of small dishes served as appetizers in Middle Eastern and Mediterranean cuisines. Common components include hummus, baba ghanoush, tabbouleh, falafel, dolmas, and a variety of olives and cheeses. Mezze is often enjoyed with pita bread and serves as a communal and flavorful start to a meal or as a light, shared meal on its own.'),
(10, 'Hummus', 'Creamy and savory dip made from blended chickpeas and other ingredients.'),
(11, 'Hashbrown', 'Crispy and golden breakfast dish made from grated or finely chopped potatoes, often mixed with onions and seasoning, then fried until browned and crunchy. Hashbrowns are commonly served as a side dish in American breakfasts, complementing eggs, bacon, and other breakfast items.')
;

-- Blogs
INSERT INTO BLOG (id, recipe_id, author_id, mod_id, title, region_id, prep_time, difficulty_lvl, instructs) VALUES
(1, 1, 1, 2, 'Japanese Tamagoyaki', 'AS', '00:20:00', 3, 'Tamagoyaki layers are thin, rectangular, and typically seasoned with soy sauce, sugar, and mirin. This slightly sweet and savory omelet can be served in traditional breakfast or as a topping.\n\n1. In a bowl, mix together eggs with soy sauce, sugar, and mirin until well combined.\n2. Heat a rectangular tamagoyaki pan over medium heat and lightly oil it.\n3. Pour a thin layer of the egg mixture into the pan, tilting to spread evenly.\n4. When the egg is almost set, roll it to one side of the pan.\n5. Add another thin layer of egg mixture, lifting the rolled omelet to let the uncooked egg flow underneath.\n6. Once this layer is nearly set, roll the omelet again, incorporating the first roll.\n\nRepeat steps 5 and 6 until all the egg mixture is used.\n\nRemove the omelet from the pan and let it cool slightly before slicing. Serve warm or at room temperature.'),
(2, 2, 1, 2, 'Perfect Boiled Egg', NULL, '00:10:00', 1, 'After boiling a pot of water (enough to fully submerge the egg(s)), gently add in the eggs and leave them to cook.\n\nFor soft-boiled eggs (runny yolk and slightly set white), cook for about 6-8 minutes.\n\nFor hard-boiled (fully set yolk and white), cook for about 9-12 minutes.'),
(3, 3, 2, 2, 'Spicy Shakshuka', 'MEDIT', '00:30:00', 2, 'Cook vegetables and poach eggs in sauce.'),
(5, 5, 1, 2, 'Classic Salmon Bagel', NULL, '00:10:00', 1, 'Assemble ingredients on a bagel.'),
(6, 6, 2, 2, 'Energy Smoothie', NULL, '00:05:00', 1, 'Blend all ingredients together.'),
(7, 7, 4, 2, 'Breakfast Burrito', 'MX', '00:15:00', 2, 'Fill tortilla with cooked ingredients.'),
(8, 8, 1, 2, 'Turkish Menmen', 'TUR', '00:25:00', 2, 'Cook vegetables and eggs together.'),
(9, 9, 2, 2, 'Jordanian Mezze', 'JO', '00:30:00', 3, 'Prepare and arrange ingredients.'),
(11, 11, 4, 2, 'Crispy Hashbrowns', NULL, '00:20:00', 2, 'Shred and fry potatoes.')
;

-- Ingredients for blog
INSERT INTO BLOG_INGREDIENT (blog_id, ingredient_id, quantity, unit) VALUES 
(1, 1, 3, 'whole'), -- Rolled Omelet: eggs
(1, 2, 2, 'tbsp'),  -- Rolled Omelet: soy sauce
(1, 3, 1, 'tbsp'),
(1, 4, 1, 'tsp'),
(1, 5, 1, 'tsp'),
(1, 6, 1, 'cup'),
(2, 1, 2, 'whole'),
(2, 7, 2, 'cups'),
(3, 1, 4, 'whole'),
(3, 8, 1, 'whole'),
(3, 9, 1, 'whole'),
(3, 4, 2, 'tbsp'),
(3, 10, 1, 'tsp'),
(3, 11, 1, 'tsp'),
(3, 12, 1, 'tsp'),
(3, 13, 2, 'tbsp'),
(3, 14, 2, 'cloves'),
(4, 15, 1, 'cup'),
(4, 16, 1, 'cup'),
(5, 17, 2, 'slices'),
(5, 18, 1, 'whole'),
(5, 19, 1, 'whole'),
(11, 5, 2, 'whole'),
(11, 4, 2, 'tbsp'),
(6, 20, 1, 'cup'),
(6, 21, 1, 'whole'),
(6, 22, 1, 'tbsp'),
(6, 23, 1, 'tbsp'),
(7, 24, 1, 'whole'),
(7, 1, 2, 'whole'),
(7, 5, 1, 'whole'),
(8, 1, 3, 'whole'),
(8, 9, 2, 'whole'),
(8, 8, 1, 'whole'),
(8, 4, 1, 'tsp'),
(8, 6, 1, 'tsp'),
(8, 25, 2, 'tbsp'),
(8, 26, 1, 'whole'),
(9, 27, 1, 'whole'),
(9, 10, 2, 'tbsp'),
(9, 28, 1, 'whole'),
(9, 29, 1, 'whole'),
(9, 30, 1, 'whole'),
(9, 9, 2, 'whole'),
(9, 31, 1, 'cup'),
(9, 32, 1, 'cup'),
(10, 33, 2, 'cups'),
(10, 4, 2, 'tbsp')
;

-- Alternative ingredients
DELETE FROM BLOG_INGREDIENT_ALT;
INSERT INTO BLOG_INGREDIENT_ALT (blog_id, standard_ingredient_id, alt_ingredient_id) VALUES 
(11, 4, 3),
(6, 22, 36),
(1, 3, 4),
(7, 5, 37),
(2, 1, 2),
(8, 26, 38),
(3, 4, 3),
(9, 27, 39),
(4, 16, 34),
(10, 33, 40),
(5, 19, 35)
;

-- Reviews for a blog
INSERT INTO BLOG_REVIEW (blog_id, reviewer_id, rating, comment) VALUES 
(1, 1, 5, 'Delicious and authentic!'),
(2, 2, 4, 'Simple and easy to make.'),
(2, 3, 4, '10 minutes is too much. It really depends on your stove.'),
(3, 3, 5, 'Spicy and flavorful.'),
(4, 4, 3, 'Healthy but a bit bland. Personally, I like it with a bit of cinnamon.'),
(4, 1, 2, 'How is this a breakfast item??'),
(5, 1, 2, 'Who eats salmon for breakfast?'),
(6, 2, 4, 'Refreshing and energizing.'),
(7, 3, 5, 'Filling and tasty.'),
(8, 4, 5, 'Amazing traditional flavor.'),
(9, 1, 4, 'A great variety of flavors.'),
(10, 2, 5, 'Smooth and creamy.'),
(11, 3, 5, 'Crispy and perfect.')
;

--===================
-- Operative Queries
--------------------

-- [Q] What Turkish (code = TUR) blogs have a prep_time <= 10 or prep_time is null?
SELECT *
FROM BLOG
WHERE region_id = 'TUR'
  AND (prep_time <= '00:10:00' OR prep_time IS NULL)
;

-- [Q] What blogs do not contain the ingredients Maple syrup (id = 36) or olive oil (id = 4)?
SELECT b.*
FROM BLOG b
WHERE b.id NOT IN (
    SELECT bi.blog_id
    FROM BLOG_INGREDIENT bi
    JOIN INGREDIENT i ON bi.ingredient_id = i.id
    WHERE i.name IN ('Maple syrup', 'Olive oil')
);

-- [Q] What blogs have a difficulty level of 3 or less, and 4+ average star ratings?
SELECT BLOG.*
FROM BLOG 
JOIN (
      SELECT BLOG_REVIEW.blog_id, AVG(BLOG_REVIEW.rating) AS avg_rating
      FROM BLOG_REVIEW 
      GROUP BY BLOG_REVIEW.blog_id
      HAVING AVG(BLOG_REVIEW.rating) >= 4
  ) avg_ratings ON BLOG.id = avg_ratings.blog_id
WHERE BLOG.difficulty_lvl <= 3
;

-- [Q] (For testing purposes)
--		Show all blog alternatives, but by name, not id.
SELECT 
    ia.blog_id,
    si.name AS standard_ingredient,
    ai.name AS alt_ingredient,
    ia.quantity,
    ia.unit
FROM BLOG_INGREDIENT_ALT ia
JOIN INGREDIENT si ON ia.standard_ingredient_id = si.id
JOIN INGREDIENT ai ON ia.alt_ingredient_id = ai.id
;

-- [Q] What alternative can I use for 'Olive oil' (id = 4) in the blog 'Hashbrown' (id = 11)?
-- (A: 'Vegetable oil, id = 3)
SELECT BLOG_INGREDIENT_ALT.alt_ingredient_id, INGREDIENT.name AS alt_ingredient_name
FROM BLOG_INGREDIENT_ALT 
JOIN BLOG ON BLOG_INGREDIENT_ALT.blog_id = BLOG.id
JOIN INGREDIENT ON BLOG_INGREDIENT_ALT.alt_ingredient_id = INGREDIENT.id
WHERE BLOG.title = 'Crispy Hashbrowns'
AND BLOG_INGREDIENT_ALT.standard_ingredient_id = (SELECT id FROM INGREDIENT WHERE name = 'Olive oil')
;

-- [Q] Which region is the blog 'Creamy Hummus' (id = 10) for?
SELECT r.code, r.name
FROM BLOG b
JOIN REGION r ON b.region_id = r.code
WHERE b.title = 'Creamy Hummus'
;

-- [Q] Sort top 5 posts (with 2+ reviews) by their average rating.
SELECT b.id, b.title, AVG(br.rating) AS avg_rating, COUNT(br.blog_id) AS review_count
FROM BLOG b
JOIN BLOG_REVIEW br ON b.id = br.blog_id
GROUP BY b.id, b.title
	HAVING COUNT(br.blog_id) >= 2
ORDER BY avg_rating DESC
LIMIT 5 -- Only show top 5
;

-- [Q] Add new blogs for a recipe:
INSERT INTO BLOG (id, recipe_id, author_id, mod_id, title, region_id, prep_time, difficulty_lvl, INSTRUCTS)
VALUES 
(4, 4, 4, 4, 'It’s Mexican?', 'MX', '00:15:00', 1, 'Mix chia seeds with milk and refrigerate.'),
(14, 4, 2, 4, 'Almondy CP', NULL, '00:25:00', 1, 'Mix chia seeds with almond milk and almonds.'),
(15, 4, 2, 4, 'Nutritious Chia', NULL, '00:20:00', 2, 'Mix chia seeds with milk, almonds, flax seeds, honey, and banana.'),
(16, 4, 1, 4, 'Plain Pudding', NULL, '00:25:00', 1, 'Mix chia seeds in water.')
;

-- [Q] What are the reviews on 'earlyBird''s (id = 2) blog?
--     Purpose: Analyze user trends to review permission levels. 
SELECT BR.blog_id, BR.reviewer_id, BR.rating, BR.comment
FROM BLOG_REVIEW BR
JOIN BLOG B ON BR.blog_id = B.id
JOIN USER U ON B.author_id = U.id
WHERE U.username = 'earlyBird'
;

-- [Q] What are the reivews BY 'earlyBird'? 
--     Purpose: Analyze user trends to review permission levels. 
SELECT BLOG_REVIEW.comment, BLOG_REVIEW.rating
FROM BLOG_REVIEW
WHERE reviewer_id = (SELECT id FROM USER WHERE username = 'earlyBird')
;

-- [Q] Which blogs are not yet approved (mod_id is null)?
SELECT *
FROM BLOG
WHERE mod_id IS NULL
;

-- [Q] Remove a blog from viewing. 
UPDATE BLOG
SET mod_id = NULL
WHERE id = 2
;

-- [Q] Accept a blog for viewing.
UPDATE BLOG
SET mod_id = 4
WHERE id = 2
;

-- [Q] EggMaster (id = 4) approve blog 1 (Tamagoyaki). 
UPDATE BLOG
SET mod_id = 4
WHERE title = 'Japanese Rolled Omelet (Tamagoyaki)';

-- [Q] Update the rating of a blog_review
UPDATE BLOG_REVIEW
SET rating = 4
WHERE blog_id = 4 AND reviewer_id = 4
;

-- [Q] Update the email of a user:
UPDATE USER
SET email = 'gotTheWorm@outlook.com'
WHERE username = 'earlyBird'
;

-- [Q] Update a user password:
UPDATE USER
SET password = 'ch1rp1ng@w@y'
WHERE id = 4
;

-- [Q] Create a table that support favorite recipes for each unique user
--     Note: Change "recipe" to "blog"
DROP TABLE IF EXISTS USER_FAVORITE;
CREATE TABLE USER_FAVORITE (
  uid INT, 
  blog_id INT,
  
  PRIMARY KEY (uid, blog_id),
  FOREIGN KEY (uid) REFERENCES USER(id),
  FOREIGN KEY (blog_id) REFERENCES BLOG(id)
);


-- [Q] List all Mexican recipes that:
-- 		* Do NOT include bellpeppers, 
--		* Take longer than 20 minutes to make.
INSERT INTO BLOG (id, recipe_id, author_id, mod_id, title, region_id, prep_time, difficulty_lvl, INSTRUCTS)
VALUES 
(20, 4, 1, 4, 'Mexican Chia Pudding', 'MX', '00:30:00', 1, 'Coming soon...')
;


SELECT DISTINCT BLOG.title, BLOG.prep_time
FROM BLOG
LEFT JOIN BLOG_INGREDIENT on BLOG_INGREDIENT.blog_id = BLOG.id
WHERE BLOG.region_id = 'MX'
	AND BLOG.prep_time > '00:20:00'
    AND BLOG_INGREDIENT.ingredient_id is NOT 9
;


-- [Q] Find the top 3 regions with the most ingredient associated with them.
-- [Q] (Updated) Find the top blogs with the most ingredients associated with them.BLOG
SELECT BLOG.title, COUNT(BLOG_INGREDIENT.blog_id) AS instance_count
FROM BLOG
LEFT JOIN BLOG_INGREDIENT ON BLOG.id = BLOG_INGREDIENT.blog_id
GROUP BY BLOG.title
ORDER BY instance_count
LIMIT 3
;


