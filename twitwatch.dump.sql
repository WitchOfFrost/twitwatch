/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for twitwatch
CREATE DATABASE IF NOT EXISTS `twitwatch` /*!40100 DEFAULT CHARACTER SET armscii8 COLLATE armscii8_bin */;
USE `twitwatch`;

-- Dumping structure for table twitwatch.hashtags
CREATE TABLE IF NOT EXISTS `hashtags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hashtag` varchar(64) COLLATE armscii8_bin NOT NULL,
  `lang` varchar(2) COLLATE armscii8_bin NOT NULL DEFAULT 'en',
  `ring` int(11) NOT NULL DEFAULT 1,
  `category` varchar(50) COLLATE armscii8_bin DEFAULT NULL,
  `active` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `FK_hashtags_rings` (`ring`),
  CONSTRAINT `FK_hashtags_rings` FOREIGN KEY (`ring`) REFERENCES `rings` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=armscii8 COLLATE=armscii8_bin;

CREATE TABLE IF NOT EXISTS `media` (
  `id` bigint(32) NOT NULL AUTO_INCREMENT,
  `tweet_id` varchar(128) NOT NULL,
  `type` varchar(128) DEFAULT NULL,
  `media_key` varchar(128) NOT NULL,
  `url` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `media_key` (`media_key`),
  KEY `FK_media_tweets` (`tweet_id`),
  CONSTRAINT `FK_media_tweets` FOREIGN KEY (`tweet_id`) REFERENCES `tweets` (`twit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=157 DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table twitwatch.rings
CREATE TABLE IF NOT EXISTS `rings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE armscii8_bin NOT NULL,
  `active` int(1) NOT NULL DEFAULT 1,
  `position` int(11) NOT NULL,
  `interval` int(11) NOT NULL,
  `upgrade_after` int(11) NOT NULL,
  `downgrade_after` int(11) NOT NULL,
  `refresh_hashtags` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=armscii8 COLLATE=armscii8_bin;

-- Data exporting was unselected.

-- Dumping structure for table twitwatch.tweets
CREATE TABLE IF NOT EXISTS `tweets` (
  `id` int(64) NOT NULL AUTO_INCREMENT,
  `twit_id` varchar(128) DEFAULT NULL,
  `author_id` varchar(128) DEFAULT NULL,
  `hashtag` int(11) DEFAULT NULL,
  `text` longtext DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `twit_id` (`twit_id`),
  KEY `FK_tweets_hashtags` (`hashtag`),
  KEY `FK_tweets_users` (`author_id`),
  CONSTRAINT `FK_tweets_hashtags` FOREIGN KEY (`hashtag`) REFERENCES `hashtags` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_tweets_users` FOREIGN KEY (`author_id`) REFERENCES `users` (`twit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4228 DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table twitwatch.users
CREATE TABLE IF NOT EXISTS `users` (
  `twit_id` varchar(128) NOT NULL,
  `username` varchar(128) DEFAULT NULL,
  `name` varchar(128) DEFAULT NULL,
  `follower_count` int(11) DEFAULT NULL,
  `following_count` int(11) DEFAULT NULL,
  `tweet_count` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `location` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`twit_id`) USING BTREE,
  UNIQUE KEY `twit_id` (`twit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

CREATE TABLE `view_tweets` (
	`hashtag_id` INT(11) NULL,
	`category` VARCHAR(50) NULL COLLATE 'armscii8_bin',
	`hashtag_name` VARCHAR(64) NULL COLLATE 'armscii8_bin',
	`id` INT(64) NOT NULL,
	`text` LONGTEXT NULL COLLATE 'utf8mb4_general_ci',
	`twit_id` VARCHAR(128) NULL COLLATE 'utf8mb4_general_ci',
	`author_id` VARCHAR(128) NULL COLLATE 'utf8mb4_general_ci',
	`created_at` DATETIME NULL
) ENGINE=MyISAM;

DROP TABLE IF EXISTS `view_tweets`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view_tweets` AS select `B`.`id` AS `hashtag_id`,`B`.`category` AS `category`,`B`.`hashtag` AS `hashtag_name`,`A`.`id` AS `id`,`A`.`text` AS `text`,`A`.`twit_id` AS `twit_id`,`A`.`author_id` AS `author_id`,`A`.`created_at` AS `created_at` from (`tweets` `A` left join `hashtags` `B` on(`A`.`hashtag` = `B`.`id`));

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
