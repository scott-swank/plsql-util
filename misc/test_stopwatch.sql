DECLARE
   sw                  stopwatch := stopwatch();
   v_seconds_waited1   NUMBER;
   v_seconds_waited2   NUMBER;
BEGIN
   -- dbms_lock.sleep() rounds UP to hsecs,
   -- so we must pass in hsecs to avoid rounding errors
   v_seconds_waited1 := ROUND(DBMS_RANDOM.VALUE(0.0, 0.05), 2);
   v_seconds_waited2 := ROUND(DBMS_RANDOM.VALUE(0.0, 0.05), 2);
   --   DBMS_OUTPUT.put_line(v_seconds_waited1 || ', ' || v_seconds_waited2);
   sw.start_timing();
   DBMS_LOCK.sleep(v_seconds_waited1);
   assert.equals(sw.split(), v_seconds_waited1, p_delta => 0.01);
   DBMS_LOCK.sleep(v_seconds_waited2);
   assert.equals(sw.split(), v_seconds_waited2, p_delta => 0.01);
   assert.equals(sw.split(), 0, p_delta => 0.01);
   assert.equals(sw.total(), v_seconds_waited1 + v_seconds_waited2, p_delta => 0.01);
   sw.unsplit();
   assert.equals(sw.stop_timing(), v_seconds_waited1 + v_seconds_waited2, p_delta => 0.01);
   assert.equals(sw.total(), v_seconds_waited1 + v_seconds_waited2, p_delta => 0.01);
END;
/