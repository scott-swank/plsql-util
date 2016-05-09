INSERT INTO swx_log_level
     VALUES (0, 'Off');

INSERT INTO swx_log_level
     VALUES (1, 'Fatal');

INSERT INTO swx_log_level
     VALUES (2, 'Error');

INSERT INTO swx_log_level
     VALUES (3, 'Warn');

INSERT INTO swx_log_level
     VALUES (4, 'Info');

INSERT INTO swx_log_level
     VALUES (5, 'Debug');

INSERT INTO swx_log_level
     VALUES (6, 'Trace');

-- we'll set up anonymous pl/sql blocks at Info
INSERT INTO swx_log_config
     VALUES ('__anonymous_block', 4);

COMMIT
/