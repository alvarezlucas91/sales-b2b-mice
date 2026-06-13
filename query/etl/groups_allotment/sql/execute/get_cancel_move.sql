SELECT
       ClassOfService as at_cd_allotment_name,
       FlightNumber   as at_cd_flight_number,
       DepartureDate  as at_dt_flight,
       DepartureStation as at_cd_airport_dep,
	   ArrivalStation   as  at_cd_airport_arr,
	   AGENTNAME as at_cd_organization,
       ca_pax,
       CONVERT(datetime, SWITCHOFFSET(CONVERT(DATETIMEOFFSET, CreatedUTC), DATENAME(TZOFFSET, SYSDATETIMEOFFSET()))) AS  at_ts_allotment_created,
	   CONVERT(datetime, SWITCHOFFSET(CONVERT(DATETIMEOFFSET, VersionStartUTC), DATENAME(TZOFFSET, SYSDATETIMEOFFSET()))) AS  at_ts_allotment_modifed,
       MOVE_SALES  AS at_cd_status,
	   DT_CONFUTC  AS at_dt_confirmed,
       PnrConf AS  at_cd_pnr_confirmed,
	   InventoryLegid AS id_inventory_leg,
	   GETDATE()  AS ts_creation,
	   GETDATE()  AS ts_modified
FROM vueling_calcods.dbo.stg_clClassAllotments_gral;
