*&---------------------------------------------------------------------*
*& Include          ZMMI_RETURN_WFSTR_MIN
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
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.

  PERFORM f_set_title_1000.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

  PERFORM f_set_pf_status_1000.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_strn.

  PERFORM f_strn_f4.

AT SELECTION-SCREEN.

  CASE sscrfields-ucomm.

    WHEN c_fct_rwnc.

      CALL METHOD lcl_data_manager=>ini_clear_data( ).

      PERFORM f_validate_input.

      "Check if user has authorization for L_LGNUM using selected LGNUM
      lcl_data_manager=>gv_proceed = abap_true.
      PERFORM f_auth_check_lgnum.

      " User is authorized, proceed
      IF lcl_data_manager=>gv_proceed = abap_true.

        PERFORM f_call_pick_scr.

        PERFORM f_fetch_data.

        IF gt_tc_return[] IS NOT INITIAL.
          lcl_data_manager=>process_data( EXPORTING iv_ident = c_pcount ).
        ELSE.
          MESSAGE TEXT-e04 TYPE zcon_msg_e.
        ENDIF.

      ENDIF.

    WHEN c_fct_exect.

      CALL METHOD lcl_data_manager=>ini_clear_data( ).

      PERFORM f_validate_input.

      " Check if user has authorization for L_LGNUM using selected LGNUM
      lcl_data_manager=>gv_proceed = abap_true.
      PERFORM f_auth_check_lgnum.

      " User is authorized, proceed
      IF lcl_data_manager=>gv_proceed = abap_true.

        PERFORM f_call_pick_scr.

        PERFORM f_fetch_data.

        IF gt_tc_return[] IS NOT INITIAL.

          " Display Screen 1001
          PERFORM f_call_screen_1001.

          IF gt_tc_return IS NOT INITIAL.
            PERFORM f_save_data.
          ENDIF.

        ELSE.

          MESSAGE TEXT-e04 TYPE zcon_msg_s DISPLAY LIKE zcon_msg_e.

        ENDIF.
      ENDIF.

    WHEN c_fct_docu.
      PERFORM f_display_docu.

  ENDCASE.