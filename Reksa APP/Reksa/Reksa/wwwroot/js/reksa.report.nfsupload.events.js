$("#btnGenerate").click(function () {
    if ($("#btnGenerate").text() == "Generate") {
        var sFileCode = $("#cmbFileType").data('kendoDropDownList').value();
        var iTranDate = $("#dtTranDate").val();
        GenerateFileUpload(sFileCode, iTranDate);
    }
    else {
        SubSave();
    }
});


function onChangeFileType(e) {
    var dropdownlist = $("#cmbFileType").data("kendoDropDownList");
    Code = dropdownlist.value();
}

function onBoundFileType(e) {
    var dropdownlist = $("#cmbFileType").data("kendoDropDownList");
    var len = dropdownlist.dataSource.data().length;

    if (len > 0) {
        dropdownlist.select(0);
        onChangeFileType();
    }

}

function onChangeFileAction(e) {
    var dropdownlist = $("#cmbFileAction").data("kendoDropDownList");
    Type = dropdownlist.text();
    if (Type == "UPLOAD") {
        $("#btnGenerate").attr('class', 'btn btn-default waves-effect waves-light');
        $("#btnGenerate").html('<span class="btn-label"><i class= "fa fa-cog"></i></span >Generate');
        $("#labelFileName").text("Transaction Date");
        $('#txtFilePath').attr('style', 'display:none;');
        $('#dateTrx').attr('style', '');
    }
    else {
        $("#btnGenerate").attr('class', 'btn btn-warning waves-effect waves-light');
        $("#btnGenerate").html('<span class="btn-label"><i class= "fa fa-save"></i></span >Save Data');
        $("#labelFileName").text("File Name");
        $('#txtFilePath').attr('style', '');
        $('#dateTrx').attr('style', 'display:none;');
    }

    $.ajax({
        type: 'GET',
        url: '/Report/GetFileTypeList',
        data: { FileType: Type },
        success: function (data) {
            $("#cmbFileType").kendoDropDownList({
                dataTextField: "FileDesc",
                dataValueField: "FileCode",
                dataSource: data,
                change: onChangeFileType,
                dataBound: onBoundFileType,
                height: 200
            });
        }
    });
}

function onBoundFileAction(e) {
    var dropdownlist = $("#cmbFileAction").data("kendoDropDownList");
    var len = dropdownlist.dataSource.data().length;

    if (len > 0) {
        dropdownlist.select(0);
        onChangeFileAction();
    }
}
