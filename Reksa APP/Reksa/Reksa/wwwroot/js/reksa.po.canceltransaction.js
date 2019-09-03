$(document).ready(function () {
    var grid = {
        height: 300
    };
    $("#dataGridView1").kendoGrid(grid);
    CallReksaPopulateCancelTransaction();
});

function CallReksaCancelTransaction() {
    var grid = $("#dataGridView1").data("kendoGrid");
    var selectedTranId = "";
    grid.refresh();
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);
        if (dataItem.checkB == true) {
            selectedTranId += dataItem.tranId + "|";
        }
    })

    if (selectedTranId == "") {
        swal("Warning", "Tidak ada data yang dipilih", "warning");
        return;
    }

    swal({
        title: "Konfirmasi Pembatalan Transaksi",
        text: "Anda yakin hendak membatalkan transaksi?",
        type: "warning",
        showCancelButton: true,
        confirmButtonClass: 'btn-info',
        confirmButtonText: "Yes",
        closeOnConfirm: true,
        closeOnCancel: true
    },
        function (isConfirm) {
            if (isConfirm) {
                $.ajax({
                    type: "POST",
                    url: '/PO/subCancelTransaction',
                    data: { listTranId: selectedTranId },
                    beforeSend: function () {
                        $("#load_screen").show();
                    }, 
                    success: function (data) {
                        if (data.blnResult == true) {
                            setTimeout(function () { swal("Approved", "Proses pembatalan transaksi sukses", "success") }, 500);   
                        }
                        else {
                            setTimeout(function () { swal("Warning", data.ErrMsg, "warning") }, 500);   
                        }
                        CallReksaPopulateCancelTransaction();
                    },
                    complete: function () {
                        $("#load_screen").hide();
                    }
                });
            } else {
                setTimeout(function () { swal("Konfirmasi Pembatalan Transaksi", "Pembatalan transaksi tidak dilakukan", "warning") }, 500);
            }
        });
}

function CallReksaPopulateCancelTransaction() {
    $.ajax({
        type: 'GET',
        url: '/PO/PopulateCancelTrans',
        beforeSend: function () {
            $("#load_screen").show();
        }, 
        success: function (data) {
            if (data.blnResult) {
                var gridView = $("#dataGridView1").data("kendoGrid");
                var gridData = populateGrid(data.dsResult.table);
                gridView.setOptions(gridData);
                gridView.dataSource.page(1);
                gridView.select("tr:eq(0)");
                gridView.hideColumn('tranId');

                $("#dataGridView1 th[data-field=clientCode]").html("Client Code")
                $("#dataGridView1 th[data-field=prodCode]").html("Product Code")
                $("#dataGridView1 th[data-field=tranCode]").html("Tran Code")
                $("#dataGridView1 th[data-field=cifName]").html("CIF Name")
                $("#dataGridView1 th[data-field=agentCode]").html("Agent Code")
                $("#dataGridView1 th[data-field=tranDesc]").html("Description")
                $("#dataGridView1 th[data-field=fullMonthMtcFee]").html("Full Amount Fee")
                $("#dataGridView1 th[data-field=tranCCY]").html("Currency")
                $("#dataGridView1 th[data-field=tranAmt]").html("Amount")
                $("#dataGridView1 th[data-field=tranUnit]").html("Unit")
                $("#dataGridView1 th[data-field=goodFund]").html("Good Fund")
                $("#dataGridView1 th[data-field=name]").html("Name")
                $("#dataGridView1 th[data-field=checkerSuid]").html("Checker ID")
                $("#dataGridView1 th[data-field=settleDate]").html("Settle Date")
                $("#dataGridView1 th[data-field=status]").html("Status")

            } else {
                swal("Warning", data.ErrMsg, "warning");
            }
        },
        complete: function () {
            $("#load_screen").hide();
        }
    });
}

function populateGrid(response) {
    if (response.length > 0) {
        var columns = generateColumns(response);
        return gridOptions = {
            dataSource: {
                transport: {
                    read: function (options) {
                        options.success(response);
                    }
                },
                pageSize: 5,
                page: 1
            },
            //change: onRowPeriodSelect,
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };
    } else {
        $("#dataGridView1").empty();
    }
}

function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var checkB = name.indexOf("checkB") > -1 || name.indexOf("checkB") > -1;
        var cifName = name.indexOf("cifName") > -1 || name.indexOf("cifName") > -1;
        var tranDesc = name.indexOf("tranDesc") > -1 || name.indexOf("tranDesc") > -1;
        var value = 'tranId';
        return {
            headerTemplate: checkB ? "Pilih" : name,
            template: checkB ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (checkB) { #" +
                "checked='checked'" +
                "# } #" +
                "/>" : columnNames,
            field: name,
            width: checkB ? 50 : cifName ? 250 : tranDesc ? 250 : 150,
            title: name
        };
    })
}
