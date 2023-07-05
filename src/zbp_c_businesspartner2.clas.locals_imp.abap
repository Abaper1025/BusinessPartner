CLASS lhc_ZC_COSTCENTER DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.


    DATA: gt_BUSINESSPARTNER2 TYPE TABLE OF zp_BUSINESSPARTNER2, "데이터를 담을 테이블
          gs_BUSINESSPARTNER2 TYPE zp_BUSINESSPARTNER2.


    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_businesspartner2 RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_businesspartner2 RESULT result.

    METHODS get_all_data FOR READ
      IMPORTING keys FOR FUNCTION zc_businesspartner2~get_all_data RESULT result.

    METHODS save_log_data FOR READ
      IMPORTING keys FOR FUNCTION zc_businesspartner2~save_log_data RESULT result.

ENDCLASS.

CLASS lhc_ZC_COSTCENTER IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD get_all_data.

    DATA: lt_yemgtt0021 TYPE TABLE OF yemgtt0021,
          ls_yemgtt0021 TYPE yemgtt0021.

    " Parameter로 전달된 테이블을 읽어 Structure 구조로 옮긴다.
    READ TABLE keys INTO DATA(ls_params) INDEX 1.


    SELECT SINGLE upper( group1 ) AS group1,  "거래처구분
                  ktokk                       "
      FROM yemgtt0021
      WHERE group1 EQ @ls_params-%param-p_group
      INTO CORRESPONDING FIELDS OF @ls_yemgtt0021.

    " Parameter가 비어있는지 체크
    IF ls_params IS NOT INITIAL.

      " Parameter로 전달되는 Key값(PType)에 따라 BUSINESSPARTNER의 전체(I), 변경(U) 데이터를 읽는다.
      CASE ls_params-%key.
        WHEN 'I'. "최초 전송 : 전체 데이터 전송
          "전체 데이터를 읽어온다
          SELECT 'I'                                                 AS ptype,         "전체 데이터 표시
                 a~Supplier                                          AS supplier,      "거래처
                 upper( @ls_params-%param-p_GROUP )                  AS group1,        "거래처구분
                 b~SupplierName                                      AS SupplierName,  "거래처명
                 b~TaxNumber2                                        AS TaxNumber2,    "사업자등록번호
                 ' '                                                 AS memo,          "메모
            CASE WHEN b~DeletionIndicator EQ 'X'
                   OR c~BusinessPartnerDeathDate LT @ls_params-%param-p_date THEN 'N' ELSE 'Y'
            END                                                      AS use_yn         "사용여부
            FROM       I_SupplierCompany AS a
            INNER JOIN I_Supplier        AS b ON a~supplier EQ b~supplier
            INNER JOIN I_BusinessPartner AS c ON b~supplier EQ c~BusinessPartner
            WHERE      a~CompanyCode          EQ @ls_params-%param-p_bukrs
              AND      b~SupplierAccountGroup EQ @ls_yemgtt0021-ktokk
             INTO CORRESPONDING FIELDS OF TABLE @gt_BUSINESSPARTNER2.

        WHEN 'U'. "등록/수정/만료 데이터 전송
          SELECT 'U'                                                 AS ptype,         "부분 데이터 표시
                 a~Supplier                                          AS supplier,      "거래처
                 upper( @ls_params-%param-p_GROUP )                  AS group1,        "거래처구분
                 SupplierName                                        AS SupplierName,  "거래처명
                 TaxNumber2                                          AS TaxNumber2,    "사업자등록번호
                 ' '                                                 AS memo,          "메모
    CASE WHEN b~DeletionIndicator EQ 'X'
           OR e~LastChangeDate EQ dats_add_days( @ls_params-%param-p_date , -1 )  THEN 'N' ELSE 'Y'
        END AS use_yn                                                                   "사용여부
        FROM I_SupplierCompany       AS a
        INNER JOIN I_Supplier        AS b ON a~supplier EQ b~supplier
        INNER JOIN I_BusinessPartner AS e ON b~supplier EQ e~BusinessPartner
        WHERE a~CompanyCode          EQ @ls_params-%param-p_bukrs
        AND   b~SupplierAccountGroup EQ @lS_yemgtt0021-ktokk
        AND   b~CreationDate EQ @ls_params-%param-p_date
        INTO CORRESPONDING FIELDS OF TABLE @gt_BUSINESSPARTNER2.


      ENDCASE.
    ENDIF.
    "데이터를 Return 테이블에 담아준다.
    LOOP AT gt_BUSINESSPARTNER2 INTO DATA(gS_BUSINESSPARTNER2).
      APPEND VALUE #( %key = ls_params-%key
                      %param = gS_BUSINESSPARTNER2  ) TO result.
      CLEAR: gS_BUSINESSPARTNER2.
    ENDLOOP.
    DATA: lt_yemgtt0020_2 TYPE TABLE OF yemgtt0020_2,
          ls_yemgtt0020_2 TYPE yemgtt0020_2.


    SELECT bukrs,
           group1,
           lifnr,
           cnt,
           ernam,
           erdat,
           erzet
      FROM yemgtt0020_2
      WHERE bukrs EQ @ls_params-%param-p_bukrs
        AND group1 EQ @ls_params-%param-p_group
      INTO TABLE @DATA(lt_tmp).

    FIELD-SYMBOLS: <fs> TYPE any.

    DATA: ls_fs TYPE REF TO data.
    LOOP AT gt_bUSINESSPARTNER2 INTO gs_bUSINESSPARTNER2.
      FIELD-SYMBOLS: <fs_bukrs>  TYPE any,
                     <fs_group1> TYPE any,
                     <fs_lifnr>  TYPE any,
                     <fs_count>  TYPE any,
                     <fs_ernam>  TYPE any,
                     <fs_erdat>  TYPE any,
                     <fs_erzet>  TYPE any,
                     <fs_aenam>  TYPE any,
                     <fs_aedat>  TYPE any,
                     <fs_aezet>  TYPE any.

      CREATE DATA ls_fs LIKE ls_yemgtt0020_2.
      ASSIGN ls_fs->* TO <fs>.


      CASE ls_params-%key.
        WHEN 'I'. "초기 전송 데이터

          ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs> TO <fs_bukrs>.
          IF sy-subrc EQ 0. <fs_bukrs> = ls_params-%param-p_bukrs. ENDIF.
          ASSIGN COMPONENT 'GROUP1' OF STRUCTURE <fs> TO <fs_group1>.
          IF sy-subrc EQ 0. <fs_group1> = gS_BUSINESSPARTNER2-group1. ENDIF.
          ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs> TO <fs_lifnr>.
          IF sy-subrc EQ 0. <fs_lifnr> = gS_BUSINESSPARTNER2-supplier. ENDIF.


          ASSIGN COMPONENT 'CNT' OF STRUCTURE <fs> TO <fs_count>.
          IF sy-subrc EQ 0. <fs_count> += 1. ENDIF.


          ASSIGN COMPONENT 'ERNAM' OF STRUCTURE <fs> TO <fs_ernam>.
          IF sy-subrc EQ 0. <fs_ernam> = sy-uname. ENDIF.
          ASSIGN COMPONENT 'ERDAT' OF STRUCTURE <fs> TO <fs_erdat>.
          IF sy-subrc EQ 0. <fs_erdat> = sy-datum. ENDIF.
          ASSIGN COMPONENT 'ERZET' OF STRUCTURE <fs> TO <fs_erzet>.
          IF sy-subrc EQ 0. <fs_erzet> = sy-uzeit. ENDIF.
          ASSIGN COMPONENT 'AENAM' OF STRUCTURE <fs> TO <fs_aenam>.
          IF sy-subrc EQ 0. <fs_aenam> = sy-uname. ENDIF.
          ASSIGN COMPONENT 'AEDAT' OF STRUCTURE <fs> TO <fs_aedat>.
          IF sy-subrc EQ 0. <fs_aedat> = sy-datum. ENDIF.
          ASSIGN COMPONENT 'AEZET' OF STRUCTURE <fs> TO <fs_aezet>.
          IF sy-subrc EQ 0. <fs_aezet> = sy-uzeit. ENDIF.

          APPEND <fs> TO lt_yemgtt0020_2.
          CLEAR : ls_yemgtt0020_2.

        WHEN 'U'.
          READ TABLE lt_tmp INTO DATA(ls_tmp) WITH KEY bukrs  = ls_params-%param-p_bukrs
                                                       group1 = gS_BUSINESSPARTNER2-group1
                                                       lifnr  = gS_BUSINESSPARTNER2-supplier.

          IF sy-subrc EQ 0. "기존 저장 되어있고 이후 수정 건
            MOVE-CORRESPONDING ls_tmp TO ls_yemgtt0020_2.
          else.
            "신규 생성되어 저장되는 건
            ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs> TO <fs_bukrs>.
            IF sy-subrc EQ 0. <fs_bukrs> = ls_params-%param-p_bukrs. ENDIF.
            ASSIGN COMPONENT 'GROUP1' OF STRUCTURE <fs> TO <fs_group1>.
            IF sy-subrc EQ 0. <fs_group1> = gS_BUSINESSPARTNER2-group1. ENDIF.
            ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs> TO <fs_lifnr>.
            IF sy-subrc EQ 0. <fs_lifnr> = gS_BUSINESSPARTNER2-supplier. ENDIF.
            ASSIGN COMPONENT 'CNT' OF STRUCTURE <fs> TO <fs_count>.
            IF sy-subrc EQ 0. <fs_count> += 1. ENDIF.
            ASSIGN COMPONENT 'ERNAM' OF STRUCTURE <fs> TO <fs_ernam>.
            IF sy-subrc EQ 0. <fs_ernam> = sy-uname. ENDIF.
            ASSIGN COMPONENT 'ERDAT' OF STRUCTURE <fs> TO <fs_erdat>.
            IF sy-subrc EQ 0. <fs_erdat> = sy-datum. ENDIF.
            ASSIGN COMPONENT 'ERZET' OF STRUCTURE <fs> TO <fs_erzet>.
            IF sy-subrc EQ 0. <fs_erzet> = sy-uzeit. ENDIF.

            ENDIF.
          ASSIGN COMPONENT 'CNT' OF STRUCTURE <fs> TO <fs_count>.
          IF sy-subrc EQ 0. <fs_count> += 1. ENDIF.
          ASSIGN COMPONENT 'AENAM' OF STRUCTURE <fs> TO <fs_aenam>.
          IF sy-subrc EQ 0. <fs_aenam> = sy-uname. ENDIF.
          ASSIGN COMPONENT 'AEDAT' OF STRUCTURE <fs> TO <fs_AEDAT>.
          IF sy-subrc EQ 0. <fs_aedat> = sy-datum. ENDIF.
          ASSIGN COMPONENT 'AEZET' OF STRUCTURE <fs> TO <fs_aezet>.
          IF sy-subrc EQ 0. <fs_aezet> = sy-uzeit. ENDIF.

          APPEND <fs> TO lt_yemgtt0020_2.
      ENDCASE.


      CLEAR : ls_yemgtt0020_2.
    ENDLOOP.

    DATA lv_record_count TYPE i.

    lv_record_count = lines( lt_yemgtt0020_2 ).


    LOOP AT lt_yemgtt0020_2 INTO ls_yemgtt0020_2.
      ls_yemgtt0020_2-cnt = lv_record_count.
      ls_yemgtt0020_2-flag = ls_params-%key-PType.
      ls_yemgtt0020_2-pre_tims = sy-uzeit.
      ls_yemgtt0020_2-pre_date = sy-datum.

      MODIFY yemgtt0020_2 FROM @ls_yemgtt0020_2.
      IF sy-subrc <> 0.
        INSERT INTO yemgtt0020_2 VALUES @ls_yemgtt0020_2.
      ENDIF.
    ENDLOOP.




  ENDMETHOD.


  METHOD save_log_data.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZC_COSTCENTER DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZC_COSTCENTER IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
