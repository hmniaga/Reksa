$(document).ready(function () {
    var grid = {
        height: 200
    };
    $("#dataGridView1").kendoGrid(grid);
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
            //console.log(data);
        });
        return data;
    };
    return function process_wb(wb) {
        var result = to_json(wb);
        if (result.length == 0) {
            swal("Warning", "No Data Result!!", "warning");
            $("#dataGridView1").empty();
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
    var grid = $("#dataGridView1").data("kendoGrid");
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