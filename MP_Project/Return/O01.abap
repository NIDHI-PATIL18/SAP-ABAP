*----------------------------------------------------------------------*
***INCLUDE ZMM_RETURN_WFSTR_O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'ZPF_STATUS_RETURN'.
  SET TITLEBAR 'ZINITIAL_SCREEN_TB'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'ZPF_STATUS_PROCESS'.
  SET TITLEBAR 'ZPROCESS_SCREEN_TB'.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_PROCESS'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE ztc_process_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_tc_main LINES ztc_process-lines.
*---------------------------------- Code for Filling the Table control 'ZTC_PROCESS' ---------------------
  IF gv_fill_tc_flag EQ 'X'.
    REFRESH gt_tc_main.
    CLEAR gs_tc_main.
    CLEAR gv_previous_count_total.
    LOOP AT gt_mseg_data INTO gs_mseg_data.
      gs_tc_main-mblnr        = gs_mseg_data-mblnr.
      gs_tc_main-matnr        = gs_mseg_data-matnr.
      gs_tc_main-charg        = gs_mseg_data-charg.
      gs_tc_main-unrescricted = gs_mseg_data-menge.
      gs_tc_main-variant      = ''.
      gs_tc_main-prev_count   = gs_mseg_data-menge.
      gv_previous_count_total = gv_previous_count_total + gs_tc_main-prev_count.                 "Total of Prev. Count
      gs_tc_main-new_count    = gs_mseg_data-menge.
      gv_new_count_total      = gv_previous_count_total.                                         "Total New Count
      APPEND gs_tc_main TO gt_tc_main.
      CLEAR gs_tc_main.
      CLEAR gv_fill_tc_flag.
    ENDLOOP.
  ENDIF.
*---------------------------------- Code for Filling the Table control 'ZTC_PROCESS' ---------------------

ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_PROCESS'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE ztc_process_get_lines OUTPUT.
  g_ztc_process_lines = sy-loopc.

  IF gv_consumption_gt EQ 'X' OR
     gv_scrap_gt       EQ 'X' OR
     gv_combination_gt EQ 'X'.
    IF gv_consumption_gt EQ 'X'.
      READ TABLE gv_mblnr INTO DATA(gs_mblnr) WITH KEY gs_tc_main-mblnr.
      IF gs_mblnr IS NOT INITIAL.
        LOOP AT SCREEN.
          IF screen-name = 'GS_TC_MAIN-SCRAP'.
            screen-input = 0.
            CLEAR gs_mblnr.
          ENDIF.
        MODIFY SCREEN.
        ENDLOOP.
        gv_no_of_rec_processed_counter = gv_no_of_rec_processed_counter + 1.
        DESCRIBE TABLE gv_mblnr LINES DATA(lv_no_of_rec_in_gv_mblnr).
        IF gv_no_of_rec_processed_counter EQ lv_no_of_rec_in_gv_mblnr.
          REFRESH gv_mblnr.
          CLEAR lv_no_of_rec_in_gv_mblnr.
          CLEAR gv_no_of_rec_processed_counter.
          CLEAR gv_consumption_gt.
        ENDIF.
      ENDIF.
    ELSEIF gv_scrap_gt EQ 'X'.

    ELSE.

    ENDIF.
  ENDIF.


ENDMODULE.