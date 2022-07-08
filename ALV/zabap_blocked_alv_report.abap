*&---------------------------------------------------------------------*
*& Report ZABAP_BLOCKED_ALV_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_BLOCKED_ALV_REPORT
* Title            : ABAP Blocked ALV Report
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_blocked_alv_report NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_BLOCKED_ALV_REPORT_TOP.
***********************************************
TABLES: lfa1,ekko,ekpo.

DATA: BEGIN OF lt_lfa1 OCCURS 0,
        lifnr LIKE lfa1-lifnr,
        name1 LIKE lfa1-name1,
        ort01 LIKE lfa1-ort01,
      END OF lt_lfa1,

      BEGIN OF lt_ekko OCCURS 0,
        ebeln LIKE ekko-ebeln,
        aedat LIKE ekko-aedat,
        zterm LIKE ekko-zterm,
        lifnr LIKE ekko-lifnr,
      END OF lt_ekko,

      BEGIN OF lt_ekpo OCCURS 0,
        ebeln LIKE ekko-ebeln,
        ebelp LIKE ekpo-ebelp,
        matnr LIKE ekpo-matnr,
        menge LIKE ekpo-menge,
        meins LIKE ekpo-meins,
        netpr LIKE ekpo-netpr,
      END OF lt_ekpo.

DATA: t_fcat TYPE slis_t_fieldcat_alv,
      w_layout TYPE slis_layout_alv,
      t_event TYPE slis_t_event.
***********************************************
*INCLUDE ZABAP_BLOCKED_ALV_REPORT_SEL.
***********************************************
SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  SELECT-OPTIONS: s_lifnr FOR lfa1-lifnr,
                  s_aedat FOR ekko-aedat.
SELECTION-SCREEN:END OF BLOCK b1.
***********************************************
*INCLUDE ZABAP_BLOCKED_ALV_REPORT_FORM.
***********************************************
***********************************************

START-OF-SELECTION.
  PERFORM block_init.
  PERFORM block_append1.
  PERFORM block_append2.
  PERFORM block_display.
*&---------------------------------------------------------------------*
*& Form BLOCK_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM block_init .
  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_INIT'
    EXPORTING
      i_callback_program = sy-cprog.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BLOCK_APPEND1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM block_append1 .
  SELECT *
    FROM lfa1
    INTO CORRESPONDING FIELDS OF TABLE lt_lfa1 UP TO 15 ROWS
    WHERE lifnr IN s_lifnr.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name = sy-cprog
      i_internal_tabname = 'LT_LFA1'
      i_inclname = sy-cprog
    CHANGING
      ct_fieldcat = t_fcat.

  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
    EXPORTING
      is_layout = w_layout
      it_fieldcat = t_fcat
      i_tabname = 'LT_LFA1'
      it_events = t_event
    TABLES
      t_outtab = lt_lfa1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BLOCK_APPEND2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM block_append2 .
  IF lt_lfa1[] IS NOT INITIAL.
    SELECT *
      FROM ekko
      INTO CORRESPONDING FIELDS OF TABLE lt_ekko
      FOR ALL ENTRIES IN lt_lfa1
      WHERE lifnr = lt_lfa1-lifnr AND
            aedat IN s_aedat.
  ENDIF.
  REFRESH t_fcat.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name = sy-cprog
      i_internal_tabname = 'LT_EKKO'
      i_inclname = sy-cprog
    CHANGING
      ct_fieldcat = t_fcat.

  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
    EXPORTING
      is_layout = w_layout
      it_fieldcat = t_fcat
      i_tabname = 'LT_EKKO'
      it_events = t_event
    TABLES
      t_outtab = lt_ekko.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BLOCK_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM block_display .
  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_DISPLAY'.
ENDFORM.