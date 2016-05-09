CREATE OR REPLACE PACKAGE BODY assert
AS
   /*
      ==============================================================================
      PL/SQL PACKAGE assert

      The package ASSERT is an argument validation library.

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
   SUBTYPE msg_t IS VARCHAR2(800 CHAR);

   --
   --  Error messages that are used across multiple APIs.
   --
   k_equals_error               CONSTANT msg_t := 'Expected [VALUE1] = [VALUE2]';
   k_equals_ns_error            CONSTANT msg_t := 'Expected [VALUE1] = [VALUE2] or both are null.';
   k_not_equal_error            CONSTANT msg_t := 'Expected [VALUE1] != [VALUE2]';
   k_not_equal_ns_error         CONSTANT msg_t := 'Expected [VALUE1] != [VALUE2] or exactly one null.';
   k_in_list_error              CONSTANT msg_t := 'Value [VALUE1] is not in list of elements: [VALUE2], [VALUE3], ...';
   k_not_in_list_error          CONSTANT msg_t := 'Value [VALUE1] found in list of elements: [VALUE2], [VALUE3], ...';
   k_less_than_error            CONSTANT msg_t := 'Expected [VALUE1] < [VALUE2]';
   k_less_than_equal_error      CONSTANT msg_t := 'Expected [VALUE1] <= [VALUE2]';
   k_greater_than_error         CONSTANT msg_t := 'Expected [VALUE1] > [VALUE2]';
   k_greater_than_equal_error   CONSTANT msg_t := 'Expected [VALUE1] >= [VALUE2]';
   k_between_error              CONSTANT msg_t := 'Expected [VALUE1] to be between [VALUE2] and [VALUE3].';

   /**
   *  FUNCTION extract_msg
   *
   *  Extract the error message text, i.e. without ORA-12345 prefix
   **/
   FUNCTION extract_msg(p_sqlerrm IN VARCHAR2, p_sqlcode IN PLS_INTEGER DEFAULT illegal_argument_code)
      RETURN VARCHAR2
   IS
      l_msg   VARCHAR2(4000 CHAR) := p_sqlerrm;
   BEGIN
      IF l_msg LIKE 'ORA-%: %'
      THEN
         -- The error prefix "ORA-12345: " is 11 chars, so we keep 12 onward
         l_msg := SUBSTR(l_msg, 12);
      END IF;

      RETURN l_msg;
   END extract_msg;

   /**
   *  FUNCTION format_msg
   *
   *  Construct the error message with respect to the provided field/value pairs.
   **/
   FUNCTION format_msg(p_msg      IN VARCHAR2,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_value1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL,
                       p_value2   IN VARCHAR2 DEFAULT NULL,
                       p_field3   IN VARCHAR2 DEFAULT NULL,
                       p_value3   IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      l_msg   msg_t := p_msg;
   BEGIN
      l_msg := REPLACE(l_msg, field1_token, NVL(p_field1, 'Field1'));
      l_msg := REPLACE(l_msg, value1_token, NVL(p_value1, 'NULL'));

      l_msg := REPLACE(l_msg, field2_token, NVL(p_field2, 'Field2'));
      l_msg := REPLACE(l_msg, value2_token, NVL(p_value2, 'NULL'));

      l_msg := REPLACE(l_msg, field3_token, NVL(p_field3, 'Field3'));
      l_msg := REPLACE(l_msg, value3_token, NVL(p_value3, 'NULL'));

      RETURN l_msg;
   END format_msg;

   /**
   *  PROCEDURE raise_error
   *
   *  Raise an illegal_argument exception for a pair of values and fields.
   **/
   PROCEDURE raise_error(p_msg      IN VARCHAR2 DEFAULT 'Illegal Argument(s)',
                         p_field1   IN VARCHAR2 DEFAULT NULL,
                         p_value1   IN VARCHAR2 DEFAULT NULL,
                         p_field2   IN VARCHAR2 DEFAULT NULL,
                         p_value2   IN VARCHAR2 DEFAULT NULL,
                         p_field3   IN VARCHAR2 DEFAULT NULL,
                         p_value3   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      raise_application_error(illegal_argument_code,
                              format_msg(p_msg      => p_msg,
                                         p_field1   => p_field1,
                                         p_value1   => p_value1,
                                         p_field2   => p_field2,
                                         p_value2   => p_value2,
                                         p_field3   => p_field3,
                                         p_value3   => p_value3));
   END raise_error;

   FUNCTION bool2char(p_bool IN BOOLEAN)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN CASE WHEN p_bool THEN 'TRUE' WHEN NOT p_bool THEN 'FALSE' ELSE 'NULL' END;
   END bool2char;

   FUNCTION date2char(p_date IN DATE)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN TO_CHAR(p_date, 'yyyy-mm-dd hh24:mi:ss');
   END date2char;

   /**
   *  PROCEDURE fail
   **/
   PROCEDURE fail(p_msg IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      raise_application_error(test_failure_code, NVL(p_msg, 'Intentional failure triggered.'));
   END fail;

   /**
   *  PROCEDURE is_true
   **/
   PROCEDURE is_true(p_condition IN BOOLEAN, p_msg IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- n.b. the ELSE clause handles null values
      IF p_condition
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, 'Expected TRUE result, got [VALUE1]'),
                     p_field1   => 'Condition',
                     p_value1   => bool2char(p_condition));
      END IF;
   END is_true;

   /**
   *  PROCEDURE is_false
   **/
   PROCEDURE is_false(p_condition IN BOOLEAN, p_msg IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- n.b. the ELSE clause handles null values
      IF NOT p_condition
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, 'Expected FALSE result, got [VALUE1]'),
                     p_field1   => 'Condition',
                     p_value1   => bool2char(p_condition));
      END IF;
   END is_false;

   /**
   *  PROCEDURE is_null
   **/
   PROCEDURE is_null(p_value IN VARCHAR2, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value IS NOT NULL
      THEN
         raise_error(p_msg => NVL(p_msg, '[FIELD1] must be null, but has value [VALUE1].'), p_field1 => p_field, p_value1 => p_value);
      END IF;
   END is_null;

   /**
   *  PROCEDURE is_null
   **/
   PROCEDURE is_null(p_value IN NUMBER, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      is_null(TO_CHAR(p_value), p_msg, p_field);
   END is_null;

   /**
   *  PROCEDURE is_null
   **/
   PROCEDURE is_null(p_value IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      is_null(date2char(p_value), p_msg, p_field);
   END is_null;

   /**
   *  PROCEDURE is_null
   **/
   PROCEDURE is_null(p_value IN BOOLEAN, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      is_null(CASE WHEN p_value IS NULL THEN NULL ELSE 'x' END, p_msg, p_field);
   END is_null;

   /**
   *  PROCEDURE is_not_null
   **/
   PROCEDURE is_not_null(p_value IN VARCHAR2, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value IS NULL
      THEN
         raise_error(p_msg => NVL(p_msg, field1_token || ' must not be null.'), p_field1 => p_field, p_value1 => p_value);
      END IF;
   END is_not_null;

   /**
   *  PROCEDURE is_not_null
   **/
   PROCEDURE is_not_null(p_value IN NUMBER, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      is_not_null(TO_CHAR(p_value), p_msg, p_field);
   END is_not_null;

   /**
   *  PROCEDURE is_not_null
   **/
   PROCEDURE is_not_null(p_value IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      is_not_null(date2char(p_value), p_msg, p_field);
   END is_not_null;

   /**
   *  PROCEDURE is_not_null
   **/
   PROCEDURE is_not_null(p_value IN BOOLEAN, p_msg IN VARCHAR2 DEFAULT NULL, p_field IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      is_not_null(CASE WHEN p_value THEN 'TRUE' WHEN NOT p_value THEN 'FALSE' ELSE NULL END, p_msg, p_field);
   END is_not_null;

   /**
   *  PROCEDURE equals
   **/
   PROCEDURE equals(p_value1   IN VARCHAR2,
                    p_value2   IN VARCHAR2,
                    p_msg      IN VARCHAR2 DEFAULT NULL,
                    p_field1   IN VARCHAR2 DEFAULT NULL,
                    p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- n.b. the ELSE clause handles null values
      IF p_value1 = p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_equals_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END equals;

   /**
   *  PROCEDURE equals_ignore_case
   **/
   PROCEDURE equals_ignore_case(p_value1   IN VARCHAR2,
                                p_value2   IN VARCHAR2,
                                p_msg      IN VARCHAR2 DEFAULT NULL,
                                p_field1   IN VARCHAR2 DEFAULT NULL,
                                p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      equals(p_value1   => UPPER(p_value1),
             p_value2   => UPPER(p_value2),
             p_msg      => p_msg,
             p_field1   => p_field1,
             p_field2   => p_field2);
   END equals_ignore_case;

   /**
   *  PROCEDURE matches
   **/
   PROCEDURE matches(p_value1              IN VARCHAR2,
                     p_value2              IN VARCHAR2,
                     p_levenshtein_delta   IN PLS_INTEGER,
                     p_msg                 IN VARCHAR2 DEFAULT NULL,
                     p_field1              IN VARCHAR2 DEFAULT NULL,
                     p_field2              IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- n.b. the ELSE clause handles null values
      IF p_value1 = p_value2 OR UTL_MATCH.edit_distance(p_value1, p_value2) <= p_levenshtein_delta
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_equals_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END matches;

   /**
   *  PROCEDURE matches
   **/
   PROCEDURE matches(p_value1               IN VARCHAR2,
                     p_value2               IN VARCHAR2,
                     p_jaro_winkler_delta   IN NUMBER,
                     p_msg                  IN VARCHAR2 DEFAULT NULL,
                     p_field1               IN VARCHAR2 DEFAULT NULL,
                     p_field2               IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- n.b. the ELSE clause handles null values
      IF p_value1 = p_value2 OR UTL_MATCH.jaro_winkler(p_value1, p_value2) <= p_jaro_winkler_delta
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_equals_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END matches;

   /**
   *  PROCEDURE matches_soundex
   **/
   PROCEDURE matches_soundex(p_value1   IN VARCHAR2,
                             p_value2   IN VARCHAR2,
                             p_msg      IN VARCHAR2 DEFAULT NULL,
                             p_field1   IN VARCHAR2 DEFAULT NULL,
                             p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- n.b. the ELSE clause handles null values
      IF SOUNDEX(p_value1) = SOUNDEX(p_value2)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_equals_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END matches_soundex;

   /**
   *  PROCEDURE equals
   **/
   PROCEDURE equals(p_value1   IN NUMBER,
                    p_value2   IN NUMBER,
                    p_msg      IN VARCHAR2 DEFAULT NULL,
                    p_field1   IN VARCHAR2 DEFAULT NULL,
                    p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- compare numbers to numbers
      -- then delegate failure to the varchar2 version
      -- n.b. the ELSE clause handles null values
      IF p_value1 = p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_equals_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END equals;

   /**
   *  PROCEDURE equals
   **/
   PROCEDURE equals(p_value1   IN NUMBER,
                    p_value2   IN NUMBER,
                    p_delta    IN NUMBER,
                    p_msg      IN VARCHAR2 DEFAULT NULL,
                    p_field1   IN VARCHAR2 DEFAULT NULL,
                    p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- n.b. the ELSE clause handles null values
      IF ABS(p_value1 - p_value2) <= NVL(p_delta, 0)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_equals_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END equals;

   /**
   *  PROCEDURE equals
   **/
   PROCEDURE equals(p_value1   IN DATE,
                    p_value2   IN DATE,
                    p_msg      IN VARCHAR2 DEFAULT NULL,
                    p_field1   IN VARCHAR2 DEFAULT NULL,
                    p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- n.b. the ELSE clause handles null values
      IF p_value1 = p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_equals_error),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1),
                     p_field2   => p_field2,
                     p_value2   => date2char(p_value2));
      END IF;
   END equals;

   /**
   *  PROCEDURE equals
   **/
   PROCEDURE equals(p_value1   IN DATE,
                    p_value2   IN DATE,
                    p_delta    IN NUMBER,
                    p_msg      IN VARCHAR2 DEFAULT NULL,
                    p_field1   IN VARCHAR2 DEFAULT NULL,
                    p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- n.b. the ELSE clause handles null values
      IF ABS(p_value1 - p_value2) <= NVL(p_delta, 0)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_equals_error),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1),
                     p_field2   => p_field2,
                     p_value2   => date2char(p_value2));
      END IF;
   END equals;

   /**
   *  PROCEDURE equals_ns
   **/
   PROCEDURE equals_ns(p_value1   IN VARCHAR2,
                       p_value2   IN VARCHAR2,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- n.b. the ELSE clause handles null values
      IF p_value1 = p_value2 OR (p_value1 IS NULL AND p_value2 IS NULL)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_equals_ns_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END equals_ns;

   /**
   *  PROCEDURE equals_ns
   **/
   PROCEDURE equals_ns(p_value1   IN NUMBER,
                       p_value2   IN NUMBER,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- compare numbers to numbers
      -- then delegate failure to the varchar2 version
      -- n.b. the ELSE clause handles null values
      IF p_value1 = p_value2 OR (p_value1 IS NULL AND p_value2 IS NULL)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_equals_ns_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END equals_ns;

   /**
   *  PROCEDURE equals_ns
   **/
   PROCEDURE equals_ns(p_value1   IN DATE,
                       p_value2   IN DATE,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- compare dates to dates
      -- then delegate failure to the varchar2 version
      -- n.b. the ELSE clause handles null values
      IF p_value1 = p_value2 OR (p_value1 IS NULL AND p_value2 IS NULL)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_equals_ns_error),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1),
                     p_field2   => p_field2,
                     p_value2   => date2char(p_value2));
      END IF;
   END equals_ns;

   /**
   *  PROCEDURE not_equal
   **/
   PROCEDURE not_equal(p_value1   IN VARCHAR2,
                       p_value2   IN VARCHAR2,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
      l_msg   msg_t;
   BEGIN
      -- n.b. the ELSE clause handles null values
      IF p_value1 != p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_not_equal_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END not_equal;

   /**
   *  PROCEDURE not_equal
   **/
   PROCEDURE not_equal(p_value1   IN NUMBER,
                       p_value2   IN NUMBER,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- compare numbers to numbers
      -- then delegate failure to the varchar2 version
      -- n.b. the ELSE clause handles null values
      IF p_value1 != p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_not_equal_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END not_equal;

   /**
   *  PROCEDURE not_equal
   **/
   PROCEDURE not_equal(p_value1   IN DATE,
                       p_value2   IN DATE,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- compare numbers to numbers
      -- then delegate failure to the varchar2 version
      -- n.b. the ELSE clause handles null values
      IF p_value1 != p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_not_equal_error),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1),
                     p_field2   => p_field2,
                     p_value2   => date2char(p_value2));
      END IF;
   END not_equal;

   /**
   *  PROCEDURE not_equal_ns
   *
   *  This null-safe variant accepts non-matching values, including NULL.
   **/
   PROCEDURE not_equal_ns(p_value1   IN VARCHAR2,
                          p_value2   IN VARCHAR2,
                          p_msg      IN VARCHAR2 DEFAULT NULL,
                          p_field1   IN VARCHAR2 DEFAULT NULL,
                          p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF (p_value1 = p_value2) OR (p_value1 IS NULL AND p_value2 IS NOT NULL) OR (p_value1 IS NOT NULL AND p_value2 IS NULL)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_not_equal_ns_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END not_equal_ns;

   /**
   *  PROCEDURE not_equal_ns
   *
   *  This null-safe variant accepts non-matching values, including NULL.
   **/
   PROCEDURE not_equal_ns(p_value1   IN NUMBER,
                          p_value2   IN NUMBER,
                          p_msg      IN VARCHAR2 DEFAULT NULL,
                          p_field1   IN VARCHAR2 DEFAULT NULL,
                          p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF (p_value1 = p_value2) OR (p_value1 IS NULL AND p_value2 IS NOT NULL) OR (p_value1 IS NOT NULL AND p_value2 IS NULL)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_not_equal_ns_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END not_equal_ns;

   /**
   *  PROCEDURE not_equal_ns
   *
   *  This null-safe variant accepts non-matching values, including NULL.
   **/
   PROCEDURE not_equal_ns(p_value1   IN DATE,
                          p_value2   IN DATE,
                          p_msg      IN VARCHAR2 DEFAULT NULL,
                          p_field1   IN VARCHAR2 DEFAULT NULL,
                          p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF (p_value1 = p_value2) OR (p_value1 IS NULL AND p_value2 IS NOT NULL) OR (p_value1 IS NOT NULL AND p_value2 IS NULL)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_not_equal_ns_error),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1),
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END not_equal_ns;

   /**
   *  PROCEDURE in_list
   **/
   PROCEDURE in_list(p_value      IN VARCHAR2,
                     p_elements   IN text_nt,
                     p_msg        IN VARCHAR2 DEFAULT NULL,
                     p_field      IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value MEMBER OF p_elements
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_in_list_error),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_value2   => CASE WHEN p_elements.COUNT >= 1 THEN p_elements(1) END,
                     p_value3   => CASE WHEN p_elements.COUNT >= 2 THEN p_elements(2) END);
      END IF;
   END in_list;

   /**
   *  PROCEDURE in_list
   **/
   PROCEDURE in_list(p_value      IN NUMBER,
                     p_elements   IN number_nt,
                     p_msg        IN VARCHAR2 DEFAULT NULL,
                     p_field      IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value MEMBER OF p_elements
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_in_list_error),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_value2   => CASE WHEN p_elements.COUNT >= 1 THEN p_elements(1) END,
                     p_value3   => CASE WHEN p_elements.COUNT >= 2 THEN p_elements(2) END);
      END IF;
   END in_list;

   /**
   *  PROCEDURE in_list
   **/
   PROCEDURE in_list(p_value      IN DATE,
                     p_elements   IN date_nt,
                     p_msg        IN VARCHAR2 DEFAULT NULL,
                     p_field      IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value MEMBER OF p_elements
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_in_list_error),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_value2   => CASE WHEN p_elements.COUNT >= 1 THEN p_elements(1) END,
                     p_value3   => CASE WHEN p_elements.COUNT >= 2 THEN p_elements(2) END);
      END IF;
   END in_list;

   /**
   *  PROCEDURE not_in_list
   **/
   PROCEDURE not_in_list(p_value      IN VARCHAR2,
                         p_elements   IN text_nt,
                         p_msg        IN VARCHAR2 DEFAULT NULL,
                         p_field      IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value NOT MEMBER OF p_elements
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_not_in_list_error),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_value2   => CASE WHEN p_elements.COUNT >= 1 THEN p_elements(1) END,
                     p_value3   => CASE WHEN p_elements.COUNT >= 2 THEN p_elements(2) END);
      END IF;
   END not_in_list;

   /**
   *  PROCEDURE not_in_list
   **/
   PROCEDURE not_in_list(p_value      IN NUMBER,
                         p_elements   IN number_nt,
                         p_msg        IN VARCHAR2 DEFAULT NULL,
                         p_field      IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value NOT MEMBER OF p_elements
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_not_in_list_error),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_value2   => CASE WHEN p_elements.COUNT >= 1 THEN p_elements(1) END,
                     p_value3   => CASE WHEN p_elements.COUNT >= 2 THEN p_elements(2) END);
      END IF;
   END not_in_list;

   /**
   *  PROCEDURE not_in_list
   **/
   PROCEDURE not_in_list(p_value      IN DATE,
                         p_elements   IN date_nt,
                         p_msg        IN VARCHAR2 DEFAULT NULL,
                         p_field      IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value NOT MEMBER OF p_elements
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_not_in_list_error),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_value2   => CASE WHEN p_elements.COUNT >= 1 THEN p_elements(1) END,
                     p_value3   => CASE WHEN p_elements.COUNT >= 2 THEN p_elements(2) END);
      END IF;
   END not_in_list;

   /**
   *  PROCEDURE less_than
   **/
   PROCEDURE less_than(p_value1   IN VARCHAR2,
                       p_value2   IN VARCHAR2,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 < p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_less_than_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END less_than;

   /**
   *  PROCEDURE less_than
   **/
   PROCEDURE less_than(p_value1   IN NUMBER,
                       p_value2   IN NUMBER,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 < p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_less_than_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END less_than;

   /**
   *  PROCEDURE less_than
   **/
   PROCEDURE less_than(p_value1   IN DATE,
                       p_value2   IN DATE,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field1   IN VARCHAR2 DEFAULT NULL,
                       p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 < p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_less_than_error),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1),
                     p_field2   => p_field2,
                     p_value2   => date2char(p_value2));
      END IF;
   END less_than;

   /**
   *  PROCEDURE less_than_equal
   **/
   PROCEDURE less_than_equal(p_value1   IN VARCHAR2,
                             p_value2   IN VARCHAR2,
                             p_msg      IN VARCHAR2 DEFAULT NULL,
                             p_field1   IN VARCHAR2 DEFAULT NULL,
                             p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 <= p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_less_than_equal_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END less_than_equal;

   /**
   *  PROCEDURE less_than_equal
   **/
   PROCEDURE less_than_equal(p_value1   IN NUMBER,
                             p_value2   IN NUMBER,
                             p_msg      IN VARCHAR2 DEFAULT NULL,
                             p_field1   IN VARCHAR2 DEFAULT NULL,
                             p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 <= p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_less_than_equal_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END less_than_equal;

   /**
   *  PROCEDURE less_than_equal
   **/
   PROCEDURE less_than_equal(p_value1   IN DATE,
                             p_value2   IN DATE,
                             p_msg      IN VARCHAR2 DEFAULT NULL,
                             p_field1   IN VARCHAR2 DEFAULT NULL,
                             p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 <= p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_less_than_equal_error),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1),
                     p_field2   => p_field2,
                     p_value2   => date2char(p_value2));
      END IF;
   END less_than_equal;

   /**
   *  PROCEDURE greater_than
   **/
   PROCEDURE greater_than(p_value1   IN VARCHAR2,
                          p_value2   IN VARCHAR2,
                          p_msg      IN VARCHAR2 DEFAULT NULL,
                          p_field1   IN VARCHAR2 DEFAULT NULL,
                          p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 > p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_greater_than_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END greater_than;

   /**
   *  PROCEDURE greater_than
   **/
   PROCEDURE greater_than(p_value1   IN NUMBER,
                          p_value2   IN NUMBER,
                          p_msg      IN VARCHAR2 DEFAULT NULL,
                          p_field1   IN VARCHAR2 DEFAULT NULL,
                          p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 > p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_greater_than_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END greater_than;

   /**
   *  PROCEDURE greater_than
   **/
   PROCEDURE greater_than(p_value1   IN DATE,
                          p_value2   IN DATE,
                          p_msg      IN VARCHAR2 DEFAULT NULL,
                          p_field1   IN VARCHAR2 DEFAULT NULL,
                          p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 > p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_greater_than_error),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1),
                     p_field2   => p_field2,
                     p_value2   => date2char(p_value2));
      END IF;
   END greater_than;

   /**
   *  PROCEDURE greater_than_equal
   **/
   PROCEDURE greater_than_equal(p_value1   IN VARCHAR2,
                                p_value2   IN VARCHAR2,
                                p_msg      IN VARCHAR2 DEFAULT NULL,
                                p_field1   IN VARCHAR2 DEFAULT NULL,
                                p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 >= p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_greater_than_equal_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END greater_than_equal;

   /**
   *  PROCEDURE greater_than_equal
   **/
   PROCEDURE greater_than_equal(p_value1   IN NUMBER,
                                p_value2   IN NUMBER,
                                p_msg      IN VARCHAR2 DEFAULT NULL,
                                p_field1   IN VARCHAR2 DEFAULT NULL,
                                p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 >= p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_greater_than_equal_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_value2);
      END IF;
   END greater_than_equal;

   /**
   *  PROCEDURE greater_than_equal
   **/
   PROCEDURE greater_than_equal(p_value1   IN DATE,
                                p_value2   IN DATE,
                                p_msg      IN VARCHAR2 DEFAULT NULL,
                                p_field1   IN VARCHAR2 DEFAULT NULL,
                                p_field2   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 >= p_value2
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_greater_than_equal_error),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1),
                     p_field2   => p_field2,
                     p_value2   => date2char(p_value2));
      END IF;
   END greater_than_equal;

   /**
   *  PROCEDURE is_between
   **/
   PROCEDURE is_between(p_value1        IN VARCHAR2,
                        p_lower_bound   IN VARCHAR2,
                        p_upper_bound   IN VARCHAR2,
                        p_msg           IN VARCHAR2 DEFAULT NULL,
                        p_field1        IN VARCHAR2 DEFAULT NULL,
                        p_field2        IN VARCHAR2 DEFAULT NULL,
                        p_field3        IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF (p_value1 BETWEEN p_lower_bound AND p_upper_bound)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_between_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_lower_bound,
                     p_field3   => p_field3,
                     p_value3   => p_upper_bound);
      END IF;
   END is_between;

   /**
   *  PROCEDURE is_between
   **/
   PROCEDURE is_between(p_value1        IN NUMBER,
                        p_lower_bound   IN NUMBER,
                        p_upper_bound   IN NUMBER,
                        p_msg           IN VARCHAR2 DEFAULT NULL,
                        p_field1        IN VARCHAR2 DEFAULT NULL,
                        p_field2        IN VARCHAR2 DEFAULT NULL,
                        p_field3        IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF (p_value1 BETWEEN p_lower_bound AND p_upper_bound)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_between_error),
                     p_field1   => p_field1,
                     p_value1   => p_value1,
                     p_field2   => p_field2,
                     p_value2   => p_lower_bound,
                     p_field3   => p_field3,
                     p_value3   => p_upper_bound);
      END IF;
   END is_between;

   /**
   *  PROCEDURE is_between
   **/
   PROCEDURE is_between(p_value1        IN DATE,
                        p_lower_bound   IN DATE,
                        p_upper_bound   IN DATE,
                        p_msg           IN VARCHAR2 DEFAULT NULL,
                        p_field1        IN VARCHAR2 DEFAULT NULL,
                        p_field2        IN VARCHAR2 DEFAULT NULL,
                        p_field3        IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF (p_value1 BETWEEN p_lower_bound AND p_upper_bound)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, k_between_error),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1),
                     p_field2   => p_field2,
                     p_value2   => date2char(p_lower_bound),
                     p_field3   => p_field3,
                     p_value3   => date2char(p_upper_bound));
      END IF;
   END is_between;

   /**
   *  PROCEDURE length_equals
   **/
   PROCEDURE length_equals(p_value    IN VARCHAR2,
                           p_length   IN PLS_INTEGER,
                           p_msg      IN VARCHAR2 DEFAULT NULL,
                           p_field    IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF NVL(LENGTH(p_value), 0) = p_length
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, 'The [FIELD1] [[VALUE1]] must be [VALUE2] characters.'),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_field2   => 'p_length',
                     p_value2   => p_length);
      END IF;
   END length_equals;

   /**
   *  PROCEDURE min_length
   **/
   PROCEDURE min_length(p_value        IN VARCHAR2,
                        p_min_length   IN PLS_INTEGER,
                        p_msg          IN VARCHAR2 DEFAULT NULL,
                        p_field        IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF NVL(LENGTH(p_value), 0) >= p_min_length
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, 'The [FIELD1] [[VALUE1]] must be at least [VALUE2] characters.'),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_field2   => 'p_min_length',
                     p_value2   => p_min_length);
      END IF;
   END min_length;

   /**
   *  PROCEDURE max_length
   **/
   PROCEDURE max_length(p_value        IN VARCHAR2,
                        p_max_length   IN PLS_INTEGER,
                        p_msg          IN VARCHAR2 DEFAULT NULL,
                        p_field        IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF NVL(LENGTH(p_value), 0) <= p_max_length
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, 'The [FIELD1] [[VALUE1]] must be no more than [VALUE2] characters.'),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_field2   => 'p_max_length',
                     p_value2   => p_max_length);
      END IF;
   END max_length;

   /**
   *  PROCEDURE length_between
   **/
   PROCEDURE length_between(p_value        IN VARCHAR2,
                            p_min_length   IN PLS_INTEGER,
                            p_max_length   IN PLS_INTEGER,
                            p_msg          IN VARCHAR2 DEFAULT NULL,
                            p_field        IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF NVL(LENGTH(p_value), 0) BETWEEN p_min_length AND p_max_length
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, 'The [FIELD1] [[VALUE1]] must be between [VALUE2] and [VALUE3] characters.'),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_field2   => 'p_min_length',
                     p_value2   => p_min_length,
                     p_field3   => 'p_max_length',
                     p_value3   => p_min_length);
      END IF;
   END length_between;

   /**
   *  PROCEDURE starts_with
   **/
   PROCEDURE starts_with(p_value    IN VARCHAR2,
                         p_prefix   IN VARCHAR2,
                         p_msg      IN VARCHAR2 DEFAULT NULL,
                         p_field    IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value LIKE p_prefix || '%'
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, 'The [FIELD1] [[VALUE1]] must begin with "[VALUE2]"'),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_field2   => 'p_prefix',
                     p_value2   => p_prefix);
      END IF;
   END starts_with;

   /**
   *  PROCEDURE ends_with
   **/
   PROCEDURE ends_with(p_value    IN VARCHAR2,
                       p_suffix   IN VARCHAR2,
                       p_msg      IN VARCHAR2 DEFAULT NULL,
                       p_field    IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value LIKE '%' || p_suffix
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, 'The [FIELD1] [[VALUE1]] must end with "[VALUE2]"'),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_field2   => 'p_suffix',
                     p_value2   => p_suffix);
      END IF;
   END ends_with;

   /**
   *  PROCEDURE contains
   **/
   PROCEDURE contains(p_value       IN VARCHAR2,
                      p_substring   IN VARCHAR2,
                      p_msg         IN VARCHAR2 DEFAULT NULL,
                      p_field       IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value LIKE '%' || p_substring || '%'
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, 'The [FIELD1] [[VALUE1]] must contain the substring "[VALUE2]"'),
                     p_field1   => p_field,
                     p_value1   => p_value,
                     p_field2   => 'p_substring',
                     p_value2   => p_substring);
      END IF;
   END contains;

   /**
   *  PROCEDURE is_numeric
   **/
   PROCEDURE is_numeric(p_value   IN VARCHAR2,
                        p_msg     IN VARCHAR2 DEFAULT NULL,
                        p_mask    IN VARCHAR2 DEFAULT NULL,
                        p_field   IN VARCHAR2 DEFAULT NULL)
   IS
      l_number   NUMBER;
   BEGIN
      IF p_mask IS NULL
      THEN
         l_number := TO_NUMBER(p_value);
      ELSE
         l_number := TO_NUMBER(p_value, p_mask);
      END IF;
   EXCEPTION
      WHEN INVALID_NUMBER
      THEN
         raise_error(p_msg => NVL(p_msg, 'Expected a number for [FIELD1], got [[VALUE1]]'), p_field1 => p_field, p_value1 => p_value);
      WHEN VALUE_ERROR
      THEN
         raise_error(p_msg => NVL(p_msg, 'Expected a number for [FIELD1], got [[VALUE1]]'), p_field1 => p_field, p_value1 => p_value);
   END is_numeric;

   /**
   *  PROCEDURE is_date
   **/
   PROCEDURE is_date(p_value   IN VARCHAR2,
                     p_msg     IN VARCHAR2 DEFAULT NULL,
                     p_mask    IN VARCHAR2 DEFAULT NULL,
                     p_field   IN VARCHAR2 DEFAULT NULL)
   IS
      l_date   DATE;
   BEGIN
      IF p_mask IS NULL
      THEN
         l_date := TO_DATE(p_value);
      ELSE
         l_date := TO_DATE(p_value, p_mask);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- there are many date conversion exceptions, we catch them all with WHEN OTHERS
         raise_error(p_msg => NVL(p_msg, 'Expected a date for [FIELD1], got [[VALUE1]]'), p_field1 => p_field, p_value1 => p_value);
   END is_date;

   /**
   *  PROCEDURE is_positive
   **/
   PROCEDURE is_positive(p_value1 IN NUMBER, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 > 0
      THEN
         NULL;
      ELSE
         raise_error(p_msg => NVL(p_msg, '[FIELD1] "[VALUE1]" must be positive'), p_field1 => p_field1, p_value1 => p_value1);
      END IF;
   END is_positive;

   /**
   *  PROCEDURE is_negative
   **/
   PROCEDURE is_negative(p_value1 IN NUMBER, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 < 0
      THEN
         NULL;
      ELSE
         raise_error(p_msg => NVL(p_msg, '[FIELD1] "[VALUE1]" must be negative'), p_field1 => p_field1, p_value1 => p_value1);
      END IF;
   END is_negative;

   /**
   *  PROCEDURE is_not_positive
   **/
   PROCEDURE is_not_positive(p_value1 IN NUMBER, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 <= 0
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, '[FIELD1] "[VALUE1]" must be less than or equal to zero.'),
                     p_field1   => p_field1,
                     p_value1   => p_value1);
      END IF;
   END is_not_positive;

   /**
   *  PROCEDURE is_not_negative
   **/
   PROCEDURE is_not_negative(p_value1 IN NUMBER, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 >= 0
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, '[FIELD1] "[VALUE1]" must be greater than or equal to zero.'),
                     p_field1   => p_field1,
                     p_value1   => p_value1);
      END IF;
   END is_not_negative;

   /**
   *  PROCEDURE is_today
   **/
   PROCEDURE is_today(p_value1 IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF TRUNC(p_value1) = TRUNC(SYSDATE)
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, '[FIELD1] "[VALUE1]" must be some time today.'),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1));
      END IF;
   END is_today;

   /**
   *  PROCEDURE is_past
   **/
   PROCEDURE is_past(p_value1 IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 < SYSDATE
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, '[FIELD1] "[VALUE1]" must be in the past.'),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1));
      END IF;
   END is_past;

   /**
   *  PROCEDURE is_future
   **/
   PROCEDURE is_future(p_value1 IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      IF p_value1 > SYSDATE
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, '[FIELD1] "[VALUE1]" must be in the future.'),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1));
      END IF;
   END is_future;

   /**
   *  PROCEDURE is_weekday
   **/
   PROCEDURE is_weekday(p_value1 IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- days since start of week less than 5: Mon, Tue, Wed, Thu, Fri
      IF TRUNC(p_value1) - TRUNC(p_value1, 'IW') < 5
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, '[FIELD1] "[VALUE1]" must be a weekday.'),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1));
      END IF;
   END is_weekday;

   /**
   *  PROCEDURE is_weekend
   **/
   PROCEDURE is_weekend(p_value1 IN DATE, p_msg IN VARCHAR2 DEFAULT NULL, p_field1 IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- days since start of week at least 5: Sat, Sun
      IF TRUNC(p_value1) - TRUNC(p_value1, 'IW') >= 5
      THEN
         NULL;
      ELSE
         raise_error(p_msg      => NVL(p_msg, '[FIELD1] "[VALUE1]" must be a weekend.'),
                     p_field1   => p_field1,
                     p_value1   => date2char(p_value1));
      END IF;
   END is_weekend;
END assert;
/