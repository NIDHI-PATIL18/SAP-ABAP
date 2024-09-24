*&---------------------------------------------------------------------*
*& Include          ZMMI_RESERVE_WFSTR_FINAL_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZMMI_RESERVE_WFSTR_TOP
*&---------------------------------------------------------------------*
*======================================================================*
*                Source Code Documentation Section                     *
*======================================================================*
* Requested by  : Ana Marlen Yañez
* Date          : Sep 04 2024
* Developer     : Kushagra Shah(SHAHAK)
* Description   : New Reserve SAP Process flow for DIE-ON Film
*                 frame proposal in WOBE plant.
*                 Transfer posting inventory from warehouse storage
*                 location to a separate storage location, maintaining
*                 original quant information, including storage units
* ITRS / Ref.   : RITM162110
* Transport     : DEVK9G0H43
*----------------------------------------------------------------------*
*======================================================================*
*----------------------------------------------------------------------*
*                           T Y P E S
*----------------------------------------------------------------------*
TYPE-POOLS : vrm.
TYPES: BEGIN OF source_s_type,
         lgnum      TYPE lqua-lgnum,
         lqnum      TYPE lqua-lqnum,
         matnr      TYPE lqua-matnr,
         werks      TYPE lqua-werks,
         charg      TYPE lqua-charg,
         bestq      TYPE lqua-bestq,
         sobkz      TYPE lqua-sobkz,
         sonum      TYPE lqua-sonum,
         lgtyp      TYPE lqua-lgtyp,
         lgpla      TYPE lqua-lgpla,
         letyp      TYPE lqua-letyp,
*          lenum      type lqua-lenum,
*          licha      type mcha-licha,
         meins      TYPE lqua-meins,
         verme      TYPE lqua-verme,
         lgort      TYPE lqua-lgort,
*          menge      TYPE zmm_scanreel_str-menge,
         del_flag   TYPE char1,
         orig_index TYPE i,
         sel_line   TYPE char1,
       END OF source_s_type.

DATA: gt_source      TYPE TABLE OF source_s_type,
      gt_source_temp TYPE TABLE OF source_s_type, " For QTY refresh purpose
      gs_source      TYPE source_s_type.
DATA: gt_source_backup TYPE TABLE OF source_s_type.
DATA: gt_source_all TYPE TABLE OF source_s_type.
TYPES: BEGIN OF dest_s_type,
         sel_line       TYPE char1,
         lgnum          TYPE lqua-lgnum,
         lqnum          TYPE lqua-lqnum,
         matnr          TYPE lqua-matnr,
*          werks    TYPE lqua-werks,
*          charg    TYPE lqua-charg,
         bestq          TYPE lqua-bestq,
         sobkz          TYPE lqua-sobkz,
         sonum          TYPE lqua-sonum,
*          lgort    TYPE lqua-lgort,
         lgtyp          TYPE lqua-lgtyp,
         lgpla          TYPE lqua-lgpla,
         letyp          TYPE lqua-letyp,
*          licha      type mcha-licha,
*          meins    TYPE lqua-meins,
*          menge    type zmm_scanreel_str-menge,
         verme          TYPE lqua-verme,
         material       TYPE zmm_scanreel_str-material,
         werks          TYPE zmm_scanreel_str-werks,
         lgort          TYPE zmm_scanreel_str-lgort,
         charg          TYPE zmm_scanreel_str-charg,
         menge          TYPE zmm_scanreel_str-menge,
         meins          TYPE zmm_scanreel_str-meins,
         timestamp      TYPE zmm_scanreel_str-timestamp,
         zlgtyp_source  TYPE zmm_scanreel_str-zlgtyp_source,
*          btanr    TYPE lqua-btanr,
         to_number      TYPE ltak-tanum,
         posting_change TYPE ltak-ubnum,
         mblnr          TYPE zmm_scanreel_str-mblnr,
         msg            TYPE bapi_msg,
         del_flag       TYPE char1,
         upd_flg        TYPE c,
         ins_flag       TYPE c,
       END OF dest_s_type.

DATA: gt_dest TYPE TABLE OF dest_s_type,
      gs_dest TYPE dest_s_type.

TYPES: BEGIN OF sel_s_type,
         sloc        TYPE lgort_d,           " Source storage location
         dloc        TYPE lgort_d,           " Destination storage location
         zlgtyp_dest TYPE zlgtyp_dest,       " Destination storage type
         wbatch      TYPE charg_d,
         bin         TYPE zstr_num_long,
       END OF sel_s_type.

DATA: gs_selection TYPE sel_s_type.

TYPES: BEGIN OF filter_s_type,
         sel_flag TYPE char1,
         charg    TYPE lqua-charg,
       END OF filter_s_type.
DATA: gt_filter TYPE TABLE OF filter_s_type,
      gs_filter TYPE filter_s_type.

DATA: gt_fieldcat TYPE lvc_t_fcat,
      gs_fieldcat TYPE lvc_s_fcat.
DATA: gt_fcat TYPE lvc_t_fcat,
      gs_fcat TYPE lvc_s_fcat.
DATA: gs_layout TYPE lvc_s_layo.

