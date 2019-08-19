$(document).ready(function load() {

    var grid = {
        height: 200
    };
    $("#dataGrid").kendoGrid(grid);
    subRefresh();
});

function subProcess() {
    var grid = $("#dataGrid").data("kendoGrid");
    grid.refresh();
    var dataItems = "";
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);
        if (dataItem.check == true)
        {
            dataItems += dataItem.tranCode + "|";
        }
    })
    if (dataItems == "")
        swal("Warning", "Tidak ada data dipilih untuk proses pembatalan !", "warning");
    else {
        swal({
            title: "Are you sure to cancel this transaction?",
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
                    url: "/PO/ProsesCancelTransactionIBMB",
                    data: { listId: dataItems },
                    beforeSend: function () {
                        $("#load_screen").show();
                    },
                    success: function (data) {
                        if (data.blnResult) {
                            swal("Success", "Proses pembatalan transaksi sukses. Harap melakukan proses otorisasi! ", "success");
                        } else {
                            swal("Warning", data.ErrMsg, "warning");
                        }
                        subRefresh();
                    },
                    complete: function () {
                        $("#load_screen").hide();
                    }
                });

            });

    }
}

function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/PO/PopulateCancelTrxIBMB',
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                var grid = $("#dataGrid").data("kendoGrid");
                var gridData = populateGrid(data.dsResult.table);
                grid.setOptions(gridData);
                grid.dataSource.pageSize(10);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");
                $("#dataGrid th[data-field=tranCode]").html("Tran Code")
                $("#dataGrid th[data-field=noReferensi]").html("No Referensi")
                $("#dataGrid th[data-field=sumberTransaksi]").html("Sumber Transaksi")
                $("#dataGrid th[data-field=jenisTransaksi]").html("Jenis Transaksi")
                $("#dataGrid th[data-field=cifNo]").html("CIFNo")
                $("#dataGrid th[data-field=namaNasabah]").html("Nama Nasabah")
                $("#dataGrid th[data-field=shareholderID]").html("Shareholder ID")
                $("#dataGrid th[data-field=clientCode]").html("Client Code")
                $("#dataGrid th[data-field=namaProduk]").html("Nama Produk")
                $("#dataGrid th[data-field=mataUang]").html("Mata Uang")
                $("#dataGrid th[data-field=namaProdukTujuanPengalihan]").html("Nama Produk Tujuan Pengalihan")
                $("#dataGrid th[data-field=clientCodeTujuanPengalihan]").html("Client Code Tujuan Pengalihan")
                $("#dataGrid th[data-field=tanggalTransaksi]").html("Tanggal Transaksi")
                $("#dataGrid th[data-field=tanggalValuta]").html("Tanggal Valuta")
                $("#dataGrid th[data-field=nominalTransaksi]").html("Nominal")
                $("#dataGrid th[data-field=unitTransaksi]").html("Unit Transaksi")
                $("#dataGrid th[data-field=fee]").html("Fee")
                
                grid.hideColumn('tranType');
            }
            else {
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
            //change: dataGridView1_Click,
            //databound: onBounddataGridView1,
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };
    } else {
        $("#dataGrid").empty();
    }
}
function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var check = name.indexOf("check") > -1 || name.indexOf("check") > -1;
        var tanggalTransaksi = name.indexOf("tanggalTransaksi") > -1 || name.indexOf("tanggalTransaksi") > -1;
        var tanggalValuta = name.indexOf("tanggalValuta") > -1 || name.indexOf("tanggalValuta") > -1;
        var namaNasabah = name.indexOf("namaNasabah") > -1 || name.indexOf("namaNasabah") > -1;
        var namaProduk = name.indexOf("namaProduk") > -1 || name.indexOf("namaProduk") > -1;

        var value = 'tranCode';
        return {
            headerTemplate: check ? "Pilih" : name,
            template: check ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (check) { #" +
                "checked='checked'" +
                "# } #" +
                "/>"
                : tanggalTransaksi ? "#= kendo.toString(kendo.parseDate(tanggalTransaksi, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                    : tanggalValuta ? "#= kendo.toString(kendo.parseDate(tanggalValuta, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                        : columnNames,
            field: name,
            width: check ? 50 : namaNasabah ? 250 : namaProduk? 350: 150,
            title: name
        };
    })
}
