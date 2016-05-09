CREATE OR REPLACE PACKAGE sql_pkg
AS
   /**
   *  PROCEDURE import_code
   *
   *  Create the specified package, function or procedure in the current schema.
   **/
   PROCEDURE import_code(p_name IN VARCHAR2, p_owner IN VARCHAR2 DEFAULT NULL, p_type IN VARCHAR2 DEFAULT NULL);
END sql_pkg;
/