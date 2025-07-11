*&---------------------------------------------------------------------*
*& Include          ZMMI_RETURN_WFSTRTOP
*&---------------------------------------------------------------------*
*======================================================================*
*                Source Code Documentation Section                     *
*======================================================================*
* Requested by  : Ana Marlen Yañez
* Date          : Sep 04 2024
* Developer     : Shashikant M (MOTARWS)
* Description   : New RETURN SAP Process flow for DIE-ON Film
*                 frame proposal in WOBE plant.
*                 Return: Goods Issue & Transfer posting inventory from
*                 warehouse storage location to a separate storage
*                 location, maintaining original quant information,
*                 including storage units
* ITRS / Ref.   : RITM162110
* Transport     : DEVK9G0H43
*----------------------------------------------------------------------*
*======================================================================*

*----------------------------------------------------------------------*
*                           TABLES
*----------------------------------------------------------------------*
TABLES sscrfields.

*----------------------------------------------------------------------*
*                           TYPE-POOLS
*----------------------------------------------------------------------*
TYPE-POOLS: zcon.

*----------------------------------------------------------------------*
*                           T Y P E S
*----------------------------------------------------------------------*
TYPES: BEGIN OF sel_s_type,
         werks  TYPE werks_d,               " Plant
         lgorts TYPE lgort_d,               " Source Storage Location
         strn   TYPE zstr_num_long,         " STR Number
         lgpla  TYPE lgpla,                 " Destination Bin
         lgortd TYPE lgort_d,               " Dest Storage Location: WAFP
         mov_wm TYPE bwart,                 " Warehouse management movement
         mov_in TYPE bwart,                 " Inventory Movement for Transfer
         mov_co TYPE bwart,                 " Consumption movement
         mov_sc TYPE bwart,                 " Scrap movement
       END OF sel_s_type.

* Data source from lqua
TYPES: BEGIN OF tc_return_s_type,                       " Type for Return Table Control and Processing
         lgnum          TYPE lqua-lgnum,
         lqnum          TYPE lqua-lqnum,
         matnr          TYPE lqua-matnr,                " Field for TC Column - Material
         werks          TYPE lqua-werks,
         charg          TYPE lqua-charg,                " Field for TC Column - Batch
         lgpla          TYPE lqua-lgpla,
         menge          TYPE p LENGTH 13 DECIMALS 0,    " Field for TC Column - Unrestricted
         meins          TYPE lqua-meins,                " UOM
         varnm          TYPE lqua-lenum,                " Field for TC Column - Variant Name "char25
         pcount         TYPE p LENGTH 13 DECIMALS 0,   " Field for TC Column - Previous Count
         consum         TYPE p LENGTH 13 DECIMALS 0,   " Field for TC Column - Consumption
         scrap          TYPE p LENGTH 13 DECIMALS 0,   " Field for TC Column - Scrap Count
         ncount         TYPE p LENGTH 13 DECIMALS 0,   " Field for TC Column - New Count
         lgort          TYPE lqua-lgort,
         lenum          TYPE lqua-lenum,
         letyp          TYPE lqua-letyp,
         lgtyp          TYPE lqua-lgtyp,
         log            TYPE bapi_msg,                  " Field for TC Column - Log
         to_number      TYPE char120,
         posting_change TYPE ubnum,
         status_c       TYPE c LENGTH 1,
         status_s       TYPE c LENGTH 1,
         c_part_failed  TYPE c LENGTH 1,
         s_part_failed  TYPE c LENGTH 1,
         n_part_failed  TYPE c LENGTH 1,
       END OF tc_return_s_type.

TYPES: BEGIN OF total_s_type,
         matnr  TYPE lqua-matnr,
         charg  TYPE lqua-charg,
         consum TYPE lqua-verme,
         scrap  TYPE lqua-verme,
         ncount TYPE lqua-verme,
         pcount TYPE lqua-verme,
         meins  TYPE lqua-meins,
       END OF total_s_type.

TYPES: gty_goodsmvt_item TYPE STANDARD TABLE OF bapi2017_gm_item_create INITIAL SIZE 0 WITH NON-UNIQUE DEFAULT KEY,
       gty_return        TYPE STANDARD TABLE OF bapiret2 WITH NON-UNIQUE DEFAULT KEY INITIAL SIZE 0.

*----------------------------------------------------------------------*
*                     INTERNAL TABLES and WORK AREAS
*----------------------------------------------------------------------*

DATA: gs_selection TYPE sel_s_type,
      gs_tc_return TYPE tc_return_s_type,
      gt_tc_return TYPE STANDARD TABLE OF tc_return_s_type.

*----------------------------------------------------------------------*
*                          GLOBAL VARIABLES
*----------------------------------------------------------------------*

DATA: gv_tot_count TYPE p LENGTH 13 DECIMALS 0,                  " Total Count: Prev. Count
      gv_tot_consu TYPE p LENGTH 13 DECIMALS 0,                  " Total Count: Consumption
      gv_tot_scrap TYPE p LENGTH 13 DECIMALS 0,                  " Total Count: Scrap
      gv_tot_new   TYPE p LENGTH 13 DECIMALS 0.                  " Total Count: New Count

