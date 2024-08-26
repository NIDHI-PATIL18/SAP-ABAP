method ZHEADER_DATASET_GET_ENTITYSET.

    select MANDT, ONO, ODATE, PM, TA, CURR
      from ZORDER_HEADER_C
      into TABLE @et_entityset up TO 18 ROWS.
    *  where ono = @lv_ono.
    
      endmethod.