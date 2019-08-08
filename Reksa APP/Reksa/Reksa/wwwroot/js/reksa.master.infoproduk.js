var _intType;
var _intProdId;
var isUpdate;
var Today = new Date();

$(document).ready(function load () {
    $("#label27").text('');
    _intType = 0;
    subResetToolBar();
    SetReadOnly(true);
    var gridOptions = {
        height: 200
    };
    $('#cmpsrSearch1').attr('href', '/Global/SearchProduct');

    $("#dataGridView1").kendoGrid(gridOptions);
    $("#dataGridView2").kendoGrid(gridOptions);
    $("#dataGridView3").kendoGrid(gridOptions);
    $("#dataGridView4").kendoGrid(gridOptions);
    $("#dataGridView5").kendoGrid(gridOptions);
    $("#dataGridView6").kendoGrid(gridOptions);
    $("#dataGridView7").kendoGrid(gridOptions);
    $("#dataGridView8").kendoGrid(gridOptions);
    $("#dgvMaintenanceFee").kendoGrid(gridOptions);
});

function subNew() {
    ResetForm();
    $('#radioButton1').prop('checked', true);
    SetReadOnly(false);
    _intType = 2;
    isUpdate = false;
    subResetToolBar();
    $("#label27").text("NEW");
    var columns, datasource, gridData;
    columns = [
        { field: "Fee", width: 100 },
        { field: "Period", width: 100 },
        { field: "Nominal", width: 100 },
        { command: "destroy", width: 100 }
    ];

    datasource = {
            schema: {
                model: {
                    fields: {
                        Fee: { type: "number", validation: { min: 0 } },
                        Period: { type: "number", validation: { min: 0 } },
                        Nominal: { type: "number", validation: { min: 0 } }
                    }
                }
            }
        };
    gridData = populateNewGrid(columns, datasource);
    $("#dataGridView1").data("kendoGrid").setOptions(gridData);
    $("#dataGridView2").data("kendoGrid").setOptions(gridData);

    columns = [
        { field: "Fee", width: 100 },
        { field: "Nominal", width: 100 },
        { command: "destroy", width: 100 }
    ];
    datasource = {
            schema: {
                model: {
                    fields: {
                        Fee: { type: "number", validation: { min: 0 } },
                        Nominal: { type: "number", validation: { min: 0 } }
                    }
                }
            }
        };
    gridData = populateNewGrid(columns, datasource);
    $("#dataGridView3").data("kendoGrid").setOptions(gridData);
    $("#dataGridView4").data("kendoGrid").setOptions(gridData);

    columns = [
        { field: "AUMMin", width: 100 },
        { field: "AUMMax", width: 100 },
        { field: "NispPct", width: 100 },
        { field: "FundMgrPct", width: 100 },
        { field: "MaintFee", width: 100 },
        { command: "destroy", width: 100 }
    ];
    datasource = {
            schema: {
                model: {
                    fields: {
                        AUMMin: { type: "number", validation: { min: 0 } },
                        AUMMax: { type: "number", validation: { min: 0 } },
                        NispPct: { type: "number", validation: { min: 0 } },
                        FundMgrPct: { type: "number", validation: { min: 0 } },
                        MaintFee: { type: "number", validation: { min: 0 } }
                    }
                }
            }
        };
    gridData = populateNewGrid(columns, datasource);
    $("#dgvMaintenanceFee").data("kendoGrid").setOptions(gridData);
}

function populateNewGrid(columns, datasource) {
    return gridOptions = {
        columns: columns,
        dataSource: datasource,
        editable: {
            createAt: "bottom"
        },
        toolbar: ["create"]
        , resizable: true
        , scrollable: { height:300 }
    };
}

function subUpdate() {
    SetReadOnly(false);
    _intType = 2;
    isUpdate = true;
    subResetToolBar();
    $("#label27").text("UPDATE");
    $("#dataGridView1").data("kendoGrid").setOptions({ editable: { createAt: "bottom" }, toolbar: ["create"] });
    $("#dataGridView2").data("kendoGrid").setOptions({ editable: { createAt: "bottom" }, toolbar: ["create"] });
    $("#dataGridView3").data("kendoGrid").setOptions({ editable: { createAt: "bottom" }, toolbar: ["create"] });
    $("#dataGridView4").data("kendoGrid").setOptions({ editable: { createAt: "bottom" }, toolbar: ["create"] });
    $("#dgvMaintenanceFee").data("kendoGrid").setOptions({ editable: { createAt: "bottom" }, toolbar: ["create"] });
}

