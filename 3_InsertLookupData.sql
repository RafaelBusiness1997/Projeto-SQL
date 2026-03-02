/*
Script for inserting records into the `task_type` lookup table.
Inserting data into the other tables will be set up as a simulation of the user experience.
In that simulation, the transaction won't be committed, as to run the simulation without affecting the database permanently.
For this table, the records are static lookup values.
Due to this, this is kept separate, as the records should be committed once and then kept untouched. 
*/

USE `task_buddy`;

INSERT INTO `task_type` (`type`)
VALUES
("Daily"), ("Weekly"), ("Date Specific");

SELECT * FROM `task_type`;
