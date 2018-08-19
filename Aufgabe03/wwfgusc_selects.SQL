use wwfgusc;

#1
CREATE OR REPLACE VIEW abfrage01 AS
    SELECT 
        Kürzel, Bezeichnung, Zeitzone
    FROM
        flughafen
    ORDER BY Bezeichnung; 
    
#2
CREATE OR REPLACE VIEW abfrage02 AS
    SELECT 
        Kennzeichen AS Kennzeichen
    FROM
        maschine m
            JOIN
        flugzeugtyp ft ON m.Flugzeugtyp_modell = ft.modell
            JOIN
        hersteller h ON ft.hersteller_HerstellerID = h.HerstellerID
    WHERE
        h.herstellername NOT LIKE 'Boeing'
    ORDER BY m.kennzeichen;
    
#3
CREATE OR REPLACE VIEW abfrage03 AS
    SELECT DISTINCT
        h.herstellername AS Hersteller,
        ft.modell AS Modell,
        m.kennzeichen AS Kennzeichen
    FROM
        maschine m
            JOIN
        flugzeugtyp ft ON m.flugzeugtyp_modell = ft.modell
            JOIN
        hersteller h ON ft.hersteller_herstellerID = h.herstellerID
            JOIN
        maschine_merkmal mm ON m.kennzeichen = mm.maschine_kennzeichen
    ORDER BY h.herstellername , ft.modell , m.kennzeichen;

#4
CREATE OR REPLACE VIEW abfrage04 AS
    SELECT 
        COUNT(maschine_kennzeichen) AS `mit Satellitentelefon`
    FROM
        maschine_merkmal
    WHERE
        merkmal_kürzel LIKE 'SAT-TEL';
	
#5
CREATE OR REPLACE VIEW abfrage05 AS
    SELECT 
        h.herstellername AS Herstellername,
        COUNT(*) AS `Anzahl der Flugzeuge`
    FROM
        maschine m
            JOIN
        flugzeugtyp ft ON m.flugzeugtyp_modell = ft.modell
            JOIN
        hersteller h ON ft.hersteller_herstellerID = h.herstellerID
    GROUP BY h.herstellername
    ORDER BY h.herstellername;
    
#06
CREATE OR REPLACE VIEW abfrage06 AS
    SELECT 
        h.herstellername AS Hersteller, ft.modell AS Modell
    FROM
        flugzeugtyp ft
            JOIN
        hersteller h ON ft.hersteller_herstellerID = h.herstellerID
            JOIN
        flugverbindung fv ON ft.modell = fv.flugzeugtyp_modell
    GROUP BY ft.modell
    HAVING COUNT(fv.flugzeugtyp_modell) = 1
    ORDER BY h.herstellername , ft.modell;

#07
CREATE OR REPLACE VIEW abfrage07 AS
    SELECT 
        h.herstellername AS Hersteller,
        ft.modell AS Modell,
        SUM(ftb.platzangebot) AS Sitzplätze
    FROM
        flugzeugtyp ft
            JOIN
        flugzeugtyp_buchungsklasse ftb ON ft.modell = ftb.flugzeugtyp_modell
            JOIN
        hersteller h ON ft.hersteller_herstellerID = h.herstellerID
    GROUP BY ft.modell
    HAVING Sitzplätze >= 150
    ORDER BY h.herstellername , ft.modell;

#08
CREATE OR REPLACE VIEW abfrage08 AS
    SELECT DISTINCT
        fv.flugnummer AS Flugnummer,
        startk.bezeichnung AS Startknoten,
        endk.bezeichnung AS Endknoten,
        MIN(tbf.kosten) AS Mindestpreis
    FROM
        flugverbindung fv
            JOIN
        flughafen startk ON fv.startknoten = startk.kürzel
            JOIN
        flughafen endk ON fv.endknoten = endk.kürzel
            JOIN
        tarif_buchungsklasse_flugverbindung tbf ON fv.flugnummer = tbf.flugverbindung_flugnummer
    GROUP BY fv.flugnummer
    HAVING mindestpreis >= 250
    ORDER BY startk.bezeichnung , endk.bezeichnung;

#09
CREATE OR REPLACE VIEW abfrage09 AS
    SELECT 
        h.herstellername AS Hersteller,
        ft.modell AS Modell,
        m.kennzeichen AS Kennzeichen
    FROM
        maschine m
            JOIN
        flugzeugtyp ft ON m.flugzeugtyp_modell = ft.modell
            JOIN
        hersteller h ON ft.hersteller_herstellerID = h.herstellerID
    WHERE
        DATEDIFF(CURDATE(), m.indienststellung) / 365.25 BETWEEN 5 AND 10
    ORDER BY m.kennzeichen;
   
