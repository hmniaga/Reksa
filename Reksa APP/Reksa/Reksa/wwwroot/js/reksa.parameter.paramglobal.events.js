$("#cmpsrSearch1").click(function cmpsrSearch1_click() {
    var url = $(this).attr("href");
    $('#cmpsrSearch1Modal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#cmpsrSearch2").click(function cmpsrSearch2_click() {
    var url = $(this).attr("href", "/Global/SearchProductSwitchIn/?prodcode=" + $("#ProductCode").val());
    $('#cmpsrSearch2Modal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});


$("#btnRefresh").click(function () {
    subRefresh();
});
$("#btnNew").click(function () {
    $("#btnNew").hide();
    $("#btnEdit").hide();
    $("#btnDelete").hide();
    $("#btnSave").show();
    $("#btnCancel").show();
    subNew();
});
$("#btnEdit").click(function () {
    $("#btnNew").hide();
    $("#btnEdit").hide();
    $("#btnDelete").hide();
    $("#btnSave").show();
    $("#btnCancel").show();
    subUpdate();
});
$("#btnDelete").click(function () {
    subDelete();
});
$("#btnSave").click(function () {
    subSave();
});
$("#btnCancel").click(function () {
    $("#btnNew").show();
    $("#btnEdit").show();
    $("#btnDelete").show();
    $("#btnSave").hide();
    $("#btnCancel").hide();
    disableAll(0);
});


$("#txtbSP1").change(function () {
    if ((_strTreeInterface == "WPR") && (_intType == 1)) {
        var NIK = $("#txtbSP1").val();
        subRefreshWARPED(NIK);
    }
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
    if (_strTreeInterface == "RSB") {
        //cmpsrSearch1.Text1 = dgvParam.CurrentRow.Cells["Kode"].Value.ToString();
        //cmpsrSearch1.ValidateField();
        $("#txtbSP3").val(data.desc2);
        //$("#textBox1").val(data.Desc5);
        $("#txtbSP5").val(data.jenisSwitchRedempt);
        $("#textPctSwc").val(data.keterangan);
    }
    else if (_strTreeInterface == "WPR") {
        $("#txtbSP3").val(data.desc2);
        $("#txtbSP4").val(data.desc5);
        var TglExpire = new Date(data.tglExpire);
        $("#dtpSP5").val(pad((TglExpire.getDate()), 2) + '/' + pad((TglExpire.getMonth() + 1), 2) + '/' + TglExpire.getFullYear());
    }
    else if (_strTreeInterface == "RPP") {
        //cmpsrSearch1.Text1 = dgvParam.CurrentRow.Cells["Kode"].Value.ToString();
        //cmpsrSearch1.ValidateField();
        $("#comboBox3").val(data.desc2);
        var TglExpire = new Date(data.tglExpire);
        $("#dtpSP").val(pad((TglExpire.getDate()), 2)  + '/' + pad((TglExpire.getMonth() + 1), 2) + '/' + TglExpire.getFullYear());
    }
    else if (_strTreeInterface == "RTY") {
        $("#txtbSP1").val(data.kode);
        $("#txtbSP2").val(data.deskripsi);
        var TanggalValuta = new Date(data.tanggalValuta);
        $("#dtpSP").val(pad((TanggalValuta.getDate()), 2)  + '/' + pad((TanggalValuta.getMonth() + 1), 2) + '/' + TanggalValuta.getFullYear());
        $("#txtbSP3").val(data.desc2);
    }

    if (_strTreeInterface == "PFP") {
        $("#txtbSP1").val(data.id);
        $("#txtbSP2").val(data.kode);
        $("#txtbSP3").val(data.deskripsi);
    }
    else if (_strTreeInterface == "SWC") {
        var minRedempt = 0;
        var switchFee;
        var switchFeeKary;

        //cmpsrSearch1.Text1 = dgvParam.CurrentRow.Cells["Kode"].Value.ToString();
        //cmpsrSearch1.ValidateField();
        //cmpsrSearch2.Criteria = cmpsrSearch1.Text1.Trim();
        //cmpsrSearch2.Text1 = dgvParam.CurrentRow.Cells["Deskripsi"].Value.ToString();
        //cmpsrSearch2.ValidateField();

        try {
            minRedempt = data.minSwitchRedempt;
            switchFee = data.switchingFeeNonKaryawan;
            minRedempt = Math.round(minRedempt * 100) / 100;
            switchFee = Math.round(switchFee * 100) / 100;
            switchFeeKary = data.switchingFeeKaryawan;
            switchFeeKary = Math.round(switchFeeKary * 100) / 100;

            $("#txtbSP3").val(minRedempt);
            //txtbSP3.Text = Puntos(txtbSP3.Text, 2);
            //txtbSP3.Select(txtbSP3.TextLength, 0);
            $("#txtbSP5").val(switchFee);
            $("#textPctSwc").val(switchFeeKary);
        }
        catch
        {
            return;
        }
        $("#comboBox1").val(data.jenisSwitchRedempt);
    }
    else if (_strTreeInterface == "MSC") {
        try {
            //cmpsrSearch1.Text1 = dgvParam.CurrentRow.Cells["Kode"].Value.ToString();
            //cmpsrSearch1.ValidateField();
        }
        catch
        {
            return;
        }
        if (data.prodId == '1') {
            $('#checkBox1').prop('checked', true);
        }
        else {
            $('#checkBox1').prop('checked', false);
        }
        $("#txtbSP2").val(data.deskripsi);
    }
    else {
        $("#txtbSP1").val(data.kode);
        $("#txtbSP2").val(data.deskripsi);
        var TanggalValuta = new Date(data.tanggalValuta);
        $("#dtpSP").val(pad((TanggalValuta.getDate()), 2) + '/' + pad((TanggalValuta.getMonth() + 1), 2) + '/' + TanggalValuta.getFullYear());
    }

    if (_strTreeInterface == "GFM") {
        $("#txtbSP3").val(data.desc2);
        $("#txtbSP4").val(data.desc5);
    }

    if (_strTreeInterface == "MNI" || _strTreeInterface == "CTD") {
        $("#txtbSP3").val(data.desc2);
    }
}