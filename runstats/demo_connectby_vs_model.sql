DECLARE
   TYPE numbers_tt IS TABLE OF NUMBER;
   l_numbers              numbers_tt;
   k_test_size   CONSTANT PLS_INTEGER := 8;
BEGIN
   rs.reset();

   SELECT LEVEL
     BULK COLLECT INTO l_numbers
     FROM DUAL
   CONNECT BY LEVEL <= k_test_size;

   rs.snap();

   SELECT num
     BULK COLLECT INTO l_numbers
     FROM DUAL
   MODEL RETURN UPDATED ROWS
      DIMENSION BY(0 idx)
      MEASURES(0 AS num)
      RULES
         (num [FOR idx FROM 1 TO k_test_size INCREMENT 1] = CV(idx));

   rs.snap();
END;
/

--BEGIN
--   rs.set_stat_threshold(100);
--   rs.set_stat_delta_threshold(5);
--END;
--/

SELECT *
  FROM swx_snaps2_v
 ORDER BY ratio DESC, snap2 DESC;