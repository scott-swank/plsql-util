CREATE OR REPLACE TYPE BODY appending_writer
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

   /*
   *  CONSTRUCTOR FUNCTION appending_writer
   */
   CONSTRUCTOR FUNCTION appending_writer
      RETURN SELF AS RESULT
   IS
   BEGIN
      RETURN;
   END;
   /*
   *  MEMBER PROCEDURE open_writer
   */
   OVERRIDING MEMBER PROCEDURE open_writer
   IS
   BEGIN
      current_line := NULL;
   END;
   --
   /*
   *  MEMBER PROCEDURE close_writer
   */
   OVERRIDING MEMBER PROCEDURE close_writer
   IS
   BEGIN
      current_line := NULL;
   END;
   --
   /*
   *  MEMBER PROCEDURE put
   */
   OVERRIDING MEMBER PROCEDURE put(t IN VARCHAR2)
   IS
   BEGIN
      IF (current_line IS NULL)
      THEN
         current_line := t;
      ELSE
         current_line := current_line || t;
      END IF;
   END;
   --
   /*
   *  MEMBER PROCEDURE put_line
   */
   OVERRIDING MEMBER PROCEDURE put_line(t IN VARCHAR2)
   IS
   BEGIN
      IF (current_line IS NULL)
      THEN
         SELF.put_line_impl(t);
      ELSE
         SELF.put_line_impl(current_line || t);
         current_line := NULL;
      END IF;
   END;

   --

   /*
   *  MEMBER PROCEDURE put_line_impl
   */
   MEMBER PROCEDURE put_line_impl(t IN VARCHAR2)
   IS
   BEGIN
      NULL;
   END;
--
END;
/