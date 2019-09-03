var treeid;
var treename;
var _selectedTree;

$(document).ready(function load () {
    var gridOptions = {
        height: 170
    };    
    $("#dgDetail").kendoGrid(gridOptions);
    $("#dataGridView1").kendoGrid(gridOptions);
    var gridOptions = {
        height: 300
    };
    $("#dgMain").kendoGrid(gridOptions);    
});

function subAcceptReject(isApprove) {
    var grid = $("#dgMain").data("kendoGrid");
    grid.refresh();
    var dataItems = "";
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.checkB == true) {
            dataItems += dataItem.refId + "|";            
        }
    })
    if (dataItems == "") {
        swal("Warning", "No data selected!", "warning");
        return;
    }
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
            confirmButtonText: "Yes, " + message + " it!"
        },
            function Confirm() {
                $.ajax({
                    type: "POST",
                    url: "/Otorisasi/ApproveReject",
                    data: { listId: dataItems, treeid: treeid, isApprove: isApprove },
                    beforeSend: function () {
                        $("#load_screen").show();
                    },
                    success: function (data) {
                        if (data.blnResult) {
                            if (isApprove == true) {
                                subPopulateGridMain();
                                setTimeout(function () { swal("Approved!", "Your data has been aprroved", "success") }, 500); 
                            }
                            else {
                                setTimeout(function () { swal("Rejected!", "Your data has been rejected", "success") }, 500); 
                                subPopulateGridMain();
                            }
                        } else {
                            setTimeout(function () { swal("Warning", data.ErrMsg, "warning") }, 500); 
                            subPopulateGridMain();
                        }
                    },
                    complete: function () {
                        $("#load_screen").hide();
                    }
                });

            });
    }
}

function subPopulateGridMain() {
    var strPopulate = _selectedTree.spriteCssClass;
    var SelectedId = '';
    if (treename != 'Authorization') {
        $.ajax({
            type: 'GET',
            url: '/Otorisasi/PopulateGridMain',
            data: { treename: treename, strPopulate: strPopulate, SelectedId: SelectedId },
            beforeSend: function () {
                $("#load_screen").show();
            },
            success: function (data) {
                if (data.blnResult) {
                    $("#dataGridView1").empty();
                    var grid = $("#dgMain").data("kendoGrid");
                    var gridData = populateGrid(data.dsResult.table);
                    grid.setOptions(gridData);
                    grid.dataSource.pageSize(10);
                    grid.dataSource.page(1);
                    grid.select("tr:eq(0)");

                    $("#dgMain th[data-field=batchGuid]").html("Batch Guid")
                    $("#dgMain th[data-field=refId]").html("Ref Id")
                    $("#dgMain th[data-field=navValueDate]").html("NAV Value Date")
                    $("#dgMain th[data-field=fileName]").html("FileName")
                    $("#dgMain th[data-field=uploadedRecords]").html("Uploaded Records")
                    $("#dgMain th[data-field=lastUser]").html("Last User")
                    $("#dgMain th[data-field=prodId]").html("Prod Id")
                    $("#dgMain th[data-field=prodName]").html("Prod Name")
                    $("#dgMain th[data-field=currentNAV]").html("Prod Name")
                    $("#dgMain th[data-field=updateNAV]").html("Update NAV")
                    $("#dgMain th[data-field=devidentDate]").html("Devident Date")
                    $("#dgMain th[data-field=devidentAmount]").html("Devident Amount")
                    $("#dgMain th[data-field=hargaUnitPerHari]").html("Harga Unit Per Hari")
                    $("#dgMain th[data-field=lastUpdate]").html("Last Update")
                    $("#dgMain th[data-field=batchRefId]").html("Batch Ref Id")
                    $("#dgMain th[data-field=syncDesc]").html("Description")
                    $("#dgMain th[data-field=tranCode]").html("Tran Code")
                    $("#dgMain th[data-field=tranType]").html("Tran Type")
                    $("#dgMain th[data-field=prodCode]").html("Prod Code")
                    $("#dgMain th[data-field=clientCode]").html("Client Code") 
                    $("#dgMain th[data-field=cifName]").html("CIF Name")
                    $("#dgMain th[data-field=tranCCY]").html("Currency")
                    $("#dgMain th[data-field=tranAmt]").html("Transaksi Amount")
                    $("#dgMain th[data-field=custodyNominal]").html("Custody Nominal")
                    $("#dgMain th[data-field=tranUnit]").html("Tran Unit")
                    $("#dgMain th[data-field=custodyUnit]").html("Custody Unit")
                    $("#dgMain th[data-field=nav]").html("NAV")
                }
                else {
                    swal("Warning", data.ErrMsg, "warning");
                    $("#dgMain").empty();
                    $("#dgDetail").empty();
                    $("#dataGridView1").empty();
                }
            },
            complete: function () {
                $("#load_screen").hide();
            }
        });
    }
}

