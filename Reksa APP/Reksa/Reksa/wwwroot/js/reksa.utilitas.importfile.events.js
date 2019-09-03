
$("#btnProcess").click(function () {
    var grid = $("#dataGridView1").data("kendoGrid");
    var listNAV;
    listNAV = grid.dataSource.view();
    var model = JSON.stringify({ 'listNAV': listNAV });
    $.ajax({
        type: 'POST',
        url: '/Utilitas/PopulateNAVParameter',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.blnResult) {
                swal("Success", "Proses Berhasil", "success");
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
});