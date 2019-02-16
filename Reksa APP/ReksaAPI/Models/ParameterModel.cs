using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class ParameterModel
    {
        public int Id { get; set; }
        public string Kode { get; set; }
        public string Deskripsi { get; set; }
        public string OfficeId { get; set; }
        public System.DateTime TanggalValuta { get; set; }
    }

    public class ReksaParamFeeSubs
    {
        public string trxType { get; set; }
        public int prodId { get; set; }
        public decimal minPctFeeEmployee { get; set; }
        public decimal maxPctFeeEmployee { get; set; }
        public decimal minPctFeeNonEmployee { get; set; }
        public decimal maxPctFeeNonEmployee { get; set; }
    }

    public class ReksaTieringNotificationSubs
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public decimal PercentFrom { get; set; }
        public decimal PercentTo { get; set; }
        public string MustApproveBy { get; set; }
    }

    public class ReksaListGLFeeSubs
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public int Sequence { get; set; }
        public string GLName { get; set; }
        public int GLNumber { get; set; }
        public decimal Percentage { get; set; }
        public string OfficeId { get; set; }
    }

    //NIco

    public class ReksaParamMFee
    {
        public string trxType { get; set; }
        public int prodId { get; set; }
        public int PeriodEfektif { get; set; }

    }

    public class ReksaProductMFee
    {
        public decimal AUMMin { get; set; }
        public decimal AUMMax { get; set; }
        public decimal NISPPct { get; set; }
        public decimal FundMgrPct { get; set; }
        public decimal MaintenanceFee { get; set; }
    }

    public class ReksaListGLMFee
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public int Sequence { get; set; }
        public string GLName { get; set; }
        public int GLNumber { get; set; }
        public decimal Percentage { get; set; }
        public string OfficeId { get; set; }
    }


    //end Nico


}
