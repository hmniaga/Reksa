
$(document).ready(function () {
    var grid = {
        height: 400
    };
    $("#dataGridView1").kendoGrid(grid);
    PopulateData();
});
function PopulateData() {
    $.ajax({
        type: 'GET',
        url: '/PO/PopulateSubscriptionLimitAlert',
        success: function (data) {
            if (data.blnResult) {
                var grid = $("#dataGridView1").data("kendoGrid");

                var gridData = populateGrid(data.dsResult.table);
                grid.setOptions(gridData);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");
                $("#dataGridView1 th[data-field=productName]").html("Product Name")
                $("#dataGridView1 th[data-field=currency]").html("Currency")
                $("#dataGridView1 th[data-field=limit]").html("Limit")
            }
            else {
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
                pageSize: 6,
                page: 1
            },
            //change: onRowKinerjaSelect,
            columns: columns,
            pageable: true,
            selectable: true,
            height: 400
        };
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