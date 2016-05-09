CREATE OR REPLACE TYPE BODY file_writer
AS
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
   CONSTRUCTOR FUNCTION file_writer(p_directory IN VARCHAR2, p_file_name IN VARCHAR2)
      RETURN SELF AS RESULT
   IS
   BEGIN
      self.dir_name := p_directory;
      self.file_name := p_file_name;
      RETURN;
   END;
   --
   OVERRIDING MEMBER PROCEDURE open_writer
   IS
      l_file_type   UTL_FILE.file_type;
   BEGIN
      l_file_type :=
         UTL_FILE.fopen(self.dir_name,
                        self.file_name,
                        'w',
                        32767);
      self.file_type_id := l_file_type.id;
      self.file_datatype := l_file_type.datatype;
   END;
   --
   OVERRIDING MEMBER PROCEDURE close_writer
   IS
      l_file_type   UTL_FILE.file_type;
   BEGIN
      l_file_type.id := self.file_type_id;
      l_file_type.datatype := self.file_datatype;

      IF UTL_FILE.is_open(l_file_type)
      THEN
         UTL_FILE.fclose(file => l_file_type);
      END IF;
   END;
   --
   OVERRIDING MEMBER PROCEDURE put(t IN VARCHAR2)
   IS
      l_file_type   UTL_FILE.file_type;
   BEGIN
      l_file_type.id := self.file_type_id;
      l_file_type.datatype := self.file_datatype;
      UTL_FILE.put(l_file_type, t);
   END;
   --
   OVERRIDING MEMBER PROCEDURE put_line(t IN VARCHAR2)
   IS
      l_file_type   UTL_FILE.file_type;
   BEGIN
      l_file_type.id := self.file_type_id;
      l_file_type.datatype := self.file_datatype;
      UTL_FILE.put_line(l_file_type, t);
   END;
--
END;
/