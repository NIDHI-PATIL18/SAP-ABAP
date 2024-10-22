*&---------------------------------------------------------------------*
*& Include          ZTC_PRACTICE_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF lstr_vbak,                             "vbak strcture
         sel_flag TYPE char1,
         vbeln    TYPE Vbak-vbeln,
         erdat    TYPE vbak-erdat,
         vbtyp    TYPE vbak-vbtyp,
       END OF lstr_vbak.

TYPES: BEGIN OF lstr_variant,                         "variant strcture
         sel_flag TYPE char1,
         vbeln    TYPE vbak-vbeln,
         varia    TYPE char10,
         varf_n   TYPE char50,
         vbtyp    TYPE vbak-vbtyp,
       END OF lstr_variant.

TYPES: BEGIN OF lstr_filter,                          "Filter Structure
         sel_flag TYPE char1,
         vbeln    TYPE Vbak-vbeln,
         erdat    TYPE vbak-erdat,
         vbtyp    TYPE vbak-vbtyp,
       END OF lstr_filter.

TYPES: BEGIN OF lstr_old_variant_names,              "Old variant names structure
         varia TYPE char10,
         vbeln TYPE vbak-vbeln,
       END OF lstr_old_variant_names.

TYPES: BEGIN OF lstr_multiple_variant_def,           "multiple variant definition Structure
         sel_flag TYPE char1,
         vbeln    TYPE Vbak-vbeln,
         varia    TYPE char10,
         varf_n   TYPE char50,
         erdat    TYPE vbak-erdat,
         netwr    TYPE vbak-netwr,
         vbtyp    TYPE vbak-vbtyp,
       END OF lstr_multiple_variant_def.

DATA: gt_vbak TYPE TABLE OF lstr_vbak,                "vbak internal table
      gs_vbak TYPE lstr_vbak.

DATA: gt_variant_data TYPE TABLE OF lstr_variant,     "variant internal table
      gs_variant_data TYPE lstr_variant.


DATA: gt_temp_main_data TYPE TABLE OF lstr_filter,    "temp internal table for main data.
      gs_temp_main_data TYPE lstr_filter.

DATA: gt_multiple_variant_def TYPE TABLE OF lstr_multiple_variant_def,            "multiple variant definition internal table
      gs_multiple_variant_def TYPE lstr_multiple_variant_def.

DATA: lv_multi_variant_netwr TYPE vbak-netwr.                   "Used for recalculating NETWR on multiple variant definition screen.

DATA: gs_multiple_variant     TYPE lstr_multiple_variant_def.                     "WorkArea used Screen fields of Screen 0200

DATA: gv_netwr TYPE vbak-netwr.                       "Global variable for 'Total Count' Used in screen 0200.

DATA: gv_sales_doc_no TYPE vbak-vbeln,                "Drop down for Sales doc number
      gv_doc_type     TYPE vbak-vbtyp.                "Drop down for documnet type

DATA: gv_old_salesdoc_no   TYPE vbak-vbeln,
      gv_old_salesdoc_type TYPE vbak-vbtyp.

DATA: gt_old_variant_names TYPE TABLE OF lstr_old_variant_names,               "Table for old vairant names used for vaildation of previous name and current name in single variant defintion internal table
      gs_old_variant_names TYPE lstr_old_variant_names.

DATA: gt_old_variant_names_model_db TYPE TABLE OF lstr_old_variant_names,      "Table for old vairant names used for vaildation of previous name and current name in model dialoge box.
      gs_old_variant_names_model_db TYPE lstr_old_variant_names.

DATA: gv_flag_for_filter_update TYPE char1.          "flag for filter update.

DATA: lv_multivar_scr_firstrun_flg TYPE char1.

DATA: gv_popup_return TYPE char1.                   "popup for confirmation of record deletion.

DATA: gv_del_rec_flag_mdbx  TYPE char1,              "flag for deletion of record in Model Dialoge box screen.
      gv_total_count_flg    TYPE char1.              "Total count flag will be 'X' if Total count and Netwr are not same.
*&SPWIZARD: DECLARATION OF TABLECONTROL 'ZTC_DISPLAY' ITSELF
CONTROLS: ztc_display TYPE TABLEVIEW USING SCREEN 0100.

*&SPWIZARD: LINES OF TABLECONTROL 'ZTC_DISPLAY'
DATA:     g_ztc_display_lines  LIKE sy-loopc.

DATA:     ok_code LIKE sy-ucomm.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'ZTC_EDIT_VAR' ITSELF
CONTROLS: ztc_edit_var TYPE TABLEVIEW USING SCREEN 0100.

*&SPWIZARD: LINES OF TABLECONTROL 'ZTC_EDIT_VAR'
DATA:     g_ztc_edit_var_lines  LIKE sy-loopc.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'ZTC_MULTI_VAR' ITSELF
CONTROLS: ZTC_MULTI_VAR TYPE TABLEVIEW USING SCREEN 0200.

*&SPWIZARD: LINES OF TABLECONTROL 'ZTC_MULTI_VAR'
DATA:     G_ZTC_MULTI_VAR_LINES  LIKE SY-LOOPC.