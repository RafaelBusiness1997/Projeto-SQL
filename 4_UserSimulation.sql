/*
This script runs queries to simulate the database's behavior during the user experience.
This includes inserting records into tables, and running queries for obtaining specific data.
This serves to check if the database's structure supports the app's intended behaviors.
The queries that run here are part of a transaction that is rolled back after the fact.
This way, test data doesn't remain in the database and spoil data integrity when real app data starts being introduced.
*/

USE `task_buddy`;

START TRANSACTION;

/* User creation. */
INSERT INTO `user` (`email`, `password`)
VALUES
("JohnDoe@gmail.com", "John123"),
("JaneDoe@gmail.com", "Jane123"),
("FrancisLane@gmail.com", "FrancisPass");

SET @john_id = (SELECT `id` FROM `user` WHERE `email` = "JohnDoe@gmail.com");
SET @daily_id = (SELECT `id` FROM `task_type` WHERE `type` = "Daily");
SET @weekly_id = (SELECT `id` FROM `task_type` WHERE `type` = "Weekly");
SET @date_id = (SELECT `id` FROM `task_type` WHERE `type` = "Date Specific");

SELECT * FROM `user`;

/* User creates new task templates. */
INSERT INTO `task_template` (`id_user`, `id_task_type`, `title`, `default_order`, `day_of_week`, `specific_date`)
VALUES
(@john_id, @daily_id, "Shower", 1, NULL, NULL),
(@john_id, @daily_id, "Breakfast", 2, NULL, NULL),
(@john_id, @weekly_id, "Groceries", 3, "Sunday", NULL),
(@john_id, @date_id, "Mom's Birthday", 4, NULL, "2026-03-31");

SET @shower_temp_id = (SELECT `id` FROM `task_template` WHERE `id_user` = @john_id AND `title` = "Shower");
SET @breakfast_temp_id = (SELECT `id` FROM `task_template` WHERE `id_user` = @john_id AND `title` = "Breakfast");
SET @groceries_temp_id = (SELECT `id` FROM `task_template` WHERE `id_user` = @john_id AND `title` = "Groceries");
SET @mom_temp_id = (SELECT `id` FROM `task_template` WHERE `id_user` = @john_id AND `title` = "Mom's Birthday");

SELECT * FROM `task_template`;

/* User creates new category. */
INSERT INTO `task_category` (`id_user`, `category`)
VALUES
(@john_id, "Self Care");

SET @care_id = (SELECT `id` FROM `task_category` WHERE `category` = "Self Care");

SELECT * FROM `task_category`;

/* User adds tasks to a category. */
UPDATE `task_template` SET `id_task_category` = @care_id WHERE `id_user` = @john_id AND `id` = @shower_temp_id;
UPDATE `task_template` SET `id_task_category` = @care_id WHERE `id_user` = @john_id AND `id` = @breakfast_temp_id;

SELECT `task_template`.`title`, `task_category`.`category`
FROM `task_template`
INNER JOIN `task_category` ON `task_template`.`id_task_category` = `task_category`.`id`;

/* User removes a task from a category. */
UPDATE `task_template` SET `id_task_category` = NULL WHERE `id_user` = @john_id AND `id` = @breakfast_temp_id;

SELECT `task_template`.`title`, `task_category`.`category`
FROM `task_template`
INNER JOIN `task_category` ON `task_template`.`id_task_category` = `task_category`.`id`;

/* Days are created in advance, and tasks are added according to templates. */
INSERT INTO `day` (`id_user`, `date_of_day`, `has_tasks`)
VALUES
(@john_id, "2026-03-29", true),
(@john_id, "2026-03-30", true),
(@john_id, "2026-03-31", true);

SET @sunday_id = (SELECT `id` FROM `day` WHERE `id_user` = @john_id AND `date_of_day` = "2026-03-29");
SET @monday_id = (SELECT `id` FROM `day` WHERE `id_user` = @john_id AND `date_of_day` = "2026-03-30");
SET @tuesday_id = (SELECT `id` FROM `day` WHERE `id_user` = @john_id AND `date_of_day` = "2026-03-31");

SELECT * FROM `day`;

/* Task records are created for each day. */
INSERT INTO `task` (`id_task_template`, `id_day`, `order`)
VALUES
(@shower_temp_id, @sunday_id, "1"),
(@breakfast_temp_id, @sunday_id, "2"),
(@groceries_temp_id, @sunday_id, "3"),
(@shower_temp_id, @monday_id, "1"),
(@breakfast_temp_id, @monday_id, "2"),
(@shower_temp_id, @tuesday_id, "1"),
(@breakfast_temp_id, @tuesday_id, "2"),
(@mom_temp_id, @tuesday_id, "3");

