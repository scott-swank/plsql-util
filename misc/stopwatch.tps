CREATE OR REPLACE TYPE stopwatch AS OBJECT
/*
   ==============================================================================
   PL/SQL TYPE stopwatch

   Timing facility with 1/100 second granularity.
   ------------------------------------------------------------------------------

   OPEN SOURCE ORACLE PL/SQL
   Version 0.2
   Copyright (C) 2003-2016 Scott Swank  scott.swank@gmail.com

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
   
   http://www.gnu.org/licenses/gpl-3.0.en.html
   ==============================================================================
*/
(
   start_hsec INTEGER,
   split_hsec INTEGER,
   stop_hsec INTEGER,
   --
   --
   --
   /**
   *  CONSTRUCTOR FUNCTION stopwatch
   *
   *  Create a stopwatch
   **/
   CONSTRUCTOR FUNCTION stopwatch
      RETURN SELF AS RESULT,
   --
   --
   --
   /**
   *  PROCEDURE start_timing
   *
   *  Begin timing, clear any previous state.
   **/
   MEMBER PROCEDURE start_timing(SELF IN OUT stopwatch),
   --
   /**
   *  FUNCTION split
   *
   *  Return the seconds since the split began -- either start_timing() or the most recent split().
   *  Returns NULL and otherwise does nothing if start_timing() has not been called, or has
   *  not been called since the most recent call to stop().
   **/
   MEMBER FUNCTION split(SELF IN OUT stopwatch)
      RETURN NUMBER,
   --
   /**
    *  PROCEDURE unsplit
    *
    *  Remove any splits. Revert to the start time.
    **/
   MEMBER PROCEDURE unsplit(SELF IN OUT stopwatch),
   --
   /**
    *  FUNCTION stop_timing
    *
    *  Stop timing. Return the seconds since start, or the most recent split.
    *  Use unsplit() first if split timing is not desired.
    *  Returns NULL and otherwise does nothing if start_timing() has not been called, or has
    *  not been called since the most recent call to stop().
    **/
   MEMBER FUNCTION stop_timing(SELF IN OUT stopwatch)
      RETURN NUMBER,
   --
   /**
    *  FUNCTION total
    *
    *  Return the seconds since start_timing() was called through the current
    *  time or whenever stop_timing() was called. Ignore any splits.
    **/
   MEMBER FUNCTION total(SELF IN OUT stopwatch)
      RETURN NUMBER
)
/