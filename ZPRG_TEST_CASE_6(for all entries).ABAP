*&---------------------------------------------------------------------*
*& Report ZPRG_TEST_CASE_3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_test_case_3.

TABLES: mara, marc, makt, t001w, mard, mlan.

TYPES: BEGIN OF lty_mara,          "MARA - General Material Data.
         matnr TYPE mara-matnr,    "Material Number
*         ersda TYPE mara-ersda,    "Created On
         mtart TYPE mara-mtart,    "Material Type
         matkl TYPE mara-matkl,    "Material Group
       END OF lty_mara,
       BEGIN OF lty_makt,          "MAKT - Material Descriptions.
         matnr TYPE makt-matnr,    "Material Number
         spras TYPE makt-spras,    "Language Key
         maktx TYPE makt-maktx,    "Material Description
       END OF lty_makt,
       BEGIN OF lty_marc,          "MARC - Plant Data for Material.
         matnr TYPE marc-matnr,    "Material Number
         werks TYPE marc-werks,    "Plant
         lgpro TYPE marc-lgpro,    "Issue Storage Location
       END OF lty_marc,
       BEGIN OF lty_t001w,         "T001W - Plants/Branches.
         werks TYPE t001w-werks,   "Plant
         name1 TYPE t001w-name1,   "Plant description
         kunnr TYPE t001w-kUNNR,   "Customer Number of Plant
         ort01 TYPE t001w-ort01,   "City
*         ekorg TYPE t001w-ekorg,   "Purchasing Organization
*         vkorg TYPE t001w-vkorg,   "Sales Organization
       END OF lty_t001w,
       BEGIN OF lty_mard,          "MARD - Storage Location Data for Material.
         lgort TYPE mard-lgort,    "Storage Location
       END OF lty_mard,
       BEGIN OF lty_mlan,          "mlan - Tax Classification for Material
         Matnr TYPE mlan-matnr,    "Material Number
         aland TYPE mlan-aland,    "Departure Country/Region
       END OF lty_mlan,

       BEGIN OF lty_final,
         matnr TYPE mara-matnr,    "Material Number
         mtart TYPE mara-mtart,    "Material Type
         matkl TYPE mara-matkl,    "Material Group
         spras TYPE makt-spras,    "Language Key
         maktx TYPE makt-maktx,    "Material Description
         werks TYPE marc-werks,    "plant
         lgpro TYPE marc-lgpro,    "Issue Storage Location
         name1 TYPE t001w-name1,   "Plant description
         kunnr TYPE t001w-kUNNR,   "Customer Number of Plant
         ort01 TYPE t001w-ort01,   "City
*         ekorg TYPE t001w-ekorg,   "Purchasing Organization
*         vkorg TYPE t001w-vkorg,   "Sales Organization
         lgort TYPE mard-lgort,    "Storage Location
         aland TYPE mlan-aland,    "Departure Country/Region
       END OF lty_final.


DATA: it_mara    TYPE TABLE OF lty_mara,
      it_makt    TYPE TABLE OF lty_makt,
      it_marc    TYPE TABLE OF lty_marc,
      it_t001w   TYPE TABLE OF lty_t001w,
      it_mard    TYPE TABLE OF lty_mard,
      it_mlan    TYPE TABLE OF lty_mlan,
      it_final   TYPE TABLE OF lty_final,
      itab_field TYPE slis_t_fieldcat_alv,
      wa_mara    TYPE lty_mara,
      wa_makt    TYPE lty_makt,
      wa_marc    TYPE lty_marc,
      wa_t001w   TYPE lty_t001w,
      wa_mard    TYPE lty_mard,
      wa_mlan    TYPE lty_mlan,
      wa_final   TYPE lty_final,
      wa_field   TYPE slis_fieldcat_alv.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.

  SELECT-OPTIONS : s_matnr FOR mara-matnr,
                   s_matkl FOR mara-matkl,
                   s_mtart FOR mara-mtart,
                   s_werks FOR marc-werks,
                   s_name1 FOR t001w-name1.

SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

  SELECT matnr
  matkl
  mtart
  FROM mara
  INTO TABLE it_mara
  WHERE matnr IN s_matnr AND
        matkl IN s_matkl AND
        mtart IN s_mtart.

  IF it_mara IS NOT INITIAL.
    SELECT matnr
      spras
      maktx
      FROM makt
      INTO TABLE it_makt
      FOR ALL ENTRIES IN it_mara
      WHERE matnr = it_mara-matnr and
      spras = sy-langu.
  ENDIF.

  IF it_makt IS NOT INITIAL.
    SELECT matnr
      werks
      lgpro
      FROM marc
      INTO TABLE it_marc
      FOR ALL ENTRIES IN it_mara
      WHERE matnr = it_mara-matnr.
  ENDIF.

  IF it_marc IS NOT INITIAL.
    SELECT werks
      name1
      kunnr
      ort01
