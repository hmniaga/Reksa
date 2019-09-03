$(document).ready(function () {
    var grid = {
        height: 200
    };
    $("#dataGridView1").kendoGrid(grid);
    subRefresh();
});

function subApproveReject(isApprove) {
    var grid = $("#dataGridView1").data("kendoGrid");
    grid.refresh();
    var dataItems = "";
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);
        if (dataItem.check == true) {
            dataItems += dataItem.bookingId + "|";
        }
    })
    if (dataItems == "")
        swal("Warning", "No data selected!", "warning");
    else {
        var messages;
        if (isApprove) {
            messages = 'approve';
        }
        else {
            messages = 'reject';
        }

        swal({
            title: "Are you sure to " + messages + " this data?",
            text: "",
            type: "warning",
            showCancelButton: true,
            confirmButtonClass: 'btn-info',
            confirmButtonText: "Yes, " + messages + " it!",
            closeOnConfirm: false
        },
            function () {
                $.ajax({
                    type: "POST",
                    url: "/Otorisasi/ApproveRejectBooking",
                    data: { listBookingId: dataItems, isApprove: isApprove },
                    success: function (data) {
                        if (data.blnResult) {
                            if (isApprove)
                                swal("Success", "Data Berhasil diapprove", "success");
                            else
                                swal("Success", "Data Berhasil direject", "success");
                        } else {
                            swal("Warning", data.ErrMsg, "warning");
                        }
                    }
                });

            });

    }
}

function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/ViewApprovalReject',
        success: function (data) {
            if (data.blnResult) {
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
                $("#dataGridView1 th[data-field=nikInputer]").html("NIK Inputter")

            }
            else {
                swal("Warning", data.ErrMsg, "warning");
                $("#dataGridView1").empty();
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
        var value = 'bookingId';
        return {
            headerTemplate: check ? "<input type='checkbox'  id='chkSelectAll' onclick='checkAll(this)' />" : name,
            template: check ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (check) { #" +
                "checked='checked'" +
                "# } #" +
                "/>"
                : tanggalBooking ? "#= kendo.toString(kendo.parseDate(tanggalBooking, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                    : columnNames,
            field: name,
            width: check ? 50 : 200,
            title: name
        };
    })
}