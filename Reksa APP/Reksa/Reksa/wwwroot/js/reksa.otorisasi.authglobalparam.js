var _strTreeInterface;
var treename;
var _intType;

$(document).ready(function () {
    var grid = {
        height: 200
    };
    $("#dgvParam").kendoGrid(grid);
    _intType = 0;
});

function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/PopulateVerifyGlobalParam',
        data: { InterfaceId: _strTreeInterface },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult)
            {
                var grid = $('#dgvParam').data('kendoGrid');
                var gridData = populateGrid(data.dsResult.table);
                grid.setOptions(gridData);
                grid.dataSource.pageSize(15);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");

                grid.hideColumn('id');
                grid.hideColumn('minSwitchRedempt');
                grid.hideColumn('jenisSwitchRedempt');
                grid.hideColumn('switchingFeeNonKaryawan');
                grid.hideColumn('switchingFeeKaryawan');
                grid.hideColumn('productCode');
                grid.hideColumn('desc5');

                $("#dgvParam th[data-field=deskripsi]").html("Deskripsi")
                $("#dgvParam th[data-field=tipeAction]").html("Tipe Action")
                $("#dgvParam th[data-field=kode]").html("Kode")
                $("#dgvParam th[data-field=prodId]").html("ProdId")
                $("#dgvParam th[data-field=lastUpdate]").html("Last Update")
                $("#dgvParam th[data-field=lastUser]").html("Last User")
                $("#dgvParam th[data-field=officeId]").html("OfficeId")
                $("#dgvParam th[data-field=productCode]").html("Product Code")                

                if (_strTreeInterface == 'PFP')
                    grid.showColumn('id');

                grid.hideColumn('tanggalValuta');
                grid.hideColumn('prodId');
                grid.hideColumn('desc2');
                grid.hideColumn('tglEfektif');
                grid.hideColumn('tglExpire');
                grid.hideColumn('keterangan');
                $("#dgvParam th[data-field=desc2]").html("Desc2")
                $("#dgvParam th[data-field=desc5]").html("Desc5")

                if ((_strTreeInterface == 'MNI') || (_strTreeInterface == 'CTD')) {
                    grid.hideColumn('officeId');
                    grid.showColumn('desc2');
                    if (_strTreeInterface == "MNI") {
                        $("#dgvParam th[data-field=kode]").html("ManInv Code")
                        $("#dgvParam th[data-field=deskripsi]").html("ManInv Description")
                        $("#dgvParam th[data-field=desc2]").html("KSEI Code")
                    }
                    else if (_strTreeInterface == "CTD") {
                        $("#dgvParam th[data-field=kode]").html("Custody Code")
                        $("#dgvParam th[data-field=deskripsi]").html("Custody Description")
                        $("#dgvParam th[data-field=desc2]").html("KSEI Code")
                    }
                }
                else if (_strTreeInterface == "GFM") {
                    grid.showColumn('desc2');
                    $("#dgvParam th[data-field=desc2]").html("Biaya")
                    $("#dgvParam th[data-field=kode]").html("Gift Code")
                    $("#dgvParam th[data-field=deskripsi]").html("Gift Description")
                }
                else if (_strTreeInterface == "WPR") {
                    grid.showColumn('desc2');
                    grid.showColumn('desc5');
                    grid.showColumn('tglExpire');
                    grid.showColumn('keterangan');

                    $("#dgvParam th[data-field=desc2]").html("Nama")
                    $("#dgvParam th[data-field=desc5]").html("Job Title")
                }
                else if (_strTreeInterface == "RSB") {
                    grid.showColumn('desc2');
                    grid.showColumn('desc5');
                    $("#dgvParam th[data-field=desc2]").html("Red.Fee Asuransi")
                    $("#dgvParam th[data-field=desc5]").html("Red.FeeNon Asuransi")
                    $("#dgvParam th[data-field=deskripsi]").html("Subs Percent Fee")
                    grid.showColumn('keterangan');
                    grid.showColumn('jenisSwitchRedempt');
                    $("#dgvParam th[data-field=keterangan]").html("Swc.FeeAsuransi")
                    $("#dgvParam th[data-field=jenisSwitchRedempt]").html("Swc.FeeNonAsuransi")
                }
                else if (_strTreeInterface == "PFP") {
                    grid.showColumn('deskripsi');
                    grid.hideColumn('tanggalValuta');
                    grid.showColumn('prodId');
                    grid.hideColumn('id');

                    $("#dgvParam th[data-field=kode]").html("Frek Pendebetan")
                    $("#dgvParam th[data-field=prodId]").html("Min Jangka Waktu")
                    $("#dgvParam th[data-field=deskripsi]").html("Kelipatan")
                }
                else if (_strTreeInterface == "MSC") {
                    grid.showColumn('deskripsi');
                    grid.hideColumn('tanggalValuta');
                    grid.showColumn('jenisSwitchRedempt');

                    $("#dgvParam th[data-field=deskripsi]").html("Min Subsc")
                    $("#dgvParam th[data-field=kode]").html("Product")
                    $("#dgvParam th[data-field=jenisSwitchRedempt]").html("IsEmployee")
                }
                else if (_strTreeInterface == "SWC") {
                    $("#dgvParam th[data-field=deskripsi]").html("ProdSwitchIn")
                    $("#dgvParam th[data-field=kode]").html("ProdSwitchOut")
                    grid.showColumn('minSwitchRedempt');
                    grid.showColumn('jenisSwitchRedempt');
                    $("#dgvParam th[data-field=jenisSwitchRedempt]").html("JenisSwitchRedempt")
                    grid.showColumn('switchingFeeNonKaryawan');
                    grid.showColumn('switchingFeeKaryawan');
                    grid.hideColumn('tanggalValuta');
                }
                else if (_strTreeInterface == "RTY") {
                    grid.showColumn('desc2');
                    $("#dgvParam th[data-field=desc2]").html("ReksadanaTypeEnglish")
                    $("#dgvParam th[data-field=deskripsi]").html("ReksadanaType")
                }
                else if (_strTreeInterface == "RPP") {
                    grid.showColumn('desc2');
                    grid.hideColumn('lastUpdate');

                    $("#dgvParam th[data-field=kode]").html("KodeProduct")
                    $("#dgvParam th[data-field=deskripsi]").html("NamaProduk")
                    $("#dgvParam th[data-field=desc2]").html("RiskProfileProduct")
                }
                else if ((_strTreeInterface == "SAC") || (_strTreeInterface == "SFC") || (_strTreeInterface == "SBC")
                    || (_strTreeInterface == "SNV") || (_strTreeInterface == "SDV") || (_strTreeInterface == "SKR")) {
                    grid.showColumn('productCode');

                    if (_strTreeInterface == "SAC") {
                        $("#dgvParam th[data-field=kode]").html("AgentCode")
                        $("#dgvParam th[data-field=deskripsi]").html("AgentDescription")
                        $("#dgvParam th[data-field=prodId]").html("Product")
                    }
                    else if (_strTreeInterface == "SFC") {
                        $("#dgvParam th[data-field=kode]").html("FundCode")
                        $("#dgvParam th[data-field=deskripsi]").html("FundDescription")
                        $("#dgvParam th[data-field=prodId]").html("Product")
                    }
                    else if (_strTreeInterface == "SBC") {
                        $("#dgvParam th[data-field=kode]").html("BankCode")
                        $("#dgvParam th[data-field=deskripsi]").html("BankDescription")
                        $("#dgvParam th[data-field=prodId]").html("Product")
                    }
                }
                else if (_strTreeInterface == "RDD") {
                    grid.showColumn('productCode');
                    grid.showColumn('tanggalValuta');

                    $("#dgvParam th[data-field=tanggalValuta]").html("ValueDate")
                }
                else if (_strTreeInterface == "GFP") {
                    grid.showColumn('productCode');
                    grid.showColumn('desc2');
                    grid.showColumn('tglEfektif');
                    grid.showColumn('tglExpire');

                    $("#dgvParam th[data-field=kode]").html("GiftCode")
                    $("#dgvParam th[data-field=deskripsi]").html("MinSubscription")
                    $("#dgvParam th[data-field=prodId]").html("Term")
                }
                else {
                    grid.hideColumn('officeId');
                }
            }
            else {
                $("#dgvParam").data('kendoGrid').dataSource.data([]);
                $("#dgvParam").empty();
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
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };
    } else {
        $("#dgvParam").empty();
    }
}
function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var checkB = name.indexOf("checkB") > -1 || name.indexOf("checkB") > -1;
        var lastUpdate = name.indexOf("lastUpdate") > -1 || name.indexOf("lastUpdate") > -1;
        var value = 'id';
        return {
            headerTemplate: checkB ? "Pilih" : name,
            template: checkB ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (checkB) { #" +
                "checked='checked'" +
                "# } #" +
                "/>"
                : lastUpdate ? "#= kendo.toString(kendo.parseDate(lastUpdate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                : columnNames,
            field: name,
            width: 150,
            title: name
        };
    })
}

