CREATE OR REPLACE TYPE std_writer
   UNDER writer
   (
      /*
      ==============================================================================
      PL/SQL Object Type: std_writer
      
      std_writer writes to standard output via dbms_output. It thus has the same
      requirement as dbms_output that the client retrieves the lines and displays
      them.
      
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
      CONSTRUCTOR FUNCTION std_writer
         RETURN SELF AS RESULT,
      OVERRIDING MEMBER PROCEDURE open_writer,
      OVERRIDING MEMBER PROCEDURE close_writer,
      OVERRIDING MEMBER PROCEDURE put (t IN VARCHAR2),
      OVERRIDING MEMBER PROCEDURE put_line (t IN VARCHAR2)
   )
/