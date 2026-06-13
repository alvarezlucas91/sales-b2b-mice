SELECT  at_cd_allotment_name,id_inventory_leg,ts_modified
FROM  salesb2b.cust_group_allotment  a
WHERE at_cd_status = 0
and not exists (
                SELECT 1
                FROM  salesb2b.cust_group_allotment b
                WHERE at_cd_status  in (-1,-2,1)
                and a.at_cd_allotment_name = b.at_cd_allotment_name AND
                a.id_inventory_leg = b.id_inventory_leg
              )
  AND at_dt_flight<GETDATE()
  group by at_cd_allotment_name,id_inventory_leg,ts_modified