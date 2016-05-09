CREATE OR REPLACE PACKAGE BODY numbers
AS
   /*
      ==============================================================================
      PL/SQL PACKAGE numbers

      Numeric manipulation and constants. No math.
      ------------------------------------------------------------------------------

      OPEN SOURCE ORACLE PL/SQL
      Version 0.5
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
   /*
   *  FUNCTION int_table
   *
   *  Create a static int_nt
   */
   FUNCTION int_table(p_start IN INTEGER, p_end IN INTEGER)
      RETURN int_nt
      DETERMINISTIC
   IS
      l_tbl   int_nt;
   BEGIN
      l_tbl := int_nt();

      FOR i IN p_start .. p_end
      LOOP
         l_tbl.EXTEND();
         l_tbl(l_tbl.COUNT) := i;
      END LOOP;

      RETURN l_tbl;
   END int_table;

   /*
   *  FUNCTION int_stream
   *
   *  Stream a pipelined int_nt
   */
   FUNCTION int_stream(p_start IN INTEGER, p_end IN INTEGER)
      RETURN int_nt
      DETERMINISTIC
      PIPELINED
   IS
   BEGIN
      FOR i IN p_start .. p_end
      LOOP
         PIPE ROW (i);
      END LOOP;

      RETURN;
   END int_stream;

   /*
   *  FUNCTION int_cur
   *
   *  Open a cursor of integers.
   *
   *  dev note: this is faster than querying dual w/connect-by,
   *  and faster than model clause iteration
   *  Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production
   */
   FUNCTION int_cur(p_start IN INTEGER, p_end IN INTEGER)
      RETURN SYS_REFCURSOR
      DETERMINISTIC
   IS
      l_cur   SYS_REFCURSOR;
   BEGIN
      OPEN l_cur FOR SELECT * FROM TABLE(int_stream(p_start, p_end));

      RETURN l_cur;
   END int_cur;

   /*
   *  FUNCTION decimal_to_hex
   */
   FUNCTION decimal_to_hex(p_number IN PLS_INTEGER)
      RETURN VARCHAR2
   IS
      l_hex_digits    PLS_INTEGER;
      l_format_mask   VARCHAR2(80 CHAR);
   BEGIN
      IF p_number IS NULL
      THEN
         RETURN NULL;
      ELSIF p_number = 0
      THEN
         RETURN '0';
      END IF;

      l_hex_digits := CEIL(LOG(16, ABS(p_number) + 1));
      l_format_mask := 'FM' || RPAD('X', l_hex_digits, 'X');

      RETURN CASE WHEN p_number < 0 THEN '-' END || TO_CHAR(ABS(p_number), l_format_mask);
   END decimal_to_hex;

   /*
   *  FUNCTION hex_to_decimal
   */
   FUNCTION hex_to_decimal(p_hex IN VARCHAR2)
      RETURN PLS_INTEGER
   IS
      l_sign          PLS_INTEGER := 1;
      l_hex           VARCHAR2(80 CHAR);
      l_format_mask   VARCHAR2(80 CHAR);
   BEGIN
      IF p_hex IS NULL
      THEN
         RETURN NULL;
      END IF;

      l_hex := TRIM(p_hex);

      IF l_hex LIKE '-%'
      THEN
         l_sign := -1;
         l_hex := SUBSTR(l_hex, 2);
      END IF;

      l_format_mask := 'FM' || RPAD('X', LENGTH(l_hex), 'X');

      RETURN l_sign * TO_NUMBER(l_hex, l_format_mask);
   END hex_to_decimal;
END numbers;
/