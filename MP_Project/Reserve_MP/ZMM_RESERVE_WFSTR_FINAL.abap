*&---------------------------------------------------------------------*
*& Report ZMM_RESERVE_WFSTR_FINAL_RP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_RESERVE_WFSTR_FINAL_RP.
*&---------------------------------------------------------------------*
*& Report ZMM_RESERVE_WFSTR
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


INCLUDE zmmi_reserve_wfstr_FINAL_top.                     " global Data
INCLUDE zmmi_reserve_wfstr_FINAL_def.                     " Local Class Definition
INCLUDE zmmi_reserve_wfstr_FINAL_sel.                     " selection screen
INCLUDE zmmi_reserve_wfstr_FINAL_imp.
INCLUDE zmmi_reserve_wfstr_FINAL_f01.
INCLUDE zmmi_reserve_wfstr_FINAL_i01.
INCLUDE zmmi_reserve_wfstr_FINAL_o01.

*----------------------------------------------------------------------*
* AT Selection-Screen
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_strno.
  PERFORM f_strno_f4.

AT SELECTION-SCREEN.
  PERFORM f_get_existing_data. " If user does not select from F4

  IF p_matnr IS INITIAL.
    MESSAGE TEXT-e01 TYPE c_type_e.
  ENDIF.

  IF p_werks IS INITIAL.
    MESSAGE TEXT-e03 TYPE c_type_e.
  ENDIF.

  IF p_sloc IS INITIAL.
    MESSAGE TEXT-e04 TYPE c_type_e.
  ENDIF.

  IF p_dloc IS INITIAL.
    MESSAGE TEXT-e05 TYPE c_type_e.
  ENDIF.

  IF p_zlgtyp IS INITIAL.
    MESSAGE TEXT-e06 TYPE c_type_e.
  ENDIF.


*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_get_lgnum.

  IF gv_lgnum IS NOT INITIAL.

    PERFORM f_auth_check.     " Authorization Check

    CHECK gv_stop IS INITIAL.
    PERFORM f_call_pick_scr.

  ENDIF.