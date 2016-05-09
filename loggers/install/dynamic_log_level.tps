CREATE OR REPLACE TYPE dynamic_log_level
   UNDER log_level
   /*
   ==============================================================================
   PL/SQL Object Type: dynamic_log_level
   
   The level is retrieved from logger_pkg.retrieve_log_level(p_namespace),
   using the attribute [context] for p_namespace. This is performed every
   [update_seconds]. If [update_seconds] is NULL this is performed every call.

   Note: the "SELF IN OUT dynamic_log_level" parameters are typically implicit,
   but must be included in the signature as a work-around for current limitations 
   of Object Types in PL/SQL. A client does not specify this parameter and may 
   ignore it. E.g. simply call lvl.is_debug_enabled()
   ------------------------------------------------------------------------------

   OPEN SOURCE CLASSES FOR ORACLE PL/SQL
   Version 0.7
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
   (
      context VARCHAR2(200 CHAR),
      next_update DATE,
      update_seconds NUMBER(4, 0),
      CONSTRUCTOR FUNCTION dynamic_log_level(p_context IN VARCHAR2, p_update_seconds IN PLS_INTEGER DEFAULT 30)
         RETURN SELF AS RESULT,
      MEMBER PROCEDURE update_level(SELF IN OUT dynamic_log_level),
      OVERRIDING MEMBER FUNCTION is_trace_enabled(SELF IN OUT dynamic_log_level)
         RETURN BOOLEAN,
      OVERRIDING MEMBER FUNCTION is_debug_enabled(SELF IN OUT dynamic_log_level)
         RETURN BOOLEAN,
      OVERRIDING MEMBER FUNCTION is_info_enabled(SELF IN OUT dynamic_log_level)
         RETURN BOOLEAN,
      OVERRIDING MEMBER FUNCTION is_warn_enabled(SELF IN OUT dynamic_log_level)
         RETURN BOOLEAN,
      OVERRIDING MEMBER FUNCTION is_error_enabled(SELF IN OUT dynamic_log_level)
         RETURN BOOLEAN,
      OVERRIDING MEMBER FUNCTION is_fatal_enabled(SELF IN OUT dynamic_log_level)
         RETURN BOOLEAN
   )
/