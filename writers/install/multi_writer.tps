DROP TYPE multi_writer
/

CREATE OR REPLACE TYPE writer_nt AS TABLE OF writer
/

CREATE OR REPLACE TYPE multi_writer
   UNDER writer
   (
      /*
      ==============================================================================
      PL/SQL Object Type: multi_writer

      A multi_writer multiplexes output across its target writers.
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
      writers writer_nt,
      CONSTRUCTOR FUNCTION multi_writer (p_writers IN writer_nt DEFAULT writer_nt ())
         RETURN SELF AS RESULT,
      OVERRIDING MEMBER PROCEDURE open_writer,
      OVERRIDING MEMBER PROCEDURE close_writer,
      OVERRIDING MEMBER PROCEDURE put (t IN VARCHAR2),
      OVERRIDING MEMBER PROCEDURE put_line (t IN VARCHAR2),
      /*
      *  MEMBER PROCEDURE add_writer
      *
      *  Add a target writer.
      */
      MEMBER PROCEDURE add_writer (p_writer IN writer),
      /*
      *  MEMBER PROCEDURE remove_writer
      *
      *  Remove the most recently added target writer.
      */
      MEMBER PROCEDURE remove_writer
   )
/