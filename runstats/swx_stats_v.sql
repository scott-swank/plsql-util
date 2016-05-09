CREATE OR REPLACE VIEW swx_stats_v
AS
/*
   ==============================================================================
   PL/SQL VIEW swx_stats_v

   A composite view of latches, stats and timer.
   ------------------------------------------------------------------------------

   OPEN SOURCE ORACLE PL/SQL
   Version 0.8
   Copyright (C) 2003-2015 Scott Swank  scott.swank@gmail.com

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
   ==============================================================================
*/
   SELECT 'LATCH' AS stat_type, name, gets AS value FROM v$latch
   UNION ALL
   SELECT 'STAT', sn.name, s.VALUE
     FROM v$statname sn
          INNER JOIN v$mystat s ON (s.statistic# = sn.statistic#)
   UNION ALL
   SELECT 'TIME', 'hsecs', hsecs FROM v$timer
   ;

DROP TABLE swx_run_stats;

CREATE GLOBAL TEMPORARY TABLE swx_run_stats
(
   runid       NUMBER,
   run_name    VARCHAR2 (15),
   stat_type   VARCHAR2 (5),
   name        VARCHAR2 (80),
   VALUE       INT
) ON COMMIT PRESERVE ROWS;