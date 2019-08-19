$(document).ready(function () {

    var grid = {
        height: 200
    };
    $("#dataGridAgentAsal").kendoGrid(grid);
    $("#dataGridAgentTujuan").kendoGrid(grid);

    var url = "/Global/SearchOffice/?criteria=ASAL";
    $('#srcCabangAsal').attr('href', url);
    var url = "/Global/SearchOffice/?criteria=TUJUAN";
    $('#srcCabangTujuan').attr('href', url);
});

function PopulateAgentCode(OfficeId) {
    return new Promise((resolve, reject) => {
        $.ajax({
            type: 'GET',
            url: '/Parameter/PopulateAgentCode',
            data: { OfficeId: OfficeId },
            beforeSend: function () {
                $("#load_screen").show();
            },
            success: function (data) {
                resolve({
                    blnResult: data.blnResult,
                    ErrMsg: data.ErrMsg,
                    dsResult: data.dsResult
                })
            },
            error: reject,
            complete: function () {
                $("#load_screen").hide();
            }
        })
    })
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
            //change: dataGridView1_Click,
            //databound: onBounddataGridView1,
            columns: columns,
            pageable: true,
            selectable: true,
            height: 300
        };
    } 
}
function generateColumns(response) {
    var columnNames = Object.keys(response[0]);
    return columnNames.map(function (name) {
        return {
            field: name,
            width: 150,
            title: name
        };
    })
}

function subProcess() {
    if ($("#srcCabangAsal_text1").val() == '') {
        swal("Warning", "Office Asal hrs diisi!", "warning");
        return;
    }
    if ($("#srcCabangTujuan_text1").val() == '') {
        swal("Warning", "Office Tujuan hrs diisi!", "warning");
        return;
    }
        $.ajax({
            type: "POST",
            url: "/Parameter/PindahOffice",
            data: { OfficeAsal: $("#srcCabangAsal_text1").val(), OfficeTujuan: $("#srcCabangTujuan_text1").val() },
            beforeSend: function () {
                $("#load_screen").show();
            },
            success: function (data) {
                if (data.blnResult) {
                    swal("Success", "Proses berhasil. Client code office asal akan dipindah ke office tujuan jika sudah diotorisasi", "success");
                    Reset();
                } else {
                    swal("Warning", data.ErrMsg, "warning");
                }
            },
            complete: function () {
                $("#load_screen").hide();
            }
        });    
}
function Reset()
{
    $("#srcCabangAsal_text1").val('');
    $("#srcCabangAsal_text2").val('');
    $("#srcCabangTujuan_text1").val('');
    $("#srcCabangTujuan_text2").val('');
}