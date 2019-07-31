$("#cmpsrCustody").click(function srcCIFRedemp_click() {
    var url = $(this).attr("href");
    $('#CustodyModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});

$("#cmpsrProduct").click(function srcCIFRedemp_click() {
    var url = $(this).attr("href");
    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});