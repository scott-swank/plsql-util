--DROP PACKAGE logger_pkg;
--
--DROP TYPE logger;
--
--DROP TYPE dynamic_log_level;

CREATE OR REPLACE TYPE log_level AS OBJECT
/*
==============================================================================
PL/SQL Object Type: log_level

A log_level indicates the granularity of logging to be performed via
functions is_trace_enabled(), is_debug_enabled(), etc.

These functions correspond to the constant log level values defined in
logger_pkg.

The sample_rate takes values between 0.0 and 1.0. The value 0.0 corresponds
to no logging, while 1.0 corresponds to always logging -- with respect to
the current log_level.value. Sample_rate values between 0.0 and 1.0 result
in only logging that proportion of the calls. E.g. If the log_level.value is
set to INFO (4) and log_level.sample_rate is 0.25, then only 1/4 of the calls
to is_info_enabled() will return TRUE.

This feature can be used when very high volumes of data are potentially being
handled.
------------------------------------------------------------------------------

OPEN SOURCE CLASSES FOR ORACLE PL/SQL
Version 0.4
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
(
   VALUE INTEGER,
   sample_rate NUMBER,
   -- default log level value is logger_pkg.info = 4
   CONSTRUCTOR FUNCTION log_level(p_value IN INTEGER DEFAULT 4, p_sample_rate IN NUMBER DEFAULT 1.0)
      RETURN SELF AS RESULT,
   MEMBER FUNCTION is_trace_enabled(SELF IN OUT log_level)
      RETURN BOOLEAN,
   MEMBER FUNCTION is_debug_enabled(SELF IN OUT log_level)
      RETURN BOOLEAN,
   MEMBER FUNCTION is_info_enabled(SELF IN OUT log_level)
      RETURN BOOLEAN,
   MEMBER FUNCTION is_warn_enabled(SELF IN OUT log_level)
      RETURN BOOLEAN,
   MEMBER FUNCTION is_error_enabled(SELF IN OUT log_level)
      RETURN BOOLEAN,
   MEMBER FUNCTION is_fatal_enabled(SELF IN OUT log_level)
      RETURN BOOLEAN
)
   NOT FINAL
/