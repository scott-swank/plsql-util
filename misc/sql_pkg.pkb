CREATE OR REPLACE PACKAGE BODY sql_pkg
AS
   /**
   *  PROCEDURE resolve_object
   *
   *  Resolve p_owner and p_type when one or both are null.
   **/
   PROCEDURE resolve_object(p_name IN VARCHAR2, p_owner IN OUT VARCHAR2, p_type IN OUT VARCHAR2)
   IS
      l_name    all_objects.object_name%TYPE;
      l_owner   all_objects.owner%TYPE;
      l_type    all_objects.object_type%TYPE;
   BEGIN
      l_name := UPPER(p_name);
      l_owner := UPPER(p_owner);
      l_type := UPPER(p_type);

      --
      --  If we have a synonym then use that to resolve the owner/type.
      --
      IF l_owner IS NULL OR l_type IS NULL
      THEN
         BEGIN
            SELECT o.owner, o.object_type
              INTO l_owner, l_type
              FROM user_synonyms s INNER JOIN all_objects o ON (o.owner = s.table_owner AND o.object_name = s.table_name)
             WHERE     s.synonym_name = p_name
                   AND o.object_type NOT IN ('PACKAGE BODY', 'TYPE BODY')
                   AND (p_owner IS NULL OR o.owner = p_owner)
                   AND (p_type IS NULL OR o.object_type = p_type);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;
      END IF;

      --
      --  Look for public synonyms too
      --
      IF l_owner IS NULL OR l_type IS NULL
      THEN
         BEGIN
            SELECT o.owner, o.object_type
              INTO l_owner, l_type
              FROM all_synonyms s INNER JOIN all_objects o ON (o.owner = s.table_owner AND o.object_name = s.table_name)
             WHERE     s.owner = 'PUBLIC'
                   AND s.synonym_name = p_name
                   AND o.object_type NOT IN ('PACKAGE BODY', 'TYPE BODY')
                   AND (p_owner IS NULL OR o.owner = p_owner)
                   AND (p_type IS NULL OR o.object_type = p_type);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;
      END IF;

      --
      --  Otherwise just look at all_objects
      --
      IF l_owner IS NULL
      THEN
         BEGIN
            IF l_type IS NULL
            THEN
               WITH candidates
                    AS (SELECT owner, object_type
                          FROM all_objects
                         WHERE object_name = l_name AND object_type NOT LIKE '% BODY' AND object_type != 'SYNONYM'
                        ORDER BY CASE
                                    WHEN USER LIKE 'CLY%' AND owner = 'CLARITY'
                                    THEN
                                       1
                                    WHEN USER NOT LIKE 'CLY%' AND owner = 'ATLAS'
                                    THEN
                                       1
                                    WHEN owner IN ('ATLAS',
                                                   'CLARITY',
                                                   'PREMIER',
                                                   'WEB')
                                    THEN
                                       2
                                    ELSE
                                       3
                                 END)
               SELECT owner, object_type
                 INTO l_owner, l_type
                 FROM candidates
                WHERE ROWNUM = 1;
            ELSE
               WITH candidates
                    AS (SELECT owner
                          FROM all_objects
                         WHERE object_name = l_name AND object_type = l_type
                        ORDER BY CASE
                                    WHEN USER LIKE 'CLY%' AND owner = 'CLARITY'
                                    THEN
                                       1
                                    WHEN USER NOT LIKE 'CLY%' AND owner = 'ATLAS'
                                    THEN
                                       1
                                    WHEN owner IN ('ATLAS',
                                                   'CLARITY',
                                                   'PREMIER',
                                                   'WEB')
                                    THEN
                                       2
                                    ELSE
                                       3
                                 END)
               SELECT owner
                 INTO l_owner
                 FROM candidates
                WHERE ROWNUM = 1;
            END IF;
         END;
      ELSIF l_type IS NULL
      THEN
         SELECT object_type
           INTO l_type
           FROM all_objects
          WHERE owner = l_owner AND object_name = l_name AND object_type NOT LIKE '% BODY';
      END IF;

      p_owner := l_owner;
      p_type := l_type;
   END resolve_object;

   /**
   *  PROCEDURE retrieve_and_compile
   **/
   PROCEDURE retrieve_and_compile(p_name IN VARCHAR2, p_owner IN VARCHAR2, p_type IN VARCHAR2)
   IS
      l_lines        DBMS_SQL.varchar2a;
      l_cur_handle   NUMBER;
   BEGIN
      --
      -- Retrieve the source
      --
      SELECT text
        BULK COLLECT INTO l_lines
        FROM all_source
       WHERE owner = p_owner AND name = p_name AND TYPE = p_type
      ORDER BY line;

      IF (l_lines.COUNT > 0)
      THEN
         l_lines(1) := 'CREATE OR REPLACE ' || l_lines(1);

         l_cur_handle := DBMS_SQL.open_cursor();

         BEGIN
            DBMS_SQL.parse(c               => l_cur_handle,
                           statement       => l_lines,
                           lb              => 1,
                           ub              => l_lines.COUNT,
                           lfflg           => FALSE,
                           language_flag   => DBMS_SQL.native);

            DBMS_SQL.close_cursor(l_cur_handle);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_SQL.close_cursor(l_cur_handle);
               RAISE;
         END;
      END IF;
   END retrieve_and_compile;

   /**
   *  PROCEDURE import_code
   *
   *  Create the specified package, function or procedure in the current schema.
   **/
   PROCEDURE import_code(p_name IN VARCHAR2, p_owner IN VARCHAR2 DEFAULT NULL, p_type IN VARCHAR2 DEFAULT NULL)
   IS
      l_name           all_objects.object_name%TYPE;
      l_owner          all_objects.owner%TYPE;
      l_type           all_objects.object_type%TYPE;
      l_synonym_name   user_synonyms.synonym_name%TYPE;
   BEGIN
      assert.is_not_null(p_name, p_field => 'p_name');

      l_name := UPPER(p_name);
      l_owner := UPPER(p_owner);
      l_type := UPPER(p_type);

      IF l_type = 'PACKAGE BODY'
      THEN
         l_type := 'PACKAGE';
      ELSIF l_type = 'TYPE BODY'
      THEN
         l_type := 'TYPE';
      END IF;

      resolve_object(p_name => l_name, p_owner => l_owner, p_type => l_type);

      BEGIN
         SELECT synonym_name
           INTO l_synonym_name
           FROM user_synonyms
          WHERE synonym_name = l_name;

         EXECUTE IMMEDIATE 'DROP SYNONYM ' || l_synonym_name;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      retrieve_and_compile(p_owner => l_owner, p_type => l_type, p_name => l_name);

      IF l_type IN ('PACKAGE', 'TYPE')
      THEN
         l_type := l_type || ' BODY';
         retrieve_and_compile(p_owner => l_owner, p_type => l_type, p_name => l_name);
      END IF;
   END import_code;
END sql_pkg;
/