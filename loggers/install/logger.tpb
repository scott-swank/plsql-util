CREATE OR REPLACE TYPE BODY logger
/*
 ==============================================================================
 PL/SQL Object Type: logger

 A logger writes messages, conditional on its log level.
 E.g. A log-level of WARN would only write messages via the warn(), error()
 or fatal() methods. Calls to trace(), debug() or info() would be ignored.

 See the object types: log_level and writer.
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
AS
   /*
   *  CONSTRUCTOR FUNCTION logger
   */
   CONSTRUCTOR FUNCTION logger(p_log_level IN log_level DEFAULT log_level(), p_writer IN writer DEFAULT std_writer())
      RETURN SELF AS RESULT
   IS
   BEGIN
      SELF.log_lvl := p_log_level;
      SELF.w := p_writer;
      SELF.w.open_writer();
      RETURN;
   END;

   /*
   *  MEMBER PROCEDURE trace
   */
   MEMBER PROCEDURE trace(p_message IN VARCHAR2)
   IS
   BEGIN
      IF (log_lvl.is_trace_enabled())
      THEN
         w.put_line(p_message);
      END IF;
   END trace;

   /*
   *  MEMBER PROCEDURE debug
   */
   MEMBER PROCEDURE debug(p_message IN VARCHAR2)
   IS
   BEGIN
      IF (log_lvl.is_debug_enabled())
      THEN
         w.put_line(p_message);
      END IF;
   END debug;

   /*
   *  MEMBER PROCEDURE info
   */
   MEMBER PROCEDURE info(p_message IN VARCHAR2)
   IS
   BEGIN
      IF (log_lvl.is_info_enabled())
      THEN
         w.put_line(p_message);
      END IF;
   END info;

   /*
   *  MEMBER PROCEDURE warn
   */
   MEMBER PROCEDURE warn(p_message IN VARCHAR2)
   IS
   BEGIN
      IF (log_lvl.is_warn_enabled())
      THEN
         w.put_line(p_message);
      END IF;
   END warn;

   /*
   *  MEMBER PROCEDURE error
   */
   MEMBER PROCEDURE error(p_message IN VARCHAR2)
   IS
   BEGIN
      IF (log_lvl.is_error_enabled())
      THEN
         w.put_line(p_message);
      END IF;
   END error;

   /*
   *  MEMBER PROCEDURE fatal
   */
   MEMBER PROCEDURE fatal(p_message IN VARCHAR2)
   IS
   BEGIN
      IF (log_lvl.is_fatal_enabled())
      THEN
         w.put_line(p_message);
      END IF;
   END fatal;
END;
/