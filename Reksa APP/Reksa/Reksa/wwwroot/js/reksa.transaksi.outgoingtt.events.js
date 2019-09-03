$("#btnRefresh").click(function () {
    subPopulate();
});
$("#btnProcess").click(function () {
    subProcess(true);
});
$("#btnReject").click(function () {
    subProcess(false);
});

function checkAll(e) {
    var state = $(e).is(':checked');
    var grid = $('#dataGridView1').data('kendoGrid');
    $.each(grid.dataSource.view(), function () {
        if (this['CheckB'] != state)
            this.dirty = true;

        this['CheckB'] = state;
    });
    grid.refresh();
}

function onCheckBoxClick(e) {
    var state = $(e).is(':checked');
    var value = e.value;
    var grid = $('#dataGridView1').data('kendoGrid');
    grid.refresh();
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);
        if (dataItem.BillId == value) {
            dataItem.CheckB = state;
        }
    })
    var chkAll = $('#chkSelectAll').is(':checked');
    var isCheckedAll = true;
    var countTrue = 0;
    var countFalse = 0;
    var countAll = 0;
    $.each(grid.dataSource.view(), function () {
        if (this['CheckB'] == true) {
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
