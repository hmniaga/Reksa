

$("#btnGetXML").click(function btnGetXML_click() {
    subUpload();
});

function onChange_cmbTipe() {
    subResetAll(0);
    var strTipeValue = "";
    if ($("#cmbTipe").data("kendoDropDownList").text() == "Sinkronisasi Transaksi") {
        strTipeValue = "Transaksi";
    }
    else if ($("#cmbTipe").data("kendoDropDownList").text() == "Sinkronisasi OS By Shareholder ID") {
        strTipeValue = "OSUnitShareholderID";
    }
    else if ($("#cmbTipe").data("kendoDropDownList").text() == "Sinkronisasi OS By Client Code") {
        strTipeValue = "OSUnitClientCode";
    }
    
    $.ajax({
        type: 'GET',
        url: '/PO/GetFileColumns',
        data: { FileType: strTipeValue},
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                var columns = [];
                for (var i = 0; i < data.dsResult.table.length; i += 1) {
                    columns[i] = {};
                    columns[i]["field"] = (data.dsResult.table)[i].columnName;
                    columns[i]["width"] = 150;
                }
                var grid = $("#dgvPreview").data("kendoGrid");
                var dataSource = new kendo.data.DataSource();
                grid.setOptions({
                    dataSource: dataSource,
                    columns: columns,
                    pageable: true,
                    selectable: true,
                    height: 300
                });
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
function onBound_cmbTipe() {
    var dropdownlist = $("#cmbTipe").data("kendoDropDownList");
    var len = dropdownlist.dataSource.data().length;
    if (len > 0) {
        dropdownlist.select(0);
        onChange_cmbTipe();
    }
}

function onChange_cmbFormat()
{
    if ($("#cmbFormat").data("kendoDropDownList").text() == "Delimited")
    {
        $("#txtbDelimiter").prop('disabled', false);
    }
    else {
        $("#txtbDelimiter").prop('disabled', true);
    }
}

function onBound_cmbFormat() {
    var dropdownlist = $("#cmbFormat").data("kendoDropDownList");
    var len = dropdownlist.dataSource.data().length;

    if (len > 0) {
        dropdownlist.select(0);
        onChange_cmbFormat();
    }
}