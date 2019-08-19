$("#_cmpsrProduct").click(function _cmpsrProduct_click() {
    var url = $(this).attr("href");
    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
//click
$("#btnRefresh").click(function () {
    subRefresh();
});
$("#btnNew").click(function () {
    subNew();
});
$("#btnEdit").click(function () {
    subUpdate();
});
$("#btnDelete").click(function () {
    subDelete();
});
$("#btnSave").click(function () {
    subSave(intMyType);
});
$("#btnCancel").click(function () {
    subCancel();
});

function onBounddataGridView1() {
    var grid = $("#dataGridView1").data("kendoGrid");
    var len = grid.dataSource.data().length;

    if (len > 0) {
        grid.select(0);
    }
}

async function dataGridView1_Click() {
    var data = this.dataItem(this.select());
    $("#_cmpsrProduct_text1").val(data.prodCode);    
    $("#_cmpsrProduct_text2").val(data.prodName); 
    ValidateProduct(data.prodCode, function (result) { $("#ProdId").val(result[0].ProdId); });
    $("#_matauang").val(data.prodCCY); 
    $("#_matauangnew").text(data.prodCCY); 
    $("#_matauangadd").text(data.prodCCY); 
    if (data.minRedemptionBy == "unit") {
        $("#_comboJenisRedemp").data('kendoDropDownList').value(0);
    }
    else {
        $("#_comboJenisRedemp").data('kendoDropDownList').value(1);
    }
    if (data.minSwitchingBy == "unit") {
        $("#_comboJenisSwitching").data('kendoDropDownList').value(0);
    }
    else {
        $("#_comboJenisSwitching").data('kendoDropDownList').value(1);
    }
    $("#_minSubsNew").data("kendoNumericTextBox").value(data.minSubsNew);
    $("#_minSubsAdd").data("kendoNumericTextBox").value(data.minSubsAdd);
    $("#_minRedemp").data("kendoNumericTextBox").value(data.minRedemption);
    $("#_minSwitching").data("kendoNumericTextBox").value(data.minSwitching);
    $("#_pctFeeSubs").data("kendoNumericTextBox").value(data.pctFeeSubs);
    $("#_pctFeeRedemp").data("kendoNumericTextBox").value(data.pctFeeRedemp);
    $("#_pctFeeSwitching").data("kendoNumericTextBox").value(data.pctFeeSwitching);
    $("#_pctHoldAmount").data("kendoNumericTextBox").value(data.pctHoldAmount);
    if (data.canSubsNew == true) {
        $("#_yesSubsNew").prop('checked', true);
        $("#_noSubsNew").prop('checked', false);
    }
    else {
        $("#_yesSubsNew").prop('checked', false);
        $("#_noSubsNew").prop('checked', true);
    }
    if (data.isVisibleIBMB == true) {
        $("#_yesTampil").prop('checked', true);
        $("#_noTampil").prop('checked', false);
    }
    else {
        $("#_yesTampil").prop('checked', false);
        $("#_noTampil").prop('checked', true);
    }
    if (data.canTrxIBank == true) {
        $("#_internetBankingcheck").prop('checked', true);
    }
    else {
        $("#_internetBankingcheck").prop('checked', false);
    }
    if (data.canTrxMBank == true) {
        $("#_mobileBankingcheck").prop('checked', true);
    }
    else {
        $("#_mobileBankingcheck").prop('checked', false);
    }
    RDBBit = data.canTrxRDB;
    RDBRedeemBit = data.canTrxRDBRedeem;
    RDBSwitchBit = data.canTrxRDBSwitch;
    RDBMinSubs = data.rdbMinSubs;
    RDBFeeSubsIns = data.rdbPctFeeSubsWithIns;
    RDBFeeSubsNoIns = data.rdbPctFeeSubsNoIns;
    RDBFullRedeemBit = data.rdbMustFullRedeem;
    RDBFeeRedempIns = data.rdbPctFeeRedempWithIns;
    RDBFeeRedempNoIns = data.rdbPctFeeRedempNoIns;
    RDBFullSwitchBit = data.rdbMustFullSwitch;

}
function onChange_pctFeeSubs() {
    if ($("#_pctFeeSubs").data("kendoNumericTextBox").value() > 100) {
        $("#_pctFeeSubs").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_pctFeeSubs() {
    if ($("#_pctFeeSubs").data("kendoNumericTextBox").value() > 100) {
        $("#_pctFeeSubs").data("kendoNumericTextBox").value(0);
    }
}
function onChange_pctFeeRedemp() {
    if ($("#_pctFeeRedemp").data("kendoNumericTextBox").value() > 100) {
        $("#_pctFeeRedemp").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_pctFeeRedemp() {
    if ($("#_pctFeeRedemp").data("kendoNumericTextBox").value() > 100) {
        $("#_pctFeeRedemp").data("kendoNumericTextBox").value(0);
    }
}
function onChange_pctFeeSwitching() {
    if ($("#_pctFeeSwitching").data("kendoNumericTextBox").value() > 100) {
        $("#_pctFeeSwitching").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_pctFeeSwitching() {
    if ($("#_pctFeeSwitching").data("kendoNumericTextBox").value() > 100) {
        $("#_pctFeeSwitching").data("kendoNumericTextBox").value(0);
    }
}
function onChange_pctHoldAmount() {
    if ($("#_pctHoldAmount").data("kendoNumericTextBox").value() > 100) {
        $("#_pctHoldAmount").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_pctHoldAmount() {
    if ($("#_pctHoldAmount").data("kendoNumericTextBox").value() > 100) {
        $("#_pctHoldAmount").data("kendoNumericTextBox").value(0);
    }
}
function onChange_pctHoldAmount() {
    if ($("#_pctHoldAmount").data("kendoNumericTextBox").value() > 100) {
        $("#_pctHoldAmount").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_pctHoldAmount() {
    if ($("#_pctHoldAmount").data("kendoNumericTextBox").value() > 100) {
        $("#_pctHoldAmount").data("kendoNumericTextBox").value(0);
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