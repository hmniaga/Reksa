//button click
$("#btnRefresh").click(function btnRefresh_click() {
    subRefresh();
});
$("#btnNew").click(function btnNew_click() {
    subNew();
});
$("#btnEdit").click(function btnEdit_click() {
    if (strMenuName == "mnuMaintainTrxPO") {
        subUpdateAsuransi();
    }
    else {
        subUpdate();
    }
    
});
$("#btnSave").click(function btnSave_click() {
    if (strMenuName == "mnuMaintainTrxPO") {
        subSaveAsuransi();
    }
    else {
        subSave();
    }
});
$("#btnCancel").click(function btnCancel_click() {
    subCancel();
});
$("#btnAddSubs").click(function btnAddSubs_click() {
    subAddSubs();
});
$("#btnEditSubs").click(function btnEditSubs_click() {
    subEditSubs();
});
$("#btnAddRedemp").click(function btnAddRedemp_click() {
    subAddRedemp();
});
$("#btnEditRedemp").click(function btnEditRedemp_click() {
    subEditRedemp();
});
$("#btnAddRDB").click(function btnAddRDB_click() {
    subAddRDB();
});
$("#btnEditRDB").click(function btnEditRDB_click() {
    subEditRDB();
});
$("#_inquiry").click(function _inquiry_click() {
    InquirySisaUnit();
});
$('#btnDocumentSubs').click(function btnDocumentSubs_click() {
    var value = $('#srcNoRefSubs_text1').val();
    $(this).attr('href', function () {
        return '/Global/Document/?IsEdit=false&TranId=0&IsSwitching=false&IsBooking=false,RefID=' + value;
    });
});
$('#btnDocumentRedemp').click(function btnDocumentRedemp_click() {
    var value = $('#srcNoRefRedemp_text1').val();
    $(this).attr('href', function () {
        return '/Global/Document/?IsEdit=false&TranId=0&IsSwitching=false&IsBooking=false,RefID=' + value;
    });
});
$('#btnDocumentRDB').click(function btnDocumentRDB_click() {
    var value = $('#srcNoRefRDB_text1').val();
    $(this).attr('href', function () {
        return '/Global/Document/?IsEdit=false&TranId=0&IsSwitching=false&IsBooking=false,RefID=' + value;
    });
});
$('#btnDocumentSwc').click(function btnDocumentSwc_click() {
    var value = $('#srcNoRefSwc_text1').val();
    $(this).attr('href', function () {
        return '/Global/Document/?IsEdit=false&TranId=0&IsSwitching=true&IsBooking=false,RefID=' + value;
    });
});
$('#btnDocumentSwcRDB').click(function btnDocumentSwcRDB_click() {
    var value = $('#srcNoRefSwcRDB_text1').val();
    $(this).attr('href', function () {
        return '/Global/Document/?IsEdit=false&TranId=0&IsSwitching=true&IsBooking=false,RefID=' + value;
    });
});
$('#btnDocumentBooking').click(function btnDocumentBooking_click() {
    var value = $('#srcNoRefBooking_text1').val();
    $(this).attr('href', function () {
        return '/Global/Document/?IsEdit=false&TranId=0&IsSwitching=false&IsBooking=true,RefID=' + value;
    });
});

