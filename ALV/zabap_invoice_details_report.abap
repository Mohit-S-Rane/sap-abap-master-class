*&---------------------------------------------------------------------*
*& Report ZABAP_INVOICE_DETAILS_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_INVOICE_DETAILS_REPORT
* Title            : ABAP Invoice Details Report
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_invoice_details_report NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_INVOICE_DETAILS_REPORT_TOP.
**********************************************
TABLES: rbkp,rseg.

TYPES: BEGIN OF zrbkp_s1,
        belnr TYPE re_belnr,
        budat TYPE budat,
        rmwwr TYPE rmwwr,
       END OF zrbkp_s1,

       BEGIN OF zrseg_s1,
        belnr TYPE belnr_d,
        ebeln TYPE ebeln,
        ebelp TYPE ebelp,
        matnr TYPE matnr,
        menge TYPE menge,
        meins TYPE meins,
        wrbtr TYPE wrbtr,
       END OF zrseg_s1.

DATA: it_rbkp TYPE TABLE OF rbkp,
      it_rseg TYPE TABLE OF rseg.
**********************************************
*INCLUDE ZABAP_INVOICE_DETAILS_REPORT_SEL.
**********************************************
SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  SELECT-OPTIONS: s_belnr FOR rbkp-belnr,
                  s_budat FOR rbkp-budat.
SELECTION-SCREEN:END OF BLOCK b1.

SELECTION-SCREEN:BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-001.
  PARAMETERS: r_rbkp RADIOBUTTON GROUP inv,
              r_rseg RADIOBUTTON GROUP inv.
SELECTION-SCREEN:END OF BLOCK b2.
**********************************************
*INCLUDE ZABAP_INVOICE_DETAILS_REPORT_F01.
**********************************************
**********************************************

START-OF-SELECTION.
PERFORM get_data.
PERFORM display_data.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  SELECT *
*    belnr
*    budat
*    rmwwr
    FROM rbkp INTO TABLE it_rbkp
    WHERE belnr IN s_belnr AND
          budat IN s_budat.

  IF it_rbkp[] IS NOT INITIAL.
    SELECT *
*      belnr
*      ebelp
*      matnr
*      menge
*      meins
*      wrbtr
      FROM rseg INTO TABLE it_rseg
      FOR ALL ENTRIES IN it_rbkp
      WHERE belnr = it_rbkp-belnr.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .
  IF r_rbkp = 'X'.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-cprog
        i_structure_name = 'RBKP'
      TABLES
        t_outtab = it_rbkp.
  ENDIF.
  IF r_rseg = 'X'.
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = sy-cprog
        i_structure_name = 'RSEG'
      TABLES
        t_outtab = it_rseg.
  ENDIF.
ENDFORM.