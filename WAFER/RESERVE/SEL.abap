*&---------------------------------------------------------------------*
*& Include          ZMMI_RESERVE_WFSTR_SEL
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

"Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.

  PARAMETERS:
    p_strno  TYPE zstr_num_long,
    p_matnr  TYPE matnr,
    p_werks  TYPE werks_d        DEFAULT c_p_werks,             " Plant - WOBE
    p_sloc   TYPE lgort_d        DEFAULT c_p_lgorts,            " Storage Location - WAFP
    p_sloc_t TYPE zlgtyp_source  DEFAULT c_p_lgtyps,            " Storage Location type - REC
    p_dloc   TYPE lgort_d        DEFAULT c_p_lgortd,            " Destination Storage location - DAAS
    p_zlgtyp TYPE zlgtyp_dest    DEFAULT c_p_lgtypd,            " Destination Storage location type - DAS
    p_prntr  TYPE tsp03-padest,                                 " Printer
    p_inv_m  TYPE bwart          DEFAULT c_p_bwart  OBLIGATORY. " Inventeroy Movement - 311

SELECTION-SCREEN END OF BLOCK b1.