//search click
$("#srcCIFSubs").click(function srcCIFSubs_click() {
    var url = $(this).attr("href");
    $('#CustomerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcCIFRedemp").click(function srcCIFRedemp_click() {
    var url = $(this).attr("href");
    $('#CustomerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcCIFRDB").click(function srcCIFRDB_click() {
    var url = $(this).attr("href");
    $('#CustomerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcCIFSwc").click(function srcCIFSwc_click() {
    var url = $(this).attr("href");
    $('#CustomerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcCIFSwcRDB").click(function srcCIFSwcRDB_click() {
    var url = $(this).attr("href");
    $('#CustomerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcCIFBooking").click(function srcCIFBooking_click() {
    var url = $(this).attr("href");
    $('#CustomerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});

$("#srcNoRefSubs").click(function srcNoRefSubs_click() {
    var strCriteria = _strTabName + "#" + $("#srcCIFSubs_text1").val();
    var url = "/Global/SearchReferensi/?criteria=" + encodeURIComponent(strCriteria);
    $('#NoRefModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcNoRefRedemp").click(function srcNoRefRedemp_click() {
    var strCriteria = _strTabName + "#" + $("#srcCIFRedemp_text1").val();
    var url = "/Global/SearchReferensi/?criteria=" + encodeURIComponent(strCriteria);
    $('#NoRefModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcNoRefRDB").click(function srcNoRefRDB_click() {
    var strCriteria = _strTabName + "#" + $("#srcNoRefRDB_text1").val();
    var url = "/Global/SearchReferensi/?criteria=" + encodeURIComponent(strCriteria);
    $('#NoRefModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcNoRefSwcRDB").click(function srcNoRefSwcRDB_click() {
    var CIFNo = $('#srcCIFSwcRDB_text1').val();
    var url = "/Global/SearchSwitchingRDB/?criteria=" + CIFNo;
    $('#NoRefModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcNoRefSwc").click(function srcNoRefSwc_click() {
    var CIFNo = $('#srcCIFSwc_text1').val();
    var url = "/Global/SearchSwitching/?criteria=" + CIFNo;
    $('#NoRefModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcNoRefBooking").click(function srcNoRefBooking_click() {
    var CIFNo = $('#srcCIFBooking_text1').val();
    var url = "/Global/SearchBooking/?criteria=" + CIFNo;
    $('#NoRefModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
}); 

$("#srcProductSubs").click(function srcProductSubs_click() {
    var strCriteria = _strTabName + "#" + $('#srcCIFSubs_text1').val();
    var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(strCriteria);
    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcProductRedemp").click(function srcProductRedemp_click() {
    var strCriteria = _strTabName + "#" + $('#srcCIFRedemp_text1').val();
    var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(strCriteria);
    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcProductRDB").click(function srcProductRDB_click() {
    var strCriteria = _strTabName + "#" + $('#srcCIFRDB_text1').val();
    var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(strCriteria);
    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcProductSwcOut").click(function srcProductSwcOut_click() {
    //var strCriteria = _strTabName + "#" + $('#srcCIFSwc_text1').val();
    //var url = "/Global/SearchTrxProduct/";
    //var target = $(this).attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));
    var url = $(this).attr("href");
    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcProductSwcIn").click(function srcProductSwcIn_click() {
    //var strCriteria = $('#srcProductSwcOut_text1').val();
    //var url = "/Global/SearchTrxProductSwcIn/";
    //var target = $(this).attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));
    var url = $(this).attr("href");
    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcProductSwcRDBOut").click(function srcProductSwcRDBOut_click() {
    var url = $(this).attr("href");
    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcProductSwcRDBIn").click(function srcProductSwcRDBIn_click() {
    var url = $(this).attr("href");
    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcProductBooking").click(function srcProductBooking_click() {
    var strCriteria = _strTabName + "#" + $("#srcCIFBooking_text1").val();
    var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(strCriteria);

    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcClientSubs").click(function srcClientSubs_click() {
    var ProdId = $('#ProdIdSubs').val();
    var url = "/Global/SearchTrxClient/";
    var target = $(this).attr('href', url + '?ProdId=' + ProdId);
    $('#ClientModal .modal-content').load(target, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcClientRedemp").click(function srcClientRedemp_click() {
    var url = $(this).attr("href");
    $('#ClientModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcClientSwcOut").click(function srcClientSwcOut_click() {
    var url = $(this).attr("href");
    $('#ClientModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcClientSwcRDBOut").click(function srcClientSwcRDBOut_click() {
    var url = $(this).attr("href");
    $('#ClientModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});

$("#srcSellerSubs").click(function srcSellerSubs_click() {
    var url = $(this).attr("href");
    $('#SellerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcSellerRedemp").click(function srcSellerRedemp_click() {
    var url = $(this).attr("href");
    $('#SellerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcSellerRDB").click(function srcSellerRDB_click() {
    var url = $(this).attr("href");
    $('#SellerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcSellerSwc").click(function srcSellerSwc_click() {
    var url = $(this).attr("href");
    $('#SellerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcSellerSwcRDB").click(function srcSellerSwcRDB_click() {
    var url = $(this).attr("href");
    $('#SellerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcSellerBooking").click(function srcSellerBooking_click() {
    var url = $(this).attr("href");
    $('#SellerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcWaperdSubs").click(function srcWaperdSubs_click() {
    var url = $(this).attr("href");
    $('#WaperdModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcWaperdRedemp").click(function srcWaperdRedemp_click() {
    var url = $(this).attr("href");
    $('#WaperdModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcWaperdRDB").click(function srcWaperdRDB_click() {
    var url = $(this).attr("href");
    $('#WaperdModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcWaperdSwc").click(function srcWaperdSwc_click() {
    var url = $(this).attr("href");
    $('#WaperdModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcWaperdSwcRDB").click(function srcWaperdSwcRDB_click() {
    var url = $(this).attr("href");
    $('#WaperdModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcWaperdBooking").click(function srcWaperdBooking_click() {
    var url = $(this).attr("href");
    $('#WaperdModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcReferentorSubs").click(function srcReferentorSubs_click() {
    var url = $(this).attr("href");
    $('#NIKRefModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcReferentorRedemp").click(function srcReferentorRedemp_click() {
    var url = $(this).attr("href");
    $('#NIKRefModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcReferentorRDB").click(function srcReferentorRDB_click() {
    var url = $(this).attr("href");
    $('#NIKRefModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcReferentorSwc").click(function srcReferentorSwc_click() {
    var url = $(this).attr("href");
    $('#NIKRefModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcReferentorSwcRDB").click(function srcReferentorSwcRDB_click() {
    var url = $(this).attr("href");
    $('#NIKRefModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcReferentorBooking").click(function srcReferentorBooking_click() {
    var url = $(this).attr("href");
    $('#NIKRefModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});


//checkbox checked change
$("#checkAll").change(function checkAll_CheckedChanged() {
    if (this.checked == true) {
        $("#RedempUnit").data("kendoNumericTextBox").value($("#OutstandingUnitRedemp").data("kendoNumericTextBox").value());
        $("#RedempUnit").data("kendoNumericTextBox").enable(false);
        IsRedempAll = true;
    }
    else {
        $("#RedempUnit").data("kendoNumericTextBox").value(0);
        $("#RedempUnit").data("kendoNumericTextBox").enable(true);
        IsRedempAll = false;
    }
});
$("#checkFeeEditBooking").change(function checkFeeEditBooking_CheckedChanged() {
    if (this.checked) {
        $("#_ComboJenisBooking").data('kendoDropDownList').enable(true);
        $("#MoneyFeeBooking").data("kendoNumericTextBox").enable(true);
        $("#PercentageFeeBooking").data("kendoNumericTextBox").enable(false);
    }
    else {
        $("#_ComboJenisBooking").data('kendoDropDownList').enable(false);
        $("#MoneyFeeBooking").data("kendoNumericTextBox").enable(false);
        $("#PercentageFeeBooking").data("kendoNumericTextBox").enable(false);
        $("#_ComboJenisBooking").data('kendoDropDownList').value(0);
        $("#MoneyNomBooking").data("kendoNumericTextBox").value(Fee);

        var resFee = HitungBookingFee($('#srcCIFSubs_text1').val(), $("#MoneyNomBooking").data("kendoNumericTextBox").value(),
            $('#srcProductBooking_text1').val(), ByPercent, $('#checkFeeEditBooking').prop('checked'),
            $("#MoneyFeeBooking").data("kendoNumericTextBox").value());
        resFee.success(function (data) {
            if (data.blnResult) {
                if ($('#checkFeeEditBooking').prop('checked') == false) {
                    $("#MoneyFeeBooking").data("kendoNumericTextBox").value(data.NominalFee);
                    $("#PercentageFeeBooking").data("kendoNumericTextBox").value(data.PctFee);
                    $("#labelFeeCurrencyBooking").text(data.FeeCurr);
                    $("#_KeteranganFeeBooking").text('%');
                }
                else if ($('#checkFeeEditBooking').prop('checked') == true) {
                    if (ByPercent) {
                        $("#PercentageFeeBooking").data("kendoNumericTextBox").value(data.NominalFee);
                        $("#labelFeeCurrencyBooking").text('%');
                        $("#_KeteranganFeeBooking").text(data.FeeCurr);
                    }
                    else {
                        $("#PercentageFeeBooking").data("kendoNumericTextBox").value(data.PctFee);
                        $("#labelFeeCurrencyBooking").text(data.FeeCurr);
                        $("#_KeteranganFeeBooking").text('%');
                    }
                }
            }
        });
    }
});
$("#checkFeeEditRDB").change(function checkFeeEditRDB_CheckedChanged() {
    if (this.checked) {
        $("#_ComboJenisRDB").data('kendoDropDownList').enable(false);
        $("#MoneyFeeRDB").data("kendoNumericTextBox").enable(false);
        $("#PercentageFeeRDB").data("kendoNumericTextBox").enable(false);
        $("#checkFeeEditRDB").prop('disabled', true);
    }
});
$("#checkFeeEditRedemp").change(function checkFeeEditRedemp_CheckedChanged() {
    var intProdId;
    var intClientid
    var intTranType;
    if (this.checked) {
        $("#_ComboJenisRedemp").data('kendoDropDownList').enable(false);
        $("#_ComboJenisRedemp").data('kendoDropDownList').value(1);
        $("#MoneyFeeRedemp").data("kendoNumericTextBox").enable(true);
        $("#PercentageFeeRedemp").data("kendoNumericTextBox").enable(false);
    }
    else {
        $("#_ComboJenisRedemp").data('kendoDropDownList').enable(false);
        $("#MoneyFeeRedemp").data("kendoNumericTextBox").enable(false);
        $("#PercentageFeeRedemp").data("kendoNumericTextBox").enable(false);

        $("#_ComboJenisRedemp").data('kendoDropDownList').value(1);
        $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(Fee);

        var res = GetImportantData("PRODUKID", $("#srcProductRedemp_text1").val());
        res.success(function (data) {
            intProdId = data.value;
        });
        var res = GetImportantData("CLIENTID", $("#srcClientRedemp_text1").val());
        res.success(function (data) {
            intClientid = data.value;
        });

        if (($("#_ComboJenisRedemp").data("kendoDropDownList").text() == "By %") && ($("#_ComboJenisRedemp").prop('checked') == true)) {
            ByPercent = true;
        }
        else {
            ByPercent = false;
        }
        if (IsRedempAll) {
            intTranType = 4;
        }
        else {
            intTranType = 3;
        }

        var resFee = HitungFee(intProdId, intClientid, intTranType, 0, $("#RedempUnit").data("kendoNumericTextBox").value()
            , false, $("#checkFeeEditRedemp").prop('checked')
            , $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(), 1, $('#srcCIFRedemp_text1').val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(data.PctFee);
                $("#PercentageFeeRedemp").data("kendoNumericTextBox").value(data.NominalFee);
                $("#labelFeeCurrencyRedemp").text("%");
                $("#_KeteranganFeeRedemp").text(data.FeeCurr);
            }
        });
    }
});
$("#checkFeeEditSubs").change(function checkFeeEditSubs_CheckedChanged(){
    var intProdId;
    var intClientid;
    var intTranType;
    if (this.checked) {
        if (_intType != 0) {
            $("#_ComboJenisSubs").data('kendoDropDownList').enable(true);
            $("#MoneyFeeSubs").data("kendoNumericTextBox").enable(true);
            $("#PercentageFeeSubs").data("kendoNumericTextBox").enable(false);
        }
    }
    else {
        if ($("#srcProductSubs_text1").val() != '') {
            $("#_ComboJenisSubs").data('kendoDropDownList').enable(false);
            $("#MoneyFeeSubs").data("kendoNumericTextBox").enable(false);
            $("#PercentageFeeSubs").data("kendoNumericTextBox").enable(false);

            $("#_ComboJenisSubs").data('kendoDropDownList').value(1);
            $("#MoneyFeeSubs").data("kendoNumericTextBox").value(Fee);

            var res = GetImportantData("PRODUKID", $("#srcProductSubs_text1").val());
            res.success(function (data) {
                intProdId = data.value;
            });

            if (IsSubsNew) {
                intTranType = 1;
                intClientid = 0;
            }
            else {
                intTranType = 2;
                var res = GetImportantData("CLIENTID", $("#srcProductSubs_text1").val());
                res.success(function (data) {
                    intClientid = data.value;
                });
            }

            var resFee = HitungFee(intProdId, intClientid, intTranType, $("#MoneyNomSubs").data("kendoNumericTextBox").value(), 0
                , $("#checkFullAmtSubs").prop('checked'), $("#checkFeeEditSubs").prop('checked')
                , $("#PercentageFeeSubs").data("kendoNumericTextBox").value(), 1, $('#srcCIFSubs_text1').val());
            resFee.success(function (data) {
                if (data.blnResult) {
                    $("#MoneyFeeSubs").data("kendoNumericTextBox").value(data.NominalFee);
                    $("#PercentageFeeSubs").data("kendoNumericTextBox").value(data.PctFee);
                    $("#labelFeeCurrencySubs").text("%");
                    $("#_KeteranganFeeSubs").text(data.FeeCurr);
                }
            });
        }
    }
});
$("#checkFeeEditSwc").change(function checkFeeEditSwc_CheckedChanged() {
    if (this.checked) {
        $("#MoneyFeeSwc").data("kendoNumericTextBox").enable(false);
        $("#PercentageFeeSwc").data("kendoNumericTextBox").enable(true);
    }
    else {
        $("#MoneyFeeSwc").data("kendoNumericTextBox").enable(false);
        $("#PercentageFeeSwc").data("kendoNumericTextBox").enable(false);

        $("#MoneyFeeSwc").data("kendoNumericTextBox").value(Fee);
        $("#PercentageFeeSwc").data("kendoNumericTextBox").value(PercentFee);
    }
});
$("#checkFeeEditSwcRDB").change(function checkFeeEditSwcRDB_CheckedChanged() {
    if (this.checked) {
        $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").enable(true);
        $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").enable(true);
    }
    else {
        $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").enable(false);
        $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").enable(false);

        $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").value(Fee);
        $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value(PercentFee);
    }
});
$("#checkFullAmtSubs").change(function checkFullAmtSubs_CheckedChanged() {
    var intProdId;
    var intClientId;
    if (this.checked) {
        $("#checkFeeEditSubs").prop('checked', false)
    }

    if ($('#srcProductSubs_text1').val() != '') {
        $("#_ComboJenisSubs").data('kendoDropDownList').enable(false);
        $("#MoneyFeeSubs").data("kendoNumericTextBox").enable(false);
        $("#PercentageFeeSubs").data("kendoNumericTextBox").enable(false);

        $("#_ComboJenisSubs").data('kendoDropDownList').value(1);
        $("#MoneyFeeSubs").data("kendoNumericTextBox").value(Fee);

        ValidateProduct($("#srcProductSubs_text1").val(), function (result) { intProdId = result[0].ProdId; });

        if (IsSubsNew) {
            intTranType = 1;
            intClientid = 0;
        }
        else {
            intTranType = 2;
            ValidateClient($("#srcClientSubs_text1").val(), intProdId, function (result) { intClientId = result[0].ClientId; });
        }
        var resFee = HitungFee(intProdId, intClientId, intTranType, $("#MoneyNomSubs").data("kendoNumericTextBox").value(), 0
            , $("#checkFullAmtSubs").prop('checked'), $("#checkFeeEditSubs").prop('checked')
            , $("#PercentageFeeSubs").data("kendoNumericTextBox").value(), 1, $('#srcCIFSubs_text1').val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeSubs").data("kendoNumericTextBox").value(data.NominalFee);
                $("#PercentageFeeSubs").data("kendoNumericTextBox").value(data.PctFee);
                $("#labelFeeCurrencySubs").text("%");
                $("#_KeteranganFeeSubs").text(data.FeeCurr);
            }
        });
    }
});
$("#checkSwcAll").change(function checkSwcAll_CheckedChanged() {
    if (this.checked == true) {
        $("#RedempSwc").data("kendoNumericTextBox").value($("#OutstandingUnitSwc").data("kendoNumericTextBox").value());
        $("#RedempSwc").data("kendoNumericTextBox").enable(false);
        IsSwitchingAll = true;
    }
    else {
        $("#RedempSwc").data("kendoNumericTextBox").value(0);
        $("#RedempSwc").data("kendoNumericTextBox").enable(true);
        IsSwitchingAll = false;
    }
});


//textbox change
$("#srcCIFSubs_text1").change(async function srcCIFSubs_text1_change() {
    var intUmur = 0;
    if ($("#srcCIFSubs_text1").val() != "") {
        if (_intType == 1) {
            //if (!CheckCIF($("#srcCIFSubs_text1").val())) {
            //    subCancel();
            //    return;
            //}
        }
        var data = await GetDataCIF($("#srcCIFSubs_text1").val());
        if (data.blnResult) {
            $("#txtbRiskProfileSubs").val(data.RiskProfile);
            var dtpRiskProfileSubs = new Date(data.LastUpdateRiskProfile);
                $("#dtpRiskProfileSubs").val(pad((dtpRiskProfileSubs.getDate()), 2) + '/' + pad((dtpRiskProfileSubs.getMonth() + 1), 2) + '/' + dtpRiskProfileSubs.getFullYear());

            $("#textSIDSubs").val(data.SID);
            $("#textShareHolderIdSubs").val(data.ShareholderID);
            $("#txtUmurSubs").val(data.Umur);
                    
            $("#maskedRekeningSubs").val(data.NoRekening);
            $("#textNamaRekeningSubs").val(data.NamaRekening);
            $("#maskedRekeningSubsUSD").val(data.NoRekeningUSD);
            $("#textNamaRekeningSubsUSD").val(data.NamaRekeningUSD);
            $("#maskedRekeningSubsMC").val(data.NoRekeningMC);
            $("#textNamaRekeningSubsMC").val(data.NamaRekeningMC);
                    
            var criteria = $("#srcCIFSubs_text1").val() + "#" + $("#srcProductSubs_text1").val() + "#" + _strTabName + "#0";
            var url = "/Global/SearchTrxClient/?criteria=" + encodeURIComponent(criteria);
            $('#srcClientSubs').attr('href', url);

            var criteria = _strTabName + "#" + $("#srcCIFSubs_text1").val();
            var url = "/Global/SearchReferensi/?criteria=" + encodeURIComponent(criteria);
            $('#srcNoRefSubs').attr('href', url);

            //intUmur = GlobalFunctionCIF.HitungUmur(cmpsrCIFSubs.Text1);
            //txtUmurSubs.Text = intUmur.ToString();
            if (_intType == 1) {
                //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSubs.Text1)) {
                //    checkPhoneOrderSubs.Enabled = false;
                //    checkPhoneOrderSubs.Checked = false;
                //}
                //else {
                //    checkPhoneOrderSubs.Enabled = true;
                //}
            }                
        }
        else {
            swal("Warning", data.ErrMsg, "warning");
        }
    }
    else
    {
        $("#txtUmurSubs").val("");
        $("#textSIDSubs").val("");
        $("#textShareHolderIdSubs").val("");
        $("#maskedRekeningSubs").val("");
        $("#maskedRekeningSubsUSD").val("");
        $("#maskedRekeningSubsMC").val("");
    }    
});
$("#srcCIFRedemp_text1").change(async function srcCIFRedemp_text1_change() {
    var intUmur = 0;
    if ($("#srcCIFRedemp_text1").val() != "") {
        if (_intType == 1) {
            //if (!CheckCIF($("#srcCIFRedemp_text1").val())) {
            //    subCancel();
            //    return;
            //}
        }
        var data = await GetDataCIF($("#srcCIFRedemp_text1").val());
        if (data.blnResult) {
            $("#txtbRiskProfileRedemp").val(data.RiskProfile);
            var dtpRiskProfileRedemp = new Date(data.LastUpdateRiskProfile);
            $("#dtpRiskProfileRedemp").val(pad((dtpRiskProfileRedemp.getDate()), 2) + '/' + pad((dtpRiskProfileRedemp.getMonth() + 1), 2) + '/' + dtpRiskProfileRedemp.getFullYear());

            $("#textSIDRedemp").val(data.SID);
            $("#textShareHolderIdRedemp").val(data.ShareholderID);
            $("#txtUmurRedemp").val(data.Umur);

            $("#maskedRekeningRedemp").val(data.NoRekening);
            $("#textNamaRekeningRedemp").val(data.NamaRekening);
            $("#maskedRekeningRedempUSD").val(data.NoRekeningUSD);
            $("#textNamaRekeningRedempUSD").val(data.NamaRekeningUSD);
            $("#maskedRekeningRedempMC").val(data.NoRekeningMC);
            $("#textNamaRekeningRedempMC").val(data.NamaRekeningMC);

            var criteria = $("#srcCIFRedemp_text1").val() + "#" + $("#srcProductRedemp_text1").val() + "#" + _strTabName + "#0";
            var url = "/Global/SearchTrxClient/?criteria=" + encodeURIComponent(criteria);
            $('#srcClientRedemp').attr('href', url);

            var criteria = _strTabName + "#" + $("#srcCIFRedemp_text1").val();
            var url = "/Global/SearchReferensi/?criteria=" + encodeURIComponent(criteria);
            $('#srcNoRefRedemp').attr('href', url);

            var criteria = _strTabName + "#" + $("#srcCIFRedemp_text1").val();
            var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(criteria);
            $('#srcProductRedemp').attr('href', url);

            //intUmur = GlobalFunctionCIF.HitungUmur(cmpsrCIFRedemp.Text1);
            //txtUmurRedemp.Text = intUmur.ToString();
            if (_intType == 1) {
                //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFRedemp.Text1)) {
                //    checkPhoneOrderRedemp.Enabled = false;
                //    checkPhoneOrderRedemp.Checked = false;
                //}
                //else {
                //    checkPhoneOrderRedemp.Enabled = true;
                //}
            }
        }
        else {
            swal("Warning", data.ErrMsg, "warning");
        }
    }
    else {
        $("#txtUmurRedemp").val("");
        $("#textSIDRedemp").val("");
        $("#textShareHolderIdRedemp").val("");
        $("#maskedRekeningRedemp").val("");
        $("#maskedRekeningRedempUSD").val("");
        $("#maskedRekeningRedempMC").val("");
    }    
});
$("#srcCIFRDB_text1").change(async function srcCIFRDB_text1_change() {
    var intUmur = 0;
    if ($("#srcCIFRDB_text1").val() != "") {
        if (_intType == 1) {
            //if (!CheckCIF($("#srcCIFRDB_text1").val())) {
            //    subCancel();
            //    return;
            //}
        }
        var data = await GetDataCIF($("#srcCIFRDB_text1").val());
        if (data.blnResult) {
            $("#txtbRiskProfileRDB").val(data.RiskProfile);
            var dtpRiskProfileRDB = new Date(data.LastUpdateRiskProfile);
            $("#dtpRiskProfileRDB").val(pad((dtpRiskProfileRDB.getDate()), 2) + '/' + pad((dtpRiskProfileRDB.getMonth() + 1), 2) + '/' + dtpRiskProfileRDB.getFullYear());

            $("#textSIDRDB").val(data.SID);
            $("#textShareHolderIdRDB").val(data.ShareholderID);
            $("#txtUmurRDB").val(data.Umur);

            $("#maskedRekeningRDB").val(data.NoRekening);
            $("#textNamaRekeningRDB").val(data.NamaRekening);
            $("#maskedRekeningRDBUSD").val(data.NoRekeningUSD);
            $("#textNamaRekeningRDBUSD").val(data.NamaRekeningUSD);
            $("#maskedRekeningRDBMC").val(data.NoRekeningMC);
            $("#textNamaRekeningRDBMC").val(data.NamaRekeningMC);

            var criteria = $("#srcCIFRDB_text1").val() + "#" + $("#srcProductRDB_text1").val() + "#" + _strTabName + "#0";
            var url = "/Global/SearchTrxClient/?criteria=" + encodeURIComponent(criteria);
            $('#srcClientRDB').attr('href', url);

            var criteria = _strTabName + "#" + $("#srcCIFRDB_text1").val();
            var url = "/Global/SearchReferensi/?criteria=" + encodeURIComponent(criteria);
            $('#srcNoRefRDB').attr('href', url);

            //intUmur = GlobalFunctionCIF.HitungUmur(cmpsrCIFRDB.Text1);
            //txtUmurRDB.Text = intUmur.ToString();
            if (_intType == 1) {
                //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFRDB.Text1)) {
                //    checkPhoneOrderRDB.Enabled = false;
                //    checkPhoneOrderRDB.Checked = false;
                //}
                //else {
                //    checkPhoneOrderRDB.Enabled = true;
                //}
            }
        }
        else {
            swal("Warning", data.ErrMsg, "warning");
        }
    }
    else {
        $("#txtUmurRDB").val("");
        $("#textSIDRDB").val("");
        $("#textShareHolderIdRDB").val("");
        $("#maskedRekeningRDB").val("");
        $("#maskedRekeningRDBUSD").val("");
        $("#maskedRekeningRDBMC").val("");
    } 
});
$("#srcCIFBooking_text1").change(async function srcCIFBooking_text1_change() {
    var intUmur = 0;
    if ($("#srcCIFBooking_text1").val() != "") {
        if (_intType == 1) {
            //if (!CheckCIF($("#srcCIFBooking_text1").val())) {
            //    subCancel();
            //    return;
            //}
        }
        var data = await GetDataCIF($("#srcCIFBooking_text1").val());
        if (data.blnResult) {
            $("#txtbRiskProfileBooking").val(data.RiskProfile);
            var dtpRiskProfileBooking = new Date(data.LastUpdateRiskProfile);
            $("#dtpRiskProfileBooking").val(pad((dtpRiskProfileBooking.getDate()), 2) + '/' + pad((dtpRiskProfileBooking.getMonth() + 1), 2) + '/' + dtpRiskProfileBooking.getFullYear());

            $("#textSIDBooking").val(data.SID);
            $("#textShareHolderIdBooking").val(data.ShareholderID);
            $("#txtUmurBooking").val(data.Umur);

            $("#maskedRekeningBooking").val(data.NoRekening);
            $("#textNamaRekeningBooking").val(data.NamaRekening);
            $("#maskedRekeningBookingUSD").val(data.NoRekeningUSD);
            $("#textNamaRekeningBookingUSD").val(data.NamaRekeningUSD);
            $("#maskedRekeningBookingMC").val(data.NoRekeningMC);
            $("#textNamaRekeningBookingMC").val(data.NamaRekeningMC);

            var criteria = $("#srcCIFBooking_text1").val() + "#" + $("#srcProductBooking_text1").val() + "#" + _strTabName + "#0";
            var url = "/Global/SearchTrxClient/?criteria=" + encodeURIComponent(criteria);
            $('#srcClientBooking').attr('href', url);

            var criteria = _strTabName + "#" + $("#srcCIFBooking_text1").val();
            var url = "/Global/SearchReferensi/?criteria=" + encodeURIComponent(criteria);
            $('#srcNoRefBooking').attr('href', url);

            //intUmur = GlobalFunctionCIF.HitungUmur(cmpsrCIFBooking.Text1);
            //txtUmurBooking.Text = intUmur.ToString();
            if (_intType == 1) {
                //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFBooking.Text1)) {
                //    checkPhoneOrderBooking.Enabled = false;
                //    checkPhoneOrderBooking.Checked = false;
                //}
                //else {
                //    checkPhoneOrderBooking..Enabled = true;
                //}
            }
        }
        else {
            swal("Warning", data.ErrMsg, "warning");
        }
    }
    else {
        $("#txtUmurBooking").val("");
        $("#textSIDBooking").val("");
        $("#textShareHolderIdBooking").val("");
        $("#maskedRekeningBooking").val("");
        $("#maskedRekeningBookingUSD").val("");
        $("#maskedRekeningBookingMC").val("");
    }
});
$("#srcCIFSwc_text1").change(async function srcCIFSwc_text1_change() {
    var intUmur = 0;
    if ($("#srcCIFSwc_text1").val() != "") {
        if (_intType == 1) {
            //if (!CheckCIF($("#srcCIFSwc_text1").val())) {
            //    subCancel();
            //    return;
            //}
        }
        var data = await GetDataCIF($("#srcCIFSwc_text1").val());
        if (data.blnResult) {
            $("#txtbRiskProfileSwc").val(data.RiskProfile);
            var dtpRiskProfileSwc = new Date(data.LastUpdateRiskProfile);
            $("#dtpRiskProfileSwc").val(pad((dtpRiskProfileSwc.getDate()), 2) + '/' + pad((dtpRiskProfileSwc.getMonth() + 1), 2) + '/' + dtpRiskProfileSwc.getFullYear());

            $("#textSIDSwc").val(data.SID);
            $("#textShareHolderIdSwc").val(data.ShareholderID);
            $("#txtUmurSwc").val(data.Umur);

            $("#maskedRekeningSwc").val(data.NoRekening);
            $("#textNamaRekeningSwc").val(data.NamaRekening);
            $("#maskedRekeningSwcUSD").val(data.NoRekeningUSD);
            $("#textNamaRekeningSwcUSD").val(data.NamaRekeningUSD);
            $("#maskedRekeningSwcMC").val(data.NoRekeningMC);
            $("#textNamaRekeningSwcMC").val(data.NamaRekeningMC);

            var criteria = $("#srcCIFSwc_text1").val();
            var url = "/Global/SearchReferensi/?criteria=" + encodeURIComponent(criteria);
            $('#srcNoRefSwc').attr('href', url);

            var criteria = _strTabName + "#" + $("#srcCIFSwc_text1").val();
            var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(criteria);
            $('#srcProductSwcOut').attr('href', url);

            var criteria = $("#srcCIFSwc_text1").val() + "#" + $("#srcProductSwcOut_text1").val() + "#" + _strTabName + "#0";
            var url = "/Global/SearchTrxClient/?criteria=" + encodeURIComponent(criteria);
            $('#srcClientSwcOut').attr('href', url);

            //intUmur = GlobalFunctionCIF.HitungUmur(cmpsrCIFSwc.Text1);
            //txtUmurSwc.Text = intUmur.ToString();
            if (_intType == 1) {
                //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSwc.Text1)) {
                //    checkPhoneOrderSwc.Enabled = false;
                //    checkPhoneOrderSwc.Checked = false;
                //}
                //else {
                //    checkPhoneOrderSwc.Enabled = true;
                //}
            }
        }
        else {
            swal("Warning", data.ErrMsg, "warning");
        }
    }
    else {
        $("#txtUmurSwc").val("");
        $("#textSIDSwc").val("");
        $("#textShareHolderIdSwc").val("");
        $("#maskedRekeningSwc").val("");
        $("#maskedRekeningSwcUSD").val("");
        $("#maskedRekeningSwcMC").val("");
    }
});
$("#srcCIFSwcRDB_text1").change(async function srcCIFSwcRDB_text1_change() {
    var intUmur = 0;
    if ($("#srcCIFSwcRDB_text1").val() != "") {
        if (_intType == 1) {
            //if (!CheckCIF($("#srcCIFSwcRDB_text1").val())) {
            //    subCancel();
            //    return;
            //}
        }
        var data = await GetDataCIF($("#srcCIFSwcRDB_text1").val());
            if (data.blnResult) {
                $("#txtbRiskProfileSwcRDB").val(data.RiskProfile);
                var dtpRiskProfileSwcRDB = new Date(data.LastUpdateRiskProfile);
                $("#dtpRiskProfileSwcRDB").val(pad((dtpRiskProfileSwcRDB.getDate()), 2) + '/' + pad((dtpRiskProfileSwcRDB.getMonth() + 1), 2) + '/' + dtpRiskProfileSwcRDB.getFullYear());

                $("#textSIDSwcRDB").val(data.SID);
                $("#textShareHolderIdSwcRDB").val(data.ShareholderID);
                $("#txtUmurSwcRDB").val(data.Umur);

                $("#maskedRekeningSwcRDB").val(data.NoRekening);
                $("#textNamaRekeningSwcRDB").val(data.NamaRekening);
                $("#maskedRekeningSwcRDBUSD").val(data.NoRekeningUSD);
                $("#textNamaRekeningSwcRDBUSD").val(data.NamaRekeningUSD);
                $("#maskedRekeningSwcRDBMC").val(data.NoRekeningMC);
                $("#textNamaRekeningSwcRDBMC").val(data.NamaRekeningMC);

                var criteria = $("#srcCIFSwcRDB_text1").val();
                var url = "/Global/SearchReferensi/?criteria=" + encodeURIComponent(criteria);
                $('#srcNoRefSwcRDB').attr('href', url);

                var criteria = _strTabName + "#" + $("#srcCIFSwcRDB_text1").val();
                var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(criteria);
                $('#srcProductSwcRDBOut').attr('href', url);

                var criteria = $("#srcCIFSwcRDB_text1").val() + "#" + $("#srcProductSwcRDBOut_text1").val() + "#" + _strTabName + "#0";
                var url = "/Global/SearchTrxClient/?criteria=" + encodeURIComponent(criteria);
                $('#srcClientSwcRDBOut').attr('href', url);

                //intUmur = GlobalFunctionCIF.HitungUmur(cmpsrCIFSwcRDB.Text1);
                //txtUmurSwcRDB.Text = intUmur.ToString();
                if (_intType == 1) {
                    //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSwcRDB.Text1)) {
                    //    checkPhoneOrderSwcRDB.Enabled = false;
                    //    checkPhoneOrderSwcRDB.Checked = false;
                    //}
                    //else {
                    //    checkPhoneOrderSwcRDB.Enabled = true;
                    //}
                }
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
    }
    else {
        $("#txtUmurSwcRDB").val("");
        $("#textSIDSwcRDB").val("");
        $("#textShareHolderIdSwcRDB").val("");
        $("#maskedRekeningSwcRDB").val("");
        $("#maskedRekeningSwcRDBUSD").val("");
        $("#maskedRekeningSwcRDBMC").val("");
    }
});
$("#srcNoRefSubs_text2").change(function srcNoRefSubs_text2_change() {
    alert('DEBUG');
    if ($("#srcNoRefSubs_text1").val() == "" && $("#srcNoRefSubs_text2").val() == "") {
        ResetFormSubs();
    }
});
$("#srcOfficeSubs_text1").change(function srcOfficeSubs_text1_change() {
    ValidasiInputKodeKantor($("#srcOfficeSubs_text1").val(), function (strIsAllowed) {
        if (strIsAllowed == "0") {
            swal("Error", "Error [ReksaValidateOfficeId], Kode kantor tidak terdaftar", "warning");
            ResetFormSubs();
        }
    });        
});
$("#srcOfficeRedemp_text1").change(function srcOfficeRedemp_text1_change() {
    ValidasiInputKodeKantor($("#srcOfficeRedemp_text1").val(), function (strIsAllowed) {
        if (strIsAllowed == "0") {
            swal("Error", "Error [ReksaValidateOfficeId], Kode kantor tidak terdaftar", "warning");
            ResetFormRedemp();
        }
    });
});
$("#srcOfficeRDB_text1").change(function srcOfficeRDB_text1_change() {
    ValidasiInputKodeKantor($("#srcOfficeRDB_text1").val(), function (strIsAllowed) {
        if (strIsAllowed == "0") {
            swal("Error", "Error [ReksaValidateOfficeId], Kode kantor tidak terdaftar", "warning");
            ResetFormRDB();
        }
    });
});
$("#srcOfficeSwc_text1").change(function srcOfficeSwc_text1_change() {
    ValidasiInputKodeKantor($("#srcOfficeSwc_text1").val(), function (strIsAllowed) {
        if (strIsAllowed == "0") {
            swal("Error", "Error [ReksaValidateOfficeId], Kode kantor tidak terdaftar", "warning");
            ResetFormSwc();
        }
    });
});
$("#srcOfficeSwcRDB_text1").change(function srcOfficeSwcRDB_text1_change() {
    ValidasiInputKodeKantor($("#srcOfficeSwcRDB_text1").val(), function (strIsAllowed) {
        if (strIsAllowed == "0") {
            swal("Error", "Error [ReksaValidateOfficeId], Kode kantor tidak terdaftar", "warning");
            ResetFormSwcRDB();
        }
    });
});
$("#srcOfficeBooking_text1").change(function srcOfficeBooking_text1_change() {
    ValidasiInputKodeKantor($("#srcOfficeBooking_text1").val(), function (strIsAllowed) {
        if (strIsAllowed == "0") {
            swal("Error", "Error [ReksaValidateOfficeId], Kode kantor tidak terdaftar", "warning");
            ResetFormBooking();
        }
    });
});
$("#srcProductSubs_text1").change(function srcProductSubs_text1_change() {
    $("#srcCurrencySubs_text1").val($("#ProdCCYSubs").val());
    ValidateCurrency($("#srcCurrencySubs_text1").val(), function (output) {
        $("#srcCurrencySubs_text2").val(output);
    });
    var strCriteria = $("#srcCIFSubs_text1").val() + "#" + $("#srcProductSubs_text1").val() + "#" + _strTabName + "#0";
    var url = "/Global/SearchTrxClient/";
    var target = $(this).attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));
    $('#srcClientSubs').attr('href', target);
    if (_intType == 1) {
        var ClientCodeSubsAdd = "";
        var res = CheckIsSubsNew($("#srcCIFSubs_text1").val(), $("#ProdIdSubs").val(), false);
        res.success(function (data) {
            if (data.blnResult) {
                IsSubsNew = data.IsSubsNew;
                ClientCodeSubsAdd = data.strClientCode;
            }
            else {
                IsSubsNew = false;
                ClientCodeSubsAdd = "";
            }
        });

        if (IsSubsNew) {
            $("#srcClientSubs_text1").prop('disabled', true);
            $("#srcClientSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        }
        else {
            $("#srcClientSubs_text1").prop('disabled', true);
            $("#srcClientSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
            $("#srcClientSubs_text1").val(ClientCodeSubsAdd);
            //cmpsrClientSwcIn.ValidateField();
        }
    }
});
$("#srcProductRedemp_text1").change(function srcProductRedemp_text1_change() {
    var strCriteria = $('#srcCIFRedemp_text1').val() + "#" + $('#srcProductRedemp_text1').val() + "#" + _strTabName + "#0";
    var url = "/Global/SearchTrxClient/";
    $('#srcClientRedemp').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));
});
$("#srcProductRDB_text1").change(function srcProductRDB_text1_change() {
    $("#srcCurrencyRDB_text1").val($("#ProdCCYRDB").val());
    ValidateCurrency($("#srcCurrencyRDB_text1").val(), function (output) {
        $("#srcCurrencyRDB_text2").val(output);
    });
    var strCriteria = $("#srcCIFRDB_text1").val() + "#" + $("#srcProductRDB_text1").val() + "#" + _strTabName + "#0";
    var url = "/Global/SearchTrxClient/";
    var target = $(this).attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));
    $('#srcClientRDB').attr('href', target);
    IsSubsNew = true;
});
$("#srcProductSwcIn_text1").change(function srcProductSwcIn_text1_change() {
    if ($("#srcProductSwcIn_text1").val() != "") {
        var strCriteria = $('#ProdIdSwcIn').val() + "#" + $('#srcCIFSwc_text1').val() + "#0";
        var url = "/Global/SearchClientSwcIn/";
        $('#srcClientSwcIn').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));

        var res = GetLatestNAV($("#ProdIdSwcIn").val());
        res.success(function (data) {
            if (data.blnResult) {
                _NAVSwcInNonRDB = data.NAV;
            }
        });
        if (_intType == 1) {
            var ClientCodeSwcIn = "";

            var res = CheckIsSubsNew($("#srcCIFSwc_text1").val(), $("#ProdIdSwcIn").val(), false);
            res.success(function (data) {
                if (data.blnResult) {
                    IsSubsNew = data.IsSubsNew;
                    ClientCodeSwcIn = data.strClientCode;
                    console.log(IsSubsNew);
                }
                else {
                    IsSubsNew = false;
                    ClientCodeSwcIn = "";
                    swal("Warning", data.ErrMsg, "warning");
                }
            });

            if (IsSubsNew) {
                $("#srcClientSwcIn_text1").prop('disabled', true);
                $("#srcClientSwcIn").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
            }
            else {
                $("#srcClientSwcIn_text1").prop('disabled', true);
                $("#srcClientSwcIn").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
                $("#srcClientSwcIn_text1").val(ClientCodeSwcIn);
                //cmpsrClientSwcIn.ValidateField();
            }
        }
        var resFee = HitungSwitchingFee($("#srcProductSwcOut_text1").val(), $("#srcProductSwcIn_text1").val()
            , true, 0, $("#RedempSwc").data("kendoNumericTextBox").value()
            , $("#checkFeeEditSwc").prop('checked')
            , $("#PercentageFeeSwc").data("kendoNumericTextBox").value(), $("#IsEmployeeSwcOut").val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeSwc").data("kendoNumericTextBox").value(data.calcFeeResult.Fee);
                $("#PercentageFeeSwc").data("kendoNumericTextBox").value(data.calcFeeResult.PercentageOutput);
                $("#labelFeeCurrencySwc").text(data.calcFeeResult.FeeCCY);
            }
        });
    }
});
$("#srcProductSwcRDBIn_text1").change(function srcProductSwcRDBIn_text1_change() {
    if ($("#srcProductSwcRDBIn_text1").val() != "") {
        var res = GetDataRDB($("#srcClientSwcRDBOut_text1").val());
        var DoneDebet = "";
        res.success(function (data) {
            if (data.blnResult) {
                if (data.listClientRDB.length > 0) {
                    DoneDebet = listClientRDB.IsDoneDebet;
                }
                if ($("#JangkaWktSwcRDB").val() == 0 && (DoneDebet == "1")) {
                    $("#RedempSwcRDB").data("kendoNumericTextBox").enable(true);
                    var strCriteria = $("#srcCIFSwcRDB_text1").val() + $("#srcProductSwcRDBIn_text1").val() + "#SWCNONRDB";
                    $('#srcClientSwcRDBIn').attr('href', '/Global/SearchTrxProduct/?criteria=' + strCriteria);
                    IsSwitchingRDBSebagian = true;
                }
                else {
                    $("#RedempSwcRDB").data("kendoNumericTextBox").enable(false);
                    $("#RedempSwcRDB").data("kendoNumericTextBox").value($("#OutstandingUnitSwcRDB").val());
                    var strCriteria = $("#srcCIFSwcRDB_text1").val() + $("#srcProductSwcRDBIn_text1").val() + "#" + _strTabName;
                    $('#srcClientSwcRDBIn').attr('href', '/Global/SearchTrxProduct/?criteria=' + strCriteria);
                    IsSwitchingRDBSebagian = false;
                }
            }
        });

        if ((_intType == 1) && ($("#JangkaWktSwcRDB").val() == 0) && (DoneDebet == "1")) {
            console.log($("#srcCIFSwcRDB_text1").val());
            var res = CheckIsSubsNew($("#srcCIFSwcRDB_text1").val(), $("#ProdIdSwcRDBIn").val(), false);
            res.success(function (data) {
                if (data.blnResult) {
                    IsSubsNew = data.IsSubsNew;
                    ClientCodeSwcIn = data.strClientCode;
                }
                else {
                    IsSubsNew = false;
                    ClientCodeSwcIn = "";
                }
            });
            if (IsSubsNew) {
                $("#srcClientSwcRDBIn_text1").prop('disabled', true);
                $("#srcClientSwcRDBIn").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
            }
            else {
                $("#srcClientSwcRDBIn_text1").prop('disabled', true);
                $("#srcClientSwcRDBIn").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
                $("#srcClientSwcRDBIn_text1").val(ClientCodeSwcIn);
                //cmpsrClientSwcRDBIn.ValidateField();
            }
        }
    }
});
$("#srcProductSwcOut_text1").change(function srcProductSwcOut_text1_change() {
    var strCriteria = $('#srcCIFSwc_text1').val() + "#" + $('#srcProductSwcOut_text1').val() + "#" + _strTabName + "#0";
    var url = "/Global/SearchTrxClient/";
    $('#srcClientSwcOut').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));

    var strCriteria = $('#srcProductSwcOut_text1').val();
    var url = "/Global/SearchTrxProductSwcIn/";
    $('#srcProductSwcIn').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria) + "&isRDB=false");

    //cmpsrProductSwcIn.Text1 = "";
    //cmpsrProductSwcIn.ValidateField();
    //cmpsrClientSwcIn.Text1 = "";
    //cmpsrClientSwcIn.ValidateField();

    var res = GetLatestNAV($("#ProdIdSwcOut").val());
    res.success(function (data) {
        if (data.blnResult) {
            _NAVSwcOutNonRDB = data.NAV;
        }
    });
});
$("#srcProductSwcRDBOut_text1").change(function srcProductSwcRDBOut_text1_change() {
    var strCriteria = $('#srcCIFSwcRDB_text1').val() + "#" + $('#srcProductSwcRDBOut_text1').val() + "#" + _strTabName + "#0";
    var url = "/Global/SearchTrxClient/";
    $('#srcClientSwcRDBOut').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));

    var strCriteria = $('#srcProductSwcRDBOut_text1').val();
    var url = "/Global/SearchTrxProductSwcIn/";
    $('#srcProductSwcRDBIn').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria) + "&isRDB=true");
    //cmpsrProductSwcRDBIn.Text1 = "";
    //cmpsrProductSwcRDBIn.ValidateField();
    //cmpsrClientSwcRDBIn.Text1 = "";
    //cmpsrClientSwcRDBIn.ValidateField();
});
$("#srcProductBooking_text1").change(function srcProductBooking_text1_change() {
    $("#srcCurrencyBooking_text1").val($("#ProdCCYBooking").val());
    ValidateCurrency($("#ProdCCYBooking").val(), function (output) {
        $("#srcCurrencyBooking_text2").val(output);
    });
});
$("#srcClientRedemp_text1").change(async function srcClientRedemp_text1_change() {
    var ClientId;
    var IsRDB;
    var criteria = $("#srcCIFRedemp_text1").val() + "#" + $("#srcProductRedemp_text1").val() + "#" + _strTabName + "#0";
    var data = await ValidateTrxClient($("#srcClientRedemp_text1").val(), criteria);
    $("#srcClientRedemp_text2").val(data.ClientName);
    ClientId = data.ClientId;
    IsRDB = data.IsRDB;
    var res = GetLatestBalance(ClientId);
    res.success(function (data) {
        if (data.blnResult) {
            $("#OutstandingUnitRedemp").data("kendoNumericTextBox").value(data.unitBalance);
        }
    });
    if ((IsRDB== "Y") && (_intType == 1))
    {
        var res = GetDataRDB($("#srcClientRedemp_text1").val());
        res.success(function (data) {
            if (data.blnResult) {
                if (data.listClientRDB.length > 0) {
                    var decJangkaWaktu = data.listClientRDB[0].SisaJangkaWaktu;
                    var dtJatuhTempo = data.listClientRDB[0].JatuhTempo;
                    var DoneDebet = data.listClientRDB[0].IsDoneDebet;
                    if (decJangkaWaktu > 0) {
                        $("#checkAll").prop('checked', true);
                        $("#checkAll").prop('disabled', true);
                        $("#RedempUnit").data("kendoNumericTextBox").enable(false);
                        IsRedempAll = true;
                        $("#checkFeeEditRedemp").prop('disabled', true);
                    }
                    else {
                        $("#checkAll").prop('checked', false);
                        $("#checkAll").prop('disabled', false);
                        $("#RedempUnit").data("kendoNumericTextBox").enable(true);
                        $("#checkFeeEditRedemp").prop('disabled', true);
                    }
                }
            }
        });
    }
    else if ((IsRDB == "Y") && (_intType == 2)) {
        $("#checkAll").prop('disabled', true);
        $("#RedempUnit").data("kendoNumericTextBox").enable(false);
        $("#checkFeeEditRedemp").prop('disabled', true);
    }
    else if ((IsRDB == "N") && (_intType == 1)) {
        $("#checkAll").prop('disabled', false);
        $("#RedempUnit").data("kendoNumericTextBox").enable(true);
        $("#checkFeeEditRedemp").prop('disabled', false);
    }
    else if ((IsRDB == "N") && (_intType == 2)) {
        $("#checkAll").prop('disabled', true);
        $("#RedempUnit").data("kendoNumericTextBox").enable(false);
        $("#checkFeeEditRedemp").prop('disabled', false);;
    }

});
$("#srcClientSwcIn_text1").change(function srcClientSwcIn_text1_change() {
    if (!IsSubsNew) {
        var res = GetLatestBalance($("#ClientIdSwcIn").val());
        res.success(function (data) {
            console.log(data);
            if (data.blnResult) {
                OutstandingUnitSwcIn = data.unitBalance;
            }
        });
    }
    else {
        OutstandingUnitSwcIn = 0;
    }
});
$("#srcClientSwcOut_text1").change(function srcClientSwcOut_text1_change() {
    if ($("#srcClientSwcIn_text1").val() != "") {
        var strCriteria = $('#ProdIdSwcIn').val() + "#" + $('#srcCIFSwc_text1').val() + "#0";
        var url = "/Global/SearchClientSwcIn/";
        $('#srcClientSwcIn').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));
    }
    var OutstandingBalance;
    var res = GetLatestBalance($("#ClientIdSwcOut").val());
    res.success(function (data) {
        if (data.blnResult) {
            OutstandingBalance = data.unitBalance;
            $("#OutstandingUnitSwc").data("kendoNumericTextBox").value(OutstandingBalance);
        }
    });
});
$("#srcClientSwcRDBOut_text1").change(async function srcClientSwcRDBOut_text1_change() {
    var ClientId;
    var IsRDB;
    var criteria = $("#srcCIFSwcRDB_text1").val() + "#" + $("#srcProductSwcRDBOut_text1").val() + "#" + _strTabName + "#0";
    
    var data = await ValidateTrxClient($("#srcClientSwcRDBOut_text1").val(), criteria);
    $("#srcClientSwcRDBOut_text2").val(data.ClientName);
    ClientId = data.ClientId;
    IsRDB = data.IsRDB;

    var res = GetLatestBalance(ClientId);
    res.success(function (data) {
        if (data.blnResult) {
            $("#OutstandingUnitSwcRDB").data("kendoNumericTextBox").value(data.unitBalance);
        }
    });

    var res = GetDataRDB($("#srcClientSwcRDBOut_text1").val());
    res.success(function (data) {
        if (data.blnResult) {
            if (data.listClientRDB.length > 0) {
                var decJangkaWaktu = data.listClientRDB[0].SisaJangkaWaktu;
                var dtJatuhTempo = data.listClientRDB[0].JatuhTempo;
                var DoneDebet = data.listClientRDB[0].IsDoneDebet;

                $("#JangkaWktSwcRDB").val(decJangkaWaktu);
                var JatuhTempo = new Date(dtJatuhTempo);
                $("#dtJatuhTempoSwcRDB").val(pad((JatuhTempo.getDate()), 2) + '/' + pad((JatuhTempo.getMonth() + 1), 2) + '/' + JatuhTempo.getFullYear());
                $("#cmbFrekPendebetanSwcRDB").data('kendoDropDownList').value(data.listClientRDB[0].FrekPendebetan);

                if ((decJangkaWaktu == 0) && (DoneDebet == "1")) {
                    $("#RedempSwcRDB").data("kendoNumericTextBox").enable(true);
                    var strCriteria = $('#srcCIFSwcRDB_text1').val() + "#" + $('#srcProductSwcRDBIn_text1').val() + "#SWCNONRDB#0";
                    var url = "/Global/SearchTrxClient/";
                    $('#srcClientSwcRDBIn').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));
                    IsSwitchingRDBSebagian = false;
                }
                else {
                    $("#RedempSwcRDB").data("kendoNumericTextBox").enable(false);
                    $("#RedempSwcRDB").data("kendoNumericTextBox").value($("#OutstandingUnitSwcRDB").data("kendoNumericTextBox").value());
                    IsSwitchingRDBSebagian = false;
                    IsSubsNew = true;
                    IsSwitchingRDBSebagian = true;
                }
                if (data.listClientRDB[0].AutoRedemption == "1") {
                    $("#cmbAutoRedempSwcRDB").data('kendoDropDownList').value(0);
                }
                else {
                    $("#cmbAutoRedempSwcRDB").data('kendoDropDownList').value(1);
                }
                if (data.listClientRDB[0].Asuransi == "1") {
                    $("#cmbAsuransiSwcRDB").data('kendoDropDownList').value(0);
                }
                else {
                    $("#cmbAsuransiSwcRDB").data('kendoDropDownList').value(1);
                }
            }
        }
    });

    if ((IsRDB == "Y") && (_intType == 1)) {
        
    }
    else if ((IsRDB == "Y") && (_intType == 2)) {
        $("#checkAll").prop('disabled', true);
        $("#RedempUnit").data("kendoNumericTextBox").enable(false);
        $("#checkFeeEditRedemp").prop('disabled', true);
    }
    else if ((IsRDB == "N") && (_intType == 1)) {
        $("#checkAll").prop('disabled', false);
        $("#RedempUnit").data("kendoNumericTextBox").enable(true);
        $("#checkFeeEditRedemp").prop('disabled', false);
    }
    else if ((IsRDB == "N") && (_intType == 2)) {
        $("#checkAll").prop('disabled', true);
        $("#RedempUnit").data("kendoNumericTextBox").enable(false);
        $("#checkFeeEditRedemp").prop('disabled', false);;
    }

});
$("#srcCurrencySubs_text1").change(function srcCurrencySubs_text1_change() {
    $("#labelFeeCurrencySubs").val($("#srcCurrencySubs_text1").val());
    $("#_KeteranganFeeSubs").val('%');
});
$("#srcSellerSubs_text1").change(function srcSellerSubs_text1_change() {
    $("#srcWaperdSubs_text1").val($("#srcSellerSubs_text1").val());
    ValidateWaperd($("#srcSellerSubs_text1").val(), function (result) {
        if (result != '') {
            $("#srcWaperdSubs_text2").val(result[0].WaperdNo);
            $("#textExpireWaperdSubs").val(result[0].DateExpire);
        }
        else {
            $("#srcWaperdSubs_text1").val('');
            $("#srcWaperdSubs_text2").val('');
            $("#textExpireWaperdSubs").val('');
        }
    });
});
$("#srcSellerRedemp_text1").change(function srcSellerRedemp_text1_change() {
    $("#srcWaperdRedemp_text1").val($("#srcSellerRedemp_text1").val());
    ValidateWaperd($("#srcSellerRedemp_text1").val(), function (result) {
        if (result != '') {
            $("#srcWaperdRedemp_text2").val(result[0].WaperdNo);
            $("#textExpireWaperdRedemp").val(result[0].DateExpire);
        }
        else {
            $("#srcSellerRedemp_text1").val('');
            $("#srcWaperdRedemp_text2").val('');
            $("#textExpireWaperdRedemp").val('');
        }
    });
});
$("#srcSellerRDB_text1").change(function srcSellerRDB_text1_change() {
    $("#srcWaperdRDB_text1").val($("#srcSellerRDB_text1").val());
    ValidateWaperd($("#srcSellerRDB_text1").val(), function (result) {
        if (result != '') {
            $("#srcWaperdRDB_text2").val(result[0].WaperdNo);
            $("#textExpireWaperdRDB").val(result[0].DateExpire);
        }
        else {
            $("#srcSellerRDB_text1").val('');
            $("#srcWaperdRDB_text2").val('');
            $("#textExpireWaperdRDB").val('');
        }
    });
});
$("#srcSellerSwc_text1").change(function srcSellerSwc_text1_change() {
    $("#srcWaperdSwc_text1").val($("#srcSellerSwc_text1").val());
    ValidateWaperd($("#srcSellerSwc_text1").val(), function (result) {
        if (result != '') {
            $("#srcWaperdSwc_text2").val(result[0].WaperdNo);
            $("#textExpireWaperdSwc").val(result[0].DateExpire);
        }
        else {
            $("#srcSellerSwc_text1").val('');
            $("#srcWaperdSwc_text2").val('');
            $("#textExpireWaperdSwc").val('');
        }
    });

});
$("#srcSellerSwcRDB_text1").change(function srcSellerSwcRDB_text1_change() {
    $("#srcWaperdSwcRDB_text1").val($("#srcSellerSwcRDB_text1").val());
    ValidateWaperd($("#srcSellerSwcRDB_text1").val(), function (result) {
        if (result != '') {
            $("#srcWaperdSwcRDB_text2").val(result[0].WaperdNo);
            $("#textExpireWaperdSwcRDB").val(result[0].DateExpire);
        }
        else {
            $("#srcSellerSwcRDB_text1").val('');
            $("#srcWaperdSwcRDB_text2").val('');
            $("#textExpireWaperdSwcRDB").val('');
        }
    });

});
$("#srcSellerBooking_text1").change(function srcSellerBooking_text1_change() {
    $("#srcWaperdBooking_text1").val($("#srcSellerBooking_text1").val());
    ValidateWaperd($("#srcSellerBooking_text1").val(), function (result) {
        if (result != '') {
            $("#srcWaperdBooking_text2").val(result[0].WaperdNo);
            $("#textExpireWaperdBooking").val(result[0].DateExpire);
        }
        else {
            $("#srcSellerBooking_text1").val('');
            $("#srcWaperdBooking_text2").val('');
            $("#textExpireWaperdBooking").val('');
        }
    });

});
$("#srcWaperdSubs_text1").change(function srcWaperdSubs_text1_change() {
    alert('DEBUG WOI');
    if ($("#srcWaperdSubs_text1").val() != "") {
        var TanggalExpire = new Date($("#textExpireWaperdSubs").val(""));
        console.log(TanggalExpire);
    }
    else
    {
        $("#textExpireWaperdSubs").val("");
    }
});

//tab click
$('a[data-toggle=tab]').click(function _tabJenisTransaksi_Selected() {
    _strTabName = this.id;
    var url = "/Global/SearchReferensi/?criteria=" + _strTabName;
    $('#srcRefSubs').attr('href', url);
    $('#srcRefRedemp').attr('href', url);
    $('#srcRefRDB').attr('href', url);
    if (_strTabName == "SWCRDB")
    {
        document.getElementById("btnEdit").disabled = true;
    }
    else {
        document.getElementById("btnEdit").disabled = false;
    }
});

//validate search
function ValidateOffice(OfficeId, result) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateOffice',
        data: { Col1: OfficeId, Col2: '', Validate: 1 },
        success: function (data) {
            if (data.length != 0) {
                result(data[0].OfficeName);
            } else {
                result("");
            }
        },
        error: function (error) {
            result("");
        }
    });
}
function ValidateReferentor(ReferentorID, result) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateReferentor',
        data: { Col1: ReferentorID, Col2: '', Validate: 1 },
        success: function (data) {
            if (data.length != 0) {
                result(data[0].NAME);
            }
            else {
                result('');
            }
        }
    });
}
function ValidateWaperd(EmployeeId, result) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateWaperd',
        data: { Col1: EmployeeId, Col2: '', Validate: 1 },
        success: function (data) {
            if (data.length != 0) {
                result(data);
            }
            else {
                result('');
            }
        }
    });
}
function ValidateClient(ClientCode, ProdId, result) {
    if (ClientCode != '') {
        $.ajax({
            type: 'GET',
            url: '/Global/ValidateClient',
            data: { Col1: ClientCode, Col2: '', Validate: 1, ProdId: ProdId },
            success: function (data) {
                if (data.length != 0) {
                    result(data);
                } 
            }
        });
    }
}
function ValidateTrxClient(ClientCode, criteria) {
    if (ClientCode != '') {
        return new Promise((resolve, reject) => {
        $.ajax({
            type: 'GET',
            url: '/Global/ValidateTrxClient',
            data: { Col1: ClientCode, Col2: '', Validate: 1, criteria: encodeURIComponent(criteria) },
            success: function (data) {
                if (data.length != 0) {
                    resolve({
                        //blnResult: data.blnResult,
                        //ErrMsg: data.ErrMsg,
                        ClientName: data[0].ClientName,
                        ClientId: data[0].ClientId,
                        IsRDB: data[0].IsRDB
                    })
                }
            },
            error: reject
            });
        })
    }
}


function ValidateProduct(ProductCode, result) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateProduct',
        data: { Col1: ProductCode, Col2: '', Validate: 1 },
        success: function (data) {
            if (data.length != 0) {
                result(data);
            }
            else {
                result('');
            }
        }
    });
}
function ValidateCurrency(CurrCode, result) {
    if (CurrCode != '') {
        $.ajax({
            type: 'GET',
            url: '/Global/ValidateCurrency',
            data: { Col1: CurrCode, Col2: '', Validate: 1 },
            success: function (data) {
                if (data.length != 0) {
                    result(data[0].CurrencyName);
                } else {
                    result('');
                }
            }
        });
    }
}
function ValidasiKodeKantor(strKodeKantor, result) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateOfficeId',
        data: { OfficeId: strKodeKantor },
        success: function (data) {
            if (data.blnResult) {
                if (data.isAllowed == true) {
                    //_tabJenisTransaksi.Enabled = true;
                    result(true);
                } else {
                    subCancel();
                    //_tabJenisTransaksi.Enabled = false;
                    swal("Warning", "Kode Kantor tidak terdaftar, transaksi reksadana tidak dapat dilakukan!", "warning");
                    $("#btnRefresh").hide();
                    $("#btnNew").hide();
                    $("#btnEdit").hide();
                    $("#btnSave").hide();
                    $("#btnCancel").hide();
                    result(false);
                }
            }
            else {
                swal("Error", data.strErrMsg, "error");
                result(false);
            }
        }
    });
}
function ValidasiCBOKodeKantor(strKodeKantor, IsEnable) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateOfficeId',
        data: { OfficeId: strKodeKantor },
        success: function (data) {
            if (data.blnResult) {
                IsEnable(data.IsEnable);
            }
            else {
                IsEnable(false);
            }
        }
    });
}
function ValidasiInputKodeKantor(strKodeKantor, strIsAllowed)
{
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateOfficeId',
        data: { OfficeId: strKodeKantor },
        success: function (data) {
            if (data.blnResult) {
                strIsAllowed(data.isAllowed);
            }
            else {
                strIsAllowed("0");
            }
        }
    });
}
function ValidateReferensi(Noref, Criteria, result) {
    if (CurrCode != '') {
        $.ajax({
            type: 'GET',
            url: '/Global/ValidateReferensi',
            data: { Col1: Noref, Col2: '', Validate: 1, Criteria },
            success: function (data) {
                if (data.length != 0) {
                    result(data[0].TanggalTransaksi);
                } else {
                    result('');
                }
            }
        });
    }
}


