CLASS lhc_customer DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CONSTANTS: gc_form_name TYPE string                VALUE `ZDMO01`,
               gc_moduleid  TYPE zde_module_object_dmo VALUE 'DMO',
               gc_appid     TYPE zde_app_id_dmo        VALUE 'ZDMO01'.

  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Customer RESULT result.

    METHODS exportexcel FOR MODIFY
      IMPORTING keys FOR ACTION Customer~ExportExcel RESULT result.
ENDCLASS.


CLASS lhc_customer IMPLEMENTATION.

  METHOD get_global_authorizations.
    " demo: ai mở được app đều xuất được
    result-%action-ExportExcel = if_abap_behv=>auth-allowed.
  ENDMETHOD.


  METHOD exportexcel.
    DATA lt_ok LIKE keys.
    DATA(lo_export) = NEW zcl_xlsx_att_export( iv_module = gc_moduleid
                                               iv_app_id = gc_appid ).

    LOOP AT keys INTO DATA(ls_key).
      TRY.
          " dữ liệu lấy qua source class gán trên template ZDMO01 (ZCL_ZDMO01_SOURCE)
          lo_export->export( iv_form_name   = gc_form_name
                             iv_document_id = CONV #( ls_key-CustomerID )
                             iv_keys        = |\{ "customer_id": "{ ls_key-CustomerID }" \}|
                             iv_file_stem   = |BangKe_{ ls_key-CustomerID }| ) ##NO_TEXT.
        CATCH zcx_xlsx INTO DATA(lx).
          APPEND VALUE #( %tky = ls_key-%tky ) TO failed-customer.
          APPEND VALUE #( %tky = ls_key-%tky
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = |Customer { ls_key-CustomerID }: { lx->get_text( ) }| ) )
            TO reported-customer ##NO_TEXT.
          CONTINUE.
      ENDTRY.

      APPEND ls_key TO lt_ok.
      APPEND VALUE #( %tky = ls_key-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-success
                               text     = |Customer { ls_key-CustomerID }: đã xuất bảng kê| ) )
        TO reported-customer ##NO_TEXT.
    ENDLOOP.

    IF lt_ok IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_zdmo01 IN LOCAL MODE
      ENTITY Customer
        ALL FIELDS WITH CORRESPONDING #( lt_ok )
      RESULT DATA(lt_customer).

    result = VALUE #( FOR c IN lt_customer ( %tky = c-%tky %param = c ) ).
  ENDMETHOD.

ENDCLASS.
