$("#btnRefresh").click(function () {
    subRefresh();
});

$("#btnProcess").click(function () {
    subApprove();
});

$("#btnReject").click(function () {
    subReject();
});


function onRowPeriodSelect() {
    var data = this.dataItem(this.select());
    logId = data.logId;
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/NFSFileCekPendingOtorisasi',
        data: { TypeGet: 'G', LogId: logId },
        success: function (data) {
            if (data.blnResult) {
                var gridView = $("#dgMain").data("kendoGrid");
                var gridData = populateGridMain(data.dsResult.table);
                gridView.setOptions(gridData);
                gridView.dataSource.page(1);
                gridView.select("tr:eq(0)");

                xmlGenerateData = data.generateData;
                sSeparator = data.fieldSeparator;
                sFormatFile = data.formatFile;
                sFilterFile = data.filterFileDialog;
                sFileName = data.fileName;

                $("#dgMain th[data-field=noCIF]").html("No CIF")
                $("#dgMain th[data-field=namaPerusahaan]").html("Nama Perusahaan")
                $("#dgMain th[data-field=noSIUP]").html("No SIUP")
                $("#dgMain th[data-field=sid]").html("SID")
                $("#dgMain th[data-field=noSKD]").html("No SKD")
                $("#dgMain th[data-field=alamatPerusahaan]").html("Alamat Perusahaan")


                gridView.hideColumn('generateData');
                gridView.hideColumn('fieldSeparator');
                gridView.hideColumn('formatFile');
                gridView.hideColumn('filterFileDialog');
                gridView.hideColumn('fileName');
            } else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
};

function onRowMainSelect() {
    var data = this.dataItem(this.select());
    $.ajax({
        type: 'GET',
        url: '/Otorisasi/NFSCekPendingDetailOtorisasi',
        data: { CIFNo: data.noCIF, LogId: logId },
        success: function (data) {
            if (data.blnResult) {
                var gridView = $("#dgDetail").data("kendoGrid");
                var gridData = populateGridDetail(data.dsResult.table);
                gridView.setOptions(gridData);

                $("#dgDetail th[data-field=field]").html("Field")
                $("#dgDetail th[data-field=oldValue]").html("Old Value")
                $("#dgDetail th[data-field=newValue]").html("New Value")
            } else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
};   
