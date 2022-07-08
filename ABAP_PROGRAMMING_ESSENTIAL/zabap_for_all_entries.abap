*&---------------------------------------------------------------------*
*& Report ZABAP_FOR_ALL_ENTRIES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_FOR_ALL_ENTRIES
* Title            : ABAP Table with For All Entries
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_for_all_entries NO STANDARD PAGE HEADING.

TABLES: lfa1, ekko.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_lifnr FOR lfa1-lifnr,
                  s_aedat FOR ekko-aedat.
SELECTION-SCREEN END OF BLOCK b1.

TYPES: BEGIN OF ty_lfa1,
        lifnr TYPE lifnr,
        name1 TYPE name1_gp,
       END OF ty_lfa1.

TYPES: BEGIN OF ty_ekko,
        lifnr TYPE lifnr,
        ebeln TYPE ebeln,
        aedat TYPE erdat,
        zterm TYPE dzterm,
       END OF ty_ekko.

TYPES: BEGIN OF ty_final,
        lifnr TYPE lifnr,
        name1 TYPE name1_gp,
        ebeln TYPE ebeln,
        aedat TYPE erdat,
        zterm TYPE dzterm,
       END OF ty_final.

DATA: it_lfa1 TYPE TABLE OF ty_lfa1,
      wa_lfa1 TYPE ty_lfa1,

      it_ekko TYPE TABLE OF ty_ekko,
      wa_ekko TYPE ty_ekko,

      it_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final.

START-OF-SELECTION.
  SELECT
    lifnr
    name1
    FROM lfa1 INTO TABLE it_lfa1
    WHERE lifnr IN s_lifnr.

  IF sy-subrc IS INITIAL.
    SELECT
      lifnr
      ebeln
      aedat
      zterm
      FROM ekko INTO TABLE it_ekko
      FOR ALL ENTRIES IN it_lfa1
      WHERE lifnr = it_lfa1-lifnr AND
            aedat IN s_aedat.

    IF sy-subrc IS INITIAL.
      SORT it_final BY lifnr.

      LOOP AT it_lfa1 INTO wa_lfa1.
        wa_final-lifnr = wa_lfa1-lifnr.
        wa_final-name1 = wa_lfa1-name1.

        READ TABLE it_ekko INTO wa_ekko WITH KEY lifnr = wa_lfa1-lifnr
                                                 aedat = wa_lfa1-name1.
          IF sy-subrc IS INITIAL.
            wa_final-ebeln = wa_ekko-ebeln.
            wa_final-aedat = wa_ekko-aedat.
            wa_final-zterm = wa_ekko-zterm.
          ENDIF.
          APPEND wa_final TO it_final.
        CLEAR: wa_lfa1, wa_ekko.
      ENDLOOP.

      LOOP AT it_final INTO wa_final.
        WRITE:/  wa_final-lifnr,
              20 wa_final-name1,
              55 wa_final-ebeln,
              70 wa_final-aedat,
              90 wa_final-zterm.
      ENDLOOP.
    ENDIF.
  ENDIF.