#10
CREATE OR REPLACE VIEW abfrage10 AS
    SELECT 
        Kürzel,
        Bezeichnung,
        (steuersatz + sicherheitsgebühren) AS Zusatzkosten
    FROM
        flughafen
    WHERE Zusatzkosten = (SELECT 
            MIN(Zusatzkosten)
        FROM
            flughafen)
    ORDER BY Bezeichnung;
    
#11
CREATE OR REPLACE VIEW abfrage11 AS
    SELECT 
        h.herstellername AS Hersteller,
        ft.modell AS Modell,
        m.kennzeichen AS Kennzeichen
    FROM
        maschine m
            JOIN
        flugzeugtyp ft ON m.flugzeugtyp_modell = ft.modell
            JOIN
        hersteller h ON ft.hersteller_herstellerID = h.herstellerID
            LEFT JOIN
        maschine_merkmal mm ON m.kennzeichen = mm.maschine_kennzeichen
    WHERE
        mm.maschine_kennzeichen IS NULL
    ORDER BY h.herstellername , ft.modell , m.kennzeichen;

#12
CREATE OR REPLACE VIEW abfrage12 AS
    SELECT 
        fv.flugnummer AS Flugnummer,
        startk.bezeichnung AS Startknoten,
        endk.bezeichnung AS Endknoten,
        (startk.sicherheitsgebühren + startk.steuersatz + fv.kerosinzuschlag + tbv.kosten) AS Gesamtpreis
    FROM
        flugverbindung fv
            JOIN
        flughafen startk ON fv.startknoten = startk.kürzel
            JOIN
        flughafen endk ON fv.endknoten = endk.kürzel
            JOIN
        tarif_buchungsklasse_flugverbindung tbv ON tbv.flugverbindung_flugnummer = fv.flugnummer
            JOIN
        tarif t ON tbv.tarif_tarifID = t.tarifid
            JOIN
        buchungsklasse b ON tbv.buchungsklasse_buchungsklassenID = b.buchungsklassenID
    WHERE
        (startk.bezeichnung = 'Frankfurt'
            OR startk.bezeichnung = 'München')
            AND t.tarifbezeichnung = 'Normaltarif'
            AND b.bezeichnung = 'Economy Class';
   
#13  
CREATE OR REPLACE VIEW abfrage13 AS
SELECT 
    f.kürzel,
    COUNT(CASE f.kürzel
        WHEN fv.startknoten THEN 1
        ELSE NULL
    END) AS `als Startknoten`,
    COUNT(CASE f.kürzel
        WHEN fv.endknoten THEN 1
        ELSE NULL
    END) AS `als Endknoten`
FROM
    flughafen f
        LEFT JOIN
    flugverbindung fv ON f.kürzel = (fv.startknoten OR fv.endknoten)
GROUP BY f.kürzel; 
    
#14
CREATE OR REPLACE VIEW abfrage14 AS
    SELECT 
        h.herstellername AS Herstellername,
        ft.modell AS Modell,
        m.kennzeichen AS Kennzeichen
    FROM
        maschine m
            JOIN
        flugzeugtyp ft ON ft.modell = m.flugzeugtyp_modell
            JOIN
        hersteller h ON ft.hersteller_herstellerID = h.herstellerID
    WHERE
        ft.max_Betriebsstunden - m.betriebsstunden = (SELECT 
                MIN(ft.max_betriebsstunden - m.betriebsstunden)
            FROM
                maschine m
                    JOIN
                flugzeugtyp ft ON ft.modell = m.flugzeugtyp_modell);
                
#15
CREATE OR REPLACE VIEW abfrage15 AS
    SELECT 
        startk.bezeichnung AS Startknoten,
        endk.bezeichnung AS Endknoten,
        MIN(tbf.kosten) AS `minimale Kosten`
    FROM
        flugverbindung fv
            JOIN
        flughafen startk ON startk.kürzel = fv.startknoten
            JOIN
        flughafen endk ON endk.kürzel = fv.endknoten
            JOIN
        tarif_buchungsklasse_flugverbindung tbf ON tbf.flugverbindung_flugnummer = fv.flugnummer
    GROUP BY startk.bezeichnung , endk.bezeichnung
    ORDER BY startknoten , endknoten;
    
#16
CREATE OR REPLACE VIEW abfrage16 AS
    SELECT 
        fv.flugnummer AS Flugnummer,
        startk.bezeichnung AS Startknoten,
        endk.bezeichnung AS Endknoten,
        CAST(TIME_TO_SEC(TIME_FORMAT(TIME(ABS(DATE_ADD(TIMEDIFF(fv.ankunftszeit, fv.abflugzeit), 
		INTERVAL (startk.zeitzone - endk.zeitzone) HOUR))),'%H:%i'))/60 AS UNSIGNED INT) AS Flugdauer_Minuten
    FROM
        flugverbindung fv
            JOIN
        flughafen startk ON fv.startknoten = startk.kürzel
            JOIN
        flughafen endk ON fv.endknoten = endk.kürzel
    ORDER BY Startknoten , Endknoten; 

