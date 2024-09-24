*&---------------------------------------------------------------------*
*& Include          ZMMI_RESERVE_WFSTR_FINAL_SEL
*&---------------------------------------------------------------------*
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

SELECTION-SCREEN BEGIN OF BLOCK b1.

  PARAMETERS:
    p_strno    TYPE zstr_num_long OBLIGATORY,
    p_matnr    TYPE matnr,
    p_werks    TYPE werks_d     DEFAULT 'WOBE',
    p_sloc     TYPE lgort_d     DEFAULT 'WAFP',
    p_sloc_t   TYPE zlgtyp_source DEFAULT 'REC',
    p_dloc     TYPE lgort_d     DEFAULT 'DAAS',
    p_zlgtyp   TYPE zlgtyp_dest DEFAULT 'DAS',
    p_prntr    TYPE tddest,
    p_wm_mov   TYPE bwart       DEFAULT '999' OBLIGATORY,
    p_inv_m    TYPE bwart       DEFAULT '311' OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b1.