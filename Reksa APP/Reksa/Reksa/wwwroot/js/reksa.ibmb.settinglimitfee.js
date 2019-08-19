var intMyType;
var RDBBit;
var RDBRedeemBit;
var RDBSwitchBit;
var RDBMinSubs
var RDBFeeSubsIns;
var RDBFeeSubsNoIns;
var RDBFullRedeemBit;
var RDBFeeRedempIns;
var RDBFeeRedempNoIns;
var RDBFullSwitchBit;

$(document).ready(function load() {
    var grid = {
        height: 200
    };
    $("#dataGridView1").kendoGrid(grid);
    var url = "/Global/SearchProduct";
    $('#_cmpsrProduct').attr('href', url);  
    intMyType = "B";
    SetToolbar(intMyType);
    SetControl(intMyType);
    subRefresh();
});

function subNew()
{
    intMyType = "A";
    SetControl(intMyType);
    SetToolbar(intMyType);
    Reset("2");
}
function subUpdate()
{
    if ($("#_cmpsrProduct_text1").val() == "") {
        swal("Warning", "Produk belum dipilih!", "warning");
        return;
    }
    intMyType = "U";
    SetControl(intMyType);
    SetToolbar(intMyType);
}
function subDelete()
{
    if ($("#_cmpsrProduct_text1").val() == "") {
        swal("Warning", "Produk belum dipilih!", "warning");
        return;
    }
    subProcess("D");
}
function subCancel()
{
    intMyType = "B";
    SetControl(intMyType);
    SetToolbar(intMyType);
    Reset("2");
}

function subSave(intMyType){
    if ($("#_cmpsrProduct_text1").val() == "") {
        swal("Warning", "Produk belum dipilih!", "warning");
        return;
    }
    if ($("#_pctFeeSubs").data("kendoNumericTextBox").value() > 100) {
        swal("Warning", "Persentase Fee Subscription tidak boleh lebih besar dari 100%!", "warning");
        return;
    }
    if ($("#_pctFeeRedemp").data("kendoNumericTextBox").value() > 100) {
        swal("Warning", "Persentase Fee Redemption tidak boleh lebih besar dari 100%!", "warning");
        return;
    }
    if ($("#_pctFeeSwitching").data("kendoNumericTextBox").value() > 100) {
        swal("Warning", "Persentase Fee Switching tidak boleh lebih besar dari 100%!", "warning");
        return;
    }
    if ($("#_pctHoldAmount").data("kendoNumericTextBox").value() > 100) {
        swal("Warning", "Persentase Fee Switching tidak boleh lebih besar dari 100%!", "warning");
        return;
    }
    if (($("#_yesSubsNew").prop("checked") != true) && ($("#_noSubsNew").prop("checked") != true)) {
        swal("Warning", "Parameter Apakah Boleh Subscription New di IB MB belum diisi !", "warning");
        return;
    }
    if (($("#_yesTampil").prop("checked") != true) && ($("#_noTampil").prop("checked") != true)) {
        swal("Warning", "Parameter Apakah akan ditampilkan di Info Detail Produk IB MB belum diisi !", "warning");
        return;
    }
    if ($("#_comboJenisSwitching").data("kendoDropDownList").text() == "") {
        swal("Warning", "Jenis Minimum Switching belum dipilih (dalam unit/nominal)!", "warning");
        return;
    }
    if ($("#_comboJenisRedemp").data("kendoDropDownList").text() == "") {
        swal("Warning", "Jenis Minimum Redemption belum dipilih (dalam unit/nominal)!", "warning");
        return;
    }
    subProcess(intMyType);
}

