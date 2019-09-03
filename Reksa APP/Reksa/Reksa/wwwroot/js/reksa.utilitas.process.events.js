
$("#btnProcess").click(function () {
    var grid = $("#dataGridView1").data("kendoGrid");
    grid.refresh();
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);
        if (dataItem.CheckB == true) {
            subProcess(dataItem.SPName, dataItem.ProcessId, dataItem.ProcessName);
        }
    })
});


function checkProcessAll(e) {
    var state = $(e).is(':checked');
    var grid = $('#dataGridView1').data('kendoGrid');
    $.each(grid.dataSource.view(), function () {
        if (this['CheckB'] != state)
            this.dirty = true;

        this['CheckB'] = state;
    });
    grid.refresh();
}

function onCheckBoxProcessClick(e) {
    var state = $(e).is(':checked');
    var value = e.value;
    var grid = $('#dataGridView1').data('kendoGrid');
    grid.refresh();

    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.ProcessId == value) {
            dataItem.CheckB = state;
        }
    })

    var chkAll = $('#chkProcessSelectAll').is(':checked');
    var isCheckedAll = false;
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
        $('#chkProcessSelectAll').prop("checked", state);
    }
    grid.refresh();
} 