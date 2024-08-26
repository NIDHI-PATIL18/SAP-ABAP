TABLES: mara, marc, makt, t001w, mard, mlan.

TYPES: BEGIN OF ty_data,
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
END OF ty_data.

DATA: it_data    TYPE TABLE OF ty_data,
wa_data     TYPE ty_data,
itab_field TYPE slis_t_fieldcat_alv,
wa_field   TYPE slis_fieldcat_alv.

SELECT-OPTIONS : s_matnr FOR mara-matnr,
                   s_matkl FOR mara-matkl,
                   s_mtart FOR mara-mtart,
                   s_werks FOR marc-werks,
                   s_name1 FOR t001w-name1.

                   ELECT matnr
                   mtart
                   matkl
                   FROM mara
                   into table it_data
                   WHERE matnr in s_matnr and
                         matkl in s_matkl and
                         mtart in s_mtart.
             
                   SELECT Spras
                     maktx
                     FROM makt
                     into table it_data
                     WHERE matnr = mara-matnr and
                           spras = sy-langu.
             
                   SELECT werks
                     lgpro
                     FROM marc
                     into table it_data
                     WHERE matnr = mara-matnr and
                           werks in s_werks.
             
                   SELECT name1
                     kunnr
                     ort01
                     ekorg
                     vkorg
                     FROM t001w
                     into table it_data
                     WHERE werks = marc-werks and
                            Name1 in s_name1.

                   SELECT lgort
                     FROM mard
                     into table it_data
                     WHERE lgort = marc-lgpro.
             
                   SELECT aland
                     FROM mlan
                     into table it_data
                     WHERE matnr = mara-matnr.
             
             
                   LOOP AT it_data INTO wa_data.
                    APPEND wa_data to it_data.
             
             
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
                       t_outtab           = it_data.
             ENDLOOP.

             matnr     
         mtart     
         matkl 
         spras   
         maktx     
         werks    
         name1 
         kunnr    
         ort01   
         ekorg   
         vkorg  
         lgort   
         aland   