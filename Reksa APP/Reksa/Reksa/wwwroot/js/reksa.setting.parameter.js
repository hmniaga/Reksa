var _intType;
var _strTreeInterface;
var _Id;
var _tanggalValuta;
var _LastSelectedNode = "";
var _LastSelectedNodeName = "";

$(document).ready(function load() {
    var grid = {
        height: 300
    };
    $("#dgvParam").kendoGrid(grid);
    $('#cmpsrSearch1').attr('href', '/Global/SearchGift');   
    $('#srcOffice').attr('href', '/Global/SearchOffice');
    $("#MoneyNominal").data("kendoNumericTextBox").wrapper.hide(); 

    document.getElementById('lblSP1').innerHTML = 'Kode';
    document.getElementById('lblSP2').innerHTML = 'Deskripsi';
    document.getElementById('lblSP4').innerHTML = 'Tanggal valuta';
    $('#lblOffice').attr('style', 'display:none;');
    $('#txtbSP1').prop('disabled', true);
    $('#txtbSP2').prop('disabled', true);
    $('#dtpSP').data("kendoDatePicker").enable(false);
    $("#cmpsrOffice_text1").prop('disabled', true);
    $("#srcOffice").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    $('#Office_div').attr('style', 'display:none;');
    document.getElementById('lblSP11').innerHTML = '';
    document.getElementById('lblSP12').innerHTML = '';
    document.getElementById('lblSP13').innerHTML = '';
    $('#txtbSP11').prop('disabled', true);
    $('#txtbSP11').attr('style', 'display:none;');
    $("#dtpSP12").data("kendoDatePicker").enable(false);
    $('dtpSP12_div').attr('style', 'display:none;');
    $("#dtpSP13").data("kendoDatePicker").enable(false);
    $('#dtpSP13_div').attr('style', 'display:none;');
    _intType = 0;
});

function trvSetupParameter_AfterSelect(e) {
    subResetToolBar();
    var dataItem = this.dataItem(e.node);
    _strTreeInterface = dataItem.id;    
    $('#lblSP11').text('');
    $('#lblSP12').text('');
    $('#lblSP13').text('');
    $('#txtbSP11').attr('style', 'display:none;');
    $('#dtpSP12_div').attr('style', 'display:none;');
    $('#dtpSP13_div').attr('style', 'display:none;');
    if (_intType == 1 || _intType == 2) {
        var message;
        if (_intType == 1)
            message = 'new';
        else
            message = 'edited';
        swal({
            title: "Confirmation",
            text: "Cancel This " + _LastSelectedNodeName + " " + message + " data ?",
            type: "info",
            showCancelButton: true,
            confirmButtonClass: 'btn-info',
            confirmButtonText: "Yes",
            cancelButtonText: "No"
        },
            function (isConfirm) {
                if (!isConfirm) {
                    var treeview = $("#trvSetupParameter").data("kendoTreeView");
                    var barDataItem = treeview.dataSource.get(_LastSelectedNode);
                    var bar = treeview.findByUid(barDataItem.uid);
                    treeview.select(bar);
                }
                else {
                    SelectNodes(dataItem.text);
                    subCancel();
                }
            });
    }
    else {
        SelectNodes(dataItem.text);
        subRefresh();
    }    
}

