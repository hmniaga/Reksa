$("#btnRefresh").click(function btnRefresh_click() {
    subRefresh();
});
$("#btnAdd").click(function btnAdd_click() {
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


$("#cmpsrSearch1").click(function cmpsrSearch1_click() {
    var url = $(this).attr("href");
    $('#ProductModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});


function onChangetxtbEffectiveDays()
{
    var res = subCalcEffectiveDate($("#dateTimePicker4").val(), $("#txtbEffectiveDays").data("kendoNumericTextBox").value());
    res.success(function (data) {
        var dtpEfektif = new Date(data.dateEnd);
        $("#dtpEfektif").val(pad((dtpEfektif.getDate()), 2) + '/' + pad((dtpEfektif.getMonth() + 1), 2) + '/' + dtpEfektif.getFullYear());
    });
}

function onSpintxtbEffectiveDays()
{
    var res = subCalcEffectiveDate($("#dateTimePicker4").val(), $("#txtbEffectiveDays").data("kendoNumericTextBox").value());
    res.success(function (data) {
        var dtpEfektif = new Date(data.dateEnd);
        $("#dtpEfektif").val(pad((dtpEfektif.getDate()), 2) + '/' + pad((dtpEfektif.getMonth() + 1), 2) + '/' + dtpEfektif.getFullYear());
    });
}

$("#radioButton1").change(function radioButton1_change() {
    $('#groupBox4').show();
    $('#groupBox5').hide();
});
$("#radioButton2").change(function radioButton2_change() {
    $('#groupBox4').hide();
    $('#groupBox5').show();
});
$("#CurrencyName").change(function CurrencyName_change() {
    $("#label13").text($("#CurrencyCode").val());
    $("#label5").text($("#CurrencyCode").val());
});
$("#checkBox1").change(function checkBox1_change() {
    if ($("#checkBox1").prop('checked') == true) {
        if ($("#checkBox1").prop('disabled') == false) {
            $("#cmpsrSearch6").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
            $("#textBox12").data("kendoNumericTextBox").enable(true);
            //$('#txtbDevidentPct').prop('disabled', false);
            $("#txtbDevidentPct").data("kendoNumericTextBox").enable(true);
        }
    }
    else
    {
        $("#CalcDevCode").val('');
        $("#CalcDevName").val('');
        $("#CalcDevCode").prop('disabled', true);
        $("#CalcDevName").prop('disabled', true);
        $("#cmpsrSearch6").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

        //$('#txtbDevidentPct').val('');
        //$('#txtbDevidentPct').prop('disabled', true);
        $("#txtbDevidentPct").data("kendoNumericTextBox").value(0);
        $("#txtbDevidentPct").data("kendoNumericTextBox").enable(false);
    }
});

$("#CurrencyCode").change(function CurrencyCode_change()
{
    $("#label13").text($("#CurrencyCode").val());
    $("#label5").text($("#CurrencyCode").val());
});