function subPopulateDetailGrid(rawData) {
    var rawData,
        data = [],
        dataLength,
        propertiesLength;
    dataLength = 2;
    propertiesLength = Object.keys(rawData).length;
    for (var i = 0; i < propertiesLength; i += 1) {

        data[i] = {};
        for (var j = 0; j < dataLength; j += 1) {
            var currentItem = rawData;
            var Items = Object.keys(currentItem)[i];

            if (j === 0) {
                data[i]["Items"] = Items;
            }
            data[i]["Values"] = currentItem[Items]
        }

    }

    var Datagrid = {
        dataSource: {
            data: data
        },
        columns: [
            { field: "Items", title: "Items" },
            { field: "Values", title: "Values" }
        ],
        pageable: true,
        selectable: true,
        height: 170
    };

    $("#dgDetail").kendoGrid(Datagrid);
    var grid = $("#dgDetail").data("kendoGrid");
    var items = grid.dataSource.view();
    for (var i = 0; i < items.length; i++) {
        var $row = $('#dgDetail').find("[data-uid='" + items[i].uid + "']");
        if (items[i].Items == "_events" || items[i].Items == "_handlers" || items[i].Items == "checkB"
            || items[i].Items == "uid" || items[i].Items == "parent") { // hide this row ...
            $row.hide();
        }
    }
}

function subPopulateDetailItem(BatchGuid) {
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/PopulateDetailItem',
        data: { BatchGuid: BatchGuid },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                var grid = $("#dataGridView1").data("kendoGrid");
                var gridData = populateGridView1(data.dsResult.table);
                grid.setOptions(gridData);
                grid.dataSource.pageSize(10);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");

                $("#dataGridView1 th[data-field=clientCode]").html("Client Code")
                $("#dataGridView1 th[data-field=outstandingUnitProReksa]").html("Outstanding Unit Pro Reksa")
                $("#dataGridView1 th[data-field=outstandingUnitBankCustody]").html("Outstanding Unit Bank Custody")
                $("#dataGridView1 th[data-field=selisih]").html("Selisih")
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
                $("#dataGridView1").empty();
            }
        },
        complete: function () {
            $("#load_screen").hide();
        }
    });
}

function subPopulateDetailMFee(BatchGuid) {
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/PopulateDetailMFee',
        data: { BatchGuid: BatchGuid },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                var grid = $("#dataGridView1").data("kendoGrid");
                var gridData = populateGridView1(data.dsResult.table);
                grid.setOptions(gridData);
                grid.dataSource.pageSize(10);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");

                $("#dataGridView1 th[data-field=clientCode]").html("Client Code")
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
                $("#dataGridView1").empty();
            }
        },
        complete: function () {
            $("#load_screen").hide();
        }
    });
}

function subPopulateDetailOSSHID(BatchGuid){
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/PopulateDetailOSSHID',
        data: { BatchGuid: BatchGuid },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                var grid = $("#dataGridView1").data("kendoGrid");
                var gridData = populateGridView1(data.dsResult.table);
                grid.setOptions(gridData);
                grid.dataSource.pageSize(10);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");

                $("#dataGridView1 th[data-field=clientCode]").html("Client Code")
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
                $("#dataGridView1").empty();
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
                pageSize: 10,
                page: 1
            },
            change: dgMain_CellClick,
            databound: onBounddgMain,
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };
    }
}

