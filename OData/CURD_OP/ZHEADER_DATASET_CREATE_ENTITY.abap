method ZHEADER_DATASET_CREATE_ENTITY.

    DATA: wa_post type zcl_zji_curd_op_03_mpc=>ts_ZHEADER_DATA,
          wa_headerdata type ZORDER_HEADER_C.
    
      io_data_provider->read_entry_data(
      IMPORTING
        es_data = wa_post
        ).
    
    wa_headerdata-Ono = wa_post-Ono.
    wa_headerdata-Odate = wa_post-Odate.
    wa_headerdata-Pm = wa_post-Pm.
    wa_headerdata-Ta = wa_post-Ta.
    
    INSERT ZORDER_HEADER_C from wa_headerdata.
    
    IF sy-subrc = 0.
      er_entity = wa_post.
    
    ENDIF.
    
      endmethod.