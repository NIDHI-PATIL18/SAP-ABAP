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
         ekorg TYPE t001w-ekorg,   "Purchasing Organization
         vkorg TYPE t001w-vkorg,   "Sales Organization
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
         name1 TYPE t001w-name1,   "Plant description
         kunnr TYPE t001w-kUNNR,   "Customer Number of Plant
         ort01 TYPE t001w-ort01,   "City
         ekorg TYPE t001w-ekorg,   "Purchasing Organization
         vkorg TYPE t001w-vkorg,   "Sales Organization
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

  IF s_matnr IS NOT INITIAL.

    SELECT * FROM mara INTO CORRESPONDING FIELDS OF TABLE it_mara
      WHERE matnr = s_matnr.

    IF sy-subrc = 0.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE it_makt FROM makt
        WHERE matnr = wa_mara-matnr.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE it_marc
        FROM marc
        WHERE matnr = wa_mara-matnr.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE it_t001w
        FROM t001w
        WHERE werks = wa_marc-werks.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE it_mard
        FROM mard
        WHERE lgort = wa_marc-lgpro.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE it_mlan
        FROM mlan
        WHERE matnr = wa_mara-matnr.


      LOOP AT it_mara INTO wa_mara.
       IF sy-subrc = 0.
        READ TABLE it_makt INTO wa_makt
        WITH KEY matnr = wa_mara-matnr.
        IF sy-subrc = 0.
        APPEND wa_makt TO it_makt.

        READ TABLE it_marc INTO wa_marc
        WITH KEY matnr = wa_marc-matnr.
        IF sy-subrc = 0.
        APPEND wa_marc TO it_marc.

        READ TABLE it_t001w INTO wa_t001w
        WITH KEY werks = wa_marc-werks.
        IF sy-subrc = 0.
        APPEND wa_t001w TO it_t001w.

        READ TABLE it_mard INTO wa_mard
        WITH KEY lgort = wa_marc-lgpro.
        IF sy-subrc = 0.
        APPEND wa_mard TO it_mard.

        READ TABLE it_mlan INTO wa_mlan
        WITH KEY matnr = wa_mara-matnr.
        IF sy-subrc = 0.
        APPEND wa_mlan TO it_mlan.


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

*       wa_field-fieldname = 'EKORG'.
*       wa_field-seltext_l = 'Purchasing Organization'.
*       APPEND wa_field TO itab_field.
*       CLEAR wa_field.

      wa_field-fieldname = 'VKORG'.
      wa_field-seltext_l = 'Sales Organization'.
      APPEND wa_field TO itab_field.
      CLEAR wa_field.

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


    ENDIF.
  ENDIF.
  ENDIF.
ENDIF.
ENDIF.
ENDIF.

ENDLOOP.
endif.
endif.