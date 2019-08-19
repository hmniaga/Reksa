var _tranGuid;

$(document).ready(function () {
    var grid = {
        height: 200
    };
    $("#dataGridView1").kendoGrid(grid);
    //PopulateWSParameter();
    PopulateData();
});

function PopulateData() {
    $.ajax({
        type: 'GET',
        url: '/PO/PopulateJurnalRTGS',
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
                grid.hideColumn('tranGuid');
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
            change: dataGridView1_Click,
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
        var beneficiaryName = name.indexOf("beneficiaryName") > -1 || name.indexOf("beneficiaryName") > -1;
        var beneficiaryBankName = name.indexOf("beneficiaryBankName") > -1 || name.indexOf("beneficiaryBankName") > -1;
        var paymentDetails2 = name.indexOf("paymentDetails2") > -1 || name.indexOf("paymentDetails2") > -1;
        var tranDate = name.indexOf("tranDate") > -1 || name.indexOf("tranDate") > -1;
        return {
            template: tranDate ? "#= kendo.toString(kendo.parseDate(tranDate, 'yyyy-MM-dd'), 'dd/MM/yyyy') #"
                : columnNames,
            field: name,
            width: beneficiaryName ? 350 : beneficiaryBankName ? 300 : paymentDetails2? 350: 150,
            title: name
        };
    })
}
function dataGridView1_Click()
{
    var data = this.dataItem(this.select());
    _tranGuid = data.tranGuid;
}

function onBounddataGridView1() {
    var grid = $("#dataGridView1").data("kendoGrid");
    var len = grid.dataSource.data().length;

    if (len > 0) {
        grid.select(0);
    }
}

function Reject() {
    $.ajax({
        type: 'POST',
        url: '/PO/RejectJurnalRTGS',
        data: { Guid1: _tranGuid },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                swal("Success", "Berhasil melakukan reject data!", "success");
                PopulateData();
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

function Process() {
    $.ajax({
        type: 'POST',
        url: '/PO/Process',
        data: { Guid1: _tranGuid },
        beforeSend: function () {
            $("#load_screen").show();
        },
        success: function (data) {
            if (data.blnResult) {
                if (data._intClassificationId == 71) {
                    swal("Success", "Berhasil diproses. Harap lakukan otorisasi supervisor agar efektif!", "success");
                }
                else if (data._intClassificationId == 72) {
                    if (data.strResult != "") {
                        swal("Success", "Berhasil dilakukan jurnal RTGS dengan Remittance Number : " + data.strResult, "success");
                    }
                    else {
                        swal("Warning", data.ErrMsg, "warning");
                    }
                }
                PopulateData();
            }
            else {
                swal("Warning", data.ErrMsg, "warning");
            }
        }
        , complete: function () {
            $("#load_screen").hide();
        }
    });
}

