DECLARE
   l_logger    logger;
   l_level     dynamic_log_level;
   l_context   VARCHAR2(200 CHAR);
BEGIN
   l_logger := logger_pkg.get_logger(p_writer => timestamp_writer());

   -- log_level defaults to: info
   l_logger.debug('[FAIL] debug is too granualar and so is not printed');
   l_logger.info('1. info is printed');
   l_logger.warn('2. warn is printed');

   -- increase it to: debug
   l_logger.log_lvl.VALUE := logger_pkg.debug;
   l_logger.debug('3. debug is now printed');
   l_logger.trace('[FAIL] but trace is still too granular');

   -- turn logging off
   l_logger.log_lvl.VALUE := logger_pkg.off;
   l_logger.error('[FAIL] error messages are not printed');
   l_logger.fatal('[FAIL] even a fatal message is skipped');

   -- back to info
   l_logger.log_lvl.VALUE := logger_pkg.info;

   IF (l_logger.log_lvl.is_info_enabled())
   THEN
      l_logger.info('4. construct involved messages [' || SYSDATE || '], otherwise this work is skipped.');
   END IF;

   -- now we want a logger that refreshes every call
   -- this does not perform as well, but demonstrates configuration changes immediately
   -- by default changes are only picked up every 30 seconds
   l_logger := logger_pkg.get_logger(p_writer => timestamp_writer(), p_refresh_seconds => 0);

   -- Now we'll look at the dynamic log_level
   l_level := TREAT(l_logger.log_lvl AS dynamic_log_level);
   l_context := l_level.context;

   -- we change the config.log_level
   UPDATE swx_log_config
      SET log_level = logger_pkg.error
    WHERE module = l_level.context;

   -- and see this in the logger
   l_logger.info('[FAIL] After changing config INFO is no longer printed');
   l_logger.error('5. However ERRORs are printed');

   UPDATE swx_log_config
      SET log_level = logger_pkg.info
    WHERE module = l_level.context;

   COMMIT;
END;
/