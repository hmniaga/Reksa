var strTransaction;
var strAction;
var strJenisTrx;
$(document).ready(function load() {
    var gridOptions = {
        height: 300
    };
    $("#dataGridView1").kendoGrid(gridOptions);
    $("#dataGridView2").kendoGrid(gridOptions);
    $("#dataGridView3").kendoGrid(gridOptions);
    subDisableAllTrxControl(false);
});
function subRefresh() {
    PopulateVerifyData("");
}
function PopulateVerifyData(RefID) {
    if ($("#radioNewAccount").prop('checked') == true) {
        strTransaction = "ACC";
    } else if ($("#radioTransaction").prop('checked') == true) {
        strTransaction = "TRX";
    }
    else if ($("#radioReverse").prop('checked') == true) {
        strTransaction = "REV";
    }
    else if ($("#radioBlocking").prop('checked') == true) {
        strTransaction = "BLK";
    }
    else {
        strTransaction = "";
    }

    if ($("#radioAllTrx").prop('checked') == true) {
        strJenisTrx = "ALL";
    }
    else if ($("#radioSubs").prop('checked') == true) {
        strJenisTrx = "SUBS";
    }
    else if ($("#radioRedemption").prop('checked') == true) {
        strJenisTrx = "REDEMP";
    }
    else if ($("#radioRDB").prop('checked') == true) {
        strJenisTrx = "SUBSRDB";
    }
    else if ($("#radioSwitching").prop('checked') == true) {
        strJenisTrx = "SWCNONRDB";
    }
    else if ($("#radioSwcRDB").prop('checked') == true) {
        strJenisTrx = "SWCRDB";
    }
    else if ($("#radioBooking").prop('checked') == true) {
        strJenisTrx = "BOOK";
    }
    else {
        strJenisTrx = "";
    }
    if ($("#radioNew").prop('checked') == true) {
        strAction = "ADD";
    }
    else if ($("#radioEdit").prop('checked') == true) {
        strAction = "EDIT";
    }

    var gridView1 = $("#dataGridView1").data("kendoGrid");
    var gridView2 = $("#dataGridView2").data("kendoGrid");
    var gridView3 = $("#dataGridView3").data("kendoGrid");
    var rowsView2 = 0;

    $.ajax({
        type: 'GET',
        url: '/Otorisasi/PopulateVerifyAuthBS',
        data: { Authorization: strTransaction, TypeTrx: strJenisTrx, strAction: strAction, NoReferensi: RefID },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                if (ObjectLength(data.dsResult) != 0) {
                    if (RefID == "") {
                        var gridView1data = populateGrid(data.dsResult.table);
                        gridView1.setOptions(gridView1data);

                        $("#dataGridView2").empty();
                        $("#dataGridView3").empty();

                        if (ObjectLength(data.dsResult) == 2) {
                            var gridView2Data = populateGridDetail(data.dsResult.table1);
                            gridView2.setOptions(gridView2Data);
                            gridView2.hideColumn('checkB');
                        }

                        if ((strTransaction == "TRX") || (strTransaction == "REV")) {
                            gridView1.hideColumn('tranType');
                            gridView1.hideColumn('noCIFBigInt');
                            gridView1.hideColumn('noCIF19');

                            gridView2.showColumn('checkB');

                            $("#groupBox1").text('Data Master');
                            $("#groupBox2").text('');
                            $("#groupBox3").text('');
                        } else {
                            if (strAction == "ADD") {
                                $("#groupBox1").text('Data Master');
                                $("#groupBox2").text('');
                                $("#groupBox3").text('');
                            }
                            else if (strAction == "EDIT") {
                                $("#groupBox1").text('Data Lama');
                                $("#groupBox2").text('Data Baru');
                                $("#groupBox3").text('');
                            }
                            else {
                                $("#groupBox1").text('');
                                $("#groupBox2").text('');
                                $("#groupBox3").text('');
                            }
                        }
                    }
                    else {
                        if (ObjectLength(data.dsResult) >= 2 && data.dsResult.table1.length != 0) {
                            var gridView2Data = populateGridDetail(data.dsResult.table1);
                            gridView2.setOptions(gridView2Data);
                            var datagridView2 = gridView2.dataSource.data();
                            $.each(datagridView2, function (i, row) {
                                var ValueDate = row.tglValuta;
                                var CurrentDate = row.today;

                                if (ValueDate > CurrentDate) {
                                    $('tr[data-uid="' + row.uid + '"] ').css("background-color", "salmon"); //salmon
                                }
                                else {
                                    $('tr[data-uid="' + row.uid + '"] ').css("background-color", "#ffffff");  //putih
                                }
                            });
                            
                            if ((strTransaction == "TRX") || (strTransaction == "REV")) {
                                gridView2.hideColumn('tranType');                               

                                if (strAction == "ADD") {
                                    $("#groupBox2").text('Data Transaksi');
                                }
                                else if (strAction == "EDIT") {
                                    $("#groupBox2").text('Data Lama');
                                }
                                else {
                                    $("#groupBox2").text('');
                                }

                                if (strJenisTrx == "SUBS") {
                                    gridView2.hideColumn('kodeProdukSwcOut');
                                    gridView2.hideColumn('kodeProdukSwcIn');
                                    gridView2.hideColumn('clientCodeSwcOut');
                                    gridView2.hideColumn('clientCodeSwcIn');
                                    gridView2.hideColumn('unitTransaksi');
                                    gridView2.hideColumn('jangkaWaktu');
                                    gridView2.hideColumn('jatuhTempo');
                                    gridView2.hideColumn('frekPendebetan');
                                    gridView2.hideColumn('asuransi');
                                    gridView2.hideColumn('autoRedemption');
                                    gridView2.hideColumn('today');
                                }
                                else if (strJenisTrx == "REDEMP") {
                                    gridView2.hideColumn('kodeProdukSwcOut');
                                    gridView2.hideColumn('kodeProdukSwcIn');
                                    gridView2.hideColumn('clientCodeSwcOut');
                                    gridView2.hideColumn('clientCodeSwcIn');
                                    gridView2.hideColumn('jangkaWaktu');
                                    gridView2.hideColumn('jatuhTempo');
                                    gridView2.hideColumn('frekPendebetan');
                                    gridView2.hideColumn('asuransi');
                                    gridView2.hideColumn('autoRedemption');
                                    gridView2.hideColumn('mataUang');
                                    gridView2.hideColumn('nominalTransaksi');
                                    gridView2.hideColumn('fullAmount');
                                    gridView2.hideColumn('today');
                                }
                                else if (strJenisTrx == "SUBSRDB") {
                                    gridView2.hideColumn('kodeProdukSwcOut');
                                    gridView2.hideColumn('kodeProdukSwcIn');
                                    gridView2.hideColumn('clientCodeSwcOut');
                                    gridView2.hideColumn('clientCodeSwcIn');
                                    gridView2.hideColumn('unitTransaksi');
                                    gridView2.hideColumn('fullAmount');
                                    gridView2.hideColumn('today');
                                }
                                else if (strJenisTrx == "SWCNONRDB") {
                                    gridView2.hideColumn('kodeProduk');
                                    gridView2.hideColumn('clientCode');
                                    gridView2.hideColumn('nominalTransaksi');
                                    gridView2.hideColumn('fullAmount');
                                    gridView2.hideColumn('jangkaWaktu');
                                    gridView2.hideColumn('jatuhTempo');
                                    gridView2.hideColumn('frekPendebetan');
                                    gridView2.hideColumn('asuransi');
                                    gridView2.hideColumn('autoRedemption');
                                    gridView2.hideColumn('today');
                                }
                                else if (strJenisTrx == "SWCRDB") {
                                    gridView2.hideColumn('kodeProduk');
                                    gridView2.hideColumn('clientCode');
                                    gridView2.hideColumn('nominalTransaksi');
                                    gridView2.hideColumn('fullAmount');
                                    gridView2.hideColumn('today');
                                }
                                else if (strJenisTrx == "BOOK") {
                                    gridView2.hideColumn('clientCode');
                                    gridView2.hideColumn('kodeProdukSwcOut');
                                    gridView2.hideColumn('kodeProdukSwcIn');
                                    gridView2.hideColumn('clientCodeSwcOut');
                                    gridView2.hideColumn('clientCodeSwcIn');
                                    gridView2.hideColumn('fullAmount');
                                    gridView2.hideColumn('initTransaksi');
                                    gridView2.hideColumn('jangkaWaktu');
                                    gridView2.hideColumn('jatuhTempo');
                                    gridView2.hideColumn('frekPendebetan');
                                    gridView2.hideColumn('asuransi');
                                    gridView2.hideColumn('autoRedemption');
                                    gridView2.hideColumn('today');
                                }
                            }
                            else {
                                if (strAction == "ADD") {
                                    $("#groupBox2").text('');
                                }
                                else if (strAction == "EDIT") {
                                    $("#groupBox2").text('Data Baru');
                                }
                                else {
                                    $("#groupBox2").text('');
                                }
                            }
                        }
                        if (ObjectLength(data.dsResult) == 3 && data.dsResult.table2.length != 0) {
                            var gridView3Data = populateGridDetail(data.dsResult.table2);
                            gridView3.setOptions(gridView3Data);

                            if ((strTransaction == "TRX") && (strAction == "EDIT")) {
                                CariPerbedaan();
                            }
                            var datagridView3 = gridView3.dataSource.data();
                            $.each(datagridView3, function (i, row) {
                                var ValueDate = row.tglValuta;
                                var CurrentDate = row.today;

                                if (ValueDate > CurrentDate) {
                                    $('tr[data-uid="' + row.uid + '"] ').css("background-color", "salmon"); //salmon
                                }
                                else {
                                    $('tr[data-uid="' + row.uid + '"] ').css("background-color", "#ffffff");  //putih
                                }
                            });

                            if ((strTransaction == "TRX") || (strTransaction == "REV")) {
                                gridView3.hideColumn('tranType');

                                if (strAction == "EDIT") {
                                    $("#groupBox3").text('Data Baru');
                                }
                                else {
                                    $("#groupBox3").text('');
                                }

                                if (strJenisTrx == "SUBS") {
                                    gridView3.hideColumn('kodeProdukSwcOut');
                                    gridView3.hideColumn('kodeProdukSwcIn');
                                    gridView3.hideColumn('clientCodeSwcOut');
                                    gridView3.hideColumn('clientCodeSwcIn');
                                    gridView3.hideColumn('unitTransaksi');
                                    gridView3.hideColumn('jangkaWaktu');
                                    gridView3.hideColumn('jatuhTempo');
                                    gridView3.hideColumn('frekPendebetan');
                                    gridView3.hideColumn('asuransi');
                                    gridView3.hideColumn('autoRedemption');
                                    gridView3.hideColumn('today');
                                }
                                else if (strJenisTrx == "REDEMP") {
                                    gridView3.hideColumn('kodeProdukSwcOut');
                                    gridView3.hideColumn('kodeProdukSwcIn');
                                    gridView3.hideColumn('clientCodeSwcOut');
                                    gridView3.hideColumn('clientCodeSwcIn');
                                    gridView3.hideColumn('jangkaWaktu');
                                    gridView3.hideColumn('jatuhTempo');
                                    gridView3.hideColumn('frekPendebetan');
                                    gridView3.hideColumn('asuransi');
                                    gridView3.hideColumn('autoRedemption');
                                    gridView3.hideColumn('mataUang');
                                    gridView3.hideColumn('nominalTransaksi');
                                    gridView3.hideColumn('fullAmount');
                                    gridView3.hideColumn('today');
                                }
                                else if (strJenisTrx == "SUBSRDB") {
                                    gridView3.hideColumn('kodeProdukSwcOut');
                                    gridView3.hideColumn('kodeProdukSwcIn');
                                    gridView3.hideColumn('clientCodeSwcOut');
                                    gridView3.hideColumn('clientCodeSwcIn');
                                    gridView3.hideColumn('unitTransaksi');
                                    gridView3.hideColumn('fullAmount');
                                    gridView3.hideColumn('today');
                                }
                                else if (strJenisTrx == "SWCNONRDB") {
                                    gridView3.hideColumn('kodeProduk');
                                    gridView3.hideColumn('clientCode');
                                    gridView3.hideColumn('nominalTransaksi');
                                    gridView3.hideColumn('fullAmount');
                                    gridView3.hideColumn('jangkaWaktu');
                                    gridView3.hideColumn('jatuhTempo');
                                    gridView3.hideColumn('frekPendebetan');
                                    gridView3.hideColumn('asuransi');
                                    gridView3.hideColumn('autoRedemption');
                                    gridView3.hideColumn('today');
                                }
                                else if (strJenisTrx == "SWCRDB") {
                                    gridView3.hideColumn('kodeProduk');
                                    gridView3.hideColumn('clientCode');
                                    gridView3.hideColumn('nominalTransaksi');
                                    gridView3.hideColumn('fullAmount');
                                    gridView3.hideColumn('today');
                                }
                                else if (strJenisTrx == "BOOK") {
                                    gridView3.hideColumn('clientCode');
                                    gridView3.hideColumn('kodeProdukSwcOut');
                                    gridView3.hideColumn('kodeProdukSwcIn');
                                    gridView3.hideColumn('clientCodeSwcIn');
                                    gridView3.hideColumn('fullAmount');
                                    gridView3.hideColumn('unitTransaksi');
                                    gridView3.hideColumn('jangkaWaktu');
                                    gridView3.hideColumn('jatuhTempo');
                                    gridView3.hideColumn('frekPendebetan');
                                    gridView3.hideColumn('asuransi');
                                    gridView3.hideColumn('autoRedemption');
                                    gridView3.hideColumn('today');
                                }
                            }
                            else {
                                $("#groupBox3").text('');
                            }
                        }
                    }
                }
            }
        }
        ,
        complete: function () {
            $("#load_screen").hide();
        }
    });
}
function CariPerbedaan() {

}

