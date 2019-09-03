var intMyType;
$(document).ready(function () {
    intMyType = "B";
    SetToolbar(intMyType);
    SetControl(intMyType);
});

function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/Transaksi/PopulateTTCompletion',
        data: { intProdId: $("#ProdId").val() },
        success: function (data) {
            if (data.blnResult) {
                $("#_prodCurr").val(data.listTransactionTT.ProdCurr);
                $("#_txtNamaPemohon").val(data.listTransactionTT.NamaPemohon);
                $("#_txtAlamatPemohon1").val(data.listTransactionTT.AlamatPemohon1);
                $("#_txtAlamatPemohon2").val(data.listTransactionTT.AlamatPemohon2);
                $("#_txtNamaPenerima").val(data.listTransactionTT.NamaPenerima);
                $("#_txtAlamatPenerima1").val(data.listTransactionTT.AlamatPenerima1);
                $("#_txtAlamatPenerima2").val(data.listTransactionTT.AlamatPenerima2);
                $("#_txtAlamatPenerima3").val(data.listTransactionTT.AlamatPenerima3);
                $("#_txtBeneficiaryAccNo").val(data.listTransactionTT.BeneficiaryAccNo);
                $("#_txtBeneficiaryBankName").val(data.listTransactionTT.BeneficiaryBankName);
                $("#_txtBeneficiaryAddress").val(data.listTransactionTT.BeneficiaryBankAddress);
                $("#_txtRemarks1").val(data.listTransactionTT.PaymentRemarks1);
                $("#_txtRemarks2").val(data.listTransactionTT.PaymentRemarks2);
                $("#_txtNoRekProduk").val(data.listTransactionTT.NoRekProduk);
                $("#_txtGLBiayaFullAmt").val(data.listTransactionTT.GLBiayaFullAmt);

                $("#_cmpsrBeneficiaryBC_text1").val(data.listTransactionTT.BeneficiaryBankCode);
                $("#_cmpsrBeneficiaryBC_text2").val(data.listTransactionTT.BeneficiaryBankName);
                intMyType = "R";
                SetToolbar(intMyType);
                SetControl(intMyType);
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}
function subNew() {
    intMyType = "A";
    SetToolbar(intMyType);
    SetControl(intMyType);
    subReset();
}
function subUpdate() {
    intMyType = "U";
    SetToolbar(intMyType);
    SetControl(intMyType);
}
function subDelete() {
    var res = subProcess();
    res.success(function (data) {
        if (data.blnResult) {
            intMyType = "D";
            SetToolbar(intMyType);
            SetControl(intMyType);
            subReset();
            swal("Success", "Data berhasil diproses. Harap melakukan otorisasi supervisor!", "success");
        }
        else {
            swal("Warning", data.ErrMsg, "warning");
        }
    });
}
function subSave() {
    if ($("#_cmpsrProduct_text1").val() == "") {
        swal("Warning", "Product harus diisi!", "warning");
        return;
    }

    if ($("#_txtNamaPenerima").val() == "") {
        swal("Warning", "Nama Penerima harus diisi!", "warning");
        return;
    }

    if ($("#_txtAlamatPenerima1").val() == "") {
        swal("Warning", "Alamat Penerima harus diisi!", "warning");
        return;
    }

    if ($("#_cmpsrBeneficiaryBC_text1").val() == "") {
        swal("Warning", "Beneficiary bank code harus diisi!", "warning");
        return;
    }

    if ($("#_txtBeneficiaryAccNo").val() == "") {
        swal("Warning", "Beneficiary account number harus diisi!", "warning");
        return;
    }

    if ($("#_txtGLBiayaFullAmt").val() == "") {
        swal("Warning", "No GL Full Amount harus diisi!", "warning");
        return;
    }

    var res = subProcess();
    res.success(function (data) {
        if (data.blnResult) {
            intMyType = "S";
            SetToolbar(intMyType);
            SetControl(intMyType);
            subReset();
            swal("Success", "Data berhasil diproses. Harap melakukan otorisasi supervisor!", "success");
        }
        else {
            swal("Warning", data.ErrMsg, "warning");
        }
    });
}
function subCancel() {
    intMyType = "B";
    SetToolbar(intMyType);
    SetControl(intMyType);
    subReset();
}
function subProcess() {
    var model = JSON.stringify({
        'ProdId': $("#ProdId").val(),
        'ProdCurr': $("#_prodCurr").val(),
        'NamaPemohon': $("#_txtNamaPemohon").val(),
        'AlamatPemohon1': $("#_txtAlamatPemohon1").val(),
        'AlamatPemohon2': $("#_txtAlamatPemohon2").val(),
        'NamaPenerima': $("#_txtNamaPenerima").val(),
        'AlamatPenerima1': $("#_txtAlamatPenerima1").val(),
        'AlamatPenerima2': $("#_txtAlamatPenerima2").val(),
        'AlamatPenerima3': $("#_txtAlamatPenerima3").val(),
        'BeneficiaryBankCode': $("#_cmpsrBeneficiaryBC_text1").val(),
        'BeneficiaryAccNo': $("#_txtBeneficiaryAccNo").val(),
        'BeneficiaryBankName': $("#_txtBeneficiaryBankName").val(),
        'BeneficiaryBankAddress': $("#_txtBeneficiaryAddress").val(),
        'PaymentRemarks1': $("#_txtRemarks1").val(),
        'PaymentRemarks2': $("#_txtRemarks2").val(),
        'NoRekProduk': $("#_txtNoRekProduk").val(),
        'GLBiayaFullAmt': $("#_txtGLBiayaFullAmt").val(),
        'InputterNIK': 0,
        'ActionType': intMyType,
    });

    return $.ajax({
        type: 'POST',
        url: '/Transaksi/MaintainCompletion',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        async: false
    });
}
function SetToolbar(intMyType) {
    if (intMyType == "B" || intMyType == "S" || intMyType == "D") {
        $("#btnRefresh").show();
        $("#btnNew").show();
        $("#btnEdit").hide();
        $("#btnDelete").hide();
        $("#btnSave").hide();
        $("#btnCancel").hide();
    }
    if (intMyType == "A") {
        $("#btnRefresh").show();
        $("#btnNew").hide();
        $("#btnEdit").hide();
        $("#btnDelete").hide();
        $("#btnSave").show();
        $("#btnCancel").show();
    }

    if (intMyType == "U") {
        $("#btnRefresh").show();
        $("#btnNew").hide();
        $("#btnEdit").hide();
        $("#btnDelete").hide();
        $("#btnSave").show();
        $("#btnCancel").show();
    }
    if (intMyType == "R") {
        $("#btnRefresh").show();
        $("#btnNew").show();
        $("#btnEdit").show();
        $("#btnDelete").show();
        $("#btnSave").hide();
        $("#btnCancel").hide();
    }
}
function SetControl(intMyType) {
    if (intMyType == "R" || intMyType == "B" || intMyType == "D" || intMyType == "S") {
        $("#_cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#_cmpsrProduct_text1").prop('disabled', false);
        //$("#_cmpsrProduct_text2").prop('disabled', false);
        $("#_cmpsrBeneficiaryBC").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#_cmpsrBeneficiaryBC_text1").prop('disabled', true);
        //$("#_cmpsrBeneficiaryBC_text2").prop('disabled', true);
        //_cmpsrProduct.Enabled = true;
        //_cmpsrBeneficiaryBC.Enabled = false;
        $("#_txtNamaPenerima").prop('disabled', true);
        $("#_txtAlamatPenerima1").prop('disabled', true);
        $("#_txtAlamatPenerima2").prop('disabled', true);
        $("#_txtAlamatPenerima3").prop('disabled', true);
        $("#_txtBeneficiaryAccNo").prop('disabled', true);
        $("#_txtGLBiayaFullAmt").prop('disabled', true);
    }

    if (intMyType == "A") {
        $("#_cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#_cmpsrProduct_text1").prop('disabled', false);
        //$("#_cmpsrProduct_text2").prop('disabled', false);
        $("#_cmpsrBeneficiaryBC").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#_cmpsrBeneficiaryBC_text1").prop('disabled', false);
        //$("#_cmpsrBeneficiaryBC_text2").prop('disabled', false);
        //_cmpsrProduct.Enabled = true;
        //_cmpsrBeneficiaryBC.Enabled = true;
        $("#_txtNamaPenerima").prop('disabled', false);
        $("#_txtAlamatPenerima1").prop('disabled', false);
        $("#_txtAlamatPenerima2").prop('disabled', false);
        $("#_txtAlamatPenerima3").prop('disabled', false);
        $("#_txtBeneficiaryAccNo").prop('disabled', false);
        $("#_txtGLBiayaFullAmt").prop('disabled', false);
    }

    if (intMyType == "U") {
        $("#_cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#_cmpsrProduct_text1").prop('disabled', true);
        //$("#_cmpsrProduct_text2").prop('disabled', true);
        $("#_cmpsrBeneficiaryBC").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#_cmpsrBeneficiaryBC_text1").prop('disabled', false);
        //$("#_cmpsrBeneficiaryBC_text2").prop('disabled', false);
        //_cmpsrProduct.Enabled = false;
        //_cmpsrBeneficiaryBC.Enabled = true;
        $("#_txtNamaPenerima").prop('disabled', false);
        $("#_txtAlamatPenerima1").prop('disabled', false);
        $("#_txtAlamatPenerima2").prop('disabled', false);
        $("#_txtAlamatPenerima3").prop('disabled', false);
        $("#_txtBeneficiaryAccNo").prop('disabled', false);
        $("#_txtGLBiayaFullAmt").prop('disabled', false);
    }
}
function subReset() {
    $("#_cmpsrBeneficiaryBC_text1").val('');
    $("#_cmpsrBeneficiaryBC_text2").val('');

    $("#_cmpsrProduct_text1").val('');
    $("#_cmpsrProduct_text2").val('');

    $("#_txtNamaPenerima").val('');
    $("#_txtAlamatPenerima1").val('');
    $("#_txtAlamatPenerima2").val('');
    $("#_txtAlamatPenerima3").val('');
    $("#_txtBeneficiaryAccNo").val('');
    $("#_txtBeneficiaryBankName").val('');
    $("#_txtBeneficiaryAddress").val('');
    $("#_txtGLBiayaFullAmt").val('');

    subReset2();
}
function subReset2() {
    $("#_prodCurr").val('');
    $("#_txtNamaPemohon").val('');
    $("#_txtAlamatPemohon1").val('');
    $("#_txtAlamatPemohon2").val('');
    $("#_txtRemarks1").val('');
    $("#_txtRemarks2").val('');
    $("#_txtNoRekProduk").val('');
}
function GetInitializeData(ProdId) {
    $.ajax({
        type: 'GET',
        url: '/Transaksi/InitializeDataTTCompletion',
        data: { intProdId: ProdId },
        success: function (data) {
            if (data.blnResult) {
                $("#_prodCurr").val(data.listTransactionTT.ProdCurr);
                $("#_txtNamaPemohon").val(data.listTransactionTT.NamaPemohon);
                $("#_txtAlamatPemohon1").val(data.listTransactionTT.AlamatPemohon1);
                $("#_txtAlamatPemohon2").val(data.listTransactionTT.AlamatPemohon2);
                $("#_txtRemarks1").val(data.listTransactionTT.PaymentRemarks1);
                $("#_txtRemarks2").val(data.listTransactionTT.PaymentRemarks2);
                $("#_txtNoRekProduk").val(data.listTransactionTT.NoRekProduk);
            }
        }
    });
}
