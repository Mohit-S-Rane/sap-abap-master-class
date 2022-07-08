*&---------------------------------------------------------------------*
*& Report ZABAP_INTERNAL_TABLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : zabap_internal_table
* Title            : ABAP Use of Internal Table
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*

REPORT zabap_internal_table NO STANDARD PAGE HEADING.

TABLES: kna1.

TYPES: BEGIN OF ty_cust,
        cust(10) TYPE c,
        name(20) TYPE c,
        city(20) TYPE c,
      END OF ty_cust.

DATA: it_cust TYPE TABLE OF ty_cust,
      wa_cust LIKE LINE OF it_cust.

SELECT
  kunnr
  name1
  ort01
  FROM kna1 INTO TABLE it_cust.


END-OF-SELECTION.
IF it_cust IS NOT INITIAL.
  LOOP AT it_cust INTO wa_cust.
    WRITE:/ wa_cust-cust,
    20 wa_cust-name,
    70 wa_cust-city.
  ENDLOOP.
ENDIF.