#Abfrage17
CREATE OR REPLACE VIEW abfrage17 AS
    SELECT 
        fv.flugnummer AS Flugnummer,
        startk.bezeichnung AS Abflughafen,
        endk.bezeichnung AS Ankunftsflughafen,
        TIME_FORMAT(fv.abflugzeit,'%H:%i') AS Abflugzeit,
        TIME_FORMAT(fv.ankunftszeit, '%H:%i') AS Ankuftszeit
    FROM
        flugverbindung fv
            JOIN
        flughafen startk ON fv.startknoten = startk.kürzel
            JOIN
        flughafen endk ON fv.endknoten = endk.kürzel
            JOIN
        nachbarflughäfen n ON 'LCY' = (n.flughafen1 OR n.flughafen2)
    WHERE
        startk.bezeichnung = 'München'
            AND endk.bezeichnung = 'London-City'
            OR (startk.bezeichnung LIKE 'München'
            AND (endk.kürzel = n.flughafen1
            OR endk.kürzel = n.flughafen2))
    GROUP BY Flugnummer; 


#18
CREATE OR REPLACE VIEW abfrage18 AS
    SELECT 
        f1.flugnummer AS Flugnummer1,
        abflug_f1.bezeichnung AS von1,
        TIME_FORMAT(f1.abflugzeit,'%H:%i') AS Abflug1,
        ankunft_f1.bezeichnung AS nach1,
        TIME_FORMAT(f1.ankunftszeit, '%H:%i') AS Ankunft1,
        '-' AS Flugnummer2,
        '-' AS von2,
        '-' AS abflug2,
        '-' AS nach2,
        '-' AS Ankunft2
    FROM
        flugverbindung f1
            JOIN
        flughafen abflug_f1 ON f1.startknoten = abflug_f1.kürzel
            JOIN
        flughafen ankunft_f1 ON f1.endknoten = ankunft_f1.kürzel
    WHERE
        (abflug_f1.bezeichnung = 'München'
            AND ankunft_f1.bezeichnung = 'San Francisco') 
    UNION SELECT 
        f1.flugnummer AS Flugnummer1,
        abflug_f1.bezeichnung AS von1,
        TIME_FORMAT(f1.abflugzeit,'%H:%i') AS Abflug1,
        ankunft_f1.bezeichnung AS nach1,
        TIME_FORMAT(f1.ankunftszeit, '%H:%i') AS Ankunft1,
        f2.flugnummer AS Flugnummer2,
        abflug_f2.bezeichnung AS von2,
        TIME_FORMAT(f2.abflugzeit, '%H:%i') AS Abflug2,
        ankunft_f2.bezeichnung AS nach2,
        TIME_FORMAT(f2.ankunftszeit, '%H:%i') AS Ankunft2
    FROM
        flugverbindung f1
            JOIN
        flughafen abflug_f1 ON f1.startknoten = abflug_f1.kürzel
            JOIN
        flughafen ankunft_f1 ON f1.endknoten = ankunft_f1.kürzel
            LEFT JOIN
        flugverbindung f2 ON f1.endknoten = f2.startknoten
            JOIN
        flughafen abflug_f2 ON f2.startknoten = abflug_f2.kürzel
            JOIN
        flughafen ankunft_f2 ON f2.endknoten = ankunft_f2.kürzel
    WHERE
        (abflug_f1.bezeichnung = 'München'
            AND ankunft_f2.bezeichnung = 'San Francisco');

/*
SELECT maschine.kennzeichen
    
    FROM maschine 
    JOIN flugzeugtyp ON maschine.flugzeugtyp_modell = flugzeugtyp.modell 
    JOIN flugverbindung ON flugzeugtyp.modell = flugverbindung.flugzeugtyp_modell
    WHERE maschine.kennzeichen = 'D-ABYZ' AND flugverbindung.flugzeugtyp_modell = 'A321';
*/
/*
SELECT flugzeugtyp_buchungsklasse.platzangebot
    FROM maschine 
    JOIN flugzeugtyp ON maschine.flugzeugtyp_modell = flugzeugtyp.modell 
    JOIN flugzeugtyp_buchungsklasse ON flugzeugtyp.modell = flugzeugtyp_buchungsklasse.flugzeugtyp_modell
    
	WHERE maschine.kennzeichen = 'D-EFST' AND flugzeugtyp_buchungsklasse.Buchungsklasse_BuchungsklassenID =1;
    
SELECT * FROM flug_buchungsklasse;

SELECT MAX(COUNT(max_betriebsstunden)) FROM flugzeugtyp
HAVING anzahl_freier_plätze = (SELECT MAX(anzahl_freier_plätze) FROM flug_buchungsklasse);
*/