*----------------------------------------------------------------------*
*                         C O N S T A N T S
*----------------------------------------------------------------------*

CONSTANTS: c_fct_back      TYPE sy-ucomm          VALUE 'BACK',              " User Selects the Back arrow button
           c_fct_cancel    TYPE sy-ucomm          VALUE 'CANCEL',            " User Selects the CANCEL button
           c_fct_execute   TYPE sy-ucomm          VALUE 'PROCESS',           " User Selects the EXECUTE button
           c_fct_rwnc      TYPE sy-ucomm          VALUE 'RWNC',              " User Selects the Return With No Consumption button
           c_fct_exect     TYPE sy-ucomm          VALUE 'EXECT',
           c_fct_docu      TYPE sy-ucomm          VALUE 'DOCUINFO',
           c_fct_onli      TYPE sy-ucomm          VALUE 'ONLI',
           c_fct_spos      TYPE sy-ucomm          VALUE 'SPOS',
           c_fct_get       TYPE sy-ucomm          VALUE 'GET',
           c_ans_yes       TYPE c                 VALUE '1',                 " Answer Yes
           c_bsskz         TYPE lvs_bsskz         VALUE 'C',                 " Special Movement Indicator - C
           c_fct_exit      TYPE sy-ucomm          VALUE 'EXIT',              " User Selects the EXIT button
           c_consum        TYPE c                 VALUE 'C',
           c_scrap         TYPE c                 VALUE 'S',
           c_ncount        TYPE c                 VALUE 'N',
           c_pcount        TYPE c                 VALUE 'P',
           c_all           TYPE c LENGTH 1        VALUE '*',                 " All Value *
           c_start_report  TYPE sy-tcode          VALUE 'START_REPORT',
           c_status_1001   TYPE dynfnam           VALUE 'STATUS_1001',
           c_status_1000   TYPE sy-pfkey          VALUE 'STATUS_1000',
           c_title_1001    TYPE dynfnam           VALUE 'TITLE_1001',
           c_title_1000    TYPE dynfnam           VALUE 'TITLE_1000',
           c_scrn_consum   TYPE string            VALUE 'GS_TC_RETURN-CONSUM',
           c_scrn_scrap    TYPE string            VALUE 'GS_TC_RETURN-SCRAP',
           c_tcr           TYPE dynfnam           VALUE 'TCR',
           c_p_str         TYPE string            VALUE 'STR',
           c_strlong       TYPE dfies-fieldname   VALUE 'STRLONG',
           c_scr_1000      TYPE sy-dynnr          VALUE '1000',
           c_p_strn        TYPE dynfnam           VALUE 'P_STRN',
           c_werks         TYPE werks_d           VALUE 'WOBE',
           c_lgorts        TYPE lgort_d           VALUE 'DAAS',
           c_lgpla         TYPE lgpla             VALUE 'RETURNS',
           c_lgortd        TYPE lgort_d           VALUE 'WAFP',
           c_mov_wm        TYPE bwlvs             VALUE '999',
           c_mov_in        TYPE bwart             VALUE '311',
           c_mov_co        TYPE bwart             VALUE '201',
           c_mov_sc        TYPE bwart             VALUE '92G',
           c_kostl         TYPE kostl             VALUE 'C10220316',
           c_reas_m        TYPE mb_grbew          VALUE '0316',
           c_werks_d       TYPE dynfnam           VALUE 'P_WERKS',
           c_lgort_s       TYPE dynfnam           VALUE 'P_LGORTS',
           c_destination_n TYPE char4             VALUE 'NONE',
           c_num0          TYPE lqua-verme        VALUE IS INITIAL,
           c_index1        TYPE sy-tabix          VALUE 1,
           c_offset_2      TYPE n LENGTH 1        VALUE 2,
           c_offset_4      TYPE n LENGTH 1        VALUE 4,
           c_offset_6      TYPE n LENGTH 1        VALUE 6,
           c_offset        TYPE i                VALUE 10,
           c_charg_len     TYPE i                VALUE 10,
           c_doc_class     TYPE dsysh-dokclass    VALUE 'TX',
           c_doc_name      TYPE rollname          VALUE 'ZMM_RETURN_WFSTR_DOCU',
           c_gm_code_03    TYPE bapi2017_gm_code  VALUE '03',
           c_gm_code_04    TYPE bapi2017_gm_code  VALUE '04',
           c_screen_1001   TYPE dynnr             VALUE '1001'.

*----------------------------------------------------------------------*
*             TABLE CONTROLS
*----------------------------------------------------------------------*
*&SPWIZARD: DECLARATION OF TABLECONTROL 'TCR' ITSELF
CONTROLS:    tcr TYPE TABLEVIEW USING SCREEN c_screen_1001.