# Löscht die Datenbank falls sie schon existiert
DROP DATABASE IF EXISTS `wwfgusc`;

# Erstellt die Datenbank neu mit dem Standard-charset
CREATE DATABASE `wwfgusc`;

# Nutzt für alle nachfolgenden Statements die Datenbank `wwfgusc`
USE `wwfgusc`;

#################################################
##Erstellen der Tables mit Attributen############
##und Schlüsseln                     ############
#################################################

CREATE TABLE `Merkmal` (
    `Kürzel` VARCHAR(10) NOT NULL,
    `Beschreibung` VARCHAR(100),
    PRIMARY KEY (`Kürzel`)
);

CREATE TABLE `Hersteller` (
	`HerstellerID` INT AUTO_INCREMENT NOT NULL,
    `Herstellername` VARCHAR(30) NOT NULL,
    PRIMARY KEY (`HerstellerID`)
);

CREATE TABLE `Flugzeugtyp` (
    `Modell` VARCHAR(10) NOT NULL,
    `Hersteller_HerstellerID` INT NOT NULL,
    PRIMARY KEY (`Modell`),
    FOREIGN KEY (`Hersteller_HerstellerID`)
        REFERENCES `Hersteller` (`HerstellerID`)
);

CREATE TABLE `Maschine` (
    `Kennzeichen` VARCHAR(10) NOT NULL,
    `Betriebsstunden` INT UNSIGNED DEFAULT 0,
    `Indienststellung` DATE,
    `Betriebsstunden_seit_Wartung` INT UNSIGNED,
    `Flugzeugtyp_Modell` VARCHAR(10) NOT NULL,
    PRIMARY KEY (`Kennzeichen`),
    FOREIGN KEY (`Flugzeugtyp_Modell`)
        REFERENCES `Flugzeugtyp` (`Modell`)
);

CREATE TABLE `Maschine_Merkmal` (
    `Maschine_Kennzeichen` VARCHAR(10) NOT NULL,
    `Merkmal_Kürzel` VARCHAR(10) NOT NULL,
    PRIMARY KEY (`Maschine_Kennzeichen` , `Merkmal_Kürzel`),
    FOREIGN KEY (`Maschine_Kennzeichen`)
        REFERENCES `Maschine` (`Kennzeichen`),
    FOREIGN KEY (`Merkmal_Kürzel`)
        REFERENCES `Merkmal` (`Kürzel`)
);

CREATE TABLE `Flughafen` (
    `Kürzel` VARCHAR(3) NOT NULL,
    `Bezeichnung` VARCHAR(50) NOT NULL,
    `Zeitzone` TINYINT SIGNED NOT NULL,
    `Steuersatz` DECIMAL(6 , 2 ) UNSIGNED,
    `Sicherheitsgebühren` DECIMAL(6 , 2 ) UNSIGNED,
    PRIMARY KEY (`Kürzel`)
);

CREATE TABLE `Nachbarflughäfen` (
    `Flughafen1` VARCHAR(3) NOT NULL,
    `Flughafen2` VARCHAR(3) NOT NULL,
    `Distanz` INT NOT NULL,
    PRIMARY KEY (`Flughafen1` , `Flughafen2`),
    FOREIGN KEY (`Flughafen1`)
        REFERENCES `Flughafen` (`Kürzel`),
    FOREIGN KEY (`Flughafen2`)
        REFERENCES `Flughafen` (`Kürzel`)
);

CREATE TABLE `Tarif` (
	`TarifID` INT AUTO_INCREMENT NOT NULL,
    `Tarifbezeichnung` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`TarifID`)
);

CREATE TABLE `Buchungsklasse` (
	`BuchungsklassenID` INT AUTO_INCREMENT NOT NULL,
    `Bezeichnung` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`BuchungsklassenID`)
);

CREATE TABLE `Flugverbindung` (
    `Flugnummer` VARCHAR(10) NOT NULL,
    `Startknoten` VARCHAR(3) NOT NULL,
    `Abflugzeit` TIME NOT NULL,
    `Endknoten` VARCHAR(3) NOT NULL,
    `Ankunftszeit` TIME NOT NULL,
    `Kerosinzuschlag` DECIMAL(6 , 2 ) UNSIGNED,
    `Flugzeugtyp_Modell` VARCHAR(10) NOT NULL,
    `Montag` TINYINT(1) NOT NULL DEFAULT 0,
    `Dienstag` TINYINT(1) NOT NULL DEFAULT 0,
    `Mittwoch` TINYINT(1) NOT NULL DEFAULT 0,
    `Donnerstag` TINYINT(1) NOT NULL DEFAULT 0,
    `Freitag` TINYINT(1) NOT NULL DEFAULT 0,
    `Samstag` TINYINT(1) NOT NULL DEFAULT 0,
    `Sonntag` TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`Flugnummer`),
    FOREIGN KEY (`Startknoten`)
        REFERENCES `Flughafen` (`Kürzel`),
    FOREIGN KEY (`Endknoten`)
        REFERENCES `Flughafen` (`Kürzel`),
    FOREIGN KEY (`Flugzeugtyp_Modell`)
        REFERENCES `Flugzeugtyp` (`Modell`)
);

