CREATE OR REPLACE PACKAGE errors
AS
   null_value                    EXCEPTION;
   illegal_argument              EXCEPTION;
   invalid_state                 EXCEPTION;

   null_value_code      CONSTANT PLS_INTEGER := -20901;
   illegal_arg_code     CONSTANT PLS_INTEGER := -20902;
   invalid_state_code   CONSTANT PLS_INTEGER := -20903;

   PRAGMA EXCEPTION_INIT (null_value, -20901);
   PRAGMA EXCEPTION_INIT (illegal_argument, -20902);
   PRAGMA EXCEPTION_INIT (invalid_state, -20903);
END errors;