//dropdown change
function cmbAutoRedempRDB_Validating() {
    console.log($("#cmbAutoRedempRDB").data("kendoDropDownList").text());
    console.log($("#cmbAutoRedempRDB").prop('disabled'));
    if (($("#cmbAutoRedempRDB").data("kendoDropDownList").text() == "Ya") && ($("#cmbAutoRedempRDB").prop('disabled') == false)) {

        swal({
            title: "Information",
            text: "Apakah yakin ingin memilih Auto Redemption?",
            type: "warning",
            showCancelButton: true,
            confirmButtonClass: 'btn-info',
            confirmButtonText: "Yes",
            closeOnConfirm: true,
            closeOnCancel: true
        },
            function (isConfirm) {
                if (!isConfirm) {
                    $("#cmbAutoRedempRDB").data("kendoDropDownList").value(0);
                    return;
                }
            });
    }
}
function _ComboJenisBooking_SelectedIndexChanged()
{
    $("#MoneyFeeBooking").val(0);
    $("#PercentageFeeBooking").val(0);

    if ($("#_ComboJenisBooking").data("kendoDropDownList").text() == "By %")
    {
        $("#_KeteranganFeeBooking").text($("#srcCurrencyBooking_text1").val());
        $("#labelFeeCurrencyBooking").text("%");
        ByPercent = true;
        //$("#MoneyFeeBooking").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 3 });
    }
    else {
        $("#_KeteranganFeeBooking").text("%");
        $("#labelFeeCurrencyBooking").text($("#srcCurrencyBooking_text1").val());
        ByPercent = false;
        //$("#MoneyFeeBooking").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 2 });
    }
}
function _ComboJenisRDB_SelectedIndexChanged()
{
    $("#pMoneyFeeRDB").val(0);
    $("#PercentageFeeRDB").val(0);

    if ($("#_ComboJenisRDB").data("kendoDropDownList").text() == "By %") {
        $("#_KeteranganFeeRDB").text($("#srcCurrencyRDB_text1").val());
        $("#labelFeeCurrencyRDB").text("%");
        ByPercent = true;
        //$("#MoneyFeeSub").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 3 });
        //$("#PercentageFeeSubs").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 2 });
    }
    else {
        $("#_KeteranganFeeRDB").text("%");
        $("#labelFeeCurrencyRDB").text($("#srcCurrencyRDB_text1").val());
        ByPercent = false;
        //$("#MoneyFeeSub").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 2 });
        //$("#PercentageFeeSubs").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 3 });
    }
}
function _ComboJenisRedemp_SelectedIndexChanged() {
    $("#pMoneyFeeRedemp").val(0);
    $("#PercentageFeeRedemp").val(0);

    if ($("#_ComboJenisRedemp").data("kendoDropDownList").text() == "By %") {
        $("#_KeteranganFeeRedemp").text($("#srcCurrencyRedemp_text1").val());
        $("#labelFeeCurrencyRedemp").text("%");
        ByPercent = true;
        //$("#MoneyFeeSub").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 3 });
        //$("#PercentageFeeSubs").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 2 });
    }
    else {
        $("#_KeteranganFeeRedemp").text("%");
        $("#labelFeeCurrencyRedemp").text($("#srcCurrencyRedemp_text1").val());
        ByPercent = false;
        //$("#MoneyFeeSub").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 2 });
        //$("#PercentageFeeSubs").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 3 });
    }
}
function _ComboJenisSubs_SelectedIndexChanged() {
    $("#MoneyFeeSubs").val(0);
    $("#PercentageFeeSubs").val(0);

    if ($("#_ComboJenisSubs").data("kendoDropDownList").text() == "By %") {
        $("#_KeteranganFeeSubs").text($("#srcCurrencySubs_text1").val());
        $("#labelFeeCurrencySubs").text("%");
        ByPercent = true;
        //$("#MoneyFeeSub").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 3 });
        //$("#PercentageFeeSubs").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 2 });
    }
    else {
        $("#_KeteranganFeeSubs").text("%");
        $("#labelFeeCurrencySubs").text($("#srcCurrencySubs_text1").val());
        ByPercent = false;
        //$("#MoneyFeeSub").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 2 });
        //$("#PercentageFeeSubs").data("kendoNumericTextBox").setOptions({ format: "#.#", decimals: 3 });
    }
}

