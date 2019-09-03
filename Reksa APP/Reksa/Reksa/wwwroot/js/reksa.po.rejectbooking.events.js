
$("#btnRefresh").click(function () {
    subRefresh();
});

$("#btnProcess").click(function () {
    subProcess();
});


$('a[data-toggle=tab]').click(function () {
    _strTabName = this.id;
    subRefresh();
});

function checkAll(e) {
    var state = $(e).is(':checked');
    var grid;
    if (_strTabName == 'A') {
        grid = $('#dataGridView1').data('kendoGrid');
    }
    else {
        grid = $('#dataGridView2').data('kendoGrid');
    }
    $.each(grid.dataSource.view(), function () {
        if (this['check'] != state)
            this.dirty = true;

        this['check'] = state;
    });
    grid.refresh();
}
function onCheckBoxClick(e) {
    var state = $(e).is(':checked');
    var value = e.value;

    var grid;
    if (_strTabName == 'A')
        grid = $('#dataGridView1').data('kendoGrid');
    else
        grid = $('#dataGridView2').data('kendoGrid');

    grid.refresh();

    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (_strTabName == 'A') {
            if (dataItem.bookingId == value) {
                dataItem.check = state;
            }
        }
        else {
            if (dataItem.tranId == value) {
                dataItem.check = state;
            }
        }

    })

    var chkAll = $('#chkSelectAll').is(':checked');
    var isCheckedAll = true;
    var countTrue = 0;
    var countFalse = 0;
    var countAll = 0;

    $.each(grid.dataSource.view(), function () {
        if (this['check'] == true) {
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

