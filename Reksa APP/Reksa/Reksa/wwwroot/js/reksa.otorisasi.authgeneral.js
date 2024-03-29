﻿var treeid;
var treename;
var SelectedTree;

$(document).ready(function () {
    var gridOptions = {
        height: 400
    };
    $("#GridOtorisasi").kendoGrid(gridOptions);
    $("#GridOtorisasiDetail").kendoGrid(gridOptions);
});

function populateGrid(response) {
    var columns = generateColumns(response);
    var gridOptions = {
        dataSource: {
            transport: {
                read: function (options) {
                    options.success(response);
                }
            },
            pageSize: 10,
            page: 1
        },
        change: onRowOtorisasiSelect,
        columns: columns,
        pageable: true,
        selectable: true,
        height: 400
    };
    // reuse the same grid, swapping its options as needed
    var grid = $("#GridOtorisasi").data("kendoGrid");
    if (grid) {
        grid.setOptions(gridOptions);
        grid.select("tr:eq(0)");
    } else {
        $("#GridOtorisasi").kendoGrid(gridOptions);
    }
}

function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var isIdColumn = name.indexOf("checkB") > -1 || name.indexOf("CheckBox") > -1;
        var tanggalValuta = name.indexOf("tanggalValuta") > -1 || name.indexOf("tanggalValuta") > -1;
        var dateInput = name.indexOf("dateInput") > -1 || name.indexOf("dateInput") > -1;

        var value;
        if (treename == 'Transaksi') {
            value = 'tranId';
        }
        else if (treename == 'Product') {
            value = 'prodId';
        }
        else if (treeid == 'REKBI1' || treeid == 'REKBI4' || treeid == 'REKBI8') {
            value = 'billId';
        }
        else if (treeid == 'REKPO4' || treeid == 'REKWS3') {
            value = 'id';
        }
        return {
            headerTemplate: isIdColumn ? "<input type='checkbox'  id='chkSelectAll' onclick='checkAll(this)' />" : name,
            template: isIdColumn ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (checkB) { #" +
                "checked='checked'" +
                "# } #" +
                "/>"
                : tanggalValuta ? "#= kendo.toString(kendo.parseDate(tanggalValuta, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                    : dateInput ? "#= kendo.toString(kendo.parseDate(dateInput, 'yyyy-MM-dd'), 'dd/MM/yyyy HH:mm:ss') #"
                        : columnNames,
            field: name,
            width: isIdColumn ? 50 : 200,
            title: isIdColumn ? "CheckBox" : name
        };
    })
}

function populateGridDetail(rawData) {
    var rawData,
        data = [],
        dataLength,
        propertiesLength;
    dataLength = 2;
    propertiesLength = Object.keys(rawData).length;
    for (var i = 0; i < propertiesLength; i += 1) {

        data[i] = {};
        for (var j = 0; j < dataLength; j += 1) {
            var currentItem = rawData;
            var Items = Object.keys(currentItem)[i];

            if (j === 0) {
                data[i]["Items"] = Items;
            }
            data[i]["Values"] = currentItem[Items]
        }

    }

    var Datagrid = {
        dataSource: {
            data: data
        },
        columns: [
            { field: "Items", title: "Items" },
            { field: "Values", title: "Values" }
        ],
        pageable: true,
        selectable: true,
        height: 400
    };

    $("#GridOtorisasiDetail").kendoGrid(Datagrid);
    var grid = $("#GridOtorisasiDetail").data("kendoGrid");
    var items = grid.dataSource.view();
    for (var i = 0; i < items.length; i++) {
        var $row = $('#GridOtorisasiDetail').find("[data-uid='" + items[i].uid + "']");
        if (items[i].Items == "_events" || items[i].Items == "_handlers" || items[i].Items == "checkB"
            || items[i].Items == "uid" || items[i].Items == "parent") { // hide this row ...
            $row.hide();
        }
    }
}

function subApprove(isApprove) {
    var grid = $("#GridOtorisasi").data("kendoGrid");
    grid.refresh();
    var dataItems = "";
    grid.tbody.find("tr[role='row']").each(function () {
        var dataItem = grid.dataItem(this);

        if (dataItem.checkB == true) {
            if (treename == 'Transaksi') {
                dataItems += dataItem.tranId + "|";
            } else if (treename == 'Product') {
                dataItems += dataItem.prodId + "|";
            }
            else if (treeid == 'REKBI1' || treeid == 'REKBI4' || treeid == 'REKBI8') {
                dataItems += dataItem.billId + "|";
            }
            else if (treeid == 'REKPO4' || treeid == 'REKWS3') {
                dataItems += dataItem.id + "|";
            }
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
            confirmButtonText: "Yes, " + message + " it!",
            closeOnConfirm: false
        },
            function () {
                $.ajax({
                    type: "POST",
                    url: "/Otorisasi/ApproveReject",
                    data: { listId: dataItems, treeid: treeid, isApprove: isApprove },
                    success: function (data) {
                        if (data.blnResult) {
                            if (isApprove == true) {
                                subPopulateGridMain();
                                swal("Approved!", "Your data has been aprroved", "success");
                            }
                            else {
                                swal("Rejected!", "Your data has been rejected", "success");
                                subPopulateGridMain();
                            }
                        } else {
                            swal("Warning", data.ErrMsg, "warning");
                            subPopulateGridMain();
                        }
                    }
                });

            });
    }
}

