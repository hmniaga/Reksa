var _intType = 0;
var _intStatus = 1;

var Today = new Date();

$(document).ready(function load() {
    CallReksaPopulateValueDate();
    $("#dateTimePicker1").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());

    var grid = {
        height: 250
    };
    $("#dataGridView1").kendoGrid(grid);
    subResetToolBar();
    
});
//button click
$("#btnRefresh").click(function btnRefresh_click() {
    CallReksaPopulateValueDate();
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
    $("#dateTimePicker1").data("kendoDatePicker").enable(false);
});
$("#btnSave").click(function btnSave_click() {
    var grid = $("#dataGridView1").data("kendoGrid");
    grid.refresh();
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);
        if (dataItem.checkB == true) {
            CallReksaMaintainValueDate(dataItem.tranCode, $("#dateTimePicker1").val(), dataItem.tranType);
        }
    })
    _intType = 0;
    subResetToolBar();
    $("#dateTimePicker1").data("kendoDatePicker").enable(false);
    CallReksaPopulateValueDate();
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
function CallReksaPopulateValueDate() {
    $.ajax({
        type: 'GET',
        url: '/PO/PopulateValueDate',
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
                $("#dataGridView1 th[data-field=tranCode]").html("Trancode")
                $("#dataGridView1 th[data-field=tranDate]").html("TranDate")
                $("#dataGridView1 th[data-field=clientCode]").html("Client Code")
                $("#dataGridView1 th[data-field=clientCodeSwitchOut]").html("Client Code Switch Out")
                $("#dataGridView1 th[data-field=clientCodeSwitchIn]").html("Client Code Switch In")
                $("#dataGridView1 th[data-field=prodCode]").html("Product Code")
                $("#dataGridView1 th[data-field=prodCodeSwitchOut]").html("Product Code Switch Out")
                $("#dataGridView1 th[data-field=prodCodeSwitchIn]").html("Product Code Switch In")
                $("#dataGridView1 th[data-field=agentCode]").html("Agent Code")
                $("#dataGridView1 th[data-field=tranDesc]").html("Description")
                $("#dataGridView1 th[data-field=tranCCY]").html("Currency")
                $("#dataGridView1 th[data-field=tranAmt]").html("Tran Amt")
                $("#dataGridView1 th[data-field=cifName]").html("CIF Name")
                $("#dataGridView1 th[data-field=tranUnit]").html("Tran Unit")
                $("#dataGridView1 th[data-field=cifNameSwcOut]").html("CIF Name SwcOut")
                $("#dataGridView1 th[data-field=cifNameSwcIn]").html("CIF Name SwcIn")
                $("#dataGridView1 th[data-field=inputer]").html("Inputter")
                $("#dataGridView1 th[data-field=valueDate]").html("Value Date")
                grid.hideColumn('tranType');
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
function CallReksaMaintainValueDate(TranCode, NewValueDate, TranType) {
    $.ajax({
        type: 'POST',
        url: '/PO/MaintainValueDate',
        data: { TranCode: TranCode, NewValueDate: NewValueDate, TranType: TranType },
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
        var tranDate = name.indexOf("tranDate") > -1 || name.indexOf("tranDate") > -1;
        var valueDate = name.indexOf("valueDate") > -1 || name.indexOf("valueDate") > -1;
        var tranId = name.indexOf("tranId") > -1 || name.indexOf("tranId") > -1;
        var clientCodeSwitchOut = name.indexOf("clientCodeSwitchOut") > -1 || name.indexOf("clientCodeSwitchOut") > -1;
        var tranDesc = name.indexOf("tranDesc") > -1 || name.indexOf("tranDesc") > -1;
        var cifName = name.indexOf("cifName") > -1 || name.indexOf("cifName") > -1;

        var value = 'tranId';
        return {
            headerTemplate: checkB ? "Pilih" : name,
            template: checkB ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (checkB) { #" +
                "checked='checked'" +
                "# } #" +
                "/>"
                : tranDate ? "#= kendo.toString(kendo.parseDate(tranDate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                    : valueDate ? "#= kendo.toString(kendo.parseDate(valueDate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                : columnNames,
            field: name,
            width: checkB ? 50 : tranId ? 70 : tranDate ? 100 : clientCodeSwitchOut ? 180 : tranDesc ? 200 : cifName ? 200 :150,
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
        if (data.clientCode != '') {
            $("#textBox1").val(data.clientCode);
                $("#textBox2").val(data.cifName);
                $("#label1").text('Client Code');
                $("#label2").text('Client Name');
                $("#label4").text('');
                $("#label5").text('');
                $("#textBox4").prop('style', 'display:none;');
                $("#textBox5").prop('style', 'display:none;');
        }
        else
        {
                $("#textBox1").val(data.clientCodeSwitchOut);
                $("#textBox2").val(data.cifNameSwcOut);
                $("#label1").text('ClientCode Switch Out');
                $("#label2").text('ClientName Switch Out');
                $("#label4").text('ClientCode Switch In');
                $("#label5").text('ClientName Switch In');
                $("#textBox4").prop('style', '');
                $("#textBox5").prop('style', '');
            }
            $("#textBox3").val(data.tranCode);
            $("#Money3").data("kendoNumericTextBox").value(data.tranAmt);
            $("#Money4").data("kendoNumericTextBox").value(data.tranUnit);  
            $("#textBox4").val(data.clientCodeSwitchIn);
        $("#textBox5").val(data.cifNameSwcIn);
        var ValueDate = new Date(data.valueDate);
        $("#dateTimePicker2").val(pad((ValueDate.getDate()), 2) + '/' + pad((ValueDate.getMonth() + 1), 2) + '/' + ValueDate.getFullYear());
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