CREATE OR REPLACE PACKAGE BODY swx_runstats_pkg
AS
/*
   ==============================================================================
   PL/SQL PACKAGE swx_runstats_pkg

   Record snapshots of statistics to allow comparisons of their
   performance signatures.

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
   g_runid                  NUMBER DEFAULT 0;
   g_stat_threshold         NUMBER DEFAULT NULL;
   g_stat_delta_threshold   NUMBER DEFAULT NULL;


   PROCEDURE set_stat_threshold (p_min_stat IN NUMBER)
   IS
   BEGIN
      g_stat_threshold := p_min_stat;
   END set_stat_threshold;


   PROCEDURE set_stat_delta_threshold (p_min_stat_delta IN NUMBER)
   IS
   BEGIN
      g_stat_delta_threshold := p_min_stat_delta;
   END set_stat_delta_threshold;

   FUNCTION stat_threshold
      RETURN NUMBER
   IS
   BEGIN
      RETURN g_stat_threshold;
   END stat_threshold;

   FUNCTION stat_delta_threshold
      RETURN NUMBER
   IS
   BEGIN
      RETURN g_stat_delta_threshold;
   END stat_delta_threshold;

   PROCEDURE insert_stats (p_run_name IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      INSERT INTO swx_run_stats (runid,
                                 run_name,
                                 stat_type,
                                 NAME,
                                 VALUE)
         SELECT g_runid,
                NVL (p_run_name, 'Run ' || g_runid),
                s.stat_type,
                s.NAME,
                s.VALUE
           FROM swx_stats_v s;
   END insert_stats;

   PROCEDURE reset
   IS
   BEGIN
      DELETE FROM swx_run_stats;

      g_runid := 0;
      insert_stats ('Baseline');
   END RESET;

   PROCEDURE snap (p_run_name IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      g_runid := g_runid + 1;
      insert_stats (p_run_name);
   END snap;
END swx_runstats_pkg;
/