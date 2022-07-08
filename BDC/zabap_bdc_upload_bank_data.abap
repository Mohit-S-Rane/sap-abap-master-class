*&---------------------------------------------------------------------*
*& Report ZABAP_BDC_UPLOAD_BANK_DATA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_BDC_UPLOAD_BANK_DATA
* Title            : ABAP BDC Upload Bank Details using Session Method
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_bdc_upload_bank_data NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_BDC_UPLOAD_BANK_DATA_TOP.
********************************************
TABLES: bnka.

TYPES: BEGIN OF ty_fi01,
        banks TYPE banks,
        bankl TYPE bankl,
        banka TYPE banka,
        stras TYPE stras_gp,
        ort01 TYPE ort01_gp,
        brnch TYPE brnch,
       END OF ty_fi01.

DATA: ls_fi01 TYPE ty_fi01,
      lt_fi01 TYPE TABLE OF ty_fi01,
      ls_bdc TYPE bdcdata,
      lt_bdc TYPE TABLE OF bdcdata.
********************************************
*INCLUDE ZABAP_BDC_UPLOAD_BANK_DATA_SEL.
********************************************
SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  PARAMETERS: p_file TYPE rlgrap-filename.
SELECTION-SCREEN:END OF BLOCK b1.
********************************************
*INCLUDE ZABAP_BDC_UPLOAD_BANK_DATA_F01.
********************************************
********************************************

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM open_file.

START-OF-SELECTION.
  PERFORM upload_file.
  PERFORM open_session.
  PERFORM process_data.
  PERFORM close_session.
*&---------------------------------------------------------------------*
*& Form OPEN_FILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM open_file .
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    CHANGING
      file_name = p_file.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPLOAD_FILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_file .
  DATA: fnam TYPE string.

  fnam = p_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename = fnam
      filetype = 'ASC' has_field_separator = 'X'
    TABLES
      data_tab = lt_fi01.

  IF sy-subrc <> 0.
    MESSAGE 'Error while uploading the file' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form OPEN_SESSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM open_session .
  CALL FUNCTION 'BDC_OPEN_GROUP'
    EXPORTING
      client = sy-mandt group = 'RMZ'
      keep = 'X'
      user = sy-uname.

  IF sy-subrc <> 0.
    MESSAGE 'Error while opening the session' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data .
LOOP AT lt_fi01 INTO ls_fi01.
  REFRESH lt_bdc.
  PERFORM bdc_dynpro USING 'SAPMF02B' '0100'.
  PERFORM bdc_field USING 'BDC_CURSOR' 'BNKA-BANKL'.
  PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field USING 'BNKA-BANKS' ls_fi01-banks.
  PERFORM bdc_field USING 'BNKA-BANKL' ls_fi01-bankl.
  PERFORM bdc_dynpro USING 'SAPMF02B' '0110'.
  PERFORM bdc_field USING 'BDC_CURSOR' 'BNKA-BRNCH'.
  PERFORM bdc_field USING 'BDC_OKCODE' '=UPDA'.
  PERFORM bdc_field USING 'BNKA-BANKA' ls_fi01-banka.
  PERFORM bdc_field USING 'BNKA-STRAS' ls_fi01-stras.
  PERFORM bdc_field USING 'BNKA-ORT01' ls_fi01-ort01.
  PERFORM bdc_field USING 'BNKA-BRNCH' ls_fi01-brnch.

  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode = 'FI01'
    TABLES
      dynprotab = lt_bdc.

  IF sy-subrc <> 0.
    MESSAGE 'Error while processing the data into ses sion' TYPE 'E'.
  ENDIF.
ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLOSE_SESSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM close_session .
  CALL FUNCTION 'BDC_CLOSE_GROUP'.
  IF sy-subrc EQ 0.
    MESSAGE 'File uploaded successfully' TYPE 'S' DISPLAY LIKE 'I'.
  ENDIF.
ENDFORM.

FORM bdc_dynpro USING VALUE(p_0087) VALUE(p_0088).
  CLEAR ls_bdc.
  ls_bdc-program = p_0087.
  ls_bdc-dynpro = p_0088.
  ls_bdc-dynbegin = 'X'.
  APPEND ls_bdc TO lt_bdc.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM bdc_field USING VALUE(p_0092) VALUE(p_0093).
CLEAR ls_bdc.
ls_bdc-fnam = p_0092.
ls_bdc-fval = p_0093.
APPEND ls_bdc TO lt_bdc.
ENDFORM.