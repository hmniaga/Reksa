var _intProdId;
var _intType;
var _boolIsDeviden;
var _boolCloseEnd;

$(document).ready(function () {
    _intType = 0;
    subResetToolBar();
    SetReadOnly(true);
    document.getElementById("label5").style.display = 'none';
});
function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/PO/RefreshProdNAV',
        data: { ProdId: $("#ProdId").val() },
        success: function (data) {
            if (data.blnResult) {
                switch (data.listProductNAV[0].Status) {
                    case "0":
                        {
                            $("#lblStatus").text("Status Produk : Belum Aktif");
                            break;
                        }
                    case "1":
                        {
                            $("#lblStatus").text("Status Produk : Aktif");
                            break;
                        }
                    case "2":
                        {
                            $("#lblStatus").text("Status Produk : Rejected");
                            break;
                        }
                }
                _intProdId = data.listProductNAV[0].ProdId;
                _intType = 1;

                $("#MoneyNAV").data("kendoNumericTextBox").value(data.listProductNAV[0].NAV);
                $("#MoneyNominal").data("kendoNumericTextBox").value(0);
                //$("#MoneyNAV").val(data.listProductNAV[0].NAV);
                //$("#MoneyNominal").val(0);

                var NAVValueDate = new Date(data.listProductNAV[0].NAVValueDate);
                var DevidenDate = new Date(data.listProductNAV[0].DevidenDate);
                $("#dtpNAVValueDate").val(NAVValueDate.getDate() + '/' + (NAVValueDate.getMonth() + 1) + '/' + NAVValueDate.getFullYear());
                $("#dtpDevident").val(DevidenDate.getDate() + '/' + (DevidenDate.getMonth() + 1) + '/' + DevidenDate.getFullYear());

                $("#srcCurrency_text1").val(data.listProductNAV[0].ProdCCY);
                ValidateCurrency($("#srcCurrency_text1").val(), function (output) {
                    $("#srcCurrency_text2").val(output);
                });
                $("#lblDevidenType").text(data.listProductNAV[0].DevidenType);
                _boolCloseEnd = data.listProductNAV[0].CloseEndBit;
                _boolIsDeviden = data.listProductNAV[0].IsDeviden;

                if (data.listProductNAV[0].IsHargaUnitPerHari == "1") {
                    document.getElementById("label5").style.display = 'block';
                }
                else {
                    document.getElementById("label5").style.display = 'none';
                }

                if (_boolIsDeviden) {
                    document.getElementById("label2").style.display = 'block';
                    document.getElementById("label4").style.display = 'block';
                }
                else {
                    document.getElementById("label2").style.display = 'none';
                    document.getElementById("label4").style.display = 'none';
                }

            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}
function subSave() {
    //console.log($("#dtpNAVValueDate").val());
    var dtpNAVValueDate = $("#dtpNAVValueDate").val();
    var dtpDevident = $("#dtpDevident").val();
    $.ajax({
        type: 'POST',
        url: '/PO/MaintainProdNAV',
        //contentType: "application/json; charset=utf-8",
        data: { ProdId: _intProdId, NAV: $("#MoneyNAV").val(), NAVValueDate: dtpNAVValueDate, DevidentDate: dtpDevident, Devident: $("#MoneyNominal").val(), HargaUnit: $("#Money1").val() },
        success: function (data) {
            if (data.blnResult) {
                _intType = 0;
                ResetForm();
                subResetToolBar();
                SetReadOnly(true);
                swal("Berhasil simpan untuk otorisasi", "No Referensi = " + data.RefID, "success");
                $("#cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}
function subUpdate() {
    SetReadOnly(false);
    $("#MoneyNominal").data("kendoNumericTextBox").enable(_boolIsDeviden);
    //$("#MoneyNominal").prop('disabled', !_boolIsDeviden);
    _intType = 2;
    subResetToolBar();
    $("#ProdCode").prop('disabled', true);
    $("#cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
}
function ValidateCurrency(CurrCode, result) {
    if (CurrCode != '') {
        $.ajax({
            type: 'GET',
            url: '/Global/ValidateCurrency',
            data: { Col1: CurrCode, Col2: '', Validate: 1 },
            success: function (data) {
                if (data.length != 0) {
                    result(data[0].CurrencyName);
                } else {
                    result('');
                }
            }
        });
    }
}
function SetReadOnly(status) {
    $("#MoneyNAV").data("kendoNumericTextBox").enable(!status);
    //$("#MoneyNAV").prop('disabled', status);
    $("#dtpNAVValueDate").prop('disabled', status);
    $("#srcCurrency_text1").prop('disabled', true);
    $("#srcCurrency").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    $("#MoneyNominal").data("kendoNumericTextBox").enable(!status);
    //$("#MoneyNominal").prop('disabled', status);
    $("#dtpDevident").prop('disabled', status);
    $("#Money1").data("kendoNumericTextBox").enable(!status);
    //$("#Money1").prop('disabled', status);
}
function ResetForm() {
    var Today = new Date();
    $("#MoneyNAV").data("kendoNumericTextBox").value(0);
    //$("#MoneyNAV").val(0);
    $("#dtpNAVValueDate").val(Today.getDate() + '/' + (Today.getMonth() + 1) + '/' + Today.getFullYear());
    $("#srcCurrency_text1").val("IDR");
    ValidateCurrency($("#srcCurrency_text1").val(), function (output) {
        $("#srcCurrency_text2").val(output);
    });
    $("#MoneyNominal").data("kendoNumericTextBox").value(0);
    //$("#MoneyNominal").val(0);
    $("#dtpDevident").val(Today.getDate() + '/' + (Today.getMonth() + 1) + '/' + Today.getFullYear());
    $("#lblDevidenType").text("");
}
function subResetToolBar() {
    switch (_intType) {
        case 0:
            {
                $("#btnRefresh").show();
                $("#btnNew").show();
                $("#btnEdit").show();
                $("#btnSave").hide();
                $("#btnCancel").hide();
                break;
            }

        case 1:
            {
                $("#btnRefresh").show();
                $("#btnNew").show();
                $("#btnEdit").show();
                $("#btnSave").hide();
                $("#btnCancel").hide();
                break;
            }

        case 2:
            {
                $("#btnRefresh").hide();
                $("#btnNew").hide();
                $("#btnEdit").hide();
                $("#btnSave").show();
                $("#btnCancel").show();
                break;
            }
    }
}
function subCancel() {
    ResetForm();
    SetReadOnly(true);
    _intType = 0;
    subResetToolBar();
    subRefresh();
    $("#srcCurrency").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
}
function subNew() {

}
function toDate(dateStr) {
    var [day, month, year] = dateStr.split("/")
    return new Date(year, month - 1, day)
}