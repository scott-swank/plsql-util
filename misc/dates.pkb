CREATE OR REPLACE PACKAGE BODY dates
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

   /*
   *  FUNCTION date_table
   *
   *  Create a static date_nt. The entries begin with p_start.
   */
   FUNCTION date_table(p_start IN DATE, p_num_days IN PLS_INTEGER)
      RETURN date_nt
      DETERMINISTIC
   IS
      l_dates   date_nt := date_nt();
   BEGIN
      FOR i IN 0 .. (p_num_days - 1)
      LOOP
         l_dates.EXTEND();
         l_dates(l_dates.COUNT) := p_start + i;
      END LOOP;

      RETURN l_dates;
   END date_table;

   /*
   *  FUNCTION date_table
   *
   *  Create a static date_nt. The entries begin with p_start, incrementing
   *  1 day per entry, not exceeding p_end.
   */
   FUNCTION date_table(p_start IN DATE, p_end IN DATE)
      RETURN date_nt
      DETERMINISTIC
   IS
      l_dates   date_nt := date_nt();
   BEGIN
      RETURN date_table(p_start, FLOOR(p_end - p_start) + 1);
   END date_table;

   /*
   *  FUNCTION date_stream
   *
   *  Stream a pipelined date_nt
   */
   FUNCTION date_stream(p_start IN DATE, p_num_days IN PLS_INTEGER)
      RETURN date_nt
      DETERMINISTIC
      PIPELINED
   IS
   BEGIN
      FOR i IN 0 .. (p_num_days - 1)
      LOOP
         PIPE ROW (p_start + i);
      END LOOP;

      RETURN;
   END date_stream;

   /*
   *  FUNCTION date_stream
   *
   *  Stream a pipelined date_nt
   */
   FUNCTION date_stream(p_start IN DATE, p_end IN DATE)
      RETURN date_nt
      DETERMINISTIC
      PIPELINED
   IS
   BEGIN
      FOR i IN 0 .. FLOOR(p_end - p_start)
      LOOP
         PIPE ROW (p_start + i);
      END LOOP;

      RETURN;
   END date_stream;

   /*
   *  FUNCTION date_cur
   *
   *  Open a cursor of dates.
   */
   FUNCTION date_cur(p_start IN DATE, p_num_days IN PLS_INTEGER)
      RETURN SYS_REFCURSOR
      DETERMINISTIC
   IS
      l_cur   SYS_REFCURSOR;
   BEGIN
      OPEN l_cur FOR SELECT * FROM TABLE(date_stream(p_start, p_num_days));

      RETURN l_cur;
   END date_cur;

   /*
   *  FUNCTION date_cur
   *
   *  Open a cursor of dates.
   */
   FUNCTION date_cur(p_start IN DATE, p_end IN DATE)
      RETURN SYS_REFCURSOR
      DETERMINISTIC
   IS
      l_cur   SYS_REFCURSOR;
   BEGIN
      OPEN l_cur FOR SELECT * FROM TABLE(date_stream(p_start, p_end));

      RETURN l_cur;
   END date_cur;

   /*
   *  FUNCTION days_in_month
   */
   FUNCTION days_in_month(p_date IN DATE)
      RETURN PLS_INTEGER
   IS
      l_first_of_month   DATE;
   BEGIN
      l_first_of_month := TRUNC(p_date, 'mm');
      RETURN ADD_MONTHS(l_first_of_month, 1) - l_first_of_month;
   END days_in_month;

   /*
   *  FUNCTION days_in_year
   */
   FUNCTION days_in_year(p_date IN DATE)
      RETURN PLS_INTEGER
   IS
      l_first_of_year   DATE;
   BEGIN
      l_first_of_year := TRUNC(p_date, 'yyyy');
      RETURN ADD_MONTHS(l_first_of_year, 12) - l_first_of_year;
   END days_in_year;

   /*
   *  FUNCTION is_weekday
   */
   FUNCTION is_weekday(p_date IN DATE)
      RETURN BOOLEAN
   IS
   BEGIN
      -- iw starts on Monday, hence {0, 1, 2, 3, 4} are Mon-Fri
      RETURN (TRUNC(p_date) - TRUNC(p_date, 'iw')) <= 4;
   END is_weekday;

   /*
   *  FUNCTION is_weekend
   */
   FUNCTION is_weekend(p_date IN DATE)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN NOT is_weekday(p_date);
   END is_weekend;
END dates;
/