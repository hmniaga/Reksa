//click
$("#cmpsrProduct").click(function cmpsrProduct_click() {
    var url = $(this).attr("href");
    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
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

        obj['TrxType'] = 'SWC';
        obj['ProdId'] = $("#ProdId").val();
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

function onRowGrid1Select(e) {
    var data = this.dataItem(this.select());
    $("#_fromPercent").data("kendoNumericTextBox").value(data.PercentFrom);
    $("#_toPercent").data("kendoNumericTextBox").value(data.PercentTo);
    $("#_Persetujuan").val(data.MustApproveBy);
};