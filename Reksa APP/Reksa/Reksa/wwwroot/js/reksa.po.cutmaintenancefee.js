var today = new Date();
$(document).ready(function () {
    
    $("#dateTimePicker1").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());
    $("#dateTimePicker2").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());

    var grid1 = {
        height: 200
    };
    var grid2 = {
        height: 200
    };
    $("#dataGridViewProduct").kendoGrid(grid1);
    $("#dataGridView1").kendoGrid(grid2);
    PopulateProducts();
});

function PopulateProducts() {
    $.ajax({
        type: 'GET',
        url: '/PO/GetListProducts',
        success: function (data) {
            if (data.blnResult) {
                var grid = $("#dataGridViewProduct").data("kendoGrid");
                var gridViewdata = populateGrid(data.listProduct);
                grid.setOptions(gridViewdata);
                grid.dataSource.pageSize(10);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");
                $("#dataGridViewProduct").data("kendoGrid").hideColumn('ProdId');                
            }
            else {
                $("#dataGridViewProduct").empty();
                swal("Warning", data.ErrMsg, "warning");
            }
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
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };

    } else {
        $("#dataGridViewProduct").empty();
    }
}
function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var isIdColumn = name.indexOf("CheckB") > -1 || name.indexOf("CheckBox") > -1;
        var ProdCode = name.indexOf("ProdCode") > -1 || name.indexOf("ProdCode") > -1;
        var CustodyCode = name.indexOf("CustodyCode") > -1 || name.indexOf("CustodyCode") > -1;
        var ProdName = name.indexOf("ProdName") > -1 || name.indexOf("ProdName") > -1;
        var prodCode = name.indexOf("prodCode") > -1 || name.indexOf("prodCode") > -1;
        var custodyCode = name.indexOf("custodyCode") > -1 || name.indexOf("custodyCode") > -1;
        var billCCY = name.indexOf("billCCY") > -1 || name.indexOf("billCCY") > -1;       
        
        var value;
        value = 'ProdId';
        return {
            headerTemplate: isIdColumn ? "Pilih" : name,
            template: isIdColumn ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (CheckB) { #" +
                "checked='checked'" +
                "# } #" +
                "/>" : columnNames,
            field: name,
            width: isIdColumn ? 50 : ProdCode ? 100 : CustodyCode ? 120 : prodCode ? 120 : custodyCode ? 120 : billCCY ? 100: ProdName ? 350 : 180,
            title: isIdColumn ? "CheckBox" : name
        };
    })
}

function onCheckBoxClick(e) {
    var state = $(e).is(':checked');
    var value = e.value;

    var grid = $('#dataGridViewProduct').data('kendoGrid');
    grid.refresh();

    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.ProdId == value) {
            dataItem.CheckB = state;
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
        if (this['CheckB'] == true) {
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
function pad(num, size) {
    var s = "000000000" + num;
    return s.substr(s.length - size);
}

function ProcessSelectedProducts()
{
    var grid = $("#dataGridViewProduct").data("kendoGrid");
    var gridPreview = $("#dataGridView1").data("kendoGrid");
    var rowsPreview = 0;
    var selectedId = 0;
    var blnValidate = true;

    grid.refresh();
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);
        if (dataItem.CheckB == true) {
            selectedId = selectedId + 1;
        }
    })
    if (selectedId == 0) {
        swal("Warning", "Harap memilih data produk terlebih dahulu!", "warning");
        blnValidate = false;
    }

    gridPreview.refresh();
    gridPreview.tbody.find("tr[role='row']").each(function () {
        rowsPreview = rowsPreview + 1;
    })

    if (rowsPreview == 0) {
        swal("Warning", "Harap memilih file dan melakuan preview terlebih dahulu! ", "warning");
        blnValidate = false;
    }
    if (blnValidate) {
        var model = JSON.stringify({
            'StartDate': $("#dateTimePicker1").val(),
            'EndDate': $("#dateTimePicker2").val(),
            'listPreview': grid.dataSource.view()
        });

        $.ajax({
            type: 'POST',
            url: '/PO/ProsesCutMaintenanceFee',
            data: model,
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            beforeSend: function () {
                $("#load_screen").show();
            },
            success: function (data) {
                if (data.blnResult) {
                    swal("Success", "Proses Cut Maintenance Fee berhasil", "success");
                    subReset();
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
}
function PreviewMaintenanceFee() {
    var grid = $("#dataGridViewProduct").data("kendoGrid");
    grid.refresh();

    var model = JSON.stringify({
        'StartDate': $("#dateTimePicker1").val(),
        'EndDate': $("#dateTimePicker2").val(),
        'listPreview': grid.dataSource.view()
    });

    $.ajax({
        type: 'POST',
        url: '/PO/PreviewMaintenanceFee',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                if (data.dsResult.table.length > 0) {
                    var grid = $("#dataGridView1").data("kendoGrid");
                    var gridData = populateGrid(data.dsResult.table);
                    grid.setOptions(gridData);
                    grid.dataSource.pageSize(10);
                    grid.dataSource.page(1);
                    grid.select("tr:eq(0)");
                    $("#dataGridView1 th[data-field=prodCode]").html("Product Code")
                    $("#dataGridView1 th[data-field=custodyCode]").html("Custody Code")
                    $("#dataGridView1 th[data-field=billCCY]").html("Currency")
                    $("#dataGridView1 th[data-field=totalBill]").html("Total Bill")
                    $("#dataGridView1 th[data-field=fee]").html("Fee")
                    $("#dataGridView1 th[data-field=feeBased]").html("Fee Based")
                    $("#dataGridView1 th[data-field=taxFeeBased]").html("Tax Fee Based")
                    $("#dataGridView1 th[data-field=feeBased3]").html("Fee Based 3")
                    $("#dataGridView1 th[data-field=feeBased4]").html("Fee Based 4")
                    $("#dataGridView1 th[data-field=feeBased5]").html("Fee Based 5")
                }
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
function subReset()
{
    $("#dataGridView1").empty();
    PopulateProducts();
    $("#dateTimePicker2").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());
}