CREATE OR REPLACE PACKAGE BODY text
AS
   /*
      ==============================================================================
      PL/SQL PACKAGE text

      String manipulation and constants.
      ------------------------------------------------------------------------------

      OPEN SOURCE ORACLE PL/SQL
      Version 0.6
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

   /**
   *  FUNCTION split
   *
   *  Split the provided string into a table of tokens with resp. to the delimiter.
   **/
   FUNCTION split(p_text IN VARCHAR2, p_delimiter IN VARCHAR2 DEFAULT ',')
      RETURN text_nt
   IS
      l_tokens       text_nt := text_nt();
      l_text         max_varchar_t := p_text;
      l_delim_pos    PLS_INTEGER;
      l_delim_size   PLS_INTEGER;
   BEGIN
      IF p_text IS NOT NULL
      THEN
         IF p_delimiter IS NULL
         THEN
            l_tokens.EXTEND;
            l_tokens(1) := p_text;
         ELSE
            l_delim_size := LENGTH(p_delimiter);
            l_text := p_text;

            LOOP
               l_delim_pos := INSTR(l_text, p_delimiter);

               IF l_delim_pos > 0
               THEN
                  l_tokens.EXTEND;
                  l_tokens(l_tokens.LAST) := SUBSTR(l_text, 1, l_delim_pos - 1);
                  l_text := SUBSTR(l_text, l_delim_pos + l_delim_size);
               ELSE
                  l_tokens.EXTEND;
                  l_tokens(l_tokens.LAST) := l_text;
                  EXIT;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN l_tokens;
   END split;

   /**
   *  FUNCTION join
   *
   *  Concatenate the tokens with the supplied delimiter. Note that NULL tokens
   *  are ignored by default. This is to comport with LISTAGG.
   **/
   FUNCTION join(p_tokens IN text_nt, p_delimiter IN VARCHAR2 DEFAULT ',', p_ignore_nulls IN flag_t DEFAULT 'Y')
      RETURN VARCHAR2
   IS
      l_text           max_varchar_t;
      l_ignore_nulls   BOOLEAN;
      l_procedural     BOOLEAN := FALSE;
      l_token          max_varchar_t;
      l_first_token    BOOLEAN := TRUE;
   BEGIN
      IF p_tokens.COUNT = 0
      THEN
         RETURN NULL;
      END IF;

      l_ignore_nulls := to_boolean(p_ignore_nulls, p_strict => TRUE);

      IF l_ignore_nulls
      THEN
         BEGIN
            SELECT LISTAGG(COLUMN_VALUE, p_delimiter) WITHIN GROUP (ORDER BY NULL) INTO l_text FROM TABLE(p_tokens);
         EXCEPTION
            WHEN concat_overflow
            THEN
               -- listagg() is limited to a varchar2(4000)
               -- but pl/sql is not
               l_procedural := TRUE;
         END;
      ELSE
         l_procedural := TRUE;
      END IF;

      IF l_procedural
      THEN
         FOR i IN 1 .. p_tokens.COUNT
         LOOP
            l_token := p_tokens(i);

            IF l_token IS NULL AND l_ignore_nulls
            THEN
               NULL;
            ELSIF l_first_token
            THEN
               l_text := l_token;
               l_first_token := FALSE;
            ELSE
               l_text := l_text || p_delimiter || p_tokens(i);
            END IF;
         END LOOP;
      END IF;

      RETURN l_text;
   END join;

   /**
   *  FUNCTION to_char
   **/
   FUNCTION TO_CHAR(p_boolean IN BOOLEAN)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN CASE WHEN p_boolean THEN 'TRUE' WHEN NOT p_boolean THEN 'FALSE' ELSE NULL END;
   END TO_CHAR;

   /**
   *  FUNCTION to_tf
   **/
   FUNCTION to_tf(p_boolean IN BOOLEAN)
      RETURN flag_t
   IS
   BEGIN
      RETURN CASE WHEN p_boolean THEN true_flag WHEN NOT p_boolean THEN false_flag ELSE NULL END;
   END to_tf;

   /**
   *  FUNCTION to_yn
   **/
   FUNCTION to_yn(p_boolean IN BOOLEAN)
      RETURN flag_t
   IS
   BEGIN
      RETURN CASE WHEN p_boolean THEN yes_flag WHEN NOT p_boolean THEN no_flag ELSE NULL END;
   END to_yn;

   /**
   *  FUNCTION to_boolean
   **/
   FUNCTION to_boolean(p_text IN VARCHAR2, p_strict IN BOOLEAN DEFAULT FALSE)
      RETURN BOOLEAN
   IS
      l_result   BOOLEAN;
   BEGIN
      l_result :=
         CASE
            WHEN UPPER(p_text) IN ('TRUE', true_flag, yes_flag) THEN TRUE
            WHEN UPPER(p_text) IN ('FALSE', false_flag, no_flag) THEN FALSE
            ELSE NULL
         END;

      IF p_strict
      THEN
         assert.is_not_null(l_result, 'The value [' || p_text || '] could not be converted to a boolean');
      END IF;

      RETURN l_result;
   END to_boolean;

   /**
   *  FUNCTION prefix
   **/
   FUNCTION prefix(p_text IN VARCHAR2, p_prefix_size IN PLS_INTEGER)
      RETURN VARCHAR2
   IS
   BEGIN
      IF p_text IS NULL OR p_prefix_size <= 0
      THEN
         RETURN NULL;
      END IF;

      RETURN SUBSTR(p_text, 1, p_prefix_size);
   END prefix;

   /**
   *  FUNCTION suffix
   **/
   FUNCTION suffix(p_text IN VARCHAR2, p_suffix_size IN PLS_INTEGER)
      RETURN VARCHAR2
   IS
   BEGIN
      IF p_text IS NULL OR p_suffix_size <= 0
      THEN
         RETURN NULL;
      END IF;

      IF LENGTH(p_text) <= p_suffix_size
      THEN
         RETURN p_text;
      END IF;

      RETURN SUBSTR(p_text, LENGTH(p_text) + 1 - p_suffix_size);
   END suffix;

   /**
   *  FUNCTION mask
   **/
   FUNCTION mask(p_text          IN VARCHAR2,
                 p_mask_char     IN VARCHAR2 DEFAULT '*',
                 p_prefix_size   IN PLS_INTEGER DEFAULT 0,
                 p_suffix_size   IN PLS_INTEGER DEFAULT 0)
      RETURN VARCHAR2
   IS
      l_len           PLS_INTEGER := LENGTH(p_text);
      l_prefix_size   PLS_INTEGER;
      l_suffix_size   PLS_INTEGER;
      l_result        max_varchar_t;
   BEGIN
      IF p_text IS NULL
      THEN
         RETURN NULL;
      END IF;

      assert.length_equals(p_mask_char, 1, p_field => 'p_mask_char');
      assert.is_not_negative(p_prefix_size, p_field1 => 'p_prefix_size');
      assert.is_not_negative(p_suffix_size, p_field1 => 'p_suffix_size');

      IF LENGTH(p_text) <= (p_prefix_size + p_suffix_size)
      THEN
         -- no masking needed
         RETURN p_text;
      END IF;

      -- ensure we're working with rational values
      l_prefix_size := LEAST(p_prefix_size, l_len);
      l_suffix_size := LEAST(p_suffix_size, l_len - l_prefix_size);

      IF l_prefix_size > 0
      THEN
         l_result := prefix(p_text, l_prefix_size);
      END IF;

      IF l_len > (l_prefix_size + l_suffix_size)
      THEN
         l_result := l_result || RPAD(p_mask_char, l_len - (l_prefix_size + l_suffix_size), p_mask_char);
      END IF;

      IF l_suffix_size > 0
      THEN
         l_result := l_result || suffix(p_text, l_suffix_size);
      END IF;

      RETURN l_result;
   END mask;

   /*
   *  As noted in the package spec, utl_match.edit_distance() should be used in
   *  lieu of Barbara Boehmer's work: ld() and mdld(). It is retained below in
   *  admiration of the work itself.
   */

   -- Levenshtein distance
   FUNCTION ld(p_source_string IN VARCHAR2, p_target_string IN VARCHAR2)
      RETURN NUMBER
   AS
      v_length_of_source      NUMBER := NVL(LENGTH(p_source_string), 0);
      v_length_of_target      NUMBER := NVL(LENGTH(p_target_string), 0);
      v_distance              NUMBER;

      TYPE mytabtype IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      first_row               mytabtype;
      column_to_left          mytabtype;
      current_column          mytabtype;
      v_cost                  NUMBER := 0;
      v_cell_above            NUMBER := 0;
      v_cell_above_and_left   NUMBER := 0;
   BEGIN
      IF v_length_of_source = 0
      THEN
         v_distance := v_length_of_target;
      ELSIF v_length_of_target = 0
      THEN
         v_distance := v_length_of_source;
      ELSE
         FOR i IN 1 .. v_length_of_source
         LOOP
            first_row(i) := i;
         END LOOP;

         FOR j IN 1 .. v_length_of_target
         LOOP
            current_column(j) := j;
         END LOOP;

         FOR i IN 1 .. v_length_of_source
         LOOP
            FOR j IN 1 .. v_length_of_target
            LOOP
               column_to_left(j) := current_column(j);
            END LOOP;

            FOR j IN 1 .. v_length_of_target
            LOOP
               IF SUBSTR(p_source_string, i, 1) = SUBSTR(p_target_string, j, 1)
               THEN
                  v_cost := 0;
               ELSE
                  v_cost := 1;
               END IF;

               IF j = 1
               THEN
                  v_cell_above := first_row(i);
               ELSE
                  v_cell_above := current_column(j - 1);
               END IF;

               IF i = 1 AND j = 1
               THEN
                  v_cell_above_and_left := 0;
               ELSIF j = 1
               THEN
                  v_cell_above_and_left := first_row(i - 1);
               ELSE
                  v_cell_above_and_left := column_to_left(j - 1);
               END IF;

               current_column(j) := LEAST(v_cell_above + 1, column_to_left(j) + 1, v_cell_above_and_left + v_cost);

               v_distance := current_column(j);
            END LOOP;
         END LOOP;
      END IF;

      RETURN v_distance;
   END ld;

   -------------------------------------------------------------
   -- Function: mdld
   -- Purpose: Perform Modified Damerau-Levenshtein Distance test on two input strings, supporting block
   --   transpositions of multiple characters
   -- Author: Barbara Boehmer and Tony Rees (baboehme@hotmail.com, Tony.Rees@csiro.au)
   -- Date created: March 2008
   -- Inputs: string 1 as p_str1, string 2 as p_str2, numeric limit on length of transposed block to be
   --   searched for as p_block_limit
   -- Outputs: computed edit distance between the input strings (0=identical on this measure, 1..n=increasing
   --   dissimilarity)
   -- Remarks:
   --   (1) Block limit must be 1 or greater. If set to 1, functions as standard Damerau-Levenshtein
   --     Distance (DLD) test; for MDLD, setting block limit to a moderately low value (e.g. 3) will
   --     avoid excessive run times
   --   (2) extension of B. Boehmer's original (2002) PL/SQL Levenshtein Distance function, available at
   --     http://www.merriampark.com/ldplsql.htm.
   -------------------------------------------------------------
   FUNCTION mdld(p_str1 VARCHAR2 DEFAULT NULL, p_str2 VARCHAR2 DEFAULT NULL, p_block_limit NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      v_str1_length         PLS_INTEGER := NVL(LENGTH(p_str1), 0);
      v_str2_length         PLS_INTEGER := NVL(LENGTH(p_str2), 0);
      v_temp_str1           VARCHAR2(32767);
      v_temp_str2           VARCHAR2(32767);

      TYPE mytabtype IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      TYPE myarray IS TABLE OF mytabtype
         INDEX BY BINARY_INTEGER;

      v_my_columns          myarray;
      v_empty_column        mytabtype;
      v_this_cost           PLS_INTEGER := 0;
      v_temp_block_length   PLS_INTEGER;
   BEGIN
      IF p_str2 = p_str1
      THEN
         RETURN 0;
      ELSIF v_str1_length = 0 OR v_str2_length = 0
      THEN
         RETURN GREATEST(v_str1_length, v_str2_length);
      ELSIF v_str1_length = 1 AND v_str2_length = 1 AND p_str2 != p_str1
      THEN
         RETURN 1;
      ELSE
         v_temp_str1 := p_str1;
         v_temp_str2 := p_str2;

         -- first trim common leading characters
         WHILE SUBSTR(v_temp_str1, 1, 1) = SUBSTR(v_temp_str2, 1, 1)
         LOOP
            v_temp_str1 := SUBSTR(v_temp_str1, 2);
            v_temp_str2 := SUBSTR(v_temp_str2, 2);
         END LOOP;

         -- then trim common trailing characters
         WHILE SUBSTR(v_temp_str1, -1, 1) = SUBSTR(v_temp_str2, -1, 1)
         LOOP
            v_temp_str1 := SUBSTR(v_temp_str1, 1, LENGTH(v_temp_str1) - 1);
            v_temp_str2 := SUBSTR(v_temp_str2, 1, LENGTH(v_temp_str2) - 1);
         END LOOP;

         v_str1_length := NVL(LENGTH(v_temp_str1), 0);
         v_str2_length := NVL(LENGTH(v_temp_str2), 0);

         -- then calculate standard Levenshtein Distance
         IF v_str1_length = 0 OR v_str2_length = 0
         THEN
            RETURN GREATEST(v_str1_length, v_str2_length);
         ELSIF v_str1_length = 1 AND v_str2_length = 1 AND p_str2 != p_str1
         THEN
            RETURN 1;
         ELSE
            -- create columns
            FOR s IN 0 .. v_str1_length
            LOOP
               v_my_columns(s) := v_empty_column;
            END LOOP;

            -- enter values in first (leftmost) column
            FOR t IN 0 .. v_str2_length
            LOOP
               v_my_columns(0)(t) := t;
            END LOOP;

            -- populate remaining columns
            FOR s IN 1 .. v_str1_length
            LOOP
               v_my_columns(s)(0) := s;

               -- populate each cell of one column:
               FOR t IN 1 .. v_str2_length
               LOOP
                  -- calculate cost
                  IF SUBSTR(v_temp_str1, s, 1) = SUBSTR(v_temp_str2, t, 1)
                  THEN
                     v_this_cost := 0;
                  ELSE
                     v_this_cost := 1;
                  END IF;

                  -- extension to cover multiple single, double, triple, etc character transpositions
                  -- that includes caculation of original Levenshtein distance when no transposition found
                  v_temp_block_length := LEAST((v_str1_length / 2), (v_str2_length / 2), NVL(p_block_limit, 1));

                  WHILE v_temp_block_length >= 1
                  LOOP
                     IF     s >= (v_temp_block_length * 2)
                        AND t >= (v_temp_block_length * 2)
                        AND SUBSTR(v_temp_str1, s - ((v_temp_block_length * 2) - 1), v_temp_block_length) =
                               SUBSTR(v_temp_str2, t - (v_temp_block_length - 1), v_temp_block_length)
                        AND SUBSTR(v_temp_str1, s - (v_temp_block_length - 1), v_temp_block_length) =
                               SUBSTR(v_temp_str2, t - ((v_temp_block_length * 2) - 1), v_temp_block_length)
                     THEN
                        -- transposition found
                        v_my_columns(s)(t) :=
                           LEAST(
                              v_my_columns(s)(t - 1) + 1,
                              v_my_columns(s - 1)(t) + 1,
                              (  v_my_columns(s - (v_temp_block_length * 2))(t - (v_temp_block_length * 2))
                               + v_this_cost
                               + (v_temp_block_length - 1)));
                        v_temp_block_length := 0;
                     ELSIF v_temp_block_length = 1
                     THEN
                        -- no transposition
                        v_my_columns(s)(t) :=
                           LEAST(v_my_columns(s)(t - 1) + 1, v_my_columns(s - 1)(t) + 1, v_my_columns(s - 1)(t - 1) + v_this_cost);
                     END IF;

                     v_temp_block_length := v_temp_block_length - 1;
                  END LOOP;
               END LOOP;
            END LOOP;
         END IF;

         RETURN v_my_columns(v_str1_length)(v_str2_length);
      END IF;
   END mdld;
END text;
/