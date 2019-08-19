var intMyType;
$(document).ready(function () {
    var grid = {
        height: 200
    };
    $("#dataGridView1").kendoGrid(grid);
    $('#_cmpsrProduct').attr('href', '/Global/SearchProduct');
    intMyType = "B";
    SetToolbar(intMyType);
    SetControl(intMyType);
    subRefresh();
});

function SetControl(intMyType)
{
    if (intMyType == "R" || intMyType == "B" || intMyType == "D" || intMyType == "S") {
        //textBox1.Enabled = false;
        //dataGridView1.Enabled = true;
        $("#_cmpsrProduct_text1").prop('disabled', true);
        $("#_cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#comboBox1").data('kendoDropDownList').enable(false);
        $("#txtbPath").prop('disabled', true);        
    }

    if (intMyType == "A") {
        $("#_cmpsrProduct_text1").prop('disabled', false);
        $("#_cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif enabled');
        $("#comboBox1").data('kendoDropDownList').enable(true);
        $("#txtbPath").prop('disabled', false);     
        //dataGridView1.Enabled = false;
    }
    if (intMyType == "U") {
        $("#_cmpsrProduct_text1").prop('disabled', true);
        $("#_cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#comboBox1").data('kendoDropDownList').enable(false);
        $("#txtbPath").prop('disabled', false);   
        //dataGridView1.Enabled = false;
    }
}
function SetToolbar(intMyType)
{
    if (intMyType == "B" || intMyType == "S" || intMyType == "D") {
        document.getElementById("btnRefresh").disabled = false;
        document.getElementById("btnNew").disabled = false;
        document.getElementById("btnEdit").disabled = false;
        document.getElementById("btnDelete").disabled = false;
        document.getElementById("btnSave").disabled = true;
        document.getElementById("btnCancel").disabled = true;
    }
    if (intMyType == "A") {
        document.getElementById("btnRefresh").disabled = false;
        document.getElementById("btnNew").disabled = true;
        document.getElementById("btnEdit").disabled = true;
        document.getElementById("btnDelete").disabled = true;
        document.getElementById("btnSave").disabled = false;
        document.getElementById("btnCancel").disabled = false;
    }

    if (intMyType == "U") {
        document.getElementById("btnRefresh").disabled = false;
        document.getElementById("btnNew").disabled = true;
        document.getElementById("btnEdit").disabled = true;
        document.getElementById("btnDelete").disabled = true;
        document.getElementById("btnSave").disabled = false;
        document.getElementById("btnCancel").disabled = false;
    }
    if (intMyType == "R") {
        document.getElementById("btnRefresh").disabled = false;
        document.getElementById("btnNew").disabled = false;
        document.getElementById("btnEdit").disabled = false;
        document.getElementById("btnDelete").disabled = false;
        document.getElementById("btnSave").disabled = true;
        document.getElementById("btnCancel").disabled = true;
    }
}

function Reset(Jenis) {
    if (Jenis != "1") {
        $("#_cmpsrProduct_text1").val('');
    }
    $("#_cmpsrProduct_text2").val('');
    //comboBox1.Text = "";
    //comboBox1.SelectedIndex = -1;
    //textBox1.Text = "";
} 
function subNew()
{
    intMyType = "A";
    SetControl(intMyType);
    SetToolbar(intMyType);
    Reset("2");

}
function subUpdate()
{
    if ($("#_cmpsrProduct_text1").val() == "") {
        swal("Warning", "Produk belum dipilih!", "warning");
        return;
    }

    intMyType = "U";
    SetControl(intMyType);
    SetToolbar(intMyType);

}
function subDelete()
{
    if ($("#_cmpsrProduct_text1").val() == "") {
        swal("Warning", "Produk belum dipilih!", "warning");
        return;
    }
    subProcess("D");
}
function subCancel()
{
    intMyType = "B";
    SetControl(intMyType);
    SetToolbar(intMyType);
    Reset("2");
}
function subSave()
{
    if ($("#_cmpsrProduct_text1").val() == "") {
        swal("Warning", "Produk belum dipilih!", "warning");
        return;
    }
    if ($("#comboBox1").data("kendoDropDownList").text() == "") {
        swal("Warning", "Jenis Kebutuhan PDF belum dipilih!", "warning");
        return;
    }

    if ($("#txtbPath").val() == "") {
        swal("Warning", "URL PDF belum dipilih!", "warning");
        return;
    }

    subProcess(intMyType);
}

function subProcess(intMyType) {
    var sFileName = document.getElementById('txtbPath');
    $.ajax({
        type: 'POST',
        url: '/IBMB/MaintainUploadPDF',
        data: { ProdId: $("#ProdId").val(), JenisKebutuhanPDF: $("#comboBox1").data("kendoDropDownList").text(), FilePath: sFileName.files[0].name, ProcessType: intMyType },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                swal("Success", "Proses simpan data berhasil! Membutuhkan otorisasi oleh supervisor agar perubahan tersebut aktif", "success");
                intMyType = "S";
                SetToolbar(intMyType);
                SetControl(intMyType);
                Reset("2");
            }
            else {
                setTimeout(function () { swal("Warning", data.ErrMsg, "warning") }, 500);
            }
        }
        , complete: function () {
            $("#load_screen").hide();
        }
    });
}
function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/IBMB/RefreshUploadPDF',
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
                //grid.hideColumn('tranGuid');
                $("#dataGridView1 th[data-field=prodCode]").html("Product Code")
                $("#dataGridView1 th[data-field=prodName]").html("Product Name")
                $("#dataGridView1 th[data-field=typePDF]").html("Type PDF")
                $("#dataGridView1 th[data-field=filePath]").html("File Path")

                intMyType = "R";
                SetToolbar(intMyType);
                SetControl(intMyType);
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }, complete: function () {
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
            change: dataGridView1_RowEnter,
            databound: onBounddataGridView1,
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
        var filePath = name.indexOf("filePath") > -1 || name.indexOf("filePath") > -1;
        return {
            //template: tranDate ? "#= kendo.toString(kendo.parseDate(tranDate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
            //    : columnNames,
            field: name,
            width: filePath? 500 : 150,
            title: name
        };
    })
}

function dataGridView1_RowEnter() {
    var data = this.dataItem(this.select());
    $("#_cmpsrProduct_text1").val(data.prodCode);
    $("#_cmpsrProduct_text2").val(data.prodName);
    if (data.typePDF == "Fund Fact Sheet") {
        $("#comboBox1").data('kendoDropDownList').value("0");
    }
    else if (data.typePDF == "Prospectus") {
        $("#comboBox1").data('kendoDropDownList').value("1");
    }
    
}
function onBounddataGridView1(){
    var grid = $("#dataGridView1").data("kendoGrid");
    var len = grid.dataSource.data().length;

    if (len > 0) {
        grid.select(0);
    }
}