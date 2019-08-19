$(document).ready(function () {
    var grid = {
        height: 200
    };
    $("#dgvPreview").kendoGrid(grid);
    $("#dgvUpload").kendoGrid(grid);
});

var X = XLSX;
var process_wb = (function () {
    var to_json = function to_json(workbook) {
        var data = [];
        workbook.SheetNames.forEach(function (y) {
            var worksheet = workbook.Sheets[y];
            var headers = {};
            for (z in worksheet) {
                if (z[0] === '!') continue;
                //parse out the column, row, and value
                var tt = 0;
                for (var i = 0; i < z.length; i++) {
                    if (!isNaN(z[i])) {
                        tt = i;
                        break;
                    }
                };
                var col = z.substring(0, tt);
                var row = parseInt(z.substring(tt));
                var value = worksheet[z].v;

                //store header names
                if (row == 1 && value) {
                    headers[col] = value;
                    continue;
                }

                if (!data[row]) data[row] = {};
                data[row][headers[col]] = value;
            }
            //drop those first two rows which are empty
            data.shift();
            data.shift();
        });
        return data;
    };
    return function process_wb(wb) {
        var result = to_json(wb);
        if (result.length == 0) {
            swal("Warning", "No Data Result!!", "warning");
            $("#dgvPreview").empty();
        }
        else {
            populateGrid(result);
        }
    };
})();

var do_file = (function () {
    return function do_file(files) {
        var f = files[0];
        var reader = new FileReader();
        reader.onload = function (e) {
            var data = e.target.result;
            data = new Uint8Array(data);
            process_wb(X.read(data, { type: 'array' }));
        };
        reader.readAsArrayBuffer(f);
    };
})();

(function () {
    var xlf = document.getElementById('filename');
    if (!xlf.addEventListener) return;
    function handleFile(e) {
        if ($("#cmpsrCustody_text1").val() == "") {
            swal("Warning", "Bank Custody tidak diisi", "warning");
        }
        else if ($("#txtbDelimiter").val() == "") {
            swal("Warning", "Delimiter tidak diisi", "warning");
        }
        else {
            var strFileExt = $("#txtbPath").val().substring($("#txtbPath").val().length - 3, $("#txtbPath").val().length).toUpperCase();
            do_file(e.target.files);
        }        
    }
    xlf.addEventListener('change', handleFile, false);
})();

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
        columns: columns,
        pageable: true,
        selectable: true,
        height: 400
    };
    // reuse the same grid, swapping its options as needed
    var grid = $("#dgvPreview").data("kendoGrid");
    if (grid) {
        grid.setOptions(gridOptions);
        grid.select("tr:eq(0)");
        var JumlahBaris = 0, Nominal = 0, Unit = 0;
        grid.tbody.find("tr[role='row']").each(function () {
            var dataItem = grid.dataItem(this);
            JumlahBaris = JumlahBaris + 1;
            Nominal = Nominal + dataItem.Nominal;
            Unit = Unit + dataItem.Unit;
        })
        if ($("#cmbTipe").data("kendoDropDownList").text() == "Sinkronisasi Transaksi") {
            swal("Information", "Total Row yang diupload : " + parseFloat(JumlahBaris).toLocaleString('en') + " \n" +
                "Total Nominal Transaksi yang diupload : " + parseFloat(Nominal).toLocaleString('en') + " \n" +
                "Total Unit Transaksi yang diupload : " + parseFloat(Unit).toLocaleString('en'), "info");
        } else if ($("#cmbTipe").data("kendoDropDownList").text() == "Sinkronisasi OS By Shareholder ID") {
            swal("Information", "Total Row yang diupload : " + parseFloat(JumlahBaris).toLocaleString('en') + " \n" +
                "Total Ending Balance yang diupload : " + parseFloat(Unit).toLocaleString('en'), "info");
        }
        else if ($("#cmbTipe").data("kendoDropDownList").text() == "Sinkronisasi OS By Client Code") {
            swal("Information", "Total Row yang diupload : " + parseFloat(JumlahBaris).toLocaleString('en') + " \n" +
                "Total Ending Balance yang diupload : " + parseFloat(Unit).toLocaleString('en'), "info");
        }
    } else {
        $("#dgvPreview").kendoGrid(gridOptions);
    }
}

function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        return {
            field: name,
            width: 200,
            title: name
        };
    })
}