function subCancel() {
    ResetForm();
    SetReadOnly(true);
    _intType = 0;
    subResetToolBar();
    subRefresh();
}

function subRefresh() {
    ResetForm();
    SetReadOnly(true);
    $.ajax({ 
        type: 'GET',
        url: '/Master/RefreshProduct',
        data: { ProdId: $("#ProdId").val() },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                switch (data.dsResult.table[0].status) {
                    case 0:
                        {
                            $("#label27").text("Status Produk : Belum Aktif");
                            break;
                        }
                    case 1:
                        {
                            $("#label27").text("Status Produk : Aktif");
                            break;
                        }
                    case 2:
                        {
                            $("#label27").text("Status Produk : Rejected");
                            break;
                        }
                }

                _intProdId = data.dsResult.table[0].prodId;
                //$("#MoneyNAV").val(data.dsResult.table[0].nav);
                $("#MoneyNAV").data("kendoNumericTextBox").value(data.dsResult.table[0].nav);
                var MoneyNAV = $("#MoneyNAV").data("kendoNumericTextBox").value();
                $("#textBox1").val($("#ProdCode").val());
                $("#textBox2").val(data.dsResult.table[0].prodName);

                $("#ManInvCode").val(data.dsResult.table[0].manInvCode);
                ValidateManInv($("#ManInvCode").val(), function (output) {
                    $("#ManInvName").val(output);
                });
                $("#cmpsrCustody_text1").val(data.dsResult.table[0].custodyCode);
                ValidateCustody($("#cmpsrCustody_text1").val(), function (output) {
                    $("#cmpsrCustody_text2").val(output);
                });
                $("#CurrencyCode").val(data.dsResult.table[0].prodCCY);
                ValidateCurrency($("#CurrencyCode").val(), function (output) {
                    $("#CurrencyName").val(output);
                });
                $("#MIAccountId").val(data.dsResult.table[0].miAccountId);
                $("#CTDAccountId").val(data.dsResult.table[0].ctdAccountId);

                //$("#MoneyOPMaksUnit").val(data.dsResult.table[0].maxTotalUnit);
                $("#MoneyOPMaksUnit").data("kendoNumericTextBox").value(data.dsResult.table[0].maxTotalUnit);
                var MoneyOPMaksUnit = $("#MoneyOPMaksUnit").data("kendoNumericTextBox").value();
                //$("#MoneyOPMaksNom").val(MoneyOPMaksUnit * MoneyNAV);
                $("#MoneyOPMaksNom").data("kendoNumericTextBox").value(MoneyOPMaksUnit * MoneyNAV);

                //$("#textBox7").val(data.dsResult.table[0].maxDailyCust);
                $("#textBox7").data("kendoNumericTextBox").value(data.dsResult.table[0].maxDailyCust);
                //$("#MoneyOPMaksPerNas").val(+$("#textBox7").val() * MoneyOPMaksUnit / 100);
                $("#MoneyOPMaksPerNas").data("kendoNumericTextBox").value($("#textBox7").data("kendoNumericTextBox").value() * MoneyOPMaksUnit / 100);
                var dateTimePicker1 = new Date(data.dsResult.table[0].changeDate);
                $("#dateTimePicker1").val(pad((dateTimePicker1.getDate()), 2) + '/' + pad((dateTimePicker1.getMonth() + 1), 2) + '/' + dateTimePicker1.getFullYear());
                var dateTimePicker2 = new Date(data.dsResult.table[0].valueDate);
                $("#dateTimePicker2").val(pad((dateTimePicker2.getDate()), 2) + '/' + pad((dateTimePicker2.getMonth() + 1), 2) + '/' + dateTimePicker2.getFullYear());
                //$("#textBox13").val(data.dsResult.table[0].subcFeeBased);
                //$("#textBox15").val(data.dsResult.table[0].redempFeeBased);
                //$("#textBox16").val(data.dsResult.table[0].maintenanceFee);
                $("#textBox13").data("kendoNumericTextBox").value(data.dsResult.table[0].subcFeeBased);
                $("#textBox15").data("kendoNumericTextBox").value(data.dsResult.table[0].redempFeeBased);
                $("#textBox16").data("kendoNumericTextBox").value(data.dsResult.table[0].maintenanceFee);


                $("#TypeCode").val(data.dsResult.table[0].typeCode);
                ValidateTypeReksa($("#TypeCode").val(), function (output) {
                    $("#TypeName").val(output);
                });
                $("#CalcDevCode").val(data.dsResult.table[0].calcCode);
                ValidateCalcDev($("#CalcDevCode").val(), function (output) {
                    $("#CalcDevName").val(output);
                });
                $("#MoneyCEMinUnit").val(data.dsResult.table[0].minTotalUnit);
                $("#MoneyCEaxUnit").val(data.dsResult.table[0].maxTotalUnit);

                var dateTimePicker3 = new Date(data.dsResult.table[0].periodStart);
                $("#dateTimePicker3").val(pad((dateTimePicker3.getDate()), 2) + '/' + pad((dateTimePicker3.getMonth() + 1), 2) + '/' + dateTimePicker3.getFullYear());
                var dateTimePicker4 = new Date(data.dsResult.table[0].periodEnd);
                $("#dateTimePicker4").val(pad((dateTimePicker4.getDate()), 2) + '/' + pad((dateTimePicker4.getMonth() + 1), 2) + '/' + dateTimePicker4.getFullYear());
                var dateTimePicker5 = new Date(data.dsResult.table[0].matureDate);
                $("#dateTimePicker5").val(pad((dateTimePicker5.getDate()), 2) + '/' + pad((dateTimePicker5.getMonth() + 1), 2) + '/' + dateTimePicker5.getFullYear());

                $("#textBox3").val(data.dsResult.table[0].upFrontFee);

                var gridView5 = $("#dataGridView5").data("kendoGrid");
                var gridView5data = populateGrid(data.dsResult.table9);
                if (data.dsResult.table9.length > 0) {
                    gridView5.setOptions(gridView5data);
                    gridView5.setOptions({ toolbar: null });
                    gridView5.select("tr:eq(0)");
                }


                $("#textBox4").val(data.dsResult.table[0].sellingFee);
                $("#txtFundCode").val(data.dsResult.table[0].nfsFundCode);

                if (data.dsResult.table[0].closeEndBit == "1") {
                    $("#radioButton1").prop('checked', false);
                    $("#radioButton2").prop('checked', true);
                }
                else {
                    $("#radioButton1").prop('checked', true);
                    $("#radioButton2").prop('checked', false);
                }

                if (data.dsResult.table[0].isDeviden == true) {
                    $("#checkBox1").prop('checked', true);
                    //$("#textBox12").val(data.dsResult.table[0].devidenPeriod);
                    $("#textBox12").data("kendoNumericTextBox").value(data.dsResult.table[0].devidenPeriod);
                    //$("#txtbDevidentPct").val(data.dsResult.table[0].devidentPct);
                    //$("#txtbEffectiveDays").val(data.dsResult.table[0].effectiveAfter);
                    $("#txtbDevidentPct").data("kendoNumericTextBox").value(data.dsResult.table[0].devidentPct);
                    $("#txtbEffectiveDays").data("kendoNumericTextBox").value(data.dsResult.table[0].effectiveAfter);
                }
                var gridView1 = $("#dataGridView1").data("kendoGrid");
                var gridView1data = populateGrid(data.dsResult.table3);
                if (data.dsResult.table3.length > 0) {
                    gridView1.setOptions(gridView1data);
                    //if (_intType > 0) {
                    //    gridView1.setOptions({ toolbar: [{ name: "Create" }] });
                    //}
                    //else
                    //{
                    gridView1.setOptions({ toolbar: null });
                    gridView1.select("tr:eq(0)");
                    //}
                }

                var gridView2 = $("#dataGridView2").data("kendoGrid");
                var gridView2data = populateGrid(data.dsResult.table4);
                if (data.dsResult.table4.length > 0) {
                    gridView2.setOptions(gridView2data);
                    gridView2.setOptions({ toolbar: null });
                    gridView2.select("tr:eq(0)");
                }

                var gridView3 = $("#dataGridView3").data("kendoGrid");
                var gridView3data = populateGrid(data.dsResult.table1);
                if (data.dsResult.table1.length > 0) {
                    gridView3.setOptions(gridView3data);
                    gridView3.setOptions({ toolbar: null });
                    gridView3.select("tr:eq(0)");
                }

                var gridView4 = $("#dataGridView4").data("kendoGrid");
                var gridView4data = populateGrid(data.dsResult.table2);
                if (data.dsResult.table2.length > 0) {
                    gridView4.setOptions(gridView4data);
                    gridView4.setOptions({ toolbar: null });
                    gridView4.select("tr:eq(0)");
                }

                var gridView6 = $("#dataGridView6").data("kendoGrid");
                var gridView6data = populateGrid(data.dsResult.table6);
                if (data.dsResult.table6.length > 0) {
                    gridView6.setOptions(gridView6data);
                    gridView6.setOptions({ toolbar: null });
                    gridView6.select("tr:eq(0)");
                }

                var gridView7 = $("#dataGridView7").data("kendoGrid");
                var gridView7data = populateGrid(data.dsResult.table7);
                if (data.dsResult.table7.length > 0) {
                    gridView7.setOptions(gridView7data);
                    gridView7.setOptions({ toolbar: null });
                    gridView7.select("tr:eq(0)");
                }

                var gridView8 = $("#dataGridView8").data("kendoGrid");
                var gridView8data = populateGrid(data.dsResult.table8);
                if (data.dsResult.table8.length > 0) {
                    gridView8.setOptions(gridView8data);
                    gridView8.setOptions({ toolbar: null });
                    gridView8.select("tr:eq(0)");
                }

                var gridMaintenanceFee = $("#dgvMaintenanceFee").data("kendoGrid");
                var gridMaintenanceFeedata = populateGrid(data.dsResult.table5);
                if (data.dsResult.table5.length > 0) {
                    gridMaintenanceFee.setOptions(gridMaintenanceFeedata);
                    gridMaintenanceFee.setOptions({ toolbar: null });
                    gridMaintenanceFee.select("tr:eq(0)");
                }
                var res = subCalcEffectiveDate($("#dateTimePicker4").val(), $("#txtbEffectiveDays").data("kendoNumericTextBox").value());
                res.success(function (data) {
                    var dateEnd = new Date(data.dateEnd);
                    $("#dtpEfektif").val(pad((dateEnd.getDate()), 2) + '/' + pad((dateEnd.getMonth() + 1), 2) + '/' + dateEnd.getFullYear());
                });

                _intType = 0;
                subResetToolBar();
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

function subSave() {
    var selectedId = 0;
    var grid = $("#dgvMaintenanceFee").data("kendoGrid");
    grid.tbody.find("tr[role='row']").each(function () {
        selectedId = selectedId + 1;
    })
    if (selectedId == 0) {
        swal("Warning", "Parameter Maintenance Fee Distribution wajib diisi", "warning");
        return;
    }

    var datePeriodStart = toDate($("#dateTimePicker3").val());
    var datePeriodEnd = toDate($("#dateTimePicker4").val());
    var dateMatureDate = toDate($("#dateTimePicker5").val());
    var dateChangeDate = toDate($("#dateTimePicker1").val());
    var dateValueDate = toDate($("#dateTimePicker2").val());
    var dateDevidenDate = toDate($("#dateTimePicker6").val());

    var dataGridView3 = $("#dataGridView3").data("kendoGrid");
    var dataGridView4 = $("#dataGridView4").data("kendoGrid");
    var dataGridView1 = $("#dataGridView1").data("kendoGrid");
    var dataGridView2 = $("#dataGridView2").data("kendoGrid");
    var dgvMaintenanceFee = $("#dgvMaintenanceFee").data("kendoGrid");

    var model = JSON.stringify({
        'intType': isUpdate ? 2 : 1,
        'intProdId': _intProdId,
        'strProdCode': $("#textBox1").val(),
        'strProdName': $("#textBox2").val(),
        'strProdCCY': $("#CurrencyCode").val(),
        'intTypeId': $("#TypeId").val(),
        'intManInvId': $("#ManInvId").val(),
        'intCustodyId': $("#CustodyId").val(),
        'decNAV': $("#MoneyNAV").data("kendoNumericTextBox").value(),
        'decMinTotalUnit': $("#MoneyCEMinUnit").data("kendoNumericTextBox").value(),
        'decMaxTotalUnit': $("#MoneyCEMaxUnit").data("kendoNumericTextBox").value(),
        'decMaxDailyUnit': $("#MoneyOPMaksUnit").data("kendoNumericTextBox").value(),
        'decMaxDailyCust': $("#textBox7").data("kendoNumericTextBox").value(),
        'dtPeriodStart': datePeriodStart,
        'dtPeriodEnd': datePeriodEnd,
        'dtMatureDate': dateMatureDate,
        'dtChangeDate': dateChangeDate,
        'dtValueDate': dateValueDate,
        'intCloseEndBit': $("#radioButton2").prop('checked') == true ? 1 : 0,
        'isDeviden': $("#checkBox1").prop('checked'),
        'intDevidenPeriod': $("#checkBox1").prop('checked') == true ? $("#textBox12").val() : 0,
        'dtDevidenDate': dateDevidenDate,
        'intCalcId': $("#checkBox1").prop('checked') == true ? $("#CalcDevId").val() : 0,
        'dsNEmployeeSFee': dataGridView3.dataSource.view(),
        'dsEmployeeSFee': dataGridView4.dataSource.view(),
        'decUpFrontFee': $("#textBox3").val() == "" ? 0 : $("#textBox3").data("kendoNumericTextBox").value(),
        'decSubcFeeBased': $("#textBox13").data("kendoNumericTextBox").value(),
        'decRedempFeeBased': $("#textBox15").val() == "" ? 0 : $("#textBox15").data("kendoNumericTextBox").value(),
        'decMaintenanceFee': $("#textBox16").data("kendoNumericTextBox").value(),
        'dsNEmployeeRFee': dataGridView1.dataSource.view(),
        'dsEmployeeRFee': dataGridView2.dataSource.view(),
        'strMIAccountId': $("#MIAccountId").val(),
        'strCTDAccountId': $("#CTDAccountId").val(),
        'intNIK': 0,
        'strGUID': '',
        'dsMaintenanceFee': dgvMaintenanceFee.dataSource.view(),
        'decDevidentPct': $("#checkBox1").prop('checked') == true ? $("#txtbDevidentPct").val() == "" ? 0 : $("#txtbDevidentPct").data("kendoNumericTextBox").value() : 0,
        'intEffectiveAfter': $("#txtbEffectiveDays").data("kendoNumericTextBox").value()
    });
    console.log(model);

    $.ajax({
        type: "POST",
        data: model,
        url: '/Master/MaintainProduct',
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult == true) {
                _intType = 0;
                subResetToolBar();
                swal("Success!", "Simpan Berhasil", "success");
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

function subDelete() {
    swal({
        title: "Information",
        text: "Are you sure to delete this product?",
        type: "info",
        showCancelButton: true,
        confirmButtonClass: 'btn-info',
        confirmButtonText: "Yes",
        closeOnConfirm: false,
        closeOnCancel: false
    },
        function (isConfirm) {
            if (!isConfirm) {
                swal("Canceled", "Delete product canceled", "error");
                return;
            }
            else {
                var dataGridView3 = $("#dataGridView3").data("kendoGrid");
                var dataGridView4 = $("#dataGridView4").data("kendoGrid");
                var dataGridView1 = $("#dataGridView1").data("kendoGrid");
                var dataGridView2 = $("#dataGridView2").data("kendoGrid");
                var dgvMaintenanceFee = $("#dgvMaintenanceFee").data("kendoGrid");

                var model = JSON.stringify({
                    'intType': 3,
                    'intProdId': _intProdId,
                    'strProdCode': '',
                    'strProdName': '',
                    'strProdCCY': '',
                    'intTypeId': 0,
                    'intManInvId': 0,
                    'intCustodyId': 0,
                    'decNAV': 0,
                    'decMinTotalUnit': 0,
                    'decMaxTotalUnit': 0,
                    'decMaxDailyUnit': 0,
                    'decMaxDailyCust': 0,
                    'dtPeriodStart': Today,
                    'dtPeriodEnd': Today,
                    'dtMatureDate': Today,
                    'dtChangeDate': Today,
                    'dtValueDate': Today,
                    'intCloseEndBit': 0,
                    'isDeviden': false,
                    'intDevidenPeriod': 0,
                    'dtDevidenDate': Today,
                    'intCalcId': 0,
                    'dsNEmployeeSFee': dataGridView3.dataSource.view(),
                    'dsEmployeeSFee': dataGridView4.dataSource.view(),
                    'decUpFrontFee': 0,
                    'decSubcFeeBased': 0,
                    'decRedempFeeBased': 0,
                    'decMaintenanceFee': 0,
                    'dsNEmployeeRFee': dataGridView1.dataSource.view(),
                    'dsEmployeeRFee': dataGridView2.dataSource.view(),
                    'strMIAccountId': '',
                    'strCTDAccountId': '',
                    'intNIK': 0,
                    'strGUID': '',
                    'dsMaintenanceFee': dgvMaintenanceFee.dataSource.view(),
                    'decDevidentPct': 0,
                    'intEffectiveAfter': 0
                });
                $.ajax({
                    type: "POST",
                    data: model,
                    url: '/Master/MaintainProduct',
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    beforeSend: function () {
                        $("#load_screen").show();
                    },
                    success: function (data) {
                        if (data.blnResult == true) {
                            $("#ProdCode").val("");
                            $("#ProdName").val("");
                            $("#ProdId").val("");
                            swal("Success", "Product Deleted", "success");
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
            editable: "popup",
            toolbar: ["create"],
            edit: function (e) {
                if (!e.model.isNew()) {
                    // Disable the editor of the "id" column when editing data items
                    var numeric = e.container.find("input[name=fee]").data("kendoNumericTextBox");
                    numeric.enable(false);
                }
            },
            columns: columns,
            selectable: true,
            height: 200
        };
    }
}

function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var fee = name.indexOf("fee") > -1 || name.indexOf("fee") > -1;
        var period = name.indexOf("period") > -1 || name.indexOf("period") > -1;
        var nominal = name.indexOf("nominal") > -1 || name.indexOf("nominal") > -1;
        var aumMin = name.indexOf("aumMin") > -1 || name.indexOf("aumMin") > -1;
        var aumMax = name.indexOf("aumMax") > -1 || name.indexOf("aumMax") > -1;
        var nispPct = name.indexOf("nispPct") > -1 || name.indexOf("nispPct") > -1;
        var fundMgrPct = name.indexOf("fundMgrPct") > -1 || name.indexOf("fundMgrPct") > -1;
        var maintFee = name.indexOf("maintFee") > -1 || name.indexOf("maintFee") > -1;
        var subscriptionFee = name.indexOf("subscriptionFee") > -1 || name.indexOf("subscriptionFee") > -1;
        var redemptFeeAsuransi = name.indexOf("redemptFeeAsuransi") > -1 || name.indexOf("redemptFeeAsuransi") > -1;
        var redemptFeeNonAsuransi = name.indexOf("redemptFeeNonAsuransi") > -1 || name.indexOf("redemptFeeNonAsuransi") > -1;

        return {
            field: name,
            width: maintFee ? 150 : fundMgrPct ? 150 : aumMax ? 120 : aumMin ? 80 : period ? 80 : fee ? 50 : 100,
            title: redemptFeeNonAsuransi ? "Redempt Fee Non Asuransi" : redemptFeeAsuransi ? "Redempt Fee Asuransi" : subscriptionFee ? "Subscription Fee" : maintFee ? "Maintenance Fee" : fundMgrPct ? "Fund Manager Pct" : nispPct ? "Percentage" : aumMax ? "AUM Max" : aumMin ? "AUM Min" : period ? "Period" : nominal ? "Nominal" : fee ? "Fee" : name
        };
    })
}

function SetReadOnly(status) {
    $("#radioButton1").prop('disabled', status);
    $("#radioButton2").prop('disabled', status);
    $("#checkBox1").prop('disabled', status);

    $("#TypeCode").prop('disabled', status); $("#TypeName").prop('disabled', status);
    $("#ManInvCode").prop('disabled', status); $("#ManInvName").prop('disabled', status);
    $("#cmpsrCustody_text1").prop('disabled', status); $("#cmpsrCustody_text2").prop('disabled', status);
    $("#CurrencyCode").prop('disabled', status); $("#CurrencyName").prop('disabled', status);
    // 7 $("#checkBox1").prop('disabled', status); $("#checkBox1").prop('disabled', status);
    // 8 $("#checkBox1").prop('disabled', status); $("#checkBox1").prop('disabled', status);

    if (!status) {
        $("#cmpsrSearch2").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#cmpsrSearch3").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#cmpsrSearch4").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#cmpsrSearch5").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#cmpsrSearch7").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#cmpsrSearch8").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    }
    else {
        $("#cmpsrSearch2").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#cmpsrSearch3").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#cmpsrSearch4").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#cmpsrSearch5").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#cmpsrSearch7").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#cmpsrSearch8").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }

    $("#textBox1").prop('disabled', status);
    $("#textBox2").prop('disabled', status);
    $("#textBox3").prop('disabled', status);
    $("#textBox4").prop('disabled', status);

    //$("#MoneyOPMaksUnit").prop('disabled', status);
    $("#MoneyOPMaksUnit").data("kendoNumericTextBox").enable(!status);
    //$("#MoneyOPMaksPerNas").prop('disabled', status);
    $("#MoneyOPMaksPerNas").data("kendoNumericTextBox").enable(!status);
    //$("#textBox7").prop('disabled', status);
    $("#textBox7").data("kendoNumericTextBox").enable(!status);

    //$("#MoneyNAV").prop('disabled', status);
    $("#MoneyNAV").data("kendoNumericTextBox").enable(!status);

    $("#dateTimePicker1").data("kendoDatePicker").enable(!status);
    $("#dateTimePicker2").data("kendoDatePicker").enable(!status);

    //$("#textBox13").prop('disabled', status);
    //$("#textBox15").prop('disabled', status);
    //$("#textBox16").prop('disabled', status);
    $("#textBox13").data("kendoNumericTextBox").enable(!status);
    $("#textBox15").data("kendoNumericTextBox").enable(!status);
    $("#textBox16").data("kendoNumericTextBox").enable(!status);
    //$("#txtbDevidentPct").prop('disabled', status);
    //$("#txtbEffectiveDays").prop('disabled', status);
    $("#txtbDevidentPct").data("kendoNumericTextBox").enable(!status);
    $("#txtbEffectiveDays").data("kendoNumericTextBox").enable(!status);
    //$("#MoneyCEMinUnit").prop('disabled', status);
    //$("#MoneyCEMaxUnit").prop('disabled', status);
    $("#MoneyCEMinUnit").data("kendoNumericTextBox").enable(!status);
    $("#MoneyCEMaxUnit").data("kendoNumericTextBox").enable(!status);

    $("#dateTimePicker3").data("kendoDatePicker").enable(!status);
    $("#dateTimePicker4").data("kendoDatePicker").enable(!status);
    $("#dateTimePicker5").data("kendoDatePicker").enable(!status);
    $("#dateTimePicker6").data("kendoDatePicker").enable(!status);

    //dataGridView1.Enabled = !status;
    //dataGridView2.Enabled = !status;
    //dataGridView3.Enabled = !status;
    //dataGridView4.Enabled = !status;

    //dgvMaintenanceFee.Enabled = !status;
    //dataGridView5.Enabled = !status;
    $("#txtFundCode").prop('disabled', status);
}

function ResetForm() {
    $("#label27").text("");
    $("#radioButton1").prop('checked', true);
    $("#radioButton2").prop('checked', false);
    $("#checkBox1").prop('checked', false);

    $("#ManInvCode").val(""); $("#ManInvName").val("");
    $("#cmpsrCustody_text1").val(""); $("#cmpsrCustody_text2").val("");
    $("#CurrencyCode").val(""); $("#CurrencyName").val("");

    $("#cmpsrCustody_text1").val(""); $("#cmpsrCustody_text2").val("");
    $("#ManInvCode").val(""); $("#ManInvName").val("");
    $("#cmpsrCustody_text1").val(""); $("#cmpsrCustody_text2").val("");

    $("#textBox1").val("");
    $("#textBox2").val("");
    //$("#textBox3").val("");
    $("#textBox3").data("kendoNumericTextBox").value(0);
    $("#MoneyOPMaksUnit").data("kendoNumericTextBox").value(0);
    $("#MoneyOPMaksNom").data("kendoNumericTextBox").value(0);
    //$("#textBox7").val("");
    $("#textBox7").data("kendoNumericTextBox").value(0);
    $("#MoneyOPMaksPerNas").data("kendoNumericTextBox").value(0);
    //$("#MoneyNAV").val(0);
    $("#MoneyNAV").data("kendoNumericTextBox").value(0);
    
    $("#dateTimePicker1").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#dateTimePicker2").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());

    $("#textBox12").data("kendoNumericTextBox").value(0);
    //$("#textBox13").val("");
    //$("#textBox15").val("");
    //$("#textBox16").val("");
    $("#textBox13").data("kendoNumericTextBox").value(0);
    $("#textBox15").data("kendoNumericTextBox").value(0);
    $("#textBox16").data("kendoNumericTextBox").value(0);
    $("#TypeCode").val(""); $("#TypeName").val("");
    //$("#txtbDevidentPct").val("");
    //$("#txtbEffectiveDays").val("1");
    $("#txtbDevidentPct").data("kendoNumericTextBox").value(0);
    $("#txtbEffectiveDays").data("kendoNumericTextBox").value(1);

    $("#MoneyCEMaxUnit").data("kendoNumericTextBox").value(0);
    $("#MoneyCEMinUnit").data("kendoNumericTextBox").value(0);
    $("#dateTimePicker3").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#dateTimePicker4").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#dateTimePicker5").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#dateTimePicker6").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());

    $("#dataGridView1").empty();
    $("#dataGridView2").empty();
    $("#dataGridView3").empty();
    $("#dataGridView4").empty();

    $("#dgvMaintenanceFee").empty();
}

function subResetToolBar() {
    switch (_intType) {
        case 0:
            {
                $("#btnRefresh").show();
                $("#btnAdd").show();
                $("#btnEdit").show();
                $("#btnDelete").show();
                $("#btnSave").hide();
                $("#btnCancel").hide();
                break;
            }
        case 1:
            {
                $("#btnRefresh").hide();
                $("#btnAdd").hide();
                $("#btnEdit").hide();
                $("#btnDelete").hide();
                $("#btnSave").show();
                $("#btnCancel").show();
                break;
            }
        case 2:
            {
                $("#btnRefresh").hide();
                $("#btnAdd").hide();
                $("#btnEdit").hide();
                $("#btnDelete").hide();
                $("#btnSave").show();
                $("#btnCancel").show();
                break;
            }
    }
}

function ValidateCalcDev(CalcCode, result) {
    if (CalcCode != '') {
        $.ajax({
            type: 'GET',
            url: '/Global/ValidateCalcDev',
            data: { Col1: CalcCode, Col2: '', Validate: 1 },
            success: function (data) {
                if (data.length != 0) {
                    result(data[0].CalcName);
                    $("#CalcDevId").val(data[0].CalcId);
                } else {
                    result('');
                }
            }
        });
    }
    else {
        result('');
    }
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
    else {
        result('');
    }
}

function ValidateCustody(CustCode, result) {
    if (TypeCode != '') {
        $.ajax({
            type: 'GET',
            url: '/Global/ValidateCustody',
            data: { Col1: CustCode, Col2: '', Validate: 1 },
            success: function (data) {
                if (data.length != 0) {
                    result(data[0].CustodyName);
                    $("#CustodyId").val(data[0].CustodyId);
                } else {
                    result('');
                }
            }
        });
    }
    else {
        result('');
    }
}

function ValidateManInv(ManInvCode, result) {
    if (TypeCode != '') {
        $.ajax({
            type: 'GET',
            url: '/Global/ValidateManInv',
            data: { Col1: ManInvCode, Col2: '', Validate: 1 },
            success: function (data) {
                if (data.length != 0) {
                    result(data[0].ManInvName);
                    $("#ManInvId").val(data[0].ManInvId);
                } else {
                    result('');
                }
            }
        });
    }
    else {
        result('');
    }
}

function ValidateTypeReksa(TypeCode, result) {
    if (TypeCode != '') {
        $.ajax({
            type: 'GET',
            url: '/Global/ValidateTypeReksa',
            data: { Col1: TypeCode, Col2: '', Validate: 1 },
            success: function (data) {
                if (data.length != 0) {
                    result(data[0].TypeName);
                    $("#TypeId").val(data[0].TypeId);
                } else {
                    result('');
                }
            }
        });
    }
    else {
        result('');
    }
}

function subCalcEffectiveDate(StartDate, NumDays) {
    return $.ajax({
        type: 'GET',
        url: '/Master/CalcEffectiveDate',
        data: { StartDate: StartDate, NumDays: NumDays }
    });
}

function toDate(dateStr) {
    var [day, month, year] = dateStr.split("/")
    return new Date(year, month - 1, day)
}

function pad(num, size) {
    var s = "000000000" + num;
    return s.substr(s.length - size);
}