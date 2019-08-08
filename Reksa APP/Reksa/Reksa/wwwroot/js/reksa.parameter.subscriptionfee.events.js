
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

//change
$("#_noGL1").change(function () {
    var res = ValidateGL($("#_noGL1").val());
    res.success(function (data) {
        if (data.blnResult) {
            $("#_descGL1").val(data.strNamaGL);
        }
    });
});
$("#_noGL2").change(function () {
    var res = ValidateGL($("#_noGL2").val());
    res.success(function (data) {
        if (data.blnResult) {
            $("#_descGL2").val(data.strNamaGL);
        }
    });
});
$("#_noGL3").change(function () {
    var res = ValidateGL($("#_noGL3").val());
    res.success(function (data) {
        if (data.blnResult) {
            $("#_descGL3").val(data.strNamaGL);
        }
    });
});
$("#_noGL4").change(function () {
    var res = ValidateGL($("#_noGL4").val());
    res.success(function (data) {
        if (data.blnResult) {
            $("#_descGL4").val(data.strNamaGL);
        }
    });
});
$("#_noGL5").change(function () {
    var res = ValidateGL($("#_noGL5").val());
    res.success(function (data) {
        if (data.blnResult) {
            $("#_descGL5").val(data.strNamaGL);
        }
    });
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


function onRowSubsFeeSelect(e) {
    var data = this.dataItem(this.select());    
    //$("#_fromPercent").val(data.PercentFrom);
    //$("#_toPercent").val(data.PercentTo);
    $("#_fromPercent").data("kendoNumericTextBox").value(data.PercentFrom);
    $("#_toPercent").data("kendoNumericTextBox").value(data.PercentTo);
    $("#_Persetujuan").val(data.MustApproveBy);
};