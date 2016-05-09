DECLARE
   l_text     VARCHAR (30 CHAR);
   l_number   NUMBER := 555;
BEGIN
   rs.reset ();
   l_text := 'first value';
   rs.snap ();

   FOR i IN 1 .. 50000
   LOOP
      l_number := EXP (LN (l_number));
   END LOOP;

   l_text := '555 = ' || trunc(l_number);
   rs.snap ();
--
  rs.set_stat_threshold(1000);
  rs.set_stat_delta_threshold(5);
END;
/

SELECT * FROM swx_snaps2_v
order by ratio desc, snap2 desc;