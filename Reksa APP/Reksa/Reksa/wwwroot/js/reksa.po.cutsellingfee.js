
var _intProdId;
$(document).ready(function () {
    var dateTimePicker2 = new Date();
    $("#dateTimePicker2").val(dateTimePicker2.getDate() + '/' + (dateTimePicker2.getMonth() + 1) + '/' + dateTimePicker2.getFullYear());
});
function ValidateProduct(ProdCode) {
    return $.ajax({
        type: 'GET',
        url: '/Global/ValidateProduct',
        data: { Col1: ProdCode, Col2: '', Validate: 1 },
        async: false
    });
}
function callReksaCutSellingFee() {
    var dtStartDate = $("#dateTimePicker1").val();
    var dtEndDate = $("#dateTimePicker2").val();
    $.ajax({
        type: 'POST',
        url: '/PO/ProcessCutSellingFee',
        data: { StartDate: dtStartDate, EndDate: dtEndDate, ProdId: _intProdId },
        success: function (data) {
            if (data.blnResult) {
                swal("Success", "Proses Cut Selling Fee berhasil", "success");
                var res = callReksaGetLastFeeDate();
                res.success(function (data) {
                    if (data.blnResult) {
                        var dateTimePicker1 = new Date(data.dtStartDate);
                        $("#dateTimePicker1").val(dateTimePicker1.getDate() + '/' + (dateTimePicker1.getMonth() + 1) + '/' + dateTimePicker1.getFullYear());
                    }
                    else {
                        swal("Warning", data.ErrMsg, "warning");
                    }
                });
                var dateTimePicker2 = new Date();
                $("#dateTimePicker2").val(dateTimePicker2.getDate() + '/' + (dateTimePicker2.getMonth() + 1) + '/' + dateTimePicker2.getFullYear());
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}
function callReksaGetLastFeeDate() {
    return $.ajax({
        type: 'GET',
        url: '/PO/GetLastFeeDate',
        data: { Type: 3, ManId: 1, ProdId: _intProdId },
        async: false
    });
}