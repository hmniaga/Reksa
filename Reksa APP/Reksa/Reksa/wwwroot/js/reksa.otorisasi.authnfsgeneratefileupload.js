var logId = 0;
var xmlGenerateData;
var sSeparator;
var sFormatFile;
var sFilterFile;
var sFileName;

$(document).ready(function () {
    var grid = {
        height: 300
    };
    $("#dgvPeriod").kendoGrid(grid);
    $("#dgMain").kendoGrid(grid);
    $("#dgDetail").kendoGrid(grid);
    subRefresh();
});

function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/NFSFileCekPendingOtorisasi',
        data: { TypeGet: 'A', LogId: '' },
        success: function (data) {
            if (data.blnResult) {
                var gridView = $("#dgvPeriod").data("kendoGrid");
                var gridData = populateGrid(data.dsResult.table);
                gridView.setOptions(gridData);
                gridView.dataSource.page(1);
                gridView.select("tr:eq(0)");
                $("#dgvPeriod th[data-field=logId]").html("Log Id")
                $("#dgvPeriod th[data-field=period]").html("Period")
                $("#dgvPeriod th[data-field=typeUpload]").html("Type Upload")
            } else {
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
            change: onRowPeriodSelect,
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };
    } else {
        $("#dgvPeriod").empty();
    }
}

function populateGridMain(response) {
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
            change: onRowMainSelect,
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };
    } else {
        $("#dgMain").empty();
    }
}

function populateGridDetail(response) {
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
        $("#dgMain").empty();
    }
}

function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var alamat = name.indexOf("namaPerusahaan") > -1 || name.indexOf("namaPerusahaan") > -1;
        var sid = name.indexOf("sid") > -1 || name.indexOf("sid") > -1;
        var noSIUP = name.indexOf("noSIUP") > -1 || name.indexOf("noSIUP") > -1;
        var alamatPerusahaan = name.indexOf("alamatPerusahaan") > -1 || name.indexOf("alamatPerusahaan") > -1;
        var noSKD = name.indexOf("noSKD") > -1 || name.indexOf("noSKD") > -1;

        return {
            field: name,
            width: alamat ? 300 : sid ? 150 : noSIUP ? 130 : alamatPerusahaan ? 600 : noSKD ? 180 : 100,
            title: name
        };
    })
}

function UpdateFlagApprove(inpLogId) {
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/UpdateFlagApprovalNFSGenerate',
        data: { Type: 'A', LogId: inpLogId },
        success: function (data) {
            if (data.blnResult) {
                //window.location = '/Report/Download?fileGuid=' + data.FileGuid
                //    + '&filename=' + data.FileName;

                swal("Success", "Sukses Generate File Upload.", "success");
                subRefresh();
            } else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}

function subApprove() {
    if (logId == 0) {
        swal("Warning", "Tidak Ada Data Yang di Proses", "warning");
    } else {
        UpdateFlagApprove(logId);
    }
}

function subReject() {
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/UpdateFlagApprovalNFSGenerate',
        data: { Type: 'R', LogId: logId },
        success: function (data) {
            if (data.blnResult) {
                swal("Success", "Berhasil Reject Data Upload", "success");
                subRefresh();
            } else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}