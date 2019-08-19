$("#btnRefresh").click(function () {
    subRefresh();
});
$('#btnApprove').click(function (e) {
    subApprove(true);
});
$('#btnReject').click(function (e) {
    subApprove(false);
});


function onSelect(e) {
    var dataItem = this.dataItem(e.node);
    _strTreeInterface = dataItem.id;
    treename = dataItem.text;
    subRefresh();
}

function checkAll(e) {
    var state = $(e).is(':checked');
    var grid = $('#dgvParam').data('kendoGrid');
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
    var grid = $('#dgvParam').data('kendoGrid');
    grid.refresh();

    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);
        if (dataItem.id == value) {
            dataItem.checkB = state;
        }
    })

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
