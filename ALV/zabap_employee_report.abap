*&---------------------------------------------------------------------*
*& Report ZABAP_EMPLOYEE_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_EMPLOYEE_REPORT
* Title            : ABAP Employee Report
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_employee_report NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_EMPLOYEE_REPORT_TOP.
****************************************
TABLES: pernr,pa0000.

TYPES: BEGIN OF ty_hr_emp,
        pernr  TYPE pernr_d,
        sname  TYPE sname,
        age(3) TYPE c,
       END OF ty_hr_emp.

DATA: ls_emp TYPE ty_hr_emp,
      lt_emp TYPE TABLE OF ty_hr_emp,
      v_age TYPE i.
****************************************
*INCLUDE ZABAP_EMPLOYEE_REPORT_SEL.
****************************************
SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  SELECT-OPTIONS s_pernr FOR pernr-pernr.
SELECTION-SCREEN:END OF BLOCK b1.
****************************************
*INCLUDE ZABAP_EMPLOYEE_REPORT_FORM.
****************************************
****************************************

START-OF-SELECTION.
*  GET PERNR.
*  CHECK PERNR-PERNR IN S_PERNR.

  IF sy-subrc EQ 0.
    PERFORM get_data.
  ENDIF.

END-OF-SELECTION.
  PERFORM display_data.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  ls_emp-pernr = pernr-pernr.
  ls_emp-sname = pernr-sname.

  CALL FUNCTION 'HR_RU_AGE_YEARS'
    EXPORTING
      pernr = pernr-pernr
      bsdte = sy-datum
    IMPORTING
      value = v_age.
      ls_emp-age = v_age.

  APPEND ls_emp TO lt_emp.
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
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-CPROG
      I_STRUCTURE_NAME = 'TY_HR_EMP'
    TABLES
      T_OUTTAB = LT_EMP.
ENDFORM.