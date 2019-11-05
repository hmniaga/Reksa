var treeid;
var treename;
var SelectedTree;
$(document).ready(function () {
    var gridOptions = {
        height: 400
    };
    $("#dataGridView1").kendoGrid(gridOptions);
});

function onSelect(e) {
    SelectedTree = this.dataItem(e.node);
    subPopulateGridMain();
}
function subPopulateGridMain() {
    
    treeid = SelectedTree.id;
    treename = SelectedTree.text;    
    var strPopulate = SelectedTree.spriteCssClass;
    if (treename != 'Authorization') {
        $.ajax({
            type: 'GET',
            url: '/Otorisasi/PopulateGridMainParamFee',
            data: { treename: treename, strPopulate: strPopulate, SelectedId: treeid },
            success: function (data) {
                var grid = $("#dataGridView1").data("kendoGrid");
                if (data.blnResult) {
                    $("#dataGridView1").empty();
                    populateGrid(data.dsResult.table);
                    grid.hideColumn('subsId');
                    $("#dataGridView1 th[data-field=processType]").html("Process Type")
                    $("#dataGridView1 th[data-field=product]").html("Product")
                    $("#dataGridView1 th[data-field=old_MinPercentFeeEmployee]").html("Old Min PercentFee Employee")
                    $("#dataGridView1 th[data-field=new_MinPercentFeeEmployee]").html("New Min PercentFee Employee")
                    $("#dataGridView1 th[data-field=old_MinPercentFeeNonEmployee]").html("Old Min PercentFee Non Employee")
                    $("#dataGridView1 th[data-field=new_MinPercentFeeNonEmployee]").html("New Min PercentFee Non Employee")
                    $("#dataGridView1 th[data-field=old_PembagianFee]").html("Old Pembagian Fee")
                    $("#dataGridView1 th[data-field=new_PembagianFee]").html("New Pembagian Fee")
                    $("#dataGridView1 th[data-field=inputDate]").html("Input Date")
                    $("#dataGridView1 th[data-field=inputter]").html("Inputter")
                    $("#dataGridView1 th[data-field=old_PeriodEfektifMFee]").html("Old Periode Efektif")
                    $("#dataGridView1 th[data-field=new_PeriodEfektifMFee]").html("New Periode Efektif")
                    $("#dataGridView1 th[data-field=old_PercentDefault]").html("Old Percent Default")
                    $("#dataGridView1 th[data-field=new_PercentDefault]").html("New Percent Default")
                    $("#dataGridView1 th[data-field=old_MaxPercentFeeEmployee]").html("Old Max Percent Fee Employee")
                    $("#dataGridView1 th[data-field=new_MaxPercentFeeEmployee]").html("New Max Percent Fee Employee")
                    $("#dataGridView1 th[data-field=old_MaxPercentFeeNonEmployee]").html("Old Max Percent Fee Non Employee")
                    $("#dataGridView1 th[data-field=new_MaxPercentFeeNonEmployee]").html("New Max Percent Fee Non Employee")
                    $("#dataGridView1 th[data-field=old_PercentageSwitchingFee]").html("Old Percentage Switching Fee")
                    $("#dataGridView1 th[data-field=new_PercentageSwitchingFee]").html("New Percentage Switching Fee")
                    
                    
                    
                    
                    
                }
                else {
                    $("#dataGridView1").empty();
                }
            }
        });
    }
}
function populateGrid(response) {
    var columns = generateColumns(response);
    var gridOptions = {
        dataSource: {
            transport: {
                read: function (options) {
                    options.success(response);
                }
            },
            pageSize: 10,
            page: 1
        },
        //change: onRowOtorisasiSelect,
        columns: columns,
        pageable: true,
        selectable: true,
        height: 400
    };

    var grid = $("#dataGridView1").data("kendoGrid");
    if (grid) {
        grid.setOptions(gridOptions);
        grid.select("tr:eq(0)");
    } else {
        $("#dataGridView1").kendoGrid(gridOptions);
    }
}
function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var checkB = name.indexOf("checkB") > -1 || name.indexOf("checkB") > -1;
        var inputDate = name.indexOf("inputDate") > -1 || name.indexOf("inputDate") > -1;
        var old_MinPercentFeeEmployee = name.indexOf("old_MinPercentFeeEmployee") > -1 || name.indexOf("old_MinPercentFeeEmployee") > -1;
        var value = 'subsId';

        return {
            headerTemplate: checkB ? "<input type='checkbox'  id='chkSelectAll' onclick='checkAll(this)' />" : name,
            template: checkB ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (checkB) { #" +
                "checked='checked'" +
                "# } #" +
                "/>"
                : inputDate ? "#= kendo.toString(kendo.parseDate(inputDate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                    : columnNames,
            field: name,
            width: old_MinPercentFeeEmployee ? 250 : checkB ? 50 : 200,
            title: checkB ? "CheckBox" : name
        };
    })
}
function checkAll(e) {
    var state = $(e).is(':checked');
    var grid = $('#dataGridView1').data('kendoGrid');
    $.each(grid.dataSource.view(), function () {
        if (this['checkB'] != state)
            this.dirty = true;

        this['checkB'] = state;
    });
    grid.refresh();
}
function onCheckBoxClick(e) {
    var state = $(e).is(':checked');
    var value = e.value;

    var grid = $('#dataGridView1').data('kendoGrid');
    grid.refresh();

    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.subsId == value) {
            dataItem.checkB = state;
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

$('#button1').click(function () {
    var SubsId;
    var Product;
    var selectedId;

    var grid = $("#dataGridView1").data("kendoGrid");
    grid.refresh();
    var dataItems = "";
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.checkB == true) {
            dataItems += dataItem.subsId + "|";
            Product = dataItem.product;
            SubsId = dataItem.subsId;
            selectedId = selectedId + 1;
        }
    })

    if (selectedId > 1) {
        $(this).attr('data-toggle', '');
        $(this).attr('data-target', '');
        swal("Warning", "Data yang dipilih lebih dari 1!", "warning");
    }
    else if (dataItems == "") {
        $(this).attr('data-toggle', '');
        $(this).attr('data-target', '');
        swal("Warning", "Tidak ada data yang dipilih!", "warning");
    }
    else {
        $(this).attr('data-toggle', 'modal');
        $(this).attr('data-target', '#AuthParamFeeDetailModal');
        var url = "/Otorisasi/AuthParamFeeDetail/?JenisFee=" + SelectedTree.id + "&SubsId=" + SubsId + "&Product=" + Product;
        $(this).attr('href', url);
    }
});
$('#btnRefresh').click(function btnRefresh_click (e) {
    subPopulateGridMain();
});
$('#btnApprove').click(function (e) {
    subApprove(true);
});
$('#btnReject').click(function (e) {
    subApprove(false);
});
function subApprove(isApprove) {
    var grid = $("#dataGridView1").data("kendoGrid");
    grid.refresh();
    var dataItems = "";
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.checkB == true) {
            dataItems += dataItem.subsId + "|";
        }
    })
    if (dataItems == "")
        swal("Warning", "No data selected!", "warning");
    else {
        var message;
        if (isApprove == true)
            message = 'approve';
        else
            message = 'reject';

        swal({
            title: "Are you sure to " + message + " this data?",
            text: "",
            type: "warning",
            showCancelButton: true,
            confirmButtonClass: 'btn-info',
            confirmButtonText: "Yes, " + message + " it!",
            closeOnConfirm: false
        },
            function () {
                $.ajax({
                    type: "POST",
                    url: "/Otorisasi/ApproveReject",
                    data: { listId: dataItems, treeid: treeid, isApprove: isApprove },
                    success: function (data) {
                        if (data.blnResult) {
                            if (isApprove == true) {
                                swal("Approved!", "Your data has been aprroved", "success");
                                subPopulateGridMain();
                            }
                            else {
                                swal("Rejected!", "Your data has been rejected", "success");
                            }
                        } else {
                            swal("Warning", data.ErrMsg, "warning");
                        }
                    }
                });
            });
    }
}