$("#btnRefresh").click(function btnRefresh_click() {
    PopulateData();
});

$("#btnProcess").click(function btnProcess_click() {
    swal({
        title: "Information",
        text: "Apakah yakin akan melakukan proses ?",
        type: "warning",
        showCancelButton: true,
        confirmButtonClass: 'btn-info',
        confirmButtonText: "Yes",
        closeOnConfirm: true,
        closeOnCancel: false
    },
        function (isConfirm) {
            if (!isConfirm) {
                swal("Canceled", "Proses data dibatalkan", "error");
                return;
            }
            else {
                Process();
            }
        });
});
$("#btnReject").click(function btnReject_click() {
    swal({
        title: "Information",
        text: "Apakah yakin akan melakukan reject ?",
        type: "warning",
        showCancelButton: true,
        confirmButtonClass: 'btn-info',
        confirmButtonText: "Yes",
        closeOnConfirm: true,
        closeOnCancel: false
    },
        function (isConfirm) {
            if (!isConfirm) {
                swal("Canceled", "Reject data dibatalkan", "error");
                return;
            }
            else {
                Reject();
            }
        });
});
