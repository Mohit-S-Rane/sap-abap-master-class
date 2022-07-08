*&---------------------------------------------------------------------*
*& Report ZABAP_INTERNAL_TABLE_OP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : zabap_internal_table_op
* Title            : ABAP Internal Table Operations
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_internal_table_op NO STANDARD PAGE HEADING.

TABLES: kna1.

TYPES: BEGIN OF ty_cust,
        cust(10) TYPE c,
        name(20) TYPE c,
        city(20) TYPE c,
      END OF ty_cust.

DATA: it_cust TYPE TABLE OF ty_cust,
      wa_cust LIKE LINE OF it_cust,
      it_cust_f TYPE TABLE OF ty_cust,
      wa_cust_f LIKE LINE OF it_cust.

SELECT
  kunnr
  name1
  ort01
  FROM kna1 INTO TABLE it_cust.


END-OF-SELECTION.
IF it_cust IS NOT INITIAL.
  LOOP AT it_cust INTO wa_cust.
    wa_cust_f-name = wa_cust-name.
    wa_cust_f-cust = wa_cust-cust.
    wa_cust_f-city = wa_cust-city.

********* APPEND **********
    APPEND wa_cust_f TO it_cust_f.
    CLEAR: wa_cust_f.
  ENDLOOP.

********* SORT **********
    SORT it_cust_f.
    SORT it_cust_f BY name.
    SORT it_cust_f BY name DESCENDING.

********* INSERT **********
  CLEAR: wa_cust_f.
  wa_cust_f-name = 'AXXXXX'.
  wa_cust_f-cust = 9999999999.
  wa_cust_f-city = 'PXXX'.
  INSERT wa_cust_f INTO it_cust_f INDEX 2.

********* CLEAR **********
  CLEAR: wa_cust_f.

********* Described Table **********
  DESCRIBE TABLE it_cust_f LINES DATA(lv_tab_count).
  WRITE:/ 'No of record available in table', lv_tab_count.

********* Delete Adjuacent Duplicate **********
  DELETE ADJACENT DUPLICATES FROM it_cust_f COMPARING name.

********* Delete **********
  DELETE it_cust_f INDEX 5.

********* Display Data **********
  LOOP AT it_cust_f INTO wa_cust_f.

********* Read Table **********
    READ TABLE it_cust INTO wa_cust WITH KEY cust = wa_cust_f-cust.
      IF sy-subrc IS INITIAL.
        AT FIRST.
        WRITE:/ 'This statement is used to read a record from Internal Table into workarea specified by either index number or key'.
        ENDAT.
      ENDIF.

    WRITE:/ wa_cust_f-cust,
    20 wa_cust_f-name,
    70 wa_cust_f-city.
  ENDLOOP.

********* FREE **********
  FREE: it_cust.
ENDIF.