$('#btnRefresh').click(function btnRefresh_click() {
    subPopulate($("#_combojenis").data("kendoDropDownList").text());
});
$('#btnProcess').click(function btnProcess_click() {
    subProcess(true, $("#_combojenis").data("kendoDropDownList").text());
});
$('#btnReject').click(function btnReject_click() {
    subProcess(false, $("#_combojenis").data("kendoDropDownList").text());
});

function checkAll(e) {
    var state = $(e).is(':checked');
    var grid = $('#dataGridView1').data('kendoGrid');
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
    var grid = $('#dataGridView1').data('kendoGrid');
    grid.refresh();
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);
        if (dataItem.billId == value) {
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

function onBound_combojenis() {
    var dropdownlist = $("#_combojenis").data("kendoDropDownList");
    var len = dropdownlist.dataSource.data().length;

    if (len > 0) {
        dropdownlist.select(0);
        _combojenis_SelectedIndexChanged();
    }
}
function _combojenis_SelectedIndexChanged() {
    subPopulate($("#_combojenis").data("kendoDropDownList").text());
}