function onBound_ComboJenisBooking() {
    var dropdownlist = $("#_ComboJenisBooking").data("kendoDropDownList");
    var len = dropdownlist.dataSource.data().length;

    if (len > 0) {
        dropdownlist.select(0);
        _ComboJenisBooking_SelectedIndexChanged();
    }
}
function onBound_ComboJenisRDB() {
    var dropdownlist = $("#_ComboJenisRDB").data("kendoDropDownList");
    var len = dropdownlist.dataSource.data().length;

    if (len > 0) {
        dropdownlist.select(0);
        _ComboJenisRDB_SelectedIndexChanged();
    }
}
function onBound_ComboJenisRedemp() {
    var dropdownlist = $("#_ComboJenisRedemp").data("kendoDropDownList");
    var len = dropdownlist.dataSource.data().length;

    if (len > 0) {
        dropdownlist.select(0);
        _ComboJenisRedemp_SelectedIndexChanged();
    }
}
function onBound_ComboJenisSubs() {
    var dropdownlist = $("#_ComboJenisSubs").data("kendoDropDownList");
    var len = dropdownlist.dataSource.data().length;

    if (len > 0) {
        dropdownlist.select(0);
        _ComboJenisSubs_SelectedIndexChanged();
    }
}
function onBounddataGridViewSubs()
{
    var grid = $("#dataGridViewSubs").data("kendoGrid");
    var len = grid.dataSource.data().length;

    if (len > 0) {
        grid.select(0);
    }
}


