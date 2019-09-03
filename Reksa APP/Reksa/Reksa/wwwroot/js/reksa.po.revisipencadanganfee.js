$(document).ready(function () {
    PopulateLastDate();
});
function PopulateLastDate() {
    $.ajax({
        type: 'GET',
        url: '/PO/GetLastTanggalPencadangan',
        success: function (data) {
            if (data.blnResult) {
                var StartDate = new Date(data.StartDate);
                $("#_awal").val(StartDate.getDate() + '/' + pad((StartDate.getMonth() + 1), 2) + '/' + StartDate.getFullYear());
                var EndDate = new Date(data.EndDate);
                $("#_akhir").val(EndDate.getDate() + '/' + pad((EndDate.getMonth() + 1), 2) + '/' + EndDate.getFullYear());
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}
function Process() {
    var Tipe = 'REVISI PENCADANGAN';
    var ProdCode = $("#_cmpsrProduct_text1").val();
    var StartDate = $("#_awal").val();
    var EndDate = $("#_akhir").val();
    $.ajax({
        type: 'POST',
        url: '/PO/MaintainPencadangan',
        data: { Tipe: Tipe, ProdCode: ProdCode, StartDate: StartDate, EndDate: EndDate },
        success: function (data) {
            if (data.blnResult) {
                swal("Proses berhasil", "Jurnal akan dijalankan setelah diotorisasi supervisor!", "success");
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}
function pad(num, size) {
    var s = "000000000" + num;
    return s.substr(s.length - size);
}