DECLARE
   l_integer   PLS_INTEGER;
   l_hex       VARCHAR2(80 CHAR);
   l_num_tbl   int_nt;
   l_cur       SYS_REFCURSOR;
BEGIN
   assert.equals(numbers.decimal_to_hex(15), 'F');
   assert.equals(numbers.decimal_to_hex(-15), '-F');
   assert.equals(numbers.decimal_to_hex(16), '10');

   assert.equals(numbers.hex_to_decimal('ff'), 255);
   assert.equals(numbers.hex_to_decimal('-100'), -256);
   assert.equals(numbers.hex_to_decimal('A'), 10);

   FOR i IN -100 .. 100
   LOOP
      -- convert i to hex and then back
      l_hex := numbers.decimal_to_hex(i);
      assert.equals(numbers.hex_to_decimal(l_hex), i);

      -- convert a random number to hex and then back
      l_integer := DBMS_RANDOM.random();
      l_hex := numbers.decimal_to_hex(l_integer);
      --dbms_output.put_line(l_integer || ' --> '||l_hex);
      assert.equals(numbers.hex_to_decimal(l_hex), l_integer);
   END LOOP;

   l_num_tbl := numbers.int_table(-3, 7);
   assert.equals(l_num_tbl.COUNT, 11);
   assert.equals(l_num_tbl(1), -3);
   assert.equals(l_num_tbl(11), 7);

   SELECT COLUMN_VALUE
     BULK COLLECT INTO l_num_tbl
     FROM TABLE(numbers.int_stream(-3, 7));

   assert.equals(l_num_tbl.COUNT, 11);
   assert.equals(l_num_tbl(1), -3);
   assert.equals(l_num_tbl(11), 7);

   l_cur := numbers.int_cur(-3, 7);

   FETCH l_cur   BULK COLLECT INTO l_num_tbl;

   CLOSE l_cur;

   assert.equals(l_num_tbl.COUNT, 11);
   assert.equals(l_num_tbl(1), -3);
   assert.equals(l_num_tbl(11), 7);
END;
/