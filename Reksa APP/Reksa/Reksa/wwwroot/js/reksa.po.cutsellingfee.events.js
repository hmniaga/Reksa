
$("#btnProcess").click(function () {
    if ($("#cmpsrProduct_text1").val() == "") {
        swal("Warning", "Kode Produk Wajib diisi", "warning");
        return;
    }
    _intProdId = $("#ProdId").val();
    if (_intProdId != 0 && ($("#cmpsrProduct_text2").val() != "")) {
        callReksaCutSellingFee();
    }
    else {
        swal("Warning", "Kode Produk Wajib diisi", "warning");
    }
});
$("#cmpsrProduct_text1").change(function () {

    var res = ValidateProduct($("#cmpsrProduct_text1").val());
    res.success(function (data) {
        _intProdId = data[0].ProdId;
    });
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
}); 