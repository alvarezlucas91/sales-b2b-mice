SELECT so.allotmentbasisname as at_cd_allotment_name,
       sf.flight_number__c as at_cd_flight_number,
       sf.flight_date__c as at_dt_flight,
       sf.arrivalairportcode__c as at_cd_airport_arr,
       sf.departureairportcode__c as at_cd_airport_dep,
       so2.productcode,
       so2.unitprice,so2.quantity
FROM sfdc.sfdc_opportunity so
     JOIN  sfdc.sfdc_opportunitylineitem so2
        ON so.id_sfdc = so2.opportunityid
     JOIN sfdc.sfdc_flight sf
        ON so2.flight = sf.id_sfdc
        where so.allotmentbasisname!=''
     and  EXISTS (SELECT 1
                     FROM  salesb2b.stg_cust_group_allotment stg
                     WHERE   stg.at_cd_allotment_name = so.allotmentbasisname  AND
                             stg.at_cd_flight_number = sf.flight_number__c AND
                             stg.at_dt_flight = sf.flight_date__c AND
                             stg.at_cd_airport_dep = sf.departureairportcode__c AND
                             stg.at_cd_airport_arr = sf.arrivalairportcode__c)
     order by so.allotmentbasisname,sf.flight_number__c
