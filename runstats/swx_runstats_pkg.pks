CREATE OR REPLACE PACKAGE swx_runstats_pkg
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

   /**
   *
   * Indicate the minimum stat value of interest.
   *
   **/
   PROCEDURE set_stat_threshold (p_min_stat IN NUMBER);

   /**
   *
   * Indicate the minimum stat variation between snaps of interest.
   *
   **/
   PROCEDURE set_stat_delta_threshold (p_min_stat_delta IN NUMBER);

   /**
   *
   * Retrieve the stat threshold.
   *
   **/
   FUNCTION stat_threshold
      RETURN NUMBER;

   /**
   *
   * Retrieve the stat delta threshold.
   *
   **/
   FUNCTION stat_delta_threshold
      RETURN NUMBER;

   /**
   *
   * Discard existing snaps and set a new baseline. Call this immediately prior
   * to new runs/snaps so that the baseline is current.
   *
   **/
   PROCEDURE reset;

   /**
   *
   * Take a snapshot of the run stats. This records the current statistics
   * for comparison against baseilne statistics or earlier snaps.
   *
   **/
   PROCEDURE snap (p_run_name IN VARCHAR2 DEFAULT NULL);
END swx_runstats_pkg;
/