//DataGrid Click 
async function dataGridViewSubs_CellClick() {
    var data = this.dataItem(this.select());
    if ($("#btnEditSubs").text() == "Done") {        
        $("#textNoTransaksiSubs").val(data.NoTrx);
        _StatusTransaksiSubs = data.StatusTransaksi;
        var dateTglTransaksiSubs = new Date(data.TglTrx);
        $("#dateTglTransaksiSubs").val(pad((dateTglTransaksiSubs.getDate()), 2) + '/' + pad((dateTglTransaksiSubs.getMonth() + 1), 2) + '/' + dateTglTransaksiSubs.getFullYear());

        $("#srcProductSubs_text1").val(data.KodeProduk);
        ValidateProduct($("#srcProductSubs_text1").val(), function (result) { $("#srcProductSubs_text2").val(result[0].ProdName); });
        $("#srcCurrencySubs_text1").val(data.CCY);
        ValidateCurrency($("#srcCurrencySubs_text1").val(), function (result) { $("#srcCurrencySubs_text2").val(result); });

        $("#MoneyNomSubs").data("kendoNumericTextBox").value(data.Nominal);
        $('#checkPhoneOrderSubs').prop('checked', data.PhoneOrder);
        $('#checkFullAmtSubs').prop('checked', data.FullAmount);
        $('#checkFeeEditSubs').prop('checked', data.EditFee);

        $("#_ComboJenisSubs").data('kendoDropDownList').value(data.JenisFee);

        //By Nominal
        if ($("#_ComboJenisSubs").data("kendoDropDownList").text() == "By %")
            $("#MoneyFeeSubs").data("kendoNumericTextBox").value(data.PctFee);
        $("#PercentageFeeSubs").data("kendoNumericTextBox").value(data.NominalFee);
        $("#labelFeeCurrencySubs").text(data.FeeKet);
        $("#_KeteranganFeeSubs").text(data.FeeCurr);
    } else {
        $("#MoneyFeeSubs").data("kendoNumericTextBox").value(data.NominalFee);
        $("#PercentageFeeSubs").data("kendoNumericTextBox").value(data.PctFee);
        $("#labelFeeCurrencySubs").text(data.FeeCurr);
        $("#_KeteranganFeeSubs").text(data.FeeKet);
    }
    $("#srcClientSubs_text1").val(data.ClientCode);
    if (_intType == 2) {
        var criteria = $("#srcCIFSubs_text1").val() + "#" + $("#srcProductSubs_text1").val() + "#" + _strTabName + "#0";
        var data = await ValidateTrxClient(data.ClientCode, criteria);
        $("#srcClientSubs_text2").val(data.ClientName);
    }
}
async function dataGridViewRedemp_CellClick() {
    var data = this.dataItem(this.select());
    if ($("#btnEditRedemp").text() == "Done") {        
        _StatusTransaksiRedemp = data.StatusTransaksi;
        $("#textNoTransaksiRedemp").val(data.NoTrx);
        var dateTglTransaksiRedemp = new Date(data.TglTrx);
        $("#dateTglTransaksiRedemp").val(pad((dateTglTransaksiRedemp.getDate()), 2) + '/' + pad((dateTglTransaksiRedemp.getMonth() + 1), 2) + '/' + dateTglTransaksiRedemp.getFullYear());
        
        $("#srcProductRedemp_text1").val(data.KodeProduk);
        ValidateProduct($("#srcProductRedemp_text1").val(), function (result) { $("#srcProductRedemp_text2").val(result[0].ProdName); });
        
        $("#srcCurrencyRedemp_text1").val(data.CCY);
        ValidateCurrency(data.CCY, function (result) { $("#srcCurrencyRedemp_text2").val(result); });


        $("#OutstandingUnitRedemp").data("kendoNumericTextBox").value(data.OutstandingUnit);
        $("#RedempUnit").data("kendoNumericTextBox").value(data.RedempUnit);

        if (data.OutstandingUnit == data.RedempUnit) {
            $('#checkAll').prop('checked', true);
        } else {
            $('#checkAll').prop('checked', false);
        }

        $('#checkFeeEditRedemp').prop('checked', data.EditFee);
        $('#checkPhoneOrderRedemp').prop('checked', data.PhoneOrder);

        $("#_ComboJenisRedemp").data('kendoDropDownList').value(data.JenisFee);

        $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(data.NominalFee);
        $("#PercentageFeeRedemp").data("kendoNumericTextBox").value(data.PctFee);

        $("#labelFeeCurrencyRedemp").text(data.FeeCurr);
        $("#_KeteranganFeeRedemp").text(data.FeeKet);

        $("#srcClientRedemp_text1").val(data.ClientCode);
        var criteria = $("#srcCIFRedemp_text1").val() + "#" + $("#srcProductRedemp_text1").val() + "#" + _strTabName + "#0";
        var data = await ValidateTrxClient(data.ClientCode, criteria);
        $("#srcClientRedemp_text2").val(data.ClientName);
        $("#OutstandingUnitRedemp").data("kendoNumericTextBox").value(data.OutstandingUnit);
    }
};
async function dataGridViewRDB_CellClick() {
    var data = this.dataItem(this.select());
    if ($("#btnEditRDB").text() == "Done") {        
        _StatusTransaksiRDB = data.StatusTransaksi;
        $("#textNoTransaksiRDB").val(data.NoTrx);
        var DateTrx = new Date(data.TglTrx);
        $("#dateTglTransaksiRDB").val(pad((DateTrx.getDate()), 2) + '/' + pad((DateTrx.getMonth() + 1), 2) + '/' + DateTrx.getFullYear());

        $("#srcProductRDB_text1").val(data.KodeProduk);
        ValidateProduct(data.KodeProduk, function (result) { $("#srcProductRDB_text2").val(result[0].ProdName); });

        $("#srcCurrencyRDB_text1").val(data.CCY);
        ValidateCurrency(data.CCY, function (result) { $("#srcCurrencyRDB_text2").val(result); });

        $("#MoneyNomRDB").data("kendoNumericTextBox").value(data.Nominal);
        $('#checkPhoneOrderRDB').prop('checked', data.PhoneOrder);
        $('#checkFeeEditRDB').prop('checked', data.EditFee);

        $("#_ComboJenisRDB").data('kendoDropDownList').value(data.JenisFee);

        $("#MoneyFeeRDB").data("kendoNumericTextBox").value(data.NominalFee);
        $("#PercentageFeeRDB").data("kendoNumericTextBox").value(data.PctFee);

        $("#labelFeeCurrencyRDB").text(data.FeeCurr);
        $("#_KeteranganFeeRDB").text(data.FeeKet);
        
        $("#JangkaWktRDB").data("kendoNumericTextBox").value(data.JangkaWaktu);
        $("#cmbAutoRedempRDB").data('kendoDropDownList').value(data.AutoRedemption);
        $("#cmbAsuransiRDB").data('kendoDropDownList').value(data.Asuransi);

        var dtJatuhTempoRDB = new Date(data.JatuhTempo);
        $("#dtJatuhTempoRDB").val(pad((dtJatuhTempoRDB.getDate()), 2) + '/' + pad((dtJatuhTempoRDB.getMonth() + 1), 2) + '/' + dtJatuhTempoRDB.getFullYear());

        $("#cmbFrekPendebetanRDB").data('kendoDropDownList').value(data.FrekPendebetan);

        $("#srcClientRDB_text1").val(data.ClientCode);
        if (_intType == 2) {
            var criteria = $("#srcCIFRDB_text1").val() + "#" + $("#srcProductRDB_text1").val() + "#" + _strTabName + "#0";
            var data = await ValidateTrxClient(data.ClientCode, criteria);
            $("#srcClientRDB_text2").val(data.ClientName);
        }
    }
};


