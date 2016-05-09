CREATE OR REPLACE PACKAGE logger_pkg
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
   off     CONSTANT INTEGER := 0;
   fatal   CONSTANT INTEGER := 1;
   error   CONSTANT INTEGER := 2;
   warn    CONSTANT INTEGER := 3;
   info    CONSTANT INTEGER := 4;
   debug   CONSTANT INTEGER := 5;
   trace   CONSTANT INTEGER := 6;

   /*
   * PROCEDURE define_writer
   *
   * Assign a writer to be used by any loggers retrieved from get_logger().
   * If none is assigned a std_writer will be used.
   */
   PROCEDURE define_writer(p_writer IN writer);

   /*
   *  FUNCTION register_log_level
   *
   *  Define the numeric log level and sample rate for the given namespace/context.
   */
   PROCEDURE register_log_level(p_namespace        swx_log_config.module%TYPE,
                                p_value         IN swx_log_config.log_level%TYPE,
                                p_sample_rate   IN swx_log_config.sample_rate%TYPE DEFAULT 1.0);

   /*
   *  FUNCTION delete_log_level
   *
   *  Remove given namespace/context along with its log level.
   */
   PROCEDURE delete_log_level(p_namespace swx_log_config.module%TYPE);

   /*
   *  PROCEDURE update_log_level
   *
   *  Given the namespace A.B.C we will first look for a log level for the following:
   *    A.B.C
   *    A.B
   *    A
   *
   *  If we do not find any of the above we use the default log level and
   *  register that log level for the top-level (e.g. A) namespace.
   *
   *  In practice this means that we will look for:
   *    your_package.some_procedure
   *    your_package
   *
   */
   PROCEDURE update_log_level(p_log_level IN OUT NOCOPY dynamic_log_level);

   /*
   * FUNCTION get_logger
   *   RETURN logger
   *
   * Obtain a logger corresponding to the current code context.
   *
   *    p_writer -- output will be sent to p_writer
   *    p_refresh_seconds -- the frequency with which the log level for this
   *      namespace will be updated, a value of zero will result in an
   *      update on every use of the logger.
   */
   FUNCTION get_logger(p_writer IN writer, p_refresh_seconds IN PLS_INTEGER DEFAULT 30)
      RETURN logger;

   /*
   *  FUNCTION get_db_logger
   *    RETURN logger
   *
   *  Obtain a logger that writes to the standard log table, swx_log.
   */
   FUNCTION get_db_logger(p_refresh_seconds IN PLS_INTEGER DEFAULT 30)
      RETURN logger;

   /*
   *  FUNCTION get_logger
   *    RETURN logger
   *
   *  Obtain a logger corresponding to the current code context. The default
   *  writer from define_writer() will be used.
   */
   FUNCTION get_logger(p_refresh_seconds IN PLS_INTEGER DEFAULT 30)
      RETURN logger;
END logger_pkg;
/