TYPES:BEGIN OF strnf4_s_type,
        zstrnum       TYPE zmm_scanreel_str-zstrnum,
        sydate        TYPE zmm_scanreel_str-sydate,
        sytime        TYPE zmm_scanreel_str-sytime,
        material      TYPE zmm_scanreel_str-material,
        lgort         TYPE zmm_scanreel_str-lgort,
        zlgtyp_source TYPE zmm_scanreel_str-zlgtyp_source,
        werks         TYPE zmm_scanreel_str-werks,
        syuser        TYPE zmm_scanreel_str-syuser,
        strlong       TYPE zmm_scanreel_str-strlong,
        zlgort_dest   TYPE zmm_scanreel_str-zlgort_dest,
        zlgtyp_dest   TYPE zmm_scanreel_str-zlgtyp_dest,
      END OF strnf4_s_type.

DATA: gt_strnf4 TYPE TABLE OF strnf4_s_type,
      gs_strnf4 TYPE strnf4_s_type.


DATA: gt_zmm_scanreel_str     TYPE STANDARD TABLE OF zmm_scanreel_str,
      gs_zmm_scanreel_str_sel TYPE zmm_scanreel_str,
      gs_zmm_scanreel_str     TYPE zmm_scanreel_str.

DATA: gt_charg_values TYPE vrm_values,
      gs_charg_value  TYPE vrm_value.
DATA:  gv_process TYPE char1.
" Goodsmovement BAPI
* DATA: gt_gm_header TYPE STANDARD TABLE OF  bapi2017_gm_head_01,
*       gs_gm_header TYPE bapi2017_gm_head_01,
*       gt_gm_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create,
*       gs_gm_item   TYPE bapi2017_gm_item_create,
*       gt_gm_return TYPE STANDARD TABLE OF bapiret2,
*       gs_gm_return TYPE bapiret2,
*       gs_gmvt_code TYPE bapi2017_gm_code, ##NEEDED

DATA: gv_mblnr TYPE bapi2017_gm_head_ret-mat_doc VALUE 1231,
      gv_msg   TYPE bapi_msg.

" Posting Change BAPI
DATA: gv_tanum TYPE tanum,
      gv_ubnum TYPE ubnum.               " Transfer order number
*Data:  gt_lubqu   TYPE STANDARD TABLE OF lubqu,   " Table for quants
*       gs_lubqu   TYPE lubqu,                     " Structure for quant
*       gt_ltap_vb TYPE STANDARD TABLE OF ltap_vb, " Table for transfer items
*       gs_ltap_vb TYPE ltap_vb.                   " Structure for transfer item


DATA: go_alv_source  TYPE REF TO cl_gui_custom_container ##NEEDED,
      go_alv_dest    TYPE REF TO cl_gui_custom_container ##NEEDED,
      go_source_grid TYPE REF TO cl_gui_alv_grid,
      go_dest_grid   TYPE REF TO cl_gui_alv_grid.


DATA: gv_charg TYPE lqua-charg.
DATA: gv_lgnum TYPE lgnum.
DATA: gv_zstrnum     TYPE zstrnum.
DATA: gv_date        TYPE sydate.
DATA: gv_time        TYPE sytime.
DATA: gv_strlong     TYPE zstr_num_long.
DATA: gv_material    TYPE matnr.
DATA: gv_batch       TYPE charg_d.
DATA: gv_lenum       TYPE lenum .      "storage unit
DATA: gv_menge       TYPE char20.
DATA: gv_stop        TYPE c.
* DATA: gv_lngstr      TYPE zbarcode.

DATA: gv_oldstr        TYPE c,        " Flag for OLD / Existing STR
      gv_orig_strs     TYPE zstrnum,   " Values from Oroiginal STR
      gv_orig_date     TYPE sydate,    " Values from Oroiginal STR
      gv_orig_time     TYPE sytime,    " Values from Oroiginal STR
      gv_orig_uname    TYPE sy-uname,   " Values from Oroiginal STR
      gv_orig_strl     TYPE zstr_num_long,   " Values from Oroiginal STR
      gv_orig_bin      TYPE lgpla,
      gv_mblnr_created TYPE c.           " Flag for MBLNR created for the selected STR.
*      gv_newstr TYPE c.

CONSTANTS: c_gmcode TYPE gm_code VALUE '04' .

CONSTANTS: c_fct_back   TYPE  sy-ucomm VALUE 'BACK' ,    " User Selects the Back arrow button
           c_fct_cancel TYPE  sy-ucomm VALUE 'CANCEL' ,  " User Selects the CANCEL button
           c_fct_exit   TYPE  sy-ucomm VALUE 'EXIT' ,    " User Selects the EXIT button
           c_fct_save   TYPE  sy-ucomm VALUE 'SAVE' ,    " User Selects the Search for Save button
           c_type_s     TYPE  c VALUE 'S',
           c_type_e     TYPE  c VALUE 'E',
           c_type_i     TYPE  c VALUE 'I',
           c_true       TYPE  c VALUE 'X',
           c_sep_ch(1)  TYPE  c        VALUE '+',
           c_l_ch(1)    TYPE  c        VALUE 'L',
           c_q_ch(1)    TYPE  c        VALUE 'Q'.