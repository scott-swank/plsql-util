CREATE OR REPLACE TYPE logger AS OBJECT
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
  Copyright (C) 2016 Scott Swank  scott.swank@gmail.com

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
   log_lvl log_level,
   w writer,
   /*
   *  CONSTRUCTOR FUNCTION logger
   *
   *  Create a logger, using the specified:
   *    log_level -- by default a static log_level as INFO level
   *    writer -- by default one that uses standard out
   */
   CONSTRUCTOR FUNCTION logger(p_log_level IN log_level DEFAULT log_level(), p_writer IN writer DEFAULT std_writer())
      RETURN SELF AS RESULT,
   /*
   *  MEMBER PROCEDURE trace
   *
   *  Send p_message to the writer when log_lvl.is_trace_enabled().
   */
   MEMBER PROCEDURE trace(p_message IN VARCHAR2),
   /*
   *  MEMBER PROCEDURE debug
   *
   *  Send p_message to the writer when log_lvl.is_debug_enabled().
   */
   MEMBER PROCEDURE debug(p_message IN VARCHAR2),
   /*
   *  MEMBER PROCEDURE info
   *
   *  Send p_message to the writer when log_lvl.is_info_enabled().
   */
   MEMBER PROCEDURE info(p_message IN VARCHAR2),
   /*
   *  MEMBER PROCEDURE warn
   *
   *  Send p_message to the writer when log_lvl.is_warn_enabled().
   */
   MEMBER PROCEDURE warn(p_message IN VARCHAR2),
   /*
   *  MEMBER PROCEDURE error
   *
   *  Send p_message to the writer when log_lvl.is_error_enabled().
   */
   MEMBER PROCEDURE error(p_message IN VARCHAR2),
   /*
   *  MEMBER PROCEDURE fatal
   *
   *  Send p_message to the writer when log_lvl.is_fatal_enabled().
   */
   MEMBER PROCEDURE fatal(p_message IN VARCHAR2)
)
   FINAL;
/