function SelectNodes(strTreeName) {
    _LastSelectedNode = _strTreeInterface;
    _LastSelectedNodeName = strTreeName;
    switch (_strTreeInterface) {
        case "PAR":
            LoadDefaultSettings();
            $('#lblSP1').text('Kode');
            $('#lblSP2').text('Deskripsi');
            $('#lblSP4').text('Tanggal valuta');
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            subClearAll();
            break;
        case "SFC":
            LoadDefaultSettings();
            $('#lblSP1').text('Kode Fund');
            $('#lblSP2').text('Deskripsi');
            $('#lblSP4').text('Tanggal valuta');
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            subClearAll();
            break;
        case "SAC":
            LoadDefaultSettings();
            $('#lblSP1').text('Kode Agen');
            $('#lblSP2').text('Deskripsi');
            $('#lblSP4').text('Tanggal valuta');
            $('#lblOffice').attr('style', '');
            $('#Office_div').attr('style', '');
            subClearAll();
            break;
        case "SBC":
            LoadDefaultSettings();
            $('#lblSP1').text('Kode Bank');
            $('#lblSP2').text('Deskripsi');
            $('#lblSP4').text('Tanggal valuta');
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            subClearAll();
            break;
        case "SNV":
            LoadDefaultSettings();
            $('#lblSP1').text('Kode');
            $("#txtbSP1").val("NAV");
            $('#lblSP2').text('NAV');
            $('#lblSP4').text('Tanggal valuta');
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            subClearAll();
            break;
        case "SDV":
            LoadDefaultSettings();
            $('#lblSP1').text('Kode');
            $("#txtbSP1").val("Deviden");
            $('#lblSP2').text('Deviden');
            $('#lblSP4').text('Tanggal valuta');
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            subClearAll();
            break;
        case "SKR":
            LoadDefaultSettings();
            $('#lblSP1').text('Kode');
            $("#txtbSP1").val("Kurs");
            $('#lblSP2').text('Kurs');
            $('#lblSP4').text('Tanggal valuta');
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            subClearAll();
            break;
        case "RDD":
            LoadDefaultSettings();
            $('#lblSP1').text('Kode');
            $("#txtbSP1").val("Schedule");
            $('#lblSP2').text('Deskripsi');
            $("#txtbSP2").val("Schedule Deviden");
            $('#lblSP4').text('Tanggal valuta');
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            subClearAll();
            break;
        case "GFP":
            LoadDefaultSettings();
            $('#lblSP1').text('Kode Gift');
            $('#lblSP2').text('Nominal');
            $('#lblSP11').text('Jk Wkt(bln)');
            $('#lblSP12').text('Tgl Efektif');
            $('#lblSP13').text('Tgl Expire');
            $('#txtbSP11').attr('style', 'display:block;');
            $('#dtpSP12_div').attr('style', 'block');
            $('#dtpSP13_div').attr('style', 'block');
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');

            $('#txtbSP1').attr('style', 'display:none;');
            $('#txtbSP2').attr('style', 'display:none;');
            $("#MoneyNominal").data("kendoNumericTextBox").wrapper.show();

            $('#cmpsrSearch1_div').attr('style', '');
            $('#cmpsrSearch1').attr('href', '/Global/SearchGift');
            subClearAll();
            break;
        default:
            LoadDefaultSettings();
            break;
    }
}

function LoadDefaultSettings() {
    $("#MoneyNominal").data("kendoNumericTextBox").wrapper.hide(); 
    $("#lblSP1").text('Kode');
    $("#lblSP2").text('Deskripsi');
    $("#lblSP4").text('Tanggal valuta');
    $('#lblOffice').prop('style', 'display:none;');
    $("#Office_div").prop('style', 'display:none;');
    $("#cmpsrSearch1_div").prop('style', 'display:none;');
    $("#txtbSP1").prop('style', 'display:block;width:270px;');
    $("#txtbSP2").prop('style', 'display:block;width:270px;');
    subClearAll();
}

function subClearAll() {
    $("#txtbSP1").val("");
    $("#txtbSP2").val("");
    $("#txtbSP11").val("");
    $("#cmpsrGift_text1").val("");
    $("#MoneyNominal").data("kendoNumericTextBox").value(0);
    $("#cmpsrOffice_text1").val("");
}

function subResetToolBar() {
    $("#btnRefresh").show();
    $("#btnNew").show();
    $("#btnEdit").show();
    $("#btnDelete").show();
    $("#btnSave").show();
    $("#btnCancel").show();
    if ((_intType == 0) || (_intType == 3)) {
        $("#btnRefresh").show();
        $("#btnNew").show();
        $("#btnEdit").show();
        $("#btnDelete").show();
        $("#btnSave").hide();
        $("#btnCancel").hide();
    }
    else if ((_intType == 1) || (_intType == 2)) {
        $("#btnRefresh").hide();
        $("#btnNew").hide();
        $("#btnEdit").hide();
        $("#btnDelete").hide();
        $("#btnSave").show();
        $("#btnCancel").show();
    }
}