function populateGridView1(response) {
    if (response.length > 0) {
        var columns = generateColumns(response);
        return gridOptions = {
            dataSource: {
                transport: {
                    read: function (options) {
                        options.success(response);
                    }
                },
                pageSize: 10,
                page: 1
            },
            columns: columns,
            pageable: true,
            selectable: true,
            height: 170
        };
    }
}

function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var isIdColumn = name.indexOf("checkB") > -1 || name.indexOf("CheckBox") > -1;
        var tanggalValuta = name.indexOf("tanggalValuta") > -1 || name.indexOf("tanggalValuta") > -1;
        var navValueDate = name.indexOf("navValueDate") > -1 || name.indexOf("navValueDate") > -1;
        var dateInput = name.indexOf("dateInput") > -1 || name.indexOf("dateInput") > -1;
        var fileName = name.indexOf("fileName") > -1 || name.indexOf("fileName") > -1;
        var batchGuid = name.indexOf("batchGuid") > -1 || name.indexOf("batchGuid") > -1;
        var refId = name.indexOf("refId") > -1 || name.indexOf("refId") > -1;
        var outstandingUnitBankCustody = name.indexOf("outstandingUnitBankCustody") > -1 || name.indexOf("outstandingUnitBankCustody") > -1;
        var tanggalTransaksi = name.indexOf("tanggalTransaksi") > -1 || name.indexOf("tanggalTransaksi") > -1;
        var reverseTanggalTransaksi = name.indexOf("reverseTanggalTransaksi") > -1 || name.indexOf("reverseTanggalTransaksi") > -1;
        var devidentDate = name.indexOf("devidentDate") > -1 || name.indexOf("devidentDate") > -1;
        var lastUpdate = name.indexOf("lastUpdate") > -1 || name.indexOf("lastUpdate") > -1;
        var nominalMaintenanceFeeBefore = name.indexOf("nominalMaintenanceFeeBefore") > -1 || name.indexOf("nominalMaintenanceFeeBefore") > -1;
        var nominalMaintenanceFeeAfter = name.indexOf("nominalMaintenanceFeeAfter") > -1 || name.indexOf("nominalMaintenanceFeeAfter") > -1;

        var value;
        value = 'refId';
        return {
            headerTemplate: isIdColumn ? "<input type='checkbox'  id='chkSelectAll' onclick='checkAll(this)' />" : name,
            template: isIdColumn ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (checkB) { #" +
                "checked='checked'" +
                "# } #" +
                "/>"
                : tanggalValuta ? "#= kendo.toString(kendo.parseDate(tanggalValuta, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                    : navValueDate ? "#= kendo.toString(kendo.parseDate(navValueDate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                        : dateInput ? "#= kendo.toString(kendo.parseDate(dateInput, 'yyyy-MM-dd'), 'dd/MM/yyyy HH:mm:ss') #"
                            : tanggalTransaksi ? "#= kendo.toString(kendo.parseDate(tanggalTransaksi, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                                : reverseTanggalTransaksi ? "#= kendo.toString(kendo.parseDate(reverseTanggalTransaksi, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                                    : devidentDate ? "#= kendo.toString(kendo.parseDate(devidentDate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                                        : lastUpdate ? "#= kendo.toString(kendo.parseDate(lastUpdate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                                            : columnNames,
            field: name,
            width: isIdColumn ? 50 : fileName ? 600 : batchGuid ? 300 : refId ? 80 : navValueDate ? 150 : outstandingUnitBankCustody ? 250 : nominalMaintenanceFeeBefore ? 250 : nominalMaintenanceFeeAfter? 250 : 200,
            title: isIdColumn ? "CheckBox" : name
        };
    })
}