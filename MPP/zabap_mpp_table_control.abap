*&---------------------------------------------------------------------*
*& Report ZABAP_MPP_TABLE_CONTROL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_MPP_TABLE_CONTROL
* Title            : ABAP MPP Table Control
* Description      : Display Table control screen with selection screen which maintains the data in custom table.
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_mpp_table_control NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_MPP_TABLE_CONTROL_TOP.
*********************************************************
TABLES: zyemployee, sscrfields.

TYPES: BEGIN OF t_emp,
        sel TYPE c.
        INCLUDE STRUCTURE zyemployee.
TYPES: END OF t_emp.

DATA: ls_emp TYPE t_emp,
      lt_emp TYPE TABLE OF t_emp.

***********************************************************

*INCLUDE ZABAP_MPP_TABLE_CONTROL_SEL.
*********************************************************
SELECTION-SCREEN:BEGIN OF LINE.
  SELECTION-SCREEN:PUSHBUTTON (10) button1 USER-COMMAND add,
                   PUSHBUTTON (10) button2 USER-COMMAND dis.
SELECTION-SCREEN:END OF LINE.

SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  SELECT-OPTIONS:emp_no FOR zyemployee-emp_no.
SELECTION-SCREEN:END OF BLOCK b1.
***********************************************************

INITIALIZATION.
  button1 = 'Addnew'.
  button2 = 'Display'.

AT SELECTION-SCREEN.
  IF sscrfields-ucomm = 'ADD'.
    CALL SCREEN 5011.
  ENDIF.

  IF sscrfields-ucomm = 'DIS'.
    sscrfields-ucomm = 'ONLI'.
  ENDIF.

START-OF-SELECTION.
  SELECT *
    FROM zyemployee INTO TABLE lt_emp
    WHERE emp_no IN emp_no.

  LOOP AT lt_emp INTO ls_emp.
    MOVE: ls_emp-emp_no TO zyemployee-emp_no,
          ls_emp-emp_fnam TO zyemployee-emp_fnam,
          ls_emp-emp_lnam TO zyemployee-emp_lnam,
          ls_emp-gen TO zyemployee-gen,
          ls_emp-dob TO zyemployee-dob,
          ls_emp-e_level TO zyemployee-e_level,
          ls_emp-skill TO zyemployee-skill,
          ls_emp-mobile TO ls_emp-mobile.
  ENDLOOP.

  CALL SCREEN 5011.
*&---------------------------------------------------------------------*
*& Module STATUS_5011 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_5011 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  SET PF-STATUS 'ZYBUTTON'.
  SET TITLEBAR 'ZYEMPLOYEE_TITLE'.
  CASE sy-ucomm.
    WHEN 'DIS'.
      LOOP AT SCREEN.
        IF screen-name = 'LS_EMP-EMP_NO' OR
           screen-name = 'LS_EMP-EMP_FNAM' OR screen-name ='LS_EMP-EMP_LNAM' OR screen-name = 'LS_EMP-GEN' OR
           screen-name = 'LS_EMP-DOB' OR
           screen-name = 'LS_EMP-E_LEVEL' OR
           screen-name = 'LS_EMP-SKILL' OR
           screen-name = 'LS_EMP-MOBILE'.
            screen-input = 0.
            MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_5011  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_5011 INPUT.
  CASE sy-ucomm.
    WHEN 'REFRESH'.
      REFRESH lt_emp.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL' OR 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.