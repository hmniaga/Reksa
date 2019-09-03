function subRefresh() {
    if ($("#srcClient_text1").val() == '') {
        swal("Warning", "Kode Nasabah Harus Diisi!", "warning");
    }
    $.ajax({
        type: 'GET',
        url: '/Transaksi/GetRegulerSubscriptionTunggakan',
        data: { intClientId: $("#ClientId").val() },
        beforeSend: function () {
            $("#load_screen").show();
        }, 
        success: function (data) {
            if (data.blnResult) {
                var dataSource = new kendo.data.DataSource(
                    {
                        data: data.listTunggakan
                    });
                var grid = $('#dgvTunggakan').data('kendoGrid');
                grid.setDataSource(dataSource);
                grid.dataSource.pageSize(15);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");
            } else {
                swal("Warning", data.ErrMsg, "warning");
            }
        },
        complete: function () {
            $("#load_screen").hide();
        }
    });
}