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
    subSave();
});
$("#btnCancel").click(function () {
    subCancel();
});