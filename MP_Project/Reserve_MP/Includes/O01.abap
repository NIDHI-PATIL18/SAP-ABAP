*&---------------------------------------------------------------------*
*& Include          ZMMI_RESERVE_WFSTR_FINAL_O01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZMMI_RESERVE_WFSTR_O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_1001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&------------------------------------------------------------------*======================================================================*
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
MODULE status_1001 OUTPUT.

  SET PF-STATUS 'ZSTATUS_1001'.
  SET TITLEBAR 'ZTITLE'.

  lcl_data_manager=>init_disable_fields( ).
  lcl_data_manager=>init_grid_source( ).
  lcl_data_manager=>init_grid_dest( ).
  lcl_data_manager=>init_filter( ).

ENDMODULE.