method ZHEADER_DATASET_GET_ENTITY.

    READ TABLE it_key_tab into data(wa_key_tab)
    with key name = 'Ono'.
    
    IF SY-SUBRC = 0.
     data(lv_Ono) = wa_key_tab-value.
    ENDIF.
    
    select single MANDT,ONO, ODATE, PM, TA, CURR
      from ZORDER_HEADER_C
      into @er_entity
      where Ono = @lv_Ono.
    
      endmethod.