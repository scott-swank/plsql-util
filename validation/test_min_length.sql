DECLARE
   l_msg   VARCHAR2(4000);
BEGIN
   --
   --  Successful assertions
   --
   assert.min_length(NULL, 0);
   assert.min_length('asdf', 0);
   assert.min_length('asdf', 1);
   assert.min_length('asdf', 2);
   assert.min_length('asdf', 3);
   assert.min_length('asdf', 4);

   -- failure with the standard error message
   -- extract the message itself, without the ORA-20702 prefix
   BEGIN
      assert.min_length('a', 2);
      assert.fail();
   EXCEPTION
      WHEN assert.illegal_argument
      THEN
         assert.equals(SQLERRM, 'ORA-20702: The Field1 [a] must be at least 2 characters.');
         assert.equals(assert.extract_msg(SQLERRM), 'The Field1 [a] must be at least 2 characters.');
   END;

   -- failure with the standard error message
   BEGIN
      assert.min_length(NULL, 2);
      assert.fail();
   EXCEPTION
      WHEN assert.illegal_argument
      THEN
         assert.equals(assert.extract_msg(SQLERRM), 'The Field1 [NULL] must be at least 2 characters.');
   END;

   -- failure with a custom error message
   BEGIN
      assert.min_length('a', 2, 'Last name is too short.');
      assert.fail();
   EXCEPTION
      WHEN assert.illegal_argument
      THEN
         assert.equals(assert.extract_msg(SQLERRM), 'Last name is too short.');
   END;

   -- failure with the standard error message and the field name specified
   BEGIN
      assert.min_length('a', 2, p_field => 'LAST_NAME');
      assert.fail();
   EXCEPTION
      WHEN assert.illegal_argument
      THEN
         assert.equals(assert.extract_msg(SQLERRM), 'The LAST_NAME [a] must be at least 2 characters.');
   END;

   -- failure with a custom error message using placeholders
   BEGIN
      assert.min_length('a', 2, '"[VALUE1]" is too short.');
      assert.fail();
   EXCEPTION
      WHEN assert.illegal_argument
      THEN
         assert.equals(assert.extract_msg(SQLERRM), '"a" is too short.');
   END;

   -- failure with a custom error message using placeholders
   BEGIN
      assert.min_length('a',
                        2,
                        '[FIELD1] must be at least [VALUE2] characters, found: "[VALUE1]" instead.',
                        p_field   => 'LAST_NAME');
      assert.fail();
   EXCEPTION
      WHEN assert.illegal_argument
      THEN
         assert.equals(assert.extract_msg(SQLERRM), 'LAST_NAME must be at least 2 characters, found: "a" instead.');
   END;
END;
/