//numeric text change
function onChangeMoneyNomBooking() {
    $("#MoneyFeeBooking").data("kendoNumericTextBox").value(0);
    $("#labelFeeCurrencyBooking").text('');
    $("#PercentageFeeBooking").data("kendoNumericTextBox").value(0);
    $("#_KeteranganFeeBooking").text('');
    $("#checkFeeEditBooking").prop('checked', false);

    if ($("#checkFeeEditBooking").prop('checked') == false) {
        $("#_ComboJenisBooking").data('kendoDropDownList').enable(false);
        $("#MoneyFeeBooking").data("kendoNumericTextBox").enable(false);
    }

    if ((this.value() != 0) && ($("#srcCIFBooking_text1").val() != "") && ($("#srcProductBooking_text1").val() != "")) {
        var resFee = HitungBookingFee($("#srcCIFBooking_text1").val(), this.value(), $("#srcProductBooking_text1").val(), ByPercent,
            $("#checkFeeEditBooking").prop('checked'), $("#MoneyFeeBooking").data("kendoNumericTextBox").value());
        resFee.success(function (data) {
            if (data.blnResult) {
                strFeeCurr = data.FeeCurr;
                if ($("#checkFeeEditBooking").prop('checked') == false) {
                    $("#MoneyFeeBooking").data("kendoNumericTextBox").value(data.NominalFee);
                    $("#PercentageFeeBooking").data("kendoNumericTextBox").value(data.PctFee);
                    $("#labelFeeCurrencyBooking").text(data.FeeCurr);
                    $("#_KeteranganFeeBooking").text('%');
                }
                else {
                    if (ByPercent == true) {
                        $("#PercentageFeeBooking").data("kendoNumericTextBox").value(data.NominalFee);
                        $("#labelFeeCurrencyBooking").text('%');
                        $("#_KeteranganFeeBooking").text(data.FeeCurr);
                    }
                    else {
                        $("#PercentageFeeBooking").data("kendoNumericTextBox").value(data.PctFee);
                        $("#labelFeeCurrencyBooking").text(data.FeeCurr);
                        $("#_KeteranganFeeBooking").text('%');
                    }
                }
            }
        });
    }
}
function onChangeMoneyNomRDB()
{
    var intProdId;
    var intTranType;
    $("#MoneyFeeRDB").data("kendoNumericTextBox").value(0);
    $("#PercentageFeeRDB").data("kendoNumericTextBox").value(0);
    $("#checkFeeEditRDB").prop('checked', false);
    $("#_ComboJenisRDB").data('kendoDropDownList').value(0);
    if ($("#checkFeeEditRDB").prop('checked') == false) {
        $("#_ComboJenisRDB").data('kendoDropDownList').enable(false);
        $("#MoneyFeeRDB").data("kendoNumericTextBox").enable(false);
    }
    $("#labelFeeCurrencyRDB").text('');
    $("#_KeteranganFeeRDB").text('');
    console.log(this.value());
    console.log($("#srcProductRDB_text1").val());
    if ((this.value() != 0) && ($("#srcProductRDB_text1").val() != "")) {
        
        ValidateProduct($("#srcProductRDB_text1").val(), function (result) { intProdId = result[0].ProdId; });
        intTranType = 5;
        var resFee = HitungFee(intProdId, 0, intTranType, this.value(), 0, true,
            $("#checkFeeEditRDB").prop('checked'), $("#PercentageFeeRDB").data("kendoNumericTextBox").value()
            , 1, $("#srcCIFRDB_text1").val()
        );
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeRDB").data("kendoNumericTextBox").value(data.NominalFee);
                $("#PercentageFeeRDB").data("kendoNumericTextBox").value(data.PctFee);
                $("#labelFeeCurrencyRDB").text(data.FeeCurr);              
            }
        });
    }
}
function onChangeMoneyNomSubs() {
    var intProdId;
    var intClientid;
    var intTranType;
    $("#MoneyFeeSubs").data("kendoNumericTextBox").value(0);
    $("#PercentageFeeSubs").data("kendoNumericTextBox").value(0);
    $("#checkFeeEditSubs").prop('checked', false);
    $("#_ComboJenisSubs").data("kendoDropDownList").value(1);

    if ($("#checkFeeEditSubs").prop('checked') == false) {
        $("#_ComboJenisSubs").data("kendoDropDownList").enable(false);
        $("#MoneyFeeSubs").data("kendoNumericTextBox").enable(false);
    }
    $("#labelFeeCurrencySubs").text('');
    $("#_KeteranganFeeSubs").text('');

    if ((this.value() != 0) && ($("#srcProductSubs_text1").val() != "")) {
        var res = GetImportantData("PRODUKID", $("#srcProductSubs_text1").val());
        res.success(function (data) {
            intProdId = data.value;
        });

        if ($("#_ComboJenisSubs").data("kendoDropDownList").text() == "By %") {
            ByPercent = true;
        }
        else {
            ByPercent = false;
        }

        if (IsSubsNew) {
            intTranType = 1;
            intClientid = 0;
        }
        else {
            intTranType = 2;
            var res = GetImportantData("CLIENTID", $("#srcProductSubs_text1").val());
            res.success(function (data) {
                intClientid = data.value;
            });
        }
        var resFee = HitungFee(intProdId, intClientid, intTranType, this.value(), 0
            , $("#checkFullAmtSubs").prop('checked'), $("#checkFeeEditSubs").prop('checked')
            , $("#PercentageFeeSubs").data("kendoNumericTextBox").value(), 1, $('#srcCIFSubs_text1').val());
        resFee.success(function (data) {
            $("#labelFeeCurrencySubs").text("%");
            if (data.blnResult) {                
                $("#MoneyFeeSubs").data("kendoNumericTextBox").value(data.NominalFee);
                $("#PercentageFeeSubs").data("kendoNumericTextBox").value(data.PctFee);
                $("#labelFeeCurrencySubs").text("%"); 
                $("#_KeteranganFeeSubs").text(data.FeeCurr);              
            }
        });
    }
}

function onChangeMoneyFeeBooking() {

}
function onChangeMoneyFeeRDB() {
    var intProdId;
    if ($("#_ComboJenisRDB").data("kendoDropDownList").text() == "By %") {
        $("#_KeteranganFeeRDB").text($("#srcCurrencyRDB_text1").val());
        $("#labelFeeCurrencyRDB").text("%");
        ByPercent = true;
    }
    else {
        $("#_KeteranganFeeRDB").text("%");
        $("#labelFeeCurrencyRDB").text($("#srcCurrencyRDB_text1").val());
        ByPercent = false;
    }

    if ($("#srcProductRDB_text1").val() != "" && $("#MoneyNomRDB").val() != 0) {

        ValidateProduct($("#srcProductRDB_text1").val(), function (result) { intProdId = result[0].ProdId; });
        var intTranType = 5;
        var resFee = HitungFee(intProdId, intTranType, $("#MoneyNomRDB").data("kendoNumericTextBox").value(), 0
            , true, $("#checkFeeEditRDB").prop('checked')
            , $("#MoneyFeeRDB").data("kendoNumericTextBox").value(), 2, $('#srcCIFRDB_text1').val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#PercentageFeeRDB").data("kendoNumericTextBox").value(data.PctFee);
            }
        }); 
    }     
}
function onChangeMoneyFeeRedemp() {
    var intProdId;
    var intClientid;
    var intTranType;
    if ($("#_ComboJenisRedemp").data("kendoDropDownList").text() == "By %") {
        $("#_KeteranganFeeRedemp").text(strFeeCurr);
        $("#labelFeeCurrencyRedemp").text("%");
        ByPercent = true;
    }
    else {
        $("#_KeteranganFeeRedemp").text("%");
        $("#labelFeeCurrencyRedemp").text(strFeeCurr);
        ByPercent = false;
    }

    if ($("#srcProductRedemp_text1").val() != "" && $("#RedempUnit").val() != 0) {
        var res = GetImportantData("PRODUKID", $("#srcProductRedemp_text1").val());
        res.success(function (data) {
            intProdId = data.value;
        });
        var res = GetImportantData("CLIENTID", $("#srcClientRedemp_text1").val());
        res.success(function (data) {
            intClientid = data.value;
        });

        if (($("#_ComboJenisRedemp").data("kendoDropDownList").text() == "By %") && ($("#checkFeeEditRedemp").prop('checked') == true)) {
            ByPercent = true;
        }
        else {
            ByPercent = false;
        }
        if (IsRedempAll) {
            intTranType = 4;
        }
        else {
            intTranType = 3;
        }

        var resFee = HitungFee(intProdId, intClientid, intTranType, $("#RedempUnit").data("kendoNumericTextBox").value()
            , false, $("#checkFeeEditRedemp").prop('checked')
            , $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(), 2, $('#srcCIFRedemp_text1').val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#PercentageFeeRedemp").data("kendoNumericTextBox").value(data.PctFee);
            }
        });
    }    
}
function onChangeMoneyFeeSubs()
{
    var intClientid;
    var intProdId;
    if ($("#_ComboJenisSubs").data("kendoDropDownList").text() == "By %") {
        $("#_KeteranganFeeSubs").text($("#srcCurrencySubs_text1").val());
        $("#labelFeeCurrencySubs").text("%");
        ByPercent = true;
    }
    else {
        $("#_KeteranganFeeSubs").text("%");
        $("#labelFeeCurrencySubs").text($("#srcCurrencySubs_text1").val());
        ByPercent = false;
    }

    if ($("#srcProductSubs_text1").val() != "" && $("#MoneyNomSubs").val() != 0 && $("#checkFeeEditSubs").prop('checked') == true) {

        ValidateProduct($("#srcProductSubs_text1").val(), function (result) { intProdId = result[0].ProdId; });

        if (IsSubsNew) {
            intTranType = 1;
            intClientid = 0;
        }
        else {
            intTranType = 2;
            ValidateClient($("#srcClientSwcRDBIn_text1").val(), intProdId, function (result) {
                $("#srcClientSwcRDBIn_text2").val(intClientid = result[0].ClientId);
            });
        }
    }
    var resFee = HitungFee(intProdId, intClientid, $("#MoneyNomSubs").data("kendoNumericTextBox").value(), 0
        , $("#checkFullAmtSubs").prop('checked'), $("#checkFeeEditSubs").prop('checked')
        , $("#MoneyFeeSubs").data("kendoNumericTextBox").value(), 2, $('#srcCIFSubs_text1').val());
    resFee.success(function (data) {
        console.log(data);
        if (data.blnResult) {
            $("#PercentageFeeSubs").data("kendoNumericTextBox").value(data.PctFee);
        }
    });   
}

