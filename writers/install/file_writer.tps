CREATE OR REPLACE TYPE file_writer
   UNDER writer
   (
      /*
      ==============================================================================
      PL/SQL Object Type: file_writer

      file_writer writes text to the specified os file via utl_file.

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
      dir_name VARCHAR2 (400),
      file_name VARCHAR2 (400),
      file_type_id INTEGER,
      file_datatype INTEGER,
      /*
      * file_writer
      *
      * p_directory -- the name of a directory object
      * p_file_name -- the os file name
      */
      CONSTRUCTOR FUNCTION file_writer (p_directory IN VARCHAR2, p_file_name IN VARCHAR2)
         RETURN SELF AS RESULT,
      OVERRIDING MEMBER PROCEDURE open_writer,
      OVERRIDING MEMBER PROCEDURE close_writer,
      OVERRIDING MEMBER PROCEDURE put (t IN VARCHAR2),
      OVERRIDING MEMBER PROCEDURE put_line (t IN VARCHAR2)
   )
/