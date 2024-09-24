METHOD move_selected_record_S.
    DATA: lt_row_selected TYPE lvc_t_row,  " To hold selected rows
          ls_row_selected TYPE lvc_s_row,  " To hold individual selected row
          lv_index        TYPE sy-tabix,   " Index for selected rows
          lt_delete_index TYPE TABLE OF sy-tabix,
          lt_index        TYPE RANGE OF sy-tabix,
          ls_index        LIKE LINE OF lt_index.

* Get selected rows from the left container (DEST)
    CALL METHOD go_source_grid->get_selected_rows
      IMPORTING
        et_index_rows = lt_row_selected.
* Loop through selected rows and move them
    LOOP AT lt_row_selected INTO ls_row_selected.
      lv_index = ls_row_selected-index.
      ls_index-sign = 'I'.
      ls_index-option = 'EQ'.
      ls_index-low = lv_index.
      APPEND ls_index TO lt_index.
* Read the selected row from gt_dest based on the index
      READ TABLE gt_source INTO gs_source INDEX lv_index.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING gs_source TO gs_dest.
        APPEND gs_dest TO gt_dest.
        CLEAR gs_dest.
        gs_source-del_flag = 'X'.
        MODIFY gt_source FROM gs_source INDEX lv_index.
      ENDIF.
    ENDLOOP.
    DELETE gt_source WHERE del_flag = 'X'.
*    SORT lt_index BY low DESCENDING.
*
*    LOOP AT lt_index INTO ls_index.
*      DELETE gt_source INDEX ls_index-low.
*    ENDLOOP.
*  * Refresh destination grids
    CALL METHOD go_source_grid->refresh_table_display.
  ENDMETHOD.
has context menu