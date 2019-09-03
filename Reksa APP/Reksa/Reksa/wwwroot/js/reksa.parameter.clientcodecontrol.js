var _intType;
$(document).ready(function () {
    _intType = 0;
    subResetToolBar();
});
function subResetToolBar() {
    switch (_intType) {
        case 0:
            {
                $("#btnRefresh").show();
                $("#btnTutup").hide();
                break;
            }
        case 1:
            {
                $("#btnRefresh").show();
                $("#btnTutup").show();
                break;
            }
    }
}
function subRefresh() {
    var ClientId = $("#ClientId").val();
    $.ajax({
        type: 'GET',
        url: '/Transaksi/GetLatestBalance',
        data: { ClientId: ClientId },
        success: function (data) {
            if (data.blnResult) {
                $("#MoneyNom").data("kendoNumericTextBox").value(data.unitBalance);
                _intType = 1;
                subResetToolBar();
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}
function Reset() {
    $("#srcClient_text1").val();
    $("#srcClient_text2").val();
    $("#MoneyNom").data("kendoNumericTextBox").value(0);
}
function subNonAktif() {
    var ClientId = $("#ClientId").val();
    var UnitBalance = $("#MoneyNom").data("kendoNumericTextBox").value();
    $.ajax({
        type: 'POST',
        url: '/Parameter/NonAktifClientId',
        data: { ClientId: ClientId, UnitBalance: UnitBalance },
        success: function (data) {
            if (data.blnResult) {
                swal("Proses berhasil", "Client code menjadi nonaktifkan jika sudah diotorisasi!", "success");
                Reset();
                _intType = 0;
                subResetToolBar();
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}