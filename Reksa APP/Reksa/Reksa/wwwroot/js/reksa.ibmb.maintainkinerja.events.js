//click
$("#btnRefresh").click(function () {
    subRefresh();
});
$("#btnEdit").click(function () {
    subUpdate();
});
$("#btnSave").click(function () {
    subSave();
});
$("#btnCancel").click(function () {
    subCancel();
});

function onRowKinerjaSelect(e) {
    var data = this.dataItem(this.select());
    $("#_cmpsrProduct_text1").val(data.ProdCode);
    $("#_cmpsrProduct_text2").val(data.ProdName);
    $("#ProdId").val(data.ProdId);
    $("#_matauang").val(data.ProdCCY);
    $("#_tipeReksadana").val(data.TypeName);
    if (data.IsVisible) {
        $("#_isVisible").prop('checked', true);
    }
    else {
        $("#_isVisible").prop('checked', false);
    }
    var ValueDate = new Date(data.ValueDate);
    $("#_NAVDate").val(ValueDate.getDate() + '/' + (ValueDate.getMonth() + 1) + '/' + ValueDate.getFullYear());

    $("#_sehari").data("kendoNumericTextBox").value(data.Sehari);
    $("#_seminggu").data("kendoNumericTextBox").value(data.Seminggu);
    $("#_sebulan").data("kendoNumericTextBox").value(data.Sebulan);
    $("#_setahun").data("kendoNumericTextBox").value(data.Setahun);
}
