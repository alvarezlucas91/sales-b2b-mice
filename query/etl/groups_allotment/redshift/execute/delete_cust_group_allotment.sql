DELETE from salesb2b.cust_group_allotment c
WHERE exists (SELECT 1
FROM salesb2b.stg_group_allotment s
    where  c.at_cd_allotment = s.at_cd_allotment
    and c.id_inventory_leg=s.id_inventory_leg
);