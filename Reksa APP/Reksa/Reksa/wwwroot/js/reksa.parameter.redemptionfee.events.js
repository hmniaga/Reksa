
//click
$("#btnRefresh").click(function () {
    if ($("#ProdCode").val() == "") {
        swal("Warning", "Produk harap dipilih dulu!", "warning");
        return;
    }
    else {
        subRefresh();
    }
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
    subSave(intMyType);
});
$("#btnCancel").click(function () {
    subCancel();
});

$("#btnAdd").click(function () {
    subControlTiering(true);
    subResetTiering();
});
$("#btnSimpan").click(function () {
    if ($("#_fromPercent").data("kendoNumericTextBox").value() == 0 ||
        $("#_toPercent").data("kendoNumericTextBox").value() == 0 ||
        $("#_Persetujuan").val() == "") {
        swal("Warning", "Data Tiering Tidak Lengkap", "warning");
        return;
    }
    if ($("#_fromPercent").data("kendoNumericTextBox").value() >
        $("#_toPercent").data("kendoNumericTextBox").value()) {
        swal("Warning", "Percent To tidak boleh lebih besar dari Percent From !", "warning");
        return;
    }
    if ($("#_toPercent").data("kendoNumericTextBox").value() > 100) {
        swal("Warning", "Percent To tidak boleh lebih besar dari 100% !", "warning");
        return;
    }
    if ($("#_fromPercent").data("kendoNumericTextBox").value() > 100) {
        swal("Warning", "Percent From tidak boleh lebih besar dari 100% !", "warning");
        return;
    }

    var blnPassed = true;
    var grid1 = $("#dataGridView1").data("kendoGrid");
    grid1.refresh();
    grid1.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid1.dataItem(this);
        if (dataItem.PercentFrom <= $("#_fromPercent").data("kendoNumericTextBox").value() && dataItem.PercentTo >= $("#_fromPercent").data("kendoNumericTextBox").value()) {
            swal("Warning", "Data fee sudah ada(1)", "warning");
            blnPassed = false;
            return;
        }
        if (dataItem.PercentFrom <= $("#_toPercent").data("kendoNumericTextBox").value() && dataItem.PercentTo >= $("#_toPercent").data("kendoNumericTextBox").value()) {
            swal("Warning", "Data fee sudah ada(2)", "warning");
            blnPassed = false;
            return;
        }
    })

    if (blnPassed) {
        var arrTieringNotif = [];
        var obj = {};
        obj['PercentFrom'] = $("#_fromPercent").data("kendoNumericTextBox").value();
        obj['PercentTo'] = $("#_toPercent").data("kendoNumericTextBox").value();
        obj['MustApproveBy'] = $("#_Persetujuan").val();

        arrTieringNotif.push(obj);
        var dataSet = grid1.dataSource.view();
        $.merge(arrTieringNotif, dataSet);

        var dataSource = new kendo.data.DataSource(
            {
                data: arrTieringNotif
            });
        grid1.setDataSource(dataSource);
        grid1.dataSource.pageSize(5);
        grid1.dataSource.page(1);
        grid1.select("tr:eq(0)");
        subControlTiering(false);
        subResetTiering();
    }
});
$("#btnHapus").click(function () {
    var grid1 = $("#dataGridView1").data("kendoGrid");
    grid1.refresh();

    grid1.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid1.dataItem(this);
        if (dataItem.PercentFrom == $("#_fromPercent").val() && dataItem.PercentTo == $("#_toPercent").val()) {
            grid1.dataSource.remove(dataItem);
            subControlTiering(false);
            subResetTiering();
        }
    })
});
$("#btnBatal").click(function () {
    subControlTiering(false);
    subResetTiering();
});

