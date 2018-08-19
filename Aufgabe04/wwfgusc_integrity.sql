use wwfgusc;

# Aufgabe 1
/*
Mit Außerdienststellung (Löschung) eines Flugzeugs wird auch die 
Information gelöscht, welche Ausstattungsmerkmale es besitzt (ALTER TABLE…).
*/
ALTER TABLE wwfgusc.Maschine_Merkmal 
DROP FOREIGN KEY maschine_merkmal_ibfk_1;

ALTER TABLE wwfgusc.Maschine_Merkmal 
ADD CONSTRAINT  maschine_merkmal_ibfk_1 
FOREIGN KEY (`Maschine_Kennzeichen`) 
REFERENCES `Maschine` (`Kennzeichen`) ON DELETE CASCADE;

# Aufgabe 2
/*
Für einen Flug dürfen nur Maschinen des für die 
Flugverbindung vorgesehenen Typs eingesetzt werden (TRIGGER).
*/
/*
DROP TRIGGER IF EXISTS tr_falscher_flugzeugtyp;
DELIMITER //
CREATE TRIGGER tr_falscher_flugzeugtyp BEFORE INSERT ON wwfgusc.Flug 
FOR EACH ROW
BEGIN

	IF (SELECT COUNT(maschine.kennzeichen) 
    
    FROM maschine 
    JOIN flugzeugtyp ON maschine.flugzeugtyp_modell = flugzeugtyp.modell 
    JOIN flugverbindung ON flugzeugtyp.modell = flugverbindung.flugzeugtyp_modell
    
	WHERE NEW.maschine_kennzeichen = maschine.kennzeichen AND NEW.flugverbindung_flugnummer = flugverbindung.flugnummer) = 0
	THEN signal sqlstate '45000' set message_text = 'Falscher Flugzeugtyp für Flugverbindung';
    
END IF;
END //
DELIMITER ;
*/
/*
INSERT INTO `Flug`
    (`Flugdatum`, `Maschine_Kennzeichen`, `Flugverbindung_Flugnummer`)
VALUES
    ('2017-04-26', 'D-IKOP', 'WWF 925');
*/

# Aufgabe 3 
/*
Bei Neuanlage eines Flugs wird die Anzahl freier Plätze pro Klasse mit der Maximalzahl 
an Plätzen der entsprechenden Klasse im verwendeten Flugzeugtyp initialisiert (TRIGGER).
*/


DROP TRIGGER IF EXISTS tr_falscher_flugzeugtyp;
DROP TRIGGER IF EXISTS tr_plaetze_neuanlage;
DELIMITER //
CREATE TRIGGER tr_plaetze_neuanlage AFTER INSERT ON wwfgusc.Flug 
FOR EACH ROW
BEGIN

	INSERT INTO Flug_Buchungsklasse 
	(`Flug_Flugdatum`, `Flug_Maschine_Kennzeichen`, `Flug_Flugverbindung_Flugnummer`, `Buchungsklasse_BuchungsklassenID`, `Anzahl freier Plätze`)
    SELECT NEW.flugdatum, NEW.maschine_kennzeichen, NEW.flugverbindung_flugnummer, 1, flugzeugtyp_buchungsklasse.platzangebot
    FROM 
    flugzeugtyp_buchungsklasse
    JOIN
    flugzeugtyp ON flugzeugtyp_buchungsklasse.flugzeugtyp_modell = flugzeugtyp.modell
    JOIN
    maschine ON flugzeugtyp.modell = maschine.flugzeugtyp_modell
	WHERE NEW.maschine_kennzeichen = maschine.kennzeichen AND flugzeugtyp_buchungsklasse.buchungsklasse_buchungsklassenID = 1;
    
	INSERT INTO Flug_Buchungsklasse 
	(`Flug_Flugdatum`, `Flug_Maschine_Kennzeichen`, `Flug_Flugverbindung_Flugnummer`, `Buchungsklasse_BuchungsklassenID`, `Anzahl freier Plätze`)
    SELECT NEW.flugdatum, NEW.maschine_kennzeichen, NEW.flugverbindung_flugnummer, 2, flugzeugtyp_buchungsklasse.platzangebot
    FROM
    flugzeugtyp_buchungsklasse
    JOIN
    flugzeugtyp ON flugzeugtyp_buchungsklasse.flugzeugtyp_modell = flugzeugtyp.modell
    JOIN
    maschine ON flugzeugtyp.modell = maschine.flugzeugtyp_modell
	WHERE NEW.maschine_kennzeichen = maschine.kennzeichen AND flugzeugtyp_buchungsklasse.buchungsklasse_buchungsklassenID = 2;
    
	INSERT INTO Flug_Buchungsklasse 
	(`Flug_Flugdatum`, `Flug_Maschine_Kennzeichen`, `Flug_Flugverbindung_Flugnummer`, `Buchungsklasse_BuchungsklassenID`, `Anzahl freier Plätze`)
    SELECT NEW.flugdatum, NEW.maschine_kennzeichen, NEW.flugverbindung_flugnummer, 3, flugzeugtyp_buchungsklasse.platzangebot
    FROM
    flugzeugtyp_buchungsklasse
    JOIN
    flugzeugtyp ON flugzeugtyp_buchungsklasse.flugzeugtyp_modell = flugzeugtyp.modell
    JOIN
    maschine ON flugzeugtyp.modell = maschine.flugzeugtyp_modell
	WHERE NEW.maschine_kennzeichen = maschine.kennzeichen AND flugzeugtyp_buchungsklasse.buchungsklasse_buchungsklassenID = 3;
    
