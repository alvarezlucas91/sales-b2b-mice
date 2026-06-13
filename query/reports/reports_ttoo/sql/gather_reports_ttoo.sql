SELECT
      ttoo_general.flight_date,
      ttoo_general.flight_number,
      ttoo_general.airport_orig,
      ttoo_general.airport_dest,
      ttoo_general.HoraSalida,
      ttoo_general.HoraLlegada,
      ttoo_general.rec_loc,
      ttoo_general.Pax_IATA,
      ttoo_general.fare_basis_nav
FROM
    (

    SELECT
          ttoo.flight_number,
          ttoo.flight_date,
          ttoo.HoraSalida,
          ttoo.HoraLlegada,
          ttoo.airport_orig,
          ttoo.airport_dest,
          ttoo.rec_loc,
          ttoo.Pax_IATA,
          ttoo.fare_basis_nav
    FROM
    (
          SELECT
            FF.flight_number
          , cast(FF.flight_date as  date)   as flight_date
          , substring(schedule_hour,1,2)    + ':' +substring(schedule_hour,3,2)   as  HoraSalida
          , substring(schedule_endhour,1,2) + ':' +substring(schedule_endhour,3,2) as HoraLlegada
          , FF.airport_orig
          , FF.airport_dest
          , fp.rec_loc
          , SUM
                (
                            CASE
                                WHEN IATA = '{0}'
                                    THEN 1
                                    ELSE 0
                            END

                ) as   Pax_IATA
          , fs.fare_basis_nav
        FROM
            FACTFLIGHT FF
            JOIN
                (
                    SELECT DISTINCT
                        FF.flight_sk
                    FROM
                        FACTPNR FP
                        JOIN
                            FACTSEGMENT FS
                            ON
                                FP.rec_loc = FS.rec_loc
                        JOIN
                            FactFlight FF
                            ON
                                FF.FLIGHT_SK = FS.flight_sk
                    WHERE
                        IATA                                         in('{0}')
                        AND fs.fare_basis_nav                        = 'GBPTG'
                        AND CONVERT(VARCHAR(8), FF.flight_date, 112) >= '{1}'
                )
                FU
                ON
                    FF.flight_sk = FU.flight_sk
            JOIN
                FACTSEGMENT FS
                ON
                    FF.flight_sk = FS.flight_sk
            JOIN
                FACTPNR FP
                ON
                    FS.rec_loc = FP.rec_loc
            JOIN
                (
                    SELECT
                        ff.flight_sk
                      , count(*) AS totalPax
                    FROM
                        FACTFLIGHT FF
                        JOIN
                            FACTSEGMENT FS
                            ON
                                FF.flight_sk = FS.flight_sk
                    GROUP BY
                        ff.flight_sk
                )
                tp
                ON
                    tp.flight_sk = ff.flight_sk
            JOIN
                Vueling_ODS..pax_leg pl
                ON
                    (
                        pl.rec_loc         =fs.rec_loc
                        AND pl.seg_seq_nbr =fs.seg_seq_nbr
                        AND pl.pax_nbr     =fs.pax_nbr
                    )
        WHERE
            CONVERT(VARCHAR(8), FF.flight_date, 112) >= '{1}'
            AND ff.idStatus                           = 1
            AND fp.IATA                               in ('{0}')
            AND fs.fare_basis_nav                     = 'GBPTG'
        GROUP BY
            FF.flight_number
          , cast(FF.flight_date as  date)
          , substring(schedule_hour,1,2)    + ':' +substring(schedule_hour,3,2)
          , substring(schedule_endhour,1,2) + ':' +substring(schedule_endhour,3,2)
          , FF.airport_orig
          , FF.airport_dest
          , FF.idStatus
          , FF.seats
          , fp.rec_loc
          , fp.iata
          , tp.totalPax
          , fs.fare_basis_nav
    )  ttoo
)  ttoo_general
