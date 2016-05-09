CREATE TABLE swx_log_level
(
   lvl    NUMBER,
   name   VARCHAR2(30 CHAR) CONSTRAINT nn_ll_n NOT NULL,
   CONSTRAINT swx_ll_pk PRIMARY KEY(lvl)
)
ORGANIZATION INDEX
TABLESPACE atlas_index
/

CREATE TABLE swx_log_config
(
   module        VARCHAR2(200 CHAR),                                                                         -- pkg.proc.nested_proc
   log_level     NUMBER CONSTRAINT nn_lc_ll NOT NULL,
   sample_rate   NUMBER DEFAULT 1,
   CONSTRAINT swx_log_config_pk PRIMARY KEY(module),
   CONSTRAINT swx_log_config_level_fk FOREIGN KEY(log_level) REFERENCES swx_log_level
)
ORGANIZATION INDEX
TABLESPACE atlas_index
/

-- only for the fk

CREATE INDEX swx_log_config_level_idx
   ON swx_log_config(log_level)
   TABLESPACE atlas_index
/

CREATE TABLE swx_log
(
   entry_date    DATE DEFAULT SYSDATE NOT NULL,
   username      VARCHAR2(30 CHAR) DEFAULT USER NOT NULL,
   module        VARCHAR2(64 CHAR) NOT NULL,
   action        VARCHAR2(64 CHAR),
   client_info   VARCHAR2(64 CHAR),
   text          VARCHAR2(4000 CHAR) NOT NULL
)
TABLESPACE premdat
/