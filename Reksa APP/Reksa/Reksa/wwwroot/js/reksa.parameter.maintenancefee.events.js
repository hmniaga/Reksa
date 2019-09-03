
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

    if ($("#_AUMMax").data("kendoNumericTextBox").value() == 0 ||
        $("#_AUMMin").data("kendoNumericTextBox").value() == 0 ||
        $("#_BankPct").data("kendoNumericTextBox").value() == 0 ||
        $("#_fundMgrPct").data("kendoNumericTextBox").value() == 0 ||
        $("#_mntcFee").data("kendoNumericTextBox").value() == 0) {
        swal("Warning", "Data Tiering Tidak Lengkap", "warning");
        return;
    }
    if ($("#_AUMMax").data("kendoNumericTextBox").value() <
        $("#_AUMMin").data("kendoNumericTextBox").value()) {
        swal("Warning", "AUM Max tidak boleh lebih besar dari AUM Min !", "warning");
        return;
    }
    if ($("#_BankPct").data("kendoNumericTextBox").value() > 100) {
        swal("Warning", "Percentage Bank tidak boleh lebih besar dari 100% !", "warning");
        return;
    }
    if ($("#_fundMgrPct").data("kendoNumericTextBox").value() > 100) {
        swal("Warning", "Percentage Fund Manager tidak boleh lebih besar dari 100% !", "warning");
        return;
    }
    if ($("#_mntcFee").data("kendoNumericTextBox").value() > 100) {
        swal("Warning", "Percentage Maintenance Fee tidak boleh lebih besar dari 100% !", "warning");
        return;
    }
    if (+$("#_BankPct").data("kendoNumericTextBox").value() + +$("#_fundMgrPct").data("kendoNumericTextBox").value() != 100) {
        swal("Warning", "Jumlah dari Percentage Bank dan Fund Manager harus 100% !", "warning");
        return;
    }

    var blnPassed = true;
    var grid1 = $("#dataGridView1").data("kendoGrid");
    grid1.refresh();
    grid1.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid1.dataItem(this);
        if (dataItem.AUMMin <= $("#_AUMMin").data("kendoNumericTextBox").value() && dataItem.AUMMax >= $("#_AUMMin").data("kendoNumericTextBox").value()) {
            swal("Warning", "Data fee sudah ada(1)", "warning");
            blnPassed = false;
            return;
        }
        if (dataItem.AUMMin <= $("#_AUMMax").data("kendoNumericTextBox").value() && dataItem.AUMMax >= $("#_AUMMax").data("kendoNumericTextBox").value()) {
            swal("Warning", "Data fee sudah ada(2)", "warning");
            blnPassed = false;
            return;
        }
    })

    if (blnPassed) {
        var arrTieringNotif = [];
        var obj = {};
        obj['AUMMin'] = $("#_AUMMin").data("kendoNumericTextBox").value();
        obj['AUMMax'] = $("#_AUMMax").data("kendoNumericTextBox").value();
        obj['NISPPct'] = $("#_BankPct").data("kendoNumericTextBox").value();
        obj['FundMgrPct'] = $("#_fundMgrPct").data("kendoNumericTextBox").value();
        obj['MaintenanceFee'] = $("#_mntcFee").data("kendoNumericTextBox").value();

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
        if (dataItem.AUMMin == $("#_AUMMin").val() && dataItem.AUMMax == $("#_AUMMax").val()) {
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

function onRowGrid1Select(e) {
    var data = this.dataItem(this.select());
    $("#_AUMMin").data("kendoNumericTextBox").value(data.AUMMin);
    $("#_AUMMax").data("kendoNumericTextBox").value(data.AUMMax);
    $("#_BankPct").data("kendoNumericTextBox").value(data.NISPPct);
    $("#_fundMgrPct").data("kendoNumericTextBox").value(data.FundMgrPct);
    $("#_mntcFee").data("kendoNumericTextBox").value(data.MaintenanceFee);
};


function onChange_mntcFee() {
    if ($("#_mntcFee").val() > 100) {
        $("#_mntcFee").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_mntcFee() {
    if ($("#_mntcFee").val() > 100) {
        $("#_mntcFee").data("kendoNumericTextBox").value(0);
    }
}
function onChange_fundMgrPct() {
    if ($("#_fundMgrPct").val() > 100) {
        $("#_fundMgrPct").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_fundMgrPct() {
    if ($("#_fundMgrPct").val() > 100) {
        $("#_fundMgrPct").data("kendoNumericTextBox").value(0);
    }
}
function onChange_BankPct() {
    if ($("#_BankPct").val() > 100) {
        $("#_BankPct").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_BankPct() {
    if ($("#_BankPct").val() > 100) {
        $("#_BankPct").data("kendoNumericTextBox").value(0);
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
