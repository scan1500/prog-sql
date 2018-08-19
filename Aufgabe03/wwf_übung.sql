use wwfgusc;

SELECT 
    kürzel, bezeichnung, zeitzone
FROM
    flughafen
ORDER BY bezeichnung;

SELECT 
    maschine.kennzeichen, hersteller.herstellername
FROM
    maschine
        JOIN
    flugzeugtyp ON maschine.flugzeugtyp_modell = flugzeugtyp.modell
        JOIN
    hersteller ON flugzeugtyp.hersteller_herstellerid = hersteller.herstellerid
WHERE
    hersteller.herstellername NOT LIKE 'Boeing'
ORDER BY maschine.kennzeichen;

SELECT 
    hersteller.herstellername,
    flugzeugtyp.modell,
    maschine.kennzeichen,
    maschine_merkmal.merkmal_kürzel
FROM
    hersteller
        JOIN
    flugzeugtyp ON hersteller.herstellerid = flugzeugtyp.hersteller_herstellerid
        JOIN
    maschine ON flugzeugtyp.modell = maschine.flugzeugtyp_modell
        JOIN
    maschine_merkmal ON maschine.kennzeichen = maschine_merkmal.maschine_kennzeichen
ORDER BY hersteller.herstellername , flugzeugtyp.modell , maschine.kennzeichen;

SELECT 
    COUNT(maschine.kennzeichen) AS Anzahl_Merkmal_Satellitentelefon
FROM
    maschine
        JOIN
    maschine_merkmal ON maschine.kennzeichen = maschine_merkmal.maschine_kennzeichen
WHERE
    maschine_merkmal.merkmal_kürzel LIKE 'SAT-TEL';

SELECT 
    hersteller.herstellername,
    COUNT(maschine.kennzeichen) AS Anzahl_Pro_Hersteller
FROM
    maschine
        JOIN
    flugzeugtyp ON maschine.flugzeugtyp_modell = flugzeugtyp.modell
        JOIN
    hersteller ON flugzeugtyp.hersteller_herstellerid = hersteller.herstellerid
GROUP BY hersteller.herstellername
ORDER BY hersteller.herstellername;

SELECT 
    hersteller.herstellername,
    flugzeugtyp.modell,
    COUNT(flugverbindung.flugnummer) AS Anzahl
FROM
    flugzeugtyp
        JOIN
    hersteller ON flugzeugtyp.hersteller_herstellerid = hersteller.herstellerid
        JOIN
    flugverbindung ON flugzeugtyp.modell = flugverbindung.flugzeugtyp_modell
GROUP BY hersteller.herstellername
HAVING Anzahl = 1;

SELECT 
    hersteller.herstellername,
    flugzeugtyp.modell,
    SUM(flugzeugtyp_buchungsklasse.platzangebot) AS Gesamtplätze
FROM
    flugzeugtyp
        JOIN
    hersteller ON flugzeugtyp.hersteller_herstellerid = hersteller.herstellerid
        JOIN
    flugzeugtyp_buchungsklasse ON flugzeugtyp.modell = flugzeugtyp_buchungsklasse.flugzeugtyp_modell
GROUP BY flugzeugtyp.modell
HAVING SUM(flugzeugtyp_buchungsklasse.platzangebot) >= 150
ORDER BY hersteller.herstellername , flugzeugtyp.modell;

SELECT DISTINCT
    flugverbindung.flugnummer,
    abflug.bezeichnung AS Abflugort,
    ankunft.bezeichnung AS Ankunftsort,
    MIN(tarif_buchungsklasse_flugverbindung.kosten) AS Mindestpreis
FROM
    flugverbindung
        JOIN
    flughafen abflug ON flugverbindung.startknoten = abflug.kürzel
        JOIN
    flughafen ankunft ON flugverbindung.endknoten = ankunft.kürzel
        JOIN
    tarif_buchungsklasse_flugverbindung ON flugverbindung.flugnummer = tarif_buchungsklasse_flugverbindung.flugverbindung_flugnummer