function ObjectLength(object) {
    var length = 0;
    for (var key in object) {
        if (object.hasOwnProperty(key)) {
            ++length;
        }
    }
    return length;
};
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
            change: dataGridView1_CellClick,
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };

    } else {
        $("#dataGridView1").empty();
    }
}
function populateGridDetail(response) {
    if (response.length > 0) {
        var columns = generateColumnsDetail(response);
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
        var isIdColumn = name.indexOf("checkB") > -1 || name.indexOf("CheckBox") > -1;
        var value;
        value = 'noReferensi';
        return {
            headerTemplate: isIdColumn ? "Pilih" : name,
            template: isIdColumn ? "<input type='checkbox' onclick='onCheckBoxClick(this)' value= '#= " + value + " #'" +
                "# if (checkB) { #" +
                "checked='checked'" +
                "# } #" +
                "/>" : columnNames,
            field: name,
            width: isIdColumn ? 50 : 180,
            title: isIdColumn ? "CheckBox" : name
        };
    })
}
function generateColumnsDetail(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        var isIdColumn = name.indexOf("checkB") > -1 || name.indexOf("CheckBox") > -1;
        var value;
        value = 'tranId';
        return {
            headerTemplate: isIdColumn ? "Pilih" : name,
            template: isIdColumn ? "<input type='checkbox' onclick='onCheckBoxClickDetail(this)' value= '#= " + value + " #'" +
                "# if (checkB) { #" +
                "checked='checked'" +
                "# } #" +
                "/>" : columnNames,
            field: name,
            width: isIdColumn ? 50 : 180,
            title: isIdColumn ? "CheckBox" : name
        };
    })
}
function subAcceptReject(IsAccept) {
    if ($('#radioNewAccount').prop('checked') == true) {
        strTransaction = "ACC";
    }
    else if ($('#radioTransaction').prop('checked') == true) {
        strTransaction = "TRX";
    }
    else if ($('#radioReverse').prop('checked') == true) {
        strTransaction = "REV";
    }
    else if ($('#radioBlocking').prop('checked') == true) {
        strTransaction = "BLK";
    }
    else {
        strTransaction = "";
    }

    if (strTransaction == "ACC") {
        var gridMain = $("#dataGridView1").data("kendoGrid");
        var dataItems = "";

        gridMain.refresh();
        gridMain.tbody.find("tr[role='row']").each(function () {
            var dataItem = gridMain.dataItem(this);
            if (dataItem.checkB == true) {
                dataItems += dataItem.nasabahId + "|";
            }
        })

        $.ajax({
            type: "POST",
            url: '/Otorisasi/AuthorizeNasabah',
            data: { listNasabahId: dataItems, isApprove: IsAccept },
            beforeSend: function () {
                $("#load_screen").show();
            },
            success: function (data) {
                if (data.blnResult == true) {
                    if (IsAccept) {
                        swal("Approved", "Proses Otorisasi Berhasil", "success");
                    } else {
                        swal("Rejected", "Proses Reject Berhasil", "success");
                    }
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
    else if (strTransaction == "BLK") {
        var gridMain = $("#dataGridView1").data("kendoGrid");
        var dataItems = "";

        gridMain.refresh();
        gridMain.tbody.find("tr[role='row']").each(function () {
            var dataItem = gridMain.dataItem(this);
            if (dataItem.checkB == true) {
                dataItems += dataItem.kodeBlokir + "|";
            }
        })

        $.ajax({
            type: "POST",
            url: '/Otorisasi/AuthorizeBlocking',
            data: { listBlockId: dataItems, isApprove: IsAccept },
            success: function (data) {
                if (data.blnResult == true) {
                    if (IsAccept) {
                        swal("Approved", "Proses Otorisasi Berhasil", "success");
                    } else {
                        swal("Rejected", "Proses Reject Berhasil", "success");
                    }
                }
                else {
                    swal("Warning", data.ErrMsg, "warning");
                }
            }
        });
    }
    else if (strTransaction == "TRX") {
        var IsEdit = false;
        if ($('#radioNew').prop(':checked') == true) {
            IsEdit = false;
        }
        else {
            IsEdit = true;
        }
        var strDesc = "";
        if (IsAccept == true) {
            strDesc = "approve";
        }
        else {
            strDesc = "reject";
        }
        var selectedDetail = 0;
        var gridDetail = $("#dataGridView2").data("kendoGrid");
        if (gridDetail == null) {
            swal({
                title: "Warning",
                text: "Harap memilih data detail transaksi yang akan di" + strDesc + "!",
                type: "warning",
                showCancelButton: false,
                confirmButtonClass: 'btn-info',
                confirmButtonText: "OK",
                closeOnConfirm: true
            });
        }
        else {
            gridDetail.refresh();
            gridDetail.tbody.find("tr[role='row']").each(function () {
                var dataItem = gridDetail.dataItem(this);
                if (dataItem.checkB == true) {
                    selectedDetail = selectedDetail + 1;
                }
            })

            var selectedMain = 0;
            var gridMain = $("#dataGridView1").data("kendoGrid");
            gridMain.refresh();
            gridMain.tbody.find("tr[role='row']").each(function () {
                var dataItem = gridMain.dataItem(this);
                if (dataItem.checkB == true) {
                    selectedMain = selectedMain + 1;
                }
            })

            if (selectedDetail == 0) {
                //alert("Harap memilih data master transaksi yang akan di" + strDesc + "!", "warning");
                swal("Warning", "Harap memilih data master transaksi yang akan di" + strDesc + "!", "warning");
                return;
            }
            if (selectedDetail > 1) {
                swal("Warning", "Harap checklist hanya 1 nomor referensi saja!", "warning");
                return;
            }
            if (selectedMain == 0) {
                swal("Warning", "Harap memilih data detail transaksi yang akan di" + strDesc + "!", "warning");
                return;
            }
            if ((IsAccept == true) && (IsEdit == false)) {

            }

            var dataItems = "";
            gridDetail.refresh();
            gridDetail.tbody.find("tr[role='row']").each(function () {
                var dataItem = gridDetail.dataItem(this);
                console.log(dataItem.tranId);
                if (dataItem.checkB == true) {
                    if (dataItem.tranType == 1 || dataItem.tranType == 8) {
                        //dataItems += dataItem.tranId + "|";
                        if (IsAccept) {
                            CekUmurNasabah(dataItem.tranId, "REKSA2", function (ErrMessage2) {
                                if (ErrMessage2 != "") {
                                    setTimeout(function () { swal("Warning", ErrMessage2, "warning") }, 500);
                                }
                            });
                            CekRiskProfile(dataItem.tranId, "REKSA2", function (ErrMessage3) {
                                if (ErrMessage3 != "") {
                                    setTimeout(function () { swal("Warning", ErrMessage3, "warning") }, 500);
                                }
                            });
                            CekTieringNotification(dataItem.tranId, "REKSA2", function (ErrMessage) {
                                if (ErrMessage != "") {
                                    setTimeout(function () { swal("Warning", ErrMessage, "warning") }, 500);
                                }
                            });
                        }
                        $.ajax({
                            type: "POST",
                            url: '/Otorisasi/AuthorizeTransaction_BS',
                            data: { listTranId: dataItem.tranId, isApprove: IsAccept },
                            success: function (data) {
                                if (data.blnResult == true) {
                                    if (IsAccept) {
                                        setTimeout(function () { swal("Approved", "Proses Approve Kode Transaksi :" + dataItem.kodeTransaksi + " Berhasil", "success") }, 500);
                                    } else {
                                        setTimeout(function () { swal("Rejected", "Proses Reject Kode Transaksi :" + dataItem.kodeTransaksi + " Berhasil", "success") }, 500);
                                    }
                                }
                                else {
                                    setTimeout(function () { swal("Warning", data.ErrMsg, "warning") }, 500);
                                }
                            }
                        });
                    }
                    else if (dataItem.tranType == 3) {
                        //dataItems += dataItem.tranId + "|";
                        if (IsAccept) {
                            CekTieringNotification(dataItem.tranId, "REKSA2", function (ErrMessage) {
                                if (ErrMessage != "") {
                                    setTimeout(function () { swal("Warning", ErrMessage, "warning") }, 500);
                                }
                            });
                        }
                        $.ajax({
                            type: "POST",
                            url: '/Otorisasi/AuthorizeTransaction_BS',
                            data: { listTranId: dataItem.tranId, isApprove: IsAccept },
                            success: function (data) {
                                if (data.blnResult == true) {
                                    if (IsAccept) {
                                        setTimeout(function () { swal("Approved", "Proses Approve Kode Transaksi :" + dataItem.kodeTransaksi + " Berhasil", "success") }, 500);
                                    } else {
                                        setTimeout(function () { swal("Rejected", "Proses Reject Kode Transaksi :" + dataItem.kodeTransaksi + " Berhasil", "success") }, 500);
                                    }
                                }
                                else {
                                    setTimeout(function () { swal("Warning", data.ErrMsg, "warning") }, 500);
                                }
                            }
                        });
                    }
                    else if (dataItem.tranType == 6 || dataItem.tranType == 9) {
                        //dataItems += dataItem.TranId + "|";
                        if (IsAccept) {
                            CekUmurNasabah(dataItem.tranId, "REKSA7", function (ErrMessage2) {
                                if (ErrMessage2 != "") {
                                    setTimeout(function () { swal("Warning", ErrMessage2, "warning") }, 500);
                                }
                            });
                            CekRiskProfile(dataItem.tranId, "REKSA7", function (ErrMessage3) {
                                if (ErrMessage3 != "") {
                                    setTimeout(function () { swal("Warning", ErrMessage3, "warning") }, 500);
                                }
                            });
                            CekTieringNotification(dataItem.tranId, "REKSA7", function (ErrMessage) {
                                if (ErrMessage != "") {
                                    setTimeout(function () { swal("Warning", ErrMessage, "warning") }, 500);
                                }
                            });
                        }
                        $.ajax({
                            type: "POST",
                            url: '/Otorisasi/AuthorizeSwitching_BS',
                            data: { listTranId: dataItem.tranId, isApprove: IsAccept },
                            success: function (data) {
                                if (data.blnResult == true) {
                                    if (IsAccept) {
                                        setTimeout(function () { swal("Approved", "Proses Approve Kode Transaksi :" + dataItem.kodeTransaksi + " Berhasil", "success") }, 500);
                                    } else {
                                        setTimeout(function () { swal("Rejected", "Proses Reject Kode Transaksi :" + dataItem.kodeTransaksi + " Berhasil", "success") }, 500);
                                    }
                                }
                                else {
                                    setTimeout(function () { swal("Warning", data.ErrMsg, "warning") }, 500);
                                }
                            }
                        });

                    }
                    else if (dataItem.tranType == 7) {
                        dataItems += dataItem.tranId + "|";
                        if (IsAccept) {
                            CekUmurNasabah(dataItem.tranId, "REKSA3", function (ErrMessage2) {
                                if (ErrMessage2 != "") {
                                    setTimeout(function () { swal("Warning", ErrMessage2, "warning") }, 500);
                                }
                            });
                            CekRiskProfile(dataItem.tranId, "REKSA3", function (ErrMessage3) {
                                if (ErrMessage3 != "") {
                                    setTimeout(function () { swal("Warning", ErrMessage3, "warning") }, 500);
                                }
                            });
                        }
                        $.ajax({
                            type: "POST",
                            url: '/Otorisasi/AuthorizeBooking',
                            data: { listBookingId: dataItem.tranId, isApprove: IsAccept },
                            success: function (data) {
                                if (data.blnResult == true) {
                                    if (IsAccept) {
                                        setTimeout(function () { swal("Approved", "Proses Approve Kode Booking :" + dataItem.kodeTransaksi + " Berhasil", "success") }, 500);
                                    } else {
                                        setTimeout(function () { swal("Rejected", "Proses Reject Kode Booking :" + dataItem.kodeTransaksi + " Berhasil", "success") }, 500);
                                    }
                                }
                                else {
                                    setTimeout(function () { swal("Warning", data.ErrMsg, "warning") }, 500);
                                }
                            }
                        });
                    }
                    else {
                        setTimeout(function () { swal("Warning", "Tipe Transaksi tidak dikenali!", "warning") }, 500);
                    }
                }
            })
        }
    }
    else if (strTransaction == "REV") {
        var gridView2 = $("#dataGridView2").data("kendoGrid");
        var selectedTranId = "";
        var selectedTranIdSwc = "";
        var intJumlah = 0;
        gridView2.refresh();
        gridView2.tbody.find("tr[role='row']").each(function () {
            var dataItem = gridView2.dataItem(this);
            if (dataItem.checkB == true) {
                intJumlah = intJumlah + 1;
                if (dataItem.tranType == 1 || dataItem.tranType == 3 || dataItem.tranType == 8) {
                    selectedTranId += dataItem.tranId + "|";
                } else if (dataItem.tranType == 6 || dataItem.tranType == 9) {
                    selectedTranIdSwc += dataItem.tranId + "|";
                }
            }
        })
        if (intJumlah != "") {
            if (selectedTranId != "") {
                $.ajax({
                    type: "POST",
                    url: '/Otorisasi/AuthorizeTranReversal',
                    data: { listTranId: selectedTranId, isApprove: IsAccept },
                    success: function (data) {
                        if (data.blnResult == true) {
                            if (selectedTranIdSwc != "") {
                                $.ajax({
                                    type: "POST",
                                    url: '/Otorisasi/AuthorizeSwcReversal',
                                    data: { listTranId: selectedTranIdSwc, isApprove: IsAccept },
                                    success: function (data) {
                                        if (data.blnResult == true) {
                                            if (IsAccept) {
                                                setTimeout(function () { swal("Approved", "Proses Otorisasi Berhasil", "success") }, 500);
                                            } else {
                                                setTimeout(function () { swal("Rejected", "Proses Reject Berhasil", "success") }, 500);
                                            }
                                        }
                                        else {
                                            setTimeout(function () { swal("Warning", data.ErrMsg, "warning") }, 500);
                                        }
                                    }
                                });
                            }
                            else {
                                if (IsAccept) {
                                    setTimeout(function () { swal("Approved", "Proses Otorisasi Berhasil", "success") }, 500);
                                } else {
                                    setTimeout(function () { swal("Rejected", "Proses Reject Berhasil", "success") }, 500);
                                }
                            }
                        }
                        else {
                            setTimeout(function () { swal("Warning", data.ErrMsg, "warning") }, 500);
                        }

                    }
                });
            }
        } else {
            setTimeout(function () { swal("Warning", "Harap memilih data detail transaksi yang akan direverse!", "warning") }, 500);
        }
    }
    subRefresh();
}
function subDisableAllTrxControl(IsEnabled) {
    $("#radioAllTrx").prop('disabled', !IsEnabled);
    $("#radioSubs").prop('disabled', !IsEnabled);
    $("#radioRedemption").prop('disabled', !IsEnabled);
    $("#radioRDB").prop('disabled', !IsEnabled);
    $("#radioSwitching").prop('disabled', !IsEnabled);
    $("#radioSwcRDB").prop('disabled', !IsEnabled);
    $("#radioBooking").prop('disabled', !IsEnabled);
}
function subDisableAllActionControl(IsEnabled) {
    $("#radioNew").prop('disabled', !IsEnabled);
    $("#radioEdit").prop('disabled', !IsEnabled);
}
function CekUmurNasabah(SelectedId, TreeId, result) {
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/CekUmurNasabah',
        data: { SelectedId: SelectedId, TreeId: TreeId },
        success: function (data) {
            result(data.ErrMsg);
        }
    });
}
function CekRiskProfile(SelectedId, TreeId, result) {
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/CekRiskProfile',
        data: { SelectedId: SelectedId, TreeId: TreeId },
        success: function (data) {
            result(data.ErrMsg);
        }
    });
}
function CekTieringNotification(SelectedId, TreeId, result) {
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/CekTieringNotification',
        data: { SelectedId: SelectedId, TreeId: TreeId },
        success: function (data) {
            result(data.ErrMsg);
        }
    });
}