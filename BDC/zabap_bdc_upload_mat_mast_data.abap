*&---------------------------------------------------------------------*
*& Report ZABAP_BDC_UPLOAD_MAT_MAST_DATA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_BDC_UPLOAD_MAT_MAST_DATA
* Title            : ABAP BDC Upload Material Master Data using Call Transaction Method
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_bdc_upload_mat_mast_data NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_BDC_UPLOAD_MAT_MAST_DATA_TOP.
********************************************
TABLES: mara,makt,mseg.

TYPES: BEGIN OF ty_mm01,
        matnr TYPE matnr,
        mbrsh TYPE mbrsh,
        mtart TYPE mtart,
        maktx TYPE maktx,
        meins TYPE meins,
        matkl TYPE matkl,
        brgew TYPE brgew,
        gewei TYPE gewei,
        ntgew TYPE ntgew,
       END OF ty_mm01,

       BEGIN OF ty_error,
        record TYPE i,
        status TYPE string,
       END OF ty_error.

DATA: ls_mm01 TYPE ty_mm01,
      lt_mm01 TYPE TABLE OF ty_mm01,
      ls_bdc TYPE bdcdata,
      lt_bdc TYPE TABLE OF bdcdata,
      ls_msg TYPE bdcmsgcoll,
      lt_msg TYPE TABLE OF bdcmsgcoll,
      lt_raw TYPE truxs_t_text_data,
      ls_error TYPE ty_error,
      lt_error TYPE TABLE OF ty_error,
      s_fcat TYPE slis_fieldcat_alv,
      t_fcat TYPE slis_t_fieldcat_alv.

********************************************
*INCLUDE ZABAP_BDC_UPLOAD_MAT_MAST_DATA_SEL.
********************************************
SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  PARAMETERS p_file TYPE rlgrap-filename.
SELECTION-SCREEN:END OF BLOCK b1.

********************************************
*INCLUDE ZABAP_BDC_UPLOAD_MAT_MAST_DATA_F01.
********************************************
********************************************

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM open_file.

START-OF-SELECTION.
  PERFORM upload_file.
  PERFORM process_data.
  PERFORM process_error.

END-OF-SELECTION.
  PERFORM display_error.
*&---------------------------------------------------------------------*
*& Form OPEN_FILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM open_file .
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = p_file.

  IF sy-subrc <> 0.
    MESSAGE 'Error while uploading file' TYPE 'E'.
  ENDIF.
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
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header = ' '
      i_tab_raw_data = lt_raw
      i_filename = p_file TABLES
      i_tab_converted_data = lt_mm01.

  IF sy-subrc <> 0.
    MESSAGE 'Error while uploading excel sheet' TYPE 'E'.
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
DATA: v_brgew TYPE char15,
      v_ntgew TYPE char15.

LOOP AT lt_mm01 INTO ls_mm01.
  IF ls_mm01-brgew IS NOT INITIAL.
    v_brgew = ls_mm01-brgew.
    CONDENSE v_brgew.
  ENDIF.
  IF ls_mm01-ntgew IS NOT INITIAL.
    v_ntgew = ls_mm01-ntgew.
    CONDENSE v_ntgew.
  ENDIF.

  REFRESH lt_bdc.
  PERFORM bdc_dynpro USING 'SAPLMGMM' '0060'.
  PERFORM bdc_field USING 'BDC_CURSOR' 'RMMG1-MTART'.
  PERFORM bdc_field USING 'BDC_OKCODE' '=ENTR'.
  PERFORM bdc_field USING 'RMMG1-MATNR' ls_mm01-matnr.
  PERFORM bdc_field USING 'RMMG1-MBRSH' ls_mm01-mbrsh.
  PERFORM bdc_field USING 'RMMG1-MTART' ls_mm01-mtart.
  PERFORM bdc_dynpro USING 'SAPLMGMM' '0070'.
  PERFORM bdc_field USING 'BDC_CURSOR' 'MSICHTAUSW-DYTXT(02)'.
  PERFORM bdc_field USING 'BDC_OKCODE' '=ENTR'.
  PERFORM bdc_field USING 'MSICHTAUSW-KZSEL(01)' 'X'.
  PERFORM bdc_field USING 'MSICHTAUSW-KZSEL(02)' 'X'.
  PERFORM bdc_dynpro USING 'SAPLMGMM' '4004'.
  PERFORM bdc_field USING 'BDC_OKCODE' '=BU'.
  PERFORM bdc_field USING 'MAKT-MAKTX' ls_mm01-maktx.
  PERFORM bdc_field USING 'MARA-MEINS' ls_mm01-meins.
  PERFORM bdc_field USING 'MARA-MATKL' ls_mm01-matkl.
  PERFORM bdc_field USING 'BDC_CURSOR' 'MARA-GEWEI'.
  PERFORM bdc_field USING 'MARA-BRGEW' v_brgew.
  PERFORM bdc_field USING 'MARA-GEWEI' ls_mm01-gewei.
  PERFORM bdc_field USING 'MARA-NTGEW' v_ntgew.

  CALL TRANSACTION 'MM01' USING lt_bdc MODE 'E' UPDATE 'A' MESSAGES INTO lt_msg.
  IF sy-subrc NE 0.
    MESSAGE 'Error while processing the data' TYPE 'E'.
  ENDIF.
  CLEAR: v_brgew, v_ntgew, ls_mm01.
ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ERROR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_error .
DATA: v_text TYPE string,
      count TYPE i.

  LOOP AT lt_msg INTO ls_msg.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id = sy-msgid
        lang = '-D'
        no = ls_msg-msgnr
        v1 = ls_msg-msgv1
        v2 = ls_msg-msgv2
        v3 = ls_msg-msgv3
        v4 = ls_msg-msgv4
      IMPORTING
        msg = v_text.

    count = count + 1.
    ls_error-record = count.
    ls_error-status = v_text.
    APPEND ls_error TO lt_error.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ERROR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_error .
CLEAR s_fcat.
s_fcat-fieldname = 'RECORD'.
s_fcat-tabname = 'LT_ERROR'.
s_fcat-seltext_m = 'Ser.No.'.
s_fcat-outputlen = 7.
APPEND s_fcat TO t_fcat.

CLEAR s_fcat.
s_fcat-fieldname = 'STATUS'.
s_fcat-tabname = 'LT_ERROR'.
s_fcat-seltext_m = 'Message - Long Text'.
s_fcat-outputlen = 50.
APPEND s_fcat TO t_fcat.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program = sy-cprog
    it_fieldcat = t_fcat
  TABLES
    t_outtab = lt_error.
ENDFORM.
*&----------------------------------------------*
*&FormBDC_DYNPRO
*&-----------------------------------------------*
* text
*------------------------------------------------*
*-->P_0061text
*-->P_0062text
*--------------------------------------------*
FORM bdc_dynpro USING VALUE(p_0061) VALUE(p_0062).
CLEAR ls_bdc.
ls_bdc-program = p_0061.
ls_bdc-dynpro = p_0062.
ls_bdc-dynbegin = abap_true.
APPEND ls_bdc TO lt_bdc.
ENDFORM.
*&------------------------------------------------*
*&FormBDC_FIELD
*&------------------------------------------------*
* text
*----------------------------------------------*
*-->P_0066text
*-->P_0067text
*-----------------------------------------------*
FORM bdc_field USING VALUE(p_0066) VALUE(p_0067).
CLEAR ls_bdc.
ls_bdc-fnam = p_0066.
ls_bdc-fval = p_0067.
APPEND ls_bdc TO lt_bdc.
ENDFORM.