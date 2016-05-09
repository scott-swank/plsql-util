CREATE OR REPLACE TYPE writer AS OBJECT
(
   /*
   ==============================================================================
   PL/SQL Object Type: writer
   
   A writer is capable simply of writing text. The target for the text varies
   by implementation. See e.g. std_writer, file_writer.
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
   unused_attr NUMBER,                                                       -- only needed to avoid PLS-00589 "no attributes found"
   CONSTRUCTOR FUNCTION writer
      RETURN SELF AS RESULT,
   /*
   * open_writer() -- handle any initialization
   */
   MEMBER PROCEDURE open_writer,
   /*
   * close_writer() -- flush output when needed, handle other cleanup
   */
   MEMBER PROCEDURE close_writer,
   /*
   * put() -- write text to a partial line
   *
   * t: the text
   */
   MEMBER PROCEDURE put (t IN VARCHAR2),
   /*
   * put_line() -- write text to a line
   *
   * t -- the text
   */
   MEMBER PROCEDURE put_line (t IN VARCHAR2)
)
   NOT FINAL;
/