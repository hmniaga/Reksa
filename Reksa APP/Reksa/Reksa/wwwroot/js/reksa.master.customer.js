var _intType = 0;
var _intOpsiNPWP = 0;
var _intValidationNPWP = 0;
var _strTabName;
var intClassificationId;
var _intId;
var intMaxDay = 0;
var intMaxYear = 0;
var _dtCurrentDate = new Date();
var _intJnsNas;
var intSelectedClient;

//load
$(document).ready(function () {
    _strTabName = "MCI";
    $('#tabs a[href="#tab-identitas"]').trigger('click');

    GetComponentSearch();
    _intType = 0;
    _intId = 0;
    $("#dtpTglTran").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpExpiry").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpRiskProfile").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtExpiredRiskProfile").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtRDBJatuhTempo").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpStartDate").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpEndDate").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpTglNPWPSendiri").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpTglNPWPKK").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpTglDokTanpaNPWP").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpTglLahir").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpJoinDate").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#txtLastUpdated").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());


    $("#lblStatus").text("");
    subDisableAll(_intType);

    document.getElementById("btnShareHolder").disabled = true;
    document.getElementById("btnGantiOpsiNPWP").disabled = true;
    ValidasiKodeKantor($("#srcOffice_text1").val(), function (output) {
        if (output) {
            ValidateOffice($("#srcOffice_text1").val(), function (res) {
                $("#srcOffice_text2").val(res);
            });
        }
    });
});
function GetComponentSearch() {
    var url = "/Global/SearchCustomer";
    $('#srcCIF').attr('href', url);
}
function subResetToolbar() {
    if (intClassificationId == 118) {
        //this.NISPToolbarButtonSetVisible(true, _strDefToolBar);

        if ((_intType == 0) || (_intType == 3)) {
            if ((_strTabName == "MCB") || (_strTabName == "MCA")) {
                $("#btnRefresh").show();
                $("#buttonadd").hide();
                $("#buttonedit").show();
                $("#buttondelete").hide();
                $("#buttonsave").hide();
                $("#buttonCancel").hide();
            }
            else {
                $("#btnRefresh").show();
                $("#buttonadd").hide();
                $("#buttonedit").hide();
                $("#buttondelete").hide();
                $("#buttonsave").hide();
                $("#buttonCancel").hide();
            }
        }

        if ((_intType == 1) || (_intType == 2)) {
            $("#btnRefresh").hide();
            $("#buttonadd").hide();
            $("#buttonedit").hide();
            $("#buttondelete").hide();
            $("#buttonsave").show();
            $("#buttonCancel").show();
        }
    }
    else {
        if ((_intType == 0) || (_intType == 3)) {
            if ((_strTabName == "MCB") || (_strTabName == "MCA")) {
                $("#btnRefresh").show();
                $("#buttonadd").hide();
                $("#buttonedit").hide();
                $("#buttondelete").hide();
                $("#buttonsave").hide();
                $("#buttonCancel").hide();
            }
            else {
                $("#btnRefresh").show();
                $("#buttonadd").show();
                $("#buttonedit").show();
                $("#buttondelete").hide();
                $("#buttonsave").hide();
                $("#buttonCancel").hide();
            }
        }

        if ((_intType == 1) || (_intType == 2)) {
            $("#btnRefresh").hide();
            $("#buttonadd").hide();
            $("#buttonedit").hide();
            $("#buttondelete").hide();
            $("#buttonsave").show();
            $("#buttonCancel").show();
        }
    }
}
function ValidasiKodeKantor(strKodeKantor, result) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateOfficeId',
        data: { OfficeId: strKodeKantor },
        async: false,
        success: function (data) {
            if (data.blnResult) {
                if (data.isAllowed == true) {
                    //tabControlClient.Enabled = true;
                    $("#srcCIF_text1").prop('disabled', true);
                    $("#srcCIF").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
                    subResetToolbar();
                    result(true);
                } else {
                    subCancel();
                    //tabControlClient.Enabled = false;
                    $("#srcCIF_text1").prop('disabled', true);
                    $("#srcCIF").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
                    swal("Warning", "Kode Kantor tidak terdaftar, pembuatan master nasabah tidak dapat dilakukan!", "warning");
                    result(false);
                }
            }
            else {
                swal("Error ValidateOfficeId", data.strErrMsg, "error");
                result(false);
            }
        }
    });
}
function subUpdate() {
    if ($("#srcCIF_text1").val() == '') {
        swal("Warning", "Pilih Nasabah Terlebih Dahulu", "warning");
    }
    else {
        subRefresh();
        _intType = 2;
        $("#lblStatus").text("UPDATING");

        if ((_strTabName == "MCI") || (_strTabName == "MCA") || (_strTabName == "MCN")) {
            $("#srcCIF_text1").prop('disabled', true);
            $("#srcCIF").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
            $("#tbNama").prop('disabled', true);
            $("#cbStatus").data('kendoDropDownList').enable(true);
            $("#srcEmployee_text1").prop('disabled', true);
            $("#srcEmployee").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
            $("#cbProfilResiko").prop('disabled', true);
            $("#cbKetum").prop('disabled', true);
            $("#txtbRiskProfile").prop('disabled', true);
            $("#maskedRekening").prop('disabled', false);
            $("#tbNamaRekening").prop('disabled', true);
            $("#maskedRekeningUSD").prop('disabled', false);
            $("#tbNamaRekeningUSD").prop('disabled', true);
            $("#maskedRekeningMC").prop('disabled', false);
            $("#tbNamaRekeningMC").prop('disabled', true);
            $("#cbDikirimKe").data('kendoDropDownList').enable(true);
            $("#srcCabang_text1").prop('disabled', false);
            $("#searchOfficeCabang").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

            $("#tbNoNPWPKK").prop('disabled', true);
            $("#tbNamaNPWPKK").prop('disabled', true);
            $("#cbKepemilikanNPWPKK").data('kendoDropDownList').enable(false);
            $("#tbKepemilikanLainnya").prop('disabled', true);
            $("#dtpTglNPWPKK").data("kendoDatePicker").enable(false);
            $("#cbAlasanTanpaNPWP").data('kendoDropDownList').enable(false);

            document.getElementById("btnGenerateNoDokTanpaNPWP").disabled = true;
            document.getElementById("btnGantiOpsiNPWP").disabled = false;

            //if (dgvKonfAddr.Rows.Count > 0) {
            //    for (int i = 0; i < dgvKonfAddr.Columns.Count; i++)
            //    {
            //        dgvKonfAddr.Columns[i].ReadOnly = false;
            //    }
            //}

            cekCheckbox();

        }
        else if (_strTabName == "MCB") {
            ReksaRefreshBlokir();
            $("#MoneyBlokir").data("kendoNumericTextBox").enable(true);
            $("#dtpExpiry").data("kendoDatePicker").enable(true);
        }
        else {
            _intType = 0;
        }
        subResetToolbar();
    }
}
function subDelete() {
    _intType = 3;
    swal({
        title: "Are you sure to delete this data?",
        text: "You need to approval from suppervisor!",
        type: "warning",
        showCancelButton: true,
        confirmButtonClass: 'btn-danger',
        confirmButtonText: "Yes, delete it!",
        closeOnConfirm: false
    },
        function () {
            subSave();
        });

    _intType = 0;
    subResetToolbar();
}
function subRefresh() {
    var CIFNo = $("#srcCIF_text1").val();
    if (CIFNo == "") {
        swal("Warning", "Nomor CIF Harus Diisi!", "warning");
        return;
    }
    if ((_strTabName == "MCI") || (_strTabName == "MCN")) {
        $.ajax({
            type: 'GET',
            url: '/Customer/RefreshNasabah',
            data: { CIFNo: CIFNo },
            beforeSend: function ()
            {
                $("#load_screen").show();
            },            
            success: function (data) {                
                if (data.blnResult) {
                    _intId = data.listCust[0].NasabahId;
                    $("#srcOffice_text1").val(data.listCust[0].OfficeId);
                    $("#textShareHolderId").val(data.listCust[0].ShareholderID);
                    $("#tbNama").val(data.listCust[0].CIFName);
                    if ($("#srcCIF_text2").val() == "") {
                        $("#srcCIF_text2").val($("#tbNama").val());
                    }
                    $("#tbTmptLahir").val(data.listCust[0].CIFBirthPlace);
                    var dateBirthDay = new Date(data.listCust[0].CIFBirthDay);
                    $("#dtpTglLahir").val(pad((dateBirthDay.getDate()), 2) + '/' + pad((dateBirthDay.getMonth() + 1), 2) + '/' + dateBirthDay.getFullYear());
                    var dateCreate = new Date(data.listCust[0].CreateDate);
                    $("#dtpJoinDate").val(pad((dateCreate.getDate()), 2) + '/' + pad((dateCreate.getMonth() + 1), 2) + '/' + dateCreate.getFullYear());
                    $("#maskedRekening").val(data.listCust[0].AccountId);
                    $("#tbNamaRekening").val(data.listCust[0].AccountName);
                    $("#maskedRekeningUSD").val(data.listCust[0].AccountIdUSD);
                    $("#tbNamaRekeningUSD").val(data.listCust[0].AccountNameUSD);
                    $("#maskedRekeningMC").val(data.listCust[0].AccountIdMC);
                    $("#tbNamaRekeningMC").val(data.listCust[0].AccountNameMC);
                    $("#tbKTP").val(data.listCust[0].CIFIDNo);
                    $("#tbHP").val(data.listCust[0].HP);
                    $("#textSID").val(data.listCust[0].CIFSID);
                    $("#textSubSegment").val(data.listCust[0].SubSegment);
                    $("#textSegment").val(data.listCust[0].Segment);
                    //checkPhoneOrder.Checked = GlobalFunctionCIF.CekCIFProductFacility(cmpsrCIF.Text1.ToString());
                    $("#cbStatus").data('kendoDropDownList').value(data.listCust[0].IsEmployee);
                    _intJnsNas = data.listCust[0].CIFType;
                    if (_intJnsNas == 1) {
                        $("#txtJenisNasabah").val('INDIVIDUAL');
                    }
                    else if (_intJnsNas == 4) {
                        $("#txtJenisNasabah").val('CORPORATE');
                    }

                    if (data.listCust[0].CIFNik != 0) {
                        $("#srcEmployee_text1").val(data.listCust[0].CIFNik);
                        ValidateReferentor(data.listCust[0].CIFNik, function (output) { $("#srcEmployee_text2").val(output); });
                    }
                    else {
                        $("#srcEmployee_text1").val('');
                        $("#srcEmployee_text2").val('');
                    }

                    GetDocStatus($("#srcCIF_text1").val(), _intType);

                    $("#txtbRiskProfile").val(data.listRisk[0].RiskProfile);
                    var dtpRiskProfile = new Date(data.listRisk[0].LastUpdate);
                    $("#dtpRiskProfile").val(pad((dtpRiskProfile.getDate()), 2) + '/' + pad((dtpRiskProfile.getMonth() + 1), 2) + '/' + dtpRiskProfile.getFullYear());

                    if ($("#txtbRiskProfile").val() == "") {
                        swal("Warning", "Data risk profile tidak ada", "warning");
                    }

                    var res = GetKonfAddress($("#srcCIF_text1").val());
                    res.success(function (data) {
                        if (data.blnResult) {
                            $("#cbDikirimKe").data('kendoDropDownList').value(data.intAddressType);
                            onBoundAddressType();
                            onChangeAddressType();
                            if (data.listKonfAddrees.length != 0) {
                                var dataSource = new kendo.data.DataSource(
                                    {
                                        data: data.listKonfAddrees
                                    });
                                var Addressgrid = $('#dgvKonfAddr').data('kendoGrid');
                                Addressgrid.setDataSource(dataSource);
                                Addressgrid.dataSource.pageSize(15);
                                Addressgrid.dataSource.page(1);
                                Addressgrid.select("tr:eq(0)");
                                if (_intType == 0) {
                                    Addressgrid.hideColumn('Pilih');
                                    Addressgrid.setOptions({
                                        selectable: false
                                    });
                                    var data = Addressgrid.dataSource.data();
                                    $.each(data, function (i, row) {
                                        var Pilih = row.Pilih;

                                        if (Pilih) {
                                            $('tr[data-uid="' + row.uid + '"] ').css("background-color", "#99cc99"); //green
                                        }
                                        else {
                                            $('tr[data-uid="' + row.uid + '"] ').css("background-color", "#ffffff");  //yellow
                                        }


                                    });
                                }
                                else {
                                    Addressgrid.showColumn('Pilih');
                                }
                            }
                            else {
                                $("#dgvKonfAddr").data('kendoGrid').dataSource.data([]);
                            }

                            if (data.listBranchAddress != null) {
                                $("#srcCabang_text1").val(data.listBranchAddress.Branch);
                                ValidateOffice($("#srcCabang_text1").val(), function (output) { $("#srcCabang_text2").val(output); });
                                $("#tbAlamatSaatIni1").val(data.listBranchAddress.AddressLine1);
                                $("#tbAlamatSaatIni2").val(data.listBranchAddress.AddressLine2);
                                $("#tbKodePos").val(data.listBranchAddress.PostalCode);
                                $("#tbKotaNasabahAlmt").val(data.listBranchAddress.Kota);
                                $("#tbProvNasabahAlmt").val(data.listBranchAddress.Province);
                                var LastUpdatedDate = new Date(data.listBranchAddress.LastUpdatedDate);
                                $("#txtLastUpdated").val(pad((LastUpdatedDate.getDate()), 2) + '/' + pad((LastUpdatedDate.getMonth() + 1), 2) + '/' + LastUpdatedDate.getFullYear());

                            }
                        }
                        else {
                            swal("Warning", "Gagal Ambil Data Alamat Konfirmasi!", "warning");
                        }
                    });

                    _intOpsiNPWP = 0;
                    if (data.listCustNPWP.length != 0) {
                        $("#tbNoNPWPSendiri").val(data.listCustNPWP[0].NoNPWPProCIF);
                        $("#tbNamaNPWPSendiri").val(data.listCustNPWP[0].NamaNPWPProCIF);
                        var TglNPWP = new Date(data.listCustNPWP[0].TglNPWP);
                        $("#dtpTglNPWPSendiri").val(pad((TglNPWP.getDate()), 2) + '/' + pad((TglNPWP.getMonth() + 1), 2) + '/' + TglNPWP.getFullYear());
                        $("#tbNoNPWPKK").val(data.listCustNPWP[0].NoNPWPKK);
                        $("#tbNamaNPWPKK").val(data.listCustNPWP[0].NamaNPWPKK);
                        $("#cbKepemilikanNPWPKK").data('kendoDropDownList').value(data.listCustNPWP[0].KepemilikanNPWPKK);
                        $("#tbKepemilikanLainnya").val(data.listCustNPWP[0].KepemilikanNPWPKKLainnya);
                        var TglNPWPKK = new Date(data.listCustNPWP[0].TglNPWPKK);
                        $("#dtpTglNPWPKK").val(pad((TglNPWPKK.getDate()), 2) + '/' + pad((TglNPWPKK.getMonth() + 1), 2) + '/' + TglNPWPKK.getFullYear());
                        $("#cbAlasanTanpaNPWP").data('kendoDropDownList').value(data.listCustNPWP[0].AlasanTanpaNPWP);
                        $("#tbNoDokTanpaNPWP").val(data.listCustNPWP[0].NoDokTanpaNPWP);
                        var TglDokTanpaNPWP = new Date(data.listCustNPWP[0].TglDokTanpaNPWP);
                        $("#dtpTglDokTanpaNPWP").val(pad((TglDokTanpaNPWP.getDate()), 2) + '/' + pad((TglDokTanpaNPWP.getMonth() + 1), 2) + '/' + TglDokTanpaNPWP.getFullYear());
                        _intOpsiNPWP = data.listCustNPWP[0].Opsi;
                        _intValidationNPWP = _intOpsiNPWP;
                    }
                    else {
                        $("#tbNoNPWPSendiri").val(data.listCust[0].CIFNPWP);
                        $("#tbNamaNPWPSendiri").val(data.listCust[0].NamaNPWP);
                        var TglNPWP = new Date(data.listCust[0].TglNPWP);
                        $("#dtpTglNPWPSendiri").val(pad((TglNPWP.getDate()), 2) + '/' + pad((TglNPWP.getMonth() + 1), 2) + '/' + TglNPWP.getFullYear());
                        $("#tbNoNPWPKK").val(data.listCust[0].NoNPWPKK);
                        $("#tbNamaNPWPKK").val(data.listCust[0].NamaNPWPKK);
                        $("#cbKepemilikanNPWPKK").data('kendoDropDownList').value(data.listCust[0].KepemilikanNPWPKK);
                        $("#tbKepemilikanLainnya").val(data.listCust[0].KepemilikanNPWPKKLainnya);
                        var TglNPWPKK = new Date(data.listCust[0].TglNPWPKK);
                        $("#dtpTglNPWPKK").val(pad((TglNPWPKK.getDate()), 2) + '/' + pad((TglNPWPKK.getMonth() + 1), 2) + '/' + TglNPWPKK.getFullYear());
                        $("#cbAlasanTanpaNPWP").data('kendoDropDownList').value(data.listCust[0].AlasanTanpaNPWP);
                        $("#tbNoDokTanpaNPWP").val(data.listCust[0].NoDokTanpaNPWP);
                        var TglDokTanpaNPWP = new Date(data.listCust[0].TglDokTanpaNPWP);
                        $("#dtpTglDokTanpaNPWP").val(pad((TglDokTanpaNPWP.getDate()), 2) + '/' + pad((TglDokTanpaNPWP.getMonth() + 1), 2) + '/' + TglDokTanpaNPWP.getFullYear());
                        _intOpsiNPWP = data.listCust[0].Opsi;
                        _intValidationNPWP = 0;
                    }

                    switch (data.listCust[0].ApprovalStatus) {
                        case "A":
                            {
                                $("#lblStatus").text("Aktif");
                                break;
                            }
                        case "N":
                            {
                                $("#lblStatus").text("Menunggu Otorisasi");
                                break;
                            }
                        case "T":
                            {
                                $("#lblStatus").text("Tutup");
                                break;
                            }
                    }
                 }
                else
                {
                    swal("Warning", data.ErrMsg, "warning");
                    subClearAll();
                    _intType = 0;
                    subResetToolbar();
                }
                $("#dgvClientCode").data('kendoGrid').dataSource.data([]);
                $("#dgvAktifitas").data('kendoGrid').dataSource.data([]);
                $("#textFrekPendebetan").val('');
                $("#txtRDBJangkaWaktu").val('');
                $("#chkRDBAsuransi").prop('checked', false);
                $("#chkAutoRedemp").prop('checked', false);
                var today = new Date();
                $("#dtRDBJatuhTempo").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());
                $("#dtpStartDate").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());
                $("#dtpEndDate").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());

                $("#srcClient_text1").val('');
                $("#srcClient_text2").val('');
                $("#MoneyBlokir").data("kendoNumericTextBox").value(0);
                $("#MoneyTotal").data("kendoNumericTextBox").value(0);
                $("#OutsUnit").data("kendoNumericTextBox").value(0);

                $("#dgvBlokir").data('kendoGrid').dataSource.data([]);
                $("#dtpExpiry").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());
                $("#dtpTglTran").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());

                var resVal = ValidateRiskProfile($("#srcCIF_text1").val(), $("#dtpRiskProfile").val());
                resVal.success(function (data) {
                    if (data.blnResult) {
                        var dtExpiredRiskProfile = new Date(data.dtExprRiskProfile);
                        $("#dtExpiredRiskProfile").val(pad((dtExpiredRiskProfile.getDate()), 2) + '/' + pad((dtExpiredRiskProfile.getMonth() + 1), 2) + '/' + dtExpiredRiskProfile.getFullYear());
                        $("#txtEmail").val(data.strEmail);
                    }
                    else {
                        $("#txtEmail").val();
                    }
                });
            },
            complete: function () {
                $("#load_screen").hide();
            }
        });
    }
    if ((_strTabName == "MCI") || (_strTabName == "MCA")) {
        $.ajax({
            type: 'GET',
            url: '/Customer/ReksaGetListClient',
            data: { CIFNo: CIFNo },
            
            success: function (data) {
                if (data.blnResult) {
                    var dataSource = new kendo.data.DataSource(
                        {
                            data: data.listClientModel
                        });
                    var dgvClientCode = $('#dgvClientCode').data('kendoGrid');
                    dgvClientCode.setDataSource(dataSource);
                    dgvClientCode.dataSource.pageSize(15);
                    dgvClientCode.dataSource.page(1);
                    dgvClientCode.select("tr:eq(0)");

                    subResetToolbar();
                    if (intClassificationId == 118) { }
                }
            }
        });
    }
    if (_strTabName == "MCB") {
        ReksaRefreshBlokir();
    }
    
}
function subNew()
{
    var urlSearchCIF = "/Global/SearchCIF";
    $('#srcCIF').attr('href', urlSearchCIF);
    _intType = 1;
    subClearAll();
    subDisableAll(_intType);
    subResetToolbar();
    $("#lblStatus").text("NEW");
    $("#dtpTglTran").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpExpiry").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpRiskProfile").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtExpiredRiskProfile").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtRDBJatuhTempo").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpStartDate").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpEndDate").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpTglNPWPSendiri").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpTglNPWPKK").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpTglDokTanpaNPWP").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpTglLahir").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpJoinDate").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    
    _intId = 0;
    ValidasiKodeKantor($("#srcOffice_text1").val(), function (output) {
        if (output) {
            ValidateOffice($("#srcOffice_text1").val(), function (res) {
                $("#srcOffice_text2").val(res);
                SetEnableOfficeId($("#srcOffice_text1").val());
            });
        }
    });
}
function subSave() {
    var selectedId = 0;

    //string strErrorMessage = "", strIsAllowed = "";
    //if (clsValidator.ValidasiUserCBO(ClQ, cmpsrKodeKantor.Text1, strBranch, out strIsAllowed, out strErrorMessage)) {
    //    if (strIsAllowed == "0") {
    //        MessageBox.Show("Error [ReksaValidateUserCBOOffice], " + strErrorMessage, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
    //        return;
    //    }
    //}
    //else {
    //    MessageBox.Show("Error [ReksaValidateUserCBOOffice]!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
    //    return;
    //}

    if ($('#srcCIF_text1').val() == "") {
        swal("Warning", "No CIF harus diisi!", "warning");
        return;
    }
    if ($('#srcCIF_text2').val() == "") {
        swal("Warning", "Nama CIF harus diisi!", "warning");
        return;
    }
    //Identitas atau nasabah
    if ((_strTabName == "MCI") || (_strTabName == "MCN")) {
        if (_intType != 3) {
            if ($('#srcOffice_text1').val() == "") {
                swal("Warning", "Kode Kantor harus terisi!", "warning");
                return;
            }
            //if ($('#textShareHolderId').val() == "") {
            //    swal("Warning", "Shareholder ID harus terisi!", "warning");
            //    return;
            //}
            if (($('#maskedRekening').val() != "") && ($('#maskedRekeningMC').val() != "")) {
                swal("Warning", "Harap hanya mengisi salah satu, Rekening IDR atau Rekening Multicurrency saja!", "warning");
                return;
            }
            if (($('#maskedRekeningUSD').val() != "") && ($('#maskedRekeningMC').val() != "")) {
                swal("Warning", "Harap hanya mengisi salah satu, Rekening USD atau Rekening Multicurrency saja!", "warning");
                return;
            }
            if ($("#maskedRekening").val() != "") {
                GetAccountRelationDetail($("#maskedRekening").val(), 1, function (output) {
                    if (!output) {
                        return;
                    }
                });
                if ($("#maskedRekening").val() == "") {
                    swal("Warning", "Nomor rekening salah!", "warning");
                    return;
                }
            }
            if ($("#maskedRekeningUSD").val() != "") {
                GetAccountRelationDetail($("#maskedRekeningUSD").val(), 3, function (output) {
                    if (!output) {
                        return;
                    }
                });
                if ($("#maskedRekeningUSD").val() == "") {
                    swal("Warning", "Nomor rekening salah!", "warning");
                    return;
                }
            }
            if ($("#maskedRekeningMC").val() != "") {
                GetAccountRelationDetail($("#maskedRekeningMC").val(), 4, function (output) {
                    if (!output) {
                        return;
                    }
                });
                if ($("#maskedRekeningMC").val() == "") {
                    swal("Warning", "Nomor rekening salah!", "warning");
                    return;
                }
            }
            if (($('#maskedRekening').val() != "") && ($('#maskedRekening').val().length < 12)) {
                swal("Warning", "Nomor rekening harus 12 digit!", "warning");
                return;
            }
            if (($('#maskedRekeningUSD').val() != "") && ($('#maskedRekeningUSD').val().length < 12)) {
                swal("Warning", "Nomor rekening harus 12 digit!", "warning");
                return;
            }
            if (($('#maskedRekeningMC').val() != "") && ($('#maskedRekeningMC').val().length < 12)) {
                swal("Warning", "Nomor rekening harus 12 digit!", "warning");
                return;
            }
            if (($('#tbNamaRekening').val() == "") && ($('#maskedRekening').val() != "")) {
                swal("Warning", "Nomor rekening IDR tidak terdaftar!", "warning");
                return;
            }
            if (($('#tbNamaRekeningUSD').val() == "") && ($('#maskedRekeningUSD').val() != "")) {
                swal("Warning", "Nomor rekening USD tidak terdaftar!", "warning");
                return;
            }
            if (($('#tbNamaRekeningMC').val() == "") && ($('#maskedRekeningMC').val() != "")) {
                swal("Warning", "Nomor rekening Multicurrency tidak terdaftar!", "warning");
                return;
            }
            if (($('#maskedRekening').val() != "") && ($('#tbNamaRekening').val() != $('#srcCIF_text2').val())) {

                swal({
                    title: "Apakah rekening IDR tersebut milik pemegang reksadana?",
                    text: "",
                    type: "warning",
                    showCancelButton: true,
                    confirmButtonClass: 'btn-warning',
                    confirmButtonText: "Yes",
                    cancelButtonText: "No",
                    closeOnConfirm: false,
                    closeOnCancel: false
                },
                    function (isConfirm) {
                        if (isConfirm) {
                            swal("Confirmed", "Rekening milik pemegang reksadana", "success");
                        }
                        else {
                            swal({ title: "Error", text: "Gagal Simpan Data", type: "error" });
                            return;
                        }
                    });

            }
            if (($('#maskedRekeningUSD').val() != "") && ($('#tbNamaRekeningUSD').val() != $('#srcCIF_text2').val())) {
                swal({
                    title: "Apakah rekening USD tersebut milik pemegang reksadana?",
                    text: "",
                    type: "warning",
                    showCancelButton: true,
                    confirmButtonClass: 'btn-warning',
                    confirmButtonText: "Yes",
                    cancelButtonText: "No",
                    closeOnConfirm: false
                },
                    function (isConfirm) {
                        if (isConfirm) {
                            swal("Confirmed", "Rekening milik pemegang reksadana", "success");
                        }
                        else {
                            swal({ title: "Error", text: "Gagal Simpan Data", type: "error" });
                        }
                    });
            }
            if (($('#maskedRekeningMC').val() != "") && ($('#tbNamaRekeningMC').val() != $('#srcCIF_text2').val())) {
                swal({
                    title: "Apakah rekening Multicurrency tersebut milik pemegang reksadana?",
                    text: "",
                    type: "warning",
                    showCancelButton: true,
                    confirmButtonClass: 'btn-warning',
                    confirmButtonText: "Yes",
                    cancelButtonText: "No",
                    closeOnConfirm: false,
                    closeOnCancel: false
                },
                    function (isConfirm) {
                        if (isConfirm) {
                            swal("Confirmed", "Rekening milik pemegang reksadana", "success");
                        }
                        else {
                            swal({ title: "Error", text: "Gagal Simpan Data", type: "error" });
                        }
                    });
            }
            if (($('#cbStatus').val() == 1) && ($("#srcEmployee_text1").val() == "")) {
                swal("Warning", "NIK karyawan tidak ditemukan!", "warning");
                return;
            }
            else if (($('#cbStatus').val() == 0) && ($("#srcEmployee_text1").val() != "")) {
                $("#srcEmployee_text1").val("");
                $("#srcEmployee_text2").val("")
            }
            if ($('#cbDikirimKe').val() == '') {
                swal("Warning", "Surat konfirmasi Dikirim Ke' harus dipilih!", "Warning");
                return;
            }
            if (($('#cbDikirimKe').val() == 1) && ($('#srcCabang_text1').val() == "")) {
                swal("Warning", "Kode kantor alamat surat harus diisi", "Warning");
                return;
            }

            var grid = $("#dgvKonfAddr").data("kendoGrid");
            grid.refresh();
            grid.tbody.find("tr[role='row']").each(function () {
                var dataItem = grid.dataItem(this);
                if (dataItem.Pilih == true) {
                    selectedId = selectedId + 1;
                }
            })
            if (selectedId == 0) {
                swal("Warning", "Wajib Memilih Alamat Konfirmasi terlebih dahulu!", "warning");
                return;
            }
            if (selectedId > 1) {
                swal("Warning", "Hanya diperbolehkan memilih 1 alamat konfirmasi!", "warning");
                return;
            }
            if ($('#cbProfilResiko').prop('checked') == false) {
                swal("Warning", "Kelengkapan Dokumen Kuesioner Risk Profile belum diisi", "warning");
                return;
            }
            if ($('#cbKetum').prop('checked') == false) {
                swal("Warning", "Kelengkapan Dokumen Ketentuan Umum Reksadana belum diisi", "warning");
                return;
            }
            if ($("#txtbRiskProfile").val() == "") {
                swal("Warning", "Data risk profile wajib ada. Mohon lengkapi dulu data Nasabah", "warning");
                return;
            }

            var resRisk = GetRiskProfileParam();
            resRisk.success(function (data) {
                if (data.blnResult) {
                    intMaxDay = data.intExpRiskProfileDay;
                    intMaxYear = data.intExpRiskProfileYear;
                }
                else {
                    swal("Warning", data.ErrMsg, "warning");
                }
            });

            //System.TimeSpan diff = _dtCurrentDate.Subtract(dtpRiskProfile.Value);
            //if (diff.Days >= intMaxDay || dtExpiredRiskProfile.Value <= _dtCurrentDate) {
            //    if (MessageBox.Show("No CIF : " + cmpsrCIF.Text1 + "\n\nTanggal Last Update Risk Profile : " + dtpRiskProfile.Value + "\n\nTanggal Last Update Risk Profile sudah lewat " + intMaxYear + " tahun \n\n Last Update Risk Profile telah lebih dari " + intMaxYear + " tahun, \n Apakah Risk Profile Nasabah Berubah ?", "Warning", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            //    {
            //        MessageBox.Show("No CIF : " + cmpsrCIF.Text1 + "\n\nTanggal Last Update Risk Profile : " + dtpRiskProfile.Value + "\n\nTanggal Last Update Risk Profile sudah lewat " + intMaxYear + " tahun \n\n Last Update Risk Profile telah lebih dari " + intMaxYear + " tahun, \n Apakah Risk Profile Nasabah Berubah ?", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            //        MessageBox.Show("Gagal Simpan Data", "Error");
            //        return;
            //    }
            //    else {
            //        dtpRiskProfile.Value = System.Convert.ToDateTime(ProReksa2.Global.strCurrentDate.ToString());
            //    }
            //}                
        }
        var intStatus;
        if ($('#cbStatus').val() == 0) {
            intStatus = 1;
        }
        else {
            intStatus = 0;
        }

        var NIKEmployee;
        if ($('#srcEmployee_text1').val().trim() == "") {
            NIKEmployee = 0;
        }
        else {
            NIKEmployee = $('#srcEmployee_text1').val();
        }
        var NasabahId;
        if ((_intType == 2) || (_intType == 3)) {
            NasabahId = $('#idNasabah').val();
        }
        else {
            NasabahId = 0;
        }

        var arrHeader = [];
        var obj = {};
        obj['Type'] = '1';
        obj['CIFNo'] = $("#srcCIF_text1").val();
        obj['DataType'] = $("#cbDikirimKe").val();
        obj['Branch'] = $("#srcOffice_text1").val();
        arrHeader.push(obj);

        var grid = $("#dgvKonfAddr").data("kendoGrid");
        grid.refresh();
        var SelectedId = "";
        grid.tbody.find("tr[role='row']").each(function () {
            var dataItem = grid.dataItem(this);

            if (dataItem.Pilih == true) {
                SelectedId += dataItem.Sequence + "|";
            }
        })
        var dtpTglLahir = toDate($("#dtpTglLahir").val());
        var dtpJoinDate = toDate($("#dtpJoinDate").val());

        var dtpTglNPWPKK = toDate($("#dtpTglNPWPKK").val());
        var dtpTglDokTanpaNPWP = toDate($("#dtpTglDokTanpaNPWP").val());
        var dtpRiskProfile = toDate($("#dtpRiskProfile").val());

        SubSaveRiskProfile();
        var model = JSON.stringify({
            'Type': _intType,
            'CIFNo': $("#srcCIF_text1").val(),
            'CIFName': $("#srcCIF_text2").val(),
            'OfficeId': $("#srcOffice_text1").val(),
            'CIFType': _intJnsNas,
            'ShareholderID': $("#textShareHolderId").val(),
            'CIFBirthPlace': $("#tbTmptLahir").val(),
            'CIFBirthDay': dtpTglLahir,
            'JoinDate': dtpJoinDate,
            'IsEmployee': intStatus,
            'CIFNIK': NIKEmployee,
            'AccountId': $("#maskedRekening").val(),
            'AccountName': $("#tbNamaRekening").val(),
            'isRiskProfile': $("#cbProfilResiko").prop('checked'),
            'isTermCondition': $("#cbKetum").prop('checked'),
            'RiskProfileLastUpdate': dtpRiskProfile,
            'NoNPWPKK': $("#tbNoNPWPKK").val(),
            'NamaNPWPKK': $("#tbNamaNPWPKK").val(),
            'KepemilikanNPWPKK': $("#cbKepemilikanNPWPKK").val(),
            'KepemilikanNPWPKKLainnya': $("#tbKepemilikanLainnya").val(),
            'TglNPWPKK': dtpTglNPWPKK,
            'AlasanTanpaNPWP': $("#cbAlasanTanpaNPWP").val(),
            'NoDokTanpaNPWP': $("#tbNoDokTanpaNPWP").val(),
            'TglDokTanpaNPWP': dtpTglDokTanpaNPWP,
            'NoNPWPProCIF': $("#tbNoNPWPSendiri").val(),
            'NamaNPWPProCIF': $("#tbNamaNPWPSendiri").val(),
            'NasabahId': NasabahId,
            'AccountIdUSD': $("#maskedRekeningUSD").val(),
            'tbNamaRekeningUSD': $("#tbNamaRekeningUSD").val(),
            'AccountIdMC': $("#maskedRekeningMC").val(),
            'AccountNameMC': $("#tbNamaRekeningMC").val(),
            'SelectedId': SelectedId,
            'HeaderAddress': arrHeader
        });

        $.ajax({
            type: "POST",
            data: model,
            url: '/Customer/MaintainNasabah',
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            beforeSend: function () {
                $("#load_screen").show();
            }, 
            success: function (data) {
                if (data.blnResult == true) {
                    swal("Success!", "Your data need to approve by supervisor", "success");
                    _intType = 0;
                    subDisableAll(_intType);
                    GetComponentSearch();
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
                                    var Errorgrid = $('#GridError').data('kendoGrid');
                                    Errorgrid.setDataSource(dataSource);
                                    Errorgrid.dataSource.pageSize(10);
                                    Errorgrid.select("tr:eq(0)");
                                    $('#ErrorSubsModal').modal('toggle');
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
    //blokir
    else if (_strTabName == "MCB") {
        if ($("#srcClient_text1").val() == "") {
            swal("Warning", "Client Code Harus Diisi!", "warning");
            return;
        }
        if ($("#MoneyBlokir").val() == 0 || $("#MoneyBlokir").val() == "") {
            swal("Warning", "Besar Blokir Harus Diisi", "warning");
            return;
        }
        if (($("#dtpExpiry").val() <= $("#dtpTglTran").val()) && (_intType != 3)) {
            swal("Warning", "Tanggal Expiry harus > Tanggal Hari ini", "warning");
            return;
        }
        var BlockId;
        if (_intType == 3) {
            BlockId = $("#BlokirId").val();
        } else {
            BlockId = 0;
        }
        var dtpExpiry = toDate($("#dtpExpiry").val());
        var dtpTglTran = toDate($("#dtpTglTran").val());
        var model = JSON.stringify({
            'ClientId': $("#BlokirClientId").val(),
            'BlockId': BlockId,
            'UnitBlokir': $("#MoneyBlokir").data("kendoNumericTextBox").value(),
            'TanggalExpiryBlokir': dtpExpiry,
            'TanggalBlokir': dtpTglTran,
            'intType': _intType
        });
        $.ajax({
            type: "POST",
            data: model,
            url: '/Customer/MaintainBlokir',
            contentType: "application/json",
            
            success: function (data) {
                if (data.blnResult == true) {
                    swal("Maintain Blokir Berhasil!", "Your data need to approve by supervisor", "success");
                    _intType = 0;
                    subDisableAll(_intType);
                    subRefresh();
                    subResetToolbar();
                }
                else {
                    swal("Error MaintainBlokir", data.strErrMsg, "error");
                }
            }
        });
    }
    //aktifitas
    else if (_strTabName == "MCA") {
        $.ajax({
            type: "POST",
            data: model,
            url: '/Customer/FlagClientId',
            contentType: "application/json",
            
            success: function (data) {
                if (data.blnResult == true) {
                    swal("Maintain Blokir Berhasil!", "Your data need to approve by supervisor", "success");
                    _intType = 0;
                    subDisableAll(_intType);
                    subRefresh();
                    subResetToolbar();
                }
                else {
                    swal("Error MaintainBlokir", data.strErrMsg, "error");
                }
            }
        });
    }
}

function subSaveIdentitas()
{

}

function subSaveFlag(ClientId, Flag) {
    $.ajax({
        type: 'POST',
        url: '/Customer/FlagClientId',
        data: { ClientId: ClientId, Flag: Flag },
        success: function (data) {
            if (data.blnResult) {
                swal("Proses berhasil", "Client code akan diflag jika sudah diotorisasi", "success");
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}
function subDisableAll(intType) {
    var CIFBirthDay = $("#dtpTglLahir").data("kendoDatePicker");
    var CreateDate = $("#dtpJoinDate").data("kendoDatePicker");
    if (intType == 0) {
        $("#srcCIF_text1").prop('disabled', true);
        $("#srcCIF").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcOffice_text1").prop('disabled', true);
        $("#srcOffice").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#txtJenisNasabah").prop('disabled', true);
        $("#textSubSegment").prop('disabled', true);
        $("#textSegment").prop('disabled', true);
        $("#textSID").prop('disabled', true);
        $("#textShareHolderId").prop('disabled', true);
        document.getElementById("btnShareHolder").disabled = true;
        $("#tbNama").prop('disabled', true);
        $("#tbTmptLahir").prop('disabled', true);
        CIFBirthDay.enable(false);
        CreateDate.enable(false);
        $("#tbKTP").prop('disabled', true);
        $("#maskedRekening").prop('disabled', true);
        $("#tbNamaRekening").prop('disabled', true);
        $("#cbKetum").prop('disabled', true);
        $("#maskedRekeningUSD").prop('disabled', true);
        $("#tbNamaRekeningUSD").prop('disabled', true);
        $("#maskedRekeningMC").prop('disabled', true);
        $("#tbNamaRekeningMC").prop('disabled', true);
        $("#cbStatus").data('kendoDropDownList').enable(false);
        $("#srcEmployee_text1").prop('disabled', true);
        $("#srcEmployee").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#cbProfilResiko").prop('disabled', true);
        $("#dtpRiskProfile").prop('disabled', true);
        $("#checkPhoneOrder").prop('disabled', true);
        $("#chkAutoRedemp").prop('disabled', true);
        $("#chkRDBAsuransi").prop('disabled', true);
        $("#cbDikirimKe").data('kendoDropDownList').enable(false);
        $("#srcCabang_text1").prop('disabled', true);
        $("#searchOfficeCabang").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#srcClient_text1").prop('disabled', true);
        $("#srcClient").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#MoneyBlokir").data("kendoNumericTextBox").enable(false);
        $("#MoneyTotal").data("kendoNumericTextBox").enable(false);
        $("#OutsUnit").data("kendoNumericTextBox").enable(false);
        $("#dtpExpiry").prop('disabled', true);
        $("#dtpTglTran").prop('disabled', true);
        $("#tbNoNPWPSendiri").prop('disabled', true);
        $("#tbNamaNPWPSendiri").prop('disabled', true);
        $("#dtpTglNPWPSendiri").prop('disabled', true);
        $("#tbNoNPWPKK").prop('disabled', true);
        $("#tbNamaNPWPKK").prop('disabled', true);
        $("#cbKepemilikanNPWPKK").data('kendoDropDownList').enable(false);
        $("#tbKepemilikanLainnya").prop('disabled', true);
        $("#dtpTglNPWPKK").prop('disabled', true);
        $("#cbAlasanTanpaNPWP").data('kendoDropDownList').enable(false);
        $("#tbNoDokTanpaNPWP").prop('disabled', true);
        $("#dtpTglDokTanpaNPWP").prop('disabled', true);
        document.getElementById("btnGenerateNoDokTanpaNPWP").disabled = true;
        document.getElementById("btnGantiOpsiNPWP").disabled = true;
    }
    else if (intType == 1) {

        $("#srcOffice_text1").prop('disabled', true);
        $("#srcOffice").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#txtJenisNasabah").prop('disabled', true);
        $("#textSubSegment").prop('disabled', true);
        $("#textSegment").prop('disabled', true);
        $("#textSID").prop('disabled', true);
        $("#textShareHolderId").prop('disabled', true);
        document.getElementById("btnShareHolder").disabled = true;
        $("#tbNama").prop('disabled', true);
        $("#tbTmptLahir").prop('disabled', true);
        $("#dtpTglLahir").prop('disabled', true);
        $("#tbKTP").prop('disabled', true);
        $("#dtpJoinDate").prop('disabled', true);
        $("#maskedRekening").prop('disabled', false);
        $("#tbNamaRekening").prop('disabled', false);
        $("#cbKetum").prop('disabled', true);
        $("#maskedRekeningUSD").prop('disabled', false);
        $("#tbNamaRekeningUSD").prop('disabled', true);
        $("#maskedRekeningMC").prop('disabled', false);
        $("#tbNamaRekeningMC").prop('disabled', true);
        $("#cbStatus").data('kendoDropDownList').enable(true);
        $("#srcEmployee_text1").prop('disabled', true);
        $("#srcEmployee").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#cbProfilResiko").prop('disabled', false);
        $("#dtpRiskProfile").prop('disabled', true);
        $("#checkPhoneOrder").prop('disabled', true);
        $("#chkAutoRedemp").prop('disabled', true);
        $("#chkRDBAsuransi").prop('disabled', true);
        $("#cbDikirimKe").data('kendoDropDownList').enable(true);
        $("#srcCabang_text1").prop('disabled', false);
        $("#searchOfficeCabang").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#srcClient_text1").prop('disabled', true);
        $("#srcClient").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#MoneyBlokir").data("kendoNumericTextBox").enable(false);
        $("#MoneyTotal").data("kendoNumericTextBox").enable(false);
        $("#OutsUnit").data("kendoNumericTextBox").enable(false);
        $("#dtpExpiry").prop('disabled', true);
        $("#dtpTglTran").prop('disabled', true);
        $("#tbNoNPWPSendiri").prop('disabled', true);
        $("#tbNamaNPWPSendiri").prop('disabled', true);
        $("#dtpTglNPWPSendiri").prop('disabled', true);
        $("#tbNoNPWPKK").prop('disabled', true);
        $("#tbNamaNPWPKK").prop('disabled', true);
        $("#cbKepemilikanNPWPKK").data('kendoDropDownList').enable(false);
        $("#tbKepemilikanLainnya").prop('disabled', true);
        $("#dtpTglNPWPKK").prop('disabled', true);
        $("#cbAlasanTanpaNPWP").data('kendoDropDownList').enable(false);
        $("#tbNoDokTanpaNPWP").prop('disabled', true);
        $("#dtpTglDokTanpaNPWP").prop('disabled', true);
        document.getElementById("btnGenerateNoDokTanpaNPWP").disabled = true;
        document.getElementById("btnGantiOpsiNPWP").disabled = true;
    }
    $('#divAlamatNasabah').hide();
    $('#divAlamatCabang').hide();
}
function subClearAll() {
    //IDENTITAS
    $("#lblStatus").text("");
    $("#srcCIF_text1").val("");
    $("#srcCIF_text2").val("");
    $("#tbNama").val("");
    $("#txtJenisNasabah").val("");
    $("#textSegment").val("");
    $("#textSubSegment").val("");
    $("#textSID").val("");
    $("#textShareHolderId").val("");
    $("#tbTmptLahir").val("");
    $("#dtpTglLahir").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#tbKTP").val("");
    $("#tbHP").val("");
    $("#txtEmail").val("");
    $("#dtpJoinDate").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#maskedRekening").val("");
    $("#tbNamaRekening").val("");
    $("#maskedRekeningUSD").val("");
    $("#tbNamaRekeningUSD").val("");
    $("#maskedRekeningMC").val("");
    $("#tbNamaRekeningMC").val("");
    $("#cbStatus").data('kendoDropDownList').value("0");
    $("#srcEmployee_text1").val("");
    $("#srcEmployee_text2").val("");
    $("#txtbRiskProfile").val("");
    $("#dtpRiskProfile").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtExpiredRiskProfile").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $('#cbProfilResiko').prop('checked', false);
    $('#cbKetum').prop('checked', false);
    $("#cbDikirimKe").data('kendoDropDownList').value("0");
    onBoundAddressType();
    onChangeAddressType();
    $("#dgvKonfAddr").data('kendoGrid').dataSource.data([]);
    $("#srcCabang_text1").val("");
    $("#srcCabang_text2").val("");
    $("#tbAlamatSaatIni1").val("");
    $("#tbAlamatSaatIni2").val("");
    $("#tbKodePos").val("");
    $("#tbKotaNasabahAlmt").val("");
    $("#tbProvNasabahAlmt").val("");
    //$("#txtLastUpdated").val("");
    $("#txtLastUpdated").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());


    //AKTIFITAS
    $("#dgvClientCode").data('kendoGrid').dataSource.data([]);
    $("#dgvAktifitas").data('kendoGrid').dataSource.data([]);
    $("#txtRDBJangkaWaktu").val("");
    $("#dtRDBJatuhTempo").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#textFrekPendebetan").val("");
    $("#dtpStartDate").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpEndDate").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $('#chkAutoRedemp').prop('checked', false);
    $('#chkRDBAsuransi').prop('checked', false);

    //NPWP
    $("#tbNoNPWPSendiri").val("");
    $("#tbNamaNPWPSendiri").val("");
    $("#dtpTglNPWPSendiri").val("");
    $("#tbNoNPWPKK").val("");
    $("#tbNamaNPWPKK").val("");
    $("#cbKepemilikanNPWPKK").data('kendoDropDownList').value(0);
    $("#tbKepemilikanLainnya").val("");
    $("#dtpTglNPWPKK").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#cbAlasanTanpaNPWP").data('kendoDropDownList').value(0);
    $("#tbNoDokTanpaNPWP").val("");
    $("#dtpTglDokTanpaNPWP").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    subClearBlokir();
}
function ReksaRefreshBlokir() {
    var ClientId = $("#BlokirClientId").val();
    $.ajax({
        type: 'GET',
        url: '/Customer/RefreshBlokir',
        data: { ClientId: ClientId },
        
        success: function (data) {
            if (data.blnResult) {
                if (data.listCLientBlokir.length != 0) {
                    var dataSource = new kendo.data.DataSource(
                        {
                            data: data.listCLientBlokir
                        });
                    var dgvBlokir = $('#dgvBlokir').data('kendoGrid');
                    dgvBlokir.setDataSource(dataSource);
                    dgvBlokir.dataSource.pageSize(5);
                    dgvBlokir.dataSource.page(1);
                    dgvBlokir.select("tr:eq(0)");
                } else {
                    $("#dgvBlokir").data('kendoGrid').dataSource.data([]);
                }
                $("#OutsUnit").data("kendoNumericTextBox").value(data.decOutstandingUnit);
                $("#MoneyTotal").data("kendoNumericTextBox").value(data.decTotal);
                subResetToolbar();
            }
        }
    });
}
function subClearBlokir() {
    $("#srcClient_text1").val("");
    $("#srcClient_text2").val("");
    $("#MoneyBlokir").data("kendoNumericTextBox").value(0);
    $("#OutsUnit").data("kendoNumericTextBox").value(0);
    $("#MoneyTotal").data("kendoNumericTextBox").value(0);
    $("#dtpTglTran").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dtpExpiry").val(pad((_dtCurrentDate.getDate()), 2) + '/' + pad((_dtCurrentDate.getMonth() + 1), 2) + '/' + _dtCurrentDate.getFullYear());
    $("#dgvBlokir").data('kendoGrid').dataSource.data([]);
}
function ValidateRiskProfile(CIFNo, RiskProfile) {
    return $.ajax({
        type: 'GET',
        url: '/Customer/CekExpRiskProfile',
        data: { CIFNo: CIFNo, RiskProfile: RiskProfile },
        async: false
    });
}
function GetDataCIF(CIFNo, _intType) {
    var NPWP = '';
    $.ajax({
        type: 'GET',
        url: '/Customer/GetCIFData',
        data: { CIFNo: CIFNo, NPWP: NPWP },
        beforeSend: function () {
            $("#load_screen").show();
        }, 
        success: function (data) {
            if (data.blnResult) {
                _intJnsNas = data.CIFData[0].intJnsNas;
                if (data.CIFData[0].JnsNas == 1) {
                    $("#txtJenisNasabah").val('INDIVIDUAL');
                }
                else if (data.CIFData[0].JnsNas == 4) {
                    $("#txtJenisNasabah").val('CORPORATE');
                }
                $("#textShareHolderId").val(data.CIFData[0].ShareholderID);
                if ((_intType == 1) && ($("#textShareHolderId").val() == "")) {
                    document.getElementById("btnShareHolder").disabled = false;
                }
                else {
                    document.getElementById("btnShareHolder").disabled = true;
                }
                $("#tbTmptLahir").val(data.CIFData[0].TempatLhr);
                var dtpTglLahir = new Date(data.CIFData[0].TglLhr);
                $("#dtpTglLahir").val(pad((dtpTglLahir.getDate()), 2) + '/' + pad((dtpTglLahir.getMonth() + 1), 2) + '/' + dtpTglLahir.getFullYear());
                $("#tbKTP").val(data.CIFData[0].KTP);
                $("#tbHP").val(data.CIFData[0].HP);
                $("#textSID").val(data.CIFData[0].CIFSID);
                $("#textSubSegment").val(data.CIFData[0].SubSegment);
                $("#textSegment").val(data.CIFData[0].Segment);
                var dtpJoinDate = new Date();
                $("#dtpJoinDate").val(pad((dtpJoinDate.getDate()), 2) + '/' + pad((dtpJoinDate.getMonth() + 1), 2) + '/' + dtpJoinDate.getFullYear());

                //PhoneOrder
                //checkPhoneOrder.Checked = GlobalFunctionCIF.CekCIFProductFacility(CIFNo);
                GetDocStatus(CIFNo, _intType);
                GetRiskProfile(CIFNo);
                if (_intType == 1) {
                    $("#tbNama").prop('disabled', true);
                    $("#tbNama").val(data.CIFData[0].CIFName);
                    if (data.CIFData[0].WarnMsg != "") {
                        swal("Warning", data.CIFData.WarnMsg, "warning");
                    }
                    var res = GetKonfAddress(CIFNo);
                    res.success(function (data) {
                        if (data.blnResult) {
                            $("#cbDikirimKe").data('kendoDropDownList').value(data.intAddressType);
                            onBoundAddressType();
                            onChangeAddressType();
                            if (data.listKonfAddrees.length != 0) {
                                var dataSource = new kendo.data.DataSource(
                                    {
                                        data: data.listKonfAddrees
                                    });
                                var Addressgrid = $('#dgvKonfAddr').data('kendoGrid');
                                Addressgrid.setDataSource(dataSource);
                                Addressgrid.dataSource.pageSize(15);
                                Addressgrid.dataSource.page(1);
                                Addressgrid.select("tr:eq(0)");
                                if (_intType == 0) {
                                    Addressgrid.hideColumn('Pilih');
                                }
                                else {
                                    Addressgrid.showColumn('Pilih');
                                }
                            }
                            else {
                                $("#dgvKonfAddr").data('kendoGrid').dataSource.data([]);
                            }

                            if (data.listBranchAddress != null) {
                                $("#srcCabang_text1").val(data.listBranchAddress.Branch);
                                ValidateOffice($("#srcCabang_text1").val(), function (output) { $("#srcCabang_text2").val(output); });
                                $("#tbAlamatSaatIni1").val(data.listBranchAddress.AddressLine1);
                                $("#tbAlamatSaatIni2").val(data.listBranchAddress.AddressLine2);
                                $("#tbKodePos").val(data.listBranchAddress.PostalCode);
                                $("#tbKotaNasabahAlmt").val(data.listBranchAddress.Kota);
                                $("#tbProvNasabahAlmt").val(data.listBranchAddress.Province);
                                var LastUpdatedDate = new Date(data.listBranchAddress.LastUpdatedDate);
                                $("#txtLastUpdated").val(pad((LastUpdatedDate.getDate()), 2) + '/' + pad((LastUpdatedDate.getMonth() + 1), 2) + '/' + LastUpdatedDate.getFullYear());
                            }
                        }
                        else {
                            swal("Warning", "Gagal Ambil Data Alamat Konfirmasi!", "warning");
                        }
                    });
                }
                document.getElementById("btnGantiOpsiNPWP").disabled = false;
                _intValidationNPWP = 1;
                _intOpsiNPWP = 1;

                $("#tbNoNPWPSendiri").val(data.CIFData[0].NPWP);
                $("#tbNamaNPWPSendiri").val(data.CIFData[0].NamaNPWP);
                var dtpTglNPWPSendiri = new Date(data.CIFData[0].TglNPWP);
                $("#dtpTglNPWPSendiri").val(pad((dtpTglNPWPSendiri.getDate()), 2) + '/' + pad((dtpTglNPWPSendiri.getMonth() + 1), 2) + '/' + dtpTglNPWPSendiri.getFullYear());

                $("#tbNoNPWPKK").val('');
                $("#tbNamaNPWPKK").val('');
                $("#tbKepemilikanLainnya").val('');
                var today = new Date();
                $("#dtpTglNPWPKK").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());
                $("#dtpTglDokTanpaNPWP").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());

                //cbAlasanTanpaNPWP.SelectedIndex = -1;
                $("#tbNoDokTanpaNPWP").val('');
                EnableFieldNPWP(1);
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
                subClearAll();
            }
        }
        ,
        complete: function () {
            $("#load_screen").hide();
        }
    });

}
function EnableFieldNPWP(intOpsi) {
    switch (intOpsi) {
        case 1:
            $("#tbNoNPWPKK").prop('disabled', true);
            $("#tbNamaNPWPKK").prop('disabled', true);
            $("#cbKepemilikanNPWPKK").data('kendoDropDownList').enable(false);
            $("#tbKepemilikanLainnya").prop('disabled', true);
            $("#dtpTglNPWPKK").prop('disabled', true);
            $("#cbAlasanTanpaNPWP").data('kendoDropDownList').enable(false);
            document.getElementById("btnGenerateNoDokTanpaNPWP").disabled = true;
            break;
        case 2:
            $("#tbNoNPWPKK").prop('disabled', false);
            $("#tbNamaNPWPKK").prop('disabled', false);
            $("#cbKepemilikanNPWPKK").data('kendoDropDownList').enable(true);
            $("#tbKepemilikanLainnya").prop('disabled', true);
            $("#dtpTglNPWPKK").prop('disabled', false);
            $("#cbAlasanTanpaNPWP").data('kendoDropDownList').enable(false);
            document.getElementById("btnGenerateNoDokTanpaNPWP").disabled = true;
            break;
        case 3:
            $("#tbNoNPWPKK").prop('disabled', true);
            $("#tbNamaNPWPKK").prop('disabled', true);
            $("#cbKepemilikanNPWPKK").data('kendoDropDownList').enable(false);
            $("#tbKepemilikanLainnya").prop('disabled', true);
            $("#dtpTglNPWPKK").prop('disabled', true);
            $("#cbAlasanTanpaNPWP").data('kendoDropDownList').enable(true);
            document.getElementById("btnGenerateNoDokTanpaNPWP").disabled = false;
            var dateDokTanpaNPWP = new Date();
            $("#dtpTglDokTanpaNPWP").val(pad((dateDokTanpaNPWP.getDate()), 2) + '/' + pad((dateDokTanpaNPWP.getMonth() + 1), 2) + '/' + dateDokTanpaNPWP.getFullYear());

            break;
    }
}
function GetKonfAddress(CIFNo) {
    return $.ajax({
        type: 'GET',
        url: '/Customer/GetKonfAddress',
        data: { CIFNo: CIFNo, KodeKantor: $('#srcOffice_text1').val() },
        async: false
    });
}
function GetRiskProfile(CIFNo) {
    $.ajax({
        type: 'GET',
        url: '/Customer/GetRiskProfile',
        data: { CIFNo: CIFNo },
        
        success: function (data) {
            if (data.blnResult) {
                $('#txtbRiskProfile').val(data.RiskProfile);
                var dtpRiskProfile = new Date(data.LastUpdate);
                $("#dtpRiskProfile").val(pad((dtpRiskProfile.getDate()), 2) + '/' + pad((dtpRiskProfile.getMonth() + 1), 2) + '/' + dtpRiskProfile.getFullYear());

                onChangedtpRiskProfile();
            }
            else {
                if ($('#txtbRiskProfile').val() == "") {
                    swal("Warning", "Data risk profile belum ada", "warning");
                }
            }
        }
    });
}
function GetDocStatus(CIFNo, _intType) {
    $.ajax({
        type: 'GET',
        url: '/Customer/GetDocStatus',
        data: { CIFNo: CIFNo },
        
        success: function (data) {
            if (data.blnResult) {
                $('#cbProfilResiko').prop('checked', data.blnDocRiskProfile);
                $('#cbKetum').prop('checked', data.blnDocTermCond);
                if (_intType != 0) {
                    cekCheckbox();
                }
            }
            else {
                swal("Error GetDocStatus", data.ErrMsg, "error");
            }
        }
    });
}
function cekCheckbox() {

    if ($('#cbKetum').prop('checked') == true) {
        $("#cbKetum").prop('disabled', true);
    }
    else {
        $('#cbKetum').prop('disabled', false);
    }

    if ($('#cbProfilResiko').prop('checked') == true) {
        $("#txtbRiskProfile").prop('disabled', true);
    }
    else {
        $("#txtbRiskProfile").prop('disabled', false);
    }
}
function subCancel() {
    _intType = 0;
    subClearAll();
    subDisableAll(_intType);
    subResetToolbar();
    GetComponentSearch();
    //cmpsrKodeKantor.Text1 = strBranch; //Reset Kode Kantor    
}
function GetAccountRelationDetail(AccountNum, Type, result) {
    $.ajax({
        type: 'GET',
        url: '/Customer/GetAccountRelationDetail',
        data: { AccountNum: AccountNum, Type: Type },
        
        success: function (data) {
            if (data.blnResult) {
                if (Type == 1) {
                    if (data.NoRek != "") {
                        $('#maskedRekening').val(data.NoRek);
                        $('#tbNamaRekening').val(data.Nama);
                        result(true);
                    }
                    else {
                        swal("Warning", "No rekening tidak ditemukan!", "warning");
                        result(false);
                    }
                }
                else if (Type == 3) {
                    if (data.NoRek != "") {
                        $('#maskedRekeningUSD').val(data.NoRek);
                        $('#tbNamaRekeningUSD').val(data.Nama);
                        result(true);
                    }
                    else {
                        swal("Warning", "No rekening USD tidak ditemukan!", "warning");
                        result(false);
                    }
                }
                else if (Type == 4) {
                    if (data.NoRek != "") {
                        $('#maskedRekeningMC').val(data.NoRek);
                        $('#tbNamaRekeningMC').val(data.Nama);
                        result(true);
                    }
                    else {
                        swal("Warning", "No rekening Multicurrency tidak ditemukan!", "warning");
                        result(false);
                    }
                }
                else if (Type == 2) {
                    $('#srcEmployee_text1').val(data.NIK);
                    ValidateReferentor($("#srcEmployee_text1").val(), function (output) {
                        $("#srcEmployee_text2").val(output);
                    });
                    if ($('#srcEmployee_text1').val() == "") {
                        $('#srcEmployee_text1').val('');
                        $('#srcEmployee_text2').val('');
                    }
                    else {
                        $("#cbStatus").data('kendoDropDownList').value(0);
                    }
                    result(true);
                }
            }
            else {
                swal("Warning", "Error mengambil detail rekening!", "warning");
                result(false);
            }
        }
    });
}
function GetAlamatCabang() {
    var Cifno = $("#srcCIF_text1").val();
    var BranchId = $("#srcCabang_text1").val();
    var intId = $("#idNasabah").val();

    $.ajax({
        type: 'GET',
        url: '/Customer/GetAlamatCabang',
        data: { CIFNO: Cifno, Branch: BranchId, intId: _intId },
        
        success: function (data) {
            if (data.blnResult) {
                $("#tbAlamatSaatIni1").val(data.listBranchAddress[0].AddressLine1);
                $("#tbAlamatSaatIni2").val(data.listBranchAddress[0].AddressLine2);
                $("#tbKodePos").val(data.listBranchAddress[0].PostalCode);
                $("#tbKotaNasabahAlmt").val(data.listBranchAddress[0].Kota);
                $("#tbProvNasabahAlmt").val(data.listBranchAddress[0].Province);
                var LastUpdatedDate = new Date(data.listBranchAddress[0].LastUpdated);
                $("#txtLastUpdated").val(pad((LastUpdatedDate.getDate()), 2) + '/' + pad((LastUpdatedDate.getMonth() + 1), 2) + '/' + LastUpdatedDate.getFullYear());

            }
            else {
                swal("Warning", "Error mengambil alamat cabang", "warning");
            }
        }
    });
}
function ReksaPopulateAktifitas() {
    var dtStart = $("#dtpStartDate").val();
    var dtEnd = $("#dtpEndDate").val();
    $.ajax({
        type: "GET",
        url: "/Customer/PopulateAktivitas",
        data: { ClientId: intSelectedClient, StartDate: dtStart, EndDate: dtEnd, IsBalance: false, IsAktivitasOnly: false, isMFee: false },
        
        success: function (data) {
            if (data.blnResult) {
                if (data.listActivity.length != 0) {
                    var dataSource = new kendo.data.DataSource(
                        {
                            data: data.listActivity
                        });
                    var dgvAktifitas = $('#dgvAktifitas').data('kendoGrid');
                    dgvAktifitas.setDataSource(dataSource);
                    dgvAktifitas.dataSource.page(1);
                    dgvAktifitas.select("tr:eq(0)");
                }
                else {
                    $("#dgvAktifitas").data('kendoGrid').dataSource.data([]);
                }
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}
function SetEnableOfficeId(strKodeKantor) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidasiCBOKodeKantor',
        data: { OfficeId: strKodeKantor },
        
        success: function (data) {
            if (data.blnResult) {
                if (data.strIsEnable == '1') {
                    $("#srcOffice_text1").prop('disabled', false);
                    $("#srcOffice").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
                } else {
                    $("#srcOffice_text1").prop('disabled', true);
                    $("#srcOffice").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
                }
            }
            else {
                swal("Error ValidasiCBOKodeKantor", data.strErrMsg, "warning");
                result(false);
            }
        }
    });
}
function GetRiskProfileParam() {
    return $.ajax({
        type: 'GET',
        url: '/Customer/GetRiskProfileParam',
        async: false
    });
}
function SubSaveRiskProfile() {
    return $.ajax({
        type: 'POST',
        url: '/Customer/SaveExpRiskProfile',
        data: { RiskProfile: $("#dtpRiskProfile").val(), ExpRiskProfile: $("#dtExpiredRiskProfile").val(), CIFNo: $("#srcCIF_text1").val() },
        
        success: function (data) {

        }
    });
}
function GetDataRDB(ClientCode) {
    $.ajax({
        type: 'GET',
        url: '/Customer/GetListClientRDB',
        data: { ClientCode: ClientCode },
        
        success: function (data) {
            if (data.blnResult) {
                if (data.listClientRDB.length > 0) {
                    $("#txtRDBJangkaWaktu").data("kendoNumericTextBox").value(data.listClientRDB[0].JangkaWaktu);
                    var dtRDBJatuhTempo = new Date(data.listClientRDB[0].JatuhTempo);
                    $("#dtRDBJatuhTempo").val(pad((dtRDBJatuhTempo.getDate()), 2) + '/' + pad((dtRDBJatuhTempo.getMonth() + 1), 2) + '/' + dtRDBJatuhTempo.getFullYear());
                    $('#chkAutoRedemp').prop('checked', data.listClientRDB[0].AutoRedemption);
                    $('#chkRDBAsuransi').prop('checked', data.listClientRDB[0].Asuransi);
                    $("#textFrekPendebetan").data("kendoNumericTextBox").value(data.listClientRDB[0].FrekPendebetan);
                }
                else {
                    $("#txtRDBJangkaWaktu").data("kendoNumericTextBox").value(0);
                    $("#dtRDBJatuhTempo").val('');
                    $('#chkAutoRedemp').prop('checked', false);
                    $('#chkRDBAsuransi').prop('checked', false);
                    $("#textFrekPendebetan").data("kendoNumericTextBox").value(0);
                }
            }
            else {
                swal("Warning Detail RDB", data.ErrMsg, "warning");
            }
        }
    });
}
function GenerateSHDID() {
    $.ajax({
        type: "GET",
        url: "/Customer/GetShareHolderID",
        dataType: "json",
        
        success: function (data) {
            if (data.blnResult == true) {
                $("#textShareHolderId").val(data.ShareHolderID);
            } else {
                swal("Error", data.ErrMsg, "error");
            }
        }
    });
}

//Other Function
function pad(num, size) {
    var s = "000000000" + num;
    return s.substr(s.length - size);
}
function toDate(dateStr) {
    var [day, month, year] = dateStr.split("/")
    return new Date(year, month - 1, day)
}
function ValidateOffice(OfficeId, result) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateOffice',
        data: { Col1: OfficeId, Col2: '', Validate: 1 },
        
        success: function (data) {
            if (data.length != 0) {
                result(data[0].OfficeName);
            } else {
                result("");
            }
        },
        error: function (error) {
            result("");
        }
    });
}
function ValidateReferentor(ReferentorID, result) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateReferentor',
        data: { Col1: ReferentorID, Col2: '', Validate: 1 },
        
        success: function (data) {
            result(data[0].NAME);
        }
    });
}