function SetControl(intMyType)
{
    if (intMyType == "R" || intMyType == "B" || intMyType == "D" || intMyType == "S") {
        $("#_cmpsrProduct_text1").prop('disabled', true);
        $("#_cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

        $("#_noSubsNew").prop('disabled', true);
        $("#_yesSubsNew").prop('disabled', true);
        $("#_yesTampil").prop('disabled', true);
        $("#_noTampil").prop('disabled', true);

        $("#_internetBankingcheck").prop('disabled', true);
        $("#_mobileBankingcheck").prop('disabled', true);

        $("#_minSubsNew").data("kendoNumericTextBox").enable(false);
        $("#_minSubsAdd").data("kendoNumericTextBox").enable(false);
        $("#_pctFeeSubs").data("kendoNumericTextBox").enable(false);
        $("#_minRedemp").data("kendoNumericTextBox").enable(false);
        $("#_pctFeeRedemp").data("kendoNumericTextBox").enable(false);
        $("#_minSwitching").data("kendoNumericTextBox").enable(false);
        $("#_pctFeeSwitching").data("kendoNumericTextBox").enable(false);
        $("#_pctHoldAmount").data("kendoNumericTextBox").enable(false);

        //dataGridView1.Enabled = true;
        $("#_comboJenisRedemp").data('kendoDropDownList').enable(false);
        $("#_comboJenisSwitching").data('kendoDropDownList').enable(false);
    }

    if (intMyType == "A") {
        $("#_cmpsrProduct_text1").prop('disabled', false);
        $("#_cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

        $("#_noSubsNew").prop('disabled', false);
        $("#_yesSubsNew").prop('disabled', false);
        $("#_yesTampil").prop('disabled', false);
        $("#_noTampil").prop('disabled', false);

        $("#_internetBankingcheck").prop('disabled', false);
        $("#_mobileBankingcheck").prop('disabled', false);

        $("#_minSubsNew").data("kendoNumericTextBox").enable(true);
        $("#_minSubsAdd").data("kendoNumericTextBox").enable(true);
        $("#_pctFeeSubs").data("kendoNumericTextBox").enable(true);
        $("#_minRedemp").data("kendoNumericTextBox").enable(true);
        $("#_pctFeeRedemp").data("kendoNumericTextBox").enable(true);
        $("#_minSwitching").data("kendoNumericTextBox").enable(true);
        $("#_pctFeeSwitching").data("kendoNumericTextBox").enable(true);
        $("#_pctHoldAmount").data("kendoNumericTextBox").enable(true);

        //dataGridView1.Enabled = false;
        $("#_comboJenisRedemp").data('kendoDropDownList').enable(true);
        $("#_comboJenisSwitching").data('kendoDropDownList').enable(true);
    }

    if (intMyType == "U") {
        $("#_cmpsrProduct_text1").prop('disabled', true);
        $("#_cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

        $("#_noSubsNew").prop('disabled', false);
        $("#_yesSubsNew").prop('disabled', false);
        $("#_yesTampil").prop('disabled', false);
        $("#_noTampil").prop('disabled', false);

        $("#_internetBankingcheck").prop('disabled', false);
        $("#_mobileBankingcheck").prop('disabled', false);

        $("#_minSubsNew").data("kendoNumericTextBox").enable(true);
        $("#_minSubsAdd").data("kendoNumericTextBox").enable(true);
        $("#_pctFeeSubs").data("kendoNumericTextBox").enable(true);
        $("#_minRedemp").data("kendoNumericTextBox").enable(true);
        $("#_pctFeeRedemp").data("kendoNumericTextBox").enable(true);
        $("#_minSwitching").data("kendoNumericTextBox").enable(true);
        $("#_pctFeeSwitching").data("kendoNumericTextBox").enable(true);
        $("#_pctHoldAmount").data("kendoNumericTextBox").enable(true);
        //dataGridView1.Enabled = false;
        $("#_comboJenisRedemp").data('kendoDropDownList').enable(true);
        $("#_comboJenisSwitching").data('kendoDropDownList').enable(true);
    }
}

function SetToolbar(intMyType)
{
    if (intMyType == "B" || intMyType == "S" || intMyType == "D") {
        document.getElementById("btnRefresh").disabled = false;
        document.getElementById("btnNew").disabled = false;
        document.getElementById("btnEdit").disabled = false;
        document.getElementById("btnDelete").disabled = false;
        document.getElementById("btnSave").disabled = true;
        document.getElementById("btnCancel").disabled = true;
    }
    if (intMyType == "A") {
        document.getElementById("btnRefresh").disabled = false;
        document.getElementById("btnNew").disabled = true;
        document.getElementById("btnEdit").disabled = true;
        document.getElementById("btnDelete").disabled = true;
        document.getElementById("btnSave").disabled = false;
        document.getElementById("btnCancel").disabled = false;
    }

    if (intMyType == "U") {
        document.getElementById("btnRefresh").disabled = false;
        document.getElementById("btnNew").disabled = true;
        document.getElementById("btnEdit").disabled = true;
        document.getElementById("btnDelete").disabled = true;
        document.getElementById("btnSave").disabled = false;
        document.getElementById("btnCancel").disabled = false;
    }
    if (intMyType == "R") {
        document.getElementById("btnRefresh").disabled = false;
        document.getElementById("btnNew").disabled = false;
        document.getElementById("btnEdit").disabled = false;
        document.getElementById("btnDelete").disabled = false;
        document.getElementById("btnSave").disabled = true;
        document.getElementById("btnCancel").disabled = true;
    }
}

function Reset(Jenis) {
    if (Jenis != "1") {
        $("#_cmpsrProduct_text1").val('');
    }
    $("#_cmpsrProduct_text2").val('');

    $("#_matauang").val('');

    $("#_noSubsNew").prop('checked', false);
    $("#_yesSubsNew").prop('checked', false);
    $("#_yesTampil").prop('checked', false);
    $("#_noTampil").prop('checked', false);

    $("#_internetBankingcheck").prop('checked', false);
    $("#_mobileBankingcheck").prop('checked', false);

    $("#_minSubsNew").data("kendoNumericTextBox").value(0);
    $("#_minSubsAdd").data("kendoNumericTextBox").value(0);
    $("#_pctFeeSubs").data("kendoNumericTextBox").value(0);
    $("#_minRedemp").data("kendoNumericTextBox").value(0);
    $("#_pctFeeRedemp").data("kendoNumericTextBox").value(0);
    $("#_minSwitching").data("kendoNumericTextBox").value(0);
    $("#_pctFeeSwitching").data("kendoNumericTextBox").value(0);
    $("#_pctHoldAmount").data("kendoNumericTextBox").value(0);
    //_comboJenisRedemp.SelectedIndex = -1;
    //_comboJenisSwitching.SelectedIndex = -1;
}

function subRefresh(){
    $.ajax({
        type: 'GET',
        url: '/IBMB/RefreshLimitFeeIBMB',
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                var grid = $("#dataGridView1").data("kendoGrid");
                var gridData = populateGrid(data.dsResult.table);
                grid.setOptions(gridData);
                grid.dataSource.pageSize(10);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");

                //var data = grid.dataSource.data();
                //$.each(data, function (i, row) {
                //    var isAlreadyEffective = row.isAlreadyEffective;

                //    if (isAlreadyEffective == "No") {
                //        $('tr[data-uid="' + row.uid + '"] ').css("background-color", "salmon"); //green
                //    }
                //    else {
                //        $('tr[data-uid="' + row.uid + '"] ').css("background-color", "#ffffff");  //yellow
                //    }


                //});


                $("#dataGridView1 th[data-field=prodCode]").html("Product Code")
                $("#dataGridView1 th[data-field=prodName]").html("Product Name")
                $("#dataGridView1 th[data-field=prodCCY]").html("Currency")
                $("#dataGridView1 th[data-field=minSubsNew]").html("Min Subs New")
                $("#dataGridView1 th[data-field=minSubsAdd]").html("Min Subs Add")
                $("#dataGridView1 th[data-field=minRedemption]").html("Min Redemption")
                $("#dataGridView1 th[data-field=minRedemptionBy]").html("Min Redemption By")
                $("#dataGridView1 th[data-field=minSwitching]").html("Min Switching")
                $("#dataGridView1 th[data-field=minSwitchingBy]").html("Min Switching By")
                $("#dataGridView1 th[data-field=pctFeeSubs]").html("Pct Fee Subs")
                $("#dataGridView1 th[data-field=pctFeeRedemp]").html("Pct Fee Redemp")
                $("#dataGridView1 th[data-field=pctFeeSwitching]").html("Pct Fee Switching")
                $("#dataGridView1 th[data-field=pctHoldAmount]").html("Pct Hold Amount")
                $("#dataGridView1 th[data-field=canSubsNew]").html("Can Subs New")
                $("#dataGridView1 th[data-field=canTrxIBank]").html("Can Trx IBank")
                $("#dataGridView1 th[data-field=canTrxMBank]").html("Can Trx MBank")
                $("#dataGridView1 th[data-field=isVisibleIBMB]").html("Visible IBMB")
                $("#dataGridView1 th[data-field=isAlreadyEffective]").html("Already Effective")
                $("#dataGridView1 th[data-field=effectiveDate]").html("Effective Date")
                $("#dataGridView1 th[data-field=canTrxRDB]").html("Can Trx RDB")
                $("#dataGridView1 th[data-field=canTrxRDBSwitch]").html("Can Trx RDB Switch")
                $("#dataGridView1 th[data-field=canTrxRDBRedeem]").html("Can Trx RDB Redeem")
                $("#dataGridView1 th[data-field=rdbMustFullRedeem]").html("Must Full Redeem (RDB)")
                $("#dataGridView1 th[data-field=rdbMustFullSwitch]").html("Must Full Switch (RDB)")
                $("#dataGridView1 th[data-field=rdbMinSubs]").html("Min Subs (RDB)")
                $("#dataGridView1 th[data-field=rdbPctFeeSubsNoIns]").html("Pct Fee Subs No Ins (RDB)")
                $("#dataGridView1 th[data-field=rdbPctFeeSubsWithIns]").html("Pct Fee Subs With Ins (RDB)")
                $("#dataGridView1 th[data-field=rdbPctFeeRedempNoIns]").html("Pct Fee Redemp No Ins (RDB)")
                $("#dataGridView1 th[data-field=rdbPctFeeRedempWithIns]").html("Pct Fee Redemp With Ins (RDB)")

                intMyType = "R";
                SetToolbar(intMyType);
                SetControl(intMyType);
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
                pageSize: 5,
                page: 1
            },
            change: dataGridView1_Click,
            databound: onBounddataGridView1,
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
        var effectiveDate = name.indexOf("effectiveDate") > -1 || name.indexOf("effectiveDate") > -1;
        var prodName = name.indexOf("prodName") > -1 || name.indexOf("prodName") > -1;
        var prodCCY = name.indexOf("prodCCY") > -1 || name.indexOf("prodCCY") > -1;
        var canTrxRDBRedeem = name.indexOf("canTrxRDBRedeem") > -1 || name.indexOf("canTrxRDBRedeem") > -1;
        var rdbMustFullRedeem = name.indexOf("rdbMustFullRedeem") > -1 || name.indexOf("rdbMustFullRedeem") > -1;
        var rdbMustFullSwitch = name.indexOf("rdbMustFullSwitch") > -1 || name.indexOf("rdbMustFullSwitch") > -1;
        var rdbPctFeeSubsNoIns = name.indexOf("rdbPctFeeSubsNoIns") > -1 || name.indexOf("rdbPctFeeSubsNoIns") > -1;
        var rdbPctFeeSubsWithIns = name.indexOf("rdbPctFeeSubsWithIns") > -1 || name.indexOf("rdbPctFeeSubsWithIns") > -1;
        var rdbPctFeeRedempNoIns = name.indexOf("rdbPctFeeRedempNoIns") > -1 || name.indexOf("rdbPctFeeRedempNoIns") > -1;
        var rdbPctFeeRedempWithIns = name.indexOf("rdbPctFeeRedempWithIns") > -1 || name.indexOf("rdbPctFeeRedempWithIns") > -1;
        
        return {
            template: effectiveDate ? "#= kendo.toString(kendo.parseDate(effectiveDate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                : columnNames,
            field: name,
            width: prodName ? 350 : prodCCY ? 90 : canTrxRDBRedeem ? 200 : rdbMustFullRedeem ? 200 : rdbMustFullSwitch ? 200 : rdbPctFeeSubsNoIns ? 200 : rdbPctFeeSubsWithIns ? 200 : rdbPctFeeRedempNoIns ? 220 : rdbPctFeeRedempWithIns? 250: 150,
            title: name
        };
    })
}
function subProcess(intMyType) {
    var minRedempByUnit = false;
    var minSwitchingByUnit = false;

    if ($("#_comboJenisRedemp").data("kendoDropDownList").text() == "unit") {
        minRedempByUnit = true;
    }
    if ($("#_comboJenisSwitching").data("kendoDropDownList").text() == "unit") {
        minSwitchingByUnit = true;
    }
    
    var model = JSON.stringify({
        'NIK': 0,
        'Module': '',
        'ProdId': $("#ProdId").val(),
        'MinSubsNew': $("#_minSubsNew").data("kendoNumericTextBox").value(),
        'MinSubsAdd': $("#_minSubsAdd").data("kendoNumericTextBox").value(),
        'MinRedemption': $("#_minRedemp").data("kendoNumericTextBox").value(),
        'MinSwitching': $("#_minSwitching").data("kendoNumericTextBox").value(),
        'PctFeeSubs': $("#_pctFeeSubs").data("kendoNumericTextBox").value(),
        'PctFeeRedemp': $("#_pctFeeRedemp").data("kendoNumericTextBox").value(),
        'PctFeeSwitching': $("#_pctFeeSwitching").data("kendoNumericTextBox").value(),
        'PctHoldAmount': $("#_pctHoldAmount").data("kendoNumericTextBox").value(),
        'ProcessType': intMyType,
        'CanSubsNew': $("#_yesSubsNew").prop("checked"),
        'CanTrxIBank': $("#_internetBankingcheck").prop("checked"),
        'CanTrxMBank': $("#_mobileBankingcheck").prop("checked"), 
        'IsVisibleIBMB': $("#_yesTampil").prop("checked"), 
        'MinRedempByUnit': minRedempByUnit,
        'MinSwitchingByUnit': minSwitchingByUnit,
        'RDBBit': RDBBit,
        'RDBRedeemBit': RDBRedeemBit,
        'RDBSwitchBit': RDBSwitchBit,
        'RDBMinSubs': RDBMinSubs,
        'RDBFeeSubsIns': RDBFeeSubsIns,
        'RDBFeeSubsNoIns': RDBFeeSubsNoIns,
        'RDBFullRedeemBit': RDBFullRedeemBit,
        'RDBFeeRedempIns': RDBFeeRedempIns,
        'RDBFeeRedempNoIns': RDBFeeRedempNoIns,
        'RDBFullSwitchBit': RDBFullSwitchBit
    });

    $.ajax({
        type: "POST",
        data: model,
        url: '/IBMB/MaintainLimitFeeIBMB',
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult == true) {
                swal("Success", "Proses simpan data berhasil! \n\n Tanggal Efektif perubahan ini: " + data.EffectiveDate
                    + "\n\n" + "Membutuhkan otorisasi oleh supervisor agar perubahan tersebut aktif", "success");
                intMyType = "S";
                SetToolbar(intMyType);
                SetControl(intMyType);
                Reset("2");
                subRefresh();
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
        ,
        complete: function () {
            $("#load_screen").hide();
        }
    });
}