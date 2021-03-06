*&---------------------------------------------------------------------*
*& Report  ZSEND_EMAIL_ATTACHMENT
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZSEND_EMAIL_ATTACHMENT
* Title            : ABAP Send Email Attachment
*&---------------------------------------------------------------------*

REPORT zsend_email_attachment.


CONSTANTS:
  gc_subject     TYPE so_obj_des VALUE 'ABAP Email (attachment) with CL_BCS', " Email subject
  gc_email_to    TYPE adr6-smtp_addr VALUE 'admin@gmail.com', " Valid email
  gc_text        TYPE soli VALUE 'Hello world! My first ABAP email with attachment!', " Text used into the email body
  gc_type_raw    TYPE so_obj_tp VALUE 'RAW', " Email type
  gc_att_type    TYPE soodk-objtp VALUE 'PDF', " Attachment type
  gc_att_subject TYPE sood-objdes VALUE 'Document in PDF'. " Attachment title

DATA:
  gt_text           TYPE soli_tab, " Table which contains email body text
  gt_attachment_hex TYPE solix_tab, " Table which contains the attached file
  gv_sent_to_all    TYPE os_boolean, " Receive the information if email was sent
  gv_error_message  TYPE string, " Used to get the error message
  go_send_request   TYPE REF TO cl_bcs, " Email object
  go_recipient      TYPE REF TO if_recipient_bcs, " Who will receive the email
  go_sender         TYPE REF TO cl_sapuser_bcs, " Who is sending the email
  go_document       TYPE REF TO cl_document_bcs, " Email body
  gx_bcs_exception  TYPE REF TO cx_bcs.


TRY.
    go_send_request = cl_bcs=>create_persistent( ).

    go_sender = cl_sapuser_bcs=>create( sy-uname ).

    go_send_request->set_sender( i_sender = go_sender ).

    go_recipient = cl_cam_address_bcs=>create_internet_address( gc_email_to ).

    go_send_request->add_recipient(
      EXPORTING
        i_recipient = go_recipient
        i_express   = abap_true
    ).

    "Email BODY
    APPEND gc_text TO gt_text.
    go_document = cl_document_bcs=>create_document(
                    i_type    = gc_type_raw
                    i_text    = gt_text
                    i_length  = '12'
                    i_subject = gc_subject ).

    go_document->add_attachment(
      EXPORTING
        i_attachment_type    = gc_att_type
        i_attachment_subject = gc_att_subject
        i_att_content_hex    = gt_attachment_hex
    ).

    go_send_request->set_document( go_document ).

    gv_sent_to_all = go_send_request->send( i_with_error_screen = abap_true ).
    IF gv_sent_to_all = abap_true.
      WRITE 'Email sent!'.
    ENDIF.

    COMMIT WORK.

  CATCH cx_bcs INTO gx_bcs_exception.
    gv_error_message = gx_bcs_exception->get_text( ).
    WRITE gv_error_message.
ENDTRY.