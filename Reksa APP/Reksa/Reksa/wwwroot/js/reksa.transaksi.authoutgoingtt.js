$(document).ready(function load() {
    var grid = {
        height: 200
    };
    $("#dataGridView1").kendoGrid(grid);
});

function subProcess(isProcess, JenisProses)
{
    var grid = $("#dataGridView1").data("kendoGrid");
    grid.refresh();
    var BillId = "";
    var strTTGuid = "";
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.checkB == true) {
            BillId += dataItem.billId + "|";
            strTTGuid += dataItem.tranGuid + "|";
        }
    })
    if (BillId == "") {
        swal("Warning", "Tidak ada data dipilih untuk proses otorisasi !", "warning");
        return;
    }

    swal({
        title: "Confirmation",
        text: "Apakah Anda akan melakukan otorisasi data ?",
        type: "info",
        showCancelButton: true,
        confirmButtonClass: 'btn-info',
        confirmButtonText: "Yes"
    },
        async function Confirm() {
            if (Confirm)
            {
                if (JenisProses == "Delete Outgoing TT") {
                    var data = await subAuthOutgoingTT(JenisProses, isProcess, BillId);
                    if (data.blnResult) {
                        setTimeout(function () { swal("Success", "Data berhasil diotorisasi!", "success") }, 500);  
                        subPopulate(JenisProses);
                    }
                    else {
                        setTimeout(function () { swal("Warning", "Error Melakukan otorisasi Data!", "warning") }, 500);
                    }
                }
                else if (JenisProses == "Proses Outgoing TT") {
                    if (isProcess == false) {
                        var data = await subAuthOutgoingTT(JenisProses, isProcess, BillId);
                        if (data.blnResult)
                        {
                            setTimeout(function () {swal("Success", "Berhasil Melakukan Reject Data!", "success") }, 500);
                            subPopulate(JenisProses);
                        }
                        else {
                            setTimeout(function () { swal("Warning", "Error Melakukan Reject Data!", "warning") }, 500);
                        }
                    }
                    else if (isProcess == true)
                    {
                        var data = await subProcessTT(BillId, JenisProses);
                    }
                }
            }
        });    
}
function subProcessTT(listBillId, JenisProses)
{
    $.ajax({
        type: "POST",
        url: "/Transaksi/subProcessTT",
        data: { listBillId: listBillId, JenisJurnal: JenisProses },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                swal("Success", "Data Berhasil diotorisasi", "success");
                subPopulate(JenisProses);
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

function subAuthOutgoingTT(JenisProses, isProcess, BillId) {
    return new Promise((resolve, reject) => {
        $.ajax({
            type: 'POST',
            url: '/Transaksi/AuthorizeOutgoingTT',
            data: { JenisProses: JenisProses, isProcess: isProcess, BillId: BillId, RemittanceNumber: '' },
            beforeSend: function () {
                $("#load_screen").show();
            },
            success: function (data) {
                resolve({
                    blnResult: data.blnResult,
                    ErrMsg: data.ErrMsg
                })
            },
            complete: function () {
                $("#load_screen").hide();
            }
        });
    })
}

function subPopulate(JenisProses) {
    $.ajax({
        type: 'GET',
        url: '/Transaksi/PopulateVerifyOutgoingTT',
        data: { JenisProses: JenisProses },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                var grid = $("#dataGridView1").data("kendoGrid");
                var gridData = populateGrid(data.dsResult.table);
                grid.setOptions(gridData);
                grid.dataSource.pageSize(10);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");
                grid.hideColumn('tranGuid');
                if (JenisProses == "Delete Outgoing TT") {
                    grid.showColumn('alasanDelete');
                    grid.hideColumn('processStatusFee');
                    grid.hideColumn('processStatusTT');
                    grid.hideColumn('errorDescriptionFee');
                    grid.hideColumn('errorDescriptionTT');
                }
                else {
                    grid.hideColumn('alasanDelete');
                    grid.showColumn('processStatusFee');
                    grid.showColumn('processStatusTT');
                    grid.showColumn('errorDescriptionFee');
                    grid.showColumn('errorDescriptionTT');
                }    
                $("#dataGridView1 th[data-field=billId]").html("Bill Id")  
                $("#dataGridView1 th[data-field=prodName]").html("Product Name")   
                $("#dataGridView1 th[data-field=alasanDelete]").html("Alasan Delete")  
                $("#dataGridView1 th[data-field=dateProcess]").html("Date Process") 
                $("#dataGridView1 th[data-field=namaPemohon]").html("Nama Pemohon") 
                $("#dataGridView1 th[data-field=alamatPemohon1]").html("Alamat Pemohon 1") 
                $("#dataGridView1 th[data-field=alamatPemohon2]").html("Alamat Pemohon 2") 

                $("#dataGridView1 th[data-field=remittanceNo]").html("Remittance No") 
                $("#dataGridView1 th[data-field=tglPembelianReksadana]").html("Tgl Pembelian Reksadana") 
                $("#dataGridView1 th[data-field=tanggalValuta]").html("Tanggal Valuta") 
                $("#dataGridView1 th[data-field=nominalTransfer]").html("Nominal Transfer") 
                $("#dataGridView1 th[data-field=currency]").html("Currency") 
                $("#dataGridView1 th[data-field=namaPenerima]").html("Nama Penerima")
                $("#dataGridView1 th[data-field=alamatPenerima]").html("Alamat Penerima")
                $("#dataGridView1 th[data-field=paymentRemarks]").html("Payment Remarks")
                $("#dataGridView1 th[data-field=beneficiaryBankCode]").html("Beneficiary Bank Code")
                $("#dataGridView1 th[data-field=beneficiaryBankName]").html("Beneficiary Bank Name") 
                $("#dataGridView1 th[data-field=beneficiaryBankAddress]").html("Beneficiary Bank Address")
                $("#dataGridView1 th[data-field=beneficiaryAccNo]").html("Beneficiary AccNo")
                $("#dataGridView1 th[data-field=noRekProduk]").html("No Rek Produk")
                $("#dataGridView1 th[data-field=glBiayaFullAmt]").html("GL Biaya Full Amount")
                $("#dataGridView1 th[data-field=userProcess]").html("User Process") 
                $("#dataGridView1 th[data-field=processStatusFee]").html("Process Status Fee") 
                $("#dataGridView1 th[data-field=errorDescriptionFee]").html("Error Description Fee") 
                $("#dataGridView1 th[data-field=processStatusTT]").html("Process Status TT") 
                $("#dataGridView1 th[data-field=errorDescriptionTT]").html("Error Description TT") 
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
                pageSize: 10,
                page: 1
            },
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };
    }
}

function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var checkB = name.indexOf("checkB") > -1 || name.indexOf("checkB") > -1;
        var tglPembelianReksadana = name.indexOf("tglPembelianReksadana") > -1 || name.indexOf("tglPembelianReksadana") > -1;
        var tanggalValuta = name.indexOf("tanggalValuta") > -1 || name.indexOf("tanggalValuta") > -1;
        var tranGuid = name.indexOf("tranGuid") > -1 || name.indexOf("tranGuid") > -1;
        var prodName = name.indexOf("prodName") > -1 || name.indexOf("prodName") > -1;
        var paymentRemarks = name.indexOf("paymentRemarks") > -1 || name.indexOf("paymentRemarks") > -1;
        var dateProcess = name.indexOf("dateProcess") > -1 || name.indexOf("dateProcess") > -1;

        var value;
        value = 'billId';

        return {
            headerTemplate: checkB ? "<input type='checkbox'  id='chkSelectAll' onclick='checkAll(this)' />" : name,
            template: checkB ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (checkB) { #" +
                "checked='checked'" +
                "# } #" +
                "/>"
                : tglPembelianReksadana ? "#= kendo.toString(kendo.parseDate(tglPembelianReksadana, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                    : tanggalValuta ? "#= kendo.toString(kendo.parseDate(tanggalValuta, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                        : dateProcess ? "#= kendo.toString(kendo.parseDate(dateProcess, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                        : columnNames,
            field: name,
            width: checkB ? 50 : tranGuid ? 300 : prodName ? 300 : paymentRemarks? 400: 200,
            title: name
        };
    })
}

