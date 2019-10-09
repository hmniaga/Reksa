
//click
$("#btnRefresh").click(function () {
    subRefresh();
});
$("#buttonadd").click(function () {
    subNew();
});
$("#buttonedit").click(function () {
    subUpdate();
});
$("#buttondelete").click(function () {
    subDelete();
});
$("#buttonsave").click(function () {    
    subSave();
});
$("#buttonCancel").click(function () {
    subCancel();
});
$("#srcOffice").click(function () {
    var url = $(this).attr("href");
    $('#OfficeModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcCIF").click(function () {
    var url = $(this).attr("href");
    $('#CustomerModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcClient").click(function () {
    var CIFNo = $("#srcCIF_text1").val();
    var url = "/Global/SearchClientbyCIF/?CIFNo=" + CIFNo;
    $('#ClientModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });

}); 
$("#srcEmployee").click(function (ev) {
    var url = $(this).attr("href");
    $('#NIKModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcCabang").click(function (ev) {
    var url = $(this).attr("href");
    $('#CabangModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$('a[data-toggle=tab]').click(function () {
    _strTabName = this.id;
    if ((_intType != 1) || (_intType != 2)) {

        //_dvAkses.RowFilter = "InterfaceTypeId = '" + _strTabName + "'";
        subResetToolbar();
    }

    //if ((_strTabName == "MCA") || (_strTabName == "MCB")) {
    //    cmpsrCIF.Enabled = false;
    //}
    //else {
    //    cmpsrCIF.Enabled = true;
    //}
});
$("#btnGantiOpsiNPWP").click(function btnGantiOpsiNPWP_click() {
    $("#tbNoNPWPKK").val('');
    $("#tbNamaNPWPKK").val('');
    $("#tbKepemilikanLainnya").val('');
    var today = new Date();
    $("#dtpTglNPWPKK").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());
    $("#dtpTglDokTanpaNPWP").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());
    $("#tbNoDokTanpaNPWP").val('');

    switch (_intOpsiNPWP) {
        case 2:
            _intOpsiNPWP = 3;
            EnableFieldNPWP(3);
            break;
        case 1:
            _intOpsiNPWP = 2;
            EnableFieldNPWP(2);
            break;
        case 3:
            _intOpsiNPWP = 2;
            EnableFieldNPWP(2);
            break;
    }
});
$("#btnGenerateNoDokTanpaNPWP").click(function btnGenerateNoDokTanpaNPWP_click() {
    $.ajax({
        type: 'GET',
        url: '/Global/GetNoNPWPCounter',
        success: function (data) {
            if (data.blnResult) {
                $("#tbNoDokTanpaNPWP").val(data.strNoDocNPWP);
                document.getElementById("btnGenerateNoDokTanpaNPWP").disabled = true;
            }
            else {
                swal("Error GetNoNPWPCounter", data.ErrMsg, "error");
            }
        }
    });
});
$("#btnPopulate").click(function btnPopulate_click() {
    if (_strTabName == "MCA") {
        ReksaPopulateAktifitas();
    }
});




function dgvClientCode_CellClick(e) {
    var ClientCode;
    var data = this.dataItem(this.select());
    ClientCode = $.trim(data.ClientCode);
    intSelectedClient = $.trim(data.ClientId);
    GetDataRDB(ClientCode);
};
function dgvBlokir_Click(e) {
    var data = this.dataItem(this.select());
    $("#BlokirId").val(data.BlockId);
    $("#MoneyBlokir").data("kendoNumericTextBox").value(data.UnitBlokir);
    var dtpTglTran = new Date(data.TanggalBlokir);
    $("#dtpTglTran").val(pad((dtpTglTran.getDate()), 2) + '/' + pad((dtpTglTran.getMonth() + 1), 2) + '/' + dtpTglTran.getFullYear());
    var dtpExpiry = new Date(data.TanggalExpiryBlokir);
    $("#dtpExpiry").val(pad((dtpExpiry.getDate()), 2) + '/' + pad((dtpExpiry.getMonth() + 1), 2) + '/' + dtpExpiry.getFullYear());
};

function onChangeAddressType(e) {
    var dropdownlist = $("#cbDikirimKe").data("kendoDropDownList");
    var ValueType = dropdownlist.value();
    if (ValueType == '0') {
        $('#divAlamatNasabah').show();
        $('#divAlamatCabang').hide();
    } else {
        $('#divAlamatNasabah').hide();
        $('#divAlamatCabang').show();
    }
}
function onBoundAddressType(e) {
    var dropdownlist = $("#cbDikirimKe").data("kendoDropDownList");
    var len = dropdownlist.dataSource.data().length;

    if (len > 0) {
        dropdownlist.select(0);
        onChangeAddressType();
    }
}

function checkKonfAddressAll(e) {
    var state = $(e).is(':checked');
    var grid = $('#dgvKonfAddr').data('kendoGrid');
    $.each(grid.dataSource.view(), function () {
        if (this['Pilih'] != state)
            this.dirty = true;

        this['Pilih'] = state;
    });
    grid.refresh();
}
function onCheckBoxKonfAddressClick(e) {
    var state = $(e).is(':checked');
    var value = e.value;
    var grid = $('#dgvKonfAddr').data('kendoGrid');
    grid.refresh();

    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.Sequence == value) {
            dataItem.Pilih = state;
        }
    })

    var chkAll = $('#chkKonfAddressSelectAll').is(':checked');
    var isCheckedAll = false;
    var countTrue = 0;
    var countFalse = 0;
    var countAll = 0;

    $.each(grid.dataSource.view(), function () {
        if (this['Pilih'] == true) {
            countTrue = countTrue + 1;
        }
        else {
            countFalse = countFalse + 1;
            isCheckedAll = false;
        }
        countAll = countAll + 1;
    });
    if (countFalse == 0 || (countFalse == 1 && !state)) {
        $('#chkKonfAddressSelectAll').prop("checked", state);
    }
    grid.refresh();
} 

