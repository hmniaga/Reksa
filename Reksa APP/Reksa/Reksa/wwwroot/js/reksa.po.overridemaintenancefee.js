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

    //click
    $("#btnUpload").click(function () {
        subUpload();
    });
});

function subUpload() {
    var FileName;
    var ProdId $("#ProdId").val();
    var BankCustody = $("#CustodyId").val();
    $.ajax({
        type: 'POST',
        url: '/PO/ImportDataMFee',
        data: { FileName: FileName, ProdId: ProdId, BankCustody, isRecalculate:0 },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                swal("Success", "Data berhasil di edit", "success");
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
            subResetAll();
        }
        else if (result.length > 5) {
            swal("Warning", "Upload tidak bisa dilakukan karena format file salah!", "warning");
            subResetAll();
        }
        else if (Object.keys(result[0])[0] != "TanggalTransaksi" || Object.keys(result[0])[1] != "ReverseTanggalTransaksi" || Object.keys(result[0])[2] != "ClientCode" || Object.keys(result[0])[3] != "NominalMaintenanceFee")
        {
            swal("Warning", "Format excel salah!", "warning");
            subResetAll();
        }        
        else
        {
            populateGrid(result);
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
        }
    }
        xlf.addEventListener('change', handleFile, false);

})();

// add the grid options here 
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
    } else {
        $("#dgvData").kendoGrid(gridOptions);
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