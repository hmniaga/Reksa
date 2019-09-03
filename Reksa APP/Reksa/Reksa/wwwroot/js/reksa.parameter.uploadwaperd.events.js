
$("#btnProcess").click(function () {
    var selectedId = 0;
    var grid = $("#dataGridView1").data("kendoGrid");
    grid.refresh();
    grid.tbody.find("tr[role='row']").each(function () {
        selectedId = selectedId + 1;
    })

    if (selectedId == 0) {
        swal("Warning", "Silahkan memilih File yang akan diupload", "warning");
    }
    else {
        swal({
            title: "Apakah yakin akan melakukan upload data ?",
            text: "",
            type: "warning",
            showCancelButton: true,
            confirmButtonClass: 'btn-info',
            confirmButtonText: "Yes",
            closeOnConfirm: true
        },
            function () {
                var grid = $("#dataGridView1").data("kendoGrid");
                var listWaperd;
                listWaperd = grid.dataSource.view();

                var model = JSON.stringify({ 'listWaperd': listWaperd });
                $.ajax({
                    type: 'POST',
                    url: '/Parameter/SaveUploadWAPERD',
                    data: model,
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        if (data.blnResult) {
                            swal("Success", "Upload Data Berhasil", "success");
                        }
                        else {
                            swal("Warning", data.ErrMsg, "warning");
                        }
                    }
                });
            });
    }
});