CREATE OR REPLACE TYPE session_writer
   UNDER appending_writer
   (
      /*
      ==============================================================================
      PL/SQL Object Type: session_writer

      session_writer writes to v$session.client_info

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
      CONSTRUCTOR FUNCTION session_writer
         RETURN SELF AS RESULT,
      --
      OVERRIDING MEMBER PROCEDURE put_line_impl(t IN VARCHAR2)
   )
/