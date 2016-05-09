DECLARE
   l_null_text   VARCHAR2(4 CHAR) := NULL;
   l_null_date   DATE := NULL;
BEGIN
   assert.is_true(TRUNC(SYSDATE) <= SYSDATE);
   assert.is_true(1 = 1, 'math has failed us');
   assert.is_false(1 > 2, 'math has failed us');
   assert.is_false('asdf' LIKE 'x%');

   assert.is_null(l_null_text);
   assert.is_null(l_null_date);
   assert.is_not_null(4);
   assert.is_not_null(SYSDATE);
   assert.is_not_null(FALSE);

   assert.equals('a', 'a', 'letters should match');
   assert.equals_ignore_case('abc', 'ABC');
   assert.equals_ns('xyz', 'xyz');
   assert.equals_ns(l_null_text, l_null_text);
   assert.equals(44.0, 44);
   assert.equals(1.0, 0.999, p_delta => 0.05);
   assert.equals(SYSDATE, SYSDATE);
   -- within 5 seconds
   assert.equals(TIMESTAMP '2002-04-01 09:59:59', TIMESTAMP '2002-04-01 10:00:03', p_delta => 5 / (24 * 60 * 60));
   assert.not_equal('a', 'b', 'letters should not match');
   assert.not_equal_ns('a', NULL);
   assert.not_equal_ns(NULL, 14);
   assert.not_equal_ns(SYSDATE, NULL);

   assert.in_list('a', text_nt('a'));
   assert.in_list('a', text_nt('a', 'b', 'c'));
   assert.in_list(4, number_nt(3, 4));
   assert.in_list(SYSDATE, date_nt(SYSDATE - 1, SYSDATE, SYSDATE + 1));

   assert.not_in_list('a', text_nt('x', 'y', 'z'));
   assert.not_in_list(14, number_nt(1, 2, 3));
   assert.not_in_list(DATE '1999-09-09', date_nt(SYSDATE, SYSDATE + 1));

   assert.matches_soundex('hair', 'hare');
   assert.matches_soundex('here', 'hear');
   -- within 1 character
   assert.matches('thick', 'think', p_levenshtein_delta => 1);
   -- within a Jaro-Winkler distance of:
   assert.matches('then', 'them', p_jaro_winkler_delta => 1.0);
   assert.matches('THEN', 'then', p_jaro_winkler_delta => 0.5);

   assert.less_than('11', '2');
   assert.less_than_equal('11', '2');
   assert.greater_than(11, 2);
   assert.greater_than_equal('33', '33');
   assert.less_than_equal(TRUNC(SYSDATE), SYSDATE);
   assert.is_between(3, 3, 5);
   assert.is_between(4, 3, 5);
   assert.is_between(5, 3, 5);
   assert.is_between(SYSDATE, TRUNC(SYSDATE), SYSDATE + 1 / 24);
   assert.is_between('a', 'a', 'a');

   assert.length_equals(NULL, 0);
   assert.length_equals('abc', 3);
   assert.min_length(NULL, 0);
   assert.min_length('xxx', 2);
   assert.max_length(NULL, 0);
   assert.max_length(NULL, 3);
   assert.max_length('abc', 3);
   assert.length_between(NULL, 0, 0);
   assert.length_between(NULL, 0, 3);
   assert.length_between('xyz', 3, 3);
   assert.length_between('xyz', 2, 5);

   assert.starts_with('The quick brown fox', 'The');
   assert.ends_with('The quick brown fox', 'fox');
   assert.contains('The quick brown fox', 'quick');

   assert.is_numeric('1234');
   assert.is_numeric('1.234e+56');
   assert.is_numeric('1.234e-56');
   assert.is_numeric('-14.2');
   assert.is_numeric('$1,000', p_mask => '$9,999,999.00');

   assert.is_date(TO_CHAR(SYSDATE));
   assert.is_date('July 1984', p_mask => 'Month YYYY');

   assert.is_positive(0.4);
   assert.is_negative(-4.8E+88);
   assert.is_not_positive(0);
   assert.is_not_positive(-1);
   assert.is_not_negative(1234);

   assert.is_today(SYSDATE);
   assert.is_today(TRUNC(SYSDATE));
   assert.is_past(TRUNC(SYSDATE), p_msg => 'only fails at midnight, why are you at work at midnight?');
   assert.is_future(SYSDATE + 1);
   -- Monday through Friday
   assert.is_weekday(TRUNC(SYSDATE, 'IW'));
   assert.is_weekday(TRUNC(SYSDATE, 'IW') + 1);
   assert.is_weekday(TRUNC(SYSDATE, 'IW') + 2);
   assert.is_weekday(TRUNC(SYSDATE, 'IW') + 3);
   assert.is_weekday(TRUNC(SYSDATE, 'IW') + 4);
   -- Saturday and Sunday
   assert.is_weekend(TRUNC(SYSDATE, 'IW') + 5);
   assert.is_weekend(TRUNC(SYSDATE, 'IW') + 6);

   BEGIN
      assert.fail('flag a bad execution path like this');
   EXCEPTION
      WHEN assert.test_failure
      THEN
         assert.equals(assert.extract_msg(SQLERRM), 'flag a bad execution path like this');
   END;
END;
/