CREATE TABLE `Flug` (
    `Flugdatum` DATE NOT NULL,
    `Maschine_Kennzeichen` VARCHAR(10) NOT NULL,
    `Flugverbindung_Flugnummer` VARCHAR(10) NOT NULL,
    PRIMARY KEY (`Flugdatum` , `Maschine_Kennzeichen` , `Flugverbindung_Flugnummer`),
    FOREIGN KEY (`Maschine_Kennzeichen`)
        REFERENCES `Maschine` (`Kennzeichen`),
    FOREIGN KEY (`Flugverbindung_Flugnummer`)
        REFERENCES `Flugverbindung` (`Flugnummer`)
);

CREATE TABLE `Tarif_Buchungsklasse_Flugverbindung` (
    `Tarif_TarifID` INT NOT NULL,
    `Buchungsklasse_BuchungsklassenID` INT NOT NULL,
    `Flugverbindung_Flugnummer` VARCHAR(10) NOT NULL,
    `Kosten` DECIMAL(6 , 2 ) UNSIGNED NOT NULL,
    PRIMARY KEY (`Tarif_TarifID` , `Buchungsklasse_BuchungsklassenID` , `Flugverbindung_Flugnummer`),
    FOREIGN KEY (`Flugverbindung_Flugnummer`)
        REFERENCES `Flugverbindung` (`Flugnummer`),
    FOREIGN KEY (`Tarif_TarifID`)
        REFERENCES `Tarif` (`TarifID`),
    FOREIGN KEY (`Buchungsklasse_BuchungsklassenID`)
        REFERENCES `Buchungsklasse` (`BuchungsklassenID`)
);

CREATE TABLE `Flug_Buchungsklasse` (
    `Flug_Flugdatum` DATE NOT NULL,
    `Flug_Maschine_Kennzeichen` VARCHAR(10) NOT NULL,
    `Flug_Flugverbindung_Flugnummer` VARCHAR(10) NOT NULL,
    `Buchungsklasse_BuchungsklassenID` INT NOT NULL,
    `Anzahl freier Plätze` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`Flug_Flugdatum` , `Flug_Maschine_Kennzeichen` , `Flug_Flugverbindung_Flugnummer` , `Buchungsklasse_BuchungsklassenID`),
    FOREIGN KEY (`Flug_Flugdatum`)
        REFERENCES `Flug` (`Flugdatum`),
    FOREIGN KEY (`Flug_Maschine_Kennzeichen`)
        REFERENCES `Maschine` (`Kennzeichen`),
    FOREIGN KEY (`Flug_Flugverbindung_Flugnummer`)
        REFERENCES `Flugverbindung` (`Flugnummer`),
    FOREIGN KEY (`Buchungsklasse_BuchungsklassenID`)
        REFERENCES `Buchungsklasse` (`BuchungsklassenID`)
);

 CREATE TABLE `Flugzeugtyp_Buchungsklasse` (
    `Flugzeugtyp_Modell` VARCHAR(10) NOT NULL,
    `Buchungsklasse_BuchungsklassenID` INT NOT NULL,
    `Platzangebot` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`Flugzeugtyp_Modell` , `Buchungsklasse_BuchungsklassenID`),
    FOREIGN KEY (`Flugzeugtyp_Modell`)
        REFERENCES `Flugzeugtyp` (`Modell`),
    FOREIGN KEY (`Buchungsklasse_BuchungsklassenID`)
        REFERENCES `Buchungsklasse` (`BuchungsklassenID`)
);

##################################
##Füllen der Tabellen mit Daten###
##################################

INSERT INTO `Flughafen` 
    (`Kürzel`, `Bezeichnung`, `Zeitzone`, `Steuersatz`, `Sicherheitsgebühren`)
VALUES 
    ('NUE', 'Nürnberg', 1, 30, 20),
    ('MUC', 'München', 1, 30, 25),
    ('STR', 'Stuttgart', 1, 30, 20),
    ('FRA', 'Frankfurt', 1, 30, 25),
    ('TXL', 'Berlin-Tegel', 1, 30, 20),
    ('CDG', 'Paris-Charles De Gaulle', 1, 35, 25),    
    ('LHR', 'London-Heathrow', 0, 40, 30),
    ('SFO', 'San Francisco', -8, 30, 50),
    ('LCY', 'London-City', 0, 40, 30);

