$("#btnGenerate").click(function () {
    var file = '';
    var jenis = '';

    if ($("#comboBox1").val() == "Individu") {
        file = "NSPIND";
        jenis = "A";
    }
    else if (comboBox1.val == "Institusi") {
        file = "NSPINS";
        jenis = "B";
    }

    $.ajax({
        type: 'POST',
        url: '/Report/ReportKYCGenFile',
        data: { File: file, Jenis: jenis, Bulan: $("#_bulancombo").val(), Tahun: $("#_tahuntxt").val() },
        success: function (data) {
            if (data.blnResult) {
                window.location = '/Report/Download?fileGuid=' + data.FileGuid
                    + '&filename=' + data.FileName;
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
    });
});