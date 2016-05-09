CREATE OR REPLACE TYPE BODY csv_writer
AS
   /*
   ==============================================================================
   PL/SQL Object Type: appending_writer

   An abstract writer that appends calls to put() for later use in
   put_line(). Subtypes only need to implement put_line_impl().

   The method put_line_impl() should not be called externally.
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
   CONSTRUCTOR FUNCTION csv_writer(p_target IN writer DEFAULT std_writer())
      RETURN SELF AS RESULT
   IS
   BEGIN
      SELF.target_writer := p_target;
      line_in_progress := 0;
      RETURN;
   END;
   --
   OVERRIDING MEMBER PROCEDURE open_writer
   IS
   BEGIN
      SELF.target_writer.open_writer();
      line_in_progress := 0;
   END;
   --
   OVERRIDING MEMBER PROCEDURE close_writer
   IS
   BEGIN
      SELF.target_writer.close_writer();
      line_in_progress := 0;
   END;
   --
   OVERRIDING MEMBER PROCEDURE put(t IN VARCHAR2)
   IS
   BEGIN
      IF (line_in_progress = 1)
      THEN
         target_writer.put(',');
      END IF;

      target_writer.put(format_field(t));

      line_in_progress := 1;
   END;
   --
   OVERRIDING MEMBER PROCEDURE put_line(t IN VARCHAR2)
   IS
   BEGIN
      IF t IS NOT NULL
      THEN
         IF (line_in_progress = 1)
         THEN
            target_writer.put(',');
         END IF;

         target_writer.put_line(format_field(t));
      ELSE
         -- just terminate the line
         target_writer.put_line(NULL);
      END IF;

      line_in_progress := 0;
   END;

   --

   /*
   *  MEMBER FUNCTION format_field
   *
   *  Handle csv escaping and quotation when necessary.
   */
   MEMBER FUNCTION format_field(p_field IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_formatted       VARCHAR2(32000 CHAR);
      l_quotes_needed   BOOLEAN := FALSE;
   BEGIN
      IF (p_field IS NULL)
      THEN
         RETURN '""';
      END IF;

      l_formatted := p_field;

      IF (INSTR(l_formatted, '"') != 0)
      THEN
         l_formatted := REPLACE(l_formatted, '"', '""');
         l_quotes_needed := TRUE;
      ELSE
         l_quotes_needed := (INSTR(l_formatted, ',') != 0);
      END IF;

      IF (l_quotes_needed)
      THEN
         l_formatted := '"' || l_formatted || '"';
      END IF;

      RETURN l_formatted;
   END;
END;
/