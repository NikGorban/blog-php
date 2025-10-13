-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mon_blog
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `mon_blog` ;

-- -----------------------------------------------------
-- Schema mon_blog
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mon_blog` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `mon_blog` ;


-- -----------------------------------------------------
-- Table `mon_blog`.`timestamps`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mon_blog`.`timestamps` ;

CREATE TABLE IF NOT EXISTS `mon_blog`.`timestamps` (
  `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` TIMESTAMP NULL);


-- -----------------------------------------------------
-- Table `mon_blog`.`role`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mon_blog`.`role` ;

CREATE TABLE IF NOT EXISTS `mon_blog`.`role` (
  `role_id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `role_name` VARCHAR(45) NOT NULL,
  `role_description` VARCHAR(500) NULL,
  PRIMARY KEY (`role_id`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `role_name_UNIQUE` ON `mon_blog`.`role` (`role_name` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mon_blog`.`user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mon_blog`.`user` ;

CREATE TABLE IF NOT EXISTS `mon_blog`.`user` (
  `user_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_login` VARCHAR(45) NOT NULL,
  `user_pxd` VARCHAR(300) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_bin' NOT NULL COMMENT 'binaire pour les accents etc... long pour le password hach',
  `user_mail` VARCHAR(160) NOT NULL,
  `user_real_name` VARCHAR(150) NULL,
  `user_date_inscription` DATETIME NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'pour validation via mail',
  `user_hidden_id` VARCHAR(100) NOT NULL COMMENT 'sert pour le mail validation, pourra etre regenere au besoin',
  `user_activate` TINYINT UNSIGNED NULL COMMENT '0 => pas valide\n1 => valide\n2 => banni\n3...',
  `user_role_id` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_user_role`
    FOREIGN KEY (`user_role_id`)
    REFERENCES `mon_blog`.`role` (`role_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `user_login_UNIQUE` ON `mon_blog`.`user` (`user_login` ASC) VISIBLE;

CREATE UNIQUE INDEX `user_mail_UNIQUE` ON `mon_blog`.`user` (`user_mail` ASC) VISIBLE;

CREATE INDEX `fk_user_role_idx` ON `mon_blog`.`user` (`user_role_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mon_blog`.`article`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mon_blog`.`article` ;

CREATE TABLE IF NOT EXISTS `mon_blog`.`article` (
  `article_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `article_title` VARCHAR(120) NOT NULL,
  `article_slug` VARCHAR(124) NOT NULL,
  `article_text` TEXT NOT NULL,
  `article_date_create` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `article_date_publish` DATETIME NULL,
  `article_visibility` TINYINT UNSIGNED NULL COMMENT '0 => non publie\n1 => en relecture\n2 => publie\n3 => supprime',
  `article_user_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`article_id`),
  CONSTRAINT `fk_article_user1`
    FOREIGN KEY (`article_user_id`)
    REFERENCES `mon_blog`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `article_slug_UNIQUE` ON `mon_blog`.`article` (`article_slug` ASC) VISIBLE;

CREATE INDEX `fk_article_user1_idx` ON `mon_blog`.`article` (`article_user_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mon_blog`.`category`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mon_blog`.`category` ;

CREATE TABLE IF NOT EXISTS `mon_blog`.`category` (
  `category_id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_title` VARCHAR(100) NOT NULL,
  `category_slug` VARCHAR(104) NOT NULL,
  `category_description` VARCHAR(400) NULL,
  `category_parent` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`category_id`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `category_slug_UNIQUE` ON `mon_blog`.`category` (`category_slug` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mon_blog`.`article_has_category`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mon_blog`.`article_has_category` ;

CREATE TABLE IF NOT EXISTS `mon_blog`.`article_has_category` (
  `article_article_id` INT UNSIGNED NOT NULL,
  `table1_category_id` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`article_article_id`, `table1_category_id`),
  CONSTRAINT `fk_article_has_table1_article1`
    FOREIGN KEY (`article_article_id`)
    REFERENCES `mon_blog`.`article` (`article_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_article_has_table1_table11`
    FOREIGN KEY (`table1_category_id`)
    REFERENCES `mon_blog`.`category` (`category_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_article_has_table1_table11_idx` ON `mon_blog`.`article_has_category` (`table1_category_id` ASC) VISIBLE;

CREATE INDEX `fk_article_has_table1_article1_idx` ON `mon_blog`.`article_has_category` (`article_article_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mon_blog`.`comment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mon_blog`.`comment` ;

CREATE TABLE IF NOT EXISTS `mon_blog`.`comment` (
  `comment_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `comment_text` VARCHAR(600) NOT NULL,
  `comment_create` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `comment_parent` INT UNSIGNED NOT NULL DEFAULT 0,
  `comment_visibility` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0 => pas valide\n1 => valide\n2 => banni',
  `comment_user_id` INT UNSIGNED NOT NULL,
  `comment_article_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`comment_id`),
  CONSTRAINT `fk_comment_user1`
    FOREIGN KEY (`comment_user_id`)
    REFERENCES `mon_blog`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_comment_article1`
    FOREIGN KEY (`comment_article_id`)
    REFERENCES `mon_blog`.`article` (`article_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_comment_user1_idx` ON `mon_blog`.`comment` (`comment_user_id` ASC) VISIBLE;

CREATE INDEX `fk_comment_article1_idx` ON `mon_blog`.`comment` (`comment_article_id` ASC) VISIBLE;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