$("#btnAddPctTier").click(function () {
    subControlPctTiering(true);
    subResetPctTiering();
});
$("#btnSavePctTier").click(function () {
    if ($("#_pctRedemptTier").data("kendoNumericTextBox").value() == 0 ||
        $("#_periodTxt").data("kendoNumericTextBox").value() == 0 ||
        $("#_statusKaryawanCmb").val() == "") {
        swal("Warning", "Data Percentage Tiering Redemp Tidak Lengkap", "warning");
        return;
    }
    if ($("#_pctRedemptTier").data("kendoNumericTextBox").value() > 100) {
        swal("Warning", "Percentage Redemption tidak boleh lebih besar dari 100% !", "warning");
        return;
    }

    if ($("#_statusKaryawanCmb").data("kendoDropDownList").text() == "Non Karyawan") {
        if ($("#_pctRedemptTier").data("kendoNumericTextBox").value() < $("#_txtMinPctNonKary").data("kendoNumericTextBox").value()) {
            swal("Warning", "Percentage Redemp tidak boleh lebih kecil dari Minimum % Fee Non Karyawan!", "warning");
            return;
        }
    }
    else if ($("#_statusKaryawanCmb").data("kendoDropDownList").text() == "Karyawan") {
        if ($("#_pctRedemptTier").data("kendoNumericTextBox").value() < $("#_txtMinPctKary").data("kendoNumericTextBox").value()) {
            swal("Warning", "Percentage Redemp tidak boleh lebih kecil dari Minimum % Fee Karyawan!", "warning");
            return;
        }
    }

    var blnPassed = true;
    var grid2 = $("#dataGridView2").data("kendoGrid");
    grid2.refresh();
    grid2.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid2.dataItem(this);
        if (dataItem.Period == $("#_periodTxt").val() && dataItem.Status == $("#_statusKaryawanCmb").data("kendoDropDownList").text()) {
            swal("Warning", "Data percentage utk period tsb sudah ada", "warning");
            blnPassed = false;
            return false;
        }
    })

    if (blnPassed) {
        var arrPctRedempt = [];
        var obj = {};
        obj['Period'] = $("#_periodTxt").data("kendoNumericTextBox").value();
        obj['Status'] = $("#_statusKaryawanCmb").data("kendoDropDownList").text()
        obj['PercentageFee'] = $("#_pctRedemptTier").data("kendoNumericTextBox").value();

        arrPctRedempt.push(obj);
        var dataSet = grid2.dataSource.view();
        $.merge(arrPctRedempt, dataSet);

        var dataSource = new kendo.data.DataSource(
            {
                data: arrPctRedempt
            });
        grid2.setDataSource(dataSource);
        grid2.dataSource.pageSize(5);
        grid2.dataSource.page(1);
        grid2.select("tr:eq(0)");
        subControlPctTiering(false);
        subResetPctTiering();
    }
});
$("#btnHapusPctTier").click(function () {
    var grid2 = $("#dataGridView2").data("kendoGrid");
    grid2.refresh();

    grid2.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid2.dataItem(this);
        if (dataItem.Status == $("#_statusKaryawanCmb").data("kendoDropDownList").text() && dataItem.Period == $("#_periodTxt").val()) {
            grid2.dataSource.remove(dataItem);
            subControlPctTiering(false);
            subResetPctTiering();
        }
    })
});
$("#btnCancelPctTier").click(function () {
    subControlPctTiering(false);
    subResetPctTiering();
});




//change
$("#_noGL1").change(function () {
    if ($("#_noGL1").val().length == 8) {
        var res = ValidateGL($("#_noGL1").val());
        res.success(function (data) {
            if (data.blnResult) {
                $("#_descGL1").val(data.strNamaGL);
            } else {
                $("#_noGL1").val('');
            }
        });
    }
    else {
        $("#_descGL1").val('');
    }
});
$("#_noGL2").change(function () {
    if ($("#_noGL2").val().length == 8) {
        var res = ValidateGL($("#_noGL2").val());
        res.success(function (data) {
            if (data.blnResult) {
                $("#_descGL2").val(data.strNamaGL);
            } else {
                $("#_noGL2").val('');
            }
        });
    }
    else {
        $("#_descGL2").val('');
    }
});
$("#_noGL3").change(function () {
    if ($("#_noGL3").val().length == 8) {
        var res = ValidateGL($("#_noGL3").val());
        res.success(function (data) {
            if (data.blnResult) {
                $("#_descGL3").val(data.strNamaGL);
            } else {
                $("#_noGL3").val('');
            }
        });
    }
    else {
        $("#_descGL3").val('');
    }
});
$("#_noGL4").change(function () {
    if ($("#_noGL4").val().length == 8) {
        var res = ValidateGL($("#_noGL4").val());
        res.success(function (data) {
            if (data.blnResult) {
                $("#_descGL4").val(data.strNamaGL);
            } else {
                $("#_noGL4").val('');
            }
        });
    }
    else {
        $("#_descGL4").val('');
    }
});
$("#_noGL5").change(function () {
    if ($("#_noGL5").val().length == 8) {
        var res = ValidateGL($("#_noGL5").val());
        res.success(function (data) {
            if (data.blnResult) {
                $("#_descGL5").val(data.strNamaGL);
            } else {
                $("#_noGL5").val('');
            }
        });
    }
    else {
        $("#_descGL5").val('');
    }
});
$("#_flatCheck").change(function () {
    if ($("#_flatCheck").prop('checked') == true) {
        $("#_bulanNonFlat").val('');
    }
});
$("#_nonFlatCheck").change(function () {
    if (intMyType == "A" || intMyType == "U") {
        if ($("#_nonFlatCheck").prop('checked') == true) {
            $("#_bulanNonFlat").prop('disabled', false);
        }
        else {
            $("#_bulanNonFlat").prop('disabled', true);
        }
    }
});