*      ekorg
*      vkorg
      FROM t001w
      INTO TABLE it_t001w
      FOR ALL ENTRIES IN it_marc
      WHERE werks = it_marc-werks.
  ENDIF.

  IF it_t001w IS NOT INITIAL.
    SELECT lgort
      FROM mard
      INTO TABLE it_mard
      FOR ALL ENTRIES IN it_marc
      WHERE lgort = it_marc-lgpro.
  ENDIF.

  IF it_mard IS NOT INITIAL.
    SELECT
      matnr
      aland
      FROM mlan
      INTO TABLE it_mlan
      FOR ALL ENTRIES IN it_mara
      WHERE matnr = it_mara-matnr.
  ENDIF.

  LOOP AT it_mara INTO wa_mara.
    wa_final-matnr = wa_mara-matnr.
    wa_final-mtart = wa_mara-mtart.
    wa_final-matkl = wa_mara-matkl.
    READ TABLE it_makt INTO wa_makt
    WITH KEY matnr = wa_mara-matnr.
    wa_final-spras = wa_makt-spras.
    wa_final-maktx = wa_makt-maktx.
    READ TABLE it_marc INTO wa_marc
    WITH KEY matnr = wa_mara-matnr.
    wa_final-werks = wa_marc-werks.
    wa_final-lgpro = wa_marc-lgpro.
    READ TABLE it_t001w INTO wa_t001w
    WITH KEY werks = wa_MARC-werks.
    wa_final-name1 = wa_t001w-name1.
    wa_final-kunnr = wa_t001w-kunnr.
    wa_final-ort01 = wa_t001w-ort01.
*    wa_final-ekorg = wa_t001w-ekorg.
*    wa_final-vkorg = wa_t001w-vkorg.
    READ TABLE it_mard INTO wa_mard
    WITH KEY lgort = wa_marc-lgpro.
    wa_final-lgort = wa_mard-lgort.
    READ TABLE it_mlan INTO wa_mlan
    WITH KEY matnr = wa_mara-matnr.
    wa_final-aland = wa_mlan-aland.
    APPEND wa_final TO it_final.
    CLEAR: wa_final.
  ENDLOOP.


  wa_field-fieldname = 'matnr'.
  wa_field-seltext_l = 'material Number'.
  APPEND wa_field TO itab_field.
  CLEAR wa_field.

  wa_field-fieldname = 'Mtart'.
  wa_field-seltext_l = 'Material type'.
  APPEND wa_field TO itab_field.
  CLEAR wa_field.

  wa_field-fieldname = 'Matkl'.
  wa_field-seltext_l = 'Material group'.
  APPEND wa_field TO itab_field.
  CLEAR wa_field.

  wa_field-fieldname = 'Spras'.
  wa_field-seltext_l = 'Language Key'.
  APPEND wa_field TO itab_field.
  CLEAR wa_field.

  wa_field-fieldname = 'Maktx'.
  wa_field-seltext_l = 'Material Description'.
  APPEND wa_field TO itab_field.
  CLEAR wa_field.

  wa_field-fieldname = 'werks'.
  wa_field-seltext_l = 'Plant'.
  APPEND wa_field TO itab_field.
  CLEAR wa_field.

  wa_field-fieldname = 'Lgpro'.
  wa_field-seltext_l = 'Issue Storage Location'.
  APPEND wa_field TO itab_field.
  CLEAR wa_field.

  wa_field-fieldname = 'Name1'.
  wa_field-seltext_l = 'Plant description'.
  APPEND wa_field TO itab_field.
  CLEAR wa_field.

  wa_field-fieldname = 'Kunnr'.
  wa_field-seltext_l = 'Customer number'.
  APPEND wa_field TO itab_field.
  CLEAR wa_field.

  wa_field-fieldname = 'ORT01'.
  wa_field-seltext_l = 'City'.
  APPEND wa_field TO itab_field.
  CLEAR wa_field.

*  wa_field-fieldname = 'EKORG'.
*  wa_field-seltext_l = 'Purchasing Organization'.
*  APPEND wa_field TO itab_field.
*  CLEAR wa_field.
*
*  wa_field-fieldname = 'VKORG'.
*  wa_field-seltext_l = 'Sales Organization'.
*  APPEND wa_field TO itab_field.
*  CLEAR wa_field.

  wa_field-fieldname = 'IGORT'.
  wa_field-seltext_l = 'Storage Location'.
  APPEND wa_field TO itab_field.
  CLEAR wa_field.

  wa_field-fieldname = 'ALAND'.
  wa_field-seltext_l = 'Departure Country/Region'.
  APPEND wa_field TO itab_field.
  CLEAR wa_field.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = 'ZPRG_TEST_CASE_3 '
      it_fieldcat        = itab_field
    TABLES
      t_outtab           = it_final.