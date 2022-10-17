/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
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
  `ring` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_hashtags_rings` (`ring`),
  CONSTRAINT `FK_hashtags_rings` FOREIGN KEY (`ring`) REFERENCES `rings` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=armscii8 COLLATE=armscii8_bin;

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
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table twitwatch.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(64) NOT NULL AUTO_INCREMENT,
  `twit_id` varchar(128) DEFAULT NULL,
  `username` varchar(128) DEFAULT NULL,
  `name` varchar(128) DEFAULT NULL,
  `follower_count` int(11) DEFAULT NULL,
  `following_count` int(11) DEFAULT NULL,
  `tweet_count` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `location` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `twit_id` (`twit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=338 DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
