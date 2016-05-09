CREATE OR REPLACE PACKAGE dates
AS
   /*
      ==============================================================================
      PL/SQL PACKAGE dates

      Date manipulation and constants.
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
   seconds_per_day    CONSTANT PLS_INTEGER := 24 * 60 * 60;
   epoch_start_date   CONSTANT DATE := DATE '1970-01-01';
   epoch_start_ts     CONSTANT TIMESTAMP := TIMESTAMP '1970-01-01 00:00:00';

   /*
   *  FUNCTION date_table
   *
   *  Create a static date_nt. The entries begin with p_start.
   */
   FUNCTION date_table(p_start IN DATE, p_num_days IN PLS_INTEGER)
      RETURN date_nt
      DETERMINISTIC;

   /*
   *  FUNCTION date_table
   *
   *  Create a static date_nt. The entries begin with p_start, incrementing
   *  1 day per entry, not exceeding p_end.
   */
   FUNCTION date_table(p_start IN DATE, p_end IN DATE)
      RETURN date_nt
      DETERMINISTIC;

   /*
   *  FUNCTION date_stream
   *
   *  Stream a pipelined date_nt
   */
   FUNCTION date_stream(p_start IN DATE, p_num_days IN PLS_INTEGER)
      RETURN date_nt
      DETERMINISTIC
      PIPELINED;

   /*
   *  FUNCTION date_stream
   *
   *  Stream a pipelined date_nt
   */
   FUNCTION date_stream(p_start IN DATE, p_end IN DATE)
      RETURN date_nt
      DETERMINISTIC
      PIPELINED;

   /*
   *  FUNCTION date_cur
   *
   *  Open a cursor of integers.
   */
   FUNCTION date_cur(p_start IN DATE, p_num_days IN PLS_INTEGER)
      RETURN SYS_REFCURSOR
      DETERMINISTIC;

   /*
   *  FUNCTION date_cur
   *
   *  Open a cursor of integers.
   */
   FUNCTION date_cur(p_start IN DATE, p_end IN DATE)
      RETURN SYS_REFCURSOR
      DETERMINISTIC;

   /*
   *  FUNCTION days_in_month
   */
   FUNCTION days_in_month(p_date IN DATE)
      RETURN PLS_INTEGER;

   /*
   *  FUNCTION days_in_year
   */
   FUNCTION days_in_year(p_date IN DATE)
      RETURN PLS_INTEGER;

   /*
   *  FUNCTION is_weekday
   */
   FUNCTION is_weekday(p_date IN DATE)
      RETURN BOOLEAN;

   /*
   *  FUNCTION is_weekend
   */
   FUNCTION is_weekend(p_date IN DATE)
      RETURN BOOLEAN;
END dates;
/