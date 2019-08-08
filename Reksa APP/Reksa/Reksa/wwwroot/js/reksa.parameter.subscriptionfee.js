var intMyType;
$(document).ready(function load() {
    intMyType = "B";
    SetToolbar(intMyType);
    SetControl(intMyType);

    var grid = {
        height: 200
    };
    $("#dataGridView1").kendoGrid(grid);
    url = "/Global/SearchProduct";
    $('#cmpsrProduct').attr('href', url);
});

function ValidateGL(NomorGL) {
    return $.ajax({
        type: 'GET',
        url: '/Parameter/ValidateGL',
        data: { NomorGL: NomorGL },
        async: false
    });
}

function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/Parameter/RefreshSubscriptionFee',
        data: { ProdukId: $("#ProdId").val() },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                //$("#_txtMinPctKary").val(data.listFee.minPctFeeEmployee);
                //$("#_txtMinPctNonKary").val(data.listFee.minPctFeeNonEmployee);
                //$("#_txtMaxPctKary").val(data.listFee.maxPctFeeEmployee);
                //$("#_txtMaxPctNonKary").val(data.listFee.maxPctFeeNonEmployee);
                $("#_txtMinPctKary").data("kendoNumericTextBox").value(data.listFee.minPctFeeEmployee);
                $("#_txtMinPctNonKary").data("kendoNumericTextBox").value(data.listFee.minPctFeeNonEmployee);
                $("#_txtMaxPctKary").data("kendoNumericTextBox").value(data.listFee.maxPctFeeEmployee);
                $("#_txtMaxPctNonKary").data("kendoNumericTextBox").value(data.listFee.maxPctFeeNonEmployee);

                $("#_namaGL1").val(data.listReksaListGLFeeSubs[0].GLName);
                $("#_namaGL2").val(data.listReksaListGLFeeSubs[1].GLName);
                $("#_namaGL3").val(data.listReksaListGLFeeSubs[2].GLName);
                $("#_namaGL4").val(data.listReksaListGLFeeSubs[3].GLName);
                $("#_namaGL5").val(data.listReksaListGLFeeSubs[4].GLName);

                $("#_noGL1").val(data.listReksaListGLFeeSubs[0].GLNumber);
                $("#_noGL2").val(data.listReksaListGLFeeSubs[1].GLNumber);
                $("#_noGL3").val(data.listReksaListGLFeeSubs[2].GLNumber);
                $("#_noGL4").val(data.listReksaListGLFeeSubs[3].GLNumber);
                $("#_noGL5").val(data.listReksaListGLFeeSubs[4].GLNumber);

                $("#_officeIdNoGL2").val(data.listReksaListGLFeeSubs[1].OfficeId);
                $("#_officeIdNoGL3").val(data.listReksaListGLFeeSubs[2].OfficeId);
                $("#_officeIdNoGL4").val(data.listReksaListGLFeeSubs[3].OfficeId);
                $("#_officeIdNoGL5").val(data.listReksaListGLFeeSubs[4].OfficeId);

                //$("#_percentGL1").val(data.listReksaListGLFeeSubs[0].Percentage);
                //$("#_percentGL2").val(data.listReksaListGLFeeSubs[1].Percentage);
                //$("#_percentGL3").val(data.listReksaListGLFeeSubs[2].Percentage);
                //$("#_percentGL4").val(data.listReksaListGLFeeSubs[3].Percentage);
                //$("#_percentGL5").val(data.listReksaListGLFeeSubs[4].Percentage);

                $("#_percentGL1").data("kendoNumericTextBox").value(data.listReksaListGLFeeSubs[0].Percentage);
                $("#_percentGL2").data("kendoNumericTextBox").value(data.listReksaListGLFeeSubs[1].Percentage);
                $("#_percentGL3").data("kendoNumericTextBox").value(data.listReksaListGLFeeSubs[2].Percentage);
                $("#_percentGL4").data("kendoNumericTextBox").value(data.listReksaListGLFeeSubs[3].Percentage);
                $("#_percentGL5").data("kendoNumericTextBox").value(data.listReksaListGLFeeSubs[4].Percentage);

                var _percentGL1 = $("#_percentGL1").val();
                var _percentGL2 = $("#_percentGL2").val();
                var _percentGL3 = $("#_percentGL3").val();
                var _percentGL4 = $("#_percentGL4").val();
                var _percentGL5 = $("#_percentGL5").val();
                var _TotalPercentGL = +_percentGL1 + +_percentGL2 + +_percentGL3 + +_percentGL4 + +_percentGL5;

                //$("#_TotalPercentGL").val(_TotalPercentGL);
                $("#_TotalPercentGL").data("kendoNumericTextBox").value(_TotalPercentGL);

                if (data.listReksaTieringNotificationSubs.length != 0) {
                    var dataSource = new kendo.data.DataSource(
                        {
                            data: data.listReksaTieringNotificationSubs
                        });
                    var SubsFeegrid = $('#dataGridView1').data('kendoGrid');
                    SubsFeegrid.setDataSource(dataSource);
                    SubsFeegrid.dataSource.pageSize(10);
                    SubsFeegrid.dataSource.page(1);
                    SubsFeegrid.select("tr:eq(0)");
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

function subCancel() {
    intMyType = "B";
    SetControl(intMyType);
    SetToolbar(intMyType);
    Reset();
}

function subDelete() {
    intMyType = "D";
    var model = JSON.stringify({
        'ProdId': $("#ProdId").val(),
        'TrxType': intMyType
    });

    $.ajax({
        type: 'POST',
        url: '/Parameter/MaintainSubsFee',
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
    if ($("#_txtMaxPctKary").val() > 100) {
        swal("Warning", "Persentase Max Fee Karyawan tidak boleh lebih besar dari 100%!", "warning");
        return;
    }
    if ($("#_txtMaxPctNonKary").val() > 100) {
        swal("Warning", "Persentase Max Fee Non Karyawan tidak boleh lebih besar dari 100%!", "warning");
        return;
    }
    if ($("#_txtMaxPctKary").val() < $("#_txtMinPctKary").val()) {
        swal("Warning", "Persentase Max Karyawan tidak boleh lebih kecil dari Persentase Min Karyawan!", "warning");
        return;
    }
    if ($("#_txtMaxPctNonKary").val() < $("#_txtMinPctNonKary").val()) {
        swal("Warning", "Persentase Max Non Karyawan tidak boleh lebih kecil dari Persentase Min Non Karyawan!", "warning");
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
        'ProdId': $("#ProdId").val(),
        'TrxType': intMyType,
        'minPctFeeNonEmployee': $("#_txtMinPctNonKary").val(),
        'maxPctFeeNonEmployee': $("#_txtMaxPctNonKary").val(),
        'minPctFeeEmployee': $("#_txtMinPctKary").val(),
        'maxPctFeeEmployee': $("#_txtMaxPctKary").val(),
        'dtSettingGL': arrSettingGL
    });

    $.ajax({
        type: 'POST',
        url: '/Parameter/MaintainSubsFee',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        beforeSend: function () {
            $("#load_screen").show();
        },
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
        },
        complete: function () {
            $("#load_screen").hide();
        }
    });
}

function Reset() {
    $("#ProdCode").val('');
    $("#ProdName").val('');


    //$("#_txtMinPctKary").val(0);
    //$("#_txtMinPctNonKary").val(0);
    //$("#_txtMaxPctKary").val(0);
    //$("#_txtMaxPctNonKary").val(0);

    $("#_txtMinPctKary").data("kendoNumericTextBox").value(0);
    $("#_txtMinPctNonKary").data("kendoNumericTextBox").value(0);
    $("#_txtMaxPctKary").data("kendoNumericTextBox").value(0);
    $("#_txtMaxPctNonKary").data("kendoNumericTextBox").value(0);

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

    $("#_TotalPercentGL").val(0);
    subResetTiering();
}

function SetControl(intMyType) {
    if (intMyType == "R" || intMyType == "B" || intMyType == "D" || intMyType == "S") {
        $("#ProdCode").prop('disabled', false);
        $("#cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        //$("#_txtMinPctKary").prop('disabled', true);
        //$("#_txtMinPctNonKary").prop('disabled', true);
        //$("#_txtMaxPctKary").prop('disabled', true);
        //$("#_txtMaxPctNonKary").prop('disabled', true);
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

        //$("#_percentGL1").prop('disabled', true);
        //$("#_percentGL2").prop('disabled', true);
        //$("#_percentGL3").prop('disabled', true);
        //$("#_percentGL4").prop('disabled', true);
        //$("#_percentGL5").prop('disabled', true);

        $("#_percentGL1").data("kendoNumericTextBox").enable(false);
        $("#_percentGL2").data("kendoNumericTextBox").enable(false);
        $("#_percentGL3").data("kendoNumericTextBox").enable(false);
        $("#_percentGL4").data("kendoNumericTextBox").enable(false);
        $("#_percentGL5").data("kendoNumericTextBox").enable(false);

        subControlTiering(false);

        document.getElementById("btnAdd").disabled = true;
        document.getElementById("btnHapus").disabled = true;
    }
    if (intMyType == "A") {
        $("#ProdCode").prop('disabled', false);
        $("#cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

        //$("#_txtMinPctKary").prop('disabled', false);
        //$("#_txtMinPctNonKary").prop('disabled', false);
        //$("#_txtMaxPctKary").prop('disabled', false);
        //$("#_txtMaxPctNonKary").prop('disabled', false);

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

        //$("#_percentGL1").prop('disabled', false);
        //$("#_percentGL2").prop('disabled', true);
        //$("#_percentGL3").prop('disabled', false);
        //$("#_percentGL4").prop('disabled', false);
        //$("#_percentGL5").prop('disabled', false);

        $("#_percentGL1").data("kendoNumericTextBox").enable(true);
        $("#_percentGL2").data("kendoNumericTextBox").enable(false);
        $("#_percentGL3").data("kendoNumericTextBox").enable(true);
        $("#_percentGL4").data("kendoNumericTextBox").enable(true);
        $("#_percentGL5").data("kendoNumericTextBox").enable(true);

        subControlTiering(false);

        document.getElementById("btnAdd").disabled = false;
        document.getElementById("btnHapus").disabled = false;
    }
    if (intMyType == "U") {
        $("#ProdCode").prop('disabled', true);
        $("#cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

        //$("#_txtMinPctKary").prop('disabled', false);
        //$("#_txtMinPctNonKary").prop('disabled', false);
        //$("#_txtMaxPctKary").prop('disabled', false);
        //$("#_txtMaxPctNonKary").prop('disabled', false);

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

        //$("#_percentGL1").prop('disabled', false);
        //$("#_percentGL2").prop('disabled', true);
        //$("#_percentGL3").prop('disabled', false);
        //$("#_percentGL4").prop('disabled', false);
        //$("#_percentGL5").prop('disabled', false);

        $("#_percentGL1").data("kendoNumericTextBox").enable(true);
        $("#_percentGL2").data("kendoNumericTextBox").enable(false);
        $("#_percentGL3").data("kendoNumericTextBox").enable(true);
        $("#_percentGL4").data("kendoNumericTextBox").enable(true);
        $("#_percentGL5").data("kendoNumericTextBox").enable(true);

        subControlTiering(false);

        document.getElementById("btnAdd").disabled = false;
        document.getElementById("btnHapus").disabled = false;
    }
}

function subControlTiering(IsTrue) {
    var IsTrueReverse;
    if (IsTrue == true)
        IsTrueReverse = false;
    else
        IsTrueReverse = true;
    //$("#_fromPercent").prop('disabled', IsTrueReverse);
    //$("#_toPercent").prop('disabled', IsTrueReverse);
    $("#_fromPercent").data("kendoNumericTextBox").enable(IsTrue);
    $("#_toPercent").data("kendoNumericTextBox").enable(IsTrue);
    $("#_Persetujuan").prop('disabled', IsTrueReverse);

    document.getElementById("btnAdd").disabled = IsTrue;
    document.getElementById("btnHapus").disabled = IsTrue;

    document.getElementById("btnSimpan").disabled = IsTrueReverse;
    document.getElementById("btnBatal").disabled = IsTrueReverse;

    //$('#dataGridView1').data('kendoGrid').enable(IsTrueReverse);
}

function subResetTiering() {
    $("#_fromPercent").val(0);
    $("#_fromPercent").val('');
    $("#_toPercent").val(0);
    $("#_toPercent").val('');
    $("#_Persetujuan").val('');
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