select
    cs_booking_date as cs_booking_date,
    cs_transaction_date as cs_transaction_date,
    cf_transaction_date as cf_transaction_date,
    refund_transaction_date as refund_transaction_date,
    cs_pnr as cs_pnr,
    cf_pnr as cf_pnr,
    refund_pnr as refund_pnr,
    cs_total_amt as cs_total_amt,
    cf_total_amt as cf_total_amt,
    refund_total_amt as refund_total_amt,
    expired_date as expired_date,
    cs_total_amt - cf_total_amt - refund_amt as available,
    cs_agency as agency_cs,
    cf_agency as agency_cf,
    refund_agency as agency_refund,
    cs_agent_name as agent_name_cs,
    cf_agent_name as agent_name_cf,
    refund_agent_name as agent_name_refund,
    agent_name as agent_name,
    cs_agent_organization_name as agent_organization_cs,
    cf_agent_organization_name as agent_organization_cf,
    refund_agent_organization_name as agent_organization_refund,
	agent_organization_code as agent_organization,
    cs_agent_department_name as agent_department_cs,
    cf_agent_department_name as agent_department_cf,
    refund_agent_department_name as agent_department_refund,
    agent_department_code as agent_department
from paymentsprocessoptimization.v_credit_flight v
left join (
    select pnr, min(agency_iata) as cs_agency, min(agent_name) as cs_agent_name,  min(agent_organization_name) as cs_agent_organization_name, min(agent_department_name) as cs_agent_department_name
    , agent_name, agent_organization_code, agent_department_code
    from revenueaccounting.v_segment_info
    group by pnr, agent_name, agent_organization_code, agent_department_code) cs
on v.cs_pnr = cs.pnr
left join (
    select pnr, min(agency_iata) as cf_agency, min(agent_name) as cf_agent_name,  min(agent_organization_name) as cf_agent_organization_name, min(agent_department_name) as cf_agent_department_name
    from revenueaccounting.v_segment_info
    group by pnr) cf
on v.cf_pnr = cf.pnr
left join (
    select pnr, min(agency_iata) as refund_agency, min(agent_name) as refund_agent_name,  min(agent_organization_name) as refund_agent_organization_name, min(agent_department_name) as refund_agent_department_name
    from revenueaccounting.v_segment_info
    group by pnr) refund
on v.refund_pnr = refund.pnr
WHERE cs_booking_date between '{0}' and '{1}'
ORDER BY cs_booking_date;