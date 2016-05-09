CREATE OR REPLACE TYPE BODY timestamp_writer
AS
   /*
   ==============================================================================
   PL/SQL Object Type: timestamp_writer

   A timestamp_writer prefixes each line with the current time, formatted with
   the provided mask. The default mask is 'hh24:mi:ss'.

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
   CONSTRUCTOR FUNCTION timestamp_writer(p_target IN writer DEFAULT std_writer(), p_mask IN VARCHAR2 DEFAULT 'hh24:mi:ss')
      RETURN SELF AS RESULT
   IS
   BEGIN
      SELF.target_writer := p_target;
      SELF.mask := p_mask;
      SELF.line_in_progress := 0;
      RETURN;
   END;
   --
   OVERRIDING MEMBER PROCEDURE open_writer
   IS
   BEGIN
      SELF.target_writer.open_writer();
      SELF.line_in_progress := 0;
   END;
   --
   OVERRIDING MEMBER PROCEDURE close_writer
   IS
   BEGIN
      SELF.line_in_progress := 0;
      SELF.target_writer.close_writer();
   END;
   --
   OVERRIDING MEMBER PROCEDURE put(t IN VARCHAR2)
   IS
   BEGIN
      IF SELF.line_in_progress = 0
      THEN
         SELF.target_writer.put(ts());
      END IF;

      SELF.target_writer.put(t);

      self.line_in_progress := 1;
   END;
   --
   OVERRIDING MEMBER PROCEDURE put_line(t IN VARCHAR2)
   IS
   BEGIN
      IF SELF.line_in_progress = 0
      THEN
         SELF.target_writer.put(ts());
      END IF;

      SELF.target_writer.put_line(t);

      self.line_in_progress := 0;
   END;

   --

   MEMBER FUNCTION ts
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '[' || TO_CHAR(SYSDATE, SELF.mask) || ']';
   END;
END;
/