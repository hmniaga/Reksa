$("#cmpsrSearch1").click(function cmpsrSearch1_click() {
    var url = $(this).attr("href");
    $('#GiftModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcOffice").click(function srcOffice_click() {
    var url = $(this).attr("href");
    $('#OfficeModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
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


function onBounddgvParam() {
    var grid = $("#dgvParam").data("kendoGrid");
    var len = grid.dataSource.data().length;

    if (len > 0) {
        grid.select(0);
    }
}

function dgvParam_Click() {
    var data = this.dataItem(this.select());
    
    _Id = data.id;
    $("#txtbSP1").val(data.kode);
    $("#txtbSP2").val(data.deskripsi);
    var tanggalValuta = new Date(data.tanggalValuta);
    _tanggalValuta = new Date(data.tanggalValuta);
    $("#dtpSP").val(pad((tanggalValuta.getDate()), 2) + '/' + pad((tanggalValuta.getMonth() + 1), 2) + '/' + tanggalValuta.getFullYear());

    if (_strTreeInterface == "SAC") {
        $("#cmpsrOffice_text1").val(data.officeId);
        ValidateOffice($("#cmpsrOffice_text1").val(), function (output) {
            $("#cmpsrOffice_text2").val(output);
        });
    }
    else if (_strTreeInterface == "GFP") {
        $("#txtbSP11").val(data.desc2);
        var tglEfektif = new Date(data.tglEfektif);
        $("#dtpSP12").val(pad((tglEfektif.getDate()), 2) + '/' + pad((tglEfektif.getMonth() + 1), 2) + '/' + tglEfektif.getFullYear());
        var tglExpire = new Date(data.tglExpire);
        $("#dtpSP13").val(pad((tglExpire.getDate()), 2) + '/' + pad((tglExpire.getMonth() + 1), 2) + '/' + tglExpire.getFullYear());

        $("#cmpsrGift_text1").val(data.kode);
        $("#MoneyNominal").data("kendoNumericTextBox").value(data.deskripsi);
    }
    //else {
    //    $("#txtbSP2").val('');
    //    var today = new Date();
    //    $("#dtpSP").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());
    //}

    switch (_strTreeInterface) {
        case ("SNV"): $("#txtbSP1").val('NAV');
            break;
        case ("SDV"): $("#txtbSP1").val('Deviden');
            break;
        case ("SKR"): $("#txtbSP1").val('Kurs');
            break;
        case ("RDD"): $("#txtbSP1").val('Schedule');
            $("#txtbSP2").val('Schedule Deviden');
            break;
    }
};