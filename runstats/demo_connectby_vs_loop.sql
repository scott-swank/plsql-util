DECLARE
   TYPE numbers_tt IS TABLE OF NUMBER;
   l_numbers              numbers_tt;
   k_test_size   CONSTANT PLS_INTEGER := 5000000;
BEGIN
   rs.reset();

   SELECT level
     BULK COLLECT INTO l_numbers
     FROM DUAL
   CONNECT BY LEVEL <= k_test_size;

   rs.snap();

   l_numbers.delete();

   FOR i IN 1 .. k_test_size
   LOOP
      l_numbers.extend();
      l_numbers(i) := i;
   END LOOP;

   rs.snap();
END;
/

SELECT *
  FROM swx_snaps2_v
 ORDER BY ratio DESC, diff DESC;