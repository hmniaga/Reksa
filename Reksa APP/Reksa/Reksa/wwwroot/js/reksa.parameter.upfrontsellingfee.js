var intMyType;
$(document).ready(function () {
    var grid = {
        height: 200
    };
    $("#dataGridView1").kendoGrid(grid);
    intMyType = "B";
    SetToolbar(intMyType);
    SetControl(intMyType);

});
function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/Parameter/RefreshMaintenanceUpFrontSelling',
        data: { ProdukId: $("#ProdId").val(), FeeType: $("#_jenisFeeCmb").data('kendoDropDownList').value() },
        success: function (data) {
            if (data.blnResult) {
                $("#PercentageDefault").data("kendoNumericTextBox").value(data.listFee.PercentDefault);

                $("#_namaGL1").val(data.listReksaListGL[0].GLName);
                $("#_namaGL2").val(data.listReksaListGL[1].GLName);
                $("#_namaGL3").val(data.listReksaListGL[2].GLName);
                $("#_namaGL4").val(data.listReksaListGL[3].GLName);
                $("#_namaGL5").val(data.listReksaListGL[4].GLName);

                $("#_noGL1").val(data.listReksaListGL[0].GLNumber);
                $("#_noGL2").val(data.listReksaListGL[1].GLNumber);
                $("#_noGL3").val(data.listReksaListGL[2].GLNumber);
                $("#_noGL4").val(data.listReksaListGL[3].GLNumber);
                $("#_noGL5").val(data.listReksaListGL[4].GLNumber);

                $("#_officeIdNoGL2").val(data.listReksaListGL[1].OfficeId);
                $("#_officeIdNoGL3").val(data.listReksaListGL[2].OfficeId);
                $("#_officeIdNoGL4").val(data.listReksaListGL[3].OfficeId);
                $("#_officeIdNoGL5").val(data.listReksaListGL[4].OfficeId);

                $("#_percentGL1").data("kendoNumericTextBox").value(data.listReksaListGL[0].Percentage);
                $("#_percentGL2").data("kendoNumericTextBox").value(data.listReksaListGL[1].Percentage);
                $("#_percentGL3").data("kendoNumericTextBox").value(data.listReksaListGL[2].Percentage);
                $("#_percentGL4").data("kendoNumericTextBox").value(data.listReksaListGL[3].Percentage);
                $("#_percentGL5").data("kendoNumericTextBox").value(data.listReksaListGL[4].Percentage);

                var _percentGL1 = $("#_percentGL1").val();
                var _percentGL2 = $("#_percentGL2").val();
                var _percentGL3 = $("#_percentGL3").val();
                var _percentGL4 = $("#_percentGL4").val();
                var _percentGL5 = $("#_percentGL5").val();
                var _TotalPercentGL = +_percentGL1 + +_percentGL2 + +_percentGL3 + +_percentGL4 + +_percentGL5;

                $("#_TotalPercentGL").data("kendoNumericTextBox").value(_TotalPercentGL);

                intMyType = "R";
                SetToolbar(intMyType);
                SetControl(intMyType);
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
                Reset();
            }
        }
    });
}
function subNew() {
    intMyType = "A";
    SetControl(intMyType);
    SetToolbar(intMyType);
    Reset();
}
function subUpdate() {
    intMyType = "U";
    SetControl(intMyType);
    SetToolbar(intMyType);
}
function subDelete() {
    intMyType = "D";
    var model = JSON.stringify({
        'ProdId': $("#ProdId").val(),
        'TrxType': intMyType
    });

    $.ajax({
        type: 'POST',
        url: '/Parameter/MaintainUpfrontSellingFee',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.blnResult) {
                Reset();
                SetControl(intMyType);
                SetToolbar(intMyType);
                swal("Delete data berhasil!", "Harap melakukan proses otorisasi!", "success");
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}
function subCancel() {
    intMyType = "B";
    SetControl(intMyType);
    SetToolbar(intMyType);
    Reset();
}
function subSave(intMyType) {
    if ($("#ProdCode").val() == "") {
        swal("Warning", "Produk belum dipilih!", "warning");
        return;
    }
    if ($("#PercentageDefault").val() > 100) {
        swal("Warning", "Persentase Default tidak boleh lebih besar dari 100% !", "warning");
        return;
    }
    if ($("#PercentageDefault").val() == 0) {
        swal("Warning", "Persentase Default tidak boleh kosong !", "warning");
        return;
    }
    if ($("#_percentGL1").val() > 100) {
        swal("Warning", "Persentase dari Nomor GL 1 tidak boleh lebih besar dari 100% !", "warning");
        return;
    }
    if ($("#_percentGL2").val() > 100) {
        swal("Warning", "Persentase dari Nomor GL 2 tidak boleh lebih besar dari 100% !", "warning");
        return;
    }
    if ($("#_percentGL3").val() > 100) {
        swal("Warning", "Persentase dari Nomor GL 3 tidak boleh lebih besar dari 100% !", "warning");
        return;
    }
    if ($("#_percentGL4").val() > 100) {
        swal("Warning", "Persentase dari Nomor GL 4 tidak boleh lebih besar dari 100% !", "warning");
        return;
    }
    if ($("#_percentGL5").val() > 100) {
        swal("Warning", "Persentase dari Nomor GL 5 tidak boleh lebih besar dari 100% !", "warning");
        return;
    }
    if ($("#_namaGL1").val() == "" || $("#_noGL1").val() == "" || $("#_percentGL1").val() == 0) {
        swal("Warning", "Nomor GL 1 dan Nomor GL 2 adalah mandatory! Harus terisi! ", "warning");
        return;
    }
    if ($("#_namaGL2").val() == "" || $("#_noGL2").val() == "" || $("#_percentGL2").val() == 0 || $("#_officeIdNoGL2").val() == "") {
        swal("Warning", "Nomor GL 1 dan Nomor GL 2 adalah mandatory! Harus terisi! ", "warning");
        return;
    }
    if ($("#_namaGL1").val() == "" || $("#_noGL1").val() == "" || $("#_percentGL1").val() == 0) {
        swal("Warning", "Nomor GL 1 dan Nomor GL 2 adalah mandatory! Harus terisi! ", "warning");
        return;
    }
    if ($("#_percentGL3").val() > 0) {
        if ($("#_namaGL3").val() == "" || $("#_noGL3").val() == "") {
            swal("Warning", "Harap mengisi nama dan nomor GL 3, jika persentase untuk nomor GL 3 terisi! ", "warning");
            return;
        }

        if ($("#_noGL3").val().length != 8) {
            swal("Warning", "Nomor GL 3 salah!", "warning");
            return;
        }
        if ($("#_officeIdNoGL3").val() == "") {
            swal("Warning", "Office Id untuk GL 3 belum diisi!", "warning");
            return;
        }
    }
    if ($("#_percentGL4").val() > 0) {
        if ($("#_namaGL4").val() == "" || $("#_noGL4").val() == "") {
            swal("Warning", "Harap mengisi nama dan nomor GL 4, jika persentase untuk nomor GL 4 terisi! ", "warning");
            return;
        }

        if ($("#_noGL4").val().length != 8) {
            swal("Warning", "Nomor GL 4 salah!", "warning");
            return;
        }
        if ($("#_officeIdNoGL4").val() == "") {
            swal("Warning", "Office Id untuk GL 4 belum diisi!", "warning");
            return;
        }
    }
    if ($("#_percentGL5").val() > 0) {
        if ($("#_namaGL5").val() == "" || $("#_noGL5").val() == "") {
            swal("Warning", "Harap mengisi nama dan nomor GL 5, jika persentase untuk nomor GL 5 terisi! ", "warning");
            return;
        }

        if ($("#_noGL5").val().length != 8) {
            swal("Warning", "Nomor GL 5 salah!", "warning");
            return;
        }
        if ($("#_officeIdNoGL5").val() == "") {
            swal("Warning", "Office Id untuk GL 5 belum diisi!", "warning");
            return;
        }
    }
    if ($("#_namaGL3").val() != "") {
        if ($("#_percentGL3").val() == 0) {
            swal("Warning", "Harap mengisi persentase nomor GL 3! ", "warning");
            return;
        }

        if ($("#_noGL3").val().length != 8) {
            swal("Warning", "Nomor GL 3 salah!", "warning");
            return;
        }
        if ($("#_officeIdNoGL3").val() == "") {
            swal("Warning", "Office Id untuk GL 3 belum diisi!", "warning");
            return;
        }
    }
    if ($("#_namaGL4").val() != "") {
        if ($("#_percentGL4").val() == 0) {
            swal("Warning", "Harap mengisi persentase nomor GL 4! ", "warning");
            return;
        }

        if ($("#_noGL4").val().length != 8) {
            swal("Warning", "Nomor GL 4 salah!", "warning");
            return;
        }
        if ($("#_officeIdNoGL4").val() == "") {
            swal("Warning", "Office Id untuk GL 4 belum diisi!", "warning");
            return;
        }
    }
    if ($("#_namaGL5").val() != "") {
        if ($("#_percentGL5").val() == 0) {
            swal("Warning", "Harap mengisi persentase nomor GL 5! ", "warning");
            return;
        }

        if ($("#_noGL5").val().length != 8) {
            swal("Warning", "Nomor GL 5 salah!", "warning");
            return;
        }
        if ($("#_officeIdNoGL5").val() == "") {
            swal("Warning", "Office Id untuk GL 5 belum diisi!", "warning");
            return;
        }
    }
    var totalPercent;
    var _percentGL2 = $("#_percentGL2").val();
    totalPercent = 100 + +_percentGL2;
    if ($("#_TotalPercentGL").val() != totalPercent) {
        swal("Warning", "Total dari persen GL harus " + totalPercent + "persen!", "warning");
        return;
    }
    if (+$("#_percentGL1").val() + +$("#_percentGL3").val() + +$("#_percentGL4").val() + +$("#_percentGL5").val() != 100) {
        swal("Warning", "Total dari persen GL 1,3,4 dan 5 harus 100 persen!", "warning");
        return;
    }
    if (+$("#_percentGL1").val() + +$("#_percentGL2").val() + +$("#_percentGL3").val() + +$("#_percentGL4").val() + +$("#_percentGL5").val() != totalPercent) {
        swal("Warning", "Total dari persen GL harus " + totalPercent + " persen!", "warning");
        return;
    }
    if ($("#_noGL1").val().length != 8) {
        swal("Warning", "Nomor GL 1 salah!", "warning");
        return;
    }
    if ($("#_noGL2").val().length != 8) {
        swal("Warning", "Nomor GL 2 salah!", "warning");
        return;
    }

    var arrSettingGL = [];
    var obj = {};
    obj['Seq'] = '1';
    obj['NamaGL'] = $("#_namaGL1").val();
    obj['NomorGL'] = $("#_noGL1").val();
    obj['OfficeId'] = $("#_officeIdNoGL2").val();
    obj['Persentase'] = $("#_percentGL1").val();
    arrSettingGL.push(obj);

    var obj = {};
    obj['Seq'] = '2';
    obj['NamaGL'] = $("#_namaGL2").val();
    obj['NomorGL'] = $("#_noGL2").val();
    obj['OfficeId'] = $("#_officeIdNoGL2").val();
    obj['Persentase'] = $("#_percentGL2").val();
    arrSettingGL.push(obj);

    var obj = {};
    obj['Seq'] = '3';
    obj['NamaGL'] = $("#_namaGL3").val();
    obj['NomorGL'] = $("#_noGL3").val();
    obj['OfficeId'] = $("#_officeIdNoGL3").val();
    obj['Persentase'] = $("#_percentGL3").val();
    arrSettingGL.push(obj);

    var obj = {};
    obj['Seq'] = '4';
    obj['NamaGL'] = $("#_namaGL4").val();
    obj['NomorGL'] = $("#_noGL4").val();
    obj['OfficeId'] = $("#_officeIdNoGL4").val();
    obj['Persentase'] = $("#_percentGL4").val();
    arrSettingGL.push(obj);

    var obj = {};
    obj['Seq'] = '5';
    obj['NamaGL'] = $("#_namaGL5").val();
    obj['NomorGL'] = $("#_noGL5").val();
    obj['OfficeId'] = $("#_officeIdNoGL5").val();
    obj['Persentase'] = $("#_percentGL5").val();
    arrSettingGL.push(obj);

    var model = JSON.stringify({
        'intProdId': $("#ProdId").val(),
        'strProcessType': intMyType,
        'strJenisFee': $("#_jenisFeeCmb").data('kendoDropDownList').value(),
        'decPercentageDefault': $("#PercentageDefault").data("kendoNumericTextBox").value(),
        'listSettingGL': arrSettingGL
    });

    $.ajax({
        type: 'POST',
        url: '/Parameter/MaintainUpfrontSellingFee',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.blnResult) {
                intMyType = "S";
                SetControl(intMyType);
                SetToolbar(intMyType);
                Reset();
                swal("Simpan data berhasil!", "Harap melakukan proses otorisasi!", "success");
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}
function Reset() {
    $("#ProdCode").val('');
    $("#ProdName").val('');

    $("#PercentageDefault").data("kendoNumericTextBox").value(0);

    $("#_namaGL3").val('');
    $("#_namaGL4").val('');
    $("#_namaGL5").val('');

    $("#_noGL1").val('');
    $("#_noGL2").val('');
    $("#_noGL3").val('');
    $("#_noGL4").val('');
    $("#_noGL5").val('');

    $("#_officeIdNoGL2").val('');
    $("#_officeIdNoGL3").val('');
    $("#_officeIdNoGL4").val('');
    $("#_officeIdNoGL5").val('');

    $("#_descGL1").val('');
    $("#_descGL2").val('');
    $("#_descGL3").val('');
    $("#_descGL4").val('');
    $("#_descGL5").val('');

    $("#_percentGL1").data("kendoNumericTextBox").value(0);
    $("#_percentGL2").data("kendoNumericTextBox").value(0);
    $("#_percentGL3").data("kendoNumericTextBox").value(0);
    $("#_percentGL4").data("kendoNumericTextBox").value(0);
    $("#_percentGL5").data("kendoNumericTextBox").value(0);
    $("#_TotalPercentGL").data("kendoNumericTextBox").value(0);
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
        $("#btnNew").show()
        $("#btnEdit").show()
        $("#btnDelete").show()
        $("#btnSave").hide();
        $("#btnCancel").hide();
    }
}
function SetControl(intMyType) {
    if (intMyType == "R" || intMyType == "B" || intMyType == "D" || intMyType == "S") {
        $("#ProdCode").prop('disabled', false);
        $("#cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

        $("#_jenisFeeCmb").data('kendoDropDownList').enable(true);
        $("#PercentageDefault").data("kendoNumericTextBox").enable(false);

        $("#_namaGL1").prop('disabled', true);
        $("#_namaGL2").prop('disabled', true);
        $("#_namaGL3").prop('disabled', true);
        $("#_namaGL4").prop('disabled', true);
        $("#_namaGL5").prop('disabled', true);

        $("#_noGL1").prop('disabled', true);
        $("#_noGL2").prop('disabled', true);
        $("#_noGL3").prop('disabled', true);
        $("#_noGL4").prop('disabled', true);
        $("#_noGL5").prop('disabled', true);

        $("#_officeIdNoGL2").prop('disabled', true);
        $("#_officeIdNoGL3").prop('disabled', true);
        $("#_officeIdNoGL4").prop('disabled', true);
        $("#_officeIdNoGL5").prop('disabled', true);

        $("#_percentGL1").data("kendoNumericTextBox").enable(false);
        $("#_percentGL2").data("kendoNumericTextBox").enable(false);
        $("#_percentGL3").data("kendoNumericTextBox").enable(false);
        $("#_percentGL4").data("kendoNumericTextBox").enable(false);
        $("#_percentGL5").data("kendoNumericTextBox").enable(false);
    }
    if (intMyType == "A") {
        $("#ProdCode").prop('disabled', false);
        $("#cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

        $("#_jenisFeeCmb").data('kendoDropDownList').enable(true);
        $("#PercentageDefault").data("kendoNumericTextBox").enable(true);

        $("#_namaGL1").prop('disabled', true);
        $("#_namaGL2").prop('disabled', true);
        $("#_namaGL3").prop('disabled', false);
        $("#_namaGL4").prop('disabled', false);
        $("#_namaGL5").prop('disabled', false);

        $("#_noGL1").prop('disabled', false);
        $("#_noGL2").prop('disabled', false);
        $("#_noGL3").prop('disabled', false);
        $("#_noGL4").prop('disabled', false);
        $("#_noGL5").prop('disabled', false);

        $("#_officeIdNoGL2").prop('disabled', false);
        $("#_officeIdNoGL3").prop('disabled', false);
        $("#_officeIdNoGL4").prop('disabled', false);
        $("#_officeIdNoGL5").prop('disabled', false);

        $("#_percentGL1").data("kendoNumericTextBox").enable(true);
        $("#_percentGL2").data("kendoNumericTextBox").enable(false);
        $("#_percentGL3").data("kendoNumericTextBox").enable(true);
        $("#_percentGL4").data("kendoNumericTextBox").enable(true);
        $("#_percentGL5").data("kendoNumericTextBox").enable(true);
    }
    if (intMyType == "U") {
        $("#ProdCode").prop('disabled', true);
        $("#cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

        $("#_jenisFeeCmb").data('kendoDropDownList').enable(true);
        $("#PercentageDefault").data("kendoNumericTextBox").enable(true);

        $("#_namaGL1").prop('disabled', true);
        $("#_namaGL2").prop('disabled', true);
        $("#_namaGL3").prop('disabled', false);
        $("#_namaGL4").prop('disabled', false);
        $("#_namaGL5").prop('disabled', false);

        $("#_noGL1").prop('disabled', false);
        $("#_noGL2").prop('disabled', false);
        $("#_noGL3").prop('disabled', false);
        $("#_noGL4").prop('disabled', false);
        $("#_noGL5").prop('disabled', false);

        $("#_officeIdNoGL2").prop('disabled', false);
        $("#_officeIdNoGL3").prop('disabled', false);
        $("#_officeIdNoGL4").prop('disabled', false);
        $("#_officeIdNoGL5").prop('disabled', false);

        $("#_percentGL1").data("kendoNumericTextBox").enable(true);
        $("#_percentGL2").data("kendoNumericTextBox").enable(false);
        $("#_percentGL3").data("kendoNumericTextBox").enable(true);
        $("#_percentGL4").data("kendoNumericTextBox").enable(true);
        $("#_percentGL5").data("kendoNumericTextBox").enable(true);
    }
}
function ValidateGL(NomorGL) {
    return $.ajax({
        type: 'GET',
        url: '/Parameter/ValidateGL',
        data: { NomorGL: NomorGL },
        async: false
    });
}