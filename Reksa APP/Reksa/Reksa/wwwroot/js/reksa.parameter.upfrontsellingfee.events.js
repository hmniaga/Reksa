
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

function onChange_PercentageDefault() {
    if ($("#PercentageDefault").val() > 100) {
        $("#PercentageDefault").data("kendoNumericTextBox").value(0);
    }
}
function onSpin_PercentageDefault() {
    if ($("#PercentageDefault").val() > 100) {
        $("#PercentageDefault").data("kendoNumericTextBox").value(0);
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