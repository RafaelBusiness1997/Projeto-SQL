USE task_buddy;

CREATE TABLE `user` (
	`id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `is_active` BOOL NOT NULL DEFAULT TRUE
);

CREATE TABLE `task_category` (
	`id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `id_user` INT UNSIGNED NOT NULL,
    `category` VARCHAR(100) NOT NULL,
    
    FOREIGN KEY (`id_user`) REFERENCES `user`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    UNIQUE (`id_user`, `category`)
);

CREATE TABLE `month` (
	`id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `id_user` INT UNSIGNED NOT NULL,
    `month_number` TINYINT UNSIGNED NOT NULL,
	`year_number` SMALLINT UNSIGNED NOT NULL,
    `completion_average` FLOAT NOT NULL,
    `perfect_days` TINYINT UNSIGNED NOT NULL,
    
    FOREIGN KEY (`id_user`) REFERENCES `user`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    CHECK (`month_number` BETWEEN 1 AND 12),
    CHECK (`completion_average` BETWEEN 0 AND 100),
    CHECK (`perfect_days` BETWEEN 0 AND 31),
    
    UNIQUE (`id_user`, `month_number`, `year_number`)
);

CREATE TABLE `year` (
	`id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `id_user` INT UNSIGNED NOT NULL,
    `year_number` SMALLINT UNSIGNED NOT NULL,
    `completion_average` FLOAT NOT NULL,
    `perfect_days` TINYINT UNSIGNED NOT NULL,
    
    FOREIGN KEY (`id_user`) REFERENCES `user`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    CHECK (`completion_average` BETWEEN 0 AND 100),
    CHECK (`perfect_days` BETWEEN 0 AND 31),
    
    UNIQUE (`id_user`, `year_number`)
);

CREATE TABLE `day` (
	`id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `id_user` INT UNSIGNED NOT NULL,
    `date_of_day` DATE NOT NULL DEFAULT (CURRENT_DATE()),
    `completion_percentage` FLOAT NOT NULL DEFAULT 0,
    `has_tasks` BOOL NOT NULL DEFAULT FALSE,
    
    FOREIGN KEY (`id_user`) REFERENCES `user`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    CHECK (`completion_percentage` BETWEEN 0 AND 100), 
    
    UNIQUE (`id_user`, `date_of_day`)
);

CREATE TABLE `task_type` (
	`id` TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `type` VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE `task_template` (
	`id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `id_user` INT UNSIGNED NOT NULL,
    `id_task_type` TINYINT UNSIGNED NOT NULL,
    `id_task_category` INT UNSIGNED DEFAULT NULL,
    `title` VARCHAR(50) NOT NULL,
    `is_listed` BOOL NOT NULL DEFAULT TRUE,
    `default_order` TINYINT UNSIGNED NOT NULL,
    `day_of_week` ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') DEFAULT NULL,
    `specific_date` DATE DEFAULT NULL,
    
    FOREIGN KEY (`id_user`) REFERENCES `user`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`id_task_type`) REFERENCES `task_type`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`id_task_category`) REFERENCES `task_category`(`id`) ON DELETE SET NULL ON UPDATE CASCADE,
    
    UNIQUE (`id_user`, `title`),
    UNIQUE (`id_user`, `default_order`)
);

CREATE TABLE `task` (
	`id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `id_task_template` INT UNSIGNED NOT NULL,
    `id_day` BIGINT UNSIGNED NOT NULL,
    `order` TINYINT UNSIGNED NOT NULL,
    `is_active` BOOL NOT NULL DEFAULT TRUE,
    `is_completed` BOOL NOT NULL DEFAULT FALSE,
    
    FOREIGN KEY (`id_task_template`) REFERENCES `task_template`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`id_day`) REFERENCES `day`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    
    UNIQUE (`id_day`, `order`)
);
