*&---------------------------------------------------------------------*
*& Report ZPRG_INTERACTIVE_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_interactive_report_top.

TABLES : Vbak.

TYPES: BEGIN OF ty_Vbak,
         vbeln TYPE vbeln_va,
         erdat TYPE erdat,
         erzet TYPE erzet,
         ernam TYPE ernam,
         vbtyp TYPE vbtypl,
         waerk TYPE waerk,
         vkorg TYPE vkorg,
       END OF ty_Vbak.

TYPES : BEGIN OF ty_vbap,
          vbeln TYPE vbeln_va,
          posnr TYPE posnr_va,
          matnr TYPE matnr,
          matkl TYPE matkl,
        END OF ty_vbap.

DATA : it_vbak  TYPE TABLE OF ty_vbak,
       wa_vbak  TYPE ty_vbak,
       it_vbap  TYPE TABLE OF ty_vbap,
       wa_vbap  TYPE ty_vbap,
       lv_vbeln TYPE vbeln_va.


*display the header table data on basic list and item table data on secondary list.

SELECT-OPTIONS : s_vbeln FOR lv_vbeln.

START-OF-SELECTION.
  SELECT vbeln
    erdat
    erzet
     ernam
    vbtyp
    waerk
    vkorg
    FROM vbak
    INTO TABLE it_vbak
    WHERE vbeln IN s_vbeln.


*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    EXPORTING
*      input  = sy-lisel+0(10)
*    IMPORTING
*      output = sy-lisel+0(10).

  LOOP AT it_vbak INTO wa_vbak.
    WRITE : / wa_vbak-vbeln, wa_vbak-erdat, wa_vbak-erzet, wa_vbak-ernam, wa_vbak-vbtyp,
    wa_vbak-waerk, wa_vbak-vkorg.
  ENDLOOP.

AT LINE-SELECTION.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = sy-lisel+0(10)
    IMPORTING
      output = sy-lisel+0(10).

  SELECT Vbeln
  posnr
  matnr
  matkl
  FROM vbap
  INTO TABLE it_vbap
  WHERE vbeln = sy-lisel+0(10).

  LOOP AT it_vbap INTO wa_vbap.
    WRITE: / wa_vbap-vbeln , wa_vbap-posnr , wa_vbap-matnr ,
    wa_vbap-matkl.
  ENDLOOP.

  TOP-OF-PAGE.
  WRITE : / TEXT-008.

  TOP-OF-PAGE DURING LINE-SELECTION.
  WRITE : / TEXT-009, SY-LISEL+0(10).