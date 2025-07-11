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
*                           TABLES
*----------------------------------------------------------------------*
TABLES sscrfields.

*----------------------------------------------------------------------*
*                           T Y P E - P O O L S
*----------------------------------------------------------------------*
TYPE-POOLS : vrm, zcon.

*----------------------------------------------------------------------*
*                           T Y P E S
*----------------------------------------------------------------------*
" Type Defination for All Records Selection for Left / source container
TYPES: BEGIN OF source_s_type,                                " TYPE for LQUA Data records
         lgnum      TYPE lqua-lgnum,                   " Warehouse
         lqnum      TYPE lqua-lqnum,                   " Quant
         matnr      TYPE lqua-matnr,                   " Material Number
         werks      TYPE lqua-werks,                   " Plant
         charg      TYPE lqua-charg,                   " Batch Number
         bestq      TYPE lqua-bestq,                   " Stock Category in the Warehouse Management System
         sobkz      TYPE lqua-sobkz,                   " Special Stock Indicator
         sonum      TYPE lqua-sonum,                   " Special Stock Number
         lgtyp      TYPE lqua-lgtyp,                   " Storage Type
         lgpla      TYPE lqua-lgpla,                   " Storage Bin
         letyp      TYPE lqua-letyp,                   " Storage Unit Type
         meins      TYPE lqua-meins,                   " Base Unit of Measure
         verme      TYPE lqua-verme,                   " Available Stock
         lgort      TYPE lqua-lgort,                   " Storage Location
         del_flag   TYPE char1,                        " Delete flag
         orig_index TYPE i,                            " Original index value
         sel_line   TYPE char1,                        " Selection flag
       END OF source_s_type,

       " Type Defination for All Records Selection for Right / destination container
       BEGIN OF dest_s_type,
         sel_line       TYPE char1,                          " Selection flag
         lgnum          TYPE lqua-lgnum,                     " Warehouse
         lqnum          TYPE lqua-lqnum,                     " Quant
         matnr          TYPE lqua-matnr,                     " Material Number
         bestq          TYPE lqua-bestq,                     " Stock Category in the Warehouse Management System
         sobkz          TYPE lqua-sobkz,                     " Special Stock Indicator
         sonum          TYPE lqua-sonum,                     " Special Stock Number
         lgtyp          TYPE lqua-lgtyp,                     " Storage Type
         lgpla          TYPE lqua-lgpla,                     " Storage Bin
         letyp          TYPE lqua-letyp,                     " Storage Unit Type
         verme          TYPE lqua-verme,                     " Available Stock
         material       TYPE zmm_scanreel_str-material,      " Material Number (Custom table)
         werks          TYPE zmm_scanreel_str-werks,         " Plant (Custom table)
         lgort          TYPE zmm_scanreel_str-lgort,         " Storage Location (Custom table)
         charg          TYPE zmm_scanreel_str-charg,         " Batch (Custom table)
         menge          TYPE zmm_scanreel_str-menge,         " Quantity (Custom table)
         meins          TYPE zmm_scanreel_str-meins,         " Base Unit (Custom table)
         timestamp      TYPE zmm_scanreel_str-timestamp,     " Storage Unit(Custom table)
         zlgtyp_source  TYPE zmm_scanreel_str-zlgtyp_source, " Source Storage Type (Custom table)
         to_number      TYPE ltak-tanum,                     " To number (LTAK)
         posting_change TYPE ltak-ubnum,                     " Posting change (LTAK)
         mblnr          TYPE zmm_scanreel_str-mblnr,         " Material Doc. (Custom table)
         msg            TYPE bapi_msg,                       " TO creation BAPI return message
         del_flag       TYPE char1,                          " Delete Flag
         upd_flg        TYPE c LENGTH 1,                     " Update Flag
         ins_flag       TYPE c LENGTH 1,                     " Insert Flag
       END OF dest_s_type,

       " Type Defination for Selection Screen
       BEGIN OF sel_s_type,
         sloc        TYPE lgort_d,                        " Source storage location
         dloc        TYPE lgort_d,                        " Destination storage location
         zlgtyp_dest TYPE zlgtyp_dest,                    " Destination storage type
         wbatch      TYPE charg_d,                        " Destination Batch
         bin         TYPE zstr_num_long,                  " Storage Bin
       END OF sel_s_type.

*----------------------------------------------------------------------*
*                   C O N S T A N T S
*----------------------------------------------------------------------*

