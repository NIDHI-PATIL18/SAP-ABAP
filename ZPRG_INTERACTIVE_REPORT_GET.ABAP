*&---------------------------------------------------------------------*
*& Report ZPRG_INTERACTIVE_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_interactive_report_get.

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

DATA : it_vbak      TYPE TABLE OF ty_vbak,
       wa_vbak      TYPE ty_vbak,
       it_vbap      TYPE TABLE OF ty_vbap,
       wa_vbap      TYPE ty_vbap,
       lv_vbeln     TYPE vbeln_va,
       lv_field(30) TYPE c,
       lv_value(30) TYPE c.


*display the header table data on basic list and item table data on secondary list.

SELECT-OPTIONS : s_vbeln FOR lv_vbeln.

START-OF-SELECTION.
  SELECT vbeln
    erdat    "recorde created date
    erzet    "Entry time
    ernam    "Name of person responsible
    vbtyp    "Document category
    waerk    "Document Currency
    vkorg    "Sales Organization
    FROM vbak
    INTO TABLE it_vbak
    WHERE vbeln IN s_vbeln.

*basic list creation

  LOOP AT it_vbak INTO wa_vbak.
    WRITE : / wa_vbak-vbeln , wa_vbak-erdat , wa_vbak-erzet , wa_vbak-ernam , wa_vbak-vbtyp ,
    wa_vbak-waerk , wa_vbak-vkorg.
  ENDLOOP.

AT LINE-SELECTION.

  GET CURSOR FIELD lv_field VALUE lv_value.

  IF lv_field = 'wa_vbak-vbeln'.

 CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = sy-lisel+0(10)
    IMPORTING
      output = sy-lisel+0(10).

    SELECT Vbeln
    posnr   "sales document item
    matnr   "Material Number
    matkl   "material Group
    FROM vbap
    INTO TABLE it_vbap
    WHERE vbeln = lv_value.
**
    LOOP AT it_vbap INTO wa_vbap.
      WRITE: / wa_vbap-vbeln , wa_vbap-posnr , wa_vbap-matnr ,
      wa_vbap-matkl.
    ENDLOOP.
  ENDIF.

*  IF lv_field = 'wa_vbak-erdat'.
*    WRITE : TEXT-000.
*  ENDIF.

  IF lv_field = 'wa_vbak-vbtyp'.
    IF lv_value = 'C'.
      WRITE : TEXT-001.
    ELSEIF lv_value = 'B'.
      WRITE : Text-002.
    ELSEIF lv_value = 'A'.
      WRITE : Text-003.
    ENDIF.
  ENDIF.
*
*  IF lv_field = 'wa_vbak-waerk'.
*    IF lv_value = 'USD'.
*      WRITE : Text-004.
*    ELSEIF lv_value = 'EUR'.
*      WRITE : Text-005.
*    ENDIF.
*  ENDIF.