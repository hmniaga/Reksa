var _intType;
var _strTreeInterface;
var _LastSelectedNode = "";
var _LastSelectedNodeName = "";
var _Id = 0;
var _tanggalValuta;

$(document).ready(function load() {
    var grid = {
        height: 200
    };
    $("#dgvParam").kendoGrid(grid);

    $("#lblSP1").text('Kode');
    $("#lblSP2").text('Deskripsi');
    $("#lblSP4").text('Tanggal valuta');
    $("#lblSP3").text('');
    $("#lblSP5").text('');
    $("#lblSP6").text('');

    $('#txtbSP3').attr('style', 'display:none;');
    $("#txtbSP3").prop('disabled', true);
    $('#txtbSP4').attr('style', 'display:none;');
    $("#txtbSP4").prop('disabled', true);
    $("#dtpSP4").data("kendoDatePicker").wrapper.hide(); 
    $("#dtpSP4").data("kendoDatePicker").enable(false);
    $("#dtpSP5").data("kendoDatePicker").wrapper.hide(); 
    $("#dtpSP5").data("kendoDatePicker").enable(false);
    $('#textPctSwc').attr('style', 'display:none;');
    $("#textPctSwc").prop('disabled', true);
    $("#cmpsrSearch1_text1").prop('disabled', false);
    $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    $("#txtbSP1").prop('disabled', true);
    $("#txtbSP2").prop('disabled', true);
    $("#dtpSP").data("kendoDatePicker").enable(false);
    $("#cmpsrSearch2_text1").prop('disabled', false);
    $("#cmpsrSearch2").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    $("#txtbSP2").prop('disabled', true);
    $("#txtbSP5").prop('disabled', true);
    $("#comboBox1").data("kendoDropDownList").enable(false);
    $("#comboBox2").data("kendoDropDownList").enable(false);
    $("#comboBox3").data("kendoDropDownList").enable(false);
    _intType = 0;   
    var treeview = $("#trvSetupParameter").data("kendoTreeView");
    var barDataItem = treeview.dataSource.get("PAR");
    var bar = treeview.findByUid(barDataItem.uid);
    treeview.select(bar);
    treeview.trigger('select', { node: bar });
    _strTreeInterface = "PAR";
    subRefresh();
});