CONSTANTS:
  c_gmcode        TYPE bapi2017_gm_code VALUE '04',      " GM Code for the BAPI
  c_selmode       TYPE c                VALUE 'A',       " Field catalog select mode type
  c_bsskz         TYPE lvs_bsskz        VALUE 'C',       " Special movement indicator for warehouse management
  c_offset        TYPE i                VALUE 10,
  c_charg_len     TYPE i                VALUE 10,
  c_sep_ch(1)     TYPE c                VALUE '+',
  c_l_ch(1)       TYPE c                VALUE 'L',
  c_dec_0         TYPE lvc_s_fcat-decimals VALUE IS INITIAL,
  c_q_ch(1)       TYPE c                VALUE 'Q',
  c_len_05        TYPE n                VALUE 5,
  c_len_06        TYPE n                VALUE 6,
  c_len_11        TYPE n LENGTH 2       VALUE 11,
  c_len_60        TYPE n LENGTH 2       VALUE 60,
  c_len_25        TYPE n LENGTH 2       VALUE 25,
  c_len_13        TYPE n LENGTH 2       VALUE 13,
  c_p_werks       TYPE werks_d          VALUE 'WOBE',
  c_p_lgorts      TYPE lgort_d          VALUE 'WAFP',
  c_p_lgtyps      TYPE zlgtyp_source    VALUE 'REC',
  c_p_lgortd      TYPE lgort_d          VALUE 'DAAS',
  c_p_lgtypd      TYPE zlgtyp_dest      VALUE 'DAS',
  c_p_bwart       TYPE bwart            VALUE '311',
  c_dynpnr        TYPE sy-dynnr         VALUE '1000',
  c_zero_qty      TYPE lqua-verme       VALUE IS INITIAL,
  c_zero_tanum    TYPE tanum            VALUE IS INITIAL,
  c_actvt         TYPE tact-actvt       VALUE '01',              " Activity for Auth Check
  c_max_capacity  TYPE lagp-lkapv       VALUE '1000000',
  c_p_gtsour      TYPE string           VALUE 'GT_SOURCE',       " SOurce Internal table
  c_p_alvs        TYPE string           VALUE 'C_ALV_SOURCE',    " source ALV (Left Conatainer)
  c_p_selline     TYPE string           VALUE 'SEL_LINE',        " selection line
  c_strno         TYPE dynfnam          VALUE 'P_STRNO',
  c_matnr         TYPE dynfnam          VALUE 'P_MATNR',
  c_werks         TYPE dynfnam          VALUE 'P_WERKS',
  c_sloc          TYPE dynfnam          VALUE 'P_SLOC',
  c_sloct         TYPE dynfnam          VALUE 'P_SLOC_T',
  c_dloc          TYPE dynfnam          VALUE 'P_DLOC',
  c_dloct         TYPE dynfnam          VALUE 'P_ZLGTYP',
  c_p_matnr       TYPE dynfnam          VALUE 'MATNR',           " Material No for the field catalog
  c_p_werks1      TYPE dynfnam          VALUE 'WERKS',           " Plant for the field catalog
  c_p_lgort       TYPE dynfnam          VALUE 'LGORT',           " Storage location for the field catalog
  c_p_charg       TYPE dynfnam          VALUE 'CHARG',           " Batch for the field catalog
  c_p_verme       TYPE dynfnam          VALUE 'VERME',           " Available Stock for the field catalog
  c_p_meins       TYPE dynfnam          VALUE 'MEINS',           " Base unit for the field catalog
  c_zstatus_1001  TYPE dynfnam          VALUE 'ZSTATUS_1001',
  c_ztitle        TYPE dynfnam          VALUE 'ZTITLE',
  c_p_gtdest      TYPE string           VALUE 'GT_DEST',          " Destination internal table.
  c_p_alvdest     TYPE string           VALUE 'C_ALV_DEST',       " Destination ALV (Right Conatainer)
  c_p_material    TYPE string           VALUE 'MATERIAL',         " Material(Custom Table) No for the field catalog
  c_p_to_num      TYPE string           VALUE 'TO_NUMBER',        " To number
  c_p_post_change TYPE string           VALUE 'POSTING_CHANGE',   " posting change Document
  c_p_msg         TYPE bapi_msg         VALUE 'MSG',
  c_p_tcs_mov     TYPE ui_func          VALUE 'TCS_MOVE',         " Move button s function code
  c_p_tcd_mov     TYPE ui_func          VALUE 'TCD_MOVE',         " move button d funtion code
  c_p_move_qi     TYPE iconquick        VALUE 'MOVE',             " Quickinfo for an icon
  c_p_move_text   TYPE text40           VALUE 'MOVE',             " move button text
  c_p_fc_batch    TYPE dynfnam          VALUE 'FC_BATCH',         " batch screen field fucntion code
  c_p_process     TYPE dynfnam          VALUE 'PROCESS',          " Process button to create dthe material doc.
  c_strlong       TYPE dfies-fieldname  VALUE 'STRLONG',          " STR Long
  c_p_str         TYPE string           VALUE 'STR',              " STR text
  c_destination_n TYPE char4            VALUE 'NONE',             " BAPI destination none.
  c_start_report  TYPE sy-tcode         VALUE 'START_REPORT',
  c_status_1000   TYPE sy-pfkey         VALUE 'ZSTATUS_1000',
  c_fct_get       TYPE sy-ucomm         VALUE 'GET',
  c_fct_onli      TYPE sy-ucomm         VALUE 'ONLI',
  c_fct_spos      TYPE sy-ucomm         VALUE 'SPOS',
  c_doc_class     TYPE dsysh-dokclass   VALUE 'TX',
  c_doc_name      TYPE rollname         VALUE 'ZMM_RESERVE_WFSTR_DOCU',
  c_fct_docu      TYPE sy-ucomm         VALUE 'DOCUINFO',
  c_index1        TYPE sy-index         VALUE 1,
  c_sy_subrc_1    TYPE sy-subrc         VALUE 1,
  c_sy_subrc_2    TYPE sy-subrc         VALUE 2,
  c_offset_2      TYPE n LENGTH 1       VALUE 2,
  c_offset_4      TYPE n LENGTH 1       VALUE 4,
  c_offset_6      TYPE n LENGTH 1       VALUE 6,
  c_spl_chars     TYPE string           VALUE '~!@#$%^&*()_+{}|:"<>?/.,;][',
  c_vrm_field     TYPE vrm_id           VALUE 'LCL_DATA_MANAGER=>GV_CHARG'.