SET @sunday_shower = (SELECT `id` FROM `task` WHERE `id_task_template` = @shower_temp_id AND `id_day` = @sunday_id);
SET @sunday_breakfast = (SELECT `id` FROM `task` WHERE `id_task_template` = @breakfast_temp_id AND `id_day` = @sunday_id);
SET @sunday_groceries = (SELECT `id` FROM `task` WHERE `id_task_template` = @groceries_temp_id AND `id_day` = @sunday_id);
SET @monday_shower = (SELECT `id` FROM `task` WHERE `id_task_template` = @shower_temp_id AND `id_day` = @monday_id);
SET @monday_breakfast = (SELECT `id` FROM `task` WHERE `id_task_template` = @breakfast_temp_id AND `id_day` = @monday_id);
SET @tuesday_shower = (SELECT `id` FROM `task` WHERE `id_task_template` = @shower_temp_id AND `id_day` = @tuesday_id);
SET @tuesday_breakfast = (SELECT `id` FROM `task` WHERE `id_task_template` = @breakfast_temp_id AND `id_day` = @tuesday_id);
SET @tuesday_mom = (SELECT `id` FROM `task` WHERE `id_task_template` = @mom_temp_id AND `id_day` = @tuesday_id);

SELECT * FROM `task`;

/* On day with tasks, user checks the task page and tasks are listed. */
SELECT `task_template`.`title`, `task`.`order`, `task`.`is_completed`
FROM `task`
INNER JOIN `task_template` ON `task`.`id_task_template` = `task_template`.`id`
WHERE `task`.`id_day` = @sunday_id AND `task`.`is_active` = true
ORDER BY `task`.`order`;

/* User removes a task just from this specific day. */
UPDATE `task` SET `is_active` = false WHERE `id` = @sunday_breakfast;

SELECT `task_template`.`title`, `task`.`order`, `task`.`is_completed`
FROM `task`
INNER JOIN `task_template` ON `task`.`id_task_template` = `task_template`.`id`
WHERE `task`.`id_day` = @sunday_id AND `task`.`is_active` = true
ORDER BY `task`.`order`;

/* 
User completes tasks throughout the day and marks them as so.
As tasks are completed, the day's completion average is updated.
 */
UPDATE `task` SET `is_completed` = true WHERE `id` = @sunday_shower;
UPDATE `day` SET `completion_percentage` = 50 WHERE `id` = @sunday_id;

UPDATE `task` SET `is_completed` = true WHERE `id` = @sunday_groceries;
UPDATE `day` SET `completion_percentage` = 100 WHERE `id` = @sunday_id;

SELECT `task_template`.`title`, `task`.`order`, `task`.`is_completed`
FROM `task`
INNER JOIN `task_template` ON `task`.`id_task_template` = `task_template`.`id`
WHERE `task`.`id_day` = @sunday_id AND `task`.`is_active` = true
ORDER BY `task`.`order`;

/* 
At the end of the day, month and year statistics are updated according to that day.
In the case of the first day of a month or year, the record for that month or year is also created at the end of that day.
They are also created for the first time even if it's not the first day of the month or year, in cases where the user just created their account.
*/
INSERT INTO `year` (`id_user`, `year_number`, `completion_average`, `perfect_days`)
VALUES
(@john_id, 2026, 100, 1);

SELECT * FROM `year`;

INSERT INTO `month` (`id_user`, `month_number`, `year_number`, `completion_average`, `perfect_days`)
VALUES
(@john_id, 3, 2026, 100, 1);

SELECT * FROM `month`;

/* 
Next day, user completes a task and misses the other. 
At the end of the day, the year and month statistics are updated since they already exist.
*/
UPDATE `task` SET `is_completed` = true WHERE `id` = @monday_shower;

UPDATE `year` SET `completion_average` = 75 WHERE `id_user` = @john_id AND `year_number` = 2026;
UPDATE `month` SET `completion_average` = 75 WHERE `id_user` = @john_id AND `month_number` = 3 AND `year_number` = 2026;

SELECT `year`.`completion_average`, `month`.`completion_average`
FROM `year`
INNER JOIN `month` ON `year`.`id_user` = `month`.`id_user` AND `year`.`year_number` = `month`.`year_number`
WHERE `year`.`id_user` = @john_id AND `year`.`year_number` = 2026;

/* User deletes their account. */
UPDATE `user` SET `is_active` = false WHERE `id` = @john_id;
UPDATE `user` SET `email` = CONCAT("anonymous", @john_id, "@deleted.com") WHERE `id` = @john_id;

SELECT * FROM `user` WHERE `id` = @john_id;

ROLLBACK;
