*&---------------------------------------------------------------------*
*& Report ZABAP_MPP_STUDENT_AI_SCREEN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_MPP_STUDENT_AI_SCREEN
* Title            : ABAP MPP Student AI Screen
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_mpp_student_ai_screen NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_MPP_STUDENT_AI_SCREEN_TOP.
*************************************
TABLES zystudent_rep.
DATA: ls_std TYPE zystudent_rep.
*************************************

CALL SCREEN 1000.
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
  MOVE: ls_std-roll_no TO zystudent_rep-roll_no,
        ls_std-f_name TO zystudent_rep-f_name,
        ls_std-l_name TO zystudent_rep-l_name,
        ls_std-ia_1 TO zystudent_rep-ia_1,
        ls_std-ia_2 TO zystudent_rep-ia_2,
        ls_std-ia_3 TO zystudent_rep-ia_3,
        ls_std-avg1 TO zystudent_rep-avg1.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  CASE sy-ucomm.
    WHEN 'INSERT'.
      MOVE zystudent_rep TO ls_std.
      IF ( ls_std-ia_1 IS NOT INITIAL AND ls_std-ia_2 IS NOT INITIAL AND ls_std-ia_3 IS NOT INITIAL ).
        ls_std-avg1 = ( ls_std-ia_1 + ls_std-ia_2 + ls_std-ia_3 ) / 3.
      ENDIF.

      INSERT INTO zystudent_rep VALUES ls_std.
      IF sy-subrc EQ 0.
        MESSAGE 'Record inserted successfully' TYPE 'S'.
      ENDIF.

    WHEN 'UPDATE'.
      MOVE zystudent_rep TO ls_std.
      UPDATE zystudent_rep FROM ls_std.
      IF sy-subrc EQ 0.
        MESSAGE 'Record updated successfully' TYPE 'S'.
      ELSE.
        MESSAGE 'Record not updated' TYPE 'S'.
      ENDIF.

    WHEN 'DELETE'.
      MOVE zystudent_rep TO ls_std.
      DELETE FROM zystudent_rep WHERE roll_no = ls_std-roll_no.
      IF sy-subrc EQ 0.
        MESSAGE 'Record deleted successfully' TYPE 'S'.
      ELSE.
        MESSAGE 'Deletion Failed' TYPE 'S'.
      ENDIF.

    WHEN 'CANCEL'.
      LEAVE PROGRAM.

    WHEN 'DISPLAY'.
      SELECT SINGLE *
        FROM zystudent_rep INTO ls_std
        WHERE roll_no = zystudent_rep-roll_no.

      IF sy-subrc NE 0.
        MESSAGE 'Record does not exist' TYPE 'E'.
      ENDIF.
  ENDCASE.
ENDMODULE.