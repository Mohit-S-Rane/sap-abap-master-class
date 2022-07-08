*&---------------------------------------------------------------------*
*& Report ZABAP_MPP_EMPLOYEE_BASIC_D
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_MPP_EMPLOYEE_BASIC_D
* Title            : ABAP MPP Employee Basic Details
* Description      : Display Employee basic details and salary details with multiple tabs using global subscreen area.
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_mpp_employee_basic_d NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_MPP_EMPLOYEE_BASIC_D_TOP.
*********************************************************
TABLES: pa0002,pa0008.

TYPES: BEGIN OF ty_sal,
        pernr TYPE persno,
        bet01 TYPE pad_amt7s,
        bet02 TYPE pad_amt7s,
        bet03 TYPE pad_amt7s,
       END OF ty_sal.

DATA: BEGIN OF ls_emp,
       rufnm TYPE smnam,
       gbdat TYPE gbdat,
       age TYPE i,
      END OF ls_emp.

DATA: ls_sal TYPE ty_sal,
      lt_sal TYPE TABLE OF ty_sal,
      lc_x LIKE sy-dynnr VALUE '51',
      io_age TYPE i.

CONTROLS: sal TYPE TABLEVIEW USING SCREEN 52,
          emp TYPE TABSTRIP.
***********************************************************

CALL SCREEN 1000.
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
  MOVE: ls_emp-rufnm TO pa0002-rufnm,
        ls_emp-gbdat TO pa0002-gbdat,
        ls_emp-age TO io_age.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  DATA v_dbcnt TYPE sy-dbcnt.

  CASE sy-ucomm.
    WHEN 'DISPLAY'.
      SELECT SINGLE
        rufnm
        gbdat
        FROM pa0002 INTO ls_emp
        WHERE pernr = pa0008-pernr.

      CALL FUNCTION 'HR_RU_AGE_YEARS'
        EXPORTING
          pernr = pa0008-pernr bsdte = sy-datum IMPORTING
          value = ls_emp-age.

      SELECT
        pernr
        bet01
        bet02
        bet03
        FROM pa0008 INTO TABLE lt_sal
        WHERE pernr = pa0008-pernr.

      v_dbcnt = sy-dbcnt.

    WHEN 'TAB1'.
      lc_x = '51'.
      emp-activetab = 'TAB1'.

    WHEN 'TAB2'.
      lc_x = '52'.
      emp-activetab = 'TAB2'.

    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_2000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_2000 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
  MOVE: ls_sal-pernr TO pa0008-pernr,
        ls_sal-bet01 TO pa0008-bet01,
        ls_sal-bet02 TO pa0008-bet02,
        ls_sal-bet03 TO pa0008-bet03.

  sal-lines = v_dbcnt.
ENDMODULE.