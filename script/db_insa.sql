-- MySQL Script generated by MySQL Workbench
-- Seg 21 Nov 2016 15:28:18 BRT
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema INSA
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `INSA` ;

-- -----------------------------------------------------
-- Schema INSA
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `INSA` DEFAULT CHARACTER SET utf8 ;
USE `INSA` ;

-- -----------------------------------------------------
-- Table `INSA`.`tb_estado`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `INSA`.`tb_estado` ;

CREATE TABLE IF NOT EXISTS `INSA`.`tb_estado` (
  `id` INT(11) NOT NULL,
  `nome` VARCHAR(50) NOT NULL,
  `nome_regiao` VARCHAR(45) NULL,
  `sigla` VARCHAR(5) NULL,
  PRIMARY KEY (`id`));


-- -----------------------------------------------------
-- Table `INSA`.`tb_reservatorio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `INSA`.`tb_reservatorio` ;

CREATE TABLE IF NOT EXISTS `INSA`.`tb_reservatorio` (
  `id` INT(11) NOT NULL,
  `nome` VARCHAR(100) NOT NULL,
  `reservat` VARCHAR(100) NOT NULL,
  `bacia` VARCHAR(45) NULL,
  `tipo` VARCHAR(45) NULL,
  `area` MEDIUMTEXT NULL,
  `perimetro` MEDIUMTEXT NULL,
  `hectares` MEDIUMTEXT NULL,
  `capacidade` MEDIUMTEXT NULL,
  `latitude` MEDIUMTEXT NULL,
  `longitude` MEDIUMTEXT NULL,
  PRIMARY KEY (`id`));


-- -----------------------------------------------------
-- Table `INSA`.`tb_monitoramento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `INSA`.`tb_monitoramento` ;

CREATE TABLE IF NOT EXISTS `INSA`.`tb_monitoramento` (
  `id_reservatorio` INT(11) NOT NULL,
  `cota` MEDIUMTEXT NULL,
  `volume` MEDIUMTEXT NOT NULL,
  `volume_percentual` MEDIUMTEXT NOT NULL,
  `data_informacao` DATE NOT NULL,
  `visualizacao` INT(11) NULL,
  `fonte` VARCHAR(50) NULL,
  INDEX `fk_tb_reservatorio_idx` (`id_reservatorio` ASC),
  CONSTRAINT `fk_tb_reservatorio`
    FOREIGN KEY (`id_reservatorio`)
    REFERENCES `INSA`.`tb_reservatorio` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `INSA`.`tb_municipio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `INSA`.`tb_municipio` ;

CREATE TABLE IF NOT EXISTS `INSA`.`tb_municipio` (
  `id` INT(11) NOT NULL,
  `nome` VARCHAR(50) NOT NULL,
  `id_estado` INT(11) NOT NULL,
  `area` MEDIUMTEXT NULL,
  `semiarido` INT(11) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_tb_estado_idx` (`id_estado` ASC),
  CONSTRAINT `fk_tb_estado`
    FOREIGN KEY (`id_estado`)
    REFERENCES `INSA`.`tb_estado` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `INSA`.`tb_reservatorio_municipio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `INSA`.`tb_reservatorio_municipio` ;

CREATE TABLE IF NOT EXISTS `INSA`.`tb_reservatorio_municipio` (
  `id_reservatorio` INT(11) NOT NULL,
  `id_municipio` INT(11) NOT NULL,
  INDEX `fk_tb_municipio_idx` (`id_municipio` ASC),
  CONSTRAINT `fk_tb_reservatorio_mun`
    FOREIGN KEY (`id_reservatorio`)
    REFERENCES `INSA`.`tb_reservatorio` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_tb__reservatorio_mun_2`
    FOREIGN KEY (`id_municipio`)
    REFERENCES `INSA`.`tb_municipio` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `INSA`.`tb_user_reservatorio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `INSA`.`tb_user_reservatorio` ;

CREATE TABLE IF NOT EXISTS `INSA`.`tb_user_reservatorio` (
  `id_reservatorio` INT(11) NOT NULL,
  `id_user` VARCHAR(50) NOT NULL,
  `atualizacao_reservatorio` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_reservatorio`, `id_user`),
  CONSTRAINT `fk_tb_reservatorio_mun00`
    FOREIGN KEY (`id_reservatorio`)
    REFERENCES `INSA`.`tb_reservatorio` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);



DROP TABLE IF EXISTS `INSA`.`mv_monitoramento`;
CREATE TABLE IF NOT EXISTS `INSA`.`mv_monitoramento` (
	`id_reservatorio` INT(11)  NOT NULL,
	`latitude` mediumtext,
	`longitude` mediumtext,
	`capacidade` mediumtext,
	`volume_percentual` mediumtext,
	`volume` mediumtext,	
  `data_informacao` DATE,  
  `fonte` mediumtext,  
	UNIQUE INDEX `id_mv_monitoramento` (`id_reservatorio`)
);


DROP PROCEDURE IF EXISTS `INSA`.`refresh_mv_monitoramento`;

CREATE PROCEDURE `INSA`.`refresh_mv_monitoramento`() 
BEGIN 
TRUNCATE TABLE `INSA`.`mv_monitoramento`; 

INSERT INTO `INSA`.`mv_monitoramento`
SELECT DISTINCT mon.id,mon.latitude,mon.longitude, mon.capacidade, ROUND(mo.volume_percentual,1), mo.volume, mon.maior_data, mo.fonte 
FROM tb_monitoramento mo 
RIGHT JOIN (SELECT r.id,r.latitude,r.longitude, r.capacidade, max(m.data_informacao) AS maior_data FROM tb_reservatorio r 
LEFT OUTER JOIN tb_monitoramento m ON r.id=m.id_reservatorio GROUP BY r.id) mon ON mo.id_reservatorio=mon.id 
AND mon.maior_data=mo.data_informacao; 

END;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
