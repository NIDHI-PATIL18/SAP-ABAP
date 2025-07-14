*----------------------------------------------------------------------*
***INCLUDE ZMMI_RESERVE_WFSTR_O01.
*----------------------------------------------------------------------*
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
*&---------------------------------------------------------------------*
*& Module STATUS_1001 OUTPUT
*&---------------------------------------------------------------------*
*& Set PF status for Screen 1001
*&---------------------------------------------------------------------*
MODULE status_1001 OUTPUT.

  SET PF-STATUS c_zstatus_1001.
  SET TITLEBAR c_ztitle.

  lcl_data_manager=>init_grid_source( ).             " Initialize the data source for left grid.
  lcl_data_manager=>init_grid_dest( ).               " Initialize the data source for right grid.
  lcl_data_manager=>init_filter( ).                  " Initialize filters for left conatiner based on batch data.

ENDMODULE.