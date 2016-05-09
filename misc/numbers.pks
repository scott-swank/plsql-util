CREATE OR REPLACE PACKAGE numbers
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

   min_number           CONSTANT NUMBER := -9.9999999999999999999999999999999999999e+125;
   max_number           CONSTANT NUMBER := 9.9999999999999999999999999999999999999e+125;
   smallest_number      CONSTANT NUMBER := 1e-127;

   min_binary_integer   CONSTANT PLS_INTEGER := -2147483648;
   max_binary_integer   CONSTANT PLS_INTEGER := 2147483647;

   pi                   CONSTANT NUMBER := 2 * ASIN(1);
   degrees_per_radian   CONSTANT NUMBER := 180 / pi;
   e                    CONSTANT NUMBER := EXP(1);

   /*
   *  FUNCTION int_table
   *
   *  Create a static int_nt
   */
   FUNCTION int_table(p_start IN INTEGER, p_end IN INTEGER)
      RETURN int_nt
      DETERMINISTIC;

   /*
   *  FUNCTION int_stream
   *
   *  Stream a pipelined int_nt
   */
   FUNCTION int_stream(p_start IN INTEGER, p_end IN INTEGER)
      RETURN int_nt
      DETERMINISTIC
      PIPELINED;

   /*
   *  FUNCTION int_cur
   *
   *  Open a cursor of integers.
   */
   FUNCTION int_cur(p_start IN INTEGER, p_end IN INTEGER)
      RETURN SYS_REFCURSOR
      DETERMINISTIC;

   /*
   *  FUNCTION decimal_to_hex
   */
   FUNCTION decimal_to_hex(p_number IN PLS_INTEGER)
      RETURN VARCHAR2;

   /*
   *  FUNCTION hex_to_decimal
   */
   FUNCTION hex_to_decimal(p_hex IN VARCHAR2)
      RETURN PLS_INTEGER;
END numbers;
/