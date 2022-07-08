*&---------------------------------------------------------------------*
*& Report ZABAP_INNER_JOIN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : zabap_inner_join
* Title            : ABAP Table Inner Join
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_inner_join NO STANDARD PAGE HEADING.

TABLES: lfa1, ekko.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_lifnr FOR lfa1-lifnr,
                  s_aedat FOR ekko-aedat.
SELECTION-SCREEN END OF BLOCK b1.

TYPES: BEGIN OF ty_final,
        lifnr TYPE lifnr,
        name1 TYPE name1_gp,
        ebeln TYPE ebeln,
        aedat TYPE erdat,
        zterm TYPE dzterm,
       END OF ty_final.

DATA: it_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final.

START-OF-SELECTION.

  SELECT
    a~lifnr
    a~name1
    b~ebeln
    b~aedat
    b~zterm
    INTO TABLE it_final
    FROM lfa1 AS a INNER JOIN ekko AS b
    ON a~lifnr = b~lifnr
    WHERE a~lifnr IN s_lifnr AND
          b~aedat IN s_aedat.

  IF sy-subrc IS INITIAL.
    SORT it_final BY lifnr.

    LOOP AT it_final INTO wa_final.
      WRITE:/  wa_final-lifnr,
            20 wa_final-name1,
            55 wa_final-ebeln,
            70 wa_final-aedat,
            90 wa_final-zterm.
    ENDLOOP.

  ENDIF.