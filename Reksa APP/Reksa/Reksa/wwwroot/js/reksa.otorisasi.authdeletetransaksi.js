$(document).ready(function load() {
    var gridOptions = {
        height: 400
    };
    $("#dataGridView1").kendoGrid(gridOptions);
    subRefresh();
});

function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/ViewApprovalDelete',
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                var grid = $("#dataGridView1").data("kendoGrid");
                var gridData = populateGridView1(data.dsResult.table);
                grid.setOptions(gridData);
                grid.dataSource.pageSize(10);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");

                $("#dataGridView1 th[data-field=tranId]").html("Tran Id")
                $("#dataGridView1 th[data-field=kodeProduk]").html("Kode Produk")
                $("#dataGridView1 th[data-field=namaProduk]").html("Nama Produk")
                $("#dataGridView1 th[data-field=clientCode]").html("Client Code")
                $("#dataGridView1 th[data-field=namaNasabah]").html("Nama Nasabah")
                $("#dataGridView1 th[data-field=nominalSubscription]").html("Nominal Subscription")
                $("#dataGridView1 th[data-field=valueDate]").html("Value Date")
                $("#dataGridView1 th[data-field=rekeningRelasi]").html("Rekening Relasi")
                $("#dataGridView1 th[data-field=namaRekeningRelasi]").html("Nama Rekening Relasi")
                $("#dataGridView1 th[data-field=agentCode]").html("Agent Code")
                $("#dataGridView1 th[data-field=nikSeller]").html("NIK Seller")
                $("#dataGridView1 th[data-field=namaSeller]").html("Nama Seller")
                $("#dataGridView1 th[data-field=nikInputer]").html("NIK Inputer")
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
                $("#dataGridView1").empty();
            }
        },
        complete: function () {
            $("#load_screen").hide();
        }
    });
}



function populateGridView1(response) {
    if (response.length > 0) {
        var columns = generateColumns(response);
        return gridOptions = {
            dataSource: {
                transport: {
                    read: function (options) {
                        options.success(response);
                    }
                },
                pageSize: 10,
                page: 1
            },
            columns: columns,
            pageable: true,
            selectable: true,
            height: 400
        };
    }
}

function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var check = name.indexOf("check") > -1 || name.indexOf("CheckBox") > -1;
        var valueDate = name.indexOf("valueDate") > -1 || name.indexOf("valueDate") > -1;
        var value;
        value = 'tranId';
        return {
            headerTemplate: check ? "<input type='checkbox'  id='chkSelectAll' onclick='checkAll(this)' />" : name,
            template: check ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (check) { #" +
                "checked='checked'" +
                "# } #" +
                "/>"
                : valueDate ? "#= kendo.toString(kendo.parseDate(valueDate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                : columnNames,
            field: name,
            width: check ? 50 : 200,
            title: check ? "CheckBox" : name
        };
    })
}


function subApproveReject(isApprove) {
    var grid = $("#dataGridView1").data("kendoGrid");
    grid.refresh();
    var dataItems = "";
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);
        if (dataItem.check == true) {
            dataItems += dataItem.tranId + "|";
        }
    })
    if (dataItems == "")
        swal("Warning", "No data selected!", "warning");
    else {
        if (isApprove) {
            swal({
                title: "Are you sure to approve this data?",
                text: "",
                type: "warning",
                showCancelButton: true,
                confirmButtonClass: 'btn-info',
                confirmButtonText: "Yes",
                closeOnConfirm: false
            },
                function () {
                    $.ajax({
                        type: "POST",
                        url: "/Otorisasi/DeleteBooking",
                        data: { listTranId: dataItems },
                        beforeSend: function () {
                            $("#load_screen").show();
                        },
                        success: function (data) {
                            if (data.blnResult) {
                                swal("Success", "Data Berhasil diotorisasi", "success");
                                subRefresh();
                            }
                            else
                            {
                                swal("Warning", data.ErrMsg, "warning");
                            }
                        },
                        complete: function () {
                            $("#load_screen").hide();
                        }
                    });
                });
        }
        else
        {
            swal({
                title: "Are you sure to reject this data?",
                text: "",
                type: "warning",
                showCancelButton: true,
                confirmButtonClass: 'btn-info',
                confirmButtonText: "Yes",
                closeOnConfirm: false
            },
                function () {
                    $.ajax({
                        type: "POST",
                        url: "/Otorisasi/RejectDeleteTrans",
                        data: { listTranId: dataItems },
                        beforeSend: function () {
                            $("#load_screen").show();
                        },
                        success: function (data) {
                            if (data.blnResult) {                                
                                swal("Success", "Data Berhasil direject", "success");
                                subRefresh();
                            }
                            else {
                                swal("Warning", data.ErrMsg, "warning");
                            }
                        },
                        complete: function () {
                            $("#load_screen").hide();
                        }
                    });
                });
        }
    }
}