function onRowGrid1Select(e) {
    var data = this.dataItem(this.select());
    $("#_fromPercent").data("kendoNumericTextBox").value(data.PercentFrom);
    $("#_toPercent").data("kendoNumericTextBox").value(data.PercentTo);
    $("#_Persetujuan").val(data.MustApproveBy);
};
function onRowGrid2Select(e) {
    var data = this.dataItem(this.select());
    $("#_periodTxt").data("kendoNumericTextBox").value(data.Period);
    $("#_pctRedemptTier").data("kendoNumericTextBox").value(data.PercentageFee);

    if (data.Status == "Karyawan") {
        $("#_statusKaryawanCmb").data('kendoDropDownList').value("1");
    }
    else {
        $("#_statusKaryawanCmb").data('kendoDropDownList').value("0");
    }
};

function onChange_txtMinPctNonKary() {
    if ($("#_txtMinPctNonKary").val() > 100) {
        $("#_txtMinPctNonKary").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_txtMinPctNonKary() {
    if ($("#_txtMinPctNonKary").val() > 100) {
        $("#_txtMinPctNonKary").data("kendoNumericTextBox").value(0);
    }
}
function onChange_txtMaxPctNonKary() {
    if ($("#_txtMaxPctNonKary").val() > 100) {
        $("#_txtMaxPctNonKary").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_txtMaxPctNonKary() {
    if ($("#_txtMaxPctNonKary").val() > 100) {
        $("#_txtMaxPctNonKary").data("kendoNumericTextBox").value(0);
    }
}
function onChange_txtMinPctKary() {
    if ($("#_txtMinPctKary").val() > 100) {
        $("#_txtMinPctKary").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_txtMinPctKary() {
    if ($("#_txtMinPctKary").val() > 100) {
        $("#_txtMinPctKary").data("kendoNumericTextBox").value(0);
    }
}
function onChange_txtMaxPctKary() {
    if ($("#_txtMaxPctKary").val() > 100) {
        $("#_txtMaxPctKary").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_txtMaxPctKary() {
    if ($("#_txtMaxPctKary").val() > 100) {
        $("#_txtMaxPctKary").data("kendoNumericTextBox").value(0);
    }
}
function onChange_fromPercent() {
    if ($("#_fromPercent").val() > 100) {
        $("#_fromPercent").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_fromPercent() {
    if ($("#_fromPercent").val() > 100) {
        $("#_fromPercent").data("kendoNumericTextBox").value(0);
    }
}
function onChange_toPercent() {
    if ($("#_toPercent").val() > 100) {
        $("#_toPercent").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_toPercent() {
    if ($("#_toPercent").val() > 100) {
        $("#_toPercent").data("kendoNumericTextBox").value(0);
    }
}
function onChange_pctRedemptTier() {
    if ($("#_pctRedemptTier").val() > 100) {
        $("#_pctRedemptTier").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_pctRedemptTier() {
    if ($("#_pctRedemptTier").val() > 100) {
        $("#_pctRedemptTier").data("kendoNumericTextBox").value(0);
    }
}
function onChange_percentGL1() {
    if ($("#_percentGL1").val() > 100) {
        $("#_percentGL1").data("kendoNumericTextBox").value(0);
    }
    $("#_TotalPercentGL").data("kendoNumericTextBox").value(+$("#_percentGL1").val() + +$("#_percentGL2").val() + +$("#_percentGL3").val() + +$("#_percentGL4").val() + +$("#_percentGL5").val());
}
function onSpin_percentGL1() {
    if ($("#_percentGL1").val() > 100) {
        $("#_percentGL1").data("kendoNumericTextBox").value(0);
    }
    $("#_TotalPercentGL").data("kendoNumericTextBox").value(+$("#_percentGL1").val() + +$("#_percentGL2").val() + +$("#_percentGL3").val() + +$("#_percentGL4").val() + +$("#_percentGL5").val());
}
function onChange_percentGL2() {
    if ($("#_percentGL2").val() > 100) {
        $("#_percentGL2").data("kendoNumericTextBox").value(0);
    }
    $("#_TotalPercentGL").data("kendoNumericTextBox").value(+$("#_percentGL1").val() + +$("#_percentGL2").val() + +$("#_percentGL3").val() + +$("#_percentGL4").val() + +$("#_percentGL5").val());
}
function onSpin_percentGL2() {
    if ($("#_percentGL2").val() > 100) {
        $("#_percentGL2").data("kendoNumericTextBox").value(0);
    }
    $("#_TotalPercentGL").data("kendoNumericTextBox").value(+$("#_percentGL1").val() + +$("#_percentGL2").val() + +$("#_percentGL3").val() + +$("#_percentGL4").val() + +$("#_percentGL5").val());
}
function onChange_percentGL3() {
    if ($("#_percentGL3").val() > 100) {
        $("#_percentGL3").data("kendoNumericTextBox").value(0);
    }
    $("#_TotalPercentGL").data("kendoNumericTextBox").value(+$("#_percentGL1").val() + +$("#_percentGL2").val() + +$("#_percentGL3").val() + +$("#_percentGL4").val() + +$("#_percentGL5").val());
}
function onSpin_percentGL3() {
    if ($("#_percentGL3").val() > 100) {
        $("#_percentGL3").data("kendoNumericTextBox").value(0);
    }
    $("#_TotalPercentGL").data("kendoNumericTextBox").value(+$("#_percentGL1").val() + +$("#_percentGL2").val() + +$("#_percentGL3").val() + +$("#_percentGL4").val() + +$("#_percentGL5").val());
}
function onChange_percentGL4() {
    if ($("#_percentGL4").val() > 100) {
        $("#_percentGL4").data("kendoNumericTextBox").value(0);
    }
    $("#_TotalPercentGL").data("kendoNumericTextBox").value(+$("#_percentGL1").val() + +$("#_percentGL2").val() + +$("#_percentGL3").val() + +$("#_percentGL4").val() + +$("#_percentGL5").val());
}
function onSpin_percentGL4() {
    if ($("#_percentGL4").val() > 100) {
        $("#_percentGL4").data("kendoNumericTextBox").value(0);
    }
    $("#_TotalPercentGL").data("kendoNumericTextBox").value(+$("#_percentGL1").val() + +$("#_percentGL2").val() + +$("#_percentGL3").val() + +$("#_percentGL4").val() + +$("#_percentGL5").val());
}
function onChange_percentGL5() {
    if ($("#_percentGL5").val() > 100) {
        $("#_percentGL5").data("kendoNumericTextBox").value(0);
    }
    $("#_TotalPercentGL").data("kendoNumericTextBox").value(+$("#_percentGL1").val() + +$("#_percentGL2").val() + +$("#_percentGL3").val() + +$("#_percentGL4").val() + +$("#_percentGL5").val());
}
function onSpin_percentGL5() {
    if ($("#_percentGL5").val() > 100) {
        $("#_percentGL5").data("kendoNumericTextBox").value(0);
    }
    $("#_TotalPercentGL").data("kendoNumericTextBox").value(+$("#_percentGL1").val() + +$("#_percentGL2").val() + +$("#_percentGL3").val() + +$("#_percentGL4").val() + +$("#_percentGL5").val());
}
