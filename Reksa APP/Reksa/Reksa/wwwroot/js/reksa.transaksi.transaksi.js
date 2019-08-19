var _strTabName;

var _intType;
var IsSubsNew = false;
var IsRedempAll;
var IsSwitchingAll;
var intPeriod = 0;
var Fee = 0;
var PercentFee = 0;
var ByPercent = false;
var strFeeCurr = "";

var globalJatuhTempoRDB;
var globalJatuhTempoSwcRDB;

var _NAVSwcOutNonRDB = 0;
var _NAVSwcInNonRDB = 0;
var OutstandingUnitSwcIn = 0;

var _StatusTransaksiSubs;
var _StatusTransaksiRDB;
var _StatusTransaksiRedemp;

var IsSwitchingRDBSebagian;

var Today = new Date();
$(document).ready(function load () {
    $('#tabs a[href="#tab-subscription"]').trigger('click');
    $("#btnRefresh").show();
    $("#btnNew").show();
    $("#btnEdit").show();
    $("#btnSave").show();
    $("#btnCancel").show();
    document.getElementById("btnSave").disabled = true;
    document.getElementById("btnCancel").disabled = true;

    _strTabName = "SUBS";

    subSetVisibleGrid(_strTabName);
    _intType = 0;
    ResetForm();
    DisableAllForm(false);
    DisableFormTrxSubs(false);
    DisableFormTrxRedemp(false);
    DisableFormTrxRDB(false);

    GetComponentSearch();
    GetKodeKantor();
    PopulateComboFrekDebet();
    //IsClickByDatagrid = false;

    ValidateOffice(strBranch, function (res) {
        $("#srcOfficeSubs_text2").val(res);
        $("#srcOfficeRedemp_text2").val(res);
        $("#srcOfficeRDB_text2").val(res);
        $("#srcOfficeSwc_text2").val(res);
        $("#srcOfficeSwcRDB_text2").val(res);
        $("#srcOfficeBooking_text2").val(res);
    });
});
function PopulateComboFrekDebet() {
    $.ajax({
        type: 'GET',
        url: '/Transaksi/PopulateComboFrekDebet',
        success: function (data) {
            $("#cmbFrekPendebetanRDB").kendoDropDownList({
                dataSource: data.list,
                dataTextField: "FrekuensiPendebetan",
                dataValueField: "FrekuensiPendebetan"
            });

            $("#cmbFrekPendebetanSwcRDB").kendoDropDownList({
                dataSource: data.list,
                dataTextField: "FrekuensiPendebetan",
                dataValueField: "FrekuensiPendebetan"
            });
        }
    });
}
function subAddSubs() {
    var strWarnMsg = '';
    var strWarnMsg2 = '';
    var strTranCode = "";
    var strNewClientCode = "";
    var _PercentageFee;
    var _NominalFee;
    var intProductId = 0;

    if ($("#btnAddSubs").text() == "Done") {
        DisableFormTrxSubs(true);
        ResetFormTrxSubsSubs();
        document.getElementById("btnEditSubs").disabled = true;
        $("#btnAddSubs").attr('class', 'btn btn-default waves-effect waves-light');
        $("#btnAddSubs").html('<span class="btn-label"><i class= "fa fa-check"></i></span >Done');
    }
    else if ($("#btnAddSubs").text() == "Add") {        
        var blnPassed = true;
        var grid = $("#dataGridViewSubs").data("kendoGrid");
        grid.refresh();
        var dataItem = grid.dataSource.view();
        if (dataItem.length >= 3) {
            swal("Warning", "Maksimal hanya dapat menambah 3 transaksi !", "warning");
            return;
        }
        if ($("#srcProductSubs_text1").val() == "") {
            swal("Warning", "Kode Produk harus diisi", "warning");
            return;
        }
        if ($("#srcCurrencySubs_text1").val() == "") {
            swal("Warning", "Mata Uang Produk harus diisi", "warning");
            return;
        }
        //if ((IsSubsNew == false) && ($("#srcClientSubs_text1").val() == "")) {
        //    swal("Warning", "Client Code harus diisi", "warning");
        //    return;
        //}
        if ($("#MoneyNomSubs").data("kendoNumericTextBox").value() == 0) {
            swal("Warning", "Nominal harus diisi", "warning");
            return;
        }
        if (($("#maskedRekeningSubsUSD").val() == "") && ($("#maskedRekeningSubsMC").val() == "") && ($("#srcCurrencySubs_text1").val() == "USD")) {
            swal("Warning", "Rekening USD / Multicurrency tidak boleh kosong untuk transaksi currency USD!", "warning");
            return;
        }
        if (($("#maskedRekeningSubs").val() == "") && ($("#maskedRekeningSubsMC").val() == "") && ($("#srcCurrencySubs_text1").val() == "IDR")) {
            swal("Warning", "Rekening IDR / Multicurrency tidak boleh kosong untuk transaksi currency IDR!", "warning");
            return;
        }
        grid.tbody.find("tr[role='row']").each(function () {
            var dataItem = grid.dataItem(this);
            if (dataItem.KodeProduk == $("#srcProductSubs_text1").val()) {
                swal("Warning", "Subscription ke produk " + $("#srcProductSubs_text1").val() + " sudah ada!", "warning");
                blnPassed = false;
                return;
            }
        })
        if (blnPassed) {
            intProductId = $("#ProdIdSubs").val();
            var ClientCodeSubsAdd = "";
            var res = CheckIsSubsNew($("#srcCIFSubs_text1").val(), intProductId, false);
            res.success(function (data) {
                if (data.blnResult) {
                    IsSubsNew = data.IsSubsNew;
                    ClientCodeSubsAdd = data.strClientCode;
                }
                else {
                    IsSubsNew = false;
                    ClientCodeSubsAdd = "";
                    swal("Warning", data.ErrMsg, "warning");
                }
            });

            if ($("#_ComboJenisSubs").data("kendoDropDownList").text() == "By %") {
                _PercentageFee = $("#MoneyFeeSubs").val();
                _NominalFee = $("#PercentageFeeSubs").val();
            }
            else {
                _PercentageFee = $("#PercentageFeeSubs").val();
                _NominalFee = $("#MoneyFeeSubs").val();
            }
            var MoneyNomSubs = $("#MoneyNomSubs").data("kendoNumericTextBox").value();
            var res = GenerateTranCodeAndClientCode(_strTabName, IsSubsNew, $("#srcProductSubs_text1").val(),
                $("#srcClientSubs_text1").val(), $("#srcCIFSubs_text1").val(),
                $("#checkFeeEditSubs").val(), _PercentageFee, 0
                , $("#checkFullAmtSubs").val(), _NominalFee, MoneyNomSubs, 0, false, 0, 0
                , _intType);
            res.success(function success(data) {
                if (data.blnResult) {
                    strTranCode = data.strTrancode;
                    strNewClientCode = data.strClientCode;
                    strWarnMsg = data.strWarnMsg;
                    strWarnMsg2 = data.strWarnMsg2;
                    if (strWarnMsg != '') {
                        swal({
                            title: "Information",
                            text: "Produk yang dipilih diatas ketentuan profile nasabah. Lanjutkan transaksi?",
                            type: "warning",
                            showCancelButton: true,
                            confirmButtonClass: 'btn-info',
                            confirmButtonText: "Yes",
                            closeOnConfirm: false,
                            closeOnCancel: false
                        },
                            function (isConfirm) {
                                if (!isConfirm) {
                                    swal("Canceled", "Proses transaksi dibatalkan.", "error");
                                    return;
                                }
                                else {
                                    swal("Confirmed", "Profil Risiko produk lebih tinggi dari Profil Risiko Nasabah . PASTIKAN Nasabah sudah menandatangani kolom Profil Risiko pada Subscription/Switching Form", "success");
                                }
                            });
                    }
                    if (strWarnMsg2 != '') {
                        swal({
                            title: "Information",
                            text: strWarnMsg2,
                            type: "warning",
                            showCancelButton: true,
                            confirmButtonClass: 'btn-info',
                            confirmButtonText: "Yes",
                            closeOnConfirm: false,
                            closeOnCancel: false
                        },
                            function (isConfirm) {
                                if (!isConfirm) {
                                    swal("Canceled", "Proses transaksi dibatalkan.", "error");
                                    return;
                                }
                                else {
                                    swal("Confirmed", "", "success");
                                }
                            });
                    }

                    if (strTranCode != "") {
                        var arrSubscription = [];
                        var obj = {};
                        obj['NoTrx'] = '';
                        obj['StatusTransaksi'] = '';
                        obj['KodeProduk'] = $("#srcProductSubs_text1").val();
                        obj['NamaProduk'] = $("#srcProductSubs_text2").val();
                        obj['ClientCode'] = strNewClientCode;
                        obj["Nominal"] = MoneyNomSubs;
                        if ($('#checkFeeEditSubs').prop('checked') == true) {
                            obj["EditFeeBy"] = $("#_ComboJenisSubs").data("kendoDropDownList").text();
                        }
                        else {
                            obj["EditFeeBy"] = "";
                        }

                        obj["FullAmount"] = $("#checkFullAmtSubs").prop('checked');
                        obj["PhoneOrder"] = $("#checkPhoneOrderSubs").prop('checked');
                        var dateTglTransaksiSubs = toDate($("#dateTglTransaksiSubs").val());
                        obj['TglTrx'] = dateTglTransaksiSubs;
                        obj["CCY"] = $("#srcCurrencySubs_text1").val();
                        obj["EditFee"] = $("#checkFeeEditSubs").prop('checked');


                        obj["JenisFee"] = $("#_ComboJenisSubs").data("kendoDropDownList").value();

                        obj["IsNew"] = IsSubsNew;
                        obj["ApaDiUpdate"] = false;
                        obj["TrxTaxAmnesty"] = false;

                        if (IsSubsNew) {
                            obj["OutstandingUnit"] = 0;
                        }
                        else {
                            //int intClientId = int.Parse(cmpsrClientSubs[2].ToString());
                            //var decUnitBalance = GetLatestBalance(intClientId);
                            var res = GetLatestBalance($("#ClientIdSubs").val());
                            res.success(function (data) {
                                if (data.blnResult) {
                                    obj["OutstandingUnit"] = data.unitBalance;
                                }
                            });
                        }
                        if ($("#_ComboJenisSubs").data("kendoDropDownList").text() == "By %") {
                            obj["FeeKet"] = $("#labelFeeCurrencySubs").text();
                            obj["FeeCurr"] = $("#_KeteranganFeeSubs").text();

                            obj["NominalFee"] = $("#PercentageFeeSubs").data("kendoNumericTextBox").value();
                            obj["PctFee"] = $("#MoneyFeeSubs").data("kendoNumericTextBox").value();
                        }
                        else {
                            obj["FeeKet"] = $("#_KeteranganFeeSubs").text();
                            obj["FeeCurr"] = $("#labelFeeCurrencySubs").text();

                            obj["NominalFee"] = $("#MoneyFeeSubs").data("kendoNumericTextBox").value();
                            obj["PctFee"] = $("#PercentageFeeSubs").data("kendoNumericTextBox").value();
                        }
                        arrSubscription.push(obj);

                        var dataSet = grid.dataSource.view();
                        $.merge(arrSubscription, dataSet);

                        var dataSource = new kendo.data.DataSource(
                            {
                                data: arrSubscription
                            });
                        grid.setDataSource(dataSource);
                        grid.dataSource.pageSize(5);
                        grid.dataSource.page(1);
                        grid.select("tr:eq(0)");
                        //$("#dataGridViewSubs").data("kendoGrid").setOptions({
                        //    columns: [
                        //        { command: "destroy", width: 100 },
                        //        { field: "NoTrx", title: "No Transaksi", width: 150 },
                        //        { field: "StatusTransaksi", title: "Status", width: 100 },
                        //        { field: "KodeProduk", title: "Kode Produk", width: 150 },
                        //        { field: "NamaProduk", title: "Nama Produk", width: 300 },
                        //        { field: "ClientCode", title: "Client Code", width: 150 },
                        //        { field: "Nominal", title: "Nominal", width: 150 },
                        //        { field: "EditFeeBy", title: "Nominal", width: 150 },        
                        //        { field: "NominalFee", title: "Nominal", width: 150 },
                        //        { field: "FullAmount", title: "FullAmount", width: 150 },
                        //        { field: "PhoneOrder", title: "Phone Order", width: 150 },
                        //        { field: "JenisFee", title: "Jenis Fee", width: 150 },
                        //        { field: "PctFee", title: "Percent Fee", width: 150 },
                        //    ],
                        //    editable: "inline"
                        //});

                        subSetVisibleGrid(_strTabName);
                        ResetFormTrxSubs();
                        DisableFormTrxSubs(true);
                        document.getElementById("btnEditSubs").disabled = true;
                        document.getElementById("btnAddSubs").disabled = false;
                        //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSubs.Text1)) {
                        //    checkPhoneOrderSubs.Enabled = false;
                        //    checkPhoneOrderSubs.Checked = false;
                        //}
                        //else {
                        //    checkPhoneOrderSubs.Enabled = true;
                        //}
                    }
                    else {
                        swal("Warning", "Gagal generate kode transaksi!", "warning");
                    }
                }
                else {
                    swal("Warning", data.ErrMsg, "warning");
                }
            });
        }
    }
}
function subEditSubs() {
    if ($("#btnEditSubs").text() == "Edit") {
        DisableFormTrxSubs(true);
        $("#srcProductSubs_text1").prop('disabled', true);
        $("#srcProductSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcClientSubs_text1").prop('disabled', true);
        $("#srcClientSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        if ($("#checkFeeEditSubs").prop('checked') == true) {
            $("#_ComboJenisSubs").data('kendoDropDownList').enable(true);
            $("#MoneyFeeSubs").data("kendoNumericTextBox").enable(true);
            $("#PercentageFeeSubs").data("kendoNumericTextBox").enable(false);
        }
        //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSubs.Text1)) {
        //    checkPhoneOrderSubs.Enabled = false;
        //    checkPhoneOrderSubs.Checked = false;
        //}
        //else {
        //    checkPhoneOrderSubs.Enabled = true;
        //}
        $("#btnEditSubs").attr('class', 'btn btn-info waves-effect waves-light');
        $("#btnEditSubs").html('<span class="btn-label"><i class= "fa fa-check"></i></span >Done');
        document.getElementById("btnAddSubs").disabled = true;
    }
    else if ($("#btnEditSubs").text() == "Done") {
        swal({
            title: "Information",
            text: "Apakah akan merubah transaksi Trancode " + $("#textNoTransaksiSubs").val() + "?",
            type: "warning",
            showCancelButton: true,
            confirmButtonClass: 'btn-info',
            confirmButtonText: "Yes",
            closeOnConfirm: true,
            closeOnCancel: false
        },
            function (isConfirm) {
                if (!isConfirm) {
                    swal("Canceled", "Proses transaksi dibatalkan.", "error");
                    return;
                }
                else {
                    if (_StatusTransaksiSubs == "Rejected") {
                        setTimeout(function () { swal("Warning", "Transaksi dengan Status Rejected tidak dapat diedit!", "warning") }, 500);                        
                        return;
                    }
                    else if (_StatusTransaksiSubs == "Reversed") {
                        setTimeout(function () { swal("Warning", "Transaksi dengan Status Reversed tidak dapat diedit!", "warning") }, 500);
                        return;
                    }
                    else if (_StatusTransaksiSubs == "Cancel By PO") {
                        setTimeout(function () { swal("Warning", "Transaksi dengan Status Cancel By PO tidak dapat diedit!", "warning") }, 500);
                        return;
                    }
                    if ($("#srcProductSubs_text1").val() == "") {
                        setTimeout(function () { swal("Warning", "Kode Produk harus diisi", "warning") }, 500);
                        return;
                    }
                    if ($("#srcCurrencySubs_text1").val() == "") {
                        setTimeout(function () { swal("Warning", "Mata Uang Produk harus diisi", "warning") }, 500);
                        return;
                    }
                    if ((IsSubsNew == false) && ($("#srcClientSubs_text1").val() == "")) {
                        setTimeout(function () { swal("Warning", "Client Code harus diisi", "warning") }, 500);
                        return;
                    }
                    if ($("#MoneyNomSubs").val() == 0) {
                        setTimeout(function () { swal("Warning", "Nominal harus diisi", "warning") }, 500);
                        return;
                    }
                    var strWarnMsg2 = '';
                    var _PercentageFee;
                    var _NominalFee;
                    var grid = $("#dataGridViewSubs").data("kendoGrid");
                    grid.refresh();

                    var arrSubscription = [];
                    var NoTrx = $("#textNoTransaksiSubs").val();
                    arrSubscription = grid.dataSource.view();
                    grid.tbody.find("tr[role='row']").each(function () {
                        var dataItem = grid.dataItem(this);
                        if (NoTrx == "" || dataItem.NoTrx != NoTrx) {
                            swal("Warning", "Data tidak ditemukan", "warning");
                            return;
                        }
                        else {
                            if ($("#_ComboJenisSubs").data("kendoDropDownList").text() == "By %") {
                                _PercentageFee = $("#MoneyFeeSubs").data("kendoNumericTextBox").value();
                                _NominalFee = $("#PercentageFeeSubs").data("kendoNumericTextBox").value();
                            } else {
                                _PercentageFee = $("#PercentageFeeSubs").data("kendoNumericTextBox").value();
                                _NominalFee = $("#MoneyFeeSubs").data("kendoNumericTextBox").value();
                            }

                            var res = GenerateTranCodeAndClientCode(_strTabName, IsSubsNew, $("#srcProductSubs_text1").val(),
                                $("#srcClientSubs_text1").val(), $("#srcCIFSubs_text1").val(),
                                $("#checkFeeEditSubs").prop('checked'), _PercentageFee, 0
                                , $("#checkFullAmtSubs").prop('checked'), _NominalFee, $("#MoneyNomSubs").data("kendoNumericTextBox").value(), 0, false, 0, 0
                                , _intType);
                            res.success(function success(data) {
                                if (data.blnResult) {
                                    strTranCode = data.strTrancode;
                                    strNewClientCode = data.strClientCode;
                                    strWarnMsg = data.strWarnMsg;
                                    strWarnMsg2 = data.strWarnMsg2;
                                    if (strWarnMsg2 != '') {
                                        setTimeout(function () { swal({
                                            title: "Information",
                                            text: strWarnMsg2,
                                            type: "warning",
                                            showCancelButton: true,
                                            confirmButtonClass: 'btn-info',
                                            confirmButtonText: "Yes",
                                            closeOnConfirm: false,
                                            closeOnCancel: false
                                        },
                                            function (isConfirm) {
                                                if (!isConfirm) {
                                                    setTimeout(function () { swal("Canceled", "Proses transaksi dibatalkan.", "error") }, 500);
                                                    return;
                                                }
                                                else {
                                                    setTimeout(function () { swal("Confirmed", "", "success") }, 500);
                                                }
                                            })
                                        }, 500);
                                    }
                                    arrSubscription.find(v => v.NoTrx == NoTrx).KodeProduk = $("#srcProductSubs_text1").val();
                                    arrSubscription.find(v => v.NoTrx == NoTrx).NamaProduk = $("#srcProductSubs_text2").val();
                                    arrSubscription.find(v => v.NoTrx == NoTrx).ClientCode = $("#srcClientSubs_text1").val();
                                    arrSubscription.find(v => v.NoTrx == NoTrx).CCY = $("#srcCurrencySubs_text1").val();
                                    arrSubscription.find(v => v.NoTrx == NoTrx).Nominal = $("#MoneyNomSubs").data("kendoNumericTextBox").value();
                                    arrSubscription.find(v => v.NoTrx == NoTrx).PhoneOrder = $("#checkPhoneOrderSubs").prop('checked');
                                    arrSubscription.find(v => v.NoTrx == NoTrx).FullAmount = $("#checkFullAmtSubs").prop('checked');
                                    arrSubscription.find(v => v.NoTrx == NoTrx).EditFee = $("#checkFeeEditSubs").prop('checked');
                                    arrSubscription.find(v => v.NoTrx == NoTrx).JenisFee = $("#_ComboJenisSubs").data("kendoDropDownList").value();
                                    arrSubscription.find(v => v.NoTrx == NoTrx).IsNew = IsSubsNew;
                                    arrSubscription.find(v => v.NoTrx == NoTrx).ApaDiUpdate = true;
                                    arrSubscription.find(v => v.NoTrx == NoTrx).TrxTaxAmnesty = false;

                                    if (IsSubsNew) {
                                        arrSubscription.find(v => v.NoTrx == NoTrx).OutstandingUnit = 0;
                                    }
                                    else {
                                        var res = GetLatestBalance($("#ClientIdSubs").val());
                                        res.success(function (data) {
                                            if (data.blnResult) {
                                                arrSubscription.find(v => v.NoTrx == NoTrx).OutstandingUnit = data.unitBalance;
                                            }
                                        });
                                    }
                                    if ($("#_ComboJenisSubs").data("kendoDropDownList").text() == "By %") {
                                        arrSubscription.find(v => v.NoTrx == NoTrx).FeeKet = $("#labelFeeCurrencySubs").text();
                                        arrSubscription.find(v => v.NoTrx == NoTrx).FeeCurr = $("#_KeteranganFeeSubs").text();

                                        arrSubscription.find(v => v.NoTrx == NoTrx).NominalFee = $("#PercentageFeeSubs").data("kendoNumericTextBox").value();
                                        arrSubscription.find(v => v.NoTrx == NoTrx).PctFee = $("#MoneyFeeSubs").data("kendoNumericTextBox").value();
                                    }
                                    else {
                                        arrSubscription.find(v => v.NoTrx == NoTrx).FeeKet = $("#_KeteranganFeeSubs").text();
                                        arrSubscription.find(v => v.NoTrx == NoTrx).FeeCurr = $("#labelFeeCurrencySubs").text();
                                        arrSubscription.find(v => v.NoTrx == NoTrx).NominalFee = $("#MoneyFeeSubs").data("kendoNumericTextBox").value();
                                        arrSubscription.find(v => v.NoTrx == NoTrx).PctFee = $("#PercentageFeeSubs").data("kendoNumericTextBox").value();
                                    }
                                    if ($('#checkFeeEditSubs').prop('checked') == true) {
                                        arrSubscription.find(v => v.NoTrx == NoTrx).EditFeeBy = $("#_ComboJenisSubs").data("kendoDropDownList").text();
                                    }
                                    else {
                                        arrSubscription.find(v => v.NoTrx == NoTrx).EditFeeBy = "";
                                    }
                                }
                                else {
                                    setTimeout(function () { swal("Warning", data.ErrMsg, "warning") }, 500);
                                }
                            });
                        }
                    });

                    var dataSource = new kendo.data.DataSource(
                        {
                            data: arrSubscription
                        });
                    grid.setDataSource(dataSource);
                    grid.dataSource.pageSize(5);
                    grid.dataSource.page(1);
                    grid.select("tr:eq(0)");

                    subSetVisibleGrid(_strTabName);
                    ResetFormTrxSubs();

                    if (_intType == 1) {
                        DisableFormTrxSubs(true);
                        document.getElementById("btnEditSubs").disabled = false;
                        document.getElementById("btnAddSubs").disabled = false;
                    }
                    else if (_intType == 2) {
                        DisableFormTrxSubs(false);
                        document.getElementById("btnEditSubs").disabled = false;
                        document.getElementById("btnAddSubs").disabled = true;
                    }
                }
            });
    }
}
function subEditRedemp() {
    if ($("#btnEditRedemp").text() == "Edit") {
        DisableFormTrxRedemp(true);
        $("#RedempUnit").data("kendoNumericTextBox").enable(false);
        $("#checkAll").prop('disabled', true);
        $("#srcProductRedemp_text1").prop('disabled', true);
        $("#srcProductRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcClientRedemp_text1").prop('disabled', true);
        $("#srcClientRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        if ($("#checkFeeEditRedemp").prop('checked') == true) {
            $("#_ComboJenisRedemp").data('kendoDropDownList').enable(true);
            $("#MoneyFeeRedemp").data("kendoNumericTextBox").enable(true);
            $("#PercentageFeeRedemp").data("kendoNumericTextBox").enable(false);
        }
        //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSubs.Text1)) {
        //    checkPhoneOrderSubs.Enabled = false;
        //    checkPhoneOrderSubs.Checked = false;
        //}
        //else {
        //    checkPhoneOrderSubs.Enabled = true;
        //}
        $("#btnEditRedemp").attr('class', 'btn btn-info waves-effect waves-light');
        $("#btnEditRedemp").html('<span class="btn-label"><i class= "fa fa-check"></i></span >Done');
        document.getElementById("btnAddRedemp").disabled = true;
    }
    else if ($("#btnEditRedemp").text() == "Done") {
        swal({
            title: "Information",
            text: "Apakah akan merubah transaksi Trancode " + $("#textNoTransaksiRedemp").val() + "?",
            type: "warning",
            showCancelButton: true,
            confirmButtonClass: 'btn-info',
            confirmButtonText: "Yes",
            closeOnConfirm: true,
            closeOnCancel: false
        },
            function (isConfirm) {
                if (!isConfirm) {
                    swal("Canceled", "Proses transaksi dibatalkan.", "error");
                    return;
                }
                else {
                    if (_StatusTransaksiRedemp == "Rejected") {
                        setTimeout(function () { swal("Warning", "Transaksi dengan Status Rejected tidak dapat diedit!", "warning") }, 500);
                        return;
                    }
                    else if (_StatusTransaksiRedemp == "Reversed") {
                        setTimeout(function () { swal("Warning", "Transaksi dengan Status Reversed tidak dapat diedit!", "warning") }, 500);
                        return;
                    }
                    else if (_StatusTransaksiRedemp == "Cancel By PO") {
                        setTimeout(function () { swal("Warning", "Transaksi dengan Status Cancel By PO tidak dapat diedit!", "warning") }, 500);
                        return;
                    }
                    if ($("#srcProductRedemp_text1").val() == "") {
                        setTimeout(function () { swal("Warning", "Kode Produk harus diisi", "warning") }, 500);
                        return;
                    }
                    if ($("#srcClientRedemp_text1").val() == "") {
                        setTimeout(function () { swal("Warning", "Client Code harus diisi", "warning") }, 500);
                        return;
                    }
                    if ($("#RedempUnit").val() == 0) {
                        setTimeout(function () { swal("Warning", "Unit harus diisi", "warning") }, 500);
                        return;
                    }
                    var strWarnMsg2 = '';
                    var _PercentageFee;
                    var _NominalFee;
                    var grid = $("#dataGridViewRedemp").data("kendoGrid");
                    grid.refresh();

                    var arrRedemp = [];
                    var NoTrx = $("#textNoTransaksiRedemp").val();
                    arrRedemp = grid.dataSource.view();
                    grid.tbody.find("tr[role='row']").each(function () {
                        var dataItem = grid.dataItem(this);
                        if (NoTrx == "" || dataItem.NoTrx != NoTrx) {
                            swal("Warning", "Data tidak ditemukan", "warning");
                            return;
                        }
                        else {
                            var res = GenerateTranCodeAndClientCode(_strTabName, false, $("#srcProductRedemp_text1").val(),
                                $("#srcClientRedemp_text1").val(), $("#srcCIFRedemp_text1").val(),
                                $("#checkFeeEditRedemp").prop('checked'), $("#MoneyFeeRedemp").data("kendoNumericTextBox").value(), intPeriod
                                , false, $("#PercentageFeeRedemp").data("kendoNumericTextBox").value(), 0, $("#RedempUnit").data("kendoNumericTextBox").value(), IsRedempAll, 0, 0
                                , _intType);
                            res.success(function success(data) {
                                if (data.blnResult) {
                                    strTranCode = data.strTrancode;
                                    strNewClientCode = data.strClientCode;
                                    strWarnMsg = data.strWarnMsg;
                                    strWarnMsg2 = data.strWarnMsg2;
                                    if (strWarnMsg2 != '') {
                                        setTimeout(function () {
                                            swal({
                                                title: "Information",
                                                text: strWarnMsg2,
                                                type: "warning",
                                                showCancelButton: true,
                                                confirmButtonClass: 'btn-info',
                                                confirmButtonText: "Yes",
                                                closeOnConfirm: false,
                                                closeOnCancel: false
                                            },
                                                function (isConfirm) {
                                                    if (!isConfirm) {
                                                        setTimeout(function () { swal("Canceled", "Proses transaksi dibatalkan.", "error") }, 500);
                                                        return;
                                                    }
                                                    else {
                                                        setTimeout(function () { swal("Confirmed", "", "success") }, 500);
                                                    }
                                                })
                                        }, 500);
                                    }
                                    arrRedemp.find(v => v.NoTrx == NoTrx).KodeProduk = $("#srcProductRedemp_text1").val();
                                    arrRedemp.find(v => v.NoTrx == NoTrx).NamaProduk = $("#srcProductRedemp_text2").val();
                                    if ($('#checkFeeEditRedemp').prop('checked') == true) {
                                        arrRedemp.find(v => v.NoTrx == NoTrx).EditFeeBy = $("#_ComboJenisRedemp").data("kendoDropDownList").text();
                                    }
                                    else {
                                        arrRedemp.find(v => v.NoTrx == NoTrx).EditFeeBy = "";
                                    }
                                    arrRedemp.find(v => v.NoTrx == NoTrx).ClientCode = $("#srcClientRedemp_text1").val();
                                    arrRedemp.find(v => v.NoTrx == NoTrx).OutstandingUnit = $("#OutstandingUnitRedemp").data("kendoNumericTextBox").value();
                                    arrRedemp.find(v => v.NoTrx == NoTrx).RedempUnit = $("#RedempUnit").data("kendoNumericTextBox").value();
                                    arrRedemp.find(v => v.NoTrx == NoTrx).PhoneOrder = $("#checkPhoneOrderRedemp").prop('checked');
                                    arrRedemp.find(v => v.NoTrx == NoTrx).EditFee = $("#checkFeeEditRedemp").prop('checked');
                                    arrRedemp.find(v => v.NoTrx == NoTrx).JenisFee = $("#_ComboJenisRedemp").data("kendoDropDownList").value();
                                    arrRedemp.find(v => v.NoTrx == NoTrx).PctFee = $("#MoneyFeeRedemp").data("kendoNumericTextBox").value();
                                    arrRedemp.find(v => v.NoTrx == NoTrx).FeeKet = $("#labelFeeCurrencyRedemp").text();
                                    arrRedemp.find(v => v.NoTrx == NoTrx).NominalFee = $("#PercentageFeeRedemp").data("kendoNumericTextBox").value();
                                    arrRedemp.find(v => v.NoTrx == NoTrx).FeeCurr = $("#_KeteranganFeeRedemp").text();                                    
                                    arrRedemp.find(v => v.NoTrx == NoTrx).IsRedempAll = IsRedempAll;
                                    arrRedemp.find(v => v.NoTrx == NoTrx).Period = intPeriod;
                                    arrRedemp.find(v => v.NoTrx == NoTrx).ApaDiUpdate = true;
                                    arrRedemp.find(v => v.NoTrx == NoTrx).TrxTaxAmnesty = false;  
                                }
                                else {
                                    setTimeout(function () { swal("Warning", data.ErrMsg, "warning") }, 500);
                                }
                            });
                        }
                    });

                    var dataSource = new kendo.data.DataSource(
                        {
                            data: arrRedemp
                        });
                    grid.setDataSource(dataSource);
                    grid.dataSource.pageSize(5);
                    grid.dataSource.page(1);
                    grid.select("tr:eq(0)");

                    subSetVisibleGrid(_strTabName);
                    ResetFormTrxRedemp();

                    if (_intType == 1) {
                        DisableFormTrxRedemp(true);
                        document.getElementById("btnEditRedemp").disabled = false;
                        document.getElementById("btnAddRedemp").disabled = false;
                    }
                    else if (_intType == 2) {
                        DisableFormTrxRedemp(false);
                        document.getElementById("btnEditRedemp").disabled = false;
                        document.getElementById("btnAddRedemp").disabled = true;
                    }
                }
            });
    }
}
function subEditRDB() {
    if ($("#btnEditRDB").text() == "Edit") {
        DisableFormTrxRDB(true);
        $("#srcProductRDB_text1").prop('disabled', true);
        $("#srcProductRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcClientRDB_text1").prop('disabled', true);
        $("#srcClientRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        if ($("#checkFeeEditRDB").prop('checked') == true) {
            $("#_ComboJenisRDB").data('kendoDropDownList').enable(true);
            $("#MoneyFeeRDB").data("kendoNumericTextBox").enable(true);
            $("#PercentageFeeRDB").data("kendoNumericTextBox").enable(false);
        }
        //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFRDB.Text1)) {
        //    checkPhoneOrderRDB.Enabled = false;
        //    checkPhoneOrderRDB.Checked = false;
        //}
        //else {
        //    checkPhoneOrderRDB.Enabled = true;
        //}
        $("#btnEditRDB").attr('class', 'btn btn-info waves-effect waves-light');
        $("#btnEditRDB").html('<span class="btn-label"><i class= "fa fa-check"></i></span >Done');
        document.getElementById("btnAddRDB").disabled = true;
    }
    else if ($("#btnEditRDB").text() == "Done") {
        swal({
            title: "Information",
            text: "Apakah akan merubah transaksi Trancode " + $("#textNoTransaksiRDB").val() + "?",
            type: "warning",
            showCancelButton: true,
            confirmButtonClass: 'btn-info',
            confirmButtonText: "Yes",
            closeOnConfirm: true,
            closeOnCancel: false
        },
            function (isConfirm) {
                if (!isConfirm) {
                    swal("Canceled", "Proses transaksi dibatalkan.", "error");
                    return;
                }
                else {
                    if (_StatusTransaksiRDB == "Rejected") {
                        setTimeout(function () { swal("Warning", "Transaksi dengan Status Rejected tidak dapat diedit!", "warning") }, 500);
                        return;
                    }
                    else if (_StatusTransaksiRDB == "Reversed") {
                        setTimeout(function () { swal("Warning", "Transaksi dengan Status Reversed tidak dapat diedit!", "warning") }, 500);
                        return;
                    }
                    else if (_StatusTransaksiRDB == "Cancel By PO") {
                        setTimeout(function () { swal("Warning", "Transaksi dengan Status Cancel By PO tidak dapat diedit!", "warning") }, 500);
                        return;
                    }
                    if ($("#srcProductRDB_text1").val() == "") {
                        setTimeout(function () { swal("Warning", "Kode Produk harus diisi", "warning") }, 500);
                        return;
                    }

                    if ($("#srcCurrencyRDB_text1").val() == "") {
                        setTimeout(function () { swal("Warning", "Mata Uang Produk harus diisi", "warning") }, 500);
                        return;
                    }
                    if ($("#MoneyNomRDB").val() == 0) {
                        setTimeout(function () { swal("Warning", "Nominal harus diisi", "warning") }, 500);
                        return;
                    }
                    if ($("#JangkaWktRDB").val() == 0) {
                        setTimeout(function () { swal("Warning", "Jangka Waktu harus diisi", "warning") }, 500);
                        return;
                    }
                    if ($("#cmbFrekPendebetanRDB").data("kendoDropDownList").text() == "") {
                        setTimeout(function () { swal("Warning", "Frekuensi Pendebetan harus dipilih", "warning") }, 500);
                        return;
                    }
                    if ($("#cmbAutoRedempRDB").data("kendoDropDownList").text() == "") {
                        setTimeout(function () { swal("Warning", "Auto Redemption harus dipilih", "warning") }, 500);
                        return;
                    }
                    if ($("#cmbAsuransiRDB").data("kendoDropDownList").text() == "") {
                        setTimeout(function () { swal("Warning", "Asuransi harus dipilih", "warning") }, 500);
                        return;
                    }
                    var strWarnMsg2 = '';
                    var grid = $("#dataGridViewRDB").data("kendoGrid");
                    grid.refresh();

                    var arrRDB = [];
                    var NoTrx = $("#textNoTransaksiRDB").val();
                    arrRDB = grid.dataSource.view();
                    grid.tbody.find("tr[role='row']").each(function () {
                        var dataItem = grid.dataItem(this);
                        if (NoTrx == "" || dataItem.NoTrx != NoTrx) {
                            swal("Warning", "Data tidak ditemukan", "warning");
                            return;
                        }
                        else {
                            var _FrekPendebetan = $("#cmbFrekPendebetanRDB").data("kendoDropDownList").text();
                            var res = GenerateTranCodeAndClientCode(_strTabName, IsSubsNew, $("#srcProductRDB_text1").val(),
                                $("#srcClientRDB_text1").val(), $("#srcCIFRDB_text1").val(),
                                $("#checkFeeEditRDB").prop('checked'), $("#PercentageFeeRDB").data("kendoNumericTextBox").value(), 0
                                , false, $("#MoneyFeeRDB").data("kendoNumericTextBox").value(), $("#MoneyNomRDB").data("kendoNumericTextBox").value(), 0, false, _FrekPendebetan, $("#JangkaWktRDB").data("kendoNumericTextBox").value()
                                , _intType);
                            res.success(function success(data) {
                                if (data.blnResult) {
                                    strTranCode = data.strTrancode;
                                    strNewClientCode = data.strClientCode;
                                    strWarnMsg = data.strWarnMsg;
                                    strWarnMsg2 = data.strWarnMsg2;
                                    if (strWarnMsg2 != '') {
                                        setTimeout(function () {
                                            swal({
                                                title: "Information",
                                                text: strWarnMsg2,
                                                type: "warning",
                                                showCancelButton: true,
                                                confirmButtonClass: 'btn-info',
                                                confirmButtonText: "Yes",
                                                closeOnConfirm: false,
                                                closeOnCancel: false
                                            },
                                                function (isConfirm) {
                                                    if (!isConfirm) {
                                                        setTimeout(function () { swal("Canceled", "Proses transaksi dibatalkan.", "error") }, 500);
                                                        return;
                                                    }
                                                    else {
                                                        setTimeout(function () { swal("Confirmed", "", "success") }, 500);
                                                    }
                                                })
                                        }, 500);
                                    }
                                    arrRDB.find(v => v.NoTrx == NoTrx).KodeProduk = $("#srcProductRDB_text1").val();
                                    arrRDB.find(v => v.NoTrx == NoTrx).NamaProduk = $("#srcProductRDB_text2").val();
                                    if ($('#checkFeeEditRDB').prop('checked') == true) {
                                        arrRDB.find(v => v.NoTrx == NoTrx).EditFeeBy = $("#_ComboJenisRDB").data("kendoDropDownList").text();
                                    }
                                    else {
                                        arrRDB.find(v => v.NoTrx == NoTrx).EditFeeBy = "";
                                    }
                                    arrRDB.find(v => v.NoTrx == NoTrx).ClientCode = $("#srcClientRDB_text1").val();
                                    arrRDB.find(v => v.NoTrx == NoTrx).CCY = $("#srcCurrencyRDB_text1").val();
                                    arrRDB.find(v => v.NoTrx == NoTrx).Nominal = $("#MoneyNomRDB").data("kendoNumericTextBox").value();
                                    arrRDB.find(v => v.NoTrx == NoTrx).PhoneOrder = $("#checkPhoneOrderRDB").prop('checked');
                                    arrRDB.find(v => v.NoTrx == NoTrx).AutoRedemption = $("#cmbAutoRedempRDB").data("kendoDropDownList").val();
                                    arrRDB.find(v => v.NoTrx == NoTrx).Asuransi = $("#cmbAsuransiRDB").data("kendoDropDownList").val();
                                    arrRDB.find(v => v.NoTrx == NoTrx).EditFee = $("#checkFeeEditRDB").prop('checked');
                                    arrRDB.find(v => v.NoTrx == NoTrx).JenisFee = $("#_ComboJenisRDB").data("kendoDropDownList").value();
                                    arrRDB.find(v => v.NoTrx == NoTrx).NominalFee = $("#MoneyFeeRDB").data("kendoNumericTextBox").value();
                                    arrRDB.find(v => v.NoTrx == NoTrx).FeeCurr = $("#labelFeeCurrencyRDB").text();
                                    arrRDB.find(v => v.NoTrx == NoTrx).PctFee = $("#PercentageFeeRDB").data("kendoNumericTextBox").value();
                                    arrRDB.find(v => v.NoTrx == NoTrx).FeeKet = $("#_KeteranganFeeRDB").text();
                                    arrRDB.find(v => v.NoTrx == NoTrx).JangkaWaktu = $("#JangkaWktRDB").data("kendoNumericTextBox").value();
                                    arrRDB.find(v => v.NoTrx == NoTrx).JatuhTempo = globalJatuhTempoRDB;
                                    arrRDB.find(v => v.NoTrx == NoTrx).FrekPendebetan = $("#cmbFrekPendebetanRDB").data("kendoDropDownList").value();
                                    arrRDB.find(v => v.NoTrx == NoTrx).ApaDiUpdate = true;
                                    arrRDB.find(v => v.NoTrx == NoTrx).TrxTaxAmnesty = false;                                   
                                }
                                else {
                                    setTimeout(function () { swal("Warning", data.ErrMsg, "warning") }, 500);
                                }
                            });
                        }
                    });

                    var dataSource = new kendo.data.DataSource(
                        {
                            data: arrRDB
                        });
                    grid.setDataSource(dataSource);
                    grid.dataSource.pageSize(5);
                    grid.dataSource.page(1);
                    grid.select("tr:eq(0)");


                    subSetVisibleGrid(_strTabName);
                    ResetFormTrxSubsRDB();

                    if (_intType == 1) {
                        DisableFormTrxRDB(true);
                        document.getElementById("btnEditRDB").disabled = false;
                        document.getElementById("btnAddRDB").disabled = false;
                    }
                    else if (_intType == 2) {
                        DisableFormTrxRDB(false);
                        document.getElementById("btnEditRDB").disabled = false;
                        document.getElementById("btnAddRDB").disabled = true;
                    }
                }
            });
    }
}
function subAddRedemp() {
    var strWarnMsg = '';
    var strWarnMsg2 = '';

    var strTranCode = "";
    var strNewClientCode = "";
    var _PercentageFee;
    var _NominalFee;
    var intProductId = 0;

    if ($("#btnAddRedemp").text() == "Done") {
        DisableFormTrxRedemp(true);
        ResetFormTrxSubsRedemp();
        document.getElementById("btnEditRedemp").disabled = true;
        $("#btnAddRedemp").attr('class', 'btn btn-default waves-effect waves-light');
        $("#btnAddRedemp").html('<span class="btn-label"><i class= "fa fa-check"></i></span >Done');
    }
    else if ($("#btnAddRedemp").text() == "Add") {
        var blnPassed = true;
        var grid = $("#dataGridViewRedemp").data("kendoGrid");
        grid.refresh();
        var dataItem = grid.dataSource.view();
        if (dataItem.length >= 3) {
            swal("Warning", "Maksimal hanya dapat menambah 3 transaksi !", "warning");
            return;
        }
        if ($("#srcProductRedemp_text1").val() == "") {
            swal("Warning", "Kode Produk harus diisi", "warning");
            return;
        }
        if ($("#srcClientRedemp_text1").val().Text1 == "") {
            swal("Warning", "Client Code harus diisi", "warning");
            return;
        }
        if ($("#RedempUnit").val() == 0) {
            swal("Warning", "Unit harus diisi", "warning");
            return;
        }
        if (+$("#RedempUnit").val() > +$("#OutstandingUnitRedemp").val()) {
            swal("Warning", "Redemption unit tidak boleh lebih besar dari Outstanding Unit!", "warning");
            return;
        }
        
        grid.tbody.find("tr[role='row']").each(function () {
            var dataItem = grid.dataItem(this);
            if (dataItem.ClientCode == $("#srcClientRedemp_text1").val())
            {
                swal("Warning", "Redemption untuk Client Code " + $("#srcClientRedemp_text1").val()  + " sudah ada!", "warning");
                blnPassed = false;
                return;
            }
        })

        if (blnPassed)
        {
            var res = GenerateTranCodeAndClientCode(_strTabName, false, $("#srcProductRedemp_text1").val(),
                $("#srcClientRedemp_text1").val(), $("#srcCIFRedemp_text1").val(),
                $("#checkFeeEditRedemp").val(), $("#MoneyFeeRedemp").val(), intPeriod
                , false, $("#PercentageFeeRedemp").val(), 0, $("#RedempUnit").val(), IsRedempAll, 0, 0
                , _intType);
            res.success(function success(data) {
                if (data.blnResult) {
                    strTranCode = data.strTrancode;
                    strNewClientCode = data.strClientCode;
                    strWarnMsg = data.strWarnMsg;
                    strWarnMsg2 = data.strWarnMsg2;

                    if (strWarnMsg2 != '') {
                        swal({
                            title: "Information",
                            text: strWarnMsg2,
                            type: "warning",
                            showCancelButton: true,
                            confirmButtonClass: 'btn-info',
                            confirmButtonText: "Yes",
                            closeOnConfirm: false,
                            closeOnCancel: false
                        },
                            function (isConfirm) {
                                if (!isConfirm) {
                                    swal("Canceled", "Proses transaksi dibatalkan.", "error");
                                    return;
                                }
                                else {
                                    swal("Confirmed", "", "success");
                                }
                            });
                    }

                    if (strTranCode != "") {
                        var arrRedemption = [];
                        var obj = {};
                        obj['NoTrx'] = '';
                        var dateTglTransaksiRedemp = toDate($("#dateTglTransaksiRedemp").val());
                        obj['TglTrx'] = dateTglTransaksiRedemp;
                        obj['KodeProduk'] = $("#srcProductRedemp_text1").val();
                        obj['NamaProduk'] = $("#srcProductRedemp_text2").val();
                        if ($('#checkFeeEditRedemp').prop('checked') == true) {
                            obj["EditFeeBy"] = $("#_ComboJenisRedemp").data("kendoDropDownList").text();
                        }
                        else {
                            obj["EditFeeBy"] = "";
                        }
                        obj['ClientCode'] = strNewClientCode;
                        obj["OutstandingUnit"] = $("#OutstandingUnitRedemp").data("kendoNumericTextBox").value();
                        obj["RedempUnit"] = $("#RedempUnit").data("kendoNumericTextBox").value();
                        obj["PhoneOrder"] = $("#checkPhoneOrderRedemp").prop('checked');
                        obj["EditFee"] = $("#checkFeeEditRedemp").prop('checked');
                        obj["JenisFee"] = $("#_ComboJenisRedemp").data("kendoDropDownList").value();
                        obj["PctFee"] = $("#MoneyFeeRedemp").data("kendoNumericTextBox").value();
                        obj["FeeKet"] = $("#labelFeeCurrencyRedemp").text();
                        obj["NominalFee"] = $("#PercentageFeeRedemp").data("kendoNumericTextBox").value();
                        obj["FeeCurr"] = $("#_KeteranganFeeRedemp").text();
                        obj["IsRedempAll"] = IsRedempAll;
                        obj["Period"] = intPeriod;
                        obj["ApaDiUpdate"] = false;
                        obj["TrxTaxAmnesty"] = false;
                        arrRedemption.push(obj);

                        var dataSet = grid.dataSource.view();
                        $.merge(arrRedemption, dataSet);

                        var dataSource = new kendo.data.DataSource(
                            {
                                data: arrRedemption
                            });
                        grid.setDataSource(dataSource);
                        grid.dataSource.pageSize(5);
                        grid.dataSource.page(1);
                        grid.select("tr:eq(0)");

                        subSetVisibleGrid(_strTabName);
                        ResetFormTrxRedemp();
                        DisableFormTrxRedemp(true);
                        document.getElementById("btnEditRedemp").disabled = true;
                        document.getElementById("btnAddRedemp").disabled = false;
                        //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSubs.Text1)) {
                        //    checkPhoneOrderSubs.Enabled = false;
                        //    checkPhoneOrderSubs.Checked = false;
                        //}
                        //else {
                        //    checkPhoneOrderSubs.Enabled = true;
                        //}
                    }
                    else {
                        swal("Warning", "Gagal generate kode transaksi!", "warning");
                    }
                }
                else {
                    swal("Warning", data.ErrMsg, "warning");
                }
            });
        }
    }
}
function subAddRDB() {
    var strWarnMsg = '';
    var strWarnMsg2 = '';

    var strTranCode = "";
    var strNewClientCode = "";
    var _PercentageFee;
    var _NominalFee;
    var intProductId = 0;

    if ($("#btnAddRDB").text() == "Done") {
        DisableFormTrxRDB(true);
        ResetFormTrxSubsRDB();
        document.getElementById("btnEditRDB").disabled = true;
        $("#btnAddRDB").attr('class', 'btn btn-default waves-effect waves-light');
        $("#btnAddRDB").html('<span class="btn-label"><i class= "fa fa-check"></i></span >Done');
    }
    else if ($("#btnAddRDB").text()  == "Add") {
        var grid = $("#dataGridViewRDB").data("kendoGrid");
        grid.refresh();
        var dataItem = grid.dataSource.view();
        if (dataItem.length >= 3) {
            swal("Warning", "Maksimal hanya dapat menambah 3 transaksi !", "warning");
            return;
        }
        if ($("#srcProductRDB_text1").val() == "") {
            swal("Warning", "Kode Produk harus diisi", "warning");
            return;
        }
        if ($("#srcCurrencyRDB_text1").val().Text1 == "") {
            swal("Warning", "Mata Uang Produk harus diisi", "warning");
            return;
        }
        if ($("#MoneyNomRDB").val() == 0) {
            swal("Warning", "Nominal harus diisi", "warning");
            return;
        }
        if ($("#JangkaWktRDB").val() == 0) {
            swal("Warning", "Jangka Waktu harus diisi", "warning");
            return;
        }
        if ($("#cmbFrekPendebetanRDB").data('kendoDropDownList').value() == '') {
            swal("Warning", "Frekuensi Pendebetan harus diisi", "warning");
            return;
        }
        if ($("#cmbAutoRedempRDB").data('kendoDropDownList').value() == '') {
            swal("Warning", "Auto Redemption harus diisi", "warning");
            return;
        }
        if ($("#cmbAsuransiRDB").data('kendoDropDownList').value() == '') {
            swal("Warning", "Asuransi harus diisi", "warning");
            return;
        }
        var res = GenerateTranCodeAndClientCode(_strTabName, false, $("#srcProductRDB_text1").val(),
            $("#srcClientRDB_text1").val(), $("#srcCIFRDB_text1").val(),
            $("#checkFeeEditRDB").val(), $("#PercentageFeeRDB").val(), 0
            , false, $("#MoneyFeeRDB").val(), $("#MoneyNomRDB").val(), 0, false, $("#cmbFrekPendebetanRDB").data('kendoDropDownList').value(), $("#JangkaWktRDB").data("kendoNumericTextBox").value()
            , _intType);

        res.success(function success(data) {
            if (data.blnResult) {
                strTranCode = data.strTrancode;
                strNewClientCode = data.strClientCode;
                strWarnMsg = data.strWarnMsg;
                strWarnMsg2 = data.strWarnMsg2;
                if (strWarnMsg != "")
                {
                    swal({
                        title: "Information",
                        text: "Produk yang dipilih diatas ketentuan profile nasabah. Lanjutkan transaksi?",
                        type: "warning",
                        showCancelButton: true,
                        confirmButtonClass: 'btn-info',
                        confirmButtonText: "Yes",
                        closeOnConfirm: false,
                        closeOnCancel: false
                    },
                        function (isConfirm) {
                            if (!isConfirm) {
                                swal("Canceled", "Proses transaksi dibatalkan.", "error");
                                return;
                            }
                            else {
                                swal("Confirmed", "Profil Risiko produk lebih tinggi dari Profil Risiko Nasabah ./nPASTIKAN Nasabah sudah menandatangani kolom Profil Risiko pada Subscription/Switching Form", "success");
                            }
                        });
                }
                if (strWarnMsg2 != '')
                {
                    swal({
                        title: "Information",
                        text: strWarnMsg2,
                        type: "warning",
                        showCancelButton: true,
                        confirmButtonClass: 'btn-info',
                        confirmButtonText: "Yes",
                        closeOnConfirm: false,
                        closeOnCancel: false
                    },
                        function (isConfirm) {
                            if (!isConfirm) {
                                swal("Canceled", "Proses transaksi dibatalkan.", "error");
                                return;
                            }
                            else {
                                swal("Confirmed", "", "success");
                            }
                        });
                }

                if (strTranCode != "") {
                    var arrRDB = [];
                    var obj = {};
                    obj['NoTrx'] = '';
                    var dateTglTransaksiRDB = toDate($("#dateTglTransaksiRDB").val());
                    obj['TglTrx'] = dateTglTransaksiRDB;
                    obj['KodeProduk'] = $("#srcProductRDB_text1").val();
                    obj['NamaProduk'] = $("#srcProductRDB_text2").val();
                    if ($('#checkFeeEditRDB').prop('checked') == true) {
                        obj["EditFeeBy"] = $("#_ComboJenisRDB").val();
                    }
                    else {
                        obj["EditFeeBy"] = "";
                    }
                    obj['ClientCode'] = strNewClientCode;
                    obj["CCY"] = $("#srcCurrencyRDB_text1").val();
                    obj["Nominal"] = $("#MoneyNomRDB").val();

                    obj["JangkaWaktu"] = $("#JangkaWktRDB").data("kendoNumericTextBox").value();
                    obj["JatuhTempo"] = globalJatuhTempoRDB;
                    obj["FrekPendebetan"] = $("#cmbFrekPendebetanRDB").data('kendoDropDownList').value();
                    obj["AutoRedemption"] = $("#cmbAutoRedempRDB").data('kendoDropDownList').value();
                    obj["Asuransi"] = $("#cmbAsuransiRDB").data('kendoDropDownList').value();

                    obj["PhoneOrder"] = $("#checkPhoneOrderRDB").prop('checked');
                    obj["EditFee"] = $("#checkFeeEditRDB").prop('checked');
                    obj["JenisFee"] = $("#_ComboJenisRDB").val();
                    obj["NominalFee"] = $("#MoneyFeeRDB").val();
                    obj["FeeCurr"] = $("#labelFeeCurrencyRDB").text();
                    obj["PctFee"] = $("#PercentageFeeRDB").val();
                    obj["FeeKet"] = $("#_KeteranganFeeRDB").text();

                    obj["ApaDiUpdate"] = false;
                    obj["TrxTaxAmnesty"] = false;
                    arrRDB.push(obj);

                    var dataSet = grid.dataSource.view();
                    $.merge(arrRDB, dataSet);

                    var dataSource = new kendo.data.DataSource(
                        {
                            data: arrRDB
                        });
                    grid.setDataSource(dataSource);
                    grid.dataSource.pageSize(5);
                    grid.dataSource.page(1);
                    grid.select("tr:eq(0)");

                    subSetVisibleGrid(_strTabName);
                    ResetFormTrxRDB();
                    DisableFormTrxRDB(true);
                    document.getElementById("btnEditRDB").disabled = true;
                    document.getElementById("btnAddRDB").disabled = false;
                    //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSubs.Text1)) {
                    //    checkPhoneOrderSubs.Enabled = false;
                    //    checkPhoneOrderSubs.Checked = false;
                    //}
                    //else {
                    //    checkPhoneOrderSubs.Enabled = true;
                    //}
                }
                else {
                    swal("Warning", "Gagal generate kode transaksi!", "warning");
                }
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        });
    }
}
function GetDataCIF(CIFNo) {
    return new Promise((resolve, reject) => {
        $.ajax({
        type: 'GET',
            url: '/Customer/RefreshNasabah',
            data: { CIFNo: CIFNo },
            beforeSend: function () {
            $("#load_screen").show();
            },
            success: function (data) {
                resolve({
                    blnResult: data.blnResult,
                    ErrMsg: data.ErrMsg,
                    ShareholderID: data.listCust[0].ShareholderID,
                    NoRekening: data.listCust[0].AccountId,
                    NamaRekening: data.listCust[0].AccountName,
                    SID: data.listCust[0].CIFSID,
                    NoRekeningUSD: data.listCust[0].AccountIdUSD,
                    NamaRekeningUSD: data.listCust[0].AccountNameUSD,
                    NoRekeningMC: data.listCust[0].AccountIdMC,
                    NamaRekeningMC: data.listCust[0].AccountNameMC,
                    RiskProfile: data.listRisk[0].RiskProfile,
                    LastUpdateRiskProfile: data.listRisk[0].LastUpdate
                })
            },
            error: reject,
            complete: function () {
                $("#load_screen").hide();
            }
        })
    })
}

function GetDataTransaksi(RefID, CIFNo) {
    var blnResult = false, ErrMsg = "", OfficeId, RefID, CIFNo, Inputter, Seller, Waperd, Referentor, Status, CIFName, dttSubscription, dttRedemption, dttSubsRDB;
    return new Promise((resolve, reject) => {
        $.ajax({
            type: 'GET',
            url: '/Transaksi/RefreshTransaction',
            data: { RefID: RefID, CIFNo: CIFNo, _strTabName: _strTabName },
            beforeSend: function () {
                $("#load_screen").show();
            },
            success: function (data) {
                if (data.listSubsDetail.length > 0) {
                    resolve({
                        blnResult: data.blnResult,
                        ErrMsg: data.ErrMsg,
                        OfficeId: data.listSubsDetail[0].OfficeId,
                        RefID: data.listSubsDetail[0].RefID,
                        CIFNo: data.listSubsDetail[0].CIFNo,
                        Inputter: data.listSubsDetail[0].Inputter,
                        Seller: data.listSubsDetail[0].Seller,
                        Waperd: data.listSubsDetail[0].Waperd,
                        Referentor: data.listSubsDetail[0].Referentor,
                        Status: data.listSubsDetail[0].Status,
                        CIFName: data.listSubsDetail[0].CIFName,
                        dttSubscription: data.listSubscription,
                        dttRedemption: data.listRedemption,
                        dttSubsRDB: data.listSubsRDB
                    })
                } else {
                    resolve({
                        blnResult: false,
                        ErrMsg: "No Referensi tidak ditemukan untuk transaksi subscription!"
                    })
                }                
            },
            error: reject,
            complete: function () {
                $("#load_screen").hide();
            }
        })
    })
}

async function subRefresh() {    
    var CIFNo;
    var RefID;
    if (_strTabName == "SUBS") {
        if ($("#srcNoRefSubs_text1").val().length == 0) {
            swal("Warning", "Silahkan Pilih kode Nomor referensi terlebih dahulu!", "warning");
            return;
        }
        var data = await GetDataTransaksi($("#srcNoRefSubs_text1").val(), $("#srcCIFSubs_text1").val());
        
        if (data.blnResult != false) {
            var dataSource = new kendo.data.DataSource(
                {
                    data: data.dttSubscription
                });
            var dataGridViewSubs = $('#dataGridViewSubs').data('kendoGrid');
            dataGridViewSubs.setDataSource(dataSource);
            dataGridViewSubs.dataSource.pageSize(15);
            dataGridViewSubs.dataSource.page(1);
            dataGridViewSubs.select("tr:eq(0)");            
            subSetVisibleGrid(_strTabName);
            
            $("#srcOfficeSubs_text1").val(data.OfficeId);
            ValidateOffice($("#srcOfficeSubs_text1").val(), function (result) { $("#srcOfficeSubs_text2").val(result) });

            var criteria = _strTabName + "#" + $("#srcCIFSubs_text1").val();
            var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(criteria);
            $('#srcProductSubs').attr('href', url);

            var criteria = $("#srcCIFSubs_text1").val() + "#" + $("#srcProductSubs_text1").val() + "#" + _strTabName + "#0";
            var url = "/Global/SearchTrxClient/?criteria=" + encodeURIComponent(criteria);
            $('#srcClientSubs').attr('href', url);

            $("#txtbInputterSubs").val(data.Inputter);
            $("#srcSellerSubs_text1").val(data.Seller);
            ValidateReferentor(data.Seller, function (output) { $("#srcSellerSubs_text2").val(output); });            
            $("#srcWaperdSubs_text1").val(data.Waperd);
            ValidateWaperd(data.Waperd, function (result) {
                if (result != '') {
                    $("#srcWaperdSubs_text2").val(result[0].WaperdNo);
                    $("#textExpireWaperdSubs").val(result[0].DateExpire);
                }
                else {
                    $("#srcWaperdSubs_text1").val('');
                    $("#srcWaperdSubs_text2").val('');
                    $("#textExpireWaperdSubs").val('');
                }
            });
            $("#srcReferentorSubs_text1").val(data.Referentor);
            ValidateReferentor(data.Referentor, function (output) { $("#srcReferentorSubs_text2").val(output); });
        }
        else {
            swal("Warning", data.ErrMsg, "warning");
        }
    }
    else if (_strTabName == "REDEMP") {
        if ($("#srcNoRefRedemp_text1").val().length == 0) {
            swal("Warning", "Silahkan Pilih kode Nomor referensi terlebih dahulu!", "warning");
            return;
        }
        var data = await GetDataTransaksi($("#srcNoRefRedemp_text1").val(), $("#srcCIFRedemp_text1").val());

        if (data.blnResult != false) {
            var dataSource = new kendo.data.DataSource(
                {
                    data: data.dttRedemption
                });
            var dataGridViewRedemp = $('#dataGridViewRedemp').data('kendoGrid');
            dataGridViewRedemp.setDataSource(dataSource);
            dataGridViewRedemp.dataSource.pageSize(15);
            dataGridViewRedemp.dataSource.page(1);
            dataGridViewRedemp.select("tr:eq(0)");
            subSetVisibleGrid(_strTabName);

            $("#srcOfficeRedemp_text1").val(data.OfficeId);
            ValidateOffice($("#srcOfficeRedemp_text1").val(), function (result) { $("#srcOfficeRedemp_text2").val(result) });

            var criteria = _strTabName + "#" + $("#srcCIFRedemp_text1").val();
            var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(criteria);
            $('#srcProductRedemp').attr('href', url);

            var criteria = $("#srcCIFRedemp_text1").val() + "#" + $("#srcProductRedemp_text1").val() + "#" + _strTabName + "#0";
            var url = "/Global/SearchTrxClient/?criteria=" + encodeURIComponent(criteria);
            $('#srcClientRedemp').attr('href', url);

            $("#txtbInputterRedemp").val(data.Inputter);
            $("#srcSellerRedemp_text1").val(data.Seller);
            ValidateReferentor(data.Seller, function (output) { $("#srcSellerRedemp_text2").val(output); });
            $("#srcWaperdRedemp_text1").val(data.Waperd);
            ValidateWaperd(data.Waperd, function (result) {
                if (result != '') {
                    $("#srcWaperdRedemp_text2").val(result[0].WaperdNo);
                    $("#textExpireWaperdRedemp").val(result[0].DateExpire);
                }
                else {
                    $("#srcWaperdRedemp_text1").val('');
                    $("#srcWaperdRedemp_text2").val('');
                    $("#textExpireWaperdRedemp").val('');
                }
            });
            $("#srcReferentorRedemp_text1").val(data.Referentor);
            ValidateReferentor(data.Referentor, function (output) { $("#srcReferentorRedemp_text2").val(output); });
        }
        else {
            swal("Warning", data.ErrMsg, "warning");
        }
    }
    else if (_strTabName == "SUBSRDB") {
        if ($("#srcNoRefRDB_text1").val().length == 0) {
            swal("Warning", "Silahkan Pilih kode Nomor referensi terlebih dahulu!", "warning");
            return;
        }
        var data = await GetDataTransaksi($("#srcNoRefRDB_text1").val(), $("#srcCIFRDB_text1").val());

        if (data.blnResult != false) {
            var dataSource = new kendo.data.DataSource(
                {
                    data: data.dttSubsRDB
                });
            var dataGridViewRDB = $('#dataGridViewRDB').data('kendoGrid');
            dataGridViewRDB.setDataSource(dataSource);
            dataGridViewRDB.dataSource.pageSize(15);
            dataGridViewRDB.dataSource.page(1);
            dataGridViewRDB.select("tr:eq(0)");
            subSetVisibleGrid(_strTabName);

            $("#srcOfficeRDB_text1").val(data.OfficeId);
            ValidateOffice($("#srcOfficeRDB_text1").val(), function (result) { $("#srcOfficeRDB_text2").val(result) });

            var criteria = _strTabName + "#" + $("#srcCIFRDB_text1").val();
            var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(criteria);
            $('#srcProductRDB').attr('href', url);

            var criteria = $("#srcCIFRDB_text1").val() + "#" + $("#srcProductRDB_text1").val() + "#" + _strTabName + "#0";
            var url = "/Global/SearchTrxClient/?criteria=" + encodeURIComponent(criteria);
            $('#srcClientRDB').attr('href', url);

            $("#txtbInputterRDB").val(data.Inputter);
            $("#srcSellerRDB_text1").val(data.Seller);
            ValidateReferentor(data.Seller, function (output) { $("#srcSellerRDB_text2").val(output); });
            $("#srcWaperdRDB_text1").val(data.Waperd);
            ValidateWaperd(data.Waperd, function (result) {
                if (result != '') {
                    $("#srcWaperdRDB_text2").val(result[0].WaperdNo);
                    $("#textExpireWaperdRDB").val(result[0].DateExpire);
                }
                else {
                    $("#srcWaperdRDB_text1").val('');
                    $("#srcWaperdRDB_text2").val('');
                    $("#textExpireWaperdRDB").val('');
                }
            });
            $("#srcReferentorRDB_text1").val(data.Referentor);
            ValidateReferentor(data.Referentor, function (output) { $("#srcReferentorRDB_text2").val(output); });
        }
        else {
            swal("Warning", data.ErrMsg, "warning");
        }
    }
    else if (_strTabName == "SWCNONRDB") {
        if ($("#srcNoRefSwc_text1").val().length == 0) {
            swal("Warning", "Silahkan Pilih kode Nomor referensi terlebih dahulu!", "warning");
            return;
        }
        CIFNo = $("#srcCIFSwc_text1").val();
        RefID = $("#srcNoRefSwc_text1").val();
        $.ajax({
            type: 'GET',
            url: '/Transaksi/RefreshSwitching',
            data: { RefID: RefID, CIFNo: CIFNo },
            beforeSend: function () {
                $("#load_screen").show();
            }, 
            success: function (data) {
                if (data.blnResult) {
                    $("#srcOfficeSwc_text1").val(data.OfficeId);
                    ValidateOffice($("#srcOfficeSwc_text1").val(), function (result) { $("#srcOfficeSwc_text2").val(result) });

                    $("#textNoTransaksiSwc").val(data.listSwitching[0].TranCode);
                    var dateTglTransaksiSwc = new Date(data.listSwitching[0].TranDate);
                    $("#dateTglTransaksiSwc").val(pad((dateTglTransaksiSwc.getDate()), 2) + '/' + pad((dateTglTransaksiSwc.getMonth() + 1), 2) + '/' + dateTglTransaksiSwc.getFullYear());

                    var criteria = _strTabName + "#" + $("#srcCIFSwc_text1").val();
                    var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(criteria);
                    $('#srcProductSwcOut').attr('href', url);

                    $("#srcProductSwcOut_text1").val(data.listSwitching[0].ProdCodeSwcOut);
                    ValidateProduct($("#srcProductSwcOut_text1").val(), function (result) { $("#srcProductSwcOut_text2").val(result[0].ProdName) });

                    var criteria = $("#srcCIFSwc_text1").val() + "#" + $("#srcProductSwcOut_text1").val() + "#" + _strTabName + "#0";
                    var url = "/Global/SearchTrxClient/?criteria=" + encodeURIComponent(criteria);
                    $('#srcClientSwcOut').attr('href', url);                    

                    $("#srcClientSwcOut_text1").val(data.listSwitching[0].ClientCodeSwcOut);
                    var criteria = data.listSwitching[0].ClientCodeSwcOut + "#" + $("#srcProductSwcOut_text1").val() + "#" + _strTabName + "#0";
                    ValidateTrxClient($("#srcClientSwcOut_text1").val(), criteria, function (result) {
                        if (result != '') {
                            $("#srcClientSwcOut_text1").val(result[0].ClientName);
                            $("#ClientIdSwcOut").val(result[0].ClientId);
                            $("#IsEmployeeSwcOut").val(result[0].IsEmployee);
                        }
                        else {
                            $("#srcClientSwcOut_text1").val('');
                            $("#ClientIdSwcOut").val(0);
                            $("#IsEmployeeSwcOut").val(0);
                        }
                    });

                    $("#srcProductSwcIn_text1").val(data.listSwitching[0].srcProductSwcIn_text1);
                    $("#srcClientSwcIn_text1").val(data.listSwitching[0].srcClientSwcIn_text1);

                    $("#txtbInputterSwc").val(data.listSwitching[0].Inputter);
                    $("#srcSellerSwc_text1").val(data.listSwitching[0].Seller);
                    ValidateReferentor(data.listSwitching[0].Seller, function (output) { $("#srcSellerSwc_text2").val(output); });
                    $("#srcWaperdSwc_text1").val(data.listSwitching[0].Waperd);
                    ValidateWaperd(data.listSwitching[0].Waperd, function (result) {
                        if (result != '') {
                            $("#srcWaperdSwc_text2").val(result[0].WaperdNo);
                            $("#textExpireWaperdSwc").val(result[0].DateExpire);
                        }
                        else {
                            $("#srcWaperdSwc_text1").val('');
                            $("#srcWaperdSwc_text2").val('');
                            $("#textExpireWaperdSwc").val('');
                        }
                    });
                    $("#srcReferentorSwc_text1").val(data.listSwitching[0].Referentor);
                    ValidateReferentor(data.listSwitching[0].Referentor, function (output) { $("#srcReferentorSwc_text2").val(output); });

                    $('#checkPhoneOrderSwc').prop('checked', data.PhoneOrder);
                    $('#checkFeeEditSwc').prop('checked', data.IsFeeEdit);
                    $("#RedempSwc").data("kendoNumericTextBox").value(data.listSwitching[0].TranUnit);
                    $("#MoneyFeeSwc").data("kendoNumericTextBox").value(data.listSwitching[0].SwitchingFee);
                    $("#PercentageFeeSwc").data("kendoNumericTextBox").value(data.listSwitching[0].Percentage);
                    $("#currFeeSwc").text(data.listSwitching[0].TranCCY);

                    switch (data.listSwitching[0].Status) {
                        case "0":
                            {
                                $("#labelStatusSwc").text("Status : Pending");
                                break;
                            }
                        case "1":
                            {
                                $("#labelStatusSwc").text("Status : Authorized");
                                break;
                            }
                        case "2":
                            {
                                $("#labelStatusSwc").text("Status : Rejected");
                                break;
                            }
                        case "3":
                            {
                                $("#labelStatusSwc").text("Status : Reversed");
                                break;
                            }
                    }                    
                }
            },
            complete: function () {
                $("#load_screen").hide();
            }
        });
    }
    else if (_strTabName == "SWCRDB") {
        if ($("#srcNoRefSwcRDB_text1").val().length == 0) {
            swal("Warning", "Silahkan Pilih kode Nomor referensi terlebih dahulu!", "warning");
            return;
        }
        CIFNo = $("#srcCIFSwcRDB_text1").val();
        RefID = $("#srcNoRefSwcRDB_text1").val();
        $.ajax({
            type: 'GET',
            url: '/Transaksi/RefreshSwitchingRDB',
            data: { RefID: RefID, CIFNo: CIFNo },
            beforeSend: function () {
                $("#load_screen").show();
            }, 
            success: function (data) {
                if (data.blnResult) {
                    $("#srcOfficeSwcRDB_text1").val(data.OfficeId);
                    ValidateOffice($("#srcOfficeSwcRDB_text1").val(), function (result) { $("#srcOfficeSwcRDB_text2").val(result) });

                    $("#textNoTransaksiSwcRDB").val(data.listSwitchingRDB[0].TranCode);
                    var dateTglTransaksiSwcRDB = new Date(data.listSwitchingRDB[0].TranDate);
                    $("#dateTglTransaksiSwcRDB").val(pad((dateTglTransaksiSwcRDB.getDate()), 2) + '/' + pad((dateTglTransaksiSwcRDB.getMonth() + 1), 2) + '/' + dateTglTransaksiSwcRDB.getFullYear());

                    var criteria = _strTabName + "#" + $("#srcCIFSwcRDB_text1").val();
                    var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(criteria);
                    $('#srcProductSwcRDBOut').attr('href', url);

                    $("#srcProductSwcRDBOut_text1").val(data.listSwitchingRDB[0].ProdCodeSwcRDBOut);
                    ValidateProduct($("#srcProductSwcRDBOut_text1").val(), function (result) { $("#srcProductSwcRDBOut_text2").val(result[0].ProdName) });

                    var criteria = $("#srcCIFSwcRDB_text1").val() + "#" + $("#srcProductSwcRDBOut_text1").val() + "#" + _strTabName + "#0";
                    var url = "/Global/SearchTrxClient/?criteria=" + encodeURIComponent(criteria);
                    $('#srcClientSwcRDBOut').attr('href', url);

                    $("#srcClientSwcRDBOut_text1").val(data.listSwitchingRDB[0].ClientCodeSwcRDBOut);
                    var criteria = data.listSwitchingRDB[0].ClientCodeSwcRDBOut + "#" + $("#srcProductSwcRDBOut_text1").val() + "#" + _strTabName + "#0";
                    ValidateTrxClient($("#srcClientSwcRDBOut_text1").val(), criteria, function (result) {
                        if (result != '') {
                            $("#srcClientSwcRDBOut_text1").val(result[0].ClientName);
                            $("#ClientIdSwcRDBOut").val(result[0].ClientId);
                            $("#IsEmployeeSwcRDBOut").val(result[0].IsEmployee);
                        }
                        else {
                            $("#srcClientSwcRDBOut_text1").val('');
                            $("#ClientIdSwcRDBOut").val(0);
                            $("#IsEmployeeSwcRDBOut").val(0);
                        }
                    });

                    $("#srcProductSwcRDBIn_text1").val(data.listSwitchingRDB[0].srcProductSwcRDBIn_text1);
                    $("#srcClientSwcRDBIn_text1").val(data.listSwitchingRDB[0].srcClientSwcRDBIn_text1);

                    $("#txtbInputterSwcRDB").val(data.listSwitchingRDB[0].Inputter);
                    $("#srcSellerSwcRDB_text1").val(data.listSwitchingRDB[0].Seller);
                    ValidateReferentor(data.listSwitchingRDB[0].Seller, function (output) { $("#srcSellerSwcRDB_text2").val(output); });
                    $("#srcWaperdSwcRDB_text1").val(data.listSwitchingRDB[0].Waperd);
                    ValidateWaperd(data.listSwitchingRDB[0].Waperd, function (result) {
                        if (result != '') {
                            $("#srcWaperdSwcRDB_text2").val(result[0].WaperdNo);
                            $("#textExpireWaperdSwcRDB").val(result[0].DateExpire);
                        }
                        else {
                            $("#srcWaperdSwcRDB_text1").val('');
                            $("#srcWaperdSwcRDB_text2").val('');
                            $("#textExpireWaperdSwcRDB").val('');
                        }
                    });
                    $("#srcReferentorSwcRDB_text1").val(data.listSwitchingRDB[0].Referentor);
                    ValidateReferentor(data.listSwitchingRDB[0].Referentor, function (output) { $("#srcReferentorSwcRDB_text2").val(output); });

                    $('#checkPhoneOrderSwcRDB').prop('checked', data.PhoneOrder);
                    $('#checkFeeEditSwcRDB').prop('checked', data.IsFeeEdit);
                    $("#RedempSwcRDB").data("kendoNumericTextBox").value(data.listSwitchingRDB[0].TranUnit);
                    $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").value(data.listSwitchingRDB[0].SwitchingFee);
                    $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value(data.listSwitchingRDB[0].Percentage);
                    $("#currFeeSwcRDB").text(data.listSwitchingRDB[0].TranCCY);

                    $("#JangkaWktSwcRDB").data("kendoNumericTextBox").value(data.listSwitchingRDB[0].JangkaWaktu);
                    dtJatuhTempoSwcRDB = new Date(data.listSwitchingRDB[0].JatuhTempo);
                    $("#dtJatuhTempoSwcRDB").val(pad((dtJatuhTempoSwcRDB.getDate()), 2) + '/' + pad((dtJatuhTempoSwcRDB.getMonth() + 1), 2) + '/' + dtJatuhTempoSwcRDB.getFullYear());
                    $("#cmbFrekPendebetanSwcRDB").data('kendoDropDownList').text(data.listSwitchingRDB[0].FrekPendebetan);
                
                    if (data.listSwitchingRDB[0].AutoRedemption == true) {
                        $("#cmbAutoRedempSwcRDB").data('kendoDropDownList').text("Ya");
                    }
                    else {
                        cmbAutoRedempSwcRDB.Text = "TIDAK";
                        $("#cmbAutoRedempSwcRDB").data('kendoDropDownList').text("Tidak");
                    }

                    if (data.listSwitchingRDB[0].Asuransi == true) {
                        $("#cmbAsuransiSwcRDB").data('kendoDropDownList').text("Ya");
                    }
                    else {
                        $("#cmbAsuransiSwcRDB").data('kendoDropDownList').text("Tidak");
                    }

                    switch (data.listSwitchingRDB[0].Status) {
                        case "0":
                            {
                                $("#labelStatusSwcRDB").text("Status : Pending");
                                break;
                            }
                        case "1":
                            {
                                $("#labelStatusSwcRDB").text("Status : Authorized");
                                break;
                            }
                        case "2":
                            {
                                $("#labelStatusSwcRDB").text("Status : Rejected");
                                break;
                            }
                        case "3":
                            {
                                $("#labelStatusSwcRDB").text("Status : Reversed");
                                break;
                            }
                    }

                }
            },
            complete: function () {
                $("#load_screen").hide();
            }
        });
    }
    else if (_strTabName == "BOOK") {
        if ($("#srcNoRefBooking_text1").val().length == 0) {
            swal("Warning", "Silahkan Pilih kode Nomor referensi terlebih dahulu!", "warning");
            return;
        }
        CIFNo = $("#srcCIFBooking_text1").val();
        RefID = $("#srcNoRefBooking_text1").val();
        $.ajax({
            type: 'GET',
            url: '/Transaksi/RefreshBooking',
            data: { RefID: RefID, CIFNo: CIFNo },
            beforeSend: function () {
                $("#load_screen").show();
            }, 
            success: function (data) {
                if (data.blnResult) {
                    $("#srcOfficeBooking_text1").val(data.OfficeId);
                    ValidateOffice($("#srcOfficeBooking_text1").val(), function (result) { $("#srcOfficeBooking_text2").val(result) });

                    var criteria = _strTabName + "#" + $("#srcCIFBooking_text1").val();
                    var url = "/Global/SearchTrxProduct/?criteria=" + encodeURIComponent(criteria);
                    $('#srcProductBooking').attr('href', url);

                    var criteria = $("#srcCIFBooking_text1").val() + "#" + $("#srcProductBooking_text1").val() + "#" + _strTabName + "#0";
                    var url = "/Global/SearchTrxClient/?criteria=" + encodeURIComponent(criteria);
                    $('#srcClientBooking').attr('href', url);

                    $("#textNoTransaksiBooking").val(data.listBooking[0].BookingCode);
                    $("#srcProductBooking_text1").val(data.listBooking[0].ProdCode);
                    ValidateProduct(data.listBooking[0].ProdCode, function (result) { $("#srcProductBooking_text2").val(result[0].ProdName) });
                    $("#srcClientBooking_text1").val(data.listBooking[0].ClientCode);
                    var criteria = data.listBooking[0].ClientCode + "#" + $("#srcProductBooking_text1").val() + "#" + _strTabName + "#0";
                    ValidateTrxClient($("#srcClientBooking_text1").val(), criteria, function (result) {
                        if (result != '') {
                            $("#srcClientBooking_text1").val(result[0].ClientName);
                            $("#ClientIdBooking").val(result[0].ClientId);
                            $("#IsEmployeeBooking").val(result[0].IsEmployee);
                        }
                        else {
                            $("#srcClientBooking_text1").val('');
                            $("#ClientIdBooking").val(0);
                            $("#IsEmployeeBooking").val(0);
                        }
                    });
                    $("#srcCurrencyBooking_text1").val(data.listBooking[0].BookingCCY);
                    ValidateCurrency($("#srcCurrencyBooking_text1").val(), function (result) { $("#srcCurrencyBooking_text2").val(result); });
                    $("#txtbInputterBooking").val(data.listBooking[0].Inputter);
                    $("#srcSellerBooking_text1").val(data.listBooking[0].Seller);
                    ValidateReferentor(data.listBooking[0].Seller, function (output) { $("#srcSellerBooking_text2").val(output); });
                    $("#srcWaperdBooking_text1").val(data.listBooking[0].Waperd);
                    ValidateWaperd(data.listBooking[0].Waperd, function (result) {
                        if (result != '') {
                            $("#srcWaperdBooking_text2").val(result[0].WaperdNo);
                            $("#textExpireWaperdBooking").val(result[0].DateExpire);
                        }
                        else {
                            $("#srcWaperdBooking_text1").val('');
                            $("#srcWaperdBooking_text2").val('');
                            $("#textExpireWaperdBooking").val('');
                        }
                    });
                    $("#srcReferentorBooking_text1").val(data.listBooking[0].Referentor);
                    ValidateReferentor(data.listBooking[0].Referentor, function (output) { $("#srcReferentorBooking_text2").val(output); });

                    var dateTglTransaksiBooking = new Date(data.listBooking[0].BookingDate);
                    $("#dateTglTransaksiBooking").val(dateTglTransaksiBooking.getDate() + '/' + (dateTglTransaksiBooking.getMonth() + 1) + '/' + dateTglTransaksiBooking.getFullYear());
                    $("#MoneyNomBooking").data("kendoNumericTextBox").value(data.listBooking[0].BookingAmt);
                    $('#checkPhoneOrderBooking').prop('checked', data.listBooking[0].PhoneOrder);
                    $('#checkFeeEditBooking').prop('checked', data.listBooking[0].IsFeeEdit);

                    $("#_ComboJenisBooking").data('kendoDropDownList').value(data.listBooking[0].JenisPerhitunganFee);
                    $("#MoneyFeeBooking").data("kendoNumericTextBox").value(data.listBooking[0].SubcFee);
                    $("#PercentageFeeBooking").data("kendoNumericTextBox").value(data.listBooking[0].PercentageFee);
                    $("#labelFeeCurrencyBooking").text(data.listBooking[0].BookingCCY);

                    switch (data.listBooking[0].Status) {
                        case "0":
                            {
                                $("#labelStatusBook").text("Status : Pending");
                                break;
                            }
                        case "1":
                            {
                                $("#labelStatusBook").text("Status : Authorized");
                                break;
                            }
                        case "2":
                            {
                                $("#labelStatusBook").text("Status : Rejected");
                                break;
                            }
                        case "3":
                            {
                                $("#labelStatusBook").text("Status : Reversed");
                                break;
                            }
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
    //_intType = 0;
    DisableAllForm(false);
    subResetToolBar();
}
function subNew() {
    _intType = 1;
    ResetForm();
    DisableAllForm(true);
    subResetToolBar();
    SetDefaultValue();

    $('#checkFullAmtSubs').prop('checked', true);

    $("#srcCIFSubs_text1").prop('disabled', false);
    $("#srcCIFSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

    $("#srcCIFRedemp_text1").prop('disabled', false);
    $("#srcCIFRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

    $("#srcCIFRDB_text1").prop('disabled', false);
    $("#srcCIFRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

    $("#srcCIFSwc_text1").prop('disabled', false);
    $("#srcCIFSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

    $("#srcCIFSwcRDB_text1").prop('disabled', false);
    $("#srcCIFSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

    $("#CIFNoBooking").prop('disabled', false);
    $("#srcCIFBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

    var strCriteria = "";
    GetKodeKantor();
    //cTransaksi.ClearData();
    SetEnableOfficeId(strBranch);

    var url;
    if (_strTabName == "SUBS") {
        IsSubsNew = true;
        DisableFormTrxSubs(true);
        //REKSA_CIF_ALL
        url = "/Global/SearchCIFAll/?criteria=" + _strTabName;
        $('#srcCIFSubs').attr('href', url);

        $("#srcClientSubs_text1").prop('disabled', true);
        $("#srcClientSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

        strCriteria = _strTabName + "#" + $("#srcCIFSubs_text1").val();
        //REKSA_TRXPRODUCT
        url = "/Global/SearchTrxProduct";
        $('#scrProductSubs').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));

        document.getElementById("btnAddSubs").disabled = false;
        document.getElementById("btnEditSubs").disabled = true;
        $("#dateTglTransaksiSubs").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    }
    else if (_strTabName == "REDEMP") {
        DisableFormTrxRedemp(true);
        IsRedempAll = false;
        //REKSA_CIF_ALL
        url = "/Global/SearchCIFAll/?criteria=" + _strTabName;
        $('#srcCIFRedemp').attr('href', url);

        strCriteria = _strTabName + "#" + $("#srcCIFRedemp_text1").val();
        //REKSA_TRXPRODUCT
        url = "/Global/SearchTrxProduct";
        $('#srcProductRedemp').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));

        document.getElementById("btnAddRedemp").disabled = false;
        document.getElementById("btnEditRedemp").disabled = true;
        $("#dateTglTransaksiRedemp").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    }
    else if (_strTabName == "SUBSRDB") {
        DisableFormTrxRDB(true);

        //REKSA_CIF_ALL
        url = "/Global/SearchCIFAll/?criteria=" + _strTabName;
        $('#srcCIFRDB').attr('href', url);

        $("#srcClientRDB_text1").prop('disabled', true);
        $("#srcClientRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

        strCriteria = _strTabName + "#" + $("#srcCIFRDB_text1").val();
        //REKSA_TRXPRODUCT
        url = "/Global/SearchCIFAll/?criteria=" + _strTabName;
        $('#srcProductRDB').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));

        document.getElementById("btnAddRDB").disabled = false;
        document.getElementById("btnEditRDB").disabled = true;
        $("#dateTglTransaksiRDB").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    }
    else if (_strTabName == "BOOK") {
        //REKSA_CIF_ALL
        url = "/Global/SearchCIFAll/?criteria=" + _strTabName;
        $('#srcCIFBooking').attr('href', url);

        strCriteria = _strTabName + "#" + $("#srcCIFBooking_text1").val();
        //REKSA_TRXPRODUCT
        url = "/Global/SearchTrxProduct";
        $('#srcProductBooking').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));

        $("#dateTglTransaksiBooking").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    }
    else if (_strTabName == "SWCNONRDB") {
        //REKSA_CIF_ALL
        url = "/Global/SearchCIFAll/?criteria=" + _strTabName;
        $('#srcCIFSwc').attr('href', url);

        strCriteria = _strTabName + "#" + $("#srcCIFSwc_text1").val();
        //REKSA_TRXPRODUCT
        url = "/Global/SearchTrxProduct";
        $('#srcProductSwcOut').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));

        //TRXSWITCHIN
        url = "/Global/SearchTrxProductSwcIn";
        $('#srcProductSwcIn').attr('href', url + '?criteria=' + $('#ProductCodeSwcOut').val());

        $("#dateTglTransaksiSwc").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    }
    else if (_strTabName == "SWCRDB") {
        //REKSA_CIF_ALL
        url = "/Global/SearchCIFAll/?criteria=" + _strTabName;
        $('#srcCIFSwcRDB').attr('href', url);

        strCriteria = _strTabName + "#" + $("#srcCIFSwcRDB_text1").val();
        //REKSA_TRXPRODUCT
        url = "/Global/SearchTrxProduct";
        $('#srcProductSwcRDBOut').attr('href', url + '?criteria=' + encodeURIComponent(strCriteria));

        //TRXSWITCHIN
        url = "/Global/SearchTrxProductSwcIn";
        $('#srcProductSwcRDBIn').attr('href', url + '?criteria=' + $('#ProductCodeSwcRDBOut').val());

        $("#dateTglTransaksiSwcRDB").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    }
}
function subUpdate()
{
    if (_strTabName == "SUBS") {
        if ($("#srcCIFSubs_text1").val() == "") {
            swal("Warning", "No CIF Subscription Harus Diisi!", "warning");
            return;
        }
        if ($("#srcNoRefSubs_text1").val() == "") {
            swal("Warning", "No Referensi Subscription Harus Diisi!", "warning");
            return;
        }
        //if (!CheckCIF(cmpsrCIFSubs.Text1.Trim())) {
        //    return;
        //}
    }
    else if (_strTabName == "REDEMP") {
        if ($("#srcCIFRedemp_text1").val() == "") {
            swal("Warning", "No CIF Redemption Harus Diisi!", "warning");
            return;
        }
        if ($("#srcNoRefRedemp_text1").val() == "") {
            swal("Warning", "No Referensi Redemption Harus Diisi!", "warning");
            return;
        }
        //if (!CheckCIF(cmpsrCIFSubs.Text1.Trim())) {
        //    return;
        //}
    }
    else if (_strTabName == "SUBSRDB") {
        if ($("#srcCIFRDB_text1").val() == "") {
            swal("Warning", "No CIF RDB Harus Diisi!", "warning");
            return;
        }
        if ($("#srcNoRefRDB_text1").val() == "") {
            swal("Warning", "No Referensi RDB Harus Diisi!", "warning");
            return;
        }
        //if (!CheckCIF(cmpsrCIFSubs.Text1.Trim())) {
        //    return;
        //}
    }
    else if (_strTabName == "BOOK") {
        if ($("#srcCIFBooking_text1").val() == "") {
            swal("Warning", "No CIF Booking Harus Diisi!", "warning");
            return;
        }
        if ($("#srcNoRefBooking_text1").val() == "") {
            swal("Warning", "No Referensi Booking Harus Diisi!", "warning");
            return;
        }
        //if (!CheckCIF(cmpsrCIFSubs.Text1.Trim())) {
        //    return;
        //}
    }
    else if (_strTabName == "SWCNONRDB") {
        if ($("#srcCIFSwc_text1").val() == "") {
            swal("Warning", "No CIF Switching Harus Diisi!", "warning");
            return;
        }
        if ($("#srcNoRefSwc_text1").val() == "") {
            swal("Warning", "No Referensi Switching Harus Diisi!", "warning");
            return;
        }
        //if (!CheckCIF(cmpsrCIFSubs.Text1.Trim())) {
        //    return;
        //}
    }
    else if (_strTabName == "SWCRDB") {
        if ($("#srcCIFSwcRDB_text1").val() == "") {
            swal("Warning", "No CIF Switching RDB Harus Diisi!", "warning");
            return;
        }
        if ($("#srcNoRefSwcRDB_text1").val() == "") {
            swal("Warning", "No Referensi Switching RDB Harus Diisi!", "warning");
            return;
        }
        //if (!CheckCIF(cmpsrCIFSubs.Text1.Trim())) {
        //    return;
        //}
    }
    subRefresh();
    _intType = 2;
    DisableAllForm(false);
    subResetToolBar();
    if (_strTabName == "SUBS") {
        DisableFormTrxSubs(false);
        $('#srcCIFSubs').attr('href', '/Global/SearchCIFAll/?criteria=SUBS');
        var strCriteria = _strTabName + "#" + $("#srcCIFSubs_text1").val();
        $('#srcProductSubs').attr('href', '/Global/SearchTrxProduct/?criteria=' + encodeURIComponent(strCriteria));
        document.getElementById("btnAddSubs").disabled = true;
        document.getElementById("btnEditSubs").disabled = false;
        $("#srcCIFSubs_text1").prop('disabled', true);
        $("#srcCIFSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcNoRefSubs_text1").prop('disabled', true);
        $("#srcNoRefSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    }
    else if (_strTabName == "REDEMP") {
        DisableFormTrxRedemp(false);
        $('#srcCIFRedemp').attr('href', '/Global/SearchCIFAll/?criteria=REDEMP');
        var strCriteria = _strTabName + "#" + $("#srcCIFRedemp_text1").val();
        $('#srcProductRedemp').attr('href', '/Global/SearchTrxProduct/?criteria=' + encodeURIComponent(strCriteria));
        document.getElementById("btnAddRedemp").disabled = true;
        document.getElementById("btnEditRedemp").disabled = false;
        $("#srcCIFRedemp_text1").prop('disabled', true);
        $("#srcCIFRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcNoRefRedemp_text1").prop('disabled', true);
        $("#srcNoRefRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }
    else if (_strTabName == "SUBSRDB") {
        DisableFormTrxRDB(false);
        $('#srcCIFRDB').attr('href', '/Global/SearchCIFAll/?criteria=SUBSRDB');
        var strCriteria = _strTabName + "#" + $("#srcCIFRDB_text1").val();
        $('#srcProductRDB').attr('href', '/Global/SearchTrxProduct/?criteria=' + encodeURIComponent(strCriteria));
        document.getElementById("btnAddRDB").disabled = true;
        document.getElementById("btnEditRDB").disabled = false;
        $("#srcCIFRDB_text1").prop('disabled', true);
        $("#srcCIFRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcNoRefRDB_text1").prop('disabled', true);
        $("#srcNoRefRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }
    else if (_strTabName == "BOOK") {
        DisableFormTrxBooking(false);
        $('#srcCIFBooking').attr('href', '/Global/SearchCIFAll/?criteria=BOOK');
        var strCriteria = _strTabName + "#" + $("#srcCIFBooking_text1").val();
        $('#srcProductBooking').attr('href', '/Global/SearchTrxProduct/?criteria=' + encodeURIComponent(strCriteria));

        //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFBooking.Text1)) {
        //    checkPhoneOrderBooking.Enabled = false;
        //    checkPhoneOrderBooking.Checked = false;
        //}
        //else {
        //    checkPhoneOrderBooking.Enabled = true;
        //}
    }
    else if (_strTabName == "SWCNONRDB") {
        DisableFormSwc(false);
        $('#srcCIFSwc').attr('href', '/Global/SearchCIFAll/?criteria=SWCNONRDB');

        var strCriteria = _strTabName + "#" + $("#srcCIFSwc_text1").val();
        $('#srcProductSwcOut').attr('href', '/Global/SearchTrxProduct/?criteria=' + encodeURIComponent(strCriteria));

        var strCriteria = $("#srcProductSwcOut_text1").val();
        $('#srcProductSwcIn').attr('href', '/Global/SearchTrxProductSwcIn/?criteria=' + encodeURIComponent(strCriteria));
        //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFBooking.Text1)) {
        //    checkPhoneOrderBooking.Enabled = false;
        //    checkPhoneOrderBooking.Checked = false;
        //}
        //else {
        //    checkPhoneOrderBooking.Enabled = true;
        //}
    }
    else if (_strTabName == "SWCRDB") {
        DisableFormSwcRDB(false);

        $('#srcCIFSwcRDB').attr('href', '/Global/SearchCIFAll/?criteria=SWCRDB');

        var strCriteria = _strTabName + "#" + $("#srcCIFSwcRDB_text1").val();
        $('#srcProductSwcRDBOut').attr('href', '/Global/SearchTrxProduct/?criteria=' + encodeURIComponent(strCriteria));

        var strCriteria = $("#srcProductSwcRDBOut_text1").val();
        $('#srcProductSwcRDBIn').attr('href', '/Global/SearchTrxProductSwcIn/?criteria=' + encodeURIComponent(strCriteria));
        //if (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFBooking.Text1)) {
        //    checkPhoneOrderBooking.Enabled = false;
        //    checkPhoneOrderBooking.Checked = false;
        //}
        //else {
        //    checkPhoneOrderBooking.Enabled = true;
        //}
        
        var res = GetDataRDB($("#srcClientSwcRDBOut_text1").val());
        var DoneDebet = "";
        res.success(function (data) {
            if (data.blnResult) {
                if (data.listClientRDB.length > 0)
                {
                    DoneDebet = listClientRDB[0].IsDoneDebet;
                }
                if ($("#JangkaWktSwcRDB").data("kendoNumericTextBox").value()  == 0 && (DoneDebet == "1")) {
                    $("#RedempSwcRDB").data("kendoNumericTextBox").enable(true);
                    var strCriteria = $("#srcCIFSwcRDB_text1").val() + $("#srcProductSwcRDBIn_text1").val() + "#SWCNONRDB";
                    $('#srcClientSwcRDBIn').attr('href', '/Global/SearchTrxProduct/?criteria=' + encodeURIComponent(strCriteria));
                    IsSwitchingRDBSebagian = true;
                }
                else
                {
                    $("#RedempSwcRDB").data("kendoNumericTextBox").enable(false);
                    $("#RedempSwcRDB").data("kendoNumericTextBox").value($("#OutstandingUnitSwcRDB").val());
                    var strCriteria = $("#srcCIFSwcRDB_text1").val() + $("#srcProductSwcRDBIn_text1").val() + "#" + _strTabName;
                    $('#srcClientSwcRDBIn').attr('href', '/Global/SearchTrxProduct/?criteria=' + encodeURIComponent(strCriteria));
                    IsSwitchingRDBSebagian = false;
                }
            }
        });
    }
}
function subSave() {
    if (_strTabName == "SUBS") {
        if ($("#srcOfficeSubs_text1").val() == "") {
            swal("Warning", "Kode Kantor harus diisi", "warning");
            return;
        }

        ValidasiInputKodeKantor($("#srcOfficeSubs_text1").val(), function (strIsAllowed) {
            if (strIsAllowed == "0") {
                swal("Error", "Error [ReksaValidateOfficeId], Kode kantor tidak terdaftar", "warning");
                ResetFormSubs();
            }
        });

        //string strErrorMessage;
        //strIsAllowed = "";
        //if (clsValidator.ValidasiUserCBO(ClQ, cmpsrKodeKantorSubs.Text1, strBranch, out strIsAllowed, out strErrorMessage)) {
        //    if (strIsAllowed == "0") {
        //        MessageBox.Show("Error [ReksaValidateUserCBOOffice], " + strErrorMessage, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //        ResetFormSubs();
        //        return;
        //    }
        //}
        //else {
        //    MessageBox.Show("Error [ReksaValidateUserCBOOffice]!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}

        if ($("#srcCIFSubs_text1").val() == "") {
            swal("Warning", "CIF harus diisi", "warning");
            return;
        }

        //if (!GlobalFunctionCIF.RetrieveCIFData(intNIK, strBranch, strModule, strGuid, Int64.Parse(cmpsrCIFSubs.Text1))) {
        //    swal("Warning", "Gagal validasi CIF ke modul ProCIF", "warning");
        //    return;
        //}

        //if ((checkPhoneOrderSubs.Checked) && (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSubs.Text1))) {
        //    swal("Warning", "Nasabah tidak memiliki fasilitas phone order!", "warning");
        //    return;
        //}

        //if ($("#textShareHolderIdSubs").val() == "") {
        //    swal("Warning", "Shareholder ID harus terdaftar", "warning");
        //    return;
        //}

        if ($("#srcSellerSubs_text1").val() == "") {
            swal("Warning", "NIK Seller harus diisi", "warning");
            return;
        }

        if ($("#srcWaperdSubs_text1").val() == "") {
            swal("Warning", "NIK Seller tidak terdaftar sbg WAPERD", "warning");
            return;
        }

        var grid = $("#dataGridViewSubs").data("kendoGrid");
        grid.refresh();
        var dataItem = grid.dataSource.view();

        if (dataItem.length == 0) {
            swal("Warning", "Data transaksi subscription tidak boleh kosong!", "warning");
            return;
        }

        //if (!System.Convert.ToBoolean(objFormDocument.chkbDocFCSubscriptionForm.CheckState)) {
        //    swal("Penerimaan Dokumen dari Nasabah", "Formulir Subscription wajib ada", "warning");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocFCIDCopy.CheckState)) {
        //    swal("Penerimaan Dokumen dari Nasabah", "Copy Bukti Identitas wajib ada", "warning");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCSubscriptionForm.CheckState)) {
        //    swal("Dokumen yang diterima oleh Nasabah", "Copy Formulir Subscription wajib ada", "warning");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCProspectus.CheckState)) {
        //    swal("Dokumen yang diterima oleh Nasabah", "Prospektus wajib ada", "warning");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCFundFactSheet.CheckState)) {
        //    swal("Dokumen yang diterima oleh Nasabah", "Fund Fact Sheet wajib ada", "warning");
        //    return;
        //}

        var grid = $("#dataGridViewSubs").data("kendoGrid");
        var arrSubs;
        var arrRedemp = [];
        var arrRDB = [];
        arrSubs = grid.dataSource.view();

        var model = JSON.stringify({
            'intType': _intType,
            'strTranType': _strTabName,
            'RefID': $("#srcNoRefSubs_text1").val(),
            'CIFNo': $("#srcCIFSubs_text1").val(),
            'OfficeId': $("#srcOfficeSubs_text1").val(),
            'NoRekening': $("#maskedRekeningSubs").val(),
            'dtSubs': arrSubs,
            'dtRedemp': arrRedemp,
            'dtRDB': arrRDB,
            'Inputter': $("#txtbInputterSubs").val(),
            'Seller': $("#srcSellerSubs_text1").val(),
            'Waperd': $("#srcWaperdSubs_text1").val(),
            'NoRekeningUSD': $("#maskedRekeningSubsUSD").val(),
            'NoRekeningMC': $("#maskedRekeningSubsMC").val(),
            'Referentor': $("#srcReferentorSubs_text1").val(),
            'pbDocFCSubscriptionForm': false,
            'pbDocFCDevidentAuthLetter': false,
            'pbDocFCJoinAcctStatementLetter': false,
            'pbDocFCIDCopy': false,
            'pbDocFCOthers': false,
            'pbDocTCSubscriptionForm': false,
            'pbDocTCTermCondition': false,
            'pbDocTCProspectus': false,
            'pbDocTCFundFactSheet': false,
            'pbDocTCOthers': false,
            'pcDocFCOthersList': '',
            'pcDocTCOthersList': ''
        });
        MaintainAllTransaksi(model);
    }
    else if (_strTabName == "REDEMP") {
        if ($("#srcOfficeRedemp_text1").val() == "") {
            swal("Warning", "Kode Kantor harus diisi", "warning");
            return;
        }

        ValidasiInputKodeKantor($("#srcOfficeRedemp_text1").val(), function (strIsAllowed) {
            if (strIsAllowed == "0") {
                swal("Error", "Error [ReksaValidateOfficeId], Kode kantor tidak terdaftar", "warning");
                ResetFormRedemp();
            }
        });

        //string strErrorMessage;
        //strIsAllowed = "";
        //if (clsValidator.ValidasiUserCBO(ClQ, cmpsrKodeKantorRedemp.Text1, strBranch, out strIsAllowed, out strErrorMessage)) {
        //    if (strIsAllowed == "0") {
        //        MessageBox.Show("Error [ReksaValidateUserCBOOffice], " + strErrorMessage, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //        ResetFormRedemp();
        //        return;
        //    }
        //}
        //else {
        //    MessageBox.Show("Error [ReksaValidateUserCBOOffice]!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}

        if ($("#srcCIFRedemp_text1").val() == "") {
            swal("Warning", "CIF harus diisi", "warning");
            return;
        }

        //if (!GlobalFunctionCIF.RetrieveCIFData(intNIK, strBranch, strModule, strGuid, Int64.Parse(cmpsrCIFRedemp.Text1))) {
        //    MessageBox.Show("Gagal validasi CIF ke modul ProCIF", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}

        //if ((checkPhoneOrderRedemp.Checked) && (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFRedemp.Text1))) {
        //    MessageBox.Show("Nasabah tidak memiliki fasilitas phone order!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}

        if ($("#textShareHolderIdRedemp").val() == "") {
            swal("Warning", "Shareholder ID harus terdaftar", "warning");
            return;
        }

        if ($("#srcSellerRedemp_text1").val() == "") {
            swal("Warning", "NIK Seller harus diisi", "warning");
            return;
        }

        if ($("#srcWaperdRedemp_text1").val() == "") {
            swal("Warning", "NIK Seller tidak terdaftar sbg WAPERD", "warning");
            return;
        }

        var grid = $("#dataGridViewRedemp").data("kendoGrid");
        grid.refresh();
        var dataItem = grid.dataSource.view();

        if (dataItem.length == 0) {
            swal("Warning", "Data transaksi redemption tidak boleh kosong!", "warning");
            return;
        }

        var grid = $("#dataGridViewRedemp").data("kendoGrid");
        var arrSubs = [];
        var arrRedemp;
        var arrRDB = [];
        arrRedemp = grid.dataSource.view();

        var model = JSON.stringify({
            'intType': _intType,
            'strTranType': _strTabName,
            'RefID': $("#srcNoRefRedemp_text1").val(),
            'CIFNo': $("#srcCIFRedemp_text1").val(),
            'OfficeId': $("#srcOfficeRedemp_text1").val(),
            'NoRekening': $("#maskedRekeningRedemp").val(),
            'dtSubs': arrSubs,
            'dtRedemp': arrRedemp,
            'dtRDB': arrRDB,
            'Inputter': $("#txtbInputterRedemp").val(),
            'Seller': $("#srcSellerRedemp_text1").val(),
            'Waperd': $("#srcWaperdRedemp_text1").val(),
            'NoRekeningUSD': $("#maskedRekeningRedempUSD").val(),
            'NoRekeningMC': $("#maskedRekeningRedempMC").val(),
            'Referentor': $("#srcReferentorRedemp_text1").val(),
            'pbDocFCSubscriptionForm': false,
            'pbDocFCDevidentAuthLetter': false,
            'pbDocFCJoinAcctStatementLetter': false,
            'pbDocFCIDCopy': false,
            'pbDocFCOthers': false,
            'pbDocTCSubscriptionForm': false,
            'pbDocTCTermCondition': false,
            'pbDocTCProspectus': false,
            'pbDocTCFundFactSheet': false,
            'pbDocTCOthers': false,
            'pcDocFCOthersList': '',
            'pcDocTCOthersList': ''
        });
        MaintainAllTransaksi(model);
    }
    else if (_strTabName == "SUBSRDB") {
        if ($("#srcOfficeRDB_text1").val() == "") {
            swal("Warning", "Kode Kantor harus diisi", "warning");
            return;
        }

        ValidasiInputKodeKantor($("#srcOfficeRDB_text1").val(), function (strIsAllowed) {
            if (strIsAllowed == "0") {
                swal("Error", "Error [ReksaValidateOfficeId], Kode kantor tidak terdaftar", "warning");
                ResetFormRDB();
            }
        });

        //string strErrorMessage;
        //strIsAllowed = "";
        //if (clsValidator.ValidasiUserCBO(ClQ, cmpsrKodeKantorRDB.Text1, strBranch, out strIsAllowed, out strErrorMessage)) {
        //    if (strIsAllowed == "0") {
        //        MessageBox.Show("Error [ReksaValidateUserCBOOffice], " + strErrorMessage, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //        ResetFormRDB();
        //        return;
        //    }
        //}
        //else {
        //    MessageBox.Show("Error [ReksaValidateUserCBOOffice]!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}

        if ($("#srcCIFRDB_text1").val() == "") {
            swal("Warning", "CIF harus diisi", "warning");
            return;
        }

        //if (!GlobalFunctionCIF.RetrieveCIFData(intNIK, strBranch, strModule, strGuid, Int64.Parse(cmpsrCIFRDB.Text1))) {
        //    MessageBox.Show("Gagal validasi CIF ke modul ProCIF", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}

        //if ((checkPhoneOrderRDB.Checked) && (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFRDB.Text1))) {
        //    MessageBox.Show("Nasabah tidak memiliki fasilitas phone order!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}

        if ($("#textShareHolderIdRDB").val() == "") {
            swal("Warning", "Shareholder ID harus terdaftar", "warning");
            return;
        }

        if ($("#srcSellerRDB_text1").val() == "") {
            swal("Warning", "NIK Seller harus diisi", "warning");
            return;
        }

        if ($("#srcWaperdRDB_text1").val() == "") {
            swal("Warning", "NIK Seller tidak terdaftar sbg WAPERD", "warning");
            return;
        }

        var grid = $("#dataGridViewRDB").data("kendoGrid");
        grid.refresh();
        var dataItem = grid.dataSource.view();

        if (dataItem.length == 0) {
            swal("Warning", "Data transaksi RDB tidak boleh kosong!", "warning");
            return;
        }

        //if (!System.Convert.ToBoolean(objFormDocument.chkbDocFCSubscriptionForm.CheckState)) {
        //    MessageBox.Show("Formulir Subscription wajib ada", "Penerimaan Dokumen dari Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocFCIDCopy.CheckState)) {
        //    MessageBox.Show("Copy Bukti Identitas wajib ada", "Penerimaan Dokumen dari Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCSubscriptionForm.CheckState)) {
        //    MessageBox.Show("Copy Formulir Subscription wajib ada", "Dokumen yang diterima oleh Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCProspectus.CheckState)) {
        //    MessageBox.Show("Prospektus wajib ada", "Dokumen yang diterima oleh Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCFundFactSheet.CheckState)) {
        //    MessageBox.Show("Fund Fact Sheet wajib ada", "Dokumen yang diterima oleh Nasabah");
        //    return;
        //}

        var grid = $("#dataGridViewRDB").data("kendoGrid");
        var arrSubs = [];
        var arrRedemp = [];
        var arrRDB;
        arrRDB = grid.dataSource.view();

        var model = JSON.stringify({
            'intType': _intType,
            'strTranType': _strTabName,
            'RefID': $("#srcNoRefRDB_text1").val(),
            'CIFNo': $("#srcCIFRDB_text1").val(),
            'OfficeId': $("#srcOfficeRDB_text1").val(),
            'NoRekening': $("#maskedRekeningRDB").val(),
            'dtSubs': arrSubs,
            'dtRedemp': arrRedemp,
            'dtRDB': arrRDB,
            'Inputter': $("#txtbInputterRDB").val(),
            'Seller': $("#srcSellerRDB_text1").val(),
            'Waperd': $("#srcWaperdRDB_text1").val(),
            'NoRekeningUSD': $("#maskedRekeningRDBUSD").val(),
            'NoRekeningMC': $("#maskedRekeningRDBMC").val(),
            'Referentor': $("#srcReferentorRDB_text1").val(),
            'pbDocFCSubscriptionForm': false,
            'pbDocFCDevidentAuthLetter': false,
            'pbDocFCJoinAcctStatementLetter': false,
            'pbDocFCIDCopy': false,
            'pbDocFCOthers': false,
            'pbDocTCSubscriptionForm': false,
            'pbDocTCTermCondition': false,
            'pbDocTCProspectus': false,
            'pbDocTCFundFactSheet': false,
            'pbDocTCOthers': false,
            'pcDocFCOthersList': '',
            'pcDocTCOthersList': ''
        });
        MaintainAllTransaksi(model);
    }
    else if (_strTabName == "SWCNONRDB") {
        if ($("#srcOfficeSwc_text1").val() == "") {
            swal("Warning", "Kode Kantor harus diisi", "warning");
            return;
        }

        ValidasiInputKodeKantor($("#srcOfficeSwc_text1").val(), function (strIsAllowed) {
            if (strIsAllowed == "0") {
                swal("Error", "Error [ReksaValidateOfficeId], Kode kantor tidak terdaftar", "warning");
                ResetFormSwc();
            }
        });


        //string strErrorMessage;
        //strIsAllowed = "";
        //if (clsValidator.ValidasiUserCBO(ClQ, cmpsrKodeKantorSwc.Text1, strBranch, out strIsAllowed, out strErrorMessage)) {
        //    if (strIsAllowed == "0") {
        //        MessageBox.Show("Error [ReksaValidateUserCBOOffice], " + strErrorMessage, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //        ResetFormSwc();
        //        return;
        //    }
        //}
        //else {
        //    MessageBox.Show("Error [ReksaValidateUserCBOOffice]!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}
        if ($("#srcCIFSwc_text1").val() == "") {
            swal("Warning", "CIF harus diisi", "warning");
            return;
        }

        //if (!GlobalFunctionCIF.RetrieveCIFData(intNIK, strBranch, strModule, strGuid, Int64.Parse(cmpsrCIFSubs.Text1))) {
        //    swal("Warning", "Gagal validasi CIF ke modul ProCIF", "warning");
        //    return;
        //}
        //if ((checkPhoneOrderSwc.Checked) && (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSwc.Text1))) {
        //    MessageBox.Show("Nasabah tidak memiliki fasilitas phone order!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}
        //if ($("#textShareHolderIdSwc").val() == "") {
        //    swal("Warning", "Shareholder ID harus terdaftar", "warning");
        //    return;
        //}
        if ($("#srcProductSwcOut_text1").val() == "") {
            swal("Warning", "Produk Switch Out Switching belum dipilih", "warning");
            return;
        }
        if ($("#srcProductSwcIn_text1").val() == "") {
            swal("Warning", "Produk Switch In Switching belum dipilih", "warning");
            return;
        }
        if ($("#srcClientSwcOut_text1").val() == "") {
            swal("Warning", "Client Code Switch Out Switching belum dipilih", "warning");
            return;
        }
        if (($("#srcClientSwcIn_text1").val() == "") && (IsSubsNew == false)) {
            swal("Warning", "Client Code Switch Out Switching belum dipilih", "warning");
            return;
        }
        if ($("#RedempSwc").val() == "") {
            swal("Warning", "Jumlah unit Switching harus diisi!", "warning");
            return;
        }
        if (_intType == 1) {
            if (+$("#RedempSwc").val() > +$("#OutstandingUnitSwc").val()) {
                swal("Warning", "Jumlah unit Switching tidak boleh lebih besar dari Outstanding Unit!", "warning");
                return;
            }
        }
        //if (!System.Convert.ToBoolean(objFormDocument.chkbDocFCSubscriptionForm.CheckState)) {
        //    MessageBox.Show("Formulir Subscription wajib ada", "Penerimaan Dokumen dari Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocFCIDCopy.CheckState)) {
        //    MessageBox.Show("Copy Bukti Identitas wajib ada", "Penerimaan Dokumen dari Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCSubscriptionForm.CheckState)) {
        //    MessageBox.Show("Copy Formulir Subscription wajib ada", "Dokumen yang diterima oleh Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCProspectus.CheckState)) {
        //    MessageBox.Show("Prospektus wajib ada", "Dokumen yang diterima oleh Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCFundFactSheet.CheckState)) {
        //    MessageBox.Show("Fund Fact Sheet wajib ada", "Dokumen yang diterima oleh Nasabah");
        //    return;
        //}
        if ($("#srcSellerSwc_text1").val() == "") {
            swal("Warning", "NIK Seller harus diisi", "warning");
            return;
        }
        if ($("#srcWaperdSwc_text1").val() == "") {
            swal("Warning", "NIK Seller tidak terdaftar sbg WAPERD", "warning");
            return;
        }

        ////cek risk profile
        //string RiskProfile;
        //TimeSpan diff;
        //DateTime LastUpdateRiskProfile;
        //DateTime ExpRiskProfile;
        //CekRiskProfile(cmpsrCIFSwc.Text1, dateTglTransaksiSwc.Value, out RiskProfile, out LastUpdateRiskProfile,
        //    out ExpRiskProfile,
        //    out diff);

        //var res = CekRiskProfile($("#srcCIFSwc_text1").val());
        //res.success(function (data) {
        //    if (data.blnResult) {
        //        IsSubsNew = data.IsSubsNew;
        //        ClientCodeSubsAdd = data.strClientCode;
        //    }
        //    else {
        //    }
        //});

        //if (RiskProfile.Trim() == "") {
        //    MessageBox.Show("CIF : " + cmpsrCIFSwc.Text1 + "\nData risk profile harus dilengkapi di Pro CIF", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}

        //if (ExpRiskProfile < System.DateTime.Today)
        //{
        //if (MessageBox.Show("CIF : " + cmpsrCIFSwc.Text1 +
        //    "\nTanggal Last Update Risk Profile : " + LastUpdateRiskProfile.ToString("dd-MMM-yyyy") +
        //    "\nTanggal Last Update risk profile sudah expired" +
        //    "\nApakah Risk Profile Nasabah berubah? ", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
        //{
        //    MessageBox.Show("Lakukan Perubahan Risk Profile di Pro CIF-Menu Inquiry and Maintenance-Data Pribadi", "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
        //    return;
        //}
        //else
        //{
        //    OleDbParameter[] Param2 = new OleDbParameter[2];
        //        (Param2[0] = new OleDbParameter("pcCIFNo", OleDbType.VarChar, 13)).Value = cmpsrCIFSwc.Text1;
        //        (Param2[1] = new OleDbParameter("pdNewLastUpdate", OleDbType.Date)).Value = dateTglTransaksiSwc.Value;

        //        if (!ClQ.ExecProc("dbo.ReksaManualUpdateRiskProfile", ref Param2))
        //        {
        //            MessageBox.Show("Gagal simpan last update risk profile", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //            return;
        //        }
        //    }
        //}

        var intSwcType, intClientIdSwcIn;
        if (IsSwitchingAll) {
            intSwcType = 6;
        }
        else {
            intSwcType = 5;
        }
        console.log(IsSubsNew);
        if (IsSubsNew) {
            intClientIdSwcIn = 0;
        }
        else {
            intClientIdSwcIn = $("#ClientIdSwcIn").val();
        }

        var decUnitBalanceNomSwcOut, decUnitBalanceNomSwcIn;

        console.log("_NAVSwcOutNonRDB :" + _NAVSwcOutNonRDB);
        console.log("_NAVSwcInNonRDB :" + _NAVSwcInNonRDB);
        console.log("OutstandingUnitSwcIn :" + OutstandingUnitSwcIn);

        decUnitBalanceNomSwcOut = $("#OutstandingUnitSwc").val() * _NAVSwcOutNonRDB;
        decUnitBalanceNomSwcIn = OutstandingUnitSwcIn * _NAVSwcInNonRDB;

        var intReferentor;

        if ($("#srcReferentorSwc_text1").val() == '') {
            intReferentor = 0;
        }
        else {
            intReferentor = $("#srcReferentorSwc_text1").val();
        }

        var dateTglTransaksiSubs = toDate($("#dateTglTransaksiSwc").val());
        var dtNAVValueDate = dateTglTransaksiSubs.setDate(dateTglTransaksiSubs.getDate() + -1);
        dtNAVValueDate = new Date(dtNAVValueDate);
        var model = JSON.stringify({
            'intType': _intType,
            'strTranType': intSwcType,
            'strTranCode': $("#textNoTransaksiSwc").val(),
            'intTranId': 1,
            'dtTranDate': dateTglTransaksiSubs,
            'intProdIdSwcOut': $("#ProdIdSwcOut").val(),
            'intProdIdSwcIn': $("#ProdIdSwcIn").val(),
            'intClientIdSwcOut': $("#ClientIdSwcOut").val(),
            'intClientIdSwcIn': intClientIdSwcIn,
            'intFundIdSwcOut': 0,
            'intFundIdSwcIn': 0,
            'strSelectedAccNo': $("#maskedRekeningSwc").val(),
            'intAgentIdSwcOut': 0,
            'intAgentIdSwcIn': 0,
            'strTranCCY': $("#ProdCCYSwcOut").val(),
            'decTranAmt': 0,
            'decTranUnit': $("#RedempSwc").data("kendoNumericTextBox").value(),
            'decSwitchingFee': $("#MoneyFeeSwc").data("kendoNumericTextBox").value(),
            'decNAVSwcOut': _NAVSwcOutNonRDB,
            'decNAVSwcIn': _NAVSwcInNonRDB,
            'dtNAVValueDate': dtNAVValueDate,
            'decUnitBalanceSwcOut': $("#OutstandingUnitSwc").data("kendoNumericTextBox").value(),
            'decUnitBalanceNomSwcOut': decUnitBalanceNomSwcOut,
            'decUnitBalanceSwcIn': OutstandingUnitSwcIn,
            'decUnitBalanceNomSwcIn': decUnitBalanceNomSwcIn,
            'intUserSuid': 0,
            'isByUnit': true,
            'intSalesId': 0,
            'strGuid': '',
            'strInputter': $("#txtbInputterSwc").val(),
            'intSeller': $("#srcSellerSwc_text1").val(),
            'intWaperd': $("#srcWaperdSwc_text1").val(),
            'isFeeEdit': $("#checkFeeEditSwc").prop('checked'),
            'isDocFCSubscriptionForm': false,
            'isDocFCDevidentAuthLetter': false,
            'isDocFCJoinAcctStatementLetter': false,
            'isDocFCIDCopy': false,
            'isDocFCOthers': false,
            'isDocTCSubscriptionForm': false,
            'isDocTCTermCondition': false,
            'isDocTCProspectus': false,
            'isDocTCFundFactSheet': false,
            'isDocTCOthers': false,
            'strDocFCOthersList': '',
            'strDocTCOthersList': '',
            'decPercentageFee': $("#PercentageFeeSwc").data("kendoNumericTextBox").value(),
            'isByPhoneOrder': $("#checkPhoneOrderSwc").prop('checked'),
            'strCIFNo': $("#srcCIFSwc_text1").val(),
            'strOfficeId': $("#srcOfficeSwc_text1").val(),
            'strRefID': $("#srcNoRefSwc_text1").val(),
            'isNew': IsSubsNew,
            'strClientCodeSwitchInNew': $("#srcClientSwcIn_text1").val(),
            'intReferentor': intReferentor,
            'isTrxTaxAmnesty': false
        });
        console.log(model);
        MaintainSwitching(model);
    }
    else if (_strTabName == "SWCRDB") {
        if ($("#srcOfficeSwcRDB_text1").val() == "") {
            swal("Warning", "Kode Kantor harus diisi", "warning");
            return;
        }

        ValidasiInputKodeKantor($("#srcOfficeSwcRDB_text1").val(), function (strIsAllowed) {
            if (strIsAllowed == "0") {
                swal("Error", "Error [ReksaValidateOfficeId], Kode kantor tidak terdaftar", "warning");
                ResetFormSwcRDB();
            }
        });

        //string strErrorMessage;
        //strIsAllowed = "";
        //if (clsValidator.ValidasiUserCBO(ClQ, cmpsrKodeKantorSwcRDB.Text1, strBranch, out strIsAllowed, out strErrorMessage)) {
        //    if (strIsAllowed == "0") {
        //        MessageBox.Show("Error [ReksaValidateUserCBOOffice], " + strErrorMessage, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //        ResetFormSwcRDB();
        //        return;
        //    }
        //}
        //else {
        //    MessageBox.Show("Error [ReksaValidateUserCBOOffice]!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}
        if ($("#srcCIFSwcRDB_text1").val() == "") {
            swal("Warning", "CIF harus diisi", "warning");
            return;
        }

        //if (!GlobalFunctionCIF.RetrieveCIFData(intNIK, strBranch, strModule, strGuid, Int64.Parse(cmpsrCIFSubs.Text1))) {
        //    swal("Warning", "Gagal validasi CIF ke modul ProCIF", "warning");
        //    return;
        //}
        //if ((checkPhoneOrderSwcRDB.Checked) && (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSwcRDB.Text1))) {
        //    MessageBox.Show("Nasabah tidak memiliki fasilitas phone order!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}
        //if ($("#textShareHolderIdSwcRDB").val() == "") {
        //    swal("Warning", "Shareholder ID harus terdaftar", "warning");
        //    return;
        //}
        if ($("#srcProductSwcRDBOut_text1").val() == "") {
            swal("Warning", "Produk Switch Out Switching RDB belum dipilih", "warning");
            return;
        }
        if ($("#srcProductSwcRDBIn_text1").val() == "") {
            swal("Warning", "Produk Switch In Switching RDB belum dipilih", "warning");
            return;
        }
        if ($("#srcClientSwcRDBOut_text1").val() == "") {
            swal("Warning", "Client Code Switch Out Switching RDB belum dipilih", "warning");
            return;
        }
        if (($("#srcClientSwcRDBIn_text1").val() == "") && (IsSubsNew == false)) {
            swal("Warning", "Client Code Switch Out Switching RDB belum dipilih", "warning");
            return;
        }
        if ($("#RedempSwcRDB").val() == "") {
            swal("Warning", "Jumlah unit Switching RDB harus diisi!", "warning");
            return;
        }
        if (_intType == 1) {
            if (+$("#RedempSwcRDB").val() > +$("#OutstandingUnitSwcRDB").val()) {
                swal("Warning", "Jumlah unit Switching RDB tidak boleh lebih besar dari Outstanding Unit!", "warning");
                return;
            }
        }
        if ($("#JangkaWktSwcRDB").data("kendoNumericTextBox").value() > 0) {
            if ($("#cmbFrekPendebetanSwcRDB").data("kendoDropDownList").text() == "") {
                swal("Warning", "Data Frekuensi pendebetan tidak boleh kosong", "warning");
                return;
            }
            if ($("#cmbAutoRedempSwcRDB").data("kendoDropDownList").text() == "") {
                swal("Warning", "Auto Redemption tidak boleh kosong", "warning");
                return;
            }
            if ($("#cmbAsuransiSwcRDB").data("kendoDropDownList").text() == "") {
                swal("Warning", "Asuransi tidak boleh kosong", "warning");
                return;
            }
        }
        //if (!System.Convert.ToBoolean(objFormDocument.chkbDocFCSubscriptionForm.CheckState)) {
        //    MessageBox.Show("Formulir Subscription wajib ada", "Penerimaan Dokumen dari Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocFCIDCopy.CheckState)) {
        //    MessageBox.Show("Copy Bukti Identitas wajib ada", "Penerimaan Dokumen dari Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCSubscriptionForm.CheckState)) {
        //    MessageBox.Show("Copy Formulir Subscription wajib ada", "Dokumen yang diterima oleh Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCProspectus.CheckState)) {
        //    MessageBox.Show("Prospektus wajib ada", "Dokumen yang diterima oleh Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCFundFactSheet.CheckState)) {
        //    MessageBox.Show("Fund Fact Sheet wajib ada", "Dokumen yang diterima oleh Nasabah");
        //    return;
        //}
        if ($("#srcSellerSwcRDB_text1").val() == "") {
            swal("Warning", "NIK Seller harus diisi", "warning");
            return;
        }
        if ($("#srcWaperdSwcRDB_text1").val() == "") {
            swal("Warning", "NIK Seller tidak terdaftar sbg WAPERD", "warning");
            return;
        }

        ////cek risk profile
        //string RiskProfile;
        //TimeSpan diff;
        //DateTime LastUpdateRiskProfile;
        //DateTime ExpRiskProfile;
        //CekRiskProfile(cmpsrCIFSwcRDB.Text1, dateTglTransaksiSwcRDB.Value, out RiskProfile, out LastUpdateRiskProfile,
        //    out ExpRiskProfile,
        //    out diff);

        //var res = CekRiskProfile($("#srcCIFSwcRDB_text1").val());
        //res.success(function (data) {
        //    if (data.blnResult) {
        //        IsSubsNew = data.IsSubsNew;
        //        ClientCodeSubsAdd = data.strClientCode;
        //    }
        //    else {
        //    }
        //});

        //if (RiskProfile.Trim() == "") {
        //    MessageBox.Show("CIF : " + cmpsrCIFSwcRDB.Text1 + "\nData risk profile harus dilengkapi di Pro CIF", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}

        //if (ExpRiskProfile < System.DateTime.Today)
        //{
        //if (MessageBox.Show("CIF : " + cmpsrCIFSwcRDB.Text1 +
        //    "\nTanggal Last Update Risk Profile : " + LastUpdateRiskProfile.ToString("dd-MMM-yyyy") +
        //    "\nTanggal Last Update risk profile sudah expired" +
        //    "\nApakah Risk Profile Nasabah berubah? ", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
        //{
        //    MessageBox.Show("Lakukan Perubahan Risk Profile di Pro CIF-Menu Inquiry and Maintenance-Data Pribadi", "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
        //    return;
        //}
        //else
        //{
        //    OleDbParameter[] Param2 = new OleDbParameter[2];
        //        (Param2[0] = new OleDbParameter("pcCIFNo", OleDbType.VarChar, 13)).Value = cmpsrCIFSwcRDB.Text1;
        //        (Param2[1] = new OleDbParameter("pdNewLastUpdate", OleDbType.Date)).Value = dateTglTransaksiSwcRDB.Value;

        //        if (!ClQ.ExecProc("dbo.ReksaManualUpdateRiskProfile", ref Param2))
        //        {
        //            MessageBox.Show("Gagal simpan last update risk profile", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //            return;
        //        }
        //    }
        //}

        var intSwcType, intClientIdSwcIn, intAutoRedemp, intAsuransi;
        intSwcType = 9;

        if (IsSubsNew) {
            intClientIdSwcIn = 0;
        }
        else {
            intClientIdSwcIn = $("#ClientIdSwcRDBIn").val();
        }
        if ($("#cmbAutoRedempSwcRDB").data("kendoDropDownList").text() == "Ya") {
            intAutoRedemp = 1;
        }
        else {
            intAutoRedemp = 0;
        }
        if ($("#cmbAsuransiSwcRDB").data("kendoDropDownList").text() == "Ya") {
            intAsuransi = 1;
        }
        else {
            intAsuransi = 0;
        }

        var intReferentor;

        if ($("#srcReferentorSwc_text1").val() == '') {
            intReferentor = 0;
        }
        else {
            intReferentor = $("#srcReferentorSwc_text1").val();
        }

        //convert date to int yyyymmdd

        var [day, month, year] = $("#dtJatuhTempoSwcRDB").val().split("/")
        var intJatuhTempo = year + month + day;

        var dateTglTransaksiSwcRDB = toDate($("#dateTglTransaksiSwcRDB").val());
        var model = JSON.stringify({
            'intType': _intType,
            'strTranType': intSwcType,
            'strTranCode': $("#textNoTransaksiSwcRDB").val(),
            'intTranId': 1,
            'dtTranDate': dateTglTransaksiSwcRDB,
            'intProdIdSwcOut': $("#ProdIdSwcRDBOut").val(),
            'intProdIdSwcIn': $("#ProdIdSwcRDBIn").val(),
            'intClientIdSwcOut': $("#ClientIdSwcRDBOut").val(),
            'intClientIdSwcIn': intClientIdSwcIn,
            'strSelectedAccNo': $("#maskedRekeningSwcRDB").val(),
            'decTranUnit': $("#RedempSwcRDB").data("kendoNumericTextBox").value(),
            'decSwitchingFee': $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").value(),
            'decUnitBalanceSwcOut': $("#OutstandingUnitSwcRDB").data("kendoNumericTextBox").value(),

            'intJangkaWaktu': $("#JangkaWktSwcRDB").data("kendoNumericTextBox").value(),
            'intJatuhTempo': intJatuhTempo,
            'intFrekPendebetan': $("#cmbFrekPendebetanSwcRDB").data("kendoDropDownList").text(),
            'intAutoRedemption': intAutoRedemp,
            'intAsuransi': intAsuransi,

            'intUserSuid': 0,
            'intReferentor': intReferentor,
            'isByUnit': true,
            'strGuid': '',
            'strCIFNo': $("#srcCIFSwcRDB_text1").val(),
            'strOfficeId': $("#srcOfficeSwcRDB_text1").val(),
            'strRefID': $("#srcNoRefSwcRDB_text1").val(),
            'isNew': IsSubsNew,
            'strClientCodeSwitchInNew': $("#srcClientSwcRDBIn_text1").val(),
            'strInputter': $("#txtbInputterSwcRDB").val(),
            'intSeller': $("#srcSellerSwcRDB_text1").val(),
            'intWaperd': $("#srcWaperdSwcRDB_text1").val(),
            'isFeeEdit': $("#checkFeeEditSwcRDB").prop('checked'),
            'decPercentageFee': $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").value(),
            'isByPhoneOrder': $("#checkPhoneOrderSwcRDB").prop('checked'),
            'isDocFCSubscriptionForm': false,
            'isDocFCDevidentAuthLetter': false,
            'isDocFCJoinAcctStatementLetter': false,
            'isDocFCIDCopy': false,
            'isDocFCOthers': false,
            'isDocTCSubscriptionForm': false,
            'isDocTCTermCondition': false,
            'isDocTCProspectus': false,
            'isDocTCFundFactSheet': false,
            'isDocTCOthers': false,
            'strDocFCOthersList': '',
            'strDocTCOthersList': '',
            'isTrxTaxAmnesty': false
        });
        console.log(model);
        MaintainSwitchingRDB(model);
    }
    else if (_strTabName == "BOOK") {
        if ($("#srcOfficeBooking_text1").val() == "") {
            swal("Warning", "Kode Kantor harus diisi", "warning");
            return;
        }

        ValidasiInputKodeKantor($("#srcOfficeBooking_text1").val(), function (strIsAllowed) {
            if (strIsAllowed == "0") {
                swal("Error", "Error [ReksaValidateOfficeId], Kode kantor tidak terdaftar", "warning");
                ResetFormSwcRDB();
            }
        });

        //string strErrorMessage;
        //strIsAllowed = "";
        //if (clsValidator.ValidasiUserCBO(ClQ, cmpsrKodeKantorSwcRDB.Text1, strBranch, out strIsAllowed, out strErrorMessage)) {
        //    if (strIsAllowed == "0") {
        //        MessageBox.Show("Error [ReksaValidateUserCBOOffice], " + strErrorMessage, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //        ResetFormSwcRDB();
        //        return;
        //    }
        //}
        //else {
        //    MessageBox.Show("Error [ReksaValidateUserCBOOffice]!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}
        if ($("#srcCIFBooking_text1").val() == "") {
            swal("Warning", "CIF harus diisi", "warning");
            return;
        }

        //if (!GlobalFunctionCIF.RetrieveCIFData(intNIK, strBranch, strModule, strGuid, Int64.Parse(cmpsrCIFSubs.Text1))) {
        //    swal("Warning", "Gagal validasi CIF ke modul ProCIF", "warning");
        //    return;
        //}
        //if ((checkPhoneOrderSwcRDB.Checked) && (!GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSwcRDB.Text1))) {
        //    MessageBox.Show("Nasabah tidak memiliki fasilitas phone order!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}
        //if ($("#textShareHolderIdBooking").val() == "") {
        //    swal("Warning", "Shareholder ID harus terdaftar", "warning");
        //    return;
        //}
        if ($("#srcSellerBooking_text1").val() == "") {
            swal("Warning", "NIK Seller harus diisi", "warning");
            return;
        }
        if ($("#srcWaperdBooking_text1").val() == "") {
            swal("Warning", "NIK Seller tidak terdaftar sbg WAPERD", "warning");
            return;
        }

        if ($("#srcProductBooking_text1").val() == "") {
            swal("Warning", "Produk Booking belum dipilih", "warning");
            return;
        }
        if ($("#MoneyNomBooking").data("kendoNumericTextBox").value() == 0) {
            swal("Warning", "Nominal Booking tidak boleh kosong", "warning");
            return;
        }
        //if (!System.Convert.ToBoolean(objFormDocument.chkbDocFCSubscriptionForm.CheckState)) {
        //    MessageBox.Show("Formulir Subscription wajib ada", "Penerimaan Dokumen dari Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocFCIDCopy.CheckState)) {
        //    MessageBox.Show("Copy Bukti Identitas wajib ada", "Penerimaan Dokumen dari Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCSubscriptionForm.CheckState)) {
        //    MessageBox.Show("Copy Formulir Subscription wajib ada", "Dokumen yang diterima oleh Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCProspectus.CheckState)) {
        //    MessageBox.Show("Prospektus wajib ada", "Dokumen yang diterima oleh Nasabah");
        //    return;
        //}
        //else if (!System.Convert.ToBoolean(objFormDocument.chkbDocTCFundFactSheet.CheckState)) {
        //    MessageBox.Show("Fund Fact Sheet wajib ada", "Dokumen yang diterima oleh Nasabah");
        //    return;
        //}
        

        ////cek risk profile
        //string RiskProfile;
        //TimeSpan diff;
        //DateTime LastUpdateRiskProfile;
        //DateTime ExpRiskProfile;
        //CekRiskProfile(cmpsrCIFSwcRDB.Text1, dateTglTransaksiSwcRDB.Value, out RiskProfile, out LastUpdateRiskProfile,
        //    out ExpRiskProfile,
        //    out diff);

        //var res = CekRiskProfile($("#srcCIFSwcRDB_text1").val());
        //res.success(function (data) {
        //    if (data.blnResult) {
        //        IsSubsNew = data.IsSubsNew;
        //        ClientCodeSubsAdd = data.strClientCode;
        //    }
        //    else {
        //    }
        //});

        //if (RiskProfile.Trim() == "") {
        //    MessageBox.Show("CIF : " + cmpsrCIFSwcRDB.Text1 + "\nData risk profile harus dilengkapi di Pro CIF", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    return;
        //}

        //if (ExpRiskProfile < System.DateTime.Today)
        //{
        //if (MessageBox.Show("CIF : " + cmpsrCIFSwcRDB.Text1 +
        //    "\nTanggal Last Update Risk Profile : " + LastUpdateRiskProfile.ToString("dd-MMM-yyyy") +
        //    "\nTanggal Last Update risk profile sudah expired" +
        //    "\nApakah Risk Profile Nasabah berubah? ", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
        //{
        //    MessageBox.Show("Lakukan Perubahan Risk Profile di Pro CIF-Menu Inquiry and Maintenance-Data Pribadi", "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
        //    return;
        //}
        //else
        //{
        //    OleDbParameter[] Param2 = new OleDbParameter[2];
        //        (Param2[0] = new OleDbParameter("pcCIFNo", OleDbType.VarChar, 13)).Value = cmpsrCIFSwcRDB.Text1;
        //        (Param2[1] = new OleDbParameter("pdNewLastUpdate", OleDbType.Date)).Value = dateTglTransaksiSwcRDB.Value;

        //        if (!ClQ.ExecProc("dbo.ReksaManualUpdateRiskProfile", ref Param2))
        //        {
        //            MessageBox.Show("Gagal simpan last update risk profile", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //            return;
        //        }
        //    }
        //}

        var moneyNominalFee, moneyPercentageFee;
        var ComboJenis = 1;
        if ($("#_ComboJenisBooking").data("kendoDropDownList").text() == "By %") {
            moneyNominalFee = $("#PercentageFeeBooking").data("kendoNumericTextBox").value();
            moneyPercentageFee = $("#MoneyFeeBooking").data("kendoNumericTextBox").value();
            ComboJenis = 1;
        }
        else {
            moneyNominalFee = $("#MoneyFeeBooking").data("kendoNumericTextBox").value();
            moneyPercentageFee = $("#PercentageFeeBooking").data("kendoNumericTextBox").value();
            ComboJenis = 0;
        }
        var intBookingId = 0;
        if (_intType == 1) {
            intBookingId = 0;
        }
        else {
            intBookingId = $("#BookingId").val();
        }
        var intReferentor;

        if ($("#srcReferentorBooking_text1").val() == '') {
            intReferentor = 0;
        }
        else {
            intReferentor = $("#srcReferentorBooking_text1").val();
        }

        var model = JSON.stringify({
            'intType': _intType,
            'intBookingId': intBookingId,
            'strCIFNo': $("#srcCIFBooking_text1").val(),
            'strCIFName': $("#srcCIFBooking_text2").val(),
            'intProdId': $("#ProdIdBooking").val(),
            'strOfficeId': $("#srcOfficeBooking_text1").val(),
            'strCurrency': $("#srcCurrencyBooking_text1").val(),
            'decNominal': $("#MoneyNomBooking").data("kendoNumericTextBox").value(),
            'strRekening': $("#maskedRekeningBooking").val(),
            'strNamaRekening': $("#textNamaRekeningBooking").val(),
            'intReferentor': intReferentor,
            'intNIK': 0,
            'strGuid': '',
            'strInputter': $("#txtbInputterBooking").val(),
            'intSeller': $("#srcSellerBooking_text1").val(),
            'intWaperd': $("#srcWaperdBooking_text1").val(),
            'isByPhoneOrder': $("#checkPhoneOrderBooking").prop('checked'),
            'isFeeEdit': $("#checkFeeEditBooking").prop('checked'),
            'intJenisPerhitunganFee': ComboJenis,
            'decPercentageFee': moneyPercentageFee,
            'decSubcFee': moneyNominalFee,
            'isDocFCSubscriptionForm': false,
            'isDocFCDevidentAuthLetter': false,
            'isDocFCJoinAcctStatementLetter': false,
            'isDocFCIDCopy': false,
            'isDocFCOthers': false,
            'isDocTCSubscriptionForm': false,
            'isDocTCTermCondition': false,
            'isDocTCProspectus': false,
            'isDocTCFundFactSheet': false,
            'isDocTCOthers': false,
            'strDocFCOthersList': '',
            'strDocTCOthersList': '',
            'isTrxTaxAmnesty': false            
        });
        console.log(model);
        MaintainNewBooking(model);

    }
}
function MaintainAllTransaksi(model) {
    $.ajax({
        type: 'POST',
        url: '/Transaksi/MaintainAllTransaksi',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        beforeSend: function () {
            $("#load_screen").show();
        }, 
        success: function (data) {
            if (data.blnResult) {
                ResetForm();
                DisableAllForm(false);
                DisableFormTrxSubs(false);
                DisableFormTrxRedemp(false);
                DisableFormTrxRDB(false);
                swal("Success", data.ErrMsg, "success");
                if (_strTabName == "SUBS") {
                    $("#srcNoRefSubs_text1").val(data.strRefID);
                    //cmpsrNoRefSubs.ValidateField();
                }
                else if (_strTabName == "REDEMP") {
                    $("#srcNoRefRedemp_text1").val(data.strRefID);
                    //cmpsrNoRefRedemp.ValidateField();
                }
                else if (_strTabName == "SUBSRDB") {
                    $("#srcNoRefRDB_text1").val(data.strRefID);
                    //cmpsrNoRefRDB.ValidateField();
                }
                subRefresh();
            }
            else {
                if (data.dtError.length > 0) {
                    swal({
                        title: "Failed",
                        text: "Data Transaksi Gagal Disimpan",
                        type: "error",
                        confirmButtonClass: 'btn-danger',
                        confirmButtonText: "OK",
                        closeOnConfirm: true
                    },
                        function (isConfirm) {
                            if (isConfirm) {
                                var dataSource = new kendo.data.DataSource(
                                    {
                                        data: data.dtError
                                    });
                                if (_strTabName == "SUBS") {
                                    var Errorgrid = $('#GridErrorSubs').data('kendoGrid');
                                    Errorgrid.setDataSource(dataSource);
                                    Errorgrid.dataSource.pageSize(10);
                                    Errorgrid.select("tr:eq(0)");
                                    $('#ErrorSubsModal').modal('toggle');
                                }
                                else if (_strTabName == "REDEMP") {
                                    var Errorgrid = $('#GridErrorRedemp').data('kendoGrid');
                                    Errorgrid.setDataSource(dataSource);
                                    Errorgrid.dataSource.pageSize(10);
                                    Errorgrid.select("tr:eq(0)");
                                    $('#ErrorRedempModal').modal('toggle');
                                }
                            }
                        });
                }
                else {
                    swal("Warning", data.ErrMsg, "warning");
                }
            }
        }
        ,
        complete: function () {
            $("#load_screen").hide();
        }
    });
}
function MaintainSwitching(model) {
    $.ajax({
        type: 'POST',
        url: '/Transaksi/MaintainSwitching',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                ResetForm();
                DisableAllForm(false);
                swal("Success", data.ErrMsg, "success");
                $("#srcNoRefSwc_text1").val(data.strRefID);
                subRefresh();
            }
            else {
                if (data.dtError.length > 0) {
                    swal({
                        title: "Failed",
                        text: "Data Transaksi Gagal Disimpan",
                        type: "error",
                        confirmButtonClass: 'btn-danger',
                        confirmButtonText: "OK",
                        closeOnConfirm: true
                    },
                        function (isConfirm) {
                            if (isConfirm) {
                                var dataSource = new kendo.data.DataSource(
                                    {
                                        data: data.dtError
                                    });
                                var Errorgrid = $('#GridErrorSwc').data('kendoGrid');
                                Errorgrid.setDataSource(dataSource);
                                Errorgrid.dataSource.pageSize(10);
                                Errorgrid.select("tr:eq(0)");
                                $('#ErrorSwcModal').modal('toggle');
                            }
                        });
                }
                else {
                    swal("Warning", data.ErrMsg, "warning");
                }
            }
        }
        ,
        complete: function () {
            $("#load_screen").hide();
        }
    });
}
function MaintainSwitchingRDB(model) {
    $.ajax({
        type: 'POST',
        url: '/Transaksi/MaintainSwitchingRDB',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                ResetForm();
                DisableAllForm(false);
                swal("Success", data.ErrMsg, "success");
                $("#srcNoRefSwcRDB_text1").val(data.strRefID);
                subRefresh();
            }
            else {
                if (data.dtError.length > 0) {
                    swal({
                        title: "Failed",
                        text: "Data Transaksi Gagal Disimpan",
                        type: "error",
                        confirmButtonClass: 'btn-danger',
                        confirmButtonText: "OK",
                        closeOnConfirm: true
                    },
                        function (isConfirm) {
                            if (isConfirm) {
                                var dataSource = new kendo.data.DataSource(
                                    {
                                        data: data.dtError
                                    });
                                var Errorgrid = $('#GridErrorSwcRDB').data('kendoGrid');
                                Errorgrid.setDataSource(dataSource);
                                Errorgrid.dataSource.pageSize(10);
                                Errorgrid.select("tr:eq(0)");
                                $('#ErrorSwcRDBModal').modal('toggle');
                            }
                        });
                }
                else {
                    swal("Warning", data.ErrMsg, "warning");
                }
            }
        }
        ,
        complete: function () {
            $("#load_screen").hide();
        }
    });
}
function MaintainNewBooking(model) {
    $.ajax({
        type: 'POST',
        url: '/Transaksi/MaintainNewBooking',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                ResetForm();
                DisableAllForm(false);
                swal("Success", data.ErrMsg, "success");
                $("#srcNoRefBooking_text1").val(data.strRefID);
                subRefresh();
            }
            else {
                if (data.dtError.length > 0) {
                    swal({
                        title: "Failed",
                        text: "Data Transaksi Gagal Disimpan",
                        type: "error",
                        confirmButtonClass: 'btn-danger',
                        confirmButtonText: "OK",
                        closeOnConfirm: true
                    },
                        function (isConfirm) {
                            if (isConfirm) {
                                var dataSource = new kendo.data.DataSource(
                                    {
                                        data: data.dtError
                                    });
                                var Errorgrid = $('#GridErrorBooking').data('kendoGrid');
                                Errorgrid.setDataSource(dataSource);
                                Errorgrid.dataSource.pageSize(10);
                                Errorgrid.select("tr:eq(0)");
                                $('#ErrorBookingModal').modal('toggle');
                            }
                        });
                }
                else {
                    swal("Warning", data.ErrMsg, "warning");
                }
            }
        }
        ,
        complete: function () {
            $("#load_screen").hide();
        }
    });
}
function subCancel() {
    _intType = 0;
    ResetForm();
    //cTransaksi.ClearData();
    DisableAllForm(false);
    DisableFormTrxSubs(false);
    DisableFormTrxRedemp(false);
    DisableFormTrxRDB(false);
    subResetToolBar();
    ResetAllKodeKantor();
}
function GetKodeKantor() {
    ValidasiKodeKantor(strBranch, function (output) {
        if (output) {
            $("#srcOfficeSubs_text1").val(strBranch);
            $("#srcOfficeRedemp_text1").val(strBranch);
            $("#srcOfficeRDB_text1").val(strBranch);
            $("#srcOfficeSwc_text1").val(strBranch);
            $("#srcOfficeSwcRDB_text1").val(strBranch);
            $("#srcOfficeBooking_text1").val(strBranch);

            ValidateOffice(strBranch, function (res) {
                $("#srcOfficeSubs_text2").val(res);
                $("#srcOfficeRedemp_text2").val(res);
                $("#srcOfficeRDB_text2").val(res);
                $("#srcOfficeSwc_text2").val(res);
                $("#srcOfficeSwcRDB_text2").val(res);
                $("#srcOfficeBooking_text2").val(res);
            });
        } else
            subCancel();
    });
}
function DisableAllForm(isEnabled) {
    DisableFormSubs(isEnabled);
    DisableFormRedemp(isEnabled);
    DisableFormRDB(isEnabled);
    DisableFormSwc(isEnabled);
    DisableFormSwcRDB(isEnabled);
    DisableFormBooking(isEnabled);
    //objFormDocument.SetReadOnly(!isEnabled);
}
function DisableFormSubs(isEnabled) {
    $("#srcOfficeSubs_text1").prop('disabled', true);
    $("#srcOfficeSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#srcWaperdSubs_text1").prop('disabled', true);
    $("#srcWaperdSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#srcNoRefSubs_text1").prop('disabled', isEnabled);
    $("#srcCIFSubs_text1").prop('disabled', isEnabled);
    $("#srcSellerSubs_text1").prop('disabled', isEnabled);
    $("#srcReferentorSubs_text1").prop('disabled', isEnabled);

    if (!isEnabled) {
        $("#srcNoRefSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcCIFSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcSellerSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcReferentorSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }
    else {
        $("#srcNoRefSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcCIFSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcSellerSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcReferentorSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    }
    document.getElementById("btnDocumentSubs").disabled = !isEnabled;

    $("#textSIDSubs").prop('disabled', true);
    $("#txtUmurSubs").prop('disabled', true);
    $("#textShareHolderIdSubs").prop('disabled', true);
    $("#textNamaRekeningSubs").prop('disabled', true);
    $("#maskedRekeningSubs").prop('disabled', true);
    $("#maskedRekeningSubsUSD").prop('disabled', true);
    $("#maskedRekeningSubsMC").prop('disabled', true);
    $("#txtbInputterSubs").prop('disabled', true);
    $("#textExpireWaperdSubs").prop('disabled', true);
}
function DisableFormTrxSubs(isEnabled) {
    $("#textNoTransaksiSubs").prop('disabled', true);
    $("#dateTglTransaksiSubs").prop('disabled', true);

    $("#srcCurrencySubs_text1").prop('disabled', true);
    $("#srcCurrenySubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#srcProductSubs_text1").prop('disabled', !isEnabled);
    $("#srcClientSubs_text1").prop('disabled', !isEnabled);
    if (isEnabled) {
        $("#srcProductSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcClientSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    } else {
        $("#srcProductSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcClientSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }

    //$("#MoneyNomSubs").prop('disabled', !isEnabled);
    $("#MoneyNomSubs").data("kendoNumericTextBox").enable(isEnabled);
    $("#checkPhoneOrderSubs").prop('disabled', true);

    if ((isEnabled == true) && ($("#srcCIFSubs_text1").val() != "")) {
        //if (GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFSubs.Text1)) {
        //    checkPhoneOrderBooking.Enabled = true;
        //}
    }
    $("#checkFullAmtSubs").prop('disabled', !isEnabled);
    $("#checkFeeEditSubs").prop('disabled', !isEnabled);

    document.getElementById("btnAddSubs").disabled = !isEnabled;
    document.getElementById("btnEditSubs").disabled = !isEnabled;
    $("#_ComboJenisSubs").data('kendoDropDownList').enable(false);
    $("#MoneyFeeSubs").data("kendoNumericTextBox").enable(false);
    //$("#PercentageFeeSubs").prop('disabled', true);
    $("#PercentageFeeSubs").data("kendoNumericTextBox").enable(false);
}
function DisableFormRedemp(isEnabled) {
    $("#srcOfficeRedemp_text1").prop('disabled', true);
    $("#srcOfficeRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#srcWaperdRedemp_text1").prop('disabled', true);
    $("#srcWaperdRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#srcNoRefRedemp_text1").prop('disabled', isEnabled);
    $("#srcCIFRedemp_text1").prop('disabled', isEnabled);
    $("#srcSellerRedemp_text1").prop('disabled', isEnabled);
    $("#srcReferentorRedemp_text1").prop('disabled', isEnabled);
    if (!isEnabled) {
        $("#srcNoRefRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcCIFRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcSellerRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcReferentorRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }
    else {
        $("#srcNoRefRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcCIFRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcSellerRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

        $("#srcReferentorRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    }
    document.getElementById("btnDokumenRedemp").disabled = !isEnabled;

    $("#textSIDRedemp").prop('disabled', true);
    $("#txtUmurRedemp").prop('disabled', true);
    $("#textShareHolderIdRedemp").prop('disabled', true);
    $("#textRekeningRedemp").prop('disabled', true);
    $("#maskedRekeningRedemp").prop('disabled', true);
    $("#maskedRekeningRedempUSD").prop('disabled', true);
    $("#maskedRekeningRedempMC").prop('disabled', true);
    $("#txtbInputterRedemp").prop('disabled', true);
    $("#textExpireWaperdRedemp").prop('disabled', true);
}
function DisableFormTrxRedemp(isEnabled) {
    $("#textNoTransaksiRedemp").prop('disabled', true);
    $("#dateTglTransaksiRedemp").prop('disabled', true);

    $("#CurrCodeRedemp").prop('disabled', true);
    $("#srcCurrenyRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#srcProductRedemp_text1").prop('disabled', !isEnabled);
    $("#srcClientRedemp_text1").prop('disabled', !isEnabled);
    if (isEnabled) {
        $("#srcProductRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcClientRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    } else {
        $("#srcProductRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcClientRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }
    $("#OutstandingUnitRedemp").data("kendoNumericTextBox").enable(false);
    $("#RedempUnit").data("kendoNumericTextBox").enable(isEnabled);
    $("#checkPhoneOrderRedemp").prop('disabled', true);

    if ((isEnabled == true) && ($("#srcCIFRedemp_text1").val() != "")) {
        //if (GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFRedemp.Text1)) {
        //    checkPhoneOrderBooking.Enabled = true;
        //}
    }
    $("#checkAll").prop('disabled', !isEnabled);
    $("#checkFeeEditRedemp").prop('disabled', !isEnabled);

    document.getElementById("btnAddRedemp").disabled = !isEnabled;
    document.getElementById("btnEditRedemp").disabled = !isEnabled;
    $("#_ComboJenisRedemp").data('kendoDropDownList').enable(false);
    //$("#MoneyFeeRedemp").prop('disabled', true);
    //$("#PercentageFeeRedemp").prop('disabled', true);
    $("#MoneyFeeRedemp").data("kendoNumericTextBox").enable(false);
    $("#PercentageFeeRedemp").data("kendoNumericTextBox").enable(false);
}
function DisableFormRDB(isEnabled) {
    $("#srcOfficeRDB_text1").prop('disabled', true);
    $("#srcOfficeRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#srcWaperdRDB_text1").prop('disabled', true);
    $("#srcWaperdRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#srcNoRefRDB_text1").prop('disabled', isEnabled);
    $("#srcCIFRDB_text1").prop('disabled', isEnabled);
    $("#srcSellerRDB_text1").prop('disabled', isEnabled);
    $("#srcReferentorRDB_text1").prop('disabled', isEnabled);
    if (!isEnabled) {
        $("#srcNoRefRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcCIFRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcSellerRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcReferentorRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }
    else {
        $("#srcNoRefRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcCIFRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcSellerRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

        $("#srcReferentorRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    }
    document.getElementById("btnDokumenRDB").disabled = !isEnabled;

    $("#textSIDRDB").prop('disabled', true);
    $("#txtUmurRDB").prop('disabled', true);
    $("#textShareHolderIdRDB").prop('disabled', true);
    $("#textRekeningRDB").prop('disabled', true);
    $("#maskedRekeningRDB").prop('disabled', true);
    $("#maskedRekeningRDBUSD").prop('disabled', true);
    $("#maskedRekeningRDBMC").prop('disabled', true);
    $("#txtbInputterRDB").prop('disabled', true);
    $("#textExpireWaperdRDB").prop('disabled', true);
}
function DisableFormTrxRDB(isEnabled) {
    $("#textNoTransaksiRDB").prop('disabled', true);
    $("#dateTglTransaksiRDB").prop('disabled', true);

    $("#srcCurrencyRDB_text1").prop('disabled', true);
    $("#srcCurrenyRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#srcProductRDB_text1").prop('disabled', !isEnabled);
    $("#srcClientRDB_text1").prop('disabled', !isEnabled);
    if (isEnabled) {
        $("#srcProductRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcClientRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    } else {
        $("#srcProductRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcClientRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }
    //$("#MoneyNomRDB").prop('disabled', !isEnabled);
    $("#MoneyNomRDB").data("kendoNumericTextBox").enable(isEnabled);
    $("#checkPhoneOrderRDB").prop('disabled', true);

    if ((isEnabled == true) && ($("#srcCIFRDB_text1").val() != "")) {
        //if (GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIFRDB.Text1)) {
        //    checkPhoneOrderBooking.Enabled = true;
        //}
    }
    $("#cmbAutoRedempRDB").data('kendoDropDownList').enable(isEnabled);
    $("#cmbAsuransiRDB").data('kendoDropDownList').enable(isEnabled);

    document.getElementById("btnAddRDB").disabled = !isEnabled;
    document.getElementById("btnEditRDB").disabled = !isEnabled;

    //$("#JangkaWktRDB").prop('disabled', !isEnabled);
    $("#JangkaWktRDB").data("kendoNumericTextBox").enable(isEnabled);
    $("#dtJatuhTempoRDB").prop('disabled', true);
    $("#cmbFrekPendebetanRDB").data('kendoDropDownList').enable(isEnabled);

    $("#checkFeeEditRDB").prop('disabled', true);
    $("#_ComboJenisRDB").data('kendoDropDownList').enable(false);
    //$("#MoneyFeeRDB").prop('disabled', true);
    //$("#PercentageFeeRDB").prop('disabled', true);
    $("#MoneyFeeRDB").data("kendoNumericTextBox").enable(false);
    $("#PercentageFeeRDB").data("kendoNumericTextBox").enable(false);
}
function DisableFormSwc(isEnabled) {
    $("#srcOfficeSwc_text1").prop('disabled', true);
    $("#srcOfficeSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#srcWaperdSwc_text1").prop('disabled', true);
    $("#srcWaperdSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#srcNoRefSwc_text1").prop('disabled', isEnabled);
    $("#srcCIFSwc_text1").prop('disabled', isEnabled);
    $("#srcSellerSwc_text1").prop('disabled', isEnabled);
    $("#srcReferentorSwc_text1").prop('disabled', isEnabled);
    if (!isEnabled) {
        $("#srcNoRefSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcCIFSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcSellerSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcReferentorSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }
    else {
        $("#srcNoRefSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcCIFSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcSellerSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

        $("#srcReferentorSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    }

    $("#checkSwcAll").prop('disabled', !isEnabled);
    $("#checkPhoneOrderSwc").prop('disabled', !isEnabled);
    $("#checkFeeEditSwc").prop('disabled', !isEnabled);
    //$("#RedempSwc").prop('disabled', !isEnabled);
    $("#RedempSwc").data("kendoNumericTextBox").enable(isEnabled);
    //$("#PercentageFeeSwc").prop('disabled', true);
    $("#PercentageFeeSwc").data("kendoNumericTextBox").enable(false);

    if (_intType == 2) {
        $("#srcNoRefSwc_text1").prop('disabled', true);
        $("#srcNoRefSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcCIFSwc_text1").prop('disabled', true);
        $("#srcCIFSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#checkPhoneOrderSwc").prop('disabled', false);
        $("#checkFeeEditSwc").prop('disabled', false);
        //$("#RedempSwc").prop('disabled', true);
        $("#RedempSwc").data("kendoNumericTextBox").enable(false);
        $("#checkSwcAll").prop('disabled', true);
        if ($('#checkFeeEditSwc').prop('checked') == true) {
            //$("#PercentageFeeSwc").prop('disabled', false);
            $("#PercentageFeeSwc").data("kendoNumericTextBox").enable(true);
        }
        else {
            //$("#PercentageFeeSwc").prop('disabled', true);
            $("#PercentageFeeSwc").data("kendoNumericTextBox").enable(false);
        }
    }

    $("#maskedRekeningSwc").prop('disabled', true);
    $("#maskedRekeningSwcUSD").prop('disabled', true);
    $("#maskedRekeningSwcMC").prop('disabled', true);
    document.getElementById("btnDokumenSwc").disabled = !isEnabled;

    $("#textSIDSwc").prop('disabled', true);
    $("#txtUmurSwc").prop('disabled', true);
    $("#textShareHolderIdSwc").prop('disabled', true);
    $("#textRekeningSwc").prop('disabled', true);

    $("#textNoTransaksiSwc").prop('disabled', !isEnabled);
    $("#dateTglTransaksiSwc").prop('disabled', true);

    $("#srcProductSwcOut_text1").prop('disabled', !isEnabled);
    $("#srcClientSwcOut_text1").prop('disabled', !isEnabled);
    $("#srcProductSwcIn_text1").prop('disabled', !isEnabled);
    if (isEnabled) {
        $("#srcProductSwcOut").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcClientSwcOut").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcProductSwcIn").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    }
    else {
        $("#srcProductSwcOut").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcClientSwcOut").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcProductSwcIn").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }
    $("#srcClientSwcIn_text1").prop('disabled', true);
    $("#srcClientSwcIn").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    //$("#MoneyFeeSwc").prop('disabled', true);
    $("#MoneyFeeSwc").data("kendoNumericTextBox").enable(false);
    $("#txtbInputterSwc").prop('disabled', true);
    $("#textExpireWaperdSwc").prop('disabled', true);
}
function DisableFormSwcRDB(isEnabled) {
    $("#srcOfficeSwcRDB_text1").prop('disabled', true);
    $("#srcOfficeSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#srcWaperdSwcRDB_text1").prop('disabled', true);
    $("#srcWaperdSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#RefIDSwcRDB").prop('disabled', isEnabled);
    $("#srcCIFSwcRDB_text1").prop('disabled', isEnabled);
    $("#srcSellerSwcRDB_text1").prop('disabled', isEnabled);
    $("#srcReferentorSwcRDB_text1").prop('disabled', isEnabled);
    if (!isEnabled) {
        $("#srcNoRefSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcCIFSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcSellerSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcReferentorSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }
    else {
        $("#srcNoRefSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcCIFSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcSellerSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

        $("#srcReferentorSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    }

    $("#checkPhoneOrderSwcRDB").prop('disabled', !isEnabled);
    $("#checkcheckFeeEditSwcRDB").prop('disabled', !isEnabled);
    //$("#RedempSwcRDB").prop('disabled', !isEnabled);
    $("#RedempSwcRDB").data("kendoNumericTextBox").enable(isEnabled);

    if (_intType == 2) {
        $("#RefIDSwcRDB").prop('disabled', true);
        $("#srcNoRefSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcCIFSwcRDB_text1").prop('disabled', true);
        $("#srcCIFSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#checkPhoneOrderSwcRDB").prop('disabled', false);
        $("#checkcheckFeeEditSwcRDB").prop('disabled', false);
        //$("#RedempSwcRDB").prop('disabled', true);
        $("#RedempSwcRDB").data("kendoNumericTextBox").enable(false);
    }

    $("#maskedRekeningSwcRDB").prop('disabled', true);
    $("#maskedRekeningSwcRDBUSD").prop('disabled', true);
    $("#maskedRekeningSwcRDBMC").prop('disabled', true);
    document.getElementById("btnDokumenSwcRDB").disabled = !isEnabled;

    $("#textSIDSwcRDB").prop('disabled', true);
    $("#txtUmurSwcRDB").prop('disabled', true);
    $("#textShareHolderIdSwcRDB").prop('disabled', true);
    $("#textRekeningSwcRDB").prop('disabled', true);

    $("#textNoTransaksiSwcRDB").prop('disabled', !isEnabled);
    $("#dateTglTransaksiSwcRDB").prop('disabled', true);

    $("#srcProductSwcRDBOut_text1").prop('disabled', !isEnabled);
    $("#srcClientSwcRDBOut_text1").prop('disabled', !isEnabled);
    $("#srcProductSwcRDBIn_text1").prop('disabled', !isEnabled);
    if (isEnabled) {
        $("#srcProductSwcRDBOut").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcClientSwcRDBOut").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcProductSwcRDBIn").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    }
    else {
        $("#srcProductSwcRDBOut").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcClientSwcRDBOut").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcProductSwcRDBIn").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }
    $("#srcClientSwcRDBIn_text1").prop('disabled', true);
    $("#srcClientSwcRDBIn").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    //$("#OutstandingUnitSwcRDB").prop('disabled', true);
    $("#OutstandingUnitSwcRDB").data("kendoNumericTextBox").enable(false);
    //$("#JangkaWktSwcRDB").prop('disabled', true);
    $("#JangkaWktSwcRDB").data("kendoNumericTextBox").enable(false);
    $("#dtJatuhTempoSwcRDB").prop('disabled', true);
    $("#cmbFrekPendebetanSwcRDB").data('kendoDropDownList').enable(false);
    $("#cmbAutoRedempSwcRDB").data('kendoDropDownList').enable(false);
    $("#cmbAsuransiSwcRDB").data('kendoDropDownList').enable(false);

    //$("#MoneyFeeSwcRDB").prop('disabled', true);
    $("#MoneyFeeSwcRDB").data("kendoNumericTextBox").enable(false);
    //$("#PercentageFeeSwcRDB").prop('disabled', true);
    $("#PercentageFeeSwcRDB").data("kendoNumericTextBox").enable(false);

    $("#txtbInputterSwcRDB").prop('disabled', true);
    $("#textExpireWaperdSwcRDB").prop('disabled', true);
}
function DisableFormBooking(isEnabled) {
    $("#srcOfficeBooking_text1").prop('disabled', true);
    $("#srcOfficeBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#WaperdNoBooking").prop('disabled', true);
    $("#srcWaperdBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#RefIDBooking").prop('disabled', isEnabled);
    $("#CIFNoBooking").prop('disabled', isEnabled);
    $("#SellerIdBooking").prop('disabled', isEnabled);
    $("#srcReferentorBooking_text1").prop('disabled', isEnabled);
    if (!isEnabled) {
        $("#srcNoRefBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcCIFBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcSellerBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcReferentorBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }
    else {
        $("#srcNoRefBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcCIFBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcSellerBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

        $("#srcReferentorBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    }
    document.getElementById("btnDokumenBooking").disabled = !isEnabled;
    $("#checkFeeEditBooking").prop('disabled', true);
    //$("#MoneyNomBooking").prop('disabled', !isEnabled);
    $("#MoneyNomBooking").data("kendoNumericTextBox").enable(isEnabled);
    if (_intType == 2) {
        $("#RefIDBooking").prop('disabled', true);
        $("#srcNoRefBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#CIFNoBooking").prop('disabled', true);
        $("#srcCIFBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

        //$("#MoneyNomBooking").prop('disabled', false);
        $("#MoneyNomBooking").data("kendoNumericTextBox").enable(true);
        $("#checkFeeEditBooking").prop('disabled', true);

    }
    $("#textSIDBooking").prop('disabled', true);
    $("#txtUmurBooking").prop('disabled', true);
    $("#textShareHolderIdBooking").prop('disabled', true);
    $("#textRekeningBooking").prop('disabled', true);

    $("#maskedRekeningBooking").prop('disabled', true);
    $("#maskedRekeningBookingUSD").prop('disabled', true);
    $("#maskedRekeningBookingMC").prop('disabled', true);

    $("#textNoTransaksiBooking").prop('disabled', !isEnabled);
    $("#dateTglTransaksiBooking").prop('disabled', true);

    $("#ClientCodeBooking").prop('disabled', true);
    $("#CurrCodeBooking").prop('disabled', true);
    $("#srcClientBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    $("#srcCurrencyBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#ProdCodeBooking").prop('disabled', !isEnabled);
    if (isEnabled) {
        $("#srcProductBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
    }
    else {
        $("#srcProductBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    }

    $("#checkPhoneOrderBooking").prop('disabled', true);
    //$("#_sisaunit").prop('disabled', true);
    $("#_sisaunit").data("kendoNumericTextBox").enable(false);

    //$("#_ComboJenisBooking").prop('disabled', true);
    $("#_ComboJenisBooking").data('kendoDropDownList').enable(false);
    //$("#MoneyFeeBooking").prop('disabled', true);
    $("#MoneyFeeBooking").data("kendoNumericTextBox").enable(false);
    //$("#PercentageFeeBooking").prop('disabled', true);
    $("#PercentageFeeBooking").data("kendoNumericTextBox").enable(false);

    $("#txtbInputterBooking").prop('disabled', true);
    $("#textExpireWaperdBooking").prop('disabled', true);
}
function subResetToolBar() {
    if (_strTabName == "SWCRDB") {
        switch (_intType) {
            case 0:
                {
                    document.getElementById("btnRefresh").disabled = false;
                    document.getElementById("btnNew").disabled = false;
                    document.getElementById("btnEdit").disabled = true;
                    document.getElementById("btnSave").disabled = true;
                    document.getElementById("btnCancel").disabled = true;
                    break;
                }
            case 1:
                {
                    document.getElementById("btnRefresh").disabled = true;
                    document.getElementById("btnNew").disabled = true;
                    document.getElementById("btnEdit").disabled = true;
                    document.getElementById("btnSave").disabled = false;
                    document.getElementById("btnCancel").disabled = false;
                    break;
                }
            case 2:
                {
                    document.getElementById("btnRefresh").disabled = true;
                    document.getElementById("btnNew").disabled = true;
                    document.getElementById("btnEdit").disabled = true;
                    document.getElementById("btnSave").disabled = false;
                    document.getElementById("btnCancel").disabled = false;
                    break;
                }
        }
    }
    else if (_strTabName == "BOOK") {
        switch (_intType) {
            case 0:
                {
                    document.getElementById("btnRefresh").disabled = false;
                    document.getElementById("btnNew").disabled = false;
                    document.getElementById("btnEdit").disabled = true;
                    document.getElementById("btnSave").disabled = true;
                    document.getElementById("btnCancel").disabled = true;
                    break;
                }
            case 1:
                {
                    document.getElementById("btnRefresh").disabled = true;
                    document.getElementById("btnNew").disabled = true;
                    document.getElementById("btnEdit").disabled = true;
                    document.getElementById("btnSave").disabled = false;
                    document.getElementById("btnCancel").disabled = false;
                    break;
                }
            case 2:
                {
                    document.getElementById("btnRefresh").disabled = true;
                    document.getElementById("btnNew").disabled = true;
                    document.getElementById("btnEdit").disabled = true;
                    document.getElementById("btnSave").disabled = false;
                    document.getElementById("btnCancel").disabled = false;
                    break;
                }
        }
    }
    else {
        console.log(_intType);
        switch (_intType) {
            case 0:
                {
                    document.getElementById("btnRefresh").disabled = false;
                    document.getElementById("btnNew").disabled = false;
                    document.getElementById("btnEdit").disabled = false;
                    document.getElementById("btnSave").disabled = true;
                    document.getElementById("btnCancel").disabled = true;
                    break;
                }
            case 1:
                {
                    document.getElementById("btnRefresh").disabled = true;
                    document.getElementById("btnNew").disabled = true;
                    document.getElementById("btnEdit").disabled = true;
                    document.getElementById("btnSave").disabled = false;
                    document.getElementById("btnCancel").disabled = false;
                    break;
                }
            case 2:
                {
                    document.getElementById("btnRefresh").disabled = true;
                    document.getElementById("btnNew").disabled = true;
                    document.getElementById("btnEdit").disabled = true;
                    document.getElementById("btnSave").disabled = false;
                    document.getElementById("btnCancel").disabled = false;
                    break;
                }
        }
    }
}
function ResetForm() {
    ResetFormSubs();
    ResetFormRedemp();
    ResetFormRDB();
    ResetFormSwc();
    ResetFormSwcRDB();
    ResetFormBooking();

    //REKSA_CIF_ALL

    $('#srcCIFSubs').attr('href', '/Global/SearchCustomer/?criteria=SUBS');
    $('#srcCIFRedemp').attr('href', '/Global/SearchCustomer/?criteria=REDEMP');
    $('#srcCIFRDB').attr('href', '/Global/SearchCustomer/?criteria=SUBSRDB');
    $('#srcCIFSwc').attr('href', '/Global/SearchCustomer/?criteria=SWC');
    $('#srcCIFSwcRDB').attr('href', '/Global/SearchCustomer/?criteria=SWCRDB');
    $('#srcCIFSwcBooking').attr('href', '/Global/SearchCustomer/?criteria=BOOK');
    //if (objFormDocument != null) objFormDocument.ResetForm();
}
function ResetFormSubs() {
    $('#srcCIFSubs_text1').val('');
    $('#srcCIFSubs_text2').val('');
    $('#srcNoRefSubs_text1').val('');
    $('#srcNoRefSubs_text2').val('');

    $('#textSIDSubs').val('');
    $('#txtUmurSubs').val('');
    $('#textShareHolderIdSubs').val('');
    $('#textNamaRekeningSubs').val('');
    $('#maskedRekeningSubs').val('');
    $('#maskedRekeningSubsUSD').val('');
    $('#maskedRekeningSubsMC').val('');
    $('#txtbRiskProfileSubs').val('');
    $("#dtpRiskProfileSubs").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#dateTglTransaksiSubs").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());

    ResetFormTrxSubs();
    $("#dataGridViewSubs").data('kendoGrid').dataSource.data([]);

    $('#txtbInputterSubs').val('');
    $('#srcSellerSubs_text1').val('');
    $('#srcSellerSubs_text2').val('');
    $('#srcWaperdSubs_text1').val('');
    $('#srcWaperdSubs_text2').val('');
    $('#textExpireWaperdSubs').val('');
    $('#srcReferentorSubs_text1').val('');
    $('#srcReferentorSubs_text2').val('');
}
function ResetFormTrxSubs() {
    _StatusTransaksiSubs = "";

    $('#textNoTransaksiSubs').val('');
    $('#srcProductSubs_text1').val('');
    $('#srcProductSubs_text2').val('');
    $('#srcClientSubs_text1').val('');
    $('#srcClientSubs_text2').val('');
    $('#srcCurrencySubs_text1').val('');
    $('#srcCurrencySubs_text2').val('');
    //$('#MoneyNomSubs').val(0);
    $("#MoneyNomSubs").data("kendoNumericTextBox").value(0);
    $('#checkPhoneOrderSubs').prop('checked', false);
    $('#checkFullAmtSubs').prop('checked', true);
    $('#checkFeeEditSubs').prop('checked', false);
    $('#_ComboJenisSubs').val('');
    //$('#MoneyFeeSubs').val(0);
    $("#MoneyFeeSubs").data("kendoNumericTextBox").value(0);
    $('#labelFeeCurrencySubs').val('');
    //$('#PercentageFeeSubs').val(0);
    $("#PercentageFeeSubs").data("kendoNumericTextBox").value(0);

    $("#btnAddSubs").attr('class', 'btn btn-default waves-effect waves-light');
    $("#btnAddSubs").html('<span class="btn-label"><i class= "fa fa-plus"></i></span >Add');
    $("#btnEditSubs").attr('class', 'btn btn-info waves-effect waves-light');
    $("#btnEditSubs").html('<span class="btn-label"><i class= "fa fa-edit"></i></span >Edit');
}
function ResetFormRedemp() {
    $('#srcCIFRedemp_text1').val('');
    $('#srcCIFRedemp_text2').val('');
    $('#srcNoRefRedemp_text1').val('');
    $('#srcNoRefRedemp_text2').val('');

    $('#textSIDRedemp').val('');
    $('#txtUmurRedemp').val('');
    $('#textShareHolderIdRedemp').val('');
    $('#textNamaRekeningRedemp').val('');
    $('#maskedRekeningRedemp').val('');
    $('#maskedRekeningRedempUSD').val('');
    $('#maskedRekeningRedempMC').val('');
    $('#txtbRiskProfileRedemp').val('');
    $("#dtpRiskProfileRedemp").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#dateTglTransaksiRedemp").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());

    ResetFormTrxRedemp();
    $("#dataGridViewRedemp").data('kendoGrid').dataSource.data([]);

    $('#txtbInputterRedemp').val('');
    $('#srcSellerRedemp_text1').val('');
    $('#srcSellerRedemp_text2').val('');
    $('#srcWaperdRedemp_text1').val('');
    $('#srcWaperdRedemp_text2').val('');
    $('#textExpireWaperdRedemp').val('');
    $('#srcReferentorRedemp_text1').val('');
    $('#srcReferentorRedemp_text2').val('');
}
function ResetFormTrxRedemp() {
    _StatusTransaksiRedemp = "";

    $('#textNoTransaksiRedemp').val('');
    $('#srcProductRedemp_text1').val('');
    $('#srcProductRedemp_text2').val('');
    $('#srcClientRedemp_text1').val('');
    $('#srcClientRedemp_text2').val('');
    $('#srcCurrenyRedemp_text1').val('');
    $('#srcCurrenyRedemp_text2').val('');

    //$('#OutstandingUnitRedemp').val(0);
    $("#OutstandingUnitRedemp").data("kendoNumericTextBox").value(0);
    //$('#RedempUnit').val(0);
    $("#RedempUnit").data("kendoNumericTextBox").value(0);

    $('#checkPhoneOrderRedemp').prop('checked', false);
    $('#checkFeeEditRedemp').prop('checked', false);
    $('#_ComboJenisRedemp').val('');
    $('#MoneyFeeRedemp').val(0);
    $('#labelFeeCurrencyRedemp').val('');
    $('#PercentageFeeRedemp').val(0);
    $('#checkAll').prop('checked', false);
    $("#btnAddRedemp").attr('class', 'btn btn-default waves-effect waves-light');
    $("#btnAddRedemp").html('<span class="btn-label"><i class= "fa fa-plus"></i></span >Add');
    $("#btnEditRedemp").attr('class', 'btn btn-info waves-effect waves-light');
    $("#btnEditRedemp").html('<span class="btn-label"><i class= "fa fa-edit"></i></span >Edit');
}
function ResetFormRDB() {
    $('#srcCIFRDB_text1').val('');
    $('#srcCIFRDB_text2').val('');
    $('#srcNoRefRDB_text1').val('');
    $('#srcNoRefRDB_text2').val('');

    $('#textSIDRDB').val('');
    $('#txtUmurRDB').val('');
    $('#textShareHolderIdRDB').val('');
    $('#textNamaRekeningRDB').val('');
    $('#maskedRekeningRDB').val('');
    $('#maskedRekeningRDBUSD').val('');
    $('#maskedRekeningRDBMC').val('');
    $('#txtbRiskProfileRDB').val('');
    $("#dtpRiskProfileRDB").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#dateTglTransaksiRDB").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());

    ResetFormTrxSubsRDB();
    $("#dataGridViewRDB").data('kendoGrid').dataSource.data([]);

    $('#txtbInputterRDB').val('');
    $('#srcSellerRDB_text1').val('');
    $('#srcSellerRDB_text2').val('');
    $('#srcWaperdRDB_text1').val('');
    $('#srcWaperdRDB_text2').val('');
    $('#textExpireWaperdRDB').val('');
    $('#srcReferentorRDB_text1').val('');
    $('#srcReferentorRDB_text2').val('');
}
function ResetFormTrxSubsRDB() {
    _StatusTransaksiRDB = "";

    $('#textNoTransaksiRDB').val('');
    $('#srcProductRDB_text1').val('');
    $('#srcProductRDB_text2').val('');
    $('#srcClientRDB_text1').val('');
    $('#srcClientRDB_text2').val('');
    $('#srcCurrencyRDB_text1').val('');
    $('#srcCurrencyRDB_text2').val('');
    $('#MoneyNomRDB').val(0);
    $('#checkPhoneOrderRDB').prop('checked', false);

    $("#JangkaWktRDB").data("kendoNumericTextBox").value(0);
    $('#dtJatuhTempoRDB').val('');
    $('#cmbFrekPendebetanRDB').val('')
    $('#cmbAutoRedempRDB').val('')
    $('#cmbAsuransiRDB').val('')

    $('#checkFeeEditRDB').prop('checked', false);
    $('#_ComboJenisRDB').val('');
    $('#MoneyFeeRDB').val(0);
    $('#labelFeeCurrencyRDB').val('');
    $('#PercentageFeeRDB').val(0);
    $("#btnAddRDB").attr('class', 'btn btn-default waves-effect waves-light');
    $("#btnAddRDB").html('<span class="btn-label"><i class= "fa fa-plus"></i></span >Add');
    $("#btnEditRDB").attr('class', 'btn btn-info waves-effect waves-light');
    $("#btnEditRDB").html('<span class="btn-label"><i class= "fa fa-edit"></i></span >Edit');
}
function ResetFormSwc() {

    $('#labelStatusSwc').text('');
    $('#srcCIFSwc_text1').val('');
    $('#srcCIFSwc_text2').val('');
    $('#srcNoRefSwc_text1').val('');
    $('#srcNoRefSwc_text2').val('');

    $('#textSIDSwc').val('');
    $('#txtUmurSwc').val('');
    $('#textShareHolderIdSwc').val('');
    $('#textNamaRekeningSwc').val('');
    $('#maskedRekeningSwc').val('');
    $('#maskedRekeningSwcUSD').val('');
    $('#maskedRekeningSwcMC').val('');
    $('#txtbRiskProfileSwc').val('');
    $("#dtpRiskProfileSwc").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $('#textNoTransaksiSwc').val('');
    $("#dateTglTransaksiSwc").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());

    $('#srcProductSwcOut_text1').val('');
    $('#srcProductSwcOut_text2').val('');

    $('#srcClientSwcOut_text1').val('');
    $('#srcClientSwcOut_text2').val('');

    $("#OutstandingUnitSwc").data("kendoNumericTextBox").value(0);
    $("#RedempSwc").data("kendoNumericTextBox").value(0);

    $('#srcProductSwcIn_text1').val('');
    $('#srcProductSwcIn_text2').val('');

    $('#srcClientSwcIn_text1').val('');
    $('#srcClientSwcIn_text2').val('');

    $('#checkPhoneOrderSwc').prop('checked', false);
    $('#checkFeeEditSwc').prop('checked', false);
    $('#checkSwcAll').prop('checked', false);

    $('#MoneyFeeSwc').val(0);
    $('#labelFeeCurrencySwc').val('');
    $('#PercentageFeeSwc').val(0);

    $('#txtbInputterSwc').val('');
    $('#srcSellerSwc_text1').val('');
    $('#srcSellerSwc_text2').val('');
    $('#srcWaperdSwc_text1').val('');
    $('#srcWaperdSwc_text2').val('');
    $('#textExpireWaperdSwc').val('');
    $('#srcReferentorSwc_text1').val('');
    $('#srcReferentorSwc_text2').val('');
}
function ResetFormSwcRDB() {
    var Today = new Date();
    $('#labelStatusSwcRDB').text('');
    $('#srcCIFSwcRDB_text1').val('');
    $('#srcCIFSwcRDB_text2').val('');
    $('#srcNoRefSwcRDB_text1').val('');
    $('#srcNoRefSwcRDB_text2').val('');

    $('#textSIDSwcRDB').val('');
    $('#txtUmurSwcRDB').val('');
    $('#textShareHolderIdSwcRDB').val('');
    $('#textNamaRekeningSwcRDB').val('');
    $('#maskedRekeningSwcRDB').val('');
    $('#maskedRekeningSwcRDBUSD').val('');
    $('#maskedRekeningSwcRDBMC').val('');
    $('#txtbRiskProfileSwcRDB').val('');
    $("#dtpRiskProfileSwcRDB").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $('#textNoTransaksiSwcRDB').val('');
    $("#dateTglTransaksiSwcRDB").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());

    $('#srcProductSwcRDBOut_text1').val('');
    $('#srcProductSwcRDBOut_text2').val('');

    $('#srcClientSwcRDBOut_text1').val('');
    $('#srcClientSwcRDBOut_text2').val('');

    $('#OutstandingUnitSwcRDB').val(0);
    $('#RedempSwcRDB').val(0);

    //$('#JangkaWktSwcRDB').val(0);
    $("#JangkaWktSwcRDB").data("kendoNumericTextBox").value(0);
    $('#dtJatuhTempoSwcRDB').val('');
    $('#cmbFrekPendebetanSwcRDB').val('');
    $("#cmbAutoRedempSwcRDB").data('kendoDropDownList').value(0);
    $("#cmbAsuransiSwcRDB").data('kendoDropDownList').value(0);

    $('#srcProductSwcRDBIn_text1').val('');
    $('#srcProductSwcRDBIn_text2').val('');

    $('#srcClientSwcRDBIn_text1').val('');
    $('#srcClientSwcRDBIn_text2').val('');

    $('#checkPhoneOrderSwcRDB').prop('checked', false);
    $('#checkFeeEditSwcRDB').prop('checked', false);
    $('#MoneyFeeSwcRDB').val(0);
    $('#labelFeeCurrencySwcRDB').val('');
    $('#PercentageFeeSwcRDB').val(0);

    $('#txtbInputterSwcRDB').val('');
    $('#srcSellerSwcRDB_text1').val('');
    $('#srcSellerSwcRDB_text2').val('');
    $('#srcWaperdSwcRDB_text1').val('');
    $('#srcWaperdSwcRDB_text2').val('');
    $('#textExpireWaperdSwcRDB').val('');
    $('#srcReferentorSwcRDB_text1').val('');
    $('#srcReferentorSwcRDB_text2').val('');
}
function ResetFormBooking() {
    var Today = new Date();
    $('#labelStatusBooking').text('');
    $('#srcCIFBooking_text1').val('');
    $('#srcCIFBooking_text2').val('');
    $('#srcNoRefBooking_text1').val('');
    $('#srcNoRefBooking_text2').val('');

    $('#textSIDBooking').val('');
    $('#txtUmurBooking').val('');
    $('#textShareHolderIdBooking').val('');
    $('#textNamaRekeningBooking').val('');
    $('#maskedRekeningBooking').val('');
    $('#maskedRekeningBookingUSD').val('');
    $('#maskedRekeningBookingMC').val('');
    $('#txtbRiskProfileBooking').val('');
    $("#dtpRiskProfileBooking").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $('#textNoTransaksiBooking').val('');
    $("#dateTglTransaksiBooking").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());

    $('#srcProductBooking_text1').val('');
    $('#srcProductBooking_text2').val('');
    $('#srcClientBooking_text1').val('');
    $('#srcClientBooking_text2').val('');
    $('#srcCurrencyBooking_text1').val('');
    $('#srcCurrencyBooking_text2').val('');

    $('#MoneyNomBooking').val(0);
    $('#checkPhoneOrderBooking').prop('checked', false);
    $('#_sisaunit').val('');

    $('#checkFeeEditBooking').prop('checked', false);
    //$('#_ComboJenisBooking').val('');
    $('#MoneyFeeBooking').val(0);
    $('#labelFeeCurrencyBooking').val('');
    $('#PercentageFeeBooking').val(0);

    $('#txtbInputterBooking').val('');
    $('#srcSellerBooking_text1').val('');
    $('#srcSellerBooking_text2').val('');
    $('#srcWaperdBooking_text1').val('');
    $('#srcWaperdBooking_text2').val('');
    $('#textExpireWaperdBooking').val('');
    $('#srcReferentorBooking_text1').val('');
    $('#srcReferentorBooking_text2').val('');
}
function SetEnableOfficeId(strKodeKantor) {
    ValidasiCBOKodeKantor(strKodeKantor, function (IsEnable) {
        $("#srcOfficeSubs_text1").val(strKodeKantor);
        $("#srcOfficeRedemp_text1").val(strKodeKantor);
        $("#srcOfficeRDB_text1").val(strKodeKantor);
        $("#srcOfficeSwc_text1").val(strKodeKantor);
        $("#srcOfficeSwcRDB_text1").val(strKodeKantor);
        $("#srcOfficeBooking_text1").val(strKodeKantor);
        if (IsEnable == "1") {
            $("#srcOfficeSubs_text1").prop('disabled', false);
            $("#srcOfficeSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

            $("#srcOfficeRedemp_text1").prop('disabled', false);
            $("#srcOfficeRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

            $("#srcOfficeRDB_text1").prop('disabled', false);
            $("#srcOfficeRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

            $("#srcOfficeSwc_text1").prop('disabled', false);
            $("#srcOfficeSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

            $("#srcOfficeSwcRDB_text1").prop('disabled', false);
            $("#srcOfficeSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

            $("#srcOfficeBooking_text1").prop('disabled', false);
            $("#srcOfficeBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        }
        else {
            $("#srcOfficeSubs_text1").prop('disabled', true);
            $("#srcOfficeSubs").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

            $("#srcOfficeRedemp_text1").prop('disabled', true);
            $("#srcOfficeRedemp").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

            $("#srcOfficeRDB_text1").prop('disabled', true);
            $("#srcOfficeRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

            $("#srcOfficeSwc_text1").prop('disabled', true);
            $("#srcOfficeSwc").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

            $("#srcOfficeSwcRDB_text1").prop('disabled', true);
            $("#srcOfficeSwcRDB").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

            $("#srcOfficeBooking_text1").prop('disabled', true);
            $("#srcOfficeBooking").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        }
    });
}


function ResetAllKodeKantor() {
    $("#srcOfficeSubs_text1").val(strBranch);
    $("#srcOfficeRedemp_text1").val(strBranch);
    $("#srcOfficeRDB_text1").val(strBranch);
    $("#srcOfficeSwc_text1").val(strBranch);
    $("#srcOfficeSwcRDB_text1").val(strBranch);
    $("#srcOfficeBooking_text1").val(strBranch);
}
function subSetVisibleGrid(_strTabName) {
    if (_strTabName == "SUBS") {
        var dataGridViewSubs = $('#dataGridViewSubs').data('kendoGrid');
        dataGridViewSubs.hideColumn('TglTrx');
    }
    else if (_strTabName == "REDEMP") {
        var dataGridViewRedemp = $('#dataGridViewRedemp').data('kendoGrid');
        dataGridViewRedemp.hideColumn('TglTrx');
    }
}
function CheckIsSubsNew(CIFNo, ProductId, IsRDB) {
    return $.ajax({
        type: 'GET',
        url: '/Transaksi/CheckSubsType',
        data: { CIFNo: CIFNo, ProductId: ProductId, IsRDB: IsRDB }
    });
}
function GenerateTranCodeAndClientCode(JenisTrx, IsSubsNew, ProductCode, ClientCode, CIFNo, IsFeeEdit, PercentageFee, Period, FullAmount, Fee, TranAmt, TranUnit, IsRedempAll, FrekuensiPendebetan, JangkaWaktu, intTypeTrx) {
    var model = JSON.stringify({
        'JenisTrx': JenisTrx,
        'IsSubsNew': IsSubsNew,
        'ProductCode': ProductCode,
        'ClientCode': ClientCode,
        'CIFNo': CIFNo,
        'IsFeeEdit': IsFeeEdit,
        'PercentageFee': PercentageFee,
        'Period': Period,
        'FullAmount': FullAmount,
        'Fee': Fee,
        'TranAmt': TranAmt,
        'TranUnit': TranUnit,
        'IsRedempAll': IsRedempAll,
        'FrekuensiPendebetan': FrekuensiPendebetan,
        'JangkaWaktu': JangkaWaktu,
        'intTypeTrx': intTypeTrx,
        'TranCode': '',
        'NewClientCode': ''
    });
    return $.ajax({
        type: 'POST',
        url: '/Transaksi/GenerateTranCodeClientCode',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        async: false
    });
}
function HitungBookingFee(CIFNo, BookingAmount, ProductCode, ByPercent, IsFeeEdit, PercentageFeeInput) {
    return $.ajax({
        type: 'GET',
        url: '/Transaksi/HitungBookingFee',
        data: {
            CIFNo: CIFNo, BookingAmount: BookingAmount, ProductCode: ProductCode, ByPercent: ByPercent, IsFeeEdit: IsFeeEdit, PercentageFeeInput: PercentageFeeInput
        },
        async: false
    });
}
function HitungFee(ProdId, ClientId, TranType, TranAmt, TranUnit, FullAmount, IsFeeEdit, PercentageFeeInput, Jenis, strCIFNo) {
    return $.ajax({
        type: 'GET',
        url: '/Transaksi/HitungFee',
        data: {
            ProdId: ProdId, ClientId: ClientId, TranType: TranType, TranAmt: TranAmt, TranUnit: TranUnit,
            FullAmount: FullAmount, IsFeeEdit: IsFeeEdit, PercentageFeeInput: PercentageFeeInput,
            Jenis: Jenis, strCIFNo: strCIFNo, ByPercent: ByPercent
        },
        async: false
    });
}
function GetLatestBalance(ClientId) {
    console.log(ClientId);
    return $.ajax({
        type: 'GET',
        url: '/Transaksi/GetLatestBalance',
        data: {
            ClientID: ClientId
        },
        async: false
    });
}
function GetImportantData(CariApa, InputData) {
    return $.ajax({
        type: 'GET',
        url: '/Transaksi/GetImportantData',
        data: { CariApa: CariApa, InputData: InputData },
        async: false
    });
}
function HitungSwitchingRDBFee(ProdIdSwitchOut, ClientIdSwitchOut, Unit, IsEdit, PercentageInput) {
    var model = JSON.stringify({
        'ProdSwitchOut': ProdIdSwitchOut,
        'ClientSwitchOut': ClientIdSwitchOut,
        'Unit': Unit,
        'IsEdit': IsEdit,
        'PercentageInput': PercentageInput
    });

    return $.ajax({
        type: 'POST',
        data: model,
        url: '/Transaksi/HitungSwitchingRDBFee',
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        async: false
    });
}
function GetDataRDB(clientCode) {
    return $.ajax({
        type: 'GET',
        url: '/Customer/GetListClientRDB',
        data: { ClientCode: clientCode }
    });
}
function GetLatestNAV(ProdId) {
    return $.ajax({
        type: 'GET',
        url: '/Transaksi/GetLatestNAV',
        data: { ProdId: ProdId },
        async: false
    });
}
function HitungSwitchingFee(ProdCodeSwitchOut, ProdCodeSwitchIn, Jenis, TranAmt, Unit, IsEdit, PercentageInput, IsEmployee) {
    var model = JSON.stringify({
        'ProdSwitchOut': ProdCodeSwitchOut,
        'ProdSwitchIn': ProdCodeSwitchIn,
        'Jenis': Jenis,
        'TranAmt': TranAmt,
        'Unit': Unit,
        'NAV': 0,
        'IsEdit': IsEdit,
        'PercentageInput': PercentageInput,
        'IsEmployee': IsEmployee
    });

    return $.ajax({
        type: 'POST',
        data: model,
        url: '/Transaksi/HitungSwitchingFee',
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        async: false
    });
}
function toDate(dateStr) {
    var [day, month, year] = dateStr.split("/")
    return new Date(year, month - 1, day)
}
function pad(num, size) {
    var s = "000000000" + num;
    return s.substr(s.length - size);
}
function InquirySisaUnit()
{
    $.ajax({
        type: 'GET',
        url: '/Master/InqUnitDitwrkan',
        data: { ProdCode: $("#srcProductBooking_text1").val() },
        success: function (data) {
            if (data.blnResult) {
                $("#_sisaunit").data("kendoNumericTextBox").value(data.sisaUnit);
            }
            else {
                $("#_sisaunit").data("kendoNumericTextBox").value(0);
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}

function GetComponentSearch()
{
    $('#srcNoRefSubs').attr('href', '/Global/SearchReferensi/?criteria=SUBS');
    $('#srcNoRefRedemp').attr('href', '/Global/SearchReferensi/?criteria=REDEMP');
    $('#srcNoRefRDB').attr('href', '/Global/SearchReferensi/?criteria=SUBSRDB');
    $('#srcNoRefSwc').attr('href', '/Global/SearchSwitching');
    $('#srcNoRefSwcRDB').attr('href', '/Global/SearchSwitchingRDB');
    $('#srcNoRefBooking').attr('href', '/Global/SearchBooking');

    $('#srcProductSubs').attr('href', '/Global/SearchTrxProduct');

    //cmpsrKodeKantorSubs.SearchDesc = "SIBS_OFFICE";
    //cmpsrKodeKantorRedemp.SearchDesc = "SIBS_OFFICE";
    //cmpsrKodeKantorRDB.SearchDesc = "SIBS_OFFICE";
    //cmpsrKodeKantorSwc.SearchDesc = "SIBS_OFFICE";
    //cmpsrKodeKantorSwcRDB.SearchDesc = "SIBS_OFFICE";
    //cmpsrKodeKantorBooking.SearchDesc = "SIBS_OFFICE";

    $('#srcCIFSubs').attr('href', '/Global/SearchCIFAll/?criteria=SUBS');
    $('#srcCIFRedemp').attr('href', '/Global/SearchCIFAll/?criteria=REDEMP');
    $('#srcCIFRDB').attr('href', '/Global/SearchCIFAll/?criteria=SUBSRDB');
    $('#srcCIFSwc').attr('href', '/Global/SearchCIFAll/?criteria=SWCNONRDB');
    $('#srcCIFSwcRDB').attr('href', '/Global/SearchCIFAll/?criteria=SWCRDB');
    $('#srcCIFBooking').attr('href', '/Global/SearchCIFAll/?criteria=BOOK');

    $('#srcClientSubs').attr('href', '/Global/SearchTrxClient/?criteria=SUBS');
    $('#srcClientRedemp').attr('href', '/Global/SearchTrxClient/?criteria=REDEMP');
    $('#srcClientRDB').attr('href', '/Global/SearchTrxClient/?criteria=SUBSRDB');
    $('#srcClientSwcOut').attr('href', '/Global/SearchTrxClient/?criteria=SWCOUT');
    $('#srcClientSwcRDBOut').attr('href', '/Global/SearchTrxClient/?criteria=SWCRDBOUT');
    $('#srcClientSwcRDBIn').attr('href', '/Global/SearchTrxClient/?criteria=SWCRDBIN');

    $('#srcClientSwcIn').attr('href', '/Global/SearchClientSwcIn');

    $('#srcCurrenySubs').attr('href', '/Global/SearchCurrency/?criteria=SUBS');
    $('#srcCurrenyRDB').attr('href', '/Global/SearchCurrency/?criteria=SUBSRDB');
    $('#srcCurrenyBooking').attr('href', '/Global/SearchCurrency/?criteria=BOOK');

    $('#srcSellerSubs').attr('href', '/Global/SearchSeller/?criteria=SUBS');
    $('#srcSellerRedemp').attr('href', '/Global/SearchSeller/?criteria=REDEMP');
    $('#srcSellerRDB').attr('href', '/Global/SearchSeller/?criteria=SUBSRDB');
    $('#srcSellerSwc').attr('href', '/Global/SearchSeller/?criteria=SWCNONRDB');
    $('#srcSellerSwcRDB').attr('href', '/Global/SearchSeller/?criteria=SWCRDB');
    $('#srcSellerBooking').attr('href', '/Global/SearchSeller/?criteria=BOOK');

    $('#srcWaperdSubs').attr('href', '/Global/SearchWaperd/?criteria=SUBS');
    $('#srcWaperdRedemp').attr('href', '/Global/SearchWaperd/?criteria=REDEMP');
    $('#srcWaperdRDB').attr('href', '/Global/SearchWaperd/?criteria=SUBSRDB');
    $('#srcWaperdSwc').attr('href', '/Global/SearchWaperd/?criteria=SWCNONRDB');
    $('#srcWaperdSwcRDB').attr('href', '/Global/SearchWaperd/?criteria=SWCRDB');
    $('#srcWaperdBooking').attr('href', '/Global/SearchWaperd/?criteria=BOOK');


    $('#srcReferentorSubs').attr('href', '/Global/SearchReferentor/?criteria=SUBS');
    $('#srcReferentorRedemp').attr('href', '/Global/SearchReferentor/?criteria=REDEMP');
    $('#srcReferentorRDB').attr('href', '/Global/SearchReferentor/?criteria=SUBSRDB');
    $('#srcReferentorSwc').attr('href', '/Global/SearchReferentor/?criteria=SWCNONRDB');
    $('#srcReferentorSwcRDB').attr('href', '/Global/SearchReferentor/?criteria=SWCRDB');
    $('#srcReferentorBooking').attr('href', '/Global/SearchReferentor/?criteria=BOOK');
}
function SetDefaultValue()
{
    $("#dateTglTransaksiSubs").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#dateTglTransaksiRedemp").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#dateTglTransaksiRDB").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#dateTglTransaksiSwc").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#dateTglTransaksiSwcRDB").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());
    $("#dateTglTransaksiBooking").val(pad((Today.getDate()), 2) + '/' + pad((Today.getMonth() + 1), 2) + '/' + Today.getFullYear());

    $("#txtbInputterSubs").val(_intNIK);
    $("#txtbInputterRedemp").val(_intNIK);
    $("#txtbInputterRDB").val(_intNIK);
    $("#txtbInputterSwc").val(_intNIK);
    $("#txtbInputterSwcRDB").val(_intNIK);
    $("#txtbInputterBooking").val(_intNIK);
}
function CekRiskProfile(CIFNo) {
    return $.ajax({
        type: 'GET',
        url: '/Cutomer/GetRiskProfile',
        data: { CIFNo: CIFNo }
    });
}

