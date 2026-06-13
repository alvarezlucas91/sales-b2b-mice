INSERT INTO {0}
SELECT DISTINCT ClassOfService
FROM Vueling_Navitaire.Rez.InventoryLegNest iln WITH (nolock)
    INNER JOIN Vueling_Navitaire.REZ.InventoryLegClass ilc
WITH (nolock)
ON iln.inventorylegid = ilc.inventorylegid AND iln.ClassNest = ilc.ClassNest
WHERE ilc.ClassType = 'N'