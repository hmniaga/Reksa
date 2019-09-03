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
    subSave();
});
$("#btnCancel").click(function () {
    subCancel();
});

//change
$("#_cmpsrProduct_text1").change(function () {
    if (intMyType == "A") {
        if (($("#_cmpsrProduct_text1").val() != "") && ($("#_cmpsrProduct_text2").val() != "")) {
            GetInitializeData($("#ProdId").val());
        }
        if ($("#_cmpsrProduct_text2").val() == "") {
            subReset2();
        }
    }
});
$("#_cmpsrBeneficiaryBC_text1").change(function () {
    $("#_txtBeneficiaryBankName").val($("#_cmpsrBeneficiaryBC_text2").val());
    $("#_txtBeneficiaryAddress").val($("#BankCodeAddress").val());
}); 
