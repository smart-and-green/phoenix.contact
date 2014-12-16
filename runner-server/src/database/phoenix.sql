/*
Navicat MySQL Data Transfer

Source Server         : sun
Source Server Version : 50617
Source Host           : localhost:3306
Source Database       : phoenix

Target Server Type    : MYSQL
Target Server Version : 50617
File Encoding         : 65001

Date: 2014-12-16 16:17:10
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for equipment_information
-- ----------------------------
DROP TABLE IF EXISTS `equipment_information`;
CREATE TABLE `equipment_information` (
  `equ_id` varchar(255) NOT NULL,
  `equ_type` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of equipment_information
-- ----------------------------

-- ----------------------------
-- Table structure for exercise_information
-- ----------------------------
DROP TABLE IF EXISTS `exercise_information`;
CREATE TABLE `exercise_information` (
  `user_id` varchar(255) NOT NULL,
  `equipment_id` varchar(255) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `duration_time` time NOT NULL DEFAULT '00:00:00',
  `energy` float DEFAULT '0',
  `num` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of exercise_information
-- ----------------------------
INSERT INTO `exercise_information` VALUES ('jim', '32', '2014-12-14 12:12:12', '2014-12-14 12:12:15', '00:00:03', '123', '1');
INSERT INTO `exercise_information` VALUES ('jim', 'bike', '2014-12-12 10:10:10', '2014-12-12 10:11:11', '23:23:22', '234', '2');
INSERT INTO `exercise_information` VALUES ('jim', 'bike', '2014-12-12 10:10:10', '2014-12-12 10:11:11', '23:23:22', '234', '3');
INSERT INTO `exercise_information` VALUES ('jim', 'bike', '2014-12-12 10:10:10', '2014-12-12 10:11:11', '23:23:22', '234', '4');
INSERT INTO `exercise_information` VALUES ('jim', 'bike', '2014-12-12 10:10:10', '2014-12-12 10:11:11', '23:23:22', '234', '5');
INSERT INTO `exercise_information` VALUES ('jim', 'bike', '2014-12-12 10:10:10', '2014-12-12 10:11:11', '23:23:22', '234', '6');
INSERT INTO `exercise_information` VALUES ('jim', 'bike', '2014-12-12 10:10:10', '2014-12-12 10:11:11', '00:00:01', '1', '7');
INSERT INTO `exercise_information` VALUES ('jim', 'bike', '2014-12-12 10:10:10', '2014-12-12 10:11:11', '00:00:01', '1', '8');

-- ----------------------------
-- Table structure for month_information
-- ----------------------------
DROP TABLE IF EXISTS `month_information`;
CREATE TABLE `month_information` (
  `user_id` varchar(256) NOT NULL,
  `year` int(11) DEFAULT '0',
  `month` int(11) DEFAULT '0',
  `month_energy` float(11,1) DEFAULT '0.0',
  `month_time` time DEFAULT '00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of month_information
-- ----------------------------
INSERT INTO `month_information` VALUES ('jim', '2014', '12', '1643.0', '160:23:33');
INSERT INTO `month_information` VALUES ('jim', '2015', '1', '23.0', '00:00:03');
INSERT INTO `month_information` VALUES ('jim', '2015', '2', '32.0', '00:00:34');

-- ----------------------------
-- Table structure for total_information
-- ----------------------------
DROP TABLE IF EXISTS `total_information`;
CREATE TABLE `total_information` (
  `user_id` varchar(255) NOT NULL,
  `duration_summary` int(6) unsigned DEFAULT '0',
  `energy_summary` float(11,0) unsigned DEFAULT '0',
  `energy_rank-summary` int(11) DEFAULT '0',
  `duration_average` int(6) DEFAULT '0',
  `energy_average` float(11,1) DEFAULT '0.0',
  `energy_rank_average` int(11) DEFAULT '0',
  `exercise_number` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of total_information
-- ----------------------------
INSERT INTO `total_information` VALUES ('jim', '145', '1429', '32', '224', '357.2', '54', '4');
INSERT INTO `total_information` VALUES ('lucy', '213', '22', '32', '32', '23.0', '12', '3');

-- ----------------------------
-- Table structure for user_information
-- ----------------------------
DROP TABLE IF EXISTS `user_information`;
CREATE TABLE `user_information` (
  `user_id` varchar(255) NOT NULL,
  `nickname` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `hobby` varchar(255) DEFAULT NULL,
  `favorite_sport` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of user_information
-- ----------------------------

-- ----------------------------
-- Table structure for user_login
-- ----------------------------
DROP TABLE IF EXISTS `user_login`;
CREATE TABLE `user_login` (
  `user_id` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of user_login
-- ----------------------------
INSERT INTO `user_login` VALUES ('jim', '123456');
INSERT INTO `user_login` VALUES ('lucy', '123456');

-- ----------------------------
-- Table structure for week_information
-- ----------------------------
DROP TABLE IF EXISTS `week_information`;
CREATE TABLE `week_information` (
  `user_id` varchar(256) NOT NULL,
  `year` int(11) DEFAULT '0',
  `week` int(11) DEFAULT NULL,
  `week_energy` float(11,1) DEFAULT '0.0',
  `week_time` time DEFAULT '00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of week_information
-- ----------------------------
INSERT INTO `week_information` VALUES ('jim', '2014', '49', '3.0', '00:00:03');
INSERT INTO `week_information` VALUES ('jim', '2014', '50', '3.0', '00:00:08');
INSERT INTO `week_information` VALUES ('jim', '2014', '51', '4.0', '00:00:09');
INSERT INTO `week_information` VALUES ('jim', '2015', '1', '3.0', '00:00:03');
INSERT INTO `week_information` VALUES ('jim', '2015', '2', '2.0', '00:03:00');
DROP TRIGGER IF EXISTS `ADD_DATA`;
DELIMITER ;;
CREATE TRIGGER `ADD_DATA` AFTER INSERT ON `exercise_information` FOR EACH ROW begin
DECLARE total FLOAT DEFAULT 0;
DECLARE cunt FLOAT DEFAULT 0;
DECLARE number FLOAT DEFAULT 0;
DECLARE num FLOAT DEFAULT 0;
SELECT NEW.energy INTO cunt ;
SELECT energy_summary INTO total FROM total_information WHERE (user_id = NEW.user_id);
SET total = total + cunt;
UPDATE total_information SET energy_summary=total WHERE (user_id= NEW.user_id);
SELECT exercise_number INTO number FROM total_information WHERE (user_id= NEW.user_id);
SET number = number + 1;
UPDATE total_information SET exercise_number=number WHERE (user_id= NEW.user_id);
UPDATE total_information SET energy_average=(total/number) WHERE (user_id= NEW.user_id);
end
;;
DELIMITER ;