function disableAll(intType) {
    if (intType == 1) {
        $("#txtbSP1").prop('disabled', false);
        $("#txtbSP2").prop('disabled', false);
        var datepicker = $("#dtpSP").data("kendoDatePicker");
        datepicker.enable(true);
    }
    else {
        $("#txtbSP1").prop('disabled', true);
        $("#txtbSP2").prop('disabled', true);
        var datepicker = $("#dtpSP").data("kendoDatePicker");
        datepicker.enable(false);
    }
}

function subRefresh() {
    var ProdId = $("#ProdId").val();
    if (ProdId == '') {
        document.getElementById("btnEdit").disabled = true;
        document.getElementById("btnDelete").disabled = true;
    }
    else {
        document.getElementById("btnEdit").disabled = false;
        document.getElementById("btnDelete").disabled = false;
    }
    if (ProdId == '') {
        swal("Warning", "Produk Harus Diisi", "warning");
        return;
    }
    $('#txtbSP1').prop('disabled', true);
    $('#txtbSP2').prop('disabled', true);
    $('#dtpSP').data("kendoDatePicker").enable(false);

    $("#cmpsrOffice_text1").prop('disabled', true);
    $("#srcOffice").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

    $("#cmpsrGift_text1").prop('disabled', true);
    $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    $("#MoneyNominal").data("kendoNumericTextBox").enable(false);

    $('#txtbSP11').prop('disabled', true);
    $('#dtpSP12').data("kendoDatePicker").enable(false);
    $('#dtpSP13').data("kendoDatePicker").enable(false);

    $.ajax({
        type: 'GET',
        url: '/Parameter/RefreshParam',
        data: { ProdukId: ProdId, InterfaceId: _strTreeInterface },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult)
            {
                var grid = $("#dgvParam").data("kendoGrid");
                var gridData = populateGrid(data.dsResult.table);
                grid.setOptions(gridData);
                grid.dataSource.pageSize(10);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");                

                grid.hideColumn('id');
                grid.hideColumn('prodId');
                grid.hideColumn('officeId');
                grid.hideColumn('desc2');
                grid.hideColumn('tglEfektif');
                grid.hideColumn('tglExpire');
                grid.hideColumn('desc5');
                grid.hideColumn('keterangan');
                grid.hideColumn('minSwitchRedempt');
                grid.hideColumn('jenisSwitchRedempt');
                grid.hideColumn('switchingFeeNonKaryawan');
                grid.hideColumn('switchingFeeKaryawan');

                $("#dgvParam th[data-field=kode]").html("Kode")
                $("#dgvParam th[data-field=deskripsi]").html("Deskripsi")
                $("#dgvParam th[data-field=officeId]").html("Office Id")
                $("#dgvParam th[data-field=tanggalValuta]").html("Tanggal Valuta")
                $("#dgvParam th[data-field=lastUpdate]").html("Last Update")
                $("#dgvParam th[data-field=lastUser]").html("Last User")
                

                switch (_strTreeInterface) {
                    case "PAR":
                        $('#lblOffice').attr('style', 'display:none;');
                        $('#Office_div').attr('style', 'display:none;');
                        break;
                    case "SAC":
                        grid.showColumn('officeId');
                        $('#lblOffice').attr('style', '');
                        $('#Office_div').attr('style', '');
                        $("#cmpsrOffice_text1").prop('disabled', true);
                        $("#srcOffice").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
                        break;
                    case "SFC":
                        $('#lblOffice').attr('style', 'display:none;');
                        $('#Office_div').attr('style', 'display:none;');
                        break;
                    case "SBC":
                        $('#lblOffice').attr('style', 'display:none;');
                        $('#Office_div').attr('style', 'display:none;');
                        break;
                    case "SNV":
                        $('#lblOffice').attr('style', 'display:none;');
                        $('#Office_div').attr('style', 'display:none;');
                        break;
                    case "SDV":
                        $('#lblOffice').attr('style', 'display:none;');
                        $('#Office_div').attr('style', 'display:none;');
                        break;
                    case "SKR":
                        $('#lblOffice').attr('style', 'display:none;');
                        $('#Office_div').attr('style', 'display:none;');
                        break;
                    case "RDD":
                        grid.showColumn('tanggalValuta');
                        $('#lblOffice').attr('style', 'display:none;');
                        $('#Office_div').attr('style', 'display:none;');
                        break;
                    case "GFP":
                        grid.showColumn('desc2');
                        grid.showColumn('tglEfektif');
                        grid.showColumn('tglExpire');
                        break;
                    default:
                        $('#lblOffice').attr('style', 'display:none;');
                        $('#Office_div').attr('style', 'display:none;');
                        break;
                }

            }
            else
            {
                swal("Warning", data.ErrMsg, "warning");
                $("#dgvParam").data('kendoGrid').dataSource.data([]);
                document.getElementById("btnEdit").disabled = true;
                document.getElementById("btnDelete").disabled = true;
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
            change: dgvParam_Click,
            databound: onBounddgvParam,
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
        var tanggalValuta = name.indexOf("tanggalValuta") > -1 || name.indexOf("tanggalValuta") > -1;
        var lastUpdate = name.indexOf("lastUpdate") > -1 || name.indexOf("lastUpdate") > -1;
        return {
            template: tanggalValuta ? "#= kendo.toString(kendo.parseDate(tanggalValuta, 'yyyy-MM-dd'), 'dd/MM/yyyy') #" :
                lastUpdate ? "#= kendo.toString(kendo.parseDate(lastUpdate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                : columnNames,
            field: name,
            width: 300,
            title: name
        };
    })
}

