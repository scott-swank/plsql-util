DECLARE
   l_txt   VARCHAR2(1000 CHAR)
      := 'Also, the type name that appears after AS in this syntax should be one of the parent types of the type of the expression for which method is being invoked.';
   w       writer := std_writer();
   w2      writer := session_writer();
   m       writer := multi_writer(writer_nt(w, w2));
BEGIN
   m.open_writer();
   m.put_line(l_txt);
   m.put_line('stuff');
   m.close_writer();
END;
/

SELECT client_info
  FROM v$session
 WHERE username = USER;