*&---------------------------------------------------------------------*
*& Report ZPRG_TEST_CASE_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_test_case_1.
"with for all entries.
TABLES :vbak, vbap, vbep.

TYPES: BEGIN OF lty_sales,
         vbeln     TYPE vbeln_va,
         erdat     TYPE erdat,
         auart     TYPE auart,
         kunnr     TYPE kunag,
         netwr     TYPE netwr_ak,
         posnr     TYPE posnr_va,
         kunwe_ana TYPE kunwe,
         kunre_ana TYPE kunre,
         kunrg_ana TYPE kunrg,
         types ,
       END OF Lty_sales,

       BEGIN OF Lty_vbep,
         vbeln TYPE vbeln_va,
         posnr TYPE posnr_va,
         wadat TYPE wadat,
         repos TYPE repos,
       END OF Lty_vbep,

       BEGIN OF Lty_FINAL,
         vbeln     TYPE vbeln_va,
         erdat     TYPE erdat,
         auart     TYPE auart,
         kunnr     TYPE kunag,
         netwr     TYPE netwr_ak,
         posnr     TYPE posnr_va,
         kunwe_ana TYPE kunwe,
         kunre_ana TYPE kunre,
         kunrg_ana TYPE kunrg,
*         posnr     TYPE posnr_va,
         wadat     TYPE wadat,
         repos     TYPE repos,
       END OF Lty_FINAL.

DATA: it_Sales   TYPE TABLE OF lty_Sales,
      wa_Sales   TYPE lty_Sales,
      it_vbep    TYPE TABLE OF lty_vbep,
      wa_vbep    TYPE lty_vbep,
      it_final   TYPE TABLE OF lty_final,
      wa_final   TYPE lty_final,
      itab_field TYPE slis_t_fieldcat_alv,
      wa_field   TYPE slis_fieldcat_alv.

SELECT-OPTIONS: s_vbeln FOR vbak-vbeln.

SELECT vbak~vbeln
        vbak~erdat
        vbak~auart
        vbak~kunnr
        vbak~netwr
        Vbap~posnr
        Vbap~kunwe_ana
        Vbap~kunre_ana
        Vbap~kunrg_ana
   FROM vbak  JOIN vbap ON vbak~vbeln = Vbap~vbeln
   INTO TABLE it_sales
   WHERE vbak~vbeln IN s_vbeln.

SELECT
  vbeln
  posnr
  wadat
repos
FROM vbep
INTO TABLE it_vbep
for all ENTRIES IN it_sales
WHERE vbeln = it_sales-vbeln AND
  posnr = it_sales-posnr.

LOOP AT it_sales INTO wa_sales.
  READ TABLE it_vbep INTO wa_vbep
  WITH KEY vbeln = wa_sales-vbeln.
*  posnr = wa_sales-posnr.
  wa_final-vbeln = wa_sales-vbeln.
  wa_final-erdat = wa_sales-erdat.
  wa_final-auart = wa_sales-auart.
  wa_final-kunnr = wa_sales-kunnr.
  wa_final-netwr = wa_sales-netwr .
  wa_final-posnr = wa_sales-posnr .
  wa_final-kunwe_ana = wa_sales-kunwe_ana .
  wa_final-kunre_ana = wa_sales-kunre_ana .
  wa_final-kunrg_ana = wa_sales-kunrg_ana .
*  wa_final-posnr     = wa_vbep-posnr .
  wa_final-wadat     = wa_vbep-wadat .
  wa_final-repos     = wa_vbep-repos .
  APPEND wa_final TO it_final.
  CLEAR : wa_final.
ENDLOOP.

wa_field-fieldname = 'vbeln'.
wa_field-seltext_l = 'Sales Document'.
*  wa_field-hotspot   = 'X'.
*  wa_field-emphasize = 'C4'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'erdat'.
wa_field-seltext_l = 'Record Created On'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'auart'.
wa_field-seltext_l = 'Sales Document Type'.
*  wa_field-emphasize = 'C4'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'kunnr'.
wa_field-seltext_l = 'Sold-to Party'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'Netwr'.
wa_field-seltext_l = 'Net Value'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

*  wa_field-fieldname = 'posnr'.
*  wa_field-seltext_l = 'Sales Document Item'.
**  wa_field-emphasize = 'C4'.
*  APPEND wa_field TO itab_field.
*  CLEAR wa_field.

wa_field-fieldname = 'KUNWE_ANA'.
wa_field-seltext_l = 'Ship-to Party'.
*  wa_field-emphasize = 'C4'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'KUNRE_ANA'.
wa_field-seltext_l = 'Bill-to Party'.
*  wa_field-emphasize = 'C4'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'KUNRG_ANA'.
wa_field-seltext_l = 'Payer'.
*  wa_field-emphasize = 'C4'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'WADAT'.
wa_field-seltext_l = 'Goods Issue Date'.
*  wa_field-emphasize = 'C4'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'REPOS'.
wa_field-seltext_l = 'Invoice Receipt Indicator'.
*  wa_field-emphasize = 'C4'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program = 'ZPRG_TEST_CASE_1 '
    it_fieldcat        = itab_field
  TABLES
    t_outtab           = it_final.