GROUP BY flugverbindung.flugnummer
HAVING Mindestpreis >= 250
ORDER BY abflug.bezeichnung , ankunft.bezeichnung;

SELECT 
    hersteller.herstellername,
    flugzeugtyp.modell,
    maschine.kennzeichen
FROM
    maschine
        JOIN
    flugzeugtyp ON maschine.flugzeugtyp_modell = flugzeugtyp.modell
        JOIN
    hersteller ON flugzeugtyp.hersteller_herstellerid = hersteller.herstellerid
WHERE
    DATEDIFF(CURDATE(), maschine.indienststellung) / 365.25 BETWEEN 5 AND 10
GROUP BY maschine.kennzeichen;

SELECT 
    flughafen.kürzel,
    flughafen.bezeichnung,
    (flughafen.sicherheitsgebühren + flughafen.steuersatz) AS Kosten
FROM
    flughafen
HAVING Kosten = (SELECT 
        MIN(flughafen.sicherheitsgebühren + flughafen.steuersatz)
    FROM
        flughafen)
ORDER BY flughafen.bezeichnung;

SELECT 
    hersteller.herstellername,
    flugzeugtyp.modell,
    maschine.kennzeichen
FROM
    maschine
        JOIN
    flugzeugtyp ON maschine.flugzeugtyp_modell = flugzeugtyp.modell
        JOIN
    hersteller ON flugzeugtyp.hersteller_herstellerid = hersteller.herstellerid
        LEFT JOIN
    maschine_merkmal ON maschine.kennzeichen = maschine_merkmal.maschine_kennzeichen
WHERE
    maschine_merkmal.maschine_kennzeichen IS NULL
ORDER BY hersteller.herstellername , flugzeugtyp.modell , maschine.kennzeichen;

SELECT 
    flugverbindung.flugnummer,
    abflug.bezeichnung,
    ankunft.bezeichnung,
    (flugverbindung.kerosinzuschlag + abflug.sicherheitsgebühren + abflug.steuersatz + tarif_buchungsklasse_flugverbindung.kosten) AS Gesamtpreis
FROM
    flugverbindung
        JOIN
    flughafen abflug ON flugverbindung.startknoten = abflug.kürzel
        JOIN
    flughafen ankunft ON flugverbindung.endknoten = ankunft.kürzel
        JOIN
    tarif_buchungsklasse_flugverbindung ON flugverbindung.flugnummer = tarif_buchungsklasse_flugverbindung.flugverbindung_flugnummer
        JOIN
    tarif ON tarif_buchungsklasse_flugverbindung.tarif_tarifid = tarif.tarifid
        JOIN
    buchungsklasse ON tarif_buchungsklasse_flugverbindung.buchungsklasse_buchungsklassenid = buchungsklasse.buchungsklassenid
WHERE
    tarif.tarifid = 1
        AND buchungsklasse.buchungsklassenid = 1
        AND (abflug.bezeichnung LIKE 'Frankfurt'
        OR abflug.bezeichnung LIKE 'München')
ORDER BY flugverbindung.flugnummer , abflug.bezeichnung;

#Abfrage13
SELECT  flughafen.kürzel,
COUNT(case flughafen.kürzel when flugverbindung.startknoten then 1 else null end) AS Abflüge,
COUNT(case flughafen.kürzel when flugverbindung.endknoten then 1 else null end) AS Ankunft
FROM
flughafen
LEFT JOIN
flugverbindung ON flughafen.kürzel = (flugverbindung.startknoten OR flugverbindung.endknoten)
GROUP BY flughafen.kürzel;

#Abfrage14
SELECT hersteller.herstellername, flugzeugtyp.modell, maschine.kennzeichen, 
(flugzeugtyp.maximale_betriebsstunden - maschine.betriebsstunden) AS Restliche_Betriebsstunden
FROM
maschine
JOIN
flugzeugtyp ON maschine.flugzeugtyp_modell = flugzeugtyp.modell
JOIN
hersteller ON flugzeugtyp.hersteller_herstellerid = hersteller.herstellerid
HAVING Restliche_Betriebsstunden = 
(Select MIN((flugzeugtyp.maximale_betriebsstunden - maschine.betriebsstunden)) 
FROM maschine JOIN flugzeugtyp ON maschine.flugzeugtyp_modell = flugzeugtyp.modell);

