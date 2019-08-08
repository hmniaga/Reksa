
var strFileName;

$(document).ready(function () {

    var grid = {
        height: 200
    };
    $("#dgvPreview").kendoGrid(grid);
    $("#dgvUpload").kendoGrid(grid);

    url = "/Global/SearchCustody";
    $('#cmpsrCustody').attr('href', url);

    url = "/Global/SearchProduct";
    $('#cmpsrProduct').attr('href', url);
});

function subUpload() {
    var gridUpload = $("#dgvUpload").data("kendoGrid");
    var gridPreview = $("#dgvPreview").data("kendoGrid");
    var rowsUpload = 0, rowsPreview = 0;
    var blnValidate = true;

    gridUpload.refresh();
    gridUpload.tbody.find("tr[role='row']").each(function () {
            rowsUpload = rowsUpload + 1;
    })
    gridPreview.refresh();
    gridPreview.tbody.find("tr[role='row']").each(function () {
        rowsPreview = rowsPreview + 1;
    })
    if (rowsUpload > 0) {
        swal("Warning", "Sudah diproses! Harap lakukan upload ulang", "warning");
        blnValidate = false;
    }
    if (rowsPreview == 0) {
        swal("Warning", "Harap memilih file dan melakuan preview terlebih dahulu! ", "warning");
        blnValidate = false;
    }
    gridPreview.tbody.find("tr[role='row']").each(function () {
        var dataItem = gridPreview.dataItem(this);
        if (dataItem.remark != null) {
            swal("Warning", "Masih ada data yang tidak sesuai, harap melakukan upload ulang! ", "warning");
            blnValidate = false;
        }
    })

    if (blnValidate) {
        var grid = $("#dgvPreview").data("kendoGrid");
        grid.refresh();

        var model = JSON.stringify({
            'FileName': strFileName,
            'ProdId': $("#ProdId").val(),
            'BankCustody': $("#CustodyId").val(),
            'isRecalculate': 1,
            'listPreview': grid.dataSource.view()
        });

        $.ajax({
            type: 'POST',
            url: '/PO/ImportDataMFee',
            data: model,
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            beforeSend: function () {
                $("#load_screen").show();
            },
            success: function (data) {
                if (data.blnResult) {
                    swal("Success", "Berhasil import data Maintenance Fee, no referensi = " + data.RefId, "success");
                    var grid = $("#dgvUpload").data("kendoGrid");
                    var gridData = populateGrid(data.dsUpload.table);
                    grid.setOptions(gridData);
                    grid.dataSource.pageSize(10);
                    grid.dataSource.page(1);
                    grid.select("tr:eq(0)");
                    $("#dgvPreview th[data-field=tanggalTransaksi]").html("Tanggal Transaksi")
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
    return async function process_wb(wb) {
        var result = to_json(wb);

        if (result.length == 0) {
            swal("Warning", "No Data Result!!", "warning");
            subResetAll();
        }
        else if (result.length > 5) {
            swal("Warning", "Upload tidak bisa dilakukan karena format file salah!", "warning");
            subResetAll();
        }
        else if (Object.keys(result[0])[0] != "TanggalTransaksi" || Object.keys(result[0])[1] != "ReverseTanggalTransaksi" || Object.keys(result[0])[2] != "ProductCode" || Object.keys(result[0])[3] != "ClientCode" || Object.keys(result[0])[4] != "OutstandingUnit" || Object.keys(result[0])[5] != "NAV")
        {
            swal("Warning", "Format excel salah!", "warning");
            subResetAll();
        }        
        else
        {
            var grid = $("#dgvPreview").data("kendoGrid");
            var data = await RecalculateMFee($("#ProdId").val(), $("#CustodyId").val(), result);
            if (data.blnResult) {
                var gridData = populateGrid(data.dsUpload.table);
                grid.setOptions(gridData);
                grid.dataSource.pageSize(10);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");
                grid.hideColumn('productCode');
                grid.hideColumn('pembagiHariMFee');
                grid.hideColumn('prodId');
                grid.hideColumn('clientId');
                $("#dgvPreview th[data-field=tanggalTransaksi]").html("Tanggal Transaksi")
                $("#dgvPreview th[data-field=reverseTanggalTransaksi]").html("Reverse Tanggal Transaksi")
                $("#dgvPreview th[data-field=clientCode]").html("Client Code")
                $("#dgvPreview th[data-field=outstandingUnit]").html("Outstanding Unit")
                $("#dgvPreview th[data-field=nav]").html("NAV")
                $("#dgvPreview th[data-field=nominalMaintenanceFee]").html("Nominal Maintenance Fee")
                $("#dgvPreview th[data-field=remark]").html("Remark")
                $("#dgvPreview th[data-field=outstandingDate]").html("Outstanding Date")
                $("#dgvPreview th[data-field=navDate]").html("NAV Date")
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    };
})();

function subResetAll() {
    $("#dgvPreview").empty();
    $("#dgvUpload").empty();
}

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
        if ($("#cmpsrCustody_text2").val() == "") {
            swal("Warning", "Harap pilih custody terlebih dahulu", "warning");
        }
        else if ($("#cmpsrProduct_text2").val() == "") {
            swal("Warning", "Harap pilih produk terlebih dahulu", "warning");
        }
        else {
            do_file(e.target.files);
            strFileName = e.target.files[0].name;
        }
    }
        xlf.addEventListener('change', handleFile, false);

})();

// add the grid options here 
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
            //change: dataGridView1_Click,
            //databound: onBounddataGridView1,
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };
    }
}

function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var tanggalTransaksi = name.indexOf("tanggalTransaksi") > -1 || name.indexOf("tanggalTransaksi") > -1;
        var reverseTanggalTransaksi = name.indexOf("reverseTanggalTransaksi") > -1 || name.indexOf("reverseTanggalTransaksi") > -1;
        return {
            template: tanggalTransaksi ? "#= kendo.toString(kendo.parseDate(tanggalTransaksi, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                : reverseTanggalTransaksi ? "#= kendo.toString(kendo.parseDate(reverseTanggalTransaksi, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                    : columnNames,
            field: name,
            width: 200,
            title: name
        };
    })
}

function RecalculateMFee(ProdId, BankCustody, dsPreview) {
    var model = JSON.stringify({
        'ProdId': ProdId,
        'BankCustody': BankCustody,
        'listPreview': dsPreview
    });
    return new Promise((resolve, reject) => {
        $.ajax({
            type: 'POST',
            url: '/PO/RecalcMFee',
            data: model,
            dataType: "json",
            contentType: "application/json; charset=utf-8",  
            beforeSend: function () {
                $("#load_screen").show();
            },
            success: function (data) {
                resolve({
                    blnResult: data.blnResult,
                    ErrMsg: data.ErrMsg,
                    dsUpload: data.dsUpload
                })
            },
            error: reject,
            complete: function () {
                $("#load_screen").hide();
            }
        })
    })
}

