*&---------------------------------------------------------------------*
*& Report ZPRG_TEST_CASE_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_test_case_2.

************************************************************************
"without for all entries. 
TABLES: vbak, vbap, vbep.

TYPES:
  BEGIN OF Lty_sales,
    vbeln	    TYPE vbak-vbeln,
    erdat     TYPE vbak-erdat,
    auart	    TYPE vbak-auart,
    kunnr	    TYPE vbak-kunnr,
    netwr	    TYPE vbak-netwr,
    kunwe_ana TYPE vbap-kunwe_ana,
    kunre_ana TYPE vbap-kunre_ana,
    kunrg_ana TYPE vbap-kunrg_ana,
    wadat	    TYPE vbep-wadat,
    repos	    TYPE vbep-repos,
  END OF Lty_sales.

DATA: IT_sales   TYPE TABLE OF LTY_sales,
      WA_sales   TYPE LTY_sales,
      itab_field TYPE slis_t_fieldcat_alv,
      wa_field   TYPE slis_fieldcat_alv.

SELECT-OPTIONS : s_vbeln FOR vbak-vbeln.

SELECT a~vbeln
      a~erdat
      a~auart
      a~kunnr
      a~netwr
      b~kunwe_ana
      b~kunre_ana
      b~kunrg_ana
      c~wadat
      c~repos
 FROM vbak AS a
 INNER JOIN vbap AS b ON a~vbeln = b~vbeln
 INNER JOIN vbep AS c ON b~vbeln = c~vbeln AND  b~posnr = c~posnr
  INTO TABLE it_sales
 WHERE a~vbeln IN s_vbeln.



LOOP AT it_sales INTO wa_sales.
*write:/ wa_sales-vbeln, wa_sales-erdat, wa_sales-auart, wa_sales-kunnr, wa_sales-netwr, wa_sales-kunwe_ana,
*wa_sales-kunre_ana, wa_sales-kunrg_ana, wa_sales-wadat, wa_sales-repos.

wa_field-fieldname = 'vbeln'.
wa_field-seltext_l = 'Sales Document'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'erdat'.
wa_field-seltext_l = 'Record Created On'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'auart'.
wa_field-seltext_l = 'Sales Document Type'.
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

wa_field-fieldname = 'KUNWE_ANA'.
wa_field-seltext_l = 'Ship-to Party'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'KUNRE_ANA'.
wa_field-seltext_l = 'Bill-to Party'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'KUNRG_ANA'.
wa_field-seltext_l = 'Payer'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'WADAT'.
wa_field-seltext_l = 'Goods Issue Date'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

wa_field-fieldname = 'REPOS'.
wa_field-seltext_l = 'Invoice Receipt Indicator'.
APPEND wa_field TO itab_field.
CLEAR wa_field.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program = 'ZPRG_TEST_CASE_1 '
    it_fieldcat        = itab_field
  TABLES
    t_outtab           = it_sales.
    
ENDLOOP.