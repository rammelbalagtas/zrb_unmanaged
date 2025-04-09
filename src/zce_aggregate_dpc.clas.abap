CLASS zce_aggregate_dpc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zce_aggregate_dpc IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    CASE io_request->get_entity_id( ).
      WHEN 'ZCE_AGGREGATE'.

        TRY.

            DATA: lr_travel_id   TYPE if_rap_query_filter=>tt_range_option,
                  lr_agency      TYPE if_rap_query_filter=>tt_range_option,
                  lr_customer    TYPE if_rap_query_filter=>tt_range_option,
                  lr_begin_date  TYPE if_rap_query_filter=>tt_range_option,
                  lr_end_date    TYPE if_rap_query_filter=>tt_range_option,
                  lr_booking_fee TYPE if_rap_query_filter=>tt_range_option,
                  lr_total_price TYPE if_rap_query_filter=>tt_range_option,
                  lr_currency    TYPE if_rap_query_filter=>tt_range_option.

            DATA lv_max_rows TYPE int8.
            DATA lv_offset TYPE int8.
            DATA lt_data TYPE STANDARD TABLE OF zce_aggregate WITH NON-UNIQUE KEY travel_id.
            DATA lt_data_final TYPE STANDARD TABLE OF zce_aggregate WITH NON-UNIQUE KEY travel_id.
            DATA ls_data TYPE zce_aggregate.
            DATA lv_sort_string TYPE string.

            "filter
            DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
            TRY.
                DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
                IF lt_filter IS NOT INITIAL.
                  LOOP AT lt_filter INTO DATA(ls_filter).
                    CASE ls_filter-name.
                      WHEN 'TRAVEL_ID'.
                        APPEND LINES OF ls_filter-range TO lr_travel_id. "test
                      WHEN 'AGENCY_ID'.
                        APPEND LINES OF ls_filter-range TO lr_agency.
                      WHEN 'CUSTOMER_ID'.
                        APPEND LINES OF ls_filter-range TO lr_customer.
                      WHEN 'BEGIN_DATE'.
                        APPEND LINES OF ls_filter-range TO lr_begin_date.
                      WHEN 'END_DATE'.
                        APPEND LINES OF ls_filter-range TO lr_end_date.
                      WHEN 'BOOKING_FEE'.
                        APPEND LINES OF ls_filter-range TO lr_booking_fee.
                      WHEN 'TOTAL_PRICE'.
                        APPEND LINES OF ls_filter-range TO lr_total_price.
                      WHEN 'CURRENCY_CODE'.
                        APPEND LINES OF ls_filter-range TO lr_currency.
                      WHEN OTHERS.
                    ENDCASE.
                  ENDLOOP.
                ENDIF.
              CATCH cx_rap_query_filter_no_range.
                "handle exception
            ENDTRY.

            IF io_request->is_data_requested( ).
              "paging
              DATA(lv_offset_request) = io_request->get_paging( )->get_offset( ).
              DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
              DATA(lv_max_rows_request) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                                  THEN 0 ELSE lv_page_size ).
              "requested elements
              DATA(lt_req_elements) = io_request->get_requested_elements( ).

              "aggregated elements
              DATA(lt_aggr_element) = io_request->get_aggregation( )->get_aggregated_elements( ).
              IF lt_aggr_element IS NOT INITIAL.
                LOOP AT lt_aggr_element ASSIGNING FIELD-SYMBOL(<fs_aggr_element>).
                  DELETE lt_req_elements WHERE table_line = <fs_aggr_element>-result_element.
                  DATA(lv_aggregation) = |{ <fs_aggr_element>-aggregation_method }( { <fs_aggr_element>-input_element } ) as { <fs_aggr_element>-result_element }|.
                  APPEND lv_aggregation TO lt_req_elements.
                ENDLOOP.
              ENDIF.

              DATA(lv_req_elements)  = concat_lines_of( table = lt_req_elements sep = `, ` ).

              DATA(lt_grouped_element) = io_request->get_aggregation( )->get_grouped_elements( ).
              DATA(lv_grouping) = concat_lines_of(  table = lt_grouped_element sep = `, ` ).

              "sorting
              DATA(sort_elements) = io_request->get_sort_elements( ).
              DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN sort_elements
                                                         ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true THEN ` descending`
                                                                                                                                         ELSE ` ascending` ) ) ).
              IF lt_aggr_element IS NOT INITIAL.
                lv_sort_string  = COND #( WHEN lt_sort_criteria IS INITIAL THEN ''
                                                                           ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).
              ELSE.
                lv_sort_string = COND #( WHEN lt_sort_criteria IS INITIAL THEN `travel_id ascending`
                                                                          ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).
              ENDIF.

              lv_offset = lv_offset_Request.
              lv_max_rows = lv_max_rows_request.

              IF lt_aggr_element IS NOT INITIAL.
                IF lv_grouping IS INITIAL AND
                   lv_sort_string IS INITIAL.
                  SELECT (lv_req_elements)
                                      FROM /dmo/travel
                                    WHERE travel_id IN @lr_travel_id
                                      AND agency_id IN @lr_agency
                                      AND customer_id IN @lr_customer
                                      AND begin_date IN @lr_begin_date
                                      AND end_date IN @lr_end_date
                                      AND booking_fee IN @lr_booking_fee
                                      AND total_price IN @lr_total_price
                                      AND currency_code IN @lr_currency
                                      INTO CORRESPONDING FIELDS OF TABLE @lt_data_final.
                ELSEIF lv_grouping IS NOT INITIAL AND
                       lv_sort_string IS NOT INITIAL.
                  SELECT (lv_req_elements)
                                      FROM /dmo/travel
                                    WHERE travel_id IN @lr_travel_id
                                      AND agency_id IN @lr_agency
                                      AND customer_id IN @lr_customer
                                      AND begin_date IN @lr_begin_date
                                      AND end_date IN @lr_end_date
                                      AND booking_fee IN @lr_booking_fee
                                      AND total_price IN @lr_total_price
                                      AND currency_code IN @lr_currency
                                      GROUP BY (lv_grouping)
                                      ORDER BY (lv_sort_string)
                                      INTO CORRESPONDING FIELDS OF TABLE @lt_data_final
                                      OFFSET @lv_offset UP TO @lv_max_rows ROWS.
                ELSEIF lv_grouping IS NOT INITIAL AND
                       lv_sort_string IS INITIAL.
                       lv_sort_string = lv_grouping.
                  SELECT (lv_req_elements)
                                      FROM /dmo/travel
                                    WHERE travel_id IN @lr_travel_id
                                      AND agency_id IN @lr_agency
                                      AND customer_id IN @lr_customer
                                      AND begin_date IN @lr_begin_date
                                      AND end_date IN @lr_end_date
                                      AND booking_fee IN @lr_booking_fee
                                      AND total_price IN @lr_total_price
                                      AND currency_code IN @lr_currency
                                      GROUP BY (lv_grouping)
                                      ORDER BY (lv_sort_string)
                                      INTO CORRESPONDING FIELDS OF TABLE @lt_data_final
                                      OFFSET @lv_offset UP TO @lv_max_rows ROWS.
                ENDIF.
              ELSE.
                SELECT (lv_req_elements)
                                    FROM /dmo/travel
                                  WHERE travel_id IN @lr_travel_id
                                    AND agency_id IN @lr_agency
                                    AND customer_id IN @lr_customer
                                    AND begin_date IN @lr_begin_date
                                    AND end_date IN @lr_end_date
                                    AND booking_fee IN @lr_booking_fee
                                    AND total_price IN @lr_total_price
                                    AND currency_code IN @lr_currency
                                    GROUP BY (lv_grouping)
                                    ORDER BY (lv_sort_string)
                                    INTO CORRESPONDING FIELDS OF TABLE @lt_data_final
                                    OFFSET @lv_offset UP TO @lv_max_rows ROWS.
              ENDIF.

              io_response->set_data( lt_data_final ).

            ENDIF.

            IF io_request->is_total_numb_of_rec_requested( ).
              SELECT COUNT( * ) FROM /dmo/travel
                      WHERE travel_id IN @lr_travel_id
                        AND agency_id IN @lr_agency
                        AND customer_id IN @lr_customer
                        AND begin_date IN @lr_begin_date
                        AND end_date IN @lr_end_date
                        AND booking_fee IN @lr_booking_fee
                        AND total_price IN @lr_total_price
                        AND currency_code IN @lr_currency
                        INTO @DATA(lv_total_rows).
              io_response->set_total_number_of_records( lv_total_rows ).
            ENDIF.
          CATCH cx_rap_query_provider.
            io_response->set_data( lt_data ).
            io_response->set_total_number_of_records( 0 ).
        ENDTRY.
      WHEN OTHERS.

    ENDCASE.
  ENDMETHOD.
ENDCLASS.
