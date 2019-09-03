
$('#btnApprove').click(function (e) {
    subApprove(true);
});

$('#btnReject').click(function (e) {
    subApprove(false);
});

function checkAll(e) {
    var state = $(e).is(':checked');
    var grid = $('#GridOtorisasi').data('kendoGrid');
    $.each(grid.dataSource.view(), function () {
        if (this['checkB'] != state)
            this.dirty = true;

        this['checkB'] = state;
    });
    grid.refresh();
}

function onCheckBoxClick(e) {
    var state = $(e).is(':checked');
    var value = e.value;

    var grid = $('#GridOtorisasi').data('kendoGrid');
    grid.refresh();

    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (treename == 'Transaksi') {
            if (dataItem.tranId == value) {
                dataItem.checkB = state;
            }
        } else if (treename == 'Product') {
            if (dataItem.prodId == value) {
                dataItem.checkB = state;
            }
        }
        else if (treeid == 'REKBI1' || treeid == 'REKBI4' || treeid == 'REKBI8') {
            if (dataItem.billId == value) {
                dataItem.checkB = state;
            }
        }
        else if (treeid == 'REKPO4' || treeid == 'REKWS3') {
            if (dataItem.id == value) {
                dataItem.checkB = state;
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

function onRowOtorisasiSelect(e) {
    var data = this.dataItem(this.select());
    populateGridDetail(data);
};

function onSelect(e) {
    SelectedTree = this.dataItem(e.node);
    if ((SelectedTree.id == "REKSA8") || (SelectedTree.id == "REKSA6")) {
        $("#btnReject").hide();
    }
    else {
        $("#btnReject").show();
    }
    subPopulateGridMain();
}