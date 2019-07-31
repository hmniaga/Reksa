$("#btnRefresh").click(function () {
    subRefresh();
});
$("#btnProcess").click(function () {
    swal({
        title: "Apakah akan melakukan Otorisasi Transaksi?",
        text: "",
        type: "warning",
        showCancelButton: true,
        confirmButtonClass: 'btn-info',
        confirmButtonText: "Yes",
        closeOnConfirm: true,
        closeOnCancel: true
    },
        function (isConfirm) {
            if (isConfirm) {
                setTimeout(function () { subAcceptReject(true) }, 500);
            }
        });

});
$("#btnReject").click(function () {
    swal({
        title: "Reject Transaksi?",
        text: "",
        type: "warning",
        showCancelButton: true,
        confirmButtonClass: 'btn-danger',
        confirmButtonText: "Yes",
        closeOnConfirm: true,
        closeOnCancel: true
    },
        function (isConfirm) {
            if (isConfirm) {
                setTimeout(function () { subAcceptReject(false) }, 500);
            }
        });
});

//change
$("#radioTransaction").change(function () {
    if ($("#radioTransaction").prop('checked') == true) {
        subDisableAllTrxControl(true);
    }
    else {
        subDisableAllTrxControl(false);
    }
});
$("#radioReverse").change(function () {
    if ($("#radioReverse").prop('checked') == true) {
        subDisableAllTrxControl(true);
        subDisableAllActionControl(false);
        $("#radioBooking").prop('disabled', true);
        document.getElementById("btnReject").disabled = true;
    }
    else {
        subDisableAllTrxControl(false);
        subDisableAllActionControl(true);
        $("#radioBooking").prop('disabled', false);
        document.getElementById("btnReject").disabled = false;
    }
});

function onCheckBoxClick(e) {
    var state = $(e).is(':checked');
    var value = e.value;

    var grid = $('#dataGridView1').data('kendoGrid');
    grid.refresh();

    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.noReferensi == value) {
            dataItem.checkB = state;
            if (state) {
                grid.select("tr:eq(value)");
            }
        }
    })
    var chkAll = $('#chkSelectAll').is(':checked');
    var isCheckedAll = true;
    var countTrue = 0;
    var countFalse = 0;
    var countAll = 0;

    $.each(grid.dataSource.view(), function () {
        if (this['checkB'] == true) {
            countTrue = countTrue + 1;
        }
        else {
            countFalse = countFalse + 1;
            isCheckedAll = false;
        }
        countAll = countAll + 1;
    });
    if (countFalse == 0 || (countFalse == 1 && !state)) {
        $('#chkSelectAll').prop("checked", state);
    }
    grid.refresh();
}

function onCheckBoxClickDetail(e) {
    var state = $(e).is(':checked');
    var value = e.value;

    var grid = $('#dataGridView2').data('kendoGrid');
    grid.refresh();

    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.tranId == value) {
            dataItem.checkB = state;
        }
    })

    var chkAll = $('#chkSelectAllDetail').is(':checked');
    var isCheckedAll = true;
    var countTrue = 0;
    var countFalse = 0;
    var countAll = 0;

    $.each(grid.dataSource.view(), function () {
        if (this['checkB'] == true) {
            countTrue = countTrue + 1;
        }
        else {
            countFalse = countFalse + 1;
            isCheckedAll = false;
        }
        countAll = countAll + 1;
    });
    if (countFalse == 0 || (countFalse == 1 && !state)) {
        $('#chkSelectAllDetail').prop("checked", state);
    }
    grid.refresh();
}

function onRowOtorisasiSelect() {
    var data = this.dataItem(this.select());
    PopulateVerifyData(data.noReferensi);
};