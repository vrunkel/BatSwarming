# BatSwarming

Planung Matlab-Ersatz für Lena und Frauke

Felder-Beschreibung Objekt Fledermaus

ok season -> immer vom 15.7. bis 14.7. -> zB 2010-2011
ok transponder -> bat-id
ok sex -> aus erstmarkierung
ok age at marking -> aus erstmarkierung
ok age at season start -> aus erstmarkierung in erster season, dann ad
ok marking date -> aus erstmarkierung
ok marking location -> aus erstmarkierung
ok first read date in ES -> 15.4. bis 14.7.
ok last read date in ES -> 15.4. bis 14.7.
ok # days with readings in ES -> anzahl tage in 15.4. bis 14.7.
ok first read date in season (after 15.7.) -> erstes auftreten in season
ok last read date before ES (15.4.) -> letztes auftreten vor dem 15.4.

Start LHI -> start longest hibernation interval lhi = längste periode ohne lesung
End LHI  -> end longest hibernation interval
# days with readings before LHI -> „differenz“ tage zwischen start LHI und 15.7.
#days with readings after LHI (bis 15.4.) -> „differenz“ tage zwischen end LHI und 15.4.
LHI length -> tage lhi

ok last read date in season -> letzte lesung 
ok loggers;



ES = early summer = 15.4. bis 14.7.




SELECT SUBSTR(Ablesungen_auto.Datum,1,10) AS Datum, SUBSTR(Ablesungen_auto.Uhrzeit,11) AS Uhrzeit, Ablesungen_auto.TransponderID, Ablesungen_auto.LesegeraetID, Erstmarkierungen.OrtID AS Erst_Ort, SUBSTR(Erstmarkierungen.Datum,1,10) AS Erst_Datum, SUBSTR(Erstmarkierungen.Uhrzeit,11) AS Erst_Uhrzeit, Erstmarkierungen.Geschlecht, Erstmarkierungen.Alter, Erstmarkierungen.Art FROM Ablesungen_auto, Erstmarkierungen WHERE Ablesungen_auto.LesegeraetID IN (345,409) AND LOWER(Ablesungen_auto.TransponderID) = LOWER(Erstmarkierungen.TransponderPID) AND LOWER(Erstmarkierungen.Art) IN ('mn', 'md');


Neu 2020: unit 5 zusätzlich zu 409 und 345

SELECT SUBSTR(Ablesungen_auto.Datum,1,10) AS Datum, SUBSTR(Ablesungen_auto.Uhrzeit,11) AS Uhrzeit, Ablesungen_auto.TransponderID, Ablesungen_auto.LesegeraetID, Erstmarkierungen.OrtID AS Erst_Ort, SUBSTR(Erstmarkierungen.Datum,1,10) AS Erst_Datum, SUBSTR(Erstmarkierungen.Uhrzeit,11) AS Erst_Uhrzeit, Erstmarkierungen.Geschlecht, Erstmarkierungen.Alter, Erstmarkierungen.Art FROM Ablesungen_auto, Erstmarkierungen WHERE Ablesungen_auto.LesegeraetID IN (5,345,409) AND LOWER(Ablesungen_auto.TransponderID) = LOWER(Erstmarkierungen.TransponderPID) AND LOWER(Erstmarkierungen.Art) IN ('mn', 'md');
