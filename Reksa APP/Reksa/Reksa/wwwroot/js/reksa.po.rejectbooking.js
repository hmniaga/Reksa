var _strTabName;
$(document).ready(function () {
    var grid = {
        height: 400
    };
    $("#dataGridView1").kendoGrid(grid);
    $("#dataGridView2").kendoGrid(grid);
    _strTabName = 'A';
    subRefresh();
});
function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/PO/PopulateRejectBooking',
        data: { strJenis: _strTabName },
        success: function (data) {
            if (data.blnResult) {
                if (_strTabName == 'A') {
                    var grid1 = $("#dataGridView1").data("kendoGrid");
                    var gridData1 = populateGrid(data.dsResult.table);
                    grid1.setOptions(gridData1);
                    grid1.dataSource.page(1);
                    grid1.select("tr:eq(0)");
                    $("#dataGridView1 th[data-field=bookingId]").html("Booking Id")
                    $("#dataGridView1 th[data-field=kodeProduk]").html("Kode Produk")
                    $("#dataGridView1 th[data-field=namaProduk]").html("Nama Produk")
                    $("#dataGridView1 th[data-field=bookingCode]").html("Booking Code")
                    $("#dataGridView1 th[data-field=namaNasabah]").html("Nama Nasabah")
                    $("#dataGridView1 th[data-field=nominalBooking]").html("Nominal Booking")
                    $("#dataGridView1 th[data-field=tanggalBooking]").html("Tanggal Booking")
                    $("#dataGridView1 th[data-field=rekeningRelasi]").html("Rekening Relasi")
                    $("#dataGridView1 th[data-field=namaRekeningRelasi]").html("Nama Rekening Relasi")
                    $("#dataGridView1 th[data-field=agentCode]").html("Agent Code")
                    $("#dataGridView1 th[data-field=nikSeller]").html("NIK Seller")
                    $("#dataGridView1 th[data-field=namaSeller]").html("Nama Seller")

                }
                else {
                    var grid2 = $("#dataGridView2").data("kendoGrid");
                    var gridData2 = populateGrid(data.dsResult.table);
                    grid2.setOptions(gridData2);
                    grid2.dataSource.page(1);
                    grid2.select("tr:eq(0)");
                    $("#dataGridView2 th[data-field=tranId]").html("Tran Id")
                    $("#dataGridView2 th[data-field=kodeProduk]").html("Kode Produk")
                    $("#dataGridView2 th[data-field=namaProduk]").html("Nama Produk")
                    $("#dataGridView2 th[data-field=clientCode]").html("Client Code")
                    $("#dataGridView2 th[data-field=namaNasabah]").html("Nama Nasabah")
                    $("#dataGridView2 th[data-field=nominalSubscription]").html("Nominal Subscription")
                    $("#dataGridView2 th[data-field=valueDate]").html("Value Date")
                    $("#dataGridView2 th[data-field=rekeningRelasi]").html("Rekening Relasi")
                    $("#dataGridView2 th[data-field=namaRekeningRelasi]").html("Nama Rekening Relasi")
                    $("#dataGridView2 th[data-field=agentCode]").html("Agent Code")
                    $("#dataGridView2 th[data-field=nikSeller]").html("NIK Seller")
                    $("#dataGridView2 th[data-field=namaSeller]").html("Nama Seller")
                }
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
                $("#dataGridView1").empty();
                $("#dataGridView2").empty();
            }
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
                pageSize: 10,
                page: 1
            },
            //change: onRowOtorisasiSelect,
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
        var check = name.indexOf("check") > -1 || name.indexOf("check") > -1;
        var tanggalBooking = name.indexOf("tanggalBooking") > -1 || name.indexOf("tanggalBooking") > -1;
        var valueDate = name.indexOf("valueDate") > -1 || name.indexOf("valueDate") > -1;
        var value;
        if (_strTabName == 'A')
            value = 'bookingId';
        else
            value = 'tranId';

        return {
            headerTemplate: check ? "<input type='checkbox'  id='chkSelectAll' onclick='checkAll(this)' />" : name,
            template: check ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (check) { #" +
                "checked='checked'" +
                "# } #" +
                "/>"
                : tanggalBooking ? "#= kendo.toString(kendo.parseDate(tanggalBooking, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                    : valueDate ? "#= kendo.toString(kendo.parseDate(valueDate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                        : columnNames,
            field: name,
            width: check ? 50 : 200,
            title: name
        };
    })
}
function subProcess() {
    var grid;
    if (_strTabName == 'A')
        grid = $("#dataGridView1").data("kendoGrid");
    else
        grid = $("#dataGridView2").data("kendoGrid");

    grid.refresh();
    var dataItems = "";
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (_strTabName == 'A') {
            if (dataItem.check == true) {
                dataItems += dataItem.bookingId + "|";
            }
        } else {
            if (dataItem.check == true) {
                dataItems += dataItem.tranId + "|";
            }
        }
    })
    if (dataItems == "")
        swal("Warning", "No data selected!", "warning");
    else {
        var messages;
        var messages1;
        if (_strTabName == 'A') {
            messages = 'reject this bookings?';
            messages1 = 'reject';
        }
        else {
            messages = 'delete this transactions?';
            messages1 = 'delete';
        }

        swal({
            title: "Are you sure to " + messages,
            text: "",
            type: "warning",
            showCancelButton: true,
            confirmButtonClass: 'btn-info',
            confirmButtonText: "Yes, " + messages1 + " it!",
            closeOnConfirm: false
        },
            function () {
                $.ajax({
                    type: "POST",
                    url: "/PO/SaveRejectBooking",
                    data: { listId: dataItems, strJenis: _strTabName },
                    success: function (data) {
                        if (data.blnResult) {
                            if (_strTabName == 'A')
                                swal("Success", "Reject Booking memerlukan Otorisasi Supervisor", "success");
                            else
                                swal("Success", "Delete Transaksi memerlukan Otorisasi Supervisor", "success");
                        } else {
                            swal("Warning", data.ErrMsg, "warning");
                        }
                        subRefresh();
                    }
                });

            });

    }
}