function onChangePercentageFeeSwc()
{
    if ($("#RedempSwc").data("kendoNumericTextBox").value() != 0)
    {
        var resFee = HitungSwitchingFee($("#srcProductSwcOut_text1").val(), $("#srcProductSwcIn_text1").val()
            , true, 0, $("#RedempSwc").data("kendoNumericTextBox").value()
            , $("#checkFeeEditSwc").prop('checked')
            , $("#PercentageFeeSwc").data("kendoNumericTextBox").value(), $("#IsEmployeeSwcOut").val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeSwc").data("kendoNumericTextBox").value(data.calcFeeResult.Fee);
                $("#PercentageFeeSwc").data("kendoNumericTextBox").value(data.calcFeeResult.PercentageOutput);
                $("#labelFeeCurrencySwc").text(data.calcFeeResult.FeeCCY);
            }
        });
    }
}
function onChangePercentageFeeSwcRDB() {
    var ProdSwcOut;
    var ClientSwcOut;
    if (($("#RedempSwcRDB").data("kendoNumericTextBox").value()) != 0
        && ($("#srcProductSwcRDBOut_text1").val() != "")
        && ($("#srcClientSwcRDBOut_text1").val() != "")) {
        var res = GetImportantData("PRODUKID", $("#srcProductSwcRDBOut_text1").val());
        res.success(function (data) {
            ProdSwcOut = data.value;
        });

        var res = GetImportantData("CLIENTID", $("#srcClientSwcRDBOut_text1").val());
        res.success(function (data) {
            ClientSwcOut = data.value;
        });

        var resFee = HitungSwitchingRDBFee(ProdSwcOut, ClientSwcOut, $("#RedempSwcRDB").data("kendoNumericTextBox").value(),
            $("#checkFeeEditSwcRDB").prop('checked'), $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").value(data.calcFeeResult.Fee);
                $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value(data.calcFeeResult.PercentageOutput);
                $("#labelFeeCurrencySwcRDB").text(data.calcFeeResult.FeeCCY);
            }
        });
    }
}

function onChangeRedempUnit() {
    var intProdId;
    var intClientid;
    var intTranType;
    $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(0);
    $("#PercentageFeeRedemp").data("kendoNumericTextBox").value(0);
    $("#checkFeeEditRedemp").prop('checked', false);
    $("#_ComboJenisRedemp").data('kendoDropDownList').value(1);

    if ($("#checkFeeEditRedemp").prop('checked') == false) {
        $("#_ComboJenisRedemp").data('kendoDropDownList').enable(false);
        $("#MoneyFeeRedemp").data("kendoNumericTextBox").enable(false);
    }
    $("#_KeteranganFeeRedemp").text('');
    $("#labelFeeCurrencyRedemp").text('');

    if ((this.value() != 0) && ($("#srcProductRedemp_text1").val() != "") && ($("#srcClientRedemp_text1").val() != "") && ($("#OutstandingUnitRedemp").data("kendoNumericTextBox").value() != 0)) {
        var res = GetImportantData("PRODUKID", $("#srcProductRedemp_text1").val());
        res.success(function (data) {
            intProdId = data.value;
        });

        var res = GetImportantData("CLIENTID", $("#srcClientRedemp_text1").val());
        res.success(function (data) {
            intClientid = data.value;
        });

        if ($("#RedempUnit").data("kendoNumericTextBox").value() == $("#OutstandingUnitRedemp").data("kendoNumericTextBox").value()) {
            IsRedempAll = true;
            $("#checkAll").prop('checked', true);
        }
        else {
            IsRedempAll = false;
            $("#checkAll").prop('checked', false);
        }

        if ($("#_ComboJenisRedemp").data("kendoDropDownList").text() == "By %") {
            ByPercent = true;
        }
        else {
            ByPercent = false;
        }

        if (IsRedempAll) {
            intTranType = 4;
        }
        else {
            intTranType = 3;
        }
        var resFee = HitungFee(intProdId, intClientid, intTranType, 0, this.value()
            , false, $("#checkFeeEditRedemp").prop('checked')
            , $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(), 1, $('#srcCIFRedemp_text1').val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(data.PctFee);
                $("#PercentageFeeRedemp").data("kendoNumericTextBox").value(data.NominalFee);
                $("#labelFeeCurrencyRedemp").text('%');
                $("#_KeteranganFeeRedemp").text(data.FeeCurr);
                strFeeCurr = data.FeeCurr;
            }
        });
    }
}
function onChangeRedempSwc() {
    $("#MoneyFeeSwc").data("kendoNumericTextBox").value(0);
    $("#PercentageFeeSwc").data("kendoNumericTextBox").value(0);
    $("#checkFeeEditSwc").prop('checked', false);

    if ($("#checkFeeEditSwc").prop('checked') == false) {
        $("#MoneyFeeSwc").data("kendoNumericTextBox").enable(false);
    }

    $("#labelFeeCurrencySwc").text('');

    if ((this.value() != 0) && ($("#srcProductSwcOut_text1").val() != "") &&
        ($("#srcProductSwcIn_text1").val() != "") && ($("#srcClientSwcOut_text1").val() != "")) {
        if ($("#RedempSwc").data("kendoNumericTextBox").value() == $("#OutstandingUnitSwc").data("kendoNumericTextBox").value()) {
            IsSwitchingAll = true;
            $("#checkSwcAll").prop('checked', true);
        }
        else {
            IsSwitchingAll = false;
            $("#checkSwcAll").prop('checked', false);
        }

        var resFee = HitungSwitchingFee($("#srcProductSwcOut_text1").val(), $("#srcProductSwcIn_text1").val()
            , true, 0, this.value()
            , $("#checkFeeEditSwc").prop('checked')
            , $("#PercentageFeeSwc").data("kendoNumericTextBox").value(), $("#IsEmployeeSwcOut").val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeSwc").data("kendoNumericTextBox").value(data.calcFeeResult.Fee);
                $("#PercentageFeeSwc").data("kendoNumericTextBox").value(data.calcFeeResult.PercentageOutput);
                $("#labelFeeCurrencySwc").text(data.calcFeeResult.FeeCCY);
            }
        });
    }
}
function onChangeRedempSwcRDB() {
    var ProdSwcOut;
    var ClientSwcOut;
    $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").value(0);
    $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value(0);
    $("#checkFeeEditSwcRDB").prop('checked', false);

    if ($("#checkFeeEditSwcRDB").prop('checked') == false) {
        $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").enable(false);
    }

    $("#labelFeeCurrencySwcRDB").text('');

    if ((this.value() != 0) && ($("#srcProductSwcRDBOut_text1").val() != "") &&
        ($("#srcClientSwcRDBOut_text1").val() != "")) {
        var res = GetImportantData("PRODUKID", $("#srcProductSwcRDBOut_text1").val());
        res.success(function (data) {
            ProdSwcOut = data.value;
        });

        var res = GetImportantData("CLIENTID", $("#srcClientSwcRDBOut_text1").val());
        res.success(function (data) {
            ClientSwcOut = data.value;
        });

        var resFee = HitungSwitchingRDBFee(ProdSwcOut, ClientSwcOut, $("#RedempSwcRDB").data("kendoNumericTextBox").value(),
            $("#checkFeeEditSwcRDB").prop('checked'), $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").value(data.calcFeeResult.Fee);
                $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value(data.calcFeeResult.PercentageOutput);
                $("#labelFeeCurrencySwcRDB").text(data.calcFeeResult.FeeCCY);
            }
        });
    }
}

function onChangeJangkaWktRDB() {
    if ($("#JangkaWktRDB").val() == 0) {
        $("#dtJatuhTempoRDB").val('');
    }
    else {
        if (_intType != 0) {
            var jangkaWaktu = $("#JangkaWktRDB").data("kendoNumericTextBox").value();
            var TodayDate = new Date();
            var jatuhTempo = TodayDate.setMonth(TodayDate.getMonth() + parseInt(jangkaWaktu));
            jatuhTempo = new Date(jatuhTempo);
            globalJatuhTempoRDB = jatuhTempo;
            $("#dtJatuhTempoRDB").val(pad((jatuhTempo.getDate()), 2) + '/' + pad((jatuhTempo.getMonth() + 1), 2) + '/' + jatuhTempo.getFullYear());
        }
    }
}
function onChangeJangkaWktSwcRDB() {
    if ($("#JangkaWktSwcRDB").val() == 0) {
        $("#dtJatuhTempoSwcRDB").val('');
    }
    else {
        if (_intType != 0) {
            var jangkaWaktu = $("#JangkaWktSwcRDB").data("kendoNumericTextBox").value();
            var TodayDate = new Date();
            var jatuhTempo = TodayDate.setMonth(TodayDate.getMonth() + parseInt(jangkaWaktu));
            jatuhTempo = new Date(jatuhTempo);
            globalJatuhTempoSwcRDB = jatuhTempo;
            $("#dtJatuhTempoSwcRDB").val(pad((jatuhTempo.getDate()), 2) + '/' + pad((jatuhTempo.getMonth() + 1), 2) + '/' + jatuhTempo.getFullYear());
        }
    }
}

//numeric text spin
function onSpinMoneyNomBooking() {
    $("#MoneyFeeBooking").data("kendoNumericTextBox").value(0);
    $("#labelFeeCurrencyBooking").text('');
    $("#PercentageFeeBooking").data("kendoNumericTextBox").value(0);
    $("#_KeteranganFeeBooking").text('');
    $("#checkFeeEditBooking").prop('checked', false);

    if ($("#checkFeeEditBooking").prop('checked') == false) {
        $("#_ComboJenisBooking").data('kendoDropDownList').enable(false);
        $("#MoneyFeeBooking").data("kendoNumericTextBox").enable(false);
    }

    if ((this.value() != 0) && ($("#srcCIFBooking_text1").val() != "") && ($("#srcProductBooking_text1").val() != "")) {
        var resFee = HitungBookingFee($("#srcCIFBooking_text1").val(), this.value(), $("#srcProductBooking_text1").val(), ByPercent,
            $("#checkFeeEditBooking").prop('checked'), $("#MoneyFeeBooking").data("kendoNumericTextBox").value());
        resFee.success(function (data) {
            strFeeCurr = data.FeeCurr;
            if (data.blnResult) {
                if ($("#checkFeeEditBooking").prop('checked') == false) {
                    $("#MoneyFeeBooking").data("kendoNumericTextBox").value(data.NominalFee);
                    $("#PercentageFeeBooking").data("kendoNumericTextBox").value(data.PctFee);
                    $("#labelFeeCurrencyBooking").text(data.FeeCurr);
                    $("#_KeteranganFeeBooking").text('%');
                }
                else {
                    if (ByPercent == true) {
                        $("#PercentageFeeBooking").data("kendoNumericTextBox").value(data.NominalFee);
                        $("#labelFeeCurrencyBooking").text('%');
                        $("#_KeteranganFeeBooking").text(data.FeeCurr);
                    }
                    else {
                        $("#PercentageFeeBooking").data("kendoNumericTextBox").value(data.PctFee);
                        $("#labelFeeCurrencyBooking").text(data.FeeCurr);
                        $("#_KeteranganFeeBooking").text('%');
                    }
                }
            }
        });
    }
}
function onSpinMoneyNomRDB() {
    var intProdId;
    var intTranType;
    $("#MoneyFeeRDB").data("kendoNumericTextBox").value(0);
    $("#PercentageFeeRDB").data("kendoNumericTextBox").value(0);
    $("#checkFeeEditRDB").prop('checked', false);
    $("#_ComboJenisRDB").data('kendoDropDownList').value(0);
    if ($("#checkFeeEditRDB").prop('checked') == false) {
        $("#_ComboJenisRDB").data('kendoDropDownList').enable(false);
        $("#MoneyFeeRDB").data("kendoNumericTextBox").enable(false);
    }
    $("#labelFeeCurrencyRDB").text('');
    $("#_KeteranganFeeRDB").text('');

    if ((this.value() != 0) && ($("#srcProductRDB_text1").val() != "")) {
        ValidateProduct($("#srcProductRDB_text1").val(), function (result) { intProdId = result[0].ProdId; });
        intTranType = 5;
        var resFee = HitungFee(intProdId, 0, intTranType, this.value(), 0, true,
            $("#checkFeeEditRDB").prop('checked'), $("#PercentageFeeRDB").data("kendoNumericTextBox").value()
            , 1, $("#srcCIFRDB_text1").val()
        );
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeRDB").data("kendoNumericTextBox").value(data.NominalFee);
                $("#PercentageFeeRDB").data("kendoNumericTextBox").value(data.PctFee);
                $("#labelFeeCurrencyRDB").text(data.FeeCurr);
            }
        });
    }
}
function onSpinMoneyNomSubs() {
    var intProdId;
    var intClientid;
    var intTranType;
    $("#MoneyFeeSubs").data("kendoNumericTextBox").value(0);
    $("#PercentageFeeSubs").data("kendoNumericTextBox").value(0);
    $("#checkFeeEditSubs").prop('checked', false);
    $("#_ComboJenisSubs").data("kendoDropDownList").value(1);

    if ($("#checkFeeEditSubs").prop('checked') == false) {
        $("#_ComboJenisSubs").data("kendoDropDownList").enable(false);
        $("#MoneyFeeSubs").data("kendoNumericTextBox").enable(false);
    }
    $("#labelFeeCurrencySubs").text('');
    $("#_KeteranganFeeSubs").text('');

    if ((this.value() != 0) && ($("#srcProductSubs_text1").val() != "")) {
        var res = GetImportantData("PRODUKID", $("#srcProductSubs_text1").val());
        res.success(function (data) {
            intProdId = data.value;
        });

        if ($("#_ComboJenisSubs").data("kendoDropDownList").text() == "By %") {
            ByPercent = true;
        }
        else {
            ByPercent = false;
        }

        if (IsSubsNew) {
            intTranType = 1;
            intClientid = 0;
        }
        else {
            intTranType = 2;
            var res = GetImportantData("CLIENTID", $("#srcProductSubs_text1").val());
            res.success(function (data) {
                intClientid = data.value;
            });
        }
        var resFee = HitungFee(intProdId, intClientid, intTranType, this.value(), 0
            , $("#checkFullAmtSubs").prop('checked'), $("#checkFeeEditSubs").prop('checked')
            , $("#PercentageFeeSubs").data("kendoNumericTextBox").value(), 1, $('#srcCIFSubs_text1').val());
        resFee.success(function (data) {
            $("#labelFeeCurrencySubs").text("%");
            if (data.blnResult) {
                $("#MoneyFeeSubs").data("kendoNumericTextBox").value(data.NominalFee);
                $("#PercentageFeeSubs").data("kendoNumericTextBox").value(data.PctFee);
                $("#labelFeeCurrencySubs").text("%");
                $("#_KeteranganFeeSubs").text(data.FeeCurr);
            }
        });
    }
}

