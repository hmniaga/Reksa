$("#btnRefresh").click(function () {
    subRefresh();
});

$("#srcClient").click(function srcClient_click() {
    var strCriteria = $('#ProdId').val();
    var url = "/Global/SearchClient/?criteria=" + encodeURIComponent(strCriteria);
    $('#ClientModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});