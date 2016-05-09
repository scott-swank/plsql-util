CREATE OR REPLACE TYPE BODY log_writer
AS
   /*
   ==============================================================================
   PL/SQL Object Type: log_writer

   log_writer writes text to the table swx_log

   ------------------------------------------------------------------------------

   OPEN SOURCE CLASSES FOR ORACLE PL/SQL
   Version 0.7
   Copyright (C) 2016 Scott Swank  scott.swank@gmail.com

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

   http://www.gnu.org/licenses/gpl-3.0.en.html
   ==============================================================================
   */

   /*
   *  CONSTRUCTOR FUNCTION log_writer
   */
   CONSTRUCTOR FUNCTION log_writer(p_module IN VARCHAR2, p_action IN VARCHAR2 DEFAULT NULL, p_client_info IN VARCHAR2 DEFAULT NULL)
      RETURN SELF AS RESULT
   IS
      l_stack_entry   utl_call_stack.unit_qualified_name;
   BEGIN
      SELF.module := p_module;
      SELF.action := p_action;
      SELF.client_info := p_client_info;

      IF p_module IS NULL
      THEN
         -- this frame is 1
         -- so our caller is 2
         l_stack_entry := utl_call_stack.subprogram(2);
         SELF.module := l_stack_entry(1);

         IF l_stack_entry.COUNT > 1
         THEN
            SELF.action := l_stack_entry(2);
         END IF;
      END IF;

      SELECT char_length
        INTO SELF.line_size
        FROM all_tab_columns tc
       WHERE     table_name = 'SWX_LOG'
             AND owner = (SELECT owner
                            FROM (SELECT USER AS owner
                                    FROM user_tables
                                   WHERE table_name = tc.table_name
                                  UNION ALL
                                  SELECT table_owner
                                    FROM user_synonyms
                                   WHERE synonym_name = tc.table_name
                                  UNION ALL
                                  SELECT table_owner
                                    FROM all_synonyms
                                   WHERE owner = 'PUBLIC' AND synonym_name = tc.table_name)
                           WHERE ROWNUM = 1)
             AND column_name = 'TEXT';

      RETURN;
   END;
   /*
   *  OVERRIDING MEMBER PROCEDURE put_line_impl
   */
   OVERRIDING MEMBER PROCEDURE put_line_impl(t IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      /*
     Pull info from v$session?

      SELECT sid,
             audsid,
             status,
             username,
             module,
             action,
             client_info
        FROM V$SESSION s
       WHERE s.audsid = SYS_CONTEXT('USERENV', 'SESSIONID');


      Or from utl_call_stack?

      How often?
      */

      INSERT INTO swx_log(module,
                          action,
                          client_info,
                          text)
      VALUES (SELF.module,
              SELF.action,
              SELF.client_info,
              SUBSTR(t, 1, SELF.line_size));

      COMMIT;
   END;
--
END;
/