function subNew() {
    _intType = 1;
    if ($("#ProductCode").val() == "") {
        swal("Warning", "Pilih Product terlebih dahulu!", "warning");
        return;
    }

    var today = new Date();
    $("#dtpSP12").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());
    $("#dtpSP13").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());
    _intType = 1;
    if (_strTreeInterface != "RDD") {
        $("#txtbSP1").val('');
        $("#txtbSP2").val('');
    }
    $("#cmpsrGift_text1").val('');
    $("#MoneyNominal").data("kendoNumericTextBox").value();
    $("#txtbSP11").val('');
    $("#cmpsrOffice_text1").val('');


    switch (_strTreeInterface) {
        case "PAR":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', true);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "SAC":
            $("#txtbSP1").prop('disabled', false);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', '');
            $('#Office_div').attr('style', '');
            $("#cmpsrOffice_text1").prop('disabled', false);
            $("#srcOffice").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
            break;
        case "SFC":
            $("#txtbSP1").prop('disabled', false);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "SBC":
            $("#txtbSP1").prop('disabled', false);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "SNV":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "SDV":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "SKR":
            $("#txtbSP1").prop('disabled', true);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "RDD":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', true);
            $("#dtpSP").data("kendoDatePicker").enable(true);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "GFP":
            $("#txtbSP1").prop('disabled', false);
            $("#txtbSP2").prop('disabled', false);
            $("#txtbSP11").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $("#dtpSP12").data("kendoDatePicker").enable(true);
            $("#dtpSP13").data("kendoDatePicker").enable(true);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');

            $("#cmpsrGift_text1").prop('disabled', false);
            $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
            $("#MoneyNominal").data("kendoNumericTextBox").enable(true);
            break;
        default:
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', true);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
    }
    subResetToolBar();
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
function subCancel() {
    _intType = 0;
    subResetToolBar();
    subRefresh();
}
function subDelete()
{
    _intType = 3;
    if ($("#ProductCode").val() == "") {
        swal("Warning", "Pilih Product terlebih dahulu!", "warning");
        return;
    }
    if (_strTreeInterface == "GFP") {
        swal("Warning", "Khusus gift product tidak bisa hapus data", "warning");
        return;
    }
    swal({
        title: "Information",
        text: "Are you sure to delete this data ?",
        type: "warning",
        showCancelButton: true,
        confirmButtonClass: 'btn-info',
        confirmButtonText: "Yes",
        closeOnConfirm: true,
        closeOnCancel: true
    },
        function (isConfirm) {
            if (isConfirm) {
                subSave();
                _intType = 0;
            }
        });
}

