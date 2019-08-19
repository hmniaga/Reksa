//click
$("#btnProcess").click(function () {
    subProcess();
});
$("#srcCabangAsal").click(function srcCabangAsal_click() {
    var url = $(this).attr("href");
    $('#OfficeModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});
$("#srcCabangTujuan").click(function srcCabangTujuan_click() {
    var url = $(this).attr("href");
    $('#OfficeModal .modal-content').load(url, function (result) {
        $(this).html(result);
        $('#display').modal({ show: true });
    });
});

//change
$("#srcCabangAsal_text1").change(async function srcCabangAsal_text1_change() {
    var data = await PopulateAgentCode($("#srcCabangAsal_text1").val());
    if (data.blnResult) {
        var grid = $("#dataGridAgentAsal").data("kendoGrid");
        var gridData = populateGrid(data.dsResult.table);
        grid.setOptions(gridData);
        grid.dataSource.pageSize(10);
        grid.dataSource.page(1);
        grid.select("tr:eq(0)");
        $("#dataGridAgentAsal th[data-field=agentCode]").html("Agent Code")
        $("#dataGridAgentAsal th[data-field=agentDesc]").html("Agent Deskripsi")
    }
    else {
        swal("Warning", data.ErrMsg, "warning");
    }
});
$("#srcCabangTujuan_text1").change(async function srcCabangTujuan_text1_change() {
    var data = await PopulateAgentCode($("#srcCabangTujuan_text1").val());
    if (data.blnResult) {
        var grid = $("#dataGridAgentTujuan").data("kendoGrid");
        var gridData = populateGrid(data.dsResult.table);
        grid.setOptions(gridData);
        grid.dataSource.pageSize(10);
        grid.dataSource.page(1);
        grid.select("tr:eq(0)");
        $("#dataGridAgentTujuan th[data-field=agentCode]").html("Agent Code")
        $("#dataGridAgentTujuan th[data-field=agentDesc]").html("Agent Deskripsi")
    }
    else {
        swal("Warning", data.ErrMsg, "warning");
    }
});