function onCheckBoxClickClient(e) {
    var state = $(e).is(':checked');
    var guid = e.value;

    var grid = $('#dgvClientCode').data('kendoGrid');
    grid.refresh();

    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.ClientId == guid) {
            dataItem.Pilih = state;
        }
    })

    var chkAll = $('#chkSelectAllClient').is(':checked');
    var isCheckedAll = true;
    var countTrue = 0;
    var countFalse = 0;
    var countAll = 0;

    $.each(grid.dataSource.view(), function () {
        if (this['Pilih'] == true) {
            countTrue = countTrue + 1;
        }
        else {
            countFalse = countFalse + 1;
            isCheckedAll = false;
        }
        countAll = countAll + 1;
    });
    if (countFalse == 0 || (countFalse == 1 && !state)) {
        $('#chkSelectAllClient').prop("checked", state);
    }
    grid.refresh();
}
function checkAllClient(e) {
    var state = $(e).is(':checked');
    var grid = $('#dgvClientCode').data('kendoGrid');
    $.each(grid.dataSource.view(), function () {
        if (this['Pilih'] != state)
            this.dirty = true;

        this['Pilih'] = state;
    });
    grid.refresh();
}
function onCheckBoxFlag(e) {
    var state = $(e).is(':checked');
    var guid = e.value;

    var grid = $('#dgvClientCode').data('kendoGrid');
    grid.refresh();

    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.ClientId == guid) {
            dataItem.Flag = state;
        }
    })

    var countTrue = 0;
    var countFalse = 0;
    var countAll = 0;

    $.each(grid.dataSource.view(), function () {
        if (this['Flag'] == true) {
            countTrue = countTrue + 1;
        }
        else {
            countFalse = countFalse + 1;
            isCheckedAll = false;
        }
        countAll = countAll + 1;
    });
    grid.refresh();
}

//change
$("#srcCIF_text1").change(function () {
    if (_intType == 1) {
        if ($("#srcCIF_text1").val() != "") {
            GetDataCIF($("#srcCIF_text1").val(), _intType);
        }
    } else {
        if ($("#srcCIF_text1").val() == "") {
            subClearAll();
        }
    }
});
$("#srcCabang_text1").change(function () {
    ValidateOffice($("#srcCabang_text1").val(), function (output) {
        $("#srcCabang_text2").val(output);
        GetAlamatCabang();
    });
});
$("#srcEmployee_text1").change(function () {
    ValidateReferentor($("#srcEmployee_text1").val(), function (output) {
        $("#srcEmployee_text2").val(output);
    });
});
$("#maskedRekening").change(function () {
    if ($("#maskedRekening").val() != "") {
        GetAccountRelationDetail($("#maskedRekening").val(), 1, function (output) {
            if (!output) {
                return;
            }
        });
        if ($("#maskedRekening").val() == "") {
            swal("Warning", "Nomor rekening salah!", "warning");
        }
    }
});
$("#maskedRekeningMC").change(function () {
    if ($("#maskedRekeningMC").val() != "") {
        GetAccountRelationDetail($("#maskedRekeningMC").val(), 4, function (output) {
            if (!output) {
                return;
            }
        });
        if ($("#maskedRekeningMC").val() == "") {
            swal("Warning", "Nomor rekening salah!", "warning");
        }
    }
});
$("#maskedRekeningUSD").change(function () {
    if ($("#maskedRekeningUSD").val() != "") {
        GetAccountRelationDetail($("#maskedRekeningUSD").val(), 3, function (output) {
            if (!output) {
                return;
            }
        });
        if ($("#maskedRekeningUSD").val() == "") {
            swal("Warning", "Nomor rekening salah!", "warning");
        }
    }
});
function onChange_cbKepemilikanNPWPKK() {
    if ($("#cbKepemilikanNPWPKK").data('kendoDropDownList').text() == "Lainnya")
        $("#tbKepemilikanLainnya").prop('disabled', false);
    else
        $("#tbKepemilikanLainnya").prop('disabled', true);
}
function onChange_cbStatus() {
    if ($("#cbStatus").data('kendoDropDownList').value() == 1) {
        GetAccountRelationDetail($("#srcCIF_text1").val(), 2, function (output) { });
    }
    else {
        $("#srcEmployee_text1").val('');
        $("#srcEmployee_text2").val('');
    }
}
function onChangedtpRiskProfile() {
    var CIFNo;
    if ($("#srcCIF_text1").val() == '')
        CIFNo = 0
    else
        CIFNo = $("#srcCIF_text1").val();
    $.ajax({
        type: 'GET',
        url: '/Customer/CekExpRiskProfile',
        data: { CIFNo: CIFNo, RiskProfile: $("#dtpRiskProfile").val() },
        success: function (data) {
            if (data.blnResult) {
                var dtExpiredRiskProfile = new Date(data.dtExprRiskProfile);
                $("#dtExpiredRiskProfile").val(pad((dtExpiredRiskProfile.getDate()), 2) + '/' + pad((dtExpiredRiskProfile.getMonth() + 1), 2) + '/' + dtExpiredRiskProfile.getFullYear());
                $("#txtEmail").val(data.strEmail);
            }
        }
    });
}



