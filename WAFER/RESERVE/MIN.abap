*&---------------------------------------------------------------------*
*& Include       ZMMI_RESERVE_WFSTR_MIN
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
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_set_pf_status_1000.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_strno.
  PERFORM f_strno_f4.

AT SELECTION-SCREEN.

  CASE sscrfields-ucomm.
    WHEN c_fct_onli.
      " STR validation
      IF p_strno IS INITIAL.
        MESSAGE TEXT-e10 TYPE zcon_msg_e.
      ELSEIF strlen( p_strno ) > c_offset AND lcl_data_manager=>gv_oldstr IS INITIAL.
        MESSAGE TEXT-e15 TYPE zcon_msg_e.
      ELSE.
        " new STR number should be numeric value
        IF p_strno CA sy-abcde AND lcl_data_manager=>gv_oldstr IS INITIAL.
          MESSAGE TEXT-e16 TYPE zcon_msg_e.
        ENDIF.
        IF p_strno CA c_spl_chars.
          MESSAGE TEXT-e44 TYPE zcon_msg_e.
        ENDIF.
      ENDIF.

      " Material Number validation
      IF p_matnr IS INITIAL.
        MESSAGE TEXT-e01 TYPE zcon_msg_e.
      ELSE.
        SELECT COUNT( matnr )
          FROM mara
         WHERE matnr = @p_matnr
          INTO @DATA(lv_matnr_count).

        IF lv_matnr_count IS INITIAL.
          MESSAGE TEXT-e32 TYPE zcon_msg_e.
        ELSE.
          CLEAR lv_matnr_count.
        ENDIF.
      ENDIF.

      " Plant Validation
      IF p_werks IS INITIAL.
        MESSAGE TEXT-e03 TYPE zcon_msg_e.
      ELSE.
        SELECT COUNT( werks )
          FROM t001w
         WHERE werks = @p_werks
          INTO @DATA(lv_werks_count)
          BYPASSING BUFFER.
        IF lv_werks_count IS INITIAL.
          MESSAGE TEXT-e33 TYPE zcon_msg_e.
        ELSE.
          CLEAR lv_werks_count.
        ENDIF.
      ENDIF.

      " Soucre storage location validation
      IF p_sloc IS INITIAL.
        MESSAGE TEXT-e04 TYPE zcon_msg_e.
      ELSE.
        SELECT COUNT( lgort )
         FROM t001l
        WHERE lgort = @p_sloc
          AND werks = @p_werks
         INTO @DATA(lv_lgort_count)
          BYPASSING BUFFER.
        IF lv_lgort_count IS INITIAL.
          MESSAGE TEXT-e38 TYPE zcon_msg_e.
        ELSE.
          CLEAR lv_lgort_count.
        ENDIF.
      ENDIF.

      IF p_werks IS NOT INITIAL AND
         p_sloc  IS NOT INITIAL.
        PERFORM f_get_lgnum.
      ENDIF.

      " Source storage type validation
      IF p_sloc_t IS INITIAL.
        MESSAGE TEXT-e42 TYPE zcon_msg_e.
      ELSE.
        IF lcl_data_manager=>gv_lgnum IS NOT INITIAL.
          SELECT COUNT( lgtyp )
           FROM t301
          WHERE lgtyp = @p_sloc_t
            AND lgnum = @lcl_data_manager=>gv_lgnum
           INTO @DATA(lv_lgtyp_count)
            BYPASSING BUFFER.
          IF lv_lgtyp_count IS INITIAL.
            MESSAGE TEXT-e39 TYPE zcon_msg_e.
          ELSE.
            CLEAR lv_lgtyp_count.
          ENDIF.
        ENDIF.
      ENDIF.

      " Destination storage location validation
      IF p_dloc IS INITIAL.
        MESSAGE TEXT-e05 TYPE zcon_msg_e.
      ELSE.
        SELECT COUNT( lgort )
         FROM t001l
        WHERE lgort = @p_dloc
          AND werks = @p_werks
         INTO @DATA(lv_lgort_d_count)
          BYPASSING BUFFER.
        IF lv_lgort_d_count IS INITIAL.
          MESSAGE TEXT-e27 TYPE zcon_msg_e.
        ELSE.
          CLEAR lv_lgort_d_count.
        ENDIF.
      ENDIF.

      " Destination storage location type validation.
      IF p_zlgtyp IS INITIAL.
        MESSAGE TEXT-e06 TYPE zcon_msg_e.
      ELSE.

        IF lcl_data_manager=>gv_lgnum IS NOT INITIAL.

          SELECT COUNT( lgtyp )
           FROM t301
          WHERE lgtyp = @p_zlgtyp
            AND lgnum = @lcl_data_manager=>gv_lgnum
           INTO @DATA(lv_lgtyp_d_count)
           BYPASSING BUFFER.
          IF lv_lgtyp_d_count IS INITIAL.
            MESSAGE TEXT-e28 TYPE zcon_msg_e.
          ELSE.
            CLEAR lv_lgtyp_d_count.
          ENDIF.
        ENDIF.
      ENDIF.

      " Validate Printer input if not initial.
      IF p_prntr IS NOT INITIAL.
        SELECT COUNT( padest )
                FROM tsp03
               WHERE padest = @p_prntr
                INTO @DATA(lv_prntr_count)
                BYPASSING BUFFER.
        IF lv_prntr_count IS INITIAL.
          MESSAGE TEXT-e34 TYPE zcon_msg_e.
        ELSE.
          CLEAR lv_prntr_count.
        ENDIF.
      ENDIF.

      " Inventeroy Movement Validation
      IF p_inv_m IS INITIAL.

        MESSAGE TEXT-e43 TYPE zcon_msg_e.

      ELSE.

        SELECT COUNT( bwart )
         FROM t156
        WHERE bwart = @p_inv_m
         INTO @DATA(lv_inv_m_count)
          BYPASSING BUFFER.
        IF lv_inv_m_count IS INITIAL.
          MESSAGE TEXT-e31 TYPE zcon_msg_e.
        ELSE.
          CLEAR lv_inv_m_count.
        ENDIF.
      ENDIF.

    WHEN c_fct_docu.
      PERFORM f_display_docu.

  ENDCASE.
*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  IF p_strno IS NOT INITIAL.
    " If user does not select from F4
    PERFORM f_get_existing_data.
  ENDIF.

  IF lcl_data_manager=>gv_oldstr IS INITIAL.

    IF strlen( p_strno ) > 10.
      lcl_data_manager=>gv_stop = abap_true.
      MESSAGE TEXT-e15 TYPE zcon_msg_s DISPLAY LIKE zcon_msg_e.
    ELSE.

      IF ( p_strno CA sy-abcde ).
        lcl_data_manager=>gv_stop = abap_true.
        MESSAGE TEXT-e16 TYPE zcon_msg_s DISPLAY LIKE zcon_msg_e.

      ELSEIF ( p_strno CA c_spl_chars ).
        lcl_data_manager=>gv_stop = abap_true.
        MESSAGE TEXT-e44 TYPE zcon_msg_s DISPLAY LIKE zcon_msg_e.
      ENDIF.

    ENDIF.
  ENDIF.

  IF lcl_data_manager=>gv_lgnum IS INITIAL.
    PERFORM f_get_lgnum.
  ENDIF.

  IF lcl_data_manager=>gv_lgnum IS NOT INITIAL.

    " Authorization Check
    PERFORM f_auth_check.

    IF lcl_data_manager=>gv_stop IS INITIAL.
      PERFORM f_call_pick_scr.
    ENDIF.

  ENDIF.