INSERT INTO `Nachbarflughäfen`
    (`Flughafen1`, `Flughafen2`,`Distanz`)
VALUES
    ('NUE','MUC', 300),
    ('STR','FRA', 250),
    ('LHR','LCY', 40);

INSERT INTO `Hersteller` 
    (`Herstellername`)
VALUES
    ('Airbus'),
    ('Boeing'),
    ('Bombardier');
    

INSERT INTO `Flugzeugtyp` 
    (`Modell`, `Hersteller_HerstellerID`)
VALUES
    ('A321', 1), 
    ('A340-600', 1),
    ('747-400', 2),
    ('737-300', 2),
    ('CRJ900', 3);
    
INSERT INTO `Merkmal`
    (`Kürzel`, `Beschreibung`)
VALUES
    ('WWW', 'Internetanbindung während des Flugs'),
    ('SAT-TEL', 'Satellitentelefongespräche während des Flugs');
    
    
INSERT INTO `Maschine`
    (`Kennzeichen`, `Betriebsstunden`, `Betriebsstunden_seit_Wartung`, `Indienststellung`, `Flugzeugtyp_Modell`)
VALUES
    ('D-ABYZ', 12345, 643, '2005-04-09', 'A321'),
    ('D-CDUX', 15223, 804, '2005-04-09', 'A321'),
    ('D-BAXY', 45632, 231, '2001-03-27', 'A321'),
    ('D-EFST', 4102, 998, '2007-02-02', 'A340-600'),
    ('D-GHQR', 2023, 654, '2009-10-05', 'A340-600'),
    ('D-IKOP', 45632, 821, '2002-03-04', '747-400'),
    ('D-BORD', 9854, 678, '2003-08-10', '737-300'),
    ('D-LMNA', 1432, 70, '2007-03-08', 'CRJ900');
    
INSERT INTO `Maschine_Merkmal`
    (`Maschine_Kennzeichen`, `Merkmal_Kürzel`)
VALUES
    ('D-EFST', 'WWW'),
    ('D-GHQR', 'WWW'),
    ('D-IKOP', 'WWW'),
    ('D-IKOP', 'SAT-TEL'),
    ('D-EFST', 'SAT-TEL');
    
INSERT INTO `Buchungsklasse`
    (`Bezeichnung`)
VALUES
    ('Economy Class'),
    ('Business Class'),
    ('First Class');
    
INSERT INTO `Flugzeugtyp_Buchungsklasse`
    (`Flugzeugtyp_Modell`, `Buchungsklasse_BuchungsklassenID`, `Platzangebot`)
VALUES
    ('A321', 1, 190),
    ('A340-600', 1, 238),
    ('A340-600', 2, 60),
    ('A340-600', 3, 8),
    ('747-400', 1, 270),
    ('747-400', 2, 66),
    ('747-400', 3, 16),
    ('737-300', 1, 127),
    ('CRJ900', 1, 86);
       

INSERT INTO `Flugverbindung`
    (`Flugnummer`, `Abflugzeit`, `Ankunftszeit`, `Kerosinzuschlag`, `Startknoten`, `Endknoten`, `Flugzeugtyp_Modell`)
VALUES
    ('WWF 925', '09:40', '10:30', 10, 'NUE', 'FRA', 'A321'),
    ('WWF 926', '12:00', '13:10', 10, 'FRA', 'NUE', 'A321'),
    
    ('WWF 929', '09:40', '10:30', 10, 'NUE', 'FRA', 'CRJ900'),
    
    ('WWF 310', '06:45', '08:00', 10, 'NUE', 'TXL', 'A321'),
    ('WWF 312', '09:15', '10:30', 10, 'TXL', 'NUE', 'A321'),
    
    ('WWF 4756', '13:05', '14:05', 20, 'MUC', 'LHR', 'A340-600'),
    
    ('WWF 9488', '16:00', '17:20', 20, 'MUC', 'LCY', '737-300'),
    
    ('WWF 4210', '16:00', '17:20', 20, 'MUC', 'CDG', 'A340-600'),
    ('WWF 5210', '17:50', '21:00', 40, 'CDG', 'SFO', 'A340-600'),
    
    ('WWF 4711', '10:00', '13:50', 40, 'MUC', 'SFO', '747-400');
    
UPDATE `Flugverbindung` 
SET 
    `Montag` = 1,
    `Dienstag` = 1,
    `Mittwoch` = 1,
    `Donnerstag` = 1,
    `Freitag` = 1
WHERE
    `Flugnummer` = 'WWF 925'
        OR `Flugnummer` = 'WWF 926'
        OR `Flugnummer` = 'WWF 310'
        OR `Flugnummer` = 'WWF 312'
        OR `Flugnummer` = 'WWF 9488'
        OR `Flugnummer` = 'WWF 4756';

UPDATE `Flugverbindung` 
SET 
    `Samstag` = 1,
    `Sonntag` = 1
WHERE
    `Flugnummer` = 'WWF 929'
        OR `Flugnummer` = 'WWF 4756';

UPDATE `Flugverbindung` 
SET 
    `Montag` = 1,
    `Mittwoch` = 1,
    `Freitag` = 1
WHERE
    `Flugnummer` = 'WWF 4210'
        OR `Flugnummer` = 'WWF 5210';
 
UPDATE `Flugverbindung` 
SET 
    `Dienstag` = 1,
    `Donnerstag` = 1
WHERE
    `Flugnummer` = 'WWF 4711';
    
INSERT INTO `Flug`
    (`Flugdatum`, `Maschine_Kennzeichen`, `Flugverbindung_Flugnummer`)
VALUES
    ('2017-04-24', 'D-ABYZ', 'WWF 925'),
    ('2017-04-24', 'D-ABYZ', 'WWF 926'),
    
    ('2017-04-29', 'D-LMNA', 'WWF 929'),
    
    ('2017-04-24', 'D-BAXY', 'WWF 310'),
    ('2017-04-24', 'D-BAXY', 'WWF 312'),
    
    ('2017-04-30', 'D-EFST', 'WWF 4756'),
    
    ('2017-04-25', 'D-BORD', 'WWF 9488'),
    
    ('2017-04-28', 'D-EFST', 'WWF 4210'),
    ('2017-04-26', 'D-EFST', 'WWF 5210'),
    
    ('2017-04-27', 'D-IKOP', 'WWF 4711');

INSERT INTO `Tarif`
    (`Tarifbezeichnung`)
VALUES
    ('Normaltarif'),
    ('Frühbucher'),
    ('Last Minute');
    
INSERT INTO `Tarif_Buchungsklasse_Flugverbindung`
    (`Flugverbindung_Flugnummer`, `Buchungsklasse_BuchungsklassenID`, `Tarif_TarifID`, `Kosten`)
VALUES

#Normaltarif
    ('WWF 925', 1, 1, 190),
    ('WWF 926', 1, 1, 190),
    ('WWF 929', 1, 1, 190),
    ('WWF 310', 1, 1, 210),
    ('WWF 312', 1, 1, 210),
    ('WWF 4756', 1, 1, 240),
    ('WWF 4756', 2, 1, 470),
    ('WWF 4756', 3, 1, 690),
    ('WWF 4210', 1, 1, 240),
    ('WWF 4210', 2, 1, 490),
    ('WWF 4210', 3, 1, 700),
    ('WWF 5210', 1, 1, 350),
    ('WWF 5210', 2, 1, 690),
    ('WWF 5210', 3, 1, 810),
    ('WWF 4711', 1, 1, 610),
    ('WWF 4711', 2, 1, 1050),
    ('WWF 4711', 3, 1, 1820),
    ('WWF 9488', 1, 1, 240),
    
 #Frühbucher   
    ('WWF 925', 1, 2, 140),
    ('WWF 926', 1, 2, 140),
    ('WWF 929', 1, 2, 140),
    ('WWF 310', 1, 2, 165),
    ('WWF 312', 1, 2, 165),
    ('WWF 4756', 1, 2, 210),
    ('WWF 4756', 2, 2, 390),
    ('WWF 4756', 3, 2, 590),
    ('WWF 4210', 1, 2, 210),
    ('WWF 4210', 2, 2, 400),
    ('WWF 4210', 3, 2, 600),
    ('WWF 5210', 1, 2, 300),
    ('WWF 5210', 2, 2, 630),
    ('WWF 5210', 3, 2, 750),
    ('WWF 4711', 1, 2, 540),
    ('WWF 4711', 2, 2, 890),
    ('WWF 4711', 3, 2, 1500),
    ('WWF 9488', 1, 2, 210),

#Last Minute
    ('WWF 925', 1, 3, 100),
    ('WWF 926', 1, 3, 100),
    ('WWF 929', 1, 3, 100),
    ('WWF 310', 1, 3, 120),
    ('WWF 312', 1, 3, 120),
    ('WWF 4756', 1, 3, 160),
    ('WWF 4210', 1, 3, 160),
    ('WWF 5210', 1, 3, 290),
    ('WWF 4711', 1, 3, 480),
    ('WWF 4711', 2, 3, 950),
    ('WWF 9488', 1, 3, 160);
