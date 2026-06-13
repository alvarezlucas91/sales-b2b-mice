DELETE
FROM salesb2b.cust_alliance
USING salesb2b.stg_cust_alliance
WHERE cust_alliance.at_cd_rec_loc=stg_cust_alliance.at_cd_rec_loc
  AND cust_alliance.at_seg_seq_nbr = stg_cust_alliance.at_seg_seq_nbr
  AND cust_alliance.at_pax_nbr= stg_cust_alliance.at_pax_nbr;