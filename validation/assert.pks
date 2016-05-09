CREATE OR REPLACE PACKAGE assert
AS
   /*
      ==============================================================================
      PL/SQL PACKAGE assert

      The package ASSERT is an argument validation library. Failed assertions result
      in an illegal_argument exception, defined below.

      A note on parameters. The assertion APIs begin with value parameters:
         assert.less_than(3, 18);

      Afterward there is an optional error message:
         assert.less_than(3, 18, 'Age must be below 18.');

      Finally we have optional field name parameters:
         assert.less_than(3, 18, p_field1 => 'CHILD_AGE', p_field2 => 'ADULT_THRESHOLD');

      The token constants may be used in the construction of error messages, e.g.
      assert.equals('12345','11111', 'Zipcode [VALUE1] should match [VALUE2 ]');

      ------------------------------------------------------------------------------

      OPEN SOURCE ORACLE PL/SQL
      Version 0.8
      Copyright (C) 2003-2015 Scott Swank  scott.swank@gmail.com

      This program is free software; you can redistribute it and/or
      modify it under the terms of the GNU General Public License
      as published by the Free Software Foundation; either version 2
      of the License, or (at your option) any later version.

      This program is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      GNU General Public License for more details.

      You should have received a copy of the GNU General Public License
      along with this program; if not, write to the Free Software
      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
      ==============================================================================
   */

   field1_token            CONSTANT VARCHAR2(30 CHAR) := '[FIELD1]';
   field2_token            CONSTANT VARCHAR2(30 CHAR) := '[FIELD2]';
   field3_token            CONSTANT VARCHAR2(30 CHAR) := '[FIELD3]';

   value1_token            CONSTANT VARCHAR2(30 CHAR) := '[VALUE1]';
   value2_token            CONSTANT VARCHAR2(30 CHAR) := '[VALUE2]';
   value3_token            CONSTANT VARCHAR2(30 CHAR) := '[VALUE3]';

   test_failure_code       CONSTANT PLS_INTEGER := -20701;
   test_failure                     EXCEPTION;
   PRAGMA EXCEPTION_INIT(test_failure, -20701);

   illegal_argument_code   CONSTANT PLS_INTEGER := -20702;
   illegal_argument                 EXCEPTION;
   PRAGMA EXCEPTION_INIT(illegal_argument, -20702);

   /**
   *  FUNCTION extract_msg
   *
   *  Extract the error message text, i.e. without ORA-12345 prefix
   **/
   FUNCTION extract_msg(p_sqlerrm IN VARCHAR2, p_sqlcode IN PLS_INTEGER DEFAULT illegal_argument_code)
      RETURN VARCHAR2;

   /**
   *  PROCEDURE fail
   **/
   PROCEDURE fail(p_msg IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_true
   **/
   PROCEDURE is_true(p_condition IN BOOLEAN, p_msg IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_false
   **/
   PROCEDURE is_false(p_condition IN BOOLEAN, p_msg IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_null
   **/
   PROCEDURE is_null(p_value IN VARCHAR2, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_null
   **/
   PROCEDURE is_null(p_value IN NUMBER, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_null
   **/
   PROCEDURE is_null(p_value IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_null
   **/
   PROCEDURE is_null(p_value IN BOOLEAN, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_not_null
   **/
   PROCEDURE is_not_null(p_value IN VARCHAR2, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_not_null
   **/
   PROCEDURE is_not_null(p_value IN NUMBER, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_not_null
   **/
   PROCEDURE is_not_null(p_value IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_not_null
   **/
   PROCEDURE is_not_null(p_value IN BOOLEAN, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE equals
   **/
   PROCEDURE equals(p_value1   IN VARCHAR2,
                    p_value2   IN VARCHAR2,
                    p_msg      IN VARCHAR2 DEFAULT NULL,
                    p_field1   IN VARCHAR2 DEFAULT NULL,
                    p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE equals_ignore_case
   **/
   PROCEDURE equals_ignore_case(p_value1   IN VARCHAR2,
                                p_value2   IN VARCHAR2,
                                p_msg      IN VARCHAR2 DEFAULT NULL,
                                p_field1   IN VARCHAR2 DEFAULT NULL,
                                p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE matches
   *
   *  p_levenshtein_delta defines the maximum acceptable Levenshtein distance.
   *  This is measured in characters.
   **/
   PROCEDURE matches(p_value1              IN VARCHAR2,
                     p_value2              IN VARCHAR2,
                     p_levenshtein_delta   IN PLS_INTEGER,
                     p_msg                 IN VARCHAR2 DEFAULT NULL,
                     p_field1              IN VARCHAR2 DEFAULT NULL,
                     p_field2              IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE matches
   *
   *  p_jaro_winkler_delta defines the maximum acceptable Jaro-Winkler distance.
   **/
   PROCEDURE matches(p_value1               IN VARCHAR2,
                     p_value2               IN VARCHAR2,
                     p_jaro_winkler_delta   IN NUMBER,
                     p_msg                  IN VARCHAR2 DEFAULT NULL,
                     p_field1               IN VARCHAR2 DEFAULT NULL,
                     p_field2               IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE matches_soundex
   **/
   PROCEDURE matches_soundex(p_value1   IN VARCHAR2,
                             p_value2   IN VARCHAR2,
                             p_msg      IN VARCHAR2 DEFAULT NULL,
                             p_field1   IN VARCHAR2 DEFAULT NULL,
                             p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE equals
   **/
   PROCEDURE equals(p_value1   IN NUMBER,
                    p_value2   IN NUMBER,
                    p_msg      IN VARCHAR2 DEFAULT NULL,
                    p_field1   IN VARCHAR2 DEFAULT NULL,
                    p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE equals
   **/
   PROCEDURE equals(p_value1   IN NUMBER,
                    p_value2   IN NUMBER,
                    p_delta    IN NUMBER,
                    p_msg      IN VARCHAR2 DEFAULT NULL,
                    p_field1   IN VARCHAR2 DEFAULT NULL,
                    p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE equals
   **/
   PROCEDURE equals(p_value1   IN DATE,
                    p_value2   IN DATE,
                    p_msg      IN VARCHAR2 DEFAULT NULL,
                    p_field1   IN VARCHAR2 DEFAULT NULL,
                    p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE equals
   **/
   PROCEDURE equals(p_value1   IN DATE,
                    p_value2   IN DATE,
                    p_delta    IN NUMBER,
                    p_msg      IN VARCHAR2 DEFAULT NULL,
                    p_field1   IN VARCHAR2 DEFAULT NULL,
                    p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE equals_ns
   *
   *  This null-safe variant accepts matching values, including NULL.
   **/
   PROCEDURE equals_ns(p_value1   IN VARCHAR2,
                       p_value2   IN VARCHAR2,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE equals_ns
   *
   *  This null-safe variant accepts matching values, including NULL.
   **/
   PROCEDURE equals_ns(p_value1   IN NUMBER,
                       p_value2   IN NUMBER,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE equals_ns
   *
   *  This null-safe variant accepts matching values, including NULL.
   **/
   PROCEDURE equals_ns(p_value1   IN DATE,
                       p_value2   IN DATE,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE not_equal
   **/
   PROCEDURE not_equal(p_value1   IN VARCHAR2,
                       p_value2   IN VARCHAR2,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE not_equal
   **/
   PROCEDURE not_equal(p_value1   IN NUMBER,
                       p_value2   IN NUMBER,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE not_equal
   **/
   PROCEDURE not_equal(p_value1   IN DATE,
                       p_value2   IN DATE,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE not_equal_ns
   *
   *  This null-safe variant accepts non-matching values, including NULL.
   **/
   PROCEDURE not_equal_ns(p_value1   IN VARCHAR2,
                          p_value2   IN VARCHAR2,
                          p_msg      IN VARCHAR2 DEFAULT NULL,
                          p_field1   IN VARCHAR2 DEFAULT NULL,
                          p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE not_equal_ns
   *
   *  This null-safe variant accepts non-matching values, including NULL.
   **/
   PROCEDURE not_equal_ns(p_value1   IN NUMBER,
                          p_value2   IN NUMBER,
                          p_msg      IN VARCHAR2 DEFAULT NULL,
                          p_field1   IN VARCHAR2 DEFAULT NULL,
                          p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE in_list
   **/
   PROCEDURE in_list(p_value      IN VARCHAR2,
                     p_elements   IN text_nt,
                     p_msg        IN VARCHAR2 DEFAULT NULL,
                     p_field      IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE in_list
   **/
   PROCEDURE in_list(p_value      IN NUMBER,
                     p_elements   IN number_nt,
                     p_msg        IN VARCHAR2 DEFAULT NULL,
                     p_field      IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE in_list
   **/
   PROCEDURE in_list(p_value      IN DATE,
                     p_elements   IN date_nt,
                     p_msg        IN VARCHAR2 DEFAULT NULL,
                     p_field      IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE not_in_list
   **/
   PROCEDURE not_in_list(p_value      IN VARCHAR2,
                         p_elements   IN text_nt,
                         p_msg        IN VARCHAR2 DEFAULT NULL,
                         p_field      IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE not_in_list
   **/
   PROCEDURE not_in_list(p_value      IN NUMBER,
                         p_elements   IN number_nt,
                         p_msg        IN VARCHAR2 DEFAULT NULL,
                         p_field      IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE not_in_list
   **/
   PROCEDURE not_in_list(p_value      IN DATE,
                         p_elements   IN date_nt,
                         p_msg        IN VARCHAR2 DEFAULT NULL,
                         p_field      IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE less_than
   **/
   PROCEDURE less_than(p_value1   IN VARCHAR2,
                       p_value2   IN VARCHAR2,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE less_than
   **/
   PROCEDURE less_than(p_value1   IN NUMBER,
                       p_value2   IN NUMBER,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE less_than
   **/
   PROCEDURE less_than(p_value1   IN DATE,
                       p_value2   IN DATE,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE less_than_equal
   **/
   PROCEDURE less_than_equal(p_value1   IN VARCHAR2,
                             p_value2   IN VARCHAR2,
                             p_msg      IN VARCHAR2 DEFAULT NULL,
                             p_field1   IN VARCHAR2 DEFAULT NULL,
                             p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE less_than_equal
   **/
   PROCEDURE less_than_equal(p_value1   IN NUMBER,
                             p_value2   IN NUMBER,
                             p_msg      IN VARCHAR2 DEFAULT NULL,
                             p_field1   IN VARCHAR2 DEFAULT NULL,
                             p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE less_than_equal
   **/
   PROCEDURE less_than_equal(p_value1   IN DATE,
                             p_value2   IN DATE,
                             p_msg      IN VARCHAR2 DEFAULT NULL,
                             p_field1   IN VARCHAR2 DEFAULT NULL,
                             p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE greater_than
   **/
   PROCEDURE greater_than(p_value1   IN VARCHAR2,
                          p_value2   IN VARCHAR2,
                          p_msg      IN VARCHAR2 DEFAULT NULL,
                          p_field1   IN VARCHAR2 DEFAULT NULL,
                          p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE greater_than
   **/
   PROCEDURE greater_than(p_value1   IN NUMBER,
                          p_value2   IN NUMBER,
                          p_msg      IN VARCHAR2 DEFAULT NULL,
                          p_field1   IN VARCHAR2 DEFAULT NULL,
                          p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE greater_than
   **/
   PROCEDURE greater_than(p_value1   IN DATE,
                          p_value2   IN DATE,
                          p_msg      IN VARCHAR2 DEFAULT NULL,
                          p_field1   IN VARCHAR2 DEFAULT NULL,
                          p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE greater_than_equal
   **/
   PROCEDURE greater_than_equal(p_value1   IN VARCHAR2,
                                p_value2   IN VARCHAR2,
                                p_msg      IN VARCHAR2 DEFAULT NULL,
                                p_field1   IN VARCHAR2 DEFAULT NULL,
                                p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE greater_than_equal
   **/
   PROCEDURE greater_than_equal(p_value1   IN NUMBER,
                                p_value2   IN NUMBER,
                                p_msg      IN VARCHAR2 DEFAULT NULL,
                                p_field1   IN VARCHAR2 DEFAULT NULL,
                                p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE greater_than_equal
   **/
   PROCEDURE greater_than_equal(p_value1   IN DATE,
                                p_value2   IN DATE,
                                p_msg      IN VARCHAR2 DEFAULT NULL,
                                p_field1   IN VARCHAR2 DEFAULT NULL,
                                p_field2   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_between
   **/
   PROCEDURE is_between(p_value1        IN VARCHAR2,
                        p_lower_bound   IN VARCHAR2,
                        p_upper_bound   IN VARCHAR2,
                        p_msg           IN VARCHAR2 DEFAULT NULL,
                        p_field1        IN VARCHAR2 DEFAULT NULL,
                        p_field2        IN VARCHAR2 DEFAULT NULL,
                        p_field3        IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_between
   **/
   PROCEDURE is_between(p_value1        IN NUMBER,
                        p_lower_bound   IN NUMBER,
                        p_upper_bound   IN NUMBER,
                        p_msg           IN VARCHAR2 DEFAULT NULL,
                        p_field1        IN VARCHAR2 DEFAULT NULL,
                        p_field2        IN VARCHAR2 DEFAULT NULL,
                        p_field3        IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_between
   **/
   PROCEDURE is_between(p_value1        IN DATE,
                        p_lower_bound   IN DATE,
                        p_upper_bound   IN DATE,
                        p_msg           IN VARCHAR2 DEFAULT NULL,
                        p_field1        IN VARCHAR2 DEFAULT NULL,
                        p_field2        IN VARCHAR2 DEFAULT NULL,
                        p_field3        IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE length_equals
   *
   *  The length of NULL is considered to be zero.
   **/
   PROCEDURE length_equals(p_value    IN VARCHAR2,
                           p_length   IN PLS_INTEGER,
                           p_msg      IN VARCHAR2 DEFAULT NULL,
                           p_field    IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE min_length
   *
   *  The length of NULL is considered to be zero.
   **/
   PROCEDURE min_length(p_value        IN VARCHAR2,
                        p_min_length   IN PLS_INTEGER,
                        p_msg          IN VARCHAR2 DEFAULT NULL,
                        p_field        IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE max_length
   *
   *  The length of NULL is considered to be zero.
   **/
   PROCEDURE max_length(p_value        IN VARCHAR2,
                        p_max_length   IN PLS_INTEGER,
                        p_msg          IN VARCHAR2 DEFAULT NULL,
                        p_field        IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE length_between
   *
   *  The length of NULL is considered to be zero.
   **/
   PROCEDURE length_between(p_value        IN VARCHAR2,
                            p_min_length   IN PLS_INTEGER,
                            p_max_length   IN PLS_INTEGER,
                            p_msg          IN VARCHAR2 DEFAULT NULL,
                            p_field        IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE starts_with
   **/
   PROCEDURE starts_with(p_value    IN VARCHAR2,
                         p_prefix   IN VARCHAR2,
                         p_msg      IN VARCHAR2 DEFAULT NULL,
                         p_field    IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE ends_with
   **/
   PROCEDURE ends_with(p_value    IN VARCHAR2,
                       p_suffix   IN VARCHAR2,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field    IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE contains
   **/
   PROCEDURE contains(p_value       IN VARCHAR2,
                      p_substring   IN VARCHAR2,
                      p_msg         IN VARCHAR2 DEFAULT NULL,
                      p_field       IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_numeric
   **/
   PROCEDURE is_numeric(p_value   IN VARCHAR2,
                        p_msg     IN VARCHAR2 DEFAULT NULL,
                        p_mask    IN VARCHAR2 DEFAULT NULL,
                        p_field   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_date
   **/
   PROCEDURE is_date(p_value   IN VARCHAR2,
                     p_msg     IN VARCHAR2 DEFAULT NULL,
                     p_mask    IN VARCHAR2 DEFAULT NULL,
                     p_field   IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_positive
   **/
   PROCEDURE is_positive(p_value1 IN NUMBER, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_negative
   **/
   PROCEDURE is_negative(p_value1 IN NUMBER, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_not_positive
   **/
   PROCEDURE is_not_positive(p_value1 IN NUMBER, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_not_negative
   **/
   PROCEDURE is_not_negative(p_value1 IN NUMBER, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_today
   **/
   PROCEDURE is_today(p_value1 IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_past
   **/
   PROCEDURE is_past(p_value1 IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_future
   **/
   PROCEDURE is_future(p_value1 IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_weekday
   **/
   PROCEDURE is_weekday(p_value1 IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL);

   /**
   *  PROCEDURE is_weekend
   **/
   PROCEDURE is_weekend(p_value1 IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL);
END assert;
/