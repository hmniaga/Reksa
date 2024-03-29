﻿var _intType = 0;
var _intStatus = 1;
$(document).ready(function load() {
    var grid = {
        height: 250
    };
    $("#dataGridView1").kendoGrid(grid);
    subResetToolBar();
    CallReksaPopulateRedemptDate();
});
//button click
$("#btnRefresh").click(function btnRefresh_click() {
    CallReksaPopulateRedemptDate();
});
$("#btnCancel").click(function btnCancel_click() {
    _intType = 0;
    subResetToolBar();
    $("#dateTimePicker1").data("kendoDatePicker").enable(false);
    _intStatus = 1;
});
$("#btnEdit").click(function btnEdit_click() {
    _intStatus = 0;
    _intType = 1;
    subResetToolBar();
    $("#dateTimePicker1").data("kendoDatePicker").enable(true);
});
$("#btnSave").click(function btnSave_click() {
    var grid = $("#dataGridView1").data("kendoGrid");
    grid.refresh();
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);
        if (dataItem.checkB == true) {
            callReksaMaintainSettleDate(dataItem.tranId, $("#dateTimePicker1").val());
        }
    })
    _intType = 0;
    subResetToolBar();
    $("#dateTimePicker1").data("kendoDatePicker").enable(false);
    CallReksaPopulateRedemptDate();
    _intStatus = 1;
});
function subResetToolBar() {
    switch (_intType) {
        case 0:
            {
                $("#btnRefresh").show();
                $("#btnEdit").show();
                $("#btnSave").hide();
                $("#btnCancel").hide();
                break;
            }
        case 1:
            {
                $("#btnRefresh").hide();
                $("#btnEdit").hide();
                $("#btnSave").show();
                $("#btnCancel").show();

                break;
            }
    }
}
function CallReksaPopulateRedemptDate() {
    $.ajax({
        type: 'GET',
        url: '/PO/PopulateRedemptDate',
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
                $("#dataGridView1 th[data-field=tranId]").html("Tran Id")
                $("#dataGridView1 th[data-field=clientCode]").html("Client Code")
                $("#dataGridView1 th[data-field=prodCode]").html("Product Code")
                $("#dataGridView1 th[data-field=agentCode]").html("Agent Code")
                $("#dataGridView1 th[data-field=tranDesc]").html("Description")
                $("#dataGridView1 th[data-field=tranCCY]").html("Currency")
                $("#dataGridView1 th[data-field=tranAmt]").html("Tran Amt")
                $("#dataGridView1 th[data-field=cifName]").html("CIF Name")
                $("#dataGridView1 th[data-field=tranCode]").html("Trancode")
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
function callReksaMaintainSettleDate(TranId, NewSettleDate) {
    $.ajax({
        type: 'POST',
        url: '/PO/MaintainSettleDate',
        data: { TranId: TranId, NewSettleDate: NewSettleDate },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                swal("Success", "Simpan berhasil", "success");
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
        var checkB = name.indexOf("checkB") > -1 || name.indexOf("checkB") > -1;
        var goodFund = name.indexOf("goodFund") > -1 || name.indexOf("goodFund") > -1;
        var value = 'tranId';
        return {
            headerTemplate: checkB ? "Pilih" : name,
            template: checkB ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (checkB) { #" +
                "checked='checked'" +
                "# } #" +
                "/>"
                : goodFund ? "#= kendo.toString(kendo.parseDate(goodFund, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                : columnNames,
            field: name,
            width: checkB ? 50 : 150,
            title: name
        };
    })
}
function onCheckBoxClick(e) {
    var state = $(e).is(':checked');
    var value = e.value;

    var grid = $('#dataGridView1').data('kendoGrid');
    grid.refresh();

    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.tranId == value) {
            dataItem.checkB = state;
            if (state) {
                grid.select("tr:eq(value)");
            }
        }
    })
    var chkAll = $('#chkSelectAll').is(':checked');
    var isCheckedAll = true;
    var countTrue = 0;
    var countFalse = 0;
    var countAll = 0;

    $.each(grid.dataSource.view(), function () {
        if (this['checkB'] == true) {
            countTrue = countTrue + 1;
        }
        else {
            countFalse = countFalse + 1;
            isCheckedAll = false;
        }
        countAll = countAll + 1;
    });
    if (countFalse == 0 || (countFalse == 1 && !state)) {
        $('#chkSelectAll').prop("checked", state);
    }
    grid.refresh();
}
function dataGridView1_Click() {
    var data = this.dataItem(this.select());
    if (_intStatus == 1) {
        $("#textBox1").val(data.clientCode);
        $("#textBox2").val(data.cIFName);
        $("#textBox3").val(data.tranCode);
        $("#Money1").data("kendoNumericTextBox").value(data.tranAmt);
        $("#Money2").data("kendoNumericTextBox").value(data.tranUnit);
        var GoodFund = new Date(data.goodFund);
        $("#dateTimePicker1").val(pad((GoodFund.getDate()), 2) + '/' + pad((GoodFund.getMonth() + 1), 2) + '/' + GoodFund.getFullYear());
    }
}
function onBounddataGridView1() {
    var grid = $("#dataGridView1").data("kendoGrid");
    var len = grid.dataSource.data().length;

    if (len > 0) {
        grid.select(0);
    }
}
function pad(num, size) {
    var s = "000000000" + num;
    return s.substr(s.length - size);
}