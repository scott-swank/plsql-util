CREATE OR REPLACE PACKAGE text
AS
   /*
      ==============================================================================
      PL/SQL PACKAGE text

      String manipulation and constants.

      Note that Barbara Boehmer's implementation of levenshtein_distance() has
      been removed. utl_match.edit_distance() should now be used.
      https://confluence.csiro.au/public/taxamatch/the-mdld-modified-damerau-levenshtein-distance-algorithm
      ------------------------------------------------------------------------------

      OPEN SOURCE ORACLE PL/SQL
      Version 0.6
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

   SUBTYPE max_varchar_t IS VARCHAR2(32767 CHAR);

   SUBTYPE max_sql_varchar_t IS VARCHAR2(4000 CHAR);

   SUBTYPE flag_t IS CHAR(1);

   concat_overflow             EXCEPTION;
   PRAGMA EXCEPTION_INIT(concat_overflow, -1489);

   max_varchar_size   CONSTANT PLS_INTEGER := 32767;
   cr                 CONSTANT CHAR(1) := CHR(13);
   lf                 CONSTANT CHAR(1) := CHR(10);
   crlf               CONSTANT CHAR(2) := cr || lf;
   eol                CONSTANT CHAR(2) := crlf;
   qt                 CONSTANT CHAR(1) := '''';
   dbl_qt             CONSTANT CHAR(1) := '"';
   tab                CONSTANT CHAR(1) := CHR(9);
   ampersand          CONSTANT CHAR(1) := CHR(38);

   true_flag          CONSTANT flag_t := 'T';
   false_flag         CONSTANT flag_t := 'F';
   yes_flag           CONSTANT flag_t := 'Y';
   no_flag            CONSTANT flag_t := 'N';

   /**
   *  FUNCTION split
   *
   *  Split the provided string into a table of tokens with resp. to the delimiter.
   **/
   FUNCTION split(p_text IN VARCHAR2, p_delimiter IN VARCHAR2 DEFAULT ',')
      RETURN text_nt;

   /**
   *  FUNCTION join
   *
   *  Concatenate the tokens with the supplied delimiter. Note that NULL tokens
   *  are ignored by default. This is to comport with LISTAGG.
   **/
   FUNCTION join(p_tokens IN text_nt, p_delimiter IN VARCHAR2 DEFAULT ',', p_ignore_nulls IN flag_t DEFAULT 'Y')
      RETURN VARCHAR2;

   /**
   *  FUNCTION to_char
   *
   *  Returns: 'TRUE', 'FALSE' or NULL.
   **/
   FUNCTION TO_CHAR(p_boolean IN BOOLEAN)
      RETURN VARCHAR2;

   /**
   *  FUNCTION to_tf
   *
   *  Returns 'T', 'F' or NULL
   **/
   FUNCTION to_tf(p_boolean IN BOOLEAN)
      RETURN flag_t;

   /**
   *  FUNCTION to_yn
   *
   *  Returns 'Y', 'N' or NULL
   **/
   FUNCTION to_yn(p_boolean IN BOOLEAN)
      RETURN flag_t;

   /**
   *  FUNCTION prefix
   **/
   FUNCTION prefix(p_text IN VARCHAR2, p_prefix_size IN PLS_INTEGER)
      RETURN VARCHAR2;

   /**
   *  FUNCTION suffix
   **/
   FUNCTION suffix(p_text IN VARCHAR2, p_suffix_size IN PLS_INTEGER)
      RETURN VARCHAR2;

   /**
   *  FUNCTION to_boolean
   *
   *  Returns TRUE for 'TRUE', 'T' or 'Y'
   *          FALSE for 'FALSE', 'F' or 'N'
   *          NULL otherwise
   *
   *  N.B. hence text.to_boolean('applesauce') returns NULL
   *
   *  If p_strict is specified as TRUE then any NULL results are rejected,
   *  resulting in an illegal_argument exception.
   **/
   FUNCTION to_boolean(p_text IN VARCHAR2, p_strict IN BOOLEAN DEFAULT FALSE)
      RETURN BOOLEAN;

   /**
   *  FUNCTION mask
   **/
   FUNCTION mask(p_text          IN VARCHAR2,
                 p_mask_char     IN VARCHAR2 DEFAULT '*',
                 p_prefix_size   IN PLS_INTEGER DEFAULT 0,
                 p_suffix_size   IN PLS_INTEGER DEFAULT 0)
      RETURN VARCHAR2;
END text;
/