function subUpdate(){
    _intType = 2;
    switch (_strTreeInterface) {
        case "PAR":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', true);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "SAC":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', '');
            $('#Office_div').attr('style', '');
            $("#cmpsrOffice_text1").prop('disabled', false);
            $("#srcOffice").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
            break;
        case "SFC":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "SBC":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "SNV":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(true);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "SDV":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(true);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "SKR":
            $("#txtbSP1").prop('disabled', true);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "RDD":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', true);
            $("#dtpSP").data("kendoDatePicker").enable(true);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
        case "GFP":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', false);
            $("#txtbSP11").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $("#dtpSP12").data("kendoDatePicker").enable(true);
            $("#dtpSP13").data("kendoDatePicker").enable(true);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            
            $("#cmpsrGift_text1").prop('disabled', false);
            $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
            $("#cmpsrSearch1_div").prop('style', '');
            $("#MoneyNominal").data("kendoNumericTextBox").enable(true);
            break;
        default:
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', true);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $('#lblOffice').attr('style', 'display:none;');
            $('#Office_div').attr('style', 'display:none;');
            break;
    }
    subResetToolBar();
}
function subSave() {
    var Code, Desc, OfficeId, dtValue;
    if ((_intType == 1) | (_intType == 2)) {
        if (_strTreeInterface != "GFP")
            Code = $("#txtbSP1").val();
        else
            Code = $("#cmpsrGift_text1").val();
    }
    else {
        Code = "";
        if (_intType == 3 && _strTreeInterface == "GFP")
            Code = $("#cmpsrGift_text1").val();
        else
            Code = $("#txtbSP1").val();
    }
    if ((_intType == 1) | (_intType == 2)) {
        if (_strTreeInterface != "GFP")
            Desc = $("#txtbSP2").val();
        else {
            var [day, month, year] = $("#dtpSP12").val().split("/")
            var dtpSP12 = year + month + day;
            var [day, month, year] = $("#dtpSP13").val().split("/")
            var dtpSP13 = year + month + day;            
            Desc = $("#MoneyNominal").data("kendoNumericTextBox").value() + "#" + $("#txtbSP11").val() + "#" + dtpSP12 + "#" + dtpSP13;
        }
    }
    else {
        Desc = "";
        if (_strTreeInterface != "GFP")
            Desc = $("#txtbSP2").val();
        else {
            var [day, month, year] = $("#dtpSP12").val().split("/")
            var dtpSP12 = year + month + day;
            var [day, month, year] = $("#dtpSP13").val().split("/")
            var dtpSP13 = year + month + day;
            Desc = $("#MoneyNominal").data("kendoNumericTextBox").value() + "#" + $("#txtbSP11").val() + "#" + dtpSP12 + "#" + dtpSP13;
        }
    }
    if (_strTreeInterface == "SAC") {
        OfficeId = $("#cmpsrOffice_text1").val();
    }
    else {
        OfficeId = "";
    }

    if ((_intType != 2) | (_intType != 3)) {
        _Id = 0;
    }

    if ((_intType == 1) | (_intType == 2)) {
        dtValue = toDate($("#dtpSP").val());
    }
    else {
        dtValue = _tanggalValuta;
    }

    var model = JSON.stringify({
        'Type': _intType,
        'InterfaceId': _strTreeInterface,
        'Code': Code,
        'Desc': Desc,
        'OfficeId': OfficeId,
        'ProdId': $("#ProdId").val(),
        'Id': _Id,
        'Value': dtValue,
        'NIK': 0,
        'Guid': '',
    });
    
    $.ajax({
        type: 'POST',
        url: '/Parameter/MaintainParameter',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                swal("Success", "Harap melakukan proses otorisasi! ", "success");
                _intType = 0;
                subResetToolBar();
                subRefresh();
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
        ,
        complete: function () {
            $("#load_screen").hide();
        }
    });
}
function pad(num, size) {
    var s = "000000000" + num;
    return s.substr(s.length - size);
}
function toDate(dateStr) {
    var [day, month, year] = dateStr.split("/")
    return new Date(year, month - 1, day)
}

