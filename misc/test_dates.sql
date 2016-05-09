DECLARE
   l_cur     SYS_REFCURSOR;
   l_dates   date_nt;
BEGIN
   assert.equals(dates.days_in_month(DATE '2015-02-01'), 28);
   assert.equals(dates.days_in_month(DATE '2015-02-14'), 28);
   assert.equals(dates.days_in_month(DATE '2015-02-28'), 28);
   assert.equals(dates.days_in_month(DATE '2016-02-01'), 29);
   assert.is_between(dates.days_in_month(SYSDATE), 28, 31);

   assert.equals(dates.days_in_year(DATE '2015-02-01'), 365);
   assert.equals(dates.days_in_year(DATE '2016-02-01'), 366);

   assert.is_true(dates.is_weekday(DATE '2016-02-01'));
   assert.is_true(dates.is_weekday(DATE '2016-02-02'));
   assert.is_true(dates.is_weekday(DATE '2016-02-03'));
   assert.is_true(dates.is_weekday(DATE '2016-02-04'));
   assert.is_true(dates.is_weekday(DATE '2016-02-05'));
   assert.is_true(dates.is_weekend(DATE '2016-02-06'));
   assert.is_true(dates.is_weekend(DATE '2016-02-07'));

   l_dates := dates.date_table(DATE '2016-02-01', DATE '2016-02-08');
   assert.equals(l_dates.COUNT, 8);
   assert.equals(l_dates(1), DATE '2016-02-01');
   assert.equals(l_dates(2), DATE '2016-02-02');
   assert.equals(l_dates(8), DATE '2016-02-08');

   l_dates := dates.date_table(DATE '2016-02-01', 8);
   assert.equals(l_dates.COUNT, 8);
   assert.equals(l_dates(1), DATE '2016-02-01');
   assert.equals(l_dates(2), DATE '2016-02-02');
   assert.equals(l_dates(8), DATE '2016-02-08');

   SELECT COLUMN_VALUE
     BULK COLLECT INTO l_dates
     FROM TABLE(dates.date_stream(DATE '2016-02-01', DATE '2016-02-08'));

   assert.equals(l_dates.COUNT, 8);
   assert.equals(l_dates(1), DATE '2016-02-01');
   assert.equals(l_dates(2), DATE '2016-02-02');
   assert.equals(l_dates(8), DATE '2016-02-08');

   SELECT COLUMN_VALUE
     BULK COLLECT INTO l_dates
     FROM TABLE(dates.date_stream(DATE '2016-02-01', 8));

   assert.equals(l_dates.COUNT, 8);
   assert.equals(l_dates(1), DATE '2016-02-01');
   assert.equals(l_dates(2), DATE '2016-02-02');
   assert.equals(l_dates(8), DATE '2016-02-08');

   l_cur := dates.date_cur(DATE '2016-02-01', DATE '2016-02-08');

   FETCH l_cur   BULK COLLECT INTO l_dates;

   CLOSE l_cur;

   assert.equals(l_dates.COUNT, 8);
   assert.equals(l_dates(1), DATE '2016-02-01');
   assert.equals(l_dates(2), DATE '2016-02-02');
   assert.equals(l_dates(8), DATE '2016-02-08');

   l_cur := dates.date_cur(DATE '2016-02-01', 8);

   FETCH l_cur   BULK COLLECT INTO l_dates;

   CLOSE l_cur;

   assert.equals(l_dates.COUNT, 8);
   assert.equals(l_dates(1), DATE '2016-02-01');
   assert.equals(l_dates(2), DATE '2016-02-02');
   assert.equals(l_dates(8), DATE '2016-02-08');
END;
/