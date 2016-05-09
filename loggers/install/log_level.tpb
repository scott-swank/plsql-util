CREATE OR REPLACE TYPE BODY log_level
AS
   /*
   ==============================================================================
   PL/SQL Object Type: log_level

   A log_level indicates the granularity of logging to be performed via
   functions is_trace_enabled(), is_debug_enabled(), etc.

   These functions correspond to the constant log level values defined in
   logger_pkg.
   ------------------------------------------------------------------------------

   OPEN SOURCE CLASSES FOR ORACLE PL/SQL
   Version 0.1
   Copyright (C) 2015 Scott Swank  scott.swank@gmail.com

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
   CONSTRUCTOR FUNCTION log_level(p_value IN INTEGER DEFAULT 4, p_sample_rate IN NUMBER DEFAULT 1.0)
      RETURN SELF AS RESULT
   IS
   BEGIN
      SELF.VALUE := p_value;
      SELF.sample_rate := p_sample_rate;
      RETURN;
   END;

   --
   --
   --

   MEMBER FUNCTION is_trace_enabled(SELF IN OUT log_level)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (    SELF.VALUE >= logger_pkg.trace
              AND SELF.sample_rate > 0.0
              AND (SELF.sample_rate >= 1.0 OR SELF.sample_rate >= DBMS_RANDOM.VALUE()));
   END is_trace_enabled;

   MEMBER FUNCTION is_debug_enabled(SELF IN OUT log_level)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (    SELF.VALUE >= logger_pkg.debug
              AND SELF.sample_rate > 0.0
              AND (SELF.sample_rate >= 1.0 OR SELF.sample_rate >= DBMS_RANDOM.VALUE()));
   END is_debug_enabled;

   MEMBER FUNCTION is_info_enabled(SELF IN OUT log_level)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (    SELF.VALUE >= logger_pkg.info
              AND SELF.sample_rate > 0.0
              AND (SELF.sample_rate >= 1.0 OR SELF.sample_rate >= DBMS_RANDOM.VALUE()));
   END is_info_enabled;

   MEMBER FUNCTION is_warn_enabled(SELF IN OUT log_level)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (    SELF.VALUE >= logger_pkg.warn
              AND SELF.sample_rate > 0.0
              AND (SELF.sample_rate >= 1.0 OR SELF.sample_rate >= DBMS_RANDOM.VALUE()));
   END is_warn_enabled;

   MEMBER FUNCTION is_error_enabled(SELF IN OUT log_level)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (    SELF.VALUE >= logger_pkg.error
              AND SELF.sample_rate > 0.0
              AND (SELF.sample_rate >= 1.0 OR SELF.sample_rate >= DBMS_RANDOM.VALUE()));
   END is_error_enabled;

   MEMBER FUNCTION is_fatal_enabled(SELF IN OUT log_level)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (    SELF.VALUE >= logger_pkg.fatal
              AND SELF.sample_rate > 0.0
              AND (SELF.sample_rate >= 1.0 OR SELF.sample_rate >= DBMS_RANDOM.VALUE()));
   END is_fatal_enabled;
END;
/