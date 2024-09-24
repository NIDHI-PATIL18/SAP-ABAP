*&---------------------------------------------------------------------*
*& Include          ZMMI_RESERVE_WFSTR_FINAL_I01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZMMI_RESERVE_WFSTR_I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1001  INPUT
*&---------------------------------------------------------------------*
*       text
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

MODULE user_command_1001 INPUT.
  lcl_screen_manager=>user_command_1001( ).
ENDMODULE.