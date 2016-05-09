DECLARE
   l_tokens             text_nt;
   l_bool_result        BOOLEAN;
   l_exception_raised   BOOLEAN;
BEGIN
   --
   -- test split/join
   --

   l_tokens := text.split('a,b,c');
   assert.equals(l_tokens.COUNT, 3);
   assert.equals(l_tokens(1), 'a');
   assert.equals(l_tokens(2), 'b');
   assert.equals(l_tokens(3), 'c');

   l_tokens := text.split('abc:def:ghi::xyz', ':');
   assert.equals(l_tokens.COUNT, 5);
   assert.equals(l_tokens(1), 'abc');
   assert.is_null(l_tokens(4));
   assert.equals(l_tokens(5), 'xyz');

   assert.equals(text.join(l_tokens), 'abc,def,ghi,xyz');
   assert.equals(text.join(l_tokens, p_ignore_nulls => 'N'), 'abc,def,ghi,,xyz');
   assert.equals(text.join(l_tokens, '-'), 'abc-def-ghi-xyz');
   assert.equals(text.join(l_tokens, NULL), 'abcdefghixyz');

   l_tokens.DELETE;
   assert.is_null(text.join(l_tokens));

   --
   -- test boolean functions
   --

   assert.equals(text.TO_CHAR(TRUE), 'TRUE');
   assert.equals(text.TO_CHAR(FALSE), 'FALSE');
   assert.is_null(text.TO_CHAR(NULL));

   assert.equals(text.to_tf(TRUE), 'T');
   assert.equals(text.to_tf(FALSE), 'F');
   assert.is_null(text.to_tf(NULL));

   assert.equals(text.to_yn(TRUE), 'Y');
   assert.equals(text.to_yn(FALSE), 'N');
   assert.is_null(text.to_yn(NULL));

   assert.is_true(text.to_boolean('True'));
   assert.is_true(text.to_boolean('TRUE'));
   assert.is_true(text.to_boolean('T'));
   assert.is_true(text.to_boolean('Y'));
   assert.is_true(text.to_boolean('y'));

   assert.is_false(text.to_boolean('false'));
   assert.is_false(text.to_boolean('FALSE'));
   assert.is_false(text.to_boolean('F'));
   assert.is_false(text.to_boolean('f'));
   assert.is_false(text.to_boolean('N'));

   assert.is_null(text.to_boolean(NULL));
   assert.is_null(text.to_boolean('applesauce'));

   BEGIN
      l_bool_result := text.to_boolean('applesauce', p_strict => TRUE);
      l_exception_raised := FALSE;
   EXCEPTION
      WHEN assert.illegal_argument
      THEN
         l_exception_raised := TRUE;
   END;

   assert.is_true(l_exception_raised);

   --
   -- test prefix/suffix
   --

   assert.is_null(text.prefix(NULL, 4));
   assert.is_null(text.prefix(NULL, 0));
   assert.is_null(text.prefix('abcdef', 0));
   assert.equals(text.prefix('abcdef', 1), 'a');
   assert.equals(text.prefix('abcdef', 3), 'abc');
   assert.equals(text.prefix('abcdef', 6), 'abcdef');
   assert.equals(text.prefix('abcdef', 18), 'abcdef');

   assert.is_null(text.suffix(NULL, 4));
   assert.is_null(text.suffix(NULL, 0));
   assert.is_null(text.suffix('abcdef', 0));
   assert.equals(text.suffix('abcdef', 1), 'f');
   assert.equals(text.suffix('abcdef', 3), 'def');
   assert.equals(text.suffix('abcdef', 6), 'abcdef');
   assert.equals(text.suffix('abcdef', 18), 'abcdef');

   --
   -- test mask()
   --

   assert.is_null(text.mask(NULL));
   assert.equals(text.mask('a'), '*');
   assert.equals(text.mask('abcdef'), '******');
   assert.equals(text.mask('abcdef', p_mask_char => '#'), '######');
   assert.equals(text.mask('abcdef', p_prefix_size => 0), '******');
   assert.equals(text.mask('abcdef', p_prefix_size => 2), 'ab****');
   assert.equals(text.mask('abcdef', p_prefix_size => 6), 'abcdef');
   assert.equals(text.mask('abcdef', p_prefix_size => 16), 'abcdef');
   assert.equals(text.mask('abcdef', p_suffix_size => 0), '******');
   assert.equals(text.mask('abcdef', p_suffix_size => 2), '****ef');
   assert.equals(text.mask('abcdef', p_suffix_size => 6), 'abcdef');
   assert.equals(text.mask('abcdef', p_suffix_size => 22), 'abcdef');
   assert.equals(text.mask('abcdef', p_prefix_size => 1, p_suffix_size => 1), 'a****f');
   assert.equals(text.mask('abcdef', p_prefix_size => 1, p_suffix_size => 2), 'a***ef');
   assert.equals(text.mask('abcdef', p_prefix_size => 2, p_suffix_size => 3), 'ab*def');
   assert.equals(text.mask('abcdef', p_prefix_size => 5, p_suffix_size => 4), 'abcdef');
   assert.equals(text.mask('abcdef',
                           p_mask_char     => '~',
                           p_prefix_size   => 2,
                           p_suffix_size   => 2),
                 'ab~~ef');
END;
/