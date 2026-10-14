" Source class của form ZDMO01 — bảng kê chuyến đi theo khách hàng (/DMO/ data).
" Gán vào cột SOURCE_CLASS của template ZDMO01 (app ZUI_XLSX_TMPL_O4).
" Keys: { "customer_id": "1" }. Tên component của ty_form = tên placeholder trong template.
CLASS zcl_zdmo01_source DEFINITION
  PUBLIC FINAL CREATE PUBLIC
  INHERITING FROM zcl_xlsx_source_base.

  PUBLIC SECTION.
    CONSTANTS c_logo_asset TYPE string VALUE `LOGO_COMPANY` ##NO_TEXT.

    TYPES:
      BEGIN OF ty_travel,
        travel_id   TYPE string,
        agency      TYPE string,
        begin_date  TYPE d,
        end_date    TYPE d,
        status      TYPE string,
        total_price TYPE p LENGTH 16 DECIMALS 2,
        currency    TYPE string,
      END OF ty_travel,
      ty_travels TYPE STANDARD TABLE OF ty_travel WITH EMPTY KEY,
      BEGIN OF ty_form,
        logo       TYPE string,
        printed_on TYPE d,
        customer   TYPE string,
        address    TYPE string,
        email      TYPE string,
        travels    TYPE ty_travels,
      END OF ty_form.

    METHODS form_name REDEFINITION.
    METHODS zif_xlsx_source~get_context REDEFINITION.
    METHODS zif_xlsx_source~get_sample REDEFINITION.
ENDCLASS.



CLASS zcl_zdmo01_source IMPLEMENTATION.


  METHOD form_name.
    rv_form_name = `ZDMO01`.
  ENDMETHOD.


  METHOD zif_xlsx_source~get_context.
    DATA lv_customer_id TYPE /dmo/customer_id.

    DATA(lv_key) = key_value( iv_keys = iv_keys iv_name = 'customer_id' ).
    IF lv_key IS INITIAL OR lv_key CN '0123456789'.
      RAISE EXCEPTION NEW zcx_xlsx( iv_text = |Customer ID '{ lv_key }' không hợp lệ| ) ##NO_TEXT.
    ENDIF.
    lv_customer_id = lv_key.

    SELECT SINGLE FROM /dmo/customer
      FIELDS title, first_name, last_name, street, postal_code, city, country_code, email_address
      WHERE customer_id = @lv_customer_id
      INTO @DATA(ls_customer).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_xlsx( iv_text = |Customer { lv_customer_id } không tồn tại trong /DMO/CUSTOMER| ) ##NO_TEXT.
    ENDIF.

    SELECT FROM /dmo/travel AS t
        LEFT OUTER JOIN /dmo/agency AS a ON a~agency_id = t~agency_id
      FIELDS t~travel_id, a~name AS agency, t~begin_date, t~end_date, t~status,
             t~total_price, t~currency_code
      WHERE t~customer_id = @lv_customer_id
      ORDER BY t~begin_date DESCENDING
      INTO TABLE @DATA(lt_travel).

    rr_context = NEW ty_form(
      logo       = asset_b64( c_logo_asset )
      printed_on = cl_abap_context_info=>get_system_date( )
      customer   = condense( |{ ls_customer-title } { ls_customer-first_name } { ls_customer-last_name }| )
      address    = condense( |{ ls_customer-street }, { ls_customer-postal_code } { ls_customer-city }, { ls_customer-country_code }| )
      email      = ls_customer-email_address
      travels    = VALUE #( FOR t IN lt_travel (
                     travel_id   = |{ t-travel_id }|
                     agency      = t-agency
                     begin_date  = t-begin_date
                     end_date    = t-end_date
                     status      = t-status
                     total_price = t-total_price
                     currency    = t-currency_code ) ) ).
  ENDMETHOD.


  METHOD zif_xlsx_source~get_sample.
    " dữ liệu mẫu tĩnh cho nút Preview của app template
    rr_context = NEW ty_form(
      printed_on = cl_abap_context_info=>get_system_date( )
      customer   = `Sample Customer`
      address    = `1 Sample Street, 10000 Sample City, DE`
      email      = `customer@example.com`
      travels    = VALUE #(
        ( travel_id = `00000001` agency = `Sunshine Travel` begin_date = '20261020'
          end_date = '20261025' status = `B` total_price = '2435.00' currency = `EUR` )
        ( travel_id = `00000002` agency = `Fly High` begin_date = '20261105'
          end_date = '20261110' status = `N` total_price = '1180.50' currency = `EUR` ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
