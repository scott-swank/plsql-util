CREATE OR REPLACE TYPE log_writer
   UNDER appending_writer
(
   /*
   ==============================================================================
   PL/SQL Object Type: log_writer

   log_writer writes text to the table swx_log

   ------------------------------------------------------------------------------

   OPEN SOURCE CLASSES FOR ORACLE PL/SQL
   Version 0.7
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

   http://www.gnu.org/licenses/gpl-3.0.en.html
   ==============================================================================
   */
   module VARCHAR2(64 CHAR),
   action VARCHAR2(64 CHAR),
   client_info VARCHAR2(64 CHAR),
   line_size NUMBER(5, 0),
   /*
   *  CONSTRUCTOR FUNCTION log_writer
   *
   *    p_module -- The value that will be written to swx_log.module
   *    p_action -- The value that will be written to swx_log.action
   *    p_client_info -- The value that will be written to swx_log.client_info
   */
   CONSTRUCTOR FUNCTION log_writer(p_module IN VARCHAR2, p_action IN VARCHAR2 DEFAULT NULL, p_client_info IN VARCHAR2 DEFAULT NULL)
      RETURN SELF AS RESULT,
   /*
   *  OVERRIDING MEMBER PROCEDURE put_line_impl
   *
   *  Create an entry in swx_log. See appending_writer.
   */
   OVERRIDING MEMBER PROCEDURE put_line_impl(t IN VARCHAR2)
)
/