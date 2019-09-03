var intMyType;
$(document).ready(function () {
    intMyType = "B";
    SetToolbar(intMyType);
    SetControl(intMyType);
    subRefresh();

    var grid = {
        height: 200
    };
    $("#dataGridView1").kendoGrid(grid);
});

function subRefresh() {
    $.ajax({
        type: 'GET',
        url: '/IBMB/RefreshKinerjaProduk',
        success: function (data) {
            if (data.blnResult) {
                var gridView = $("#dataGridView1").data("kendoGrid");
                var gridData = populateGrid(data.listKinerjaProduk);

                gridView.setOptions(gridData);
                gridView.dataSource.page(1);
                gridView.select("tr:eq(0)");
                gridView.hideColumn('ProdId');
                gridView.hideColumn('NIK');
                gridView.hideColumn('Module');
                gridView.hideColumn('ProcessType');

                $("#dataGridView1 th[data-field=ProdCode]").html("Product Code")
                $("#dataGridView1 th[data-field=ProdName]").html("Product Name")
                $("#dataGridView1 th[data-field=ProdCCY]").html("Product Currency")
                $("#dataGridView1 th[data-field=TypeName]").html("Tipe Reksadana")
                $("#dataGridView1 th[data-field=ValueDate]").html("Date Value")
                intMyType = "R";
                SetToolbar(intMyType);
                SetControl(intMyType);
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
}

function subSave() {
    if ($("#_cmpsrProduct_text1").val() == "") {
        swal("Warning", "Product belum dipilih!", "warning");
        return;
    }

    if ($("#_sehari").val() > 100) {
        swal("Warning", "Persentase Kinerja Sehari tidak boleh lebih besar dari 100%!", "warning");
        return;
    }
    if ($("#_seminggu").val() > 100) {
        swal("Warning", "Persentase Kinerja Seminggu tidak boleh lebih besar dari 100%!", "warning");
        return;
    }
    if ($("#_sebulan").val() > 100) {
        swal("Warning", "Persentase Kinerja Sebulan tidak boleh lebih besar dari 100%!", "warning");
        return;
    }
    if ($("#_setahun").val() > 100) {
        swal("Warning", "Persentase Kinerja Setahun tidak boleh lebih besar dari 100%!", "warning");
        return;
    }

    var res = subProcess();
    res.success(function (data) {
        if (data.blnResult) {
            intMyType = "S";
            SetToolbar(intMyType);
            SetControl(intMyType);
            subReset();
            swal("Success", "Proses simpan data berhasil! Membutuhkan otorisasi oleh supervisor agar perubahan tersebut aktif.", "success");
        }
        else {
            swal("Warning", data.ErrMsg, "warning");
        }
    });
}

function subProcess() {
    var ValueDate = toDate($("#_NAVDate").val());
    var model = JSON.stringify({
        'ProdId': $("#ProdId").val(),
        'NIK': 0,
        'Module': '',
        'IsVisible': $("#_isVisible").prop('checked'),
        'Sehari': $("#_sehari").data("kendoNumericTextBox").value(),
        'Seminggu': $("#_seminggu").data("kendoNumericTextBox").value(),
        'Sebulan': $("#_sebulan").data("kendoNumericTextBox").value(),
        'Setahun': $("#_setahun").data("kendoNumericTextBox").value(),
        'ValueDate': ValueDate,
        'ProcessType': intMyType
    });

    return $.ajax({
        type: 'POST',
        url: '/IBMB/MaintainKinerjaProduk',
        data: model,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        async: false
    });
}

function subUpdate() {
    if ($("#_cmpsrProduct_text1").val() == "") {
        swal("Warning", "Produk harap dipilih dulu!", "warning");
        return;
    }
    intMyType = "U";
    SetControl(intMyType);
    SetToolbar(intMyType);
}

function subCancel() {
    intMyType = "B";
    SetControl(intMyType);
    SetToolbar(intMyType);
    Reset();
}

function SetControl(intMyType) {
    if (intMyType == "R" || intMyType == "B" || intMyType == "S") {
        $("#_cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#_cmpsrProduct_text1").prop('disabled', true);

        $("#_isVisible").prop('disabled', true);
        $("#_sehari").data("kendoNumericTextBox").enable(false);
        $("#_seminggu").data("kendoNumericTextBox").enable(false);
        $("#_setahun").data("kendoNumericTextBox").enable(false);
        $("#_sebulan").data("kendoNumericTextBox").enable(false);
    }

    if (intMyType == "U") {
        $("#_cmpsrProduct").attr('class', 'btn btn-default btn-sm btn-search-component src-cif disabled');
        $("#_cmpsrProduct_text1").prop('disabled', true);

        $("#_isVisible").prop('disabled', false);
        $("#_sehari").data("kendoNumericTextBox").enable(true);
        $("#_seminggu").data("kendoNumericTextBox").enable(true);
        $("#_setahun").data("kendoNumericTextBox").enable(true);
        $("#_sebulan").data("kendoNumericTextBox").enable(true);
    }
}

function SetToolbar(intMyType) {
    if (intMyType == "B" || intMyType == "S") {
        $("#btnRefresh").show();
        $("#btnEdit").show();
        $("#btnSave").hide();
        $("#btnCancel").hide();
    }
    if (intMyType == "U") {
        $("#btnRefresh").show();
        $("#btnEdit").hide();
        $("#btnSave").show();
        $("#btnCancel").show();
    }
    if (intMyType == "R") {
        $("#btnRefresh").show();
        $("#btnEdit").show();
        $("#btnSave").hide();
        $("#btnCancel").hide();
    }
}

function subReset() {
    $("#_cmpsrProduct_text1").val('');
    $("#_cmpsrProduct_text2").val('');

    $("#_matauang").val('');
    var Today = new Date();
    $("#_NAVDate").val(Today.getDate() + '/' + (Today.getMonth() + 1) + '/' + Today.getFullYear());
    $("#_tipeReksadana").val('');
    $("#_isVisible").prop('checked', false);
    $("#_sehari").data("kendoNumericTextBox").value(0);
    $("#_seminggu").data("kendoNumericTextBox").value(0);
    $("#_setahun").data("kendoNumericTextBox").value(0);
    $("#_sebulan").data("kendoNumericTextBox").value(0);
}

function toDate(dateStr) {
    var [day, month, year] = dateStr.split("/")
    return new Date(Date.UTC(year, month - 1, day))
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
            change: onRowKinerjaSelect,
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
        var ProdCode = name.indexOf("ProdCode") > -1 || name.indexOf("ProdCode") > -1;
        var ProdName = name.indexOf("ProdName") > -1 || name.indexOf("ProdName") > -1;
        var ProdCCY = name.indexOf("ProdCCY") > -1 || name.indexOf("ProdCCY") > -1;
        var TypeName = name.indexOf("TypeName") > -1 || name.indexOf("TypeName") > -1;
        var ValueDate = name.indexOf("ValueDate") > -1 || name.indexOf("ValueDate") > -1;
        var IsVisible = name.indexOf("IsVisible") > -1 || name.indexOf("IsVisible") > -1;
        return {
            field: name,
            width: ProdCode ? 110 : ProdName ? 350 : ProdCCY ? 150 : TypeName ? 300 : ValueDate ? 180 : IsVisible ? 80 : 100,
            title: name,
            template:
                ValueDate ? "#= kendo.toString(kendo.parseDate(ValueDate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #" :
                    IsVisible ? "<input disabled type='checkbox' " +
                        "# if (IsVisible) { #" +
                        "checked='checked'" +
                        "# } #"
                        : columnNames,
        };
    })
}

function ValidateProduct(ProdCode, result) {
    $.ajax({
        type: 'GET',
        url: '/Global/ValidateProduct',
        data: { Col1: ProdCode, Col2: '', Validate: 1 },
        success: function (data) {
            if (data.length != 0) {
                result(data[0].ProdId);
            }
            else {
                result('');
            }
        }
    });
} 