function subPopulateGridMain() {
    treeid = SelectedTree.id;
    treename = SelectedTree.text;
    var strPopulate = SelectedTree.spriteCssClass;
    var SelectedId = '';
    console.log(strPopulate);
    console.log(treename);
    console.log(treeid);
    if (treename != 'Authorization') {
        $.ajax({
            type: 'GET',
            url: '/Otorisasi/PopulateGridMain',
            data: { treename: treename, strPopulate: strPopulate, SelectedId: SelectedId },
            success: function (data) {
                if (data.blnResult) {
                    $("#GridOtorisasiDetail").empty();
                    populateGrid(data.dsResult.table);

                    var grid = $("#GridOtorisasi").data("kendoGrid");

                    if (treeid == 'REKBI1' || treeid == 'REKBI4' || treeid == 'REKBI8') {
                        $("#GridOtorisasi th[data-field=billId]").html("Bill ID")
                        $("#GridOtorisasi th[data-field=billName]").html("Bill Name")
                        $("#GridOtorisasi th[data-field=debitCredit]").html("Debit/Credit")
                        $("#GridOtorisasi th[data-field=createDate]").html("Create Date")
                        $("#GridOtorisasi th[data-field=valueDate]").html("Value Date")
                        $("#GridOtorisasi th[data-field=paymentDate]").html("Payment Date")
                        $("#GridOtorisasi th[data-field=prodCode]").html("Product Code")
                        $("#GridOtorisasi th[data-field=custodyCode]").html("Custody Code")
                        $("#GridOtorisasi th[data-field=billCCY]").html("Currency")
                        $("#GridOtorisasi th[data-field=totalBill]").html("Total Bill")
                        $("#GridOtorisasi th[data-field=fee]").html("Fee")
                        $("#GridOtorisasi th[data-field=feeBased]").html("Fee Based")
                        $("#GridOtorisasi th[data-field=taxFeeBased]").html("Tax Fee Based")
                        $("#GridOtorisasi th[data-field=feeBased3]").html("Fee Based 3")
                        $("#GridOtorisasi th[data-field=feeBased4]").html("Fee Based 4")
                        $("#GridOtorisasi th[data-field=feeBased5]").html("Fee Based 5")
                    }
                    else if (treeid == 'REKPO4') {
                        $("#GridOtorisasi th[data-field=action]").html("Action")
                        $("#GridOtorisasi th[data-field=produk]").html("Produk")
                        $("#GridOtorisasi th[data-field=mataUang]").html("Mata Uang")
                        $("#GridOtorisasi th[data-field=namaPemohon]").html("Nama Pemohon")
                        $("#GridOtorisasi th[data-field=alamatPemohon]").html("Alamat Pemohon")
                        $("#GridOtorisasi th[data-field=namaPenerima]").html("Nama Penerima")
                        $("#GridOtorisasi th[data-field=alamatPenerima]").html("Alamat Penerima")
                        $("#GridOtorisasi th[data-field=beneficiaryBankCode]").html("Beneficiary Bank Code")
                        $("#GridOtorisasi th[data-field=beneficiaryAccNo]").html("Beneficiary Account")
                        $("#GridOtorisasi th[data-field=beneficiaryBankAddress]").html("Beneficiary Bank Address")
                        $("#GridOtorisasi th[data-field=paymentRemarks1]").html("Remark 1")
                        $("#GridOtorisasi th[data-field=paymentRemarks2]").html("Remark 2")
                        $("#GridOtorisasi th[data-field=noRekProduk]").html("No Rekening Produk")
                        $("#GridOtorisasi th[data-field=glBiayaFullAmt]").html("GL Biaya Full Amount")
                        $("#GridOtorisasi th[data-field=inputterNIK]").html("Inputter")
                        $("#GridOtorisasi th[data-field=inputDate]").html("Date Input")
                        grid.hideColumn('id');
                    }
                    else if (treeid == 'REKWS3') {
                        $("#GridOtorisasi th[data-field=actionType]").html("Action Type")
                        $("#GridOtorisasi th[data-field=kodeProduk]").html("Kode Produk")
                        $("#GridOtorisasi th[data-field=namaProduk]").html("Nama Produk")
                        $("#GridOtorisasi th[data-field=mataUang]").html("Mata Uang")
                        $("#GridOtorisasi th[data-field=typeReksadana]").html("Tipe Reksadana")
                        $("#GridOtorisasi th[data-field=tanggalValuta]").html("Tanggal Valuta")
                        $("#GridOtorisasi th[data-field=tampilDiIBMB]").html("Tampil Di IBMB")
                        $("#GridOtorisasi th[data-field=sehari]").html("Sehari")
                        $("#GridOtorisasi th[data-field=seminggu]").html("Seminggu")
                        $("#GridOtorisasi th[data-field=sebulan]").html("Sebulan")
                        $("#GridOtorisasi th[data-field=setahun]").html("Setahun")
                        $("#GridOtorisasi th[data-field=userInput]").html("User Input")
                        $("#GridOtorisasi th[data-field=userInputName]").html("User Input Name")
                        $("#GridOtorisasi th[data-field=dateInput]").html("Date Input")
                        grid.hideColumn('id');
                    }

                }
                else {
                    $("#GridOtorisasi").empty();
                    $("#GridOtorisasiDetail").empty();
                }
            }
        });
    }
}
