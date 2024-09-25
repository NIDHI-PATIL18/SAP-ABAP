METHOD get_data.

    *local structure for VBAK--------------------------------------------*
        TYPES : BEGIN OF lty_data,
                  vbeln TYPE vbeln_va,
                  erdat TYPE erdat,
                  erzet TYPE erzet,
                  ernam TYPE ernam,
                END OF lty_data.
    
        DATA : lt_data TYPE TABLE OF lty_data.
        DATA : ls_data TYPE lty_data.
    
    *local structure for VBAP--------------------------------------------*
        TYPES : BEGIN OF lty_data1,
                  vbeln TYPE vbeln_va,
                  posnr TYPE posnr_va,
                  matnr TYPE matnr,
                END OF lty_data1.
    
        DATA : lt_data1 TYPE TABLE OF lty_data1.
        DATA : ls_data1 TYPE lty_data1.
    
    *Data declaration for the final work area---------------------------*
        DATA : Ls_OUTPUT TYPE zstr_sales_details. "pss the structure type from the SE11
    
    *logic to fetch data from vbak/vbap---------------------------------*
        SELECT vbeln erdat erzet ernam
          FROM vbak
          INTO TABLE Lt_data
          WHERE vbeln = pvbeln.
    
        IF lt_data IS NOT INITIAL. "not blank.
          SELECT vbeln posnr matnr
            FROM vbap
            INTO TABLE lt_data1
            FOR ALL ENTRIES IN lt_data
            WHERE vbeln = lt_data-vbeln.
        ENDIF.
    
    *Nested loop-------------------------------------------------------*
        LOOP AT lt_data INTO ls_data.
          LOOP AT lt_data1 INTO ls_data1 WHERE vbeln = ls_data-vbeln.
            Ls_OUTPUT-vbeln = ls_data-vbeln.
            Ls_OUTPUT-erdat = ls_data-erdat.
            Ls_OUTPUT-erzet = ls_data-erzet.
            Ls_OUTPUT-ernam = ls_data-ernam.
            Ls_OUTPUT-posnr = ls_data1-posnr.
            Ls_OUTPUT-matnr = ls_data1-matnr.
            APPEND Ls_OUTPUT TO lt_output.
            CLEAR : Ls_OUTPUT.
          ENDLOOP.
        ENDLOOP.
    
    
    
      ENDMETHOD.