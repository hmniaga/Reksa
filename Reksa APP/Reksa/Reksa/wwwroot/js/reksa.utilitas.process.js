$(document).ready(function () {
    subRefresh();
});

function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/Utilitas/PopulateProcess',
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                if (data.listProcess.length != 0) {
                    var dataSource = new kendo.data.DataSource(
                        {
                            data: data.listProcess
                        });
                    var grid = $('#dataGridView1').data('kendoGrid');
                    grid.setDataSource(dataSource);
                    grid.dataSource.pageSize(5);
                    grid.dataSource.page(1);
                    grid.select("tr:eq(0)");

                    grid.hideColumn('Pilih');
                } else {
                    $("#dataGridView1").data('kendoGrid').dataSource.data([]);
                }
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }, complete: function () {
            $("#load_screen").hide();
        }
    });
}

function subProcess(SPName, ProcessId, ProcessName) {
    $.ajax({
        type: 'POST',
        url: '/Utilitas/subProcess',
        data: { SPName: SPName, ProcessId: ProcessId },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                swal("Success", ProcessName + " Telah Dijalankan", "success");
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        },
        complete: function () {
            $("#load_screen").hide();
        }
    });
    subRefresh();
}
