CREATE OR REPLACE TYPE BODY wrapping_writer
AS
   /*
   ==============================================================================
   PL/SQL Object Type: wrapping_writer

   A wrapping_writer outputs lines only of specifed maximum length, wrapping any
   additional text to successive lines. It does not account for whitespace.
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
   CONSTRUCTOR FUNCTION wrapping_writer(p_line_len IN NUMBER, p_target IN writer DEFAULT std_writer())
      RETURN SELF AS RESULT
   IS
   BEGIN
      SELF.target_writer := p_target;
      SELF.line_len := p_line_len;
      RETURN;
   END;
   --
   OVERRIDING MEMBER PROCEDURE open_writer
   IS
   BEGIN
      SELF.target_writer.open_writer();
   END;
   --
   OVERRIDING MEMBER PROCEDURE close_writer
   IS
   BEGIN
      SELF.target_writer.close_writer();
   END;
   --
   OVERRIDING MEMBER PROCEDURE put(t IN VARCHAR2)
   IS
      l_position   PLS_INTEGER := 1;
      l_size       PLS_INTEGER := LENGTH(t);
   BEGIN
      IF SELF.line_len IS NULL
      THEN
         SELF.target_writer.put(t);
      ELSE
         WHILE l_position <= l_size
         LOOP
            IF l_position + SELF.line_len <= l_size
            THEN
               SELF.target_writer.put(SUBSTR(t, l_position, SELF.line_len));
            ELSE
               SELF.target_writer.put_line(SUBSTR(t, l_position));
            END IF;

            l_position := l_position + SELF.line_len;
         END LOOP;
      END IF;
   END;
   --
   OVERRIDING MEMBER PROCEDURE put_line(t IN VARCHAR2)
   IS
      l_position   PLS_INTEGER := 1;
      l_size       PLS_INTEGER := LENGTH(t);
   BEGIN
      IF SELF.line_len IS NULL
      THEN
         SELF.target_writer.put_line(t);
      ELSE
         WHILE l_position <= l_size
         LOOP
            SELF.target_writer.put_line(SUBSTR(t, l_position, SELF.line_len));
            l_position := l_position + SELF.line_len;
         END LOOP;
      END IF;
   END;
--
END;
/