function subUpload() {
    var rowsPreview = 0, rowsUpload = 0; 
    var gridPreview = $("#dgvPreview").data("kendoGrid");
    var gridUpload = $("#dgvUpload").data("kendoGrid");
    gridPreview.refresh();
    gridPreview.tbody.find("tr[role='row']").each(function () {
        rowsPreview = rowsPreview + 1;
    })
    gridUpload.refresh();
    gridUpload.tbody.find("tr[role='row']").each(function () {
        rowsUpload = rowsUpload + 1;
    })
    if (rowsPreview == 0) {
        swal('Warning', 'Harap melakukan preview data terlebih dahulu!', 'warning');
        return;
    }
    if (rowsUpload != 0) {
        swal('Warning', 'Upload sudah berhasil dilakukan, harap lakukan upload file baru!', 'warning');
        return;
    }

    var TableNames, cmbType;
    var grid = $("#dgvPreview").data("kendoGrid");
    var arrSyncTrx = [];
    var arrSyncOSUnitShareholderID = [];
    var arrSyncOSUnitClientCode = [];

    if ($("#cmbTipe").data("kendoDropDownList").text() == "Sinkronisasi Transaksi") {
        TableNames = "Transaksi";
        arrSyncTrx = grid.dataSource.view();
        cmbType = 1;
    } else if ($("#cmbTipe").data("kendoDropDownList").text() == "Sinkronisasi OS By Shareholder ID") {
        TableNames = "OSUnitShareholderID";
        arrSyncOSUnitShareholderID = grid.dataSource.view();
        cmbType = 2;
    }
    else if ($("#cmbTipe").data("kendoDropDownList").text() == "Sinkronisasi OS By Client Code") {
        TableNames = "OSUnitClientCode";
        arrSyncOSUnitClientCode = grid.dataSource.view();
        cmbType = 3;
    }
    var sFileName = document.getElementById('txtbPath');
    var [day, month, year] = $("#dtSyncDate").val().split("/")
    var intPeriod = year + month + day;
    
    var model = JSON.stringify({
        'Type': cmbType,
        'BankCustody': $("#CustodyId").val(),
        'Period': intPeriod,
        'FileName': sFileName.files[0].name,
        'NIK': 0,
        'TableNames': TableNames,
        'listTransaksi': arrSyncTrx,
        'listOSUnitShareholderID': arrSyncOSUnitShareholderID,
        'listOSUnitClientCode': arrSyncOSUnitClientCode
    });

    $.ajax({
        type: "POST",
        data: model,
        url: '/PO/ImportData',
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult == true) {
                var grid = $("#dgvUpload").data("kendoGrid");
                var gridData = populateGridUpload(data.dsResult.table);
                grid.setOptions(gridData);
                grid.dataSource.pageSize(10);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");
                $("#dgvUpload th[data-field=refId]").html("RefID")
                $("#dgvUpload th[data-field=batchGuid]").html("Batch GUID")
                $("#dgvUpload th[data-field=period]").html("Period")
                $("#dgvUpload th[data-field=fileName]").html("FileName")
                $("#dgvUpload th[data-field=numOfRecord]").html("Num Of Record")
                swal("Success", "Berhasil import data " + $("#cmbTipe").data("kendoDropDownList").text() + ", no referensi = " + data.strRefID, "success");
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
function populateGridUpload(response) {
    if (response.length > 0) {
        var columns = generateColumnsUpload(response);
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
            //change: dataGridView1_Click,
            //databound: onBounddataGridView1,
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };
    } else {
        $("#dgvUpload").empty();
    }
}
function generateColumnsUpload(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var refId = name.indexOf("refId") > -1 || name.indexOf("refId") > -1;
        var batchGuid = name.indexOf("batchGuid") > -1 || name.indexOf("batchGuid") > -1;
        var fileName = name.indexOf("fileName") > -1 || name.indexOf("fileName") > -1;
        return {
            field: name,
            width: refId ? 80 : batchGuid ? 300 : fileName? 250: 150,
            title: name
        };
    })
}
function subResetAll(i)
{
    if (i == 0) {
        $("#cmpsrCustody_text1").val('');
        $("#cmpsrCustody_text2").val('');
    }
    Today = new Date();
    $("#dtSyncDate").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#txtbDelimiter").val(";");
    $("#dgvPreview").empty();
    $("#dgvUpload").empty();
}
function pad(num, size) {
    var s = "000000000" + num;
    return s.substr(s.length - size);
}