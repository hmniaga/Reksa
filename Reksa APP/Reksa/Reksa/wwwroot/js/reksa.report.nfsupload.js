var Type;
var Code;
$(document).ready(function () {
    var gridOptions = {
        height: 400
    };
    $("#dgvData").kendoGrid(gridOptions);
});


function GenerateFileUpload(sFileCode, iTranDate) {
    $.ajax({
        type: 'POST',
        url: '/Report/NFSGenerateFileUpload',
        data: { FileCode: sFileCode, TranDate: iTranDate },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                window.location = '/Report/Download?fileGuid=' + data.FileGuid
                    + '&filename=' + data.FileName;
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

function SubSave() {
    var grid = $("#dgvData").data("kendoGrid");
    grid.refresh();
    var dataItem = grid.dataSource.view();
    if (dataItem.length == 0) {
        swal("Warning", "Data tidak boleh kosong!", "warning");
        return;
    }

    var sFileCode = $("#cmbFileType").data('kendoDropDownList').value();
    var sFileName = document.getElementById('filename');
    var arr;
    arr = grid.dataSource.view();
    var model = JSON.stringify({
        'FileCode': sFileCode,
        'FileName': sFileName.files[0].name,
        'listKYC': arr,
    });

    $.ajax({
        type: 'POST',
        url: '/Report/NFSGenerateFileDownload',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.blnResult == true) {
                swal("Success", data.ErrMsg, "success");
            } else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });

}

function toDate(dateStr) {
    var [day, month, year] = dateStr.split("/")
    return new Date(year, month - 1, day)
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
            //console.log(data);
        });
        return data;
    };
    return function process_wb(wb) {
        var result = to_json(wb);
        if (result.length == 0) {
            swal("Warning", "No Data Result!!", "warning");
            $("#dgvData").empty();
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
    function handleFile(e) { do_file(e.target.files); }
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
    var grid = $("#dgvData").data("kendoGrid");
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
