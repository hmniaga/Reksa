$("#cmpsrSearch1").click(function cmpsrSearch1_click() {
    var url = $(this).attr("href");
    $('#cmpsrSearch1Modal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#cmpsrSearch2").click(function cmpsrSearch2_click() {
    var url = $(this).attr("href", "/Global/SearchProductSwitchIn/?criteria=PAR&prodcode=" + $("#cmpsrSearch1_text1").val());
    $('#cmpsrSearch2Modal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});


$("#btnRefresh").click(function btnRefresh_click() {
    subRefresh();
});
$("#btnNew").click(function btnNew_click() {
    subNew();
});
$("#btnEdit").click(function btnEdit_click() {
    subUpdate();
});
$("#btnDelete").click(function btnDelete_click() {
    subDelete();
});
$("#btnSave").click(function btnSave_click() {
    subSave();
});
$("#btnCancel").click(function btnCancel_click() {
    subCancel();
});

$("#dtpSP").change(function dtpSP_ValueChanged() {
    if (_strTreeInterface == "RHT") {
        var dateStr = $("#dtpSP").val();
        var [day, month, year] = dateStr.split("/");
        $("#txtbSP1").val(year)
    }
});

$("#txtbSP1").change(function txtbSP1_change() {
    if ((_strTreeInterface == "WPR") && (_intType == 1)) {
        var NIK = $("#txtbSP1").val();
        subRefreshWARPED(NIK);
    }
});
$("#txtbSP3").change(function txtbSP3_change() {
    if (_strTreeInterface == "SWC") {
        Puntos($("#txtbSP3").val(), 2);
        //txtbSP3.Select(txtbSP3.TextLength, 0);
    }
});

function onBounddgvParam() {
    var grid = $("#dgvParam").data("kendoGrid");
    var len = grid.dataSource.data().length;

    if (len > 0) {
        grid.select(0);
    }
    else
    {
        $("#txtbSP1").val("");
        $("#txtbSP2").val("");
        var today = new Date();
        $("#dtpSP").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());

    }
}

function dgvParam_Click() {
    $("#txtbSP1").val("");
    $("#txtbSP2").val("");
    var today = new Date();
    $("#dtpSP").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());
    _Id = 0;
    _tanggalValuta = new Date();


    var data = this.dataItem(this.select());    
    _Id = data.id;
    _tanggalValuta = data.tanggalValuta;
    if (_strTreeInterface == "RSB") {
        $("#cmpsrSearch1_text1").val(data.kode);
        ValidateProduct($("#cmpsrSearch1_text1").val(), function (result) { $("#cmpsrSearch1_text2").val(result[0].ProdName); });
        $("#txtbSP3").val(data.desc2);
        $("#textBox1").val(data.desc5);
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
        $("#cmpsrSearch1_text1").val(data.kode);
        ValidateProduct($("#cmpsrSearch1_text1").val(), function (result) { $("#cmpsrSearch1_text2").val(result[0].ProdName); });

        $("#comboBox3").data("kendoDropDownList").text(data.desc2) 
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

        $("#cmpsrSearch1_text1").val(data.kode);
        ValidateProduct($("#cmpsrSearch1_text1").val(), function (result) { $("#cmpsrSearch1_text2").val(result[0].ProdName); });
        $("#cmpsrSearch2_text1").val(data.deskripsi);
        ValidateProduct($("#cmpsrSearch2_text1").val(), function (result) { $("#cmpsrSearch2_text2").val(result[0].ProdName); });
        
        minRedempt = data.minSwitchRedempt;
        switchFee = data.switchingFeeNonKaryawan;
        minRedempt = Math.round(minRedempt * 100) / 100;
        switchFee = Math.round(switchFee * 100) / 100;
        switchFeeKary = data.switchingFeeKaryawan;
        switchFeeKary = Math.round(switchFeeKary * 100) / 100;

        $("#txtbSP3").val(minRedempt);
        Puntos($("#txtbSP3").val(), 2);
        //txtbSP3.Select(txtbSP3.TextLength, 0);
        $("#txtbSP5").val(switchFee);
        $("#textPctSwc").val(switchFeeKary);
        $("#comboBox1").val(data.jenisSwitchRedempt);
    }
    else if (_strTreeInterface == "MSC") {
        try
        {
            $("#cmpsrSearch1_text1").val(data.kode);
            ValidateProduct($("#cmpsrSearch1_text1").val(), function (result) { $("#cmpsrSearch1_text2").val(result[0].ProdName); });
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
    if (_strTreeInterface == "OFF") {
        $("#cmpsrSearch1_text1").val(data.kode);
        ValidateOffice($("#cmpsrSearch1_text1").val(), function (result) { $("#cmpsrSearch1_text2").val(result); });
    }
    else if (_strTreeInterface == "CTR") {        
        $("#cmpsrSearch1_text1").val(data.kode);
        ValidateCountry($("#cmpsrSearch1_text1").val(), function (result) { $("#cmpsrSearch1_text2").val(result[0].NamaNegara); });

    }
}

function ValidateProduct(ProductCode, result) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateProduct',
        data: { Col1: ProductCode, Col2: '', Validate: 1 },
        success: function (data) {
            if (data.length != 0) {
                result(data);
            }
            else {
                result('');
            }
        }
    });
}
function ValidateCountry(CountryCode, result) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateCountry',
        data: { Col1: CountryCode, Col2: '', Validate: 1 },
        success: function (data) {
            if (data.length != 0) {
                result(data);
            }
            else {
                result('');
            }
        }
    });
}
function ValidateOffice(OfficeId, result) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateOffice',
        data: { Col1: OfficeId, Col2: '', Validate: 1 },
        success: function (data) {
            if (data.length != 0) {
                result(data[0].OfficeName);
            } else {
                result("");
            }
        }
    });
}