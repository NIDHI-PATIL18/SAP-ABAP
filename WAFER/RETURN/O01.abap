*&---------------------------------------------------------------------*
*& Include          ZMMI_RETURN_WFSTR_O01
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
*&---------------------------------------------------------------------*
*& Module STATUS_1001 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_1001 OUTPUT.

  SET PF-STATUS c_status_1001.
  SET TITLEBAR c_title_1001.
  lcl_data_manager=>initialize_screen_1001( ).

ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TCR'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tcr_change_tc_attr OUTPUT.

  PERFORM f_tcr_change_tc_attr.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module TCR_GET_LINES OUTPUT
*&---------------------------------------------------------------------*
MODULE tcr_get_lines OUTPUT.

  PERFORM f_tcr_get_lines.

ENDMODULE.