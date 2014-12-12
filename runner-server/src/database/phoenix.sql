/*
Navicat MySQL Data Transfer

Source Server         : sun
Source Server Version : 50617
Source Host           : localhost:3306
Source Database       : phoenix

Target Server Type    : MYSQL
Target Server Version : 50617
File Encoding         : 65001

Date: 2014-12-12 19:14:46
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
  `equipment_id` varchar(255) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `exercise_time` time DEFAULT NULL,
  `calories` float DEFAULT NULL,
  `power_generate` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of exercise_information
-- ----------------------------
INSERT INTO `exercise_information` VALUES ('jim', null, null, null, null, null, null);

-- ----------------------------
-- Table structure for total_information
-- ----------------------------
DROP TABLE IF EXISTS `total_information`;
CREATE TABLE `total_information` (
  `user_id` varchar(255) DEFAULT NULL,
  `duration-summary` int(6) DEFAULT NULL,
  `energy-summary` float(11,0) DEFAULT NULL,
  `energy-rank-summary` int(11) DEFAULT NULL,
  `duration-average` int(6) DEFAULT NULL,
  `energy-average` float(11,0) DEFAULT NULL,
  `energy-rank-average` int(11) DEFAULT NULL,
  `duration-lastweek` int(6) DEFAULT NULL,
  `energy-lastweek` float(11,0) DEFAULT NULL,
  `energy-rank-lastweek` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of total_information
-- ----------------------------
INSERT INTO `total_information` VALUES ('jim', '145', '23', '32', '224', '34', '54', '345', '23', '64');
INSERT INTO `total_information` VALUES ('lucy', null, null, null, null, null, null, null, null, null);

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