function trvSetupParameter_AfterSelect(e) {
    subResetToolBar();
    var dataItem = this.dataItem(e.node);
    _strTreeInterface = dataItem.id;
    if (_intType == 1 || _intType == 2) {
        var message;
        if (_intType == 1)
            message = 'new';
        else
            message = 'edited';
        swal({
            title: "Confirmation",
            text: "Cancel This " + _LastSelectedNodeName + " " + message +" data ?",
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
            document.getElementById('lblSP1').innerHTML = 'Kode';
            document.getElementById('lblSP2').innerHTML = 'Deskripsi';
            document.getElementById('lblSP4').innerHTML = 'Tanggal valuta';

            $("#cmpsrSearch1_div").prop('style', 'display:none;');
            break;
        case "MNI":
            LoadDefaultSettings();
            document.getElementById('lblSP1').innerHTML = 'Kode Man Inv';
            document.getElementById('lblSP2').innerHTML = 'Nama Man INV';
            document.getElementById('lblSP3').innerHTML = 'Kode Man Inv (KSEI)';
            document.getElementById('lblSP4').innerHTML = 'Tanggal valuta';

            $("#cmpsrSearch1_div").prop('style', 'display:none;');
            document.getElementById("txtbSP3").style.display = 'block';
            //txtbSP3.MaxLength = 5;

            $("#lblSP1").prop('class', 'col-sm-4 control-label');
            $("#lblSP2").prop('class', 'col-sm-4 control-label');
            $("#lblSP4").prop('class', 'col-sm-4 control-label');
            $("#lblSP5").prop('class', 'col-sm-5 control-label');
            $("#lblSP3").prop('class', 'col-sm-5 control-label');
            $("#lblSP6").prop('class', 'col-sm-5 control-label');
            break;
        case "CTD":
            LoadDefaultSettings();
            document.getElementById('lblSP1').innerHTML = 'Kode Custody';
            document.getElementById('lblSP2').innerHTML = 'Custody';
            document.getElementById('lblSP4').innerHTML = 'Tanggal valuta';
            document.getElementById('lblSP3').innerHTML = 'Custody (KSEI)';

            $("#cmpsrSearch1_div").prop('style', 'display:none;');
            document.getElementById("txtbSP3").style.display = 'block';
            //txtbSP3.MaxLength = 5;

            $("#lblSP1").prop('class', 'col-sm-4 control-label');
            $("#lblSP2").prop('class', 'col-sm-4 control-label');
            $("#lblSP4").prop('class', 'col-sm-4 control-label');
            $("#lblSP5").prop('class', 'col-sm-4 control-label');
            $("#lblSP3").prop('class', 'col-sm-4 control-label');
            $("#lblSP6").prop('class', 'col-sm-4 control-label');
            break;
        case "RTY":
            LoadDefaultSettings();
            document.getElementById('lblSP1').innerHTML = 'Kode Tipe';
            document.getElementById('lblSP2').innerHTML = 'Tipe Reksa IND';
            document.getElementById('lblSP3').innerHTML = 'Tipe Reksa ENG';
            document.getElementById('lblSP4').innerHTML = 'Tanggal valuta';

            document.getElementById("txtbSP3").style.display = 'block';
            $("#cmpsrSearch1_div").prop('style', 'display:none;');

            $("#lblSP1").prop('class', 'col-sm-4 control-label');
            $("#lblSP2").prop('class', 'col-sm-4 control-label');
            $("#lblSP4").prop('class', 'col-sm-4 control-label');
            $("#lblSP5").prop('class', 'col-sm-4 control-label');
            $("#lblSP3").prop('class', 'col-sm-4 control-label');
            $("#lblSP6").prop('class', 'col-sm-4 control-label');
            break;
        case "RHT":
            LoadDefaultSettings();
            document.getElementById('lblSP1').innerHTML = 'Kode';
            document.getElementById('lblSP2').innerHTML = 'Keterangan';
            document.getElementById('lblSP4').innerHTML = 'Tanggal Libur';

            $("#cmpsrSearch1_div").prop('style', 'display:none;');

            $("#lblSP1").prop('class', 'col-sm-4 control-label');
            $("#lblSP2").prop('class', 'col-sm-4 control-label');
            $("#lblSP4").prop('class', 'col-sm-4 control-label');
            break;
        case "RSC":
            LoadDefaultSettings();
            document.getElementById('lblSP1').innerHTML = 'Kode Sales';
            document.getElementById('lblSP2').innerHTML = 'Nama Sales';
            document.getElementById('lblSP4').innerHTML = 'Tanggal Valuta';

            $("#cmpsrSearch1_div").prop('style', 'display:none;');

            $("#lblSP1").prop('class', 'col-sm-4 control-label');
            $("#lblSP2").prop('class', 'col-sm-4 control-label');
            $("#lblSP4").prop('class', 'col-sm-4 control-label');
            break;
        case "GFM":
            LoadDefaultSettings();
            document.getElementById('lblSP3').innerHTML = 'Biaya';
            document.getElementById('lblSP5').innerHTML = '';
            document.getElementById('lblSP6').innerHTML = '';
            document.getElementById("txtbSP3").style.display = 'block';
            $("#dtpSP4").data("kendoDatePicker").wrapper.hide();
            $("#dtpSP5").data("kendoDatePicker").wrapper.hide();
            document.getElementById("textPctSwc").style.display = 'none';
            $("#cmpsrSearch1_div").prop('style', 'display:none;');
            break;
        case "RSB":
            LoadDefaultSettings();
            $("#cmpsrSearch1_div").prop('style', '');
            document.getElementById("txtbSP1").style.display = 'none';
            document.getElementById("txtbSP2").style.display = 'block';
            document.getElementById("txtbSP3").style.display = 'block';
            document.getElementById("txtbSP5").style.display = 'block';
            document.getElementById("textPctSwc").style.display = 'block';
            $("#dtpSP").data("kendoDatePicker").wrapper.hide();
            $("#dtpSP4").data("kendoDatePicker").wrapper.hide();
            $("#dtpSP5").data("kendoDatePicker").wrapper.hide();
            document.getElementById('lblSP1').innerHTML = 'Kode Produk';
            document.getElementById('lblSP2').innerHTML = 'Subs Fee(%)';
            document.getElementById('lblSP3').innerHTML = 'Redemption Fee(%)';
            document.getElementById('lblSP4').innerHTML = 'Swc.Fee Non Asuransi (%)';
            document.getElementById('lblSP6').innerHTML = 'Swc.Fee Asuransi (%)';

            $('#cmpsrSearch1').attr('href', '/Global/SearchProduct/?criteria=PAR');
            $("#textBox1").prop('style', '');
            $("#textBox1").prop('disabled', true);
            document.getElementById('lblSP5').innerHTML = 'Red.Fee Non Asuransi (%)';
            document.getElementById('lblSP3').innerHTML = 'Red.Fee Asuransi (%)';

            $("#lblSP1").prop('class', 'col-sm-4 control-label');
            $("#lblSP2").prop('class', 'col-sm-4 control-label');
            $("#lblSP4").prop('class', 'col-sm-4 control-label');
            $("#lblSP5").prop('class', 'col-sm-6 control-label');
            $("#lblSP3").prop('class', 'col-sm-6 control-label');
            $("#lblSP6").prop('class', 'col-sm-6 control-label');
            break;
        case "WPR":
            LoadDefaultSettings();
            document.getElementById('lblSP3').innerHTML = 'Nama';
            document.getElementById('lblSP5').innerHTML = 'Job Title';
            document.getElementById('lblSP6').innerHTML = 'Tgl Expired';
            $("#txtbSP3").prop('style', 'display:block;width:270px;');
            $("#dtpSP4").data("kendoDatePicker").wrapper.hide();
            $("#txtbSP4").prop('style', 'display:block;width:270px;');
            $("#dtpSP5").data("kendoDatePicker").wrapper.show();
            document.getElementById("textPctSwc").style.display = 'none';

            $("#lblSP1").prop('class', 'col-sm-4 control-label');
            $("#lblSP2").prop('class', 'col-sm-4 control-label');
            $("#lblSP4").prop('class', 'col-sm-4 control-label');
            break;
        case "PFP":
            LoadDefaultSettings();
            document.getElementById('lblSP1').innerHTML = 'Frek Pendebetan';
            document.getElementById('lblSP2').innerHTML = 'Min Jangka Wkt';
            document.getElementById('lblSP3').innerHTML = 'Kelipatan';
            document.getElementById("txtbSP3").style.display = 'block';
            $("#dtpSP").data("kendoDatePicker").wrapper.hide();
            $("#lblSP3").prop('style', '');
            $("#lblSP4").prop('style', 'display:none;');
            $("#dtpSP4").data("kendoDatePicker").wrapper.hide();
            $("#dtpSP5").data("kendoDatePicker").wrapper.hide();
            document.getElementById("textPctSwc").style.display = 'none';
            $("#cmpsrSearch1_div").prop('style', 'display:none;');

            $("#txtbSP1").prop('style', 'width:80px;');
            $("#txtbSP2").prop('style', 'width:80px;');
            $("#lblSP1").prop('class', 'col-sm-5 control-label');
            $("#lblSP2").prop('class', 'col-sm-5 control-label');
            $("#lblSP4").prop('class', 'col-sm-5 control-label');
            break;
        case "MSC":
            LoadDefaultSettings();
            $("#cmpsrSearch1_div").prop('style', '');
            document.getElementById("txtbSP1").style.display = 'none';
            document.getElementById("txtbSP2").style.display = 'block';
            document.getElementById("txtbSP3").style.display = 'none';

            $("#dtpSP").data("kendoDatePicker").wrapper.hide();
            $("#dtpSP4").data("kendoDatePicker").wrapper.hide();
            $("#dtpSP5").data("kendoDatePicker").wrapper.hide();
            document.getElementById("textPctSwc").style.display = 'none';

            $("#checkBox1_div").attr('style', '');
            $("#checkBox1").prop('disabled', true);

            document.getElementById('lblSP1').innerHTML = 'Kode Produk';
            document.getElementById('lblSP2').innerHTML = 'Min Subsc';
            document.getElementById('lblSP3').innerHTML = '';

            document.getElementById('lblSP4').innerHTML = '';
            document.getElementById('lblSP5').innerHTML = '';
            document.getElementById('lblSP6').innerHTML = '';

            $('#cmpsrSearch1').attr('href', '/Global/SearchProduct/?criteria=PAR');

            $("#lblSP1").prop('class', 'col-sm-4 control-label');
            $("#lblSP2").prop('class', 'col-sm-4 control-label');
            $("#lblSP4").prop('class', 'col-sm-4 control-label');
            break;
        case "SWC":
            LoadDefaultSettings();
            $("#cmpsrSearch1_div").prop('style', '');
            $("#cmpsrSearch2_div").prop('style', '');
            document.getElementById("txtbSP1").style.display = 'none';
            document.getElementById("txtbSP2").style.display = 'none';
            $("#txtbSP3").prop('style', 'width:100px;');
            document.getElementById("txtbSP4").style.display = 'none';
            $("#txtbSP5").prop('style', 'display:block;width:150px;');
            $("#comboBox1").data("kendoDropDownList").wrapper.show();
            $("#comboBox2").data("kendoDropDownList").wrapper.hide();

            $("#dtpSP").data("kendoDatePicker").wrapper.hide();
            $("#dtpSP4").data("kendoDatePicker").wrapper.hide();
            $("#dtpSP5").data("kendoDatePicker").wrapper.hide();

            document.getElementById("textPctSwc").style.display = 'block';
            $("#checkBox1_div").attr('style', 'display:none;');

            document.getElementById('lblSP1').innerHTML = 'Product Switch Out';
            document.getElementById('lblSP2').innerHTML = 'Product Switch In';
            document.getElementById('lblSP3').innerHTML = 'Min Redempt';

            document.getElementById('lblSP4').innerHTML = '%Swc Non Employee';
            document.getElementById('lblSP5').innerHTML = 'Min Subsc';
            document.getElementById("lblSP5").style.display = 'none';
            document.getElementById('lblSP6').innerHTML = '%Swc Employee';

            $('#cmpsrSearch1').attr('href', '/Global/SearchProductSwitchOut/?criteria=PAR');
            $('#cmpsrSearch2').attr('href', '/Global/SearchProductSwitchIn/?criteria=PAR&prodcode=' + $("#cmpsrSearch1_text1").val());

            $("#lblSP1").prop('class', 'col-sm-4 control-label');
            $("#lblSP2").prop('class', 'col-sm-4 control-label');
            $("#lblSP4").prop('class', 'col-sm-4 control-label');
            $("#lblSP5").prop('class', 'col-sm-4 control-label');
            $("#lblSP3").prop('class', 'col-sm-4 control-label');
            $("#lblSP6").prop('class', 'col-sm-4 control-label');
            break;
        case "RPP":
            LoadDefaultSettings();
            $("#cmpsrSearch1_div").prop('style', '');
            document.getElementById("txtbSP1").style.display = 'none';
            document.getElementById("txtbSP2").style.display = 'none';
            document.getElementById("txtbSP3").style.display = 'none';
            document.getElementById("txtbSP4").style.display = 'none';
            document.getElementById("txtbSP5").style.display = 'none';

            $("#comboBox1").data("kendoDropDownList").wrapper.hide();
            $("#comboBox2").data("kendoDropDownList").wrapper.hide();
            $("#comboBox3").data("kendoDropDownList").wrapper.show();

            $("#dtpSP").data("kendoDatePicker").wrapper.show();
            $("#dtpSP4").data("kendoDatePicker").wrapper.hide();
            $("#dtpSP5").data("kendoDatePicker").wrapper.hide();

            document.getElementById("textPctSwc").style.display = 'none';
            $("#checkBox1_div").attr('style', 'display:none;');

            document.getElementById('lblSP1').innerHTML = 'Product';
            document.getElementById('lblSP2').innerHTML = 'Risk Profile Produk';
            document.getElementById('lblSP3').innerHTML = '';
            document.getElementById('lblSP4').innerHTML = 'Tanggal Valuta';
            document.getElementById('lblSP5').innerHTML = '';
            document.getElementById('lblSP6').innerHTML = '';
            $('#cmpsrSearch1').attr('href', '/Global/SearchProduct/?criteria=PAR');

            $("#lblSP1").prop('class', 'col-sm-4 control-label');
            $("#lblSP2").prop('class', 'col-sm-5 control-label');
            $("#lblSP4").prop('class', 'col-sm-5 control-label');
            break;
        case "PRE":
            LoadDefaultSettings();
            document.getElementById('lblSP1').innerHTML = '';
            document.getElementById('lblSP2').innerHTML = 'Percentage (%)';
            document.getElementById("txtbSP1").style.display = 'none';
            break;
        case "CTR":
            LoadDefaultSettings();
            $("#cmpsrSearch1_div").prop('style', '');
            document.getElementById("txtbSP1").style.display = 'none';
            document.getElementById("txtbSP2").style.display = 'none';
            document.getElementById("txtbSP3").style.display = 'none';
            document.getElementById("txtbSP4").style.display = 'none';
            document.getElementById("txtbSP5").style.display = 'none';
            $("#comboBox1").data("kendoDropDownList").wrapper.hide();
            $("#comboBox2").data("kendoDropDownList").wrapper.hide();
            $("#comboBox3").data("kendoDropDownList").wrapper.hide();

            $("#dtpSP").data("kendoDatePicker").wrapper.show();
            $("#dtpSP4").data("kendoDatePicker").wrapper.hide();
            $("#dtpSP5").data("kendoDatePicker").wrapper.hide();
            document.getElementById("textPctSwc").style.display = 'none';
            $("#checkBox1_div").attr('style', 'display:none;');

            document.getElementById('lblSP1').innerHTML = 'Country';
            document.getElementById('lblSP2').innerHTML = '';
            document.getElementById('lblSP3').innerHTML = '';

            document.getElementById('lblSP4').innerHTML = 'Tanggal Valuta';
            document.getElementById('lblSP5').innerHTML = '';
            document.getElementById('lblSP6').innerHTML = '';

            $('#cmpsrSearch1').attr('href', '/Global/SearchCountry/?criteria=PAR');

            $("#lblSP1").prop('class', 'col-sm-4 control-label');
            $("#lblSP2").prop('class', 'col-sm-4 control-label');
            $("#lblSP4").prop('class', 'col-sm-4 control-label');

            break;
        case "OFF":
            LoadDefaultSettings();
            $("#cmpsrSearch1_div").prop('style', '');
            document.getElementById("txtbSP1").style.display = 'none';
            document.getElementById("txtbSP2").style.display = 'none';
            document.getElementById("txtbSP3").style.display = 'none';
            document.getElementById("txtbSP4").style.display = 'none';
            document.getElementById("txtbSP5").style.display = 'none';
            $("#comboBox1").data("kendoDropDownList").wrapper.hide();
            $("#comboBox2").data("kendoDropDownList").wrapper.hide();
            $("#comboBox3").data("kendoDropDownList").wrapper.hide();

            $("#dtpSP").data("kendoDatePicker").wrapper.show();
            $("#dtpSP4").data("kendoDatePicker").wrapper.hide();
            $("#dtpSP5").data("kendoDatePicker").wrapper.hide();
            document.getElementById("textPctSwc").style.display = 'none';
            $("#checkBox1_div").attr('style', 'display:none;');

            document.getElementById('lblSP1').innerHTML = 'Office';
            document.getElementById('lblSP2').innerHTML = '';
            document.getElementById('lblSP3').innerHTML = '';

            document.getElementById('lblSP4').innerHTML = 'Tanggal Valuta';
            document.getElementById('lblSP5').innerHTML = '';
            document.getElementById('lblSP6').innerHTML = '';

            $('#cmpsrSearch1').attr('href', '/Global/SearchOffice/?criteria=PAR');

            $("#lblSP1").prop('class', 'col-sm-4 control-label');
            $("#lblSP2").prop('class', 'col-sm-4 control-label');
            $("#lblSP4").prop('class', 'col-sm-4 control-label');
            break;
        default:
            LoadDefaultSettings();
            break;

    }
}

function LoadDefaultSettings() {
    $("#lblSP1").prop('class', 'col-sm-3 control-label');
    $("#lblSP2").prop('class', 'col-sm-3 control-label');
    $("#lblSP4").prop('class', 'col-sm-3 control-label');
    $("#lblSP5").prop('class', 'col-sm-3 control-label');
    $("#lblSP3").prop('class', 'col-sm-3 control-label');
    $("#lblSP6").prop('class', 'col-sm-3 control-label');
    $("#txtbSP1").prop('style', 'width:200px;');
    $("#txtbSP2").prop('style', 'width:250px;');

    document.getElementById('lblSP1').innerHTML = 'Kode';
    document.getElementById('lblSP2').innerHTML = 'Deskripsi';
    document.getElementById('lblSP4').innerHTML = 'Tanggal valuta';
    document.getElementById('lblSP3').innerHTML = '';
    document.getElementById('lblSP5').innerHTML = '';
    document.getElementById('lblSP6').innerHTML = '';
    document.getElementById("txtbSP1").style.display = 'block';
    document.getElementById("txtbSP2").style.display = 'block';
    document.getElementById("txtbSP3").style.display = 'none';
    $("#dtpSP").data("kendoDatePicker").wrapper.show(); 
    $("#dtpSP4").data("kendoDatePicker").wrapper.hide(); 
    $("#dtpSP5").data("kendoDatePicker").wrapper.hide(); 
    document.getElementById("textPctSwc").style.display = 'none';
    $("#cmpsrSearch1_text1").val('');
    $("#cmpsrSearch1_text2").val('');
    $("#cmpsrSearch1_div").prop('style', 'display:none;');
    document.getElementById("txtbSP4").style.display = 'none';
    $("#txtbSP4").prop('disabled', true);
    $("#lblSP4").attr('style', '');
    $("#checkBox1_div").attr('style', 'display:none;');
    $("#checkBox1").prop('disabled', true);
    $("#textBox1").attr('style', 'display:none;');
    $("#lblSP5").attr('style', '');
    $("#cmpsrSearch2_text1").val('');
    $("#cmpsrSearch2_text2").val('');
    $("#cmpsrSearch2_div").prop('style', 'display:none;');
    document.getElementById("txtbSP5").style.display = 'none';
    $("#comboBox1").data("kendoDropDownList").wrapper.hide();
    $("#comboBox2").data("kendoDropDownList").wrapper.hide();
    $("#comboBox3").data("kendoDropDownList").wrapper.hide();
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
        if (_strTreeInterface == "KNP" || _strTreeInterface == "ANP")
            $("#btnEdit").hide();
        if (_strTreeInterface == "PRE") {
            $("#btnDelete").hide();
            $("#btnNew").hide();
        }
        if (_strTreeInterface == "OFF" || _strTreeInterface == "CTR")
            $("#btnEdit").hide();
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

function subNew() {
    _intType = 1;
    if ((_strTreeInterface != "RHT") && (_strTreeInterface != "RDD")) {
        $("#txtbSP1").val('');
    }
    $("#txtbSP2").val('');
    $("#txtbSP3").val('');
    $("#txtbSP4").val('');
    $("#txtbSP5").val('');
    switch (_strTreeInterface) {
        case "PAR":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', true);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            break;
        case "MNI":
            $("#txtbSP1").prop('disabled', false);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $("#txtbSP3").prop('disabled', false);
            break;
        case "CTD":
            $("#txtbSP1").prop('disabled', false);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $("#txtbSP3").prop('disabled', false);
            break;
        case "RHT":
            $("#txtbSP1").prop('disabled', true);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(true);
            break;
        case "GFM":
            $("#txtbSP1").prop('disabled', false);
            $("#txtbSP2").prop('disabled', false);
            $("#txtbSP3").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            break;
        case "RTY":
            $("#txtbSP1").prop('disabled', false);
            $("#txtbSP2").prop('disabled', false);
            $("#txtbSP3").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            break;
        case "RSB":
            $("#cmpsrSearch1_text1").val('');
            $("#cmpsrSearch1_text2").val('');
            $("#cmpsrSearch1_text1").prop('disabled', false);
            $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
            $("#dtpSP").data("kendoDatePicker").enable(false);
            $("#txtbSP2").prop('disabled', false);
            $("#txtbSP3").prop('disabled', false);
            $("#textBox1").prop('disabled', false);
            $("#textBox1").val('');            
            $("#txtbSP5").prop('disabled', false);
            $("#txtbSP5").val('');
            $("#textPctSwc").prop('disabled', false);
            $("#textPctSwc").val('');
            break;
        case "WPR":
            $("#txtbSP1").prop('disabled', false);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP5").data("kendoDatePicker").enable(true);
            $("#textPctSwc").prop('disabled', true);
            break;
        case "PFP":
            $("#txtbSP1").prop('disabled', false);
            $("#txtbSP2").prop('disabled', false);
            $("#txtbSP3").prop('disabled', false);
            break;
        case "MSC":
            $("#cmpsrSearch1_text1").val('');
            $("#cmpsrSearch1_text2").val('');
            $("#cmpsrSearch1_text1").prop('disabled', false);
            $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
            $("#txtbSP2").prop('disabled', false);
            $("#checkBox1").prop('disabled', false);
            break;
        case "SWC":
            $("#cmpsrSearch1_text1").val('');
            $("#cmpsrSearch1_text2").val('');
            $("#cmpsrSearch1_text1").prop('disabled', false);
            $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

            $("#cmpsrSearch2_text1").val('');
            $("#cmpsrSearch2_text2").val('');
            $("#cmpsrSearch2_text1").prop('disabled', false);
            $("#cmpsrSearch2").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');

            $("#txtbSP3").prop('disabled', false);
            $("#txtbSP4").prop('disabled', false);
            $("#txtbSP5").prop('disabled', false);
            $("#textPctSwc").prop('disabled', false);
            $("#comboBox1").data("kendoDropDownList").enable(true);
            $("#comboBox2").data("kendoDropDownList").enable(true);
            break;
        case "RPP":
            $("#cmpsrSearch1_text1").val('');
            $("#cmpsrSearch1_text2").val('');
            $("#cmpsrSearch1_text1").prop('disabled', false);
            $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
            $("#comboBox3").data("kendoDropDownList").enable(true);
            break;
        case "CTR":
            $("#cmpsrSearch1_text1").val('');
            $("#cmpsrSearch1_text2").val('');
            $("#cmpsrSearch1_text1").prop('disabled', false);
            $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
            break;
        case "OFF":
            $("#cmpsrSearch1_text1").val('');
            $("#cmpsrSearch1_text2").val('');
            $("#cmpsrSearch1_text1").prop('disabled', false);
            $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
            break;
        default:
            $("#txtbSP1").prop('disabled', false);
            $("#txtbSP2").prop('disabled', false);
            $("#dtpSP").data("kendoDatePicker").enable(false);
            break;
    }
    subResetToolBar();
}

function subRefresh() {
    $("#txtbSP1").val("");
    $("#txtbSP2").val("");
    var today = new Date();
    $("#dtpSP").val(pad((today.getDate()), 2) + '/' + pad((today.getMonth() + 1), 2) + '/' + today.getFullYear());

    $("#txtbSP1").prop('disabled', true);
    $("#txtbSP2").prop('disabled', true);
    $("#txtbSP3").prop('disabled', true);
    $('#dtpSP4').data("kendoDatePicker").enable(false);
    $('#dtpSP5').data("kendoDatePicker").enable(false);
    $("#textPctSwc").prop('disabled', true);
    $("#cmpsrSearch1_text1").prop('disabled', false);
    $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    $('#dtpSP').data("kendoDatePicker").enable(false);
    $("#textBox1").prop('disabled', true);
    $("#txtbSP5").prop('disabled', true);
    $("#txtbSP4").prop('disabled', true);
    $("#cmpsrSearch2_text1").prop('disabled', false);
    $("#cmpsrSearch2").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
    $("#comboBox1").data("kendoDropDownList").enable(false);
    $("#comboBox2").data("kendoDropDownList").enable(false);
    $("#comboBox3").data("kendoDropDownList").enable(false);

    var ProdId = '';
    $.ajax({
        type: 'GET',
        url: '/Parameter/RefreshParamGlobal',
        data: { ProdukId: ProdId, InterfaceId: _strTreeInterface },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                var grid = $('#dgvParam').data('kendoGrid');
                var gridData = populateGrid(data.dsResult.table);
                grid.setOptions(gridData);
                grid.dataSource.pageSize(10);
                grid.dataSource.page(1);
                grid.select("tr:eq(0)");

                grid.hideColumn('id');
                grid.hideColumn('minSwitchRedempt');
                grid.hideColumn('jenisSwitchRedempt');
                grid.hideColumn('switchingFeeNonKaryawan');
                grid.hideColumn('switchingFeeKaryawan');
                grid.hideColumn('desc5');

                $("#dgvParam th[data-field=deskripsi]").html("Deskripsi")
                $("#dgvParam th[data-field=kode]").html("Kode")
                $("#dgvParam th[data-field=prodId]").html("ProdId")

                $("#dgvParam th[data-field=tanggalValuta]").html("Tanggal Valuta")
                $("#dgvParam th[data-field=lastUpdate]").html("Last Update")
                $("#dgvParam th[data-field=lastUser]").html("Last User")
                $("#dgvParam th[data-field=officeId]").html("Office Id")
                $("#dgvParam th[data-field=tglExpire]").html("Tanggal Expired")
                $("#dgvParam th[data-field=keterangan]").html("Keterangan")
                $("#dgvParam th[data-field=minSwitchRedempt]").html("Min Switch Redempt")
                $("#dgvParam th[data-field=jenisSwitchRedempt]").html("Jenis Switch Redempt")
                $("#dgvParam th[data-field=switchingFeeNonKaryawan]").html("Switching Fee Non Karyawan")
                $("#dgvParam th[data-field=switchingFeeKaryawan]").html("Switching Fee Karyawan")

                if (_strTreeInterface == 'PFP')
                    grid.showColumn('id');

                grid.showColumn('tanggalValuta');
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
                    $("#dgvParam th[data-field=desc2]").html("KSEI CODE")
                }
                else if (_strTreeInterface == "RTY") {
                    grid.showColumn('desc2');
                    $("#dgvParam th[data-field=dec2]").html("Tipe Reksadana English")
                    $("#dgvParam th[data-field=deskripsi]").html("Tipe Reksadana")
                }
                else if (_strTreeInterface == "GFM") {
                    grid.showColumn('desc2');
                    $("#dgvParam th[data-field=desc2]").html("Biaya")
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
                    $("#dgvParam th[data-field=desc5]").html("Red.Fee Non Asuransi")
                    $("#dgvParam th[data-field=deskripsi]").html("Subs Percent Fee")
                    grid.showColumn('keterangan');
                    grid.showColumn('jenisSwitchRedempt');
                    $("#dgvParam th[data-field=keterangan]").html("Swc Fee Asuransi")
                    $("#dgvParam th[data-field=jenisSwitchRedempt]").html("Swc Fee Non Asuransi")
                }
                else if (_strTreeInterface == "PFP") {
                    grid.showColumn('deskripsi');
                    grid.hideColumn('tanggalValuta');

                    $("#dgvParam th[data-field=kode]").html("Min Jangka Waktu")
                    $("#dgvParam th[data-field=id]").html("Frek Pendebetan")
                    $("#dgvParam th[data-field=deskripsi]").html("Kelipatan")
                }
                else if (_strTreeInterface == "MSC") {
                    grid.showColumn('deskripsi');
                    grid.hideColumn('tanggalValuta');
                    grid.showColumn('prodId');

                    $("#dgvParam th[data-field=deskripsi]").html("Min Subsc")
                    $("#dgvParam th[data-field=kode]").html("Product")
                    $("#dgvParam th[data-field=prodId]").html("IsEmployee")
                }
                else if (_strTreeInterface == "SWC") {
                    $("#dgvParam th[data-field=deskripsi]").html("Prod SwitchIn")
                    $("#dgvParam th[data-field=kode]").html("Prod SwitchOut")
                    grid.showColumn('minSwitchRedempt');
                    grid.showColumn('jenisSwitchRedempt');
                    grid.showColumn('switchingFeeNonKaryawan');
                    grid.showColumn('switchingFeeKaryawan');
                    grid.hideColumn('tanggalValuta');
                }
                else if (_strTreeInterface == "RPP") {
                    grid.showColumn('desc2');
                    grid.hideColumn('lastUpdate');

                    $("#dgvParam th[data-field=kode]").html("Kode Product")
                    $("#dgvParam th[data-field=deskripsi]").html("Nama Produk")
                    $("#dgvParam th[data-field=desc2]").html("Risk Profile Product")
                }
                else {
                    grid.hideColumn('officeId');
                }

            } else {
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
        var deskripsi = name.indexOf("deskripsi") > -1 || name.indexOf("deskripsi") > -1;
        var desc2 = name.indexOf("desc2") > -1 || name.indexOf("desc2") > -1;
        var tglExpire = name.indexOf("tglExpire") > -1 || name.indexOf("tglExpire") > -1;
        var desc5 = name.indexOf("desc5") > -1 || name.indexOf("desc5") > -1;
        var switchingFeeNonKaryawan = name.indexOf("switchingFeeNonKaryawan") > -1 || name.indexOf("switchingFeeNonKaryawan") > -1;
        var switchingFeeKaryawan = name.indexOf("switchingFeeKaryawan") > -1 || name.indexOf("switchingFeeKaryawan") > -1;
        var minSwitchRedempt = name.indexOf("minSwitchRedempt") > -1 || name.indexOf("minSwitchRedempt") > -1;
        var jenisSwitchRedempt = name.indexOf("jenisSwitchRedempt") > -1 || name.indexOf("jenisSwitchRedempt") > -1;
        return {
            template: tanggalValuta ? "#= kendo.toString(kendo.parseDate(tanggalValuta, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                : lastUpdate ? "#= kendo.toString(kendo.parseDate(lastUpdate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                    : tglExpire ? "#= kendo.toString(kendo.parseDate(tglExpire, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                        : columnNames,
            field: name,
            width: deskripsi ? 350 : desc2 ? 300 : desc5 ? 350 : switchingFeeNonKaryawan ? 250 : switchingFeeKaryawan ? 250 : minSwitchRedempt ? 200 : jenisSwitchRedempt? 200: 150,
            title: name
        };
    })
}

function subSave() {
    var message = 'save';
    var Code, Desc, ProdId, Id, Value;

    if ((_intType == 1) | (_intType == 2)) {
        if (_strTreeInterface != "RSB" && _strTreeInterface != "MSC" && _strTreeInterface != "SWC" && _strTreeInterface != "RPP"
            && _strTreeInterface != "CTR" && _strTreeInterface != "OFF"
        ) {
            Code = $("#txtbSP1").val();
        }
        else {
            Code = $("#cmpsrSearch1_text1").val();
        }
    }
    else {
        Code = "";
        if (_intType == 3 && (_strTreeInterface == "EVT" | _strTreeInterface == "WPR" | _strTreeInterface == "GFM" | _strTreeInterface == "ANP" | _strTreeInterface == "KNP"))
            Code = $("#txtbSP1").val();
        else if (_intType == 3 && (_strTreeInterface == "RSB"))
            Code = $("#cmpsrSearch1_text1").val();
        else if (_intType == 3 && (_strTreeInterface == "PFP"))
            Code = $("#txtbSP1").val();
        else if (_intType == 3 && (_strTreeInterface == "MSC"))
            Code = $("#cmpsrSearch1_text1").val();
        else if (_intType == 3 && (_strTreeInterface == "SWC"))
            Code = $("#cmpsrSearch1_text1").val();
        else if (_intType == 3 && (_strTreeInterface == "RPP"))
            Code = $("#cmpsrSearch1_text1").val();
        else
            Code = $("#txtbSP1").val();
    }

    if (_strTreeInterface == "SWC") {
        Desc = $("#cmpsrSearch2_text1").val() + " #" + $("#txtbSP3").val() + " #" + $("#comboBox1").data("kendoDropDownList").text() + "#" + $("#txtbSP5").val() + "#" + $("#textPctSwc").val();
    }
    else if (_strTreeInterface == "OFF" || _strTreeInterface == "CTR") {
        Desc = $("#cmpsrSearch1_text2").val();
    }
    else {
        if ((_intType == 1) | (_intType == 2) | (_intType == 3)) {
            Desc = $("#txtbSP2").val();
            if (_strTreeInterface == "GFM") {
                if ($("#txtbSP3").val() == "") $("#txtbSP3").val() = "0";
                Desc = Desc + "#" + $("#txtbSP3").val();
            }
            if (_strTreeInterface == "RPP") {
                Desc = $("#comboBox3").data("kendoDropDownList").text();
            }
            if (_strTreeInterface == "RTY") {
                Desc = $("#txtbSP2").val() + "#" + $("#txtbSP3").val();
            }
            if (_strTreeInterface == "RSB") {
                Desc = $("#txtbSP2").val() + "#" + $("#txtbSP3").val() + "#" + $("#textBox1").val() + "#" + $("#textPctSwc").val() + "#" + $("#txtbSP5").val();
            }
            if (_strTreeInterface == "WPR") {
                Desc = $("#txtbSP2").val() + "#" + $("#txtbSP3").val() + "#" + $("#txtbSP4").val() + "#" + $("#dtpSP5").val();
            }
            if (_strTreeInterface == "PFP") {
                Desc = $("#txtbSP2").val() + "#" + $("#txtbSP3").val();
            }
            if (_strTreeInterface == "MNI" || _strTreeInterface == "CTD") {
                Desc = $("#txtbSP2").val() + "#" + $("#txtbSP3").val();
            }
        }
        else {
            Desc = "";
        }
    }

    if (_strTreeInterface == "MSC") {
        if ($("#checkBox1").prop('checked' == true))
            ProdId = "1";
        else
            ProdId = "0";
    }
    if ((_intType == 2) | (_intType == 3)) {
        Id = _Id;
    }
    else {
        Id = 0;
    }

    if ((_intType == 1) | (_intType == 2)) {
        var dtpSP = toDate($("#dtpSP").val());
        Value = dtpSP;
    }
    else {
        if (_strTreeInterface != "SWC") {
            Value = _tanggalValuta;
        }
        else {
            Value = new Date();
        }
    }

    if (_intType == 3)
        message = 'delete';
    else if (_intType == 2)
        message = 'edit';

    swal({
        title: "Are you sure to " + message + " this data?",
        text: "You need to approval from suppervisor!",
        type: "warning",
        showCancelButton: true,
        confirmButtonClass: 'btn-warning',
        confirmButtonText: "Yes, " + message + " it!",
        closeOnConfirm: true
    },
        function Confirm () {
            var model = JSON.stringify({
                'Type': _intType,
                'InterfaceId': _strTreeInterface,
                'Code': Code,
                'Desc': Desc,
                'OfficeId': '',
                'ProdId': ProdId,
                'Id': Id,
                'Value': Value,
                'NIK': 0,
                'Guid': ''
            });

            console.log(model);

            $.ajax({
                type: "POST",
                data: model,
                url: '/Parameter/MaintainParamGlobal',
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                beforeSend: function () {
                    $("#load_screen").show();
                },
                success: function (data) {
                    if (data.blnResult == true) {
                        setTimeout(function () { swal("Success!", "Your data need to approve by supervisor", "success") }, 500);
                        _intType = 0;
                        subResetToolBar();
                        subRefresh();
                    }
                    else {
                        setTimeout(function () { swal("Warning", data.strErrMsg, "warning") }, 500);
                    }
                },
                complete: function () {
                    $("#load_screen").hide();
                }
            });
        });
}

function subDelete() {
    _intType = 3;
    if (_Id > 0) {
        subSave();
    } else {
        swal("Warning", "Tidak ada data yang dipilih","warning");
    }
}

function subUpdate() {
    var grid = $("#dgvParam").data("kendoGrid");
    var rows = 0
    grid.refresh();
    grid.tbody.find("tr[role='row']").each(function () {
        rows = rows + 1;
    })
    if (rows > 0) {
        _intType = 2;
        switch (_strTreeInterface) {
            case "PAR":
                $("#txtbSP1").prop('disabled', true);
                $("#txtbSP2").prop('disabled', true);
                $("#dtpSP").data("kendoDatePicker").enable(false);
                break;
            case "MNI":
                $("#txtbSP1").prop('disabled', true);
                $("#txtbSP2").prop('disabled', false);
                $("#dtpSP").data("kendoDatePicker").enable(false);
                $("#txtbSP3").prop('disabled', false);
                break;
            case "CTD":
                $("#txtbSP1").prop('disabled', true);
                $("#txtbSP2").prop('disabled', false);
                $("#dtpSP").data("kendoDatePicker").enable(false);
                $("#txtbSP3").prop('disabled', false);
                break;
            case "RTY":
                $("#txtbSP1").prop('disabled', true);
                $("#txtbSP2").prop('disabled', false);
                $("#txtbSP3").prop('disabled', false);
                $("#dtpSP").data("kendoDatePicker").enable(false);
                break;
            case "GFM":
                $("#txtbSP1").prop('disabled', true);
                $("#txtbSP2").prop('disabled', false);
                $("#dtpSP").data("kendoDatePicker").enable(false);
                $("#txtbSP3").prop('disabled', false);
                break;
            case "WPR":
                $("#txtbSP1").prop('disabled', true);
                $("#txtbSP2").prop('disabled', false);
                $("#dtpSP5").data("kendoDatePicker").enable(true);
                $("#textPctSwc").prop('disabled', true);
                break;
            case "PFP":
                $("#txtbSP1").prop('disabled', true);
                $("#txtbSP2").prop('disabled', false);
                $("#txtbSP3").prop('disabled', false);
                break;
            case "MSC":
                $("#cmpsrSearch1_text1").prop('disabled', true);
                $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
                $("#txtbSP2").prop('disabled', false);
                $("#checkBox1").prop('disabled', true);
                break;
            case "RSB":
                $("#txtbSP2").prop('disabled', false);
                $("#cmpsrSearch1_text1").prop('disabled', true);
                $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
                $("#txtbSP3").prop('disabled', false);
                $("#textBox1").prop('disabled', false);
                $("#txtbSP5").prop('disabled', false);
                $("#textPctSwc").prop('disabled', false);
                break;
            case "SWC":
                $("#cmpsrSearch1_text1").prop('disabled', true);
                $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
                $("#cmpsrSearch2_text1").prop('disabled', true);
                $("#cmpsrSearch2").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');

                $("#txtbSP3").prop('disabled', false);
                $("#txtbSP4").prop('disabled', false);
                $("#txtbSP5").prop('disabled', false);
                $("#comboBox1").data("kendoDropDownList").enable(true);
                $("#comboBox2").data("kendoDropDownList").enable(true);
                $("#textPctSwc").prop('disabled', false);
                break;
            case "RPP":
                $("#cmpsrSearch1_text1").prop('disabled', true);
                $("#cmpsrSearch1").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
                $("#comboBox3").data("kendoDropDownList").enable(true);
                break;
            default:
                $("#txtbSP1").prop('disabled', true);
                $("#txtbSP2").prop('disabled', false);
                $("#dtpSP").data("kendoDatePicker").enable(false);
                break;
        }
        subResetToolBar();
    }
    else {
        swal("Warning", "Tidak ada data yang dapat di update", "warning");
    }
}

function subCancel() {
    _intType = 0;
    subResetToolBar();
    subRefresh();
}

function subRefreshWARPED(NIK) {
    $.ajax({
        type: "GET",
        data: { NIK: NIK },
        url: '/Parameter/RefreshWARPED',
        dataType: "json",
        success: function (data) {
            $("#txtbSP3").val(data.Name);
            $("#txtbSP4").val(data.JobTittle);
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

function Puntos(strValor, intNumDecimales) {
    $.ajax({
        type: "GET",
        data: { strValor: strValor, intNumDecimales: intNumDecimales },
        url: '/Parameter/Puntos',
        success: function (data) {
            $("#txtbSP3").val(data.strAux);
        }
    });
}
