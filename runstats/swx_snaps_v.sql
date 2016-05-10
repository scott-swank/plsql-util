CREATE OR REPLACE VIEW swx_snaps_v
AS
/*
   ==============================================================================
   PL/SQL VIEW swx_snaps_v

   View of the 6 most recent stats snapshots.

   Based on the sql*plus script runstats by Tom Kyte.
   asktom.oracle.com
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
   SELECT s.*,
          AVG (max_stat) OVER (PARTITION BY stat_type) AS avg_stat,
          AVG (max_stat - min_stat) OVER (PARTITION BY stat_type)
             AS avg_stat_delta
     FROM (  SELECT stat_type,
                    name,
                    MAX (DECODE (runid, 1, stat)) AS snap1,
                    MAX (DECODE (runid, 2, stat)) AS snap2,
                    MAX (DECODE (runid, 3, stat)) AS snap3,
                    MAX (DECODE (runid, 4, stat)) AS snap4,
                    MAX (DECODE (runid, 5, stat)) AS snap5,
                    MAX (DECODE (runid, 6, stat)) AS snap6,
                    MIN (stat) AS min_stat,
                    MAX (stat) AS max_stat
               FROM (SELECT stat_type,
                            name,
                            runid,
                            run_name,
                              VALUE
                            - LAG (
                                 VALUE)
                              OVER (PARTITION BY stat_type, name
                                    ORDER BY runid)
                               AS stat
                       FROM swx_run_stats)
              WHERE runid > 0
           GROUP BY stat_type, name
             HAVING MAX (stat) > 0) s
/

CREATE OR REPLACE VIEW swx_snaps2_v
AS
/*
   ==============================================================================
   PL/SQL VIEW swx_snaps2_v

   View comparing the first two stats snapshots.

   Based on the sql*plus script runstats by Tom Kyte.
   asktom.oracle.com
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
   SELECT stat_type,
          name,
          snap1,
          snap2,
          ROUND (
             CASE
                WHEN snap1 > 0 THEN snap2 / snap1
                WHEN snap2 > 0 THEN 9.9999999999999999999999999999999999999e+125 -- infinity
                ELSE 0
             END, 2) AS ratio,
          snap2 - snap1 AS diff
     FROM swx_snaps_v
    WHERE    max_stat >= NVL (swx_runstats_pkg.stat_threshold (), avg_stat)
          OR (max_stat - min_stat) >= NVL (swx_runstats_pkg.stat_delta_threshold (), avg_stat_delta)
          OR stat_type = 'TIME'
/

CREATE SYNONYM snaps_v FOR swx_snaps_v;
CREATE SYNONYM snaps2_v FOR swx_snaps2_v;