function subApprove(isApprove) {
    var grid = $("#dgvParam").data("kendoGrid");
    grid.refresh();
    var dataItems = "";
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.checkB == true) {
            dataItems += dataItem.id + "|";
        }
    })
    if (dataItems == "")
        swal("Warning", "No data selected!", "warning");
    else {
        var message;
        if (isApprove == true)
            message = 'approve';
        else
            message = 'reject';

        swal({
            title: "Are you sure to " + message + " this data?",
            text: "",
            type: "warning",
            showCancelButton: true,
            confirmButtonClass: 'btn-info',
            confirmButtonText: "Yes, " + message + " it!"
        },
            function () {
                $.ajax({
                    type: "POST",
                    url: "/Otorisasi/AuthorizeGlobalParam",
                    data: { listId: dataItems, InterfaceId: _strTreeInterface, isApprove: isApprove },
                    beforeSend: function () {
                        $("#load_screen").show();
                    },
                    success: function (data) {
                        if (data.blnResult) {
                            if (isApprove == true)
                                setTimeout(function () { swal("Approved!", "Your data has been aprroved", "success") }, 500); 
                            else
                                setTimeout(function () { swal("Rejected!", "Your data has been rejected", "success") }, 500); 
                        } else {
                            setTimeout(function () { swal("Warning", data.ErrMsg, "warning")}, 500); 
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