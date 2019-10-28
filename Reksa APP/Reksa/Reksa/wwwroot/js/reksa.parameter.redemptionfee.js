
var intMyType;
$(document).ready(function () {
    var grid = {
        height: 200
    };
    $("#dataGridView1").kendoGrid(grid);
    $("#dataGridView2").kendoGrid(grid);
    intMyType = "B";
    SetToolbar(intMyType);
    SetControl(intMyType);
});
function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/Parameter/RefreshRedemptionFee',
        data: { ProdukId: $("#ProdId").val() },
        beforeSend: function () {
            $("#load_screen").show();
        }, 
        success: function (data) {
            if (data.blnResult) {
                $("#_txtMinPctKary").data("kendoNumericTextBox").value(data.redempFee.MinPctFeeEmployee);
                $("#_txtMinPctNonKary").data("kendoNumericTextBox").value(data.redempFee.MinPctFeeNonEmployee);
                $("#_txtMaxPctKary").data("kendoNumericTextBox").value(data.redempFee.MaxPctFeeEmployee);
                $("#_txtMaxPctNonKary").data("kendoNumericTextBox").value(data.redempFee.MaxPctFeeNonEmployee);

                if (data.redempFee.RedempIncFee == "1") {
                    $("#_YesRadio").prop("checked", true);
                    $("#_noRadio").prop("checked", false);
                }
                else {
                    $("#_YesRadio").prop("checked", false);
                    $("#_noRadio").prop("checked", true);
                }

                $("#_namaGL1").val(data.listRedempFeeGL[0].GLName);
                $("#_namaGL2").val(data.listRedempFeeGL[1].GLName);
                $("#_namaGL3").val(data.listRedempFeeGL[2].GLName);
                $("#_namaGL4").val(data.listRedempFeeGL[3].GLName);
                $("#_namaGL5").val(data.listRedempFeeGL[4].GLName);

                $("#_noGL1").val(data.listRedempFeeGL[0].GLNumber);
                $("#_noGL2").val(data.listRedempFeeGL[1].GLNumber);
                $("#_noGL3").val(data.listRedempFeeGL[2].GLNumber);
                $("#_noGL4").val(data.listRedempFeeGL[3].GLNumber);
                $("#_noGL5").val(data.listRedempFeeGL[4].GLNumber);

                $("#_officeIdNoGL2").val(data.listRedempFeeGL[1].OfficeId);
                $("#_officeIdNoGL3").val(data.listRedempFeeGL[2].OfficeId);
                $("#_officeIdNoGL4").val(data.listRedempFeeGL[3].OfficeId);
                $("#_officeIdNoGL5").val(data.listRedempFeeGL[4].OfficeId);

                $("#_percentGL1").data("kendoNumericTextBox").value(data.listRedempFeeGL[0].Percentage);
                $("#_percentGL2").data("kendoNumericTextBox").value(data.listRedempFeeGL[1].Percentage);
                $("#_percentGL3").data("kendoNumericTextBox").value(data.listRedempFeeGL[2].Percentage);
                $("#_percentGL4").data("kendoNumericTextBox").value(data.listRedempFeeGL[3].Percentage);
                $("#_percentGL5").data("kendoNumericTextBox").value(data.listRedempFeeGL[4].Percentage);

                var _percentGL1 = $("#_percentGL1").val();
                var _percentGL2 = $("#_percentGL2").val();
                var _percentGL3 = $("#_percentGL3").val();
                var _percentGL4 = $("#_percentGL4").val();
                var _percentGL5 = $("#_percentGL5").val();
                var _TotalPercentGL = +_percentGL1 + +_percentGL2 + +_percentGL3 + +_percentGL4 + +_percentGL5;

                $("#_TotalPercentGL").data("kendoNumericTextBox").value(_TotalPercentGL);

                if (data.listRedempFeePercentageTiering.length != 0) {
                    var Grid2 = $("#dataGridView2").data("kendoGrid");
                    var gridData = populateGrid2(data.listRedempFeePercentageTiering);
                    Grid2.setOptions(gridData);
                    Grid2.dataSource.pageSize(10);
                    Grid2.dataSource.page(1);
                    Grid2.select("tr:eq(0)");
                    Grid2.hideColumn('ProductId');
                    Grid2.hideColumn('Nominal');
                    $("#dataGridView2 th[data-field=PercentageFee]").html("Max Redemption Fee")
                } else {
                    $("#dataGridView2").data('kendoGrid').dataSource.data([]);
                }

                if (data.listRedempFeeTieringNotif.length != 0) {

                    var Grid1 = $("#dataGridView1").data("kendoGrid");
                    var gridData = populateGrid(data.listRedempFeeTieringNotif);
                    Grid1.setOptions(gridData);
                    Grid1.dataSource.pageSize(10);
                    Grid1.dataSource.page(1);
                    Grid1.select("tr:eq(0)");
                    Grid1.hideColumn('TrxType');
                    Grid1.hideColumn('ProdId');
                } else {
                    $("#dataGridView1").data('kendoGrid').dataSource.data([]);
                }
                intMyType = "R";
                SetToolbar(intMyType);
                SetControl(intMyType);
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
                Reset();
            }
        }
        ,
        complete: function () {
            $("#load_screen").hide();
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
        url: '/Parameter/MaintainRedempFee',
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
    if ($("#_txtMinPctKary").val() > 100) {
        swal("Warning", "Persentase Min Fee Karyawan tidak boleh lebih besar dari 100%!", "warning");
        return;
    }
    if ($("#_txtMinPctNonKary").val() > 100) {
        swal("Warning", "Persentase Min Fee Non Karyawan tidak boleh lebih besar dari 100%!", "warning");
        return;
    }
    //if ($("#_txtMaxPctKary").val() > 100) {
    //    swal("Warning", "Persentase Max Fee Karyawan tidak boleh lebih besar dari 100%!", "warning");
    //    return;
    //}
    //if ($("#_txtMaxPctNonKary").val() > 100) {
    //    swal("Warning", "Persentase Max Fee Non Karyawan tidak boleh lebih besar dari 100%!", "warning");
    //    return;
    //}
    //if ($("#_txtMaxPctKary").val() < $("#_txtMinPctKary").val()) {
    //    swal("Warning", "Persentase Max Karyawan tidak boleh lebih kecil dari Persentase Min Karyawan!", "warning");
    //    return;
    //}
    //if ($("#_txtMaxPctNonKary").val() < $("#_txtMinPctNonKary").val()) {
    //    swal("Warning", "Persentase Max Non Karyawan tidak boleh lebih kecil dari Persentase Min Non Karyawan!", "warning");
    //    return;
    //}
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
    if (($("#_YesRadio").prop("checked") == false) && ($("#_noRadio").prop("checked") == false)) {
        swal("Warning", "Parameter pencairan fee belum dipilih!", "warning");
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

    var IsRedempIncFee;
    var IsFlat;
    var PeriodNonFlat;
    if ($("#_noRadio").prop("checked") == true) {
        IsRedempIncFee = false;
    }
    else if ($("#_YesRadio").prop("checked") == true) {
        IsRedempIncFee = true;
    }

    if ($("#_flatCheck").prop("checked") == true) {
        IsFlat = true;
        PeriodNonFlat = 0;
    }
    else if ($("#_nonFlatCheck").prop("checked") == true) {
        IsFlat = false;
        PeriodNonFlat = $("#_bulanNonFlat").val();
    }

    var grid1 = $("#dataGridView1").data("kendoGrid");
    var arrTieringNotif;
    arrTieringNotif = grid1.dataSource.view();

    var grid2 = $("#dataGridView2").data("kendoGrid");
    var arrRedemPeriod;
    arrRedemPeriod = grid2.dataSource.view();

    var model = JSON.stringify({
        'intProdId': $("#ProdId").val(),
        'strProcessType': intMyType,
        'RedempIncFeeout': IsRedempIncFee,
        'IsFlat': IsFlat,
        'intNonFlatPeriod': PeriodNonFlat,
        'decMinPctFeeNonEmployee': $("#_txtMinPctNonKary").val(),
        'decMaxPctFeeNonEmployee': $("#_txtMaxPctNonKary").val(),
        'decMinPctFeeEmployee': $("#_txtMinPctKary").val(),
        'decMaxPctFeeEmployee': $("#_txtMaxPctKary").val(),
        'listSettingGL': arrSettingGL,
        'listTieringNotif': arrTieringNotif,
        'listTieringPct': arrRedemPeriod
    });

    console.log(model);

    $.ajax({
        type: 'POST',
        url: '/Parameter/MaintainRedempFee',
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

    $("#_txtMinPctKary").data("kendoNumericTextBox").value(0);
    $("#_txtMinPctNonKary").data("kendoNumericTextBox").value(0);
    $("#_txtMaxPctKary").data("kendoNumericTextBox").value(0);
    $("#_txtMaxPctNonKary").data("kendoNumericTextBox").value(0);

    $("#_bulanNonFlat").val('');

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

    $("#_flatCheck").prop("checked", false);
    $("#_nonFlatCheck").prop("checked", false);
    $("#_YesRadio").prop("checked", false);
    $("#_noRadio").prop("checked", false);

    subResetTiering();
    subResetPctTiering();
}
function subResetTiering() {
    $("#_fromPercent").data("kendoNumericTextBox").value(0);
    $("#_toPercent").data("kendoNumericTextBox").value(0);
    $("#_Persetujuan").val('');
}
function subResetPctTiering() {
    $("#_pctRedemptTier").data("kendoNumericTextBox").value(0);
    $("#_periodTxt").data("kendoNumericTextBox").value(0);
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

        $("#_txtMinPctKary").data("kendoNumericTextBox").enable(false);
        $("#_txtMinPctNonKary").data("kendoNumericTextBox").enable(false);
        $("#_txtMaxPctKary").data("kendoNumericTextBox").enable(false);
        $("#_txtMaxPctNonKary").data("kendoNumericTextBox").enable(false);

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

        $("#_flatCheck").prop('disabled', true);
        $("#_nonFlatCheck").prop('disabled', true);
        $("#_YesRadio").prop('disabled', true);
        $("#_noRadio").prop('disabled', true);

        subControlTiering(false);
        subControlPctTiering(false);

        document.getElementById("btnAdd").disabled = true;
        document.getElementById("btnHapus").disabled = true;

        document.getElementById("btnAddPctTier").disabled = true;
        document.getElementById("btnHapusPctTier").disabled = true;

        if ($("#_nonFlatCheck").prop('checked') == true) {
            $("#_bulanNonFlat").prop('disabled', true);
        }
    }
    if (intMyType == "A") {
        $("#ProdCode").prop('disabled', false);
        $("#cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

        $("#_txtMinPctKary").data("kendoNumericTextBox").enable(true);
        $("#_txtMinPctNonKary").data("kendoNumericTextBox").enable(true);
        $("#_txtMaxPctKary").data("kendoNumericTextBox").enable(true);
        $("#_txtMaxPctNonKary").data("kendoNumericTextBox").enable(true);

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

        $("#_flatCheck").prop('disabled', false);
        $("#_nonFlatCheck").prop('disabled', false);
        $("#_YesRadio").prop('disabled', false);
        $("#_noRadio").prop('disabled', false);

        subControlTiering(false);
        subControlPctTiering(false);

        document.getElementById("btnAdd").disabled = false;
        document.getElementById("btnHapus").disabled = false;

        document.getElementById("btnAddPctTier").disabled = false;
        document.getElementById("btnHapusPctTier").disabled = false;

        if ($("#_nonFlatCheck").prop('checked') == true) {
            $("#_bulanNonFlat").prop('disabled', false);
        }
    }
    if (intMyType == "U") {
        $("#ProdCode").prop('disabled', true);
        $("#cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

        $("#_txtMinPctKary").data("kendoNumericTextBox").enable(true);
        $("#_txtMinPctNonKary").data("kendoNumericTextBox").enable(true);
        $("#_txtMaxPctKary").data("kendoNumericTextBox").enable(true);
        $("#_txtMaxPctNonKary").data("kendoNumericTextBox").enable(true);

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

        $("#_flatCheck").prop('disabled', false);
        $("#_nonFlatCheck").prop('disabled', false);
        $("#_YesRadio").prop('disabled', false);
        $("#_noRadio").prop('disabled', false);

        subControlTiering(false);
        subControlPctTiering(false);

        document.getElementById("btnAdd").disabled = false;
        document.getElementById("btnHapus").disabled = false;

        document.getElementById("btnAddPctTier").disabled = false;
        document.getElementById("btnHapusPctTier").disabled = false;

        if ($("#_nonFlatCheck").prop('checked') == true) {
            $("#_bulanNonFlat").prop('disabled', false);
        }
    }
}
function subControlTiering(IsTrue) {
    var IsTrueReverse;
    if (IsTrue == true)
        IsTrueReverse = false;
    else
        IsTrueReverse = true;
    $("#_fromPercent").data("kendoNumericTextBox").enable(IsTrue);
    $("#_toPercent").data("kendoNumericTextBox").enable(IsTrue);
    //$("#_fromPercent").prop('disabled', IsTrueReverse);
    //$("#_toPercent").prop('disabled', IsTrueReverse);
    $("#_Persetujuan").prop('disabled', IsTrueReverse);

    document.getElementById("btnAdd").disabled = IsTrue;
    document.getElementById("btnHapus").disabled = IsTrue;

    document.getElementById("btnSimpan").disabled = IsTrueReverse;
    document.getElementById("btnBatal").disabled = IsTrueReverse;

    //$('#dataGridView1').data('kendoGrid').enable(IsTrueReverse);
}
function subControlPctTiering(IsTrue) {
    $("#_periodTxt").data("kendoNumericTextBox").enable(IsTrue);
    $("#_pctRedemptTier").data("kendoNumericTextBox").enable(IsTrue);
    $("#_statusKaryawanCmb").data('kendoDropDownList').enable(IsTrue);

    document.getElementById("btnAddPctTier").disabled = IsTrue;
    document.getElementById("btnHapusPctTier").disabled = IsTrue;
    document.getElementById("btnSavePctTier").disabled = !IsTrue;
    document.getElementById("btnCancelPctTier").disabled = !IsTrue;

    //dataGridView2.Enabled = !IsTrue;
}

function populateGrid(response) {
    if (response.length > 0) {
        var columns = generateColumns(response);
        return gridOptions = {
            dataSource: {
                transport: {
                    read: function (options) {
                        options.success(response);
                    }
                },
                pageSize: 6,
                page: 1
            },
            change: onRowGrid1Select,
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };
    } else {
        $("#dataGridView1").empty();
    }
}
function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        return {
            field: name,
            width: 400,
            title: name,
        };
    })
}
function populateGrid2(response) {
    if (response.length > 0) {
        var columns = generateColumns2(response);
        return gridOptions = {
            dataSource: {
                transport: {
                    read: function (options) {
                        options.success(response);
                    }
                },
                pageSize: 6,
                page: 1
            },
            change: onRowGrid2Select,
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };
    } else {
        $("#dataGridView2").empty();
    }
}
function generateColumns2(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        return {
            field: name,
            width: 400,
            title: name,
        };
    })
}

function ValidateGL(NomorGL) {
    return $.ajax({
        type: 'GET',
        url: '/Parameter/ValidateGL',
        data: { NomorGL: NomorGL },
        async: false
    });
}