function onSpinMoneyFeeBooking() {

}
function onSpinMoneyFeeRDB() {
    var intProdId;
    if ($("#_ComboJenisRDB").data("kendoDropDownList").text() == "By %") {
        $("#_KeteranganFeeRDB").text($("#srcCurrencyRDB_text1").val());
        $("#labelFeeCurrencyRDB").text("%");
        ByPercent = true;
    }
    else {
        $("#_KeteranganFeeRDB").text("%");
        $("#labelFeeCurrencyRDB").text($("#srcCurrencyRDB_text1").val());
        ByPercent = false;
    }

    if ($("#srcProductRDB_text1").val() != "" && $("#MoneyNomRDB").val() != 0) {

        ValidateProduct($("#srcProductRDB_text1").val(), function (result) { intProdId = result[0].ProdId; });
        var intTranType = 5;
        var resFee = HitungFee(intProdId, intTranType, $("#MoneyNomRDB").data("kendoNumericTextBox").value(), 0
            , true, $("#checkFeeEditRDB").prop('checked')
            , $("#MoneyFeeRDB").data("kendoNumericTextBox").value(), 2, $('#srcCIFRDB_text1').val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#PercentageFeeRDB").data("kendoNumericTextBox").value(data.PctFee);
            }
        });
    }
}
function onSpinMoneyFeeRedemp() {
    var intProdId;
    var intClientid;
    var intTranType;
    if ($("#_ComboJenisRedemp").data("kendoDropDownList").text() == "By %") {
        $("#_KeteranganFeeRedemp").text(strFeeCurr);
        $("#labelFeeCurrencyRedemp").text("%");
        ByPercent = true;
    }
    else {
        $("#_KeteranganFeeRedemp").text("%");
        $("#labelFeeCurrencyRedemp").text(strFeeCurr);
        ByPercent = false;
    }

    if ($("#srcProductRedemp_text1").val() != "" && $("#RedempUnit").val() != 0) {
        var res = GetImportantData("PRODUKID", $("#srcProductRedemp_text1").val());
        res.success(function (data) {
            intProdId = data.value;
        });
        var res = GetImportantData("CLIENTID", $("#srcClientRedemp_text1").val());
        res.success(function (data) {
            intClientid = data.value;
        });

        if (($("#_ComboJenisRedemp").data("kendoDropDownList").text() == "By %") && ($("#checkFeeEditRedemp").prop('checked') == true)) {
            ByPercent = true;
        }
        else {
            ByPercent = false;
        }
        if (IsRedempAll) {
            intTranType = 4;
        }
        else {
            intTranType = 3;
        }

        var resFee = HitungFee(intProdId, intClientid, intTranType, $("#RedempUnit").data("kendoNumericTextBox").value()
            , false, $("#checkFeeEditRedemp").prop('checked')
            , $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(), 2, $('#srcCIFRedemp_text1').val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#PercentageFeeRedemp").data("kendoNumericTextBox").value(data.PctFee);
            }
        });
    }
}
function onSpinMoneyFeeSubs()
{
    var intClientid;
    var intProdId;
    if ($("#_ComboJenisSubs").data("kendoDropDownList").text() == "By %") {
        $("#_KeteranganFeeSubs").text($("#srcCurrencySubs_text1").val());
        $("#labelFeeCurrencySubs").text("%");
        ByPercent = true;
    }
    else {
        $("#_KeteranganFeeSubs").text("%");
        $("#labelFeeCurrencySubs").text($("#srcCurrencySubs_text1").val());
        ByPercent = false;
    }

    if ($("#srcProductSubs_text1").val() != "" && $("#MoneyNomSubs").val() != 0 && $("#checkFeeEditSubs").prop('checked') == true) {
  
        ValidateProduct($("#srcProductSubs_text1").val(), function (result) { intProdId = result[0].ProdId; });

        if (IsSubsNew) {
            intTranType = 1;
            intClientid = 0;
        }
        else {
            intTranType = 2;
            ValidateClient($("#srcClientSwcRDBIn_text1").val(), intProdId, function (result) {
                $("#srcClientSwcRDBIn_text2").val( intClientid = result[0].ClientId);
            });
        }
    }
    var resFee = HitungFee(intProdId, intClientid, $("#MoneyNomSubs").data("kendoNumericTextBox").value(), 0
        , $("#checkFullAmtSubs").prop('checked'), $("#checkFeeEditSubs").prop('checked')
        , $("#MoneyFeeSubs").data("kendoNumericTextBox").value(), 2, $('#srcCIFSubs_text1').val());
    resFee.success(function (data) {
        if (data.blnResult) {
            $("#PercentageFeeSubs").data("kendoNumericTextBox").value(data.PctFee);
        }
    }); 
}

function onSpinPercentageFeeSwc() {
    if ($("#RedempSwc").data("kendoNumericTextBox").value() != 0) {
        var resFee = HitungSwitchingFee($("#srcProductSwcOut_text1").val(), $("#srcProductSwcIn_text1").val()
            , true, 0, $("#RedempSwc").data("kendoNumericTextBox").value()
            , $("#checkFeeEditSwc").prop('checked')
            , $("#PercentageFeeSwc").data("kendoNumericTextBox").value(), $("#IsEmployeeSwcOut").val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeSwc").data("kendoNumericTextBox").value(data.calcFeeResult.Fee);
                $("#PercentageFeeSwc").data("kendoNumericTextBox").value(data.calcFeeResult.PercentageOutput);
                $("#labelFeeCurrencySwc").text(data.calcFeeResult.FeeCCY);
            }
        });
    }
}
function onSpinPercentageFeeSwcRDB() {
    var ProdSwcOut;
    var ClientSwcOut;
    if (($("#RedempSwcRDB").data("kendoNumericTextBox").value()) != 0
        && ($("#srcProductSwcRDBOut_text1").val() != "")
        && ($("#srcClientSwcRDBOut_text1").val() != "")) {
        var res = GetImportantData("PRODUKID", $("#srcProductSwcRDBOut_text1").val());
        res.success(function (data) {
            ProdSwcOut = data.value;
        });

        var res = GetImportantData("CLIENTID", $("#srcClientSwcRDBOut_text1").val());
        res.success(function (data) {
            ClientSwcOut = data.value;
        });

        var resFee = HitungSwitchingRDBFee(ProdSwcOut, ClientSwcOut, $("#RedempSwcRDB").data("kendoNumericTextBox").value(),
            $("#checkFeeEditSwcRDB").prop('checked'), $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").value(data.calcFeeResult.Fee);
                $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value(data.calcFeeResult.PercentageOutput);
                $("#labelFeeCurrencySwcRDB").text(data.calcFeeResult.FeeCCY);
            }
        });
    }
}

function onSpinRedempUnit() {
    var intProdId;
    var intClientid;
    var intTranType;
    $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(0);
    $("#PercentageFeeRedemp").data("kendoNumericTextBox").value(0);
    $("#checkFeeEditRedemp").prop('checked', false);
    $("#_ComboJenisRedemp").data('kendoDropDownList').value(1);

    if ($("#checkFeeEditRedemp").prop('checked') == false) {
        $("#_ComboJenisRedemp").data('kendoDropDownList').enable(false);
        $("#MoneyFeeRedemp").data("kendoNumericTextBox").enable(false);
    }
    $("#_KeteranganFeeRedemp").text('');
    $("#labelFeeCurrencyRedemp").text('');

    if ((this.value() != 0) && ($("#srcProductRedemp_text1").val() != "") && ($("#srcClientRedemp_text1").val() != "") && ($("#OutstandingUnitRedemp").data("kendoNumericTextBox").value() != 0)) {
        var res = GetImportantData("PRODUKID", $("#srcProductRedemp_text1").val());
        res.success(function (data) {
            intProdId = data.value;
        });

        var res = GetImportantData("CLIENTID", $("#srcClientRedemp_text1").val());
        res.success(function (data) {
            intClientid = data.value;
        });

        if ($("#RedempUnit").data("kendoNumericTextBox").value() == $("#OutstandingUnitRedemp").data("kendoNumericTextBox").value()) {
            IsRedempAll = true;
            $("#checkAll").prop('checked', true);
        }
        else {
            IsRedempAll = false;
            $("#checkAll").prop('checked', false);
        }

        if ($("#_ComboJenisRedemp").data("kendoDropDownList").text() == "By %") {
            ByPercent = true;
        }
        else {
            ByPercent = false;
        }

        if (IsRedempAll) {
            intTranType = 4;
        }
        else {
            intTranType = 3;
        }
        var resFee = HitungFee(intProdId, intClientid, intTranType, 0, this.value()
            , false, $("#checkFeeEditRedemp").prop('checked')
            , $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(), 1, $('#srcCIFRedemp_text1').val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(data.PctFee);
                $("#PercentageFeeRedemp").data("kendoNumericTextBox").value(data.NominalFee);
                $("#labelFeeCurrencyRedemp").text('%');
                $("#_KeteranganFeeRedemp").text(data.FeeCurr);
                strFeeCurr = data.FeeCurr;
            }
        });
    }
}
function onSpinRedempSwc() {
    $("#MoneyFeeSwc").data("kendoNumericTextBox").value(0);
    $("#PercentageFeeSwc").data("kendoNumericTextBox").value(0);
    $("#checkFeeEditSwc").prop('checked', false);

    if ($("#checkFeeEditSwc").prop('checked') == false) {
        $("#MoneyFeeSwc").data("kendoNumericTextBox").enable(false);
    }

    $("#labelFeeCurrencySwc").text('');

    if ((this.value() != 0) && ($("#srcProductSwcOut_text1").val() != "") &&
        ($("#srcProductSwcIn_text1").val() != "") && ($("#srcClientSwcOut_text1").val() != "")) {
        if ($("#RedempSwc").data("kendoNumericTextBox").value() == $("#OutstandingUnitSwc").data("kendoNumericTextBox").value()) {
            IsSwitchingAll = true;
            $("#checkSwcAll").prop('checked', true);
        }
        else {
            IsSwitchingAll = false;
            $("#checkSwcAll").prop('checked', false);
        }



        var resFee = HitungSwitchingFee($("#srcProductSwcOut_text1").val(), $("#srcProductSwcIn_text1").val()
            , true, 0, this.value()
            , $("#checkFeeEditSwc").prop('checked')
            , $("#PercentageFeeSwc").data("kendoNumericTextBox").value(), $("#IsEmployeeSwcOut").val());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeSwc").data("kendoNumericTextBox").value(data.calcFeeResult.Fee);
                $("#PercentageFeeSwc").data("kendoNumericTextBox").value(data.calcFeeResult.PercentageOutput);
                $("#labelFeeCurrencySwc").text(data.calcFeeResult.FeeCCY);
            }
        });
    }
}
function onSpinRedempSwcRDB() {
    var ProdSwcOut;
    var ClientSwcOut;
    $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").value(0);
    $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value(0);
    $("#checkFeeEditSwcRDB").prop('checked', false);

    if ($("#checkFeeEditSwcRDB").prop('checked') == false) {
        $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").enable(false);
    }

    $("#labelFeeCurrencySwcRDB").text('');

    if ((this.value() != 0) && ($("#srcProductSwcRDBOut_text1").val() != "") &&
        ($("#srcClientSwcRDBOut_text1").val() != "")) {
        var res = GetImportantData("PRODUKID", $("#srcProductSwcRDBOut_text1").val());
        res.success(function (data) {
            ProdSwcOut = data.value;
        });

        var res = GetImportantData("CLIENTID", $("#srcClientSwcRDBOut_text1").val());
        res.success(function (data) {
            ClientSwcOut = data.value;
        });

        var resFee = HitungSwitchingRDBFee(ProdSwcOut, ClientSwcOut, $("#RedempSwcRDB").data("kendoNumericTextBox").value(),
            $("#checkFeeEditSwcRDB").prop('checked'), $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value());
        resFee.success(function (data) {
            if (data.blnResult) {
                $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").value(data.calcFeeResult.Fee);
                $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value(data.calcFeeResult.PercentageOutput);
                $("#labelFeeCurrencySwcRDB").text(data.calcFeeResult.FeeCCY);
            }
        });
    }
}

function onSpinJangkaWktRDB() {
    if ($("#JangkaWktRDB").val() == 0) {
        $("#dtJatuhTempoRDB").val('');
    }
    else {
        if (_intType != 0) {
            var jangkaWaktu = $("#JangkaWktRDB").data("kendoNumericTextBox").value();
            var TodayDate = new Date();
            var jatuhTempo = TodayDate.setMonth(TodayDate.getMonth() + parseInt(jangkaWaktu));
            jatuhTempo = new Date(jatuhTempo);
            globalJatuhTempoRDB = jatuhTempo;
            $("#dtJatuhTempoRDB").val(pad((jatuhTempo.getDate()), 2) + '/' + pad((jatuhTempo.getMonth() + 1), 2) + '/' + jatuhTempo.getFullYear());
        }
    }
}
function onSpinJangkaWktSwcRDB() {
    if ($("#JangkaWktSwcRDB").val() == 0) {
        $("#dtJatuhTempoSwcRDB").val('');
    }
    else {
        if (_intType != 0) {
            var jangkaWaktu = $("#JangkaWktSwcRDB").data("kendoNumericTextBox").value();
            var TodayDate = new Date();
            var jatuhTempo = TodayDate.setMonth(TodayDate.getMonth() + parseInt(jangkaWaktu));
            jatuhTempo = new Date(jatuhTempo);
            globalJatuhTempoSwcRDB = jatuhTempo;
            $("#dtJatuhTempoSwcRDB").val(pad((jatuhTempo.getDate()), 2) + '/' + pad((jatuhTempo.getMonth() + 1), 2) + '/' + jatuhTempo.getFullYear());
        }
    }
}