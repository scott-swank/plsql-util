CREATE OR REPLACE PACKAGE BODY logger_pkg
/*
 ==============================================================================
 PACKAGE logger_pkg

 The logger_pkg is a factory for loggers and coordinates logger meta-data.

 See the object types: logger, log_level and writer.
 ------------------------------------------------------------------------------

 OPEN SOURCE CLASSES FOR ORACLE PL/SQL
 Version 0.4
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
AS
   g_default_writer      writer := std_writer();
   g_default_log_level   PLS_INTEGER := info;

   /*
   * PROCEDURE define_writer
   */
   PROCEDURE define_writer(p_writer IN writer)
   IS
   BEGIN
      g_default_writer := writer;
   END define_writer;

   /*
   *  FUNCTION client_stack_entry
   *    RETURN utl_call_stack.unit_qualified_name
   *
   *  Find the top call stack entry that did not originate in this package.
   *  This is the "client" stack entry.
   */
   FUNCTION client_stack_entry
      RETURN utl_call_stack.unit_qualified_name
   IS
      l_depth         PLS_INTEGER;
      l_stack_entry   utl_call_stack.unit_qualified_name;
   BEGIN
      l_depth := utl_call_stack.dynamic_depth();

      -- find the first call stack entry that is not in LOGGER_PKG
      -- depth=1 is this function
      -- depth=2 is the requestor
      -- because this is a package-private function the external caller must be at depth 3 or greater
      FOR i IN 3 .. l_depth
      LOOP
         l_stack_entry := utl_call_stack.subprogram(i);

         IF (l_stack_entry(1) != 'LOGGER_PKG')
         THEN
            RETURN l_stack_entry;
         END IF;
      END LOOP;

      RETURN NULL;
   END client_stack_entry;

   /*
   *  PROCEDURE register_log_level
   */
   PROCEDURE register_log_level(p_namespace        swx_log_config.module%TYPE,
                                p_value         IN swx_log_config.log_level%TYPE,
                                p_sample_rate   IN swx_log_config.sample_rate%TYPE DEFAULT 1.0)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      -- Create an entry for this top-level namespace (typically a package)
      INSERT INTO swx_log_config(module, log_level, sample_rate)
      VALUES (p_namespace, p_value, p_sample_rate);

      COMMIT;
   END register_log_level;

   /*
   *  FUNCTION delete_log_level
   *
   *  Remove given namespace/context along with its log level.
   */
   PROCEDURE delete_log_level(p_namespace swx_log_config.module%TYPE)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      DELETE FROM swx_log_config
       WHERE module = p_namespace;

      COMMIT;
   END delete_log_level;

   /*
   * FUNCTION retrieve_log_level
   */
   PROCEDURE update_log_level(p_log_level IN OUT NOCOPY dynamic_log_level)
   IS
      l_namespace         swx_log_config.module%TYPE;
      l_log_level_value   PLS_INTEGER;
      l_sample_rate       NUMBER;
      l_last_delim_pos    PLS_INTEGER;
   BEGIN
      l_namespace := p_log_level.context;
      l_log_level_value := NULL;

      WHILE (l_log_level_value IS NULL)
      LOOP
         BEGIN
            SELECT log_level, sample_rate
              INTO l_log_level_value, l_sample_rate
              FROM swx_log_config lc
             WHERE lc.module = l_namespace;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_last_delim_pos := INSTR(l_namespace, '.', -1);

               IF (l_last_delim_pos > 0)
               THEN
                  -- discard the last component of the namespace
                  -- e.g. we found no log_level value for 'SOME_PKG.A_PROCEDURE'
                  --      now we look for 'SOME_PKG'
                  l_namespace := SUBSTR(l_namespace, 1, l_last_delim_pos - 1);
               ELSE
                  l_log_level_value := g_default_log_level;
                  l_sample_rate := 1.0;

                  -- Create an entry for this top-level namespace (typically a package)
                  register_log_level(l_namespace, l_log_level_value, l_sample_rate);
               END IF;
         END;
      END LOOP;

      p_log_level.VALUE := l_log_level_value;
      p_log_level.sample_rate := l_sample_rate;
   END update_log_level;

   /*
   *  FUNCTION get_logger
   *    RETURN logger
   */
   FUNCTION get_logger(p_writer writer, p_refresh_seconds IN PLS_INTEGER DEFAULT 30)
      RETURN logger
   IS
      l_stack_entry   utl_call_stack.unit_qualified_name;
      l_namespace     swx_log_config.module%TYPE;
      l_log_level     log_level;
   BEGIN
      l_stack_entry := client_stack_entry();
      l_namespace := utl_call_stack.concatenate_subprogram(l_stack_entry);
      l_log_level := dynamic_log_level(l_namespace, p_refresh_seconds);

      RETURN logger(p_log_level => l_log_level, p_writer => p_writer);
   END get_logger;

   /*
   *  FUNCTION get_db_logger
   *    RETURN logger
   */
   FUNCTION get_db_logger(p_refresh_seconds IN PLS_INTEGER DEFAULT 30)
      RETURN logger
   IS
      l_stack_entry   utl_call_stack.unit_qualified_name;
      l_module        swx_log.module%TYPE;
      l_action        swx_log.action%TYPE;
      l_db_writer     log_writer;
   BEGIN
      l_stack_entry := utl_call_stack.subprogram(2);
      l_module := l_stack_entry(1);

      IF l_stack_entry.COUNT > 1
      THEN
         -- l_module is the package
         -- l_action will be the procedure/function
         l_action := l_stack_entry(2);
      END IF;

      l_db_writer := log_writer(l_module, l_action);
      RETURN get_logger(l_db_writer, p_refresh_seconds);
   END get_db_logger;

   /*
   *  FUNCTION get_logger
   *    RETURN logger
   */
   FUNCTION get_logger(p_refresh_seconds IN PLS_INTEGER DEFAULT 30)
      RETURN logger
   IS
   BEGIN
      RETURN get_logger(g_default_writer, p_refresh_seconds);
   END get_logger;
END logger_pkg;
/