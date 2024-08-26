*&---------------------------------------------------------------------*
*& Report ZPRG_TEST_CASE_4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPRG_TEST_CASE_4.

TABLES: mara, marc, makt, t001w, mard, mlan.

Types: BEGIN OF ty_data,
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
         ekorg TYPE t001w-ekorg,   "Purchasing Organization
         vkorg TYPE t001w-vkorg,   "Sales Organization
         lgort TYPE mard-lgort,    "Storage Location
         aland TYPE mlan-aland,    "Departure Country/Region
     END OF ty_data,
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

     DATA : it_data type table of ty_data,
            it_final   TYPE TABLE OF lty_final,
            itab_field TYPE slis_t_fieldcat_alv,
            wa_data type ty_data,
            wa_final   TYPE lty_final,
            wa_field   TYPE slis_fieldcat_alv.

    SELECT-OPTIONS:s_matnr FOR mara-matnr,
                   s_matkl FOR mara-matkl,
                   s_mtart FOR mara-mtart,
                   s_werks FOR marc-werks,
                   s_name1 FOR t001w-name1.


    start-of-SELECTION.
     select a~matnr
         a~mtart
         a~matkl
         b~spras
         b~maktx
         c~werks
         d~name1
         d~kunnr
         d~ort01
         d~ekorg
         d~vkorg
         e~lgort
         f~aland
         into table it_data
         from mara as a
         inner join makt as b on a~matnr = b~matnr
         inner join marc as c on a~matnr = c~matnr
         inner join t001w as d on c~werks = d~werks
         inner join mard as e on c~lgpro = e~lgort
         INNER JOIN mlan as f on a~matnr = f~matnr
         where a~matnr in s_matnr and
               a~mtart in s_mtart and
               a~matkl in s_matkl and
               c~werks in s_werks and
               d~name1 in s_name1.

       LOOP AT it_data into wa_data.

       wa_field-fieldname = 'matnr'.
       wa_field-seltext_l = 'material Number'.
       APPEND wa_field TO itab_field.
       CLEAR wa_field.

       wa_field-fieldname = 'Matkl'.
       wa_field-seltext_l = 'Material group'.
       APPEND wa_field TO itab_field.
       CLEAR wa_field.

       wa_field-fieldname = 'Mtart'.
       wa_field-seltext_l = 'Material type'.
       APPEND wa_field TO itab_field.
       CLEAR wa_field.

       wa_field-fieldname = 'werks'.
       wa_field-seltext_l = 'Plant'.
       APPEND wa_field TO itab_field.
       CLEAR wa_field.

       wa_field-fieldname = 'Maktx'.
       wa_field-seltext_l = 'Material Description'.
       APPEND wa_field TO itab_field.
       CLEAR wa_field.

       wa_field-fieldname = 'Name1'.
       wa_field-seltext_l = 'Plant description'.
       APPEND wa_field TO itab_field.
       CLEAR wa_field.

       wa_field-fieldname = 'EKORG'.
       wa_field-seltext_l = 'Purchasing Organization'.
       APPEND wa_field TO itab_field.
       CLEAR wa_field.

       wa_field-fieldname = 'VKORG'.
       wa_field-seltext_l = 'Sales Organization'.
       APPEND wa_field TO itab_field.
       CLEAR wa_field.

       wa_field-fieldname = 'ORT01'.
       wa_field-seltext_l = 'City'.
       APPEND wa_field TO itab_field.
       CLEAR wa_field.

       wa_field-fieldname = 'Kunnr'.
       wa_field-seltext_l = 'Customer number'.
       APPEND wa_field TO itab_field.
       CLEAR wa_field.

       ENDLOOP.