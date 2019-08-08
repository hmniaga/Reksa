
$(document).ready(function load() {
    callReksaGetLastFeeDate();    
});

async function callReksaGetLastFeeDate() {
    var data = await subcallReksaGetLastFeeDate();
    if (data.blnResult) {
        var dtStartDate = new Date(data.dtStartDate);
        $("#dateTimePicker1").val(pad((dtStartDate.getDate()), 2) + '/' + pad((dtStartDate.getMonth() + 1), 2) + '/' + dtStartDate.getFullYear());

    }
    else {
        swal("Warning", data.ErrMsg, "warning");
    }
}

function subcallReksaGetLastFeeDate() {
    return new Promise((resolve, reject) => {
        $.ajax({
            type: 'GET',
            url: '/PO/GetLastFeeDate',
            data: { Type: 2, ManId: 0, ProdId: 0 },
            beforeSend: function () {
                $("#load_screen").show();
            },
            success: function (data) {
                resolve({
                    blnResult: data.blnResult,
                    ErrMsg: data.ErrMsg,
                    dtStartDate: data.dtStartDate
                })
            },
            error: reject,
            complete: function () {
                $("#load_screen").hide();
            }
        })
    })
}

function callReksaCutRedempFee() {
    $.ajax({
        type: 'POST',
        url: '/PO/ProsesCutRedempFee',
        data: { StartDate: $("#dateTimePicker1").val(), EndDate: $("#dateTimePicker2").val()},
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                swal("Success", "Proses Cut Redemption berhasil", "success");
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
