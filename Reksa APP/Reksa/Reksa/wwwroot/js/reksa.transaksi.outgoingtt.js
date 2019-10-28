$(document).ready(function () {
    var grid = {
        height: 200
    };
    $("#dataGridView1").kendoGrid(grid);
    subPopulate();
});

function subPopulate() {
    $.ajax({
        type: 'GET',
        url: '/Transaksi/PopulateOutgoingTT',
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                var gridView = $("#dataGridView1").data("kendoGrid");
                var gridData = populateGrid(data.listOutgoingTT);

                gridView.setOptions(gridData);
                gridView.dataSource.page(1);
                gridView.select("tr:eq(0)");

                $("#dataGridView1 th[data-field=BillId]").html("Bill Id")
                $("#dataGridView1 th[data-field=ProdName]").html("Product Name")
                $("#dataGridView1 th[data-field=NamaPemohon]").html("Nama Pemohon")
                $("#dataGridView1 th[data-field=AlamatPemohon1]").html("Alamat Pemohon 1")
                $("#dataGridView1 th[data-field=AlamatPemohon2]").html("Alamat Pemohon 2")
                $("#dataGridView1 th[data-field=RemittanceNo]").html("Remittance No")
                $("#dataGridView1 th[data-field=TglPembelianReksadana]").html("Tgl Pembelian Reksadana")
                $("#dataGridView1 th[data-field=BillId]").html("Bill Id")
                $("#dataGridView1 th[data-field=BillId]").html("Bill Id")
                $("#dataGridView1 th[data-field=BillId]").html("Bill Id")
                $("#dataGridView1 th[data-field=BillId]").html("Bill Id")
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
                pageSize: 6,
                page: 1
            },
            //change: onRowKinerjaSelect,
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
        var CheckB = name.indexOf("CheckB") > -1 || name.indexOf("CheckB") > -1;
        var NamaPemohon = name.indexOf("NamaPemohon") > -1 || name.indexOf("NamaPemohon") > -1;
        var ProdName = name.indexOf("ProdName") > -1 || name.indexOf("ProdName") > -1;
        var AlamatPemohon1 = name.indexOf("AlamatPemohon1") > -1 || name.indexOf("AlamatPemohon1") > -1;
        var AlamatPemohon2 = name.indexOf("AlamatPemohon2") > -1 || name.indexOf("AlamatPemohon2") > -1;
        var PaymentRemarks = name.indexOf("PaymentRemarks") > -1 || name.indexOf("PaymentRemarks") > -1;
        var AlamatPenerima = name.indexOf("AlamatPenerima") > -1 || name.indexOf("AlamatPenerima") > -1;
        var TglPembelianReksadana = name.indexOf("TglPembelianReksadana") > -1 || name.indexOf("TglPembelianReksadana") > -1;
        var TanggalValuta = name.indexOf("TanggalValuta") > -1 || name.indexOf("TanggalValuta") > -1;
        var RemittanceNo = name.indexOf("RemittanceNo") > -1 || name.indexOf("RemittanceNo") > -1;
        var NominalTransfer = name.indexOf("NominalTransfer") > -1 || name.indexOf("NominalTransfer") > -1;
        var NamaPenerima = name.indexOf("NamaPenerima") > -1 || name.indexOf("NamaPenerima") > -1;

        value = 'BillId';
        return {
            headerTemplate: CheckB ? "<input type='checkbox'  id='chkSelectAll' onclick='checkAll(this)' />" : name,
            template: CheckB ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (CheckB) { #" +
                "checked='checked'" +
                "# } #" +
                "/>"
                : TglPembelianReksadana ? "#= kendo.toString(kendo.parseDate(TglPembelianReksadana, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                    : TanggalValuta ? "#= kendo.toString(kendo.parseDate(TanggalValuta, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                        : columnNames,
            field: name,
            width:
                CheckB ? 50 :
                    NamaPemohon ? 200 :
                        ProdName ? 300 :
                            AlamatPemohon1 ? 300 :
                                AlamatPemohon2 ? 300 :
                                    PaymentRemarks ? 380 :
                                        AlamatPenerima ? 300 :
                                            RemittanceNo ? 150 :
                                                NominalTransfer ? 200 :
                                                    NamaPenerima ? 200 :
                                                        TglPembelianReksadana ? 200 :
                                                            TanggalValuta ? 150
                                                                : 100,
            title: CheckB ? "CheckBox" : name
        };
    })
}

function subProcess(isProcess) {
    if (isProcess == false) {
        //Get alasan
    }

}

function subProcess2(BillId, isProcess, AlasanDelete) {
    $.ajax({
        type: 'GET',
        url: '/Transaksi/MaintainOutgoingTT',
        data: { BillId: BillId, isProcess: isProcess, AlasanDelete: AlasanDelete},
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                
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