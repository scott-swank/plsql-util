CREATE OR REPLACE TYPE BODY multi_writer
AS
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
   CONSTRUCTOR FUNCTION multi_writer(p_writers IN writer_nt DEFAULT writer_nt())
      RETURN SELF AS RESULT
   IS
   BEGIN
      SELF.writers := p_writers;
      RETURN;
   END;
   --
   OVERRIDING MEMBER PROCEDURE open_writer
   IS
   BEGIN
      FOR i IN 1 .. SELF.writers.COUNT
      LOOP
         SELF.writers(i).open_writer();
      END LOOP;
   END;
   --
   OVERRIDING MEMBER PROCEDURE close_writer
   IS
   BEGIN
      FOR i IN 1 .. SELF.writers.COUNT
      LOOP
         SELF.writers(i).close_writer();
      END LOOP;
   END;
   --
   OVERRIDING MEMBER PROCEDURE put(t IN VARCHAR2)
   IS
   BEGIN
      FOR i IN 1 .. SELF.writers.COUNT
      LOOP
         SELF.writers(i).put(t);
      END LOOP;
   END;
   --
   OVERRIDING MEMBER PROCEDURE put_line(t IN VARCHAR2)
   IS
   BEGIN
      FOR i IN 1 .. SELF.writers.COUNT
      LOOP
         SELF.writers(i).put_line(t);
      END LOOP;
   END;

   --
   MEMBER PROCEDURE add_writer(p_writer IN writer)
   IS
   BEGIN
      SELF.writers.EXTEND();
      SELF.writers(SELF.writers.LAST) := p_writer;
   END;

   --
   MEMBER PROCEDURE remove_writer
   IS
   BEGIN
      SELF.writers(SELF.writers.LAST) := NULL;
      SELF.writers.DELETE(SELF.writers.LAST);
   END;
END;
/