$("#cmpsrCustody").click(function cmpsrCustody_click() {
    var url = $(this).attr("href");
    $('#CustodyModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});

$("#cmpsrProduct").click(function cmpsrProduct_click() {
    var url = $(this).attr("href");
    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});

//click
$("#btnUpload").click(function () {
    subUpload();
});
