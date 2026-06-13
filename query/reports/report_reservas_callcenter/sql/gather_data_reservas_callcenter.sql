SELECT DISTINCT pnr.rec_loc    as Pnr,
				fs.at_dt_sale  as Dt_booking_date,
                a.AgentName    as AgentName,
                ar.RoleCode    as AgentRole,
                l.Name         as Location,
                fs.family_fare as FamilyFare,
                fs.ruta_global as Route
FROM VUELING_CALCODS..factpnr pnr
         JOIN VUELING_CALCODS..factsegment fs on pnr.rec_loc = fs.rec_loc
         JOIN VUELING_CALCODS..factflight ff on ff.flight_sk = fs.flight_sk
         JOIN Vueling_Navitaire..Agent a on a.AgentID = pnr.ID_BOOKING_AGENT
         JOIN Vueling_Navitaire..AgentRole ar on ar.AgentID = a.AgentID
         JOIN Vueling_Navitaire..Location l on l.LocationCode = a.LocationCode
WHERE pnr.sales_sk < 3
  AND CAST(pnr.booking_date as date) between '20240701' and getdate()
  AND ar.RoleCode IN ('RESX','CSEX','RESP');