#Abfrage15
SELECT abflug.bezeichnung AS von , ankunft.bezeichnung AS nach, MIN(tarif_buchungsklasse_flugverbindung.kosten) AS Günstigster_Preis
FROM
flugverbindung
JOIN
flughafen abflug ON flugverbindung.startknoten = abflug.kürzel
JOIN
flughafen ankunft ON flugverbindung.endknoten = ankunft.kürzel
Join
tarif_buchungsklasse_flugverbindung ON flugverbindung.flugnummer = tarif_buchungsklasse_flugverbindung.flugverbindung_flugnummer
JOIN
tarif ON tarif_buchungsklasse_flugverbindung.tarif_tarifid = tarif.tarifid
JOIN
buchungsklasse ON tarif_buchungsklasse_flugverbindung.buchungsklasse_buchungsklassenid = buchungsklasse.buchungsklassenid
GROUP BY von, nach
ORDER BY von, nach;

#Abfrage16
SELECT flugverbindung.flugnummer, abflug.bezeichnung AS Abflughafen , ankunft.bezeichnung AS Ankunftsflughafen,
TIME(ABS(DATE_ADD(TIMEDIFF(flugverbindung.ankunftszeit, flugverbindung.abflugzeit), INTERVAL (abflug.zeitzone-ankunft.zeitzone) hour))) AS Dauer
FROM
flugverbindung
JOIN
flughafen abflug ON flugverbindung.startknoten = abflug.kürzel
JOIN
flughafen ankunft ON flugverbindung.endknoten = ankunft.kürzel
ORDER BY Abflughafen, Ankunftsflughafen; 

#Abfrage17
SELECT flugverbindung.flugnummer, abflug.bezeichnung AS Abflughafen, ankunft.bezeichnung AS Ankunftsflughafen,
flugverbindung.abflugzeit, flugverbindung.ankunftszeit
FROM
flugverbindung
JOIN
flughafen abflug ON flugverbindung.startknoten = abflug.kürzel
JOIN
flughafen ankunft ON flugverbindung.endknoten = ankunft.kürzel
JOIN
nachbarflughäfen ON ankunft.kürzel = nachbarflughäfen.flughafen
WHERE abflug.bezeichnung like 'München' AND ((ankunft.bezeichnung like 'London-City') 
OR ('LCY' = nachbarflughäfen.nachbar))
ORDER BY Abflughafen, Ankunftsflughafen; 

#Abfrage18
SELECT f1.flugnummer AS Flugnummer1, abflug_f1.bezeichnung AS von1, f1.abflugzeit AS Abflug1, ankunft_f1.bezeichnung AS nach1, f1.ankunftszeit AS Ankunft1,
'-' AS Flugnummer2, '-' as von2, '-' as abflug2, '-' as nach2, '-' as Ankunft2
FROM
flugverbindung f1
JOIN
flughafen abflug_f1 ON f1.startknoten = abflug_f1.kürzel
JOIN
flughafen ankunft_f1 ON f1.endknoten = ankunft_f1.kürzel
WHERE (abflug_f1.bezeichnung = 'München' AND ankunft_f1.bezeichnung = 'San Francisco')

UNION

SELECT f1.flugnummer AS Flugnummer1, abflug_f1.bezeichnung AS von1, f1.abflugzeit AS Abflug1, ankunft_f1.bezeichnung AS nach1, f1.ankunftszeit AS Ankunft1,
f2.flugnummer AS Flugnummer2, abflug_f2.bezeichnung AS von2, f2.abflugzeit AS Abflug2, ankunft_f2.bezeichnung AS nach2, f2.ankunftszeit AS Ankunft2
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
WHERE (abflug_f1.bezeichnung = 'München' AND ankunft_f2.bezeichnung = 'San Francisco');
