$('#btnApprove').click(function btnApprove_click() {
    subAcceptReject(true);
});

$('#btnReject').click(function btnReject_click() {    
    subAcceptReject(false);
});

function onBounddgMain() {
    var grid = $("#dgMain").data("kendoGrid");
    var len = grid.dataSource.data().length;

    if (len > 0) {
        grid.select(0);
    }
}

function dgMain_CellClick(e) {
    var data = this.dataItem(this.select());
    subPopulateDetailGrid(data);
    $("#dataGridView1").empty();
    if (treeid == "REKSY1") {
        subPopulateDetailItem(data.batchGuid);
    }
    else if ((treeid == "REKSY4") || (treeid == "REKSY6")) {
        subPopulateDetailMFee(data.batchGuid);
    }
    else if (treeid == "REKSY5") {        
        subPopulateDetailOSSHID(data.batchGuid);
    }
};

function trvMenu_NodeMouseClick(e) {
    _selectedTree = this.dataItem(e.node);
    treeid = _selectedTree.id;
    treename = _selectedTree.text;
    console.log(treeid);
    subPopulateGridMain();
}

function checkAll(e) {
    var state = $(e).is(':checked');
    var grid = $('#dgMain').data('kendoGrid');
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
    var grid = $('#dgMain').data('kendoGrid');
    grid.refresh();
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);
        if (dataItem.refId == value) {
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
