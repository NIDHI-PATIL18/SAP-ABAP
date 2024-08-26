*&---------------------------------------------------------------------*
*& Report ZPRG_TEST_CASE_3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_test_case_3.

TABLES: mara, marc, makt, t001w, mard, mlan.

TYPES: BEGIN OF lty_material_details,
         "MARA - General Material Data.
         matnr TYPE mara-matnr,    "Material Number
*         ersda TYPE mara-ersda,    "Created On
         mtart TYPE mara-mtart,    "Material Type
         matkl TYPE mara-matkl,    "Material Group
         "MAKT - Material Descriptions.
         spras TYPE makt-spras,    "Language Key
         maktx TYPE makt-maktx,    "Material Description
         "MARC - Plant Data for Material.
         werks TYPE marc-werks,    "Plant
         "T001W - Plants/Branches.
         name1 TYPE t001w-name1,   "Plant description
         kunnr TYPE t001w-kUNNR,   "Customer Number of Plant
         ort01 TYPE t001w-ort01,   "City
         ekorg TYPE t001w-ekorg,   "Purchasing Organization
         vkorg TYPE t001w-vkorg,   "Sales Organization
         "MARD - Storage Location Data for Material.
         lgort TYPE mard-lgort,    "Storage Location
         "mlan - Tax Classification for Material
         aland TYPE mlan-aland,    "Departure Country/Region
       END OF lty_material_details,
       
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
         
         
       DATA: it_mat type table of lty_material_details,
             wa_mat type lty_material_details,
             it_final TYPE TABLE of lty_final,
             wa_final type lty_final,
             itab_field TYPE slis_t_fieldcat_alv,
             wa_field   TYPE slis_fieldcat_alv.
       
       SELECT-OPTIONS : s_matnr for mara-matnr,
                        s_matkl for mara-maktl,
                        s_mtart for mara-mtart,
                        s_werks for marc-werks,
                        s_name1 for t001w-name1.
       
       Select a~matnr
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
         from mara as a 
         inner join makt as b on a~matnr = b~matnr
         inner join marc as c on a~matnr = c~matnr
         inner join t001w as d on a~matnr = d~matnr
         inner join mard as e on a~matnr = e~matnr
         INNER JOIN mlan as f on a~matnr = f~matnr
         into table it_mat
         where a~matnr in s_matnr and
               a~mtart in s_mtart and  
               a~maktl in s_maktl and
               c~werks in s_werks and 
               d~name1 in s_name1.
               
               
      LOOP AT it_mat into wa_mat.
        
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