END //
DELIMITER ;

# Aufgabe 4
/*
Schreiben Sie eine gespeicherte PROZEDUR, die Flugnummer, Abflug- und Ankunftszeit und noch 
verfügbare Plätze in der Economy-Klasse aller Flüge zwischen zwei Flughäfen an einem bestimmten 
Datum ermittelt. Die Kürzel der beiden Flughäfen und das Flugdatum werden als Parameter übergeben.
*/
DROP PROCEDURE IF EXISTS pr_eco_search;
DELIMITER //
CREATE PROCEDURE pr_eco_search(IN abflugort CHAR(3), IN ankunftsort CHAR(3), IN flugdatum DATE)
BEGIN
  SELECT flugverbindung.flugnummer, flugverbindung.abflugzeit, flugverbindung.ankunftszeit, flug_buchungsklasse.`Anzahl freier Plätze`
    FROM
        flugverbindung
		JOIN
        flughafen startk ON flugverbindung.startknoten = startk.kürzel
		JOIN
        flughafen endk ON flugverbindung.endknoten = endk.kürzel
		JOIN
		flugzeugtyp ON flugverbindung.flugzeugtyp_modell = flugzeugtyp.modell
		JOIN
		maschine ON flugzeugtyp.modell = maschine.flugzeugtyp_modell
		JOIN
		flug ON flugverbindung.flugnummer = flug.flugverbindung_flugnummer
		AND maschine.kennzeichen = flug.maschine_kennzeichen
        JOIN
        buchungsklasse
        JOIN
        flug_buchungsklasse ON flug.flugdatum = flug_buchungsklasse.flug_flugdatum 
        AND maschine.kennzeichen = flug_buchungsklasse.flug_maschine_kennzeichen
		AND flugverbindung.flugnummer = flug_buchungsklasse.flug_flugverbindung_flugnummer
		AND buchungsklasse.buchungsklassenid = flug_buchungsklasse.buchungsklasse_buchungsklassenid

  WHERE flugverbindung.startknoten = abflugort 
  AND flugverbindung.endknoten = ankunftsort 
  AND Flug_Buchungsklasse.flug_flugdatum = flugdatum
  AND buchungsklasse.buchungsklassenid = 1;
END //
DELIMITER ;

INSERT INTO `Flug`
    (`Flugdatum`, `Maschine_Kennzeichen`, `Flugverbindung_Flugnummer`)
VALUES
    ('2077-04-24', 'D-ABYZ', 'WWF 925'),
    ('2077-04-24', 'D-EFST', 'WWF 4756');
    
CALL pr_eco_search ('NUE','FRA','2077-04-24');

# Aufgabe 5
/*
Erstellen Sie eine FUNKTION, die für eine Flugverbindung die Gesamtflugdauer 
in Minuten ermittelt (in Anlehnung an Abfrage 16 von Aufgabenblatt 3). 
Die Kennung der Flugverbindung wird als Parameter übergeben.
*/
DELIMITER //

CREATE FUNCTION fnc_flight_duration(kennung VARCHAR(10)) RETURNS INT
BEGIN
RETURN (SELECT CAST(TIME_TO_SEC(TIME_FORMAT(TIME(ABS(DATE_ADD(TIMEDIFF(flugverbindung.ankunftszeit, flugverbindung.abflugzeit), 
		INTERVAL (startk.zeitzone - endk.zeitzone) HOUR))),'%H:%i'))/60 AS UNSIGNED INT) AS Flugdauer_Minuten
FROM
flugverbindung
JOIN
flughafen startk ON flugverbindung.startknoten = startk.kürzel
JOIN
flughafen endk ON flugverbindung.endknoten = endk.kürzel
WHERE flugverbindung.Flugnummer = kennung);
END //
DELIMITER ;



