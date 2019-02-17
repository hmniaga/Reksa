using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class CalculateFeeModel
    {
        public class GlobalFeeRequest
        {
            public int ProdId { get; set; }
            public int ClientId { get; set; }
            public int TranType { get; set; }
            public decimal TranAmt { get; set; }
            public decimal Unit { get; set; }
            public int NIK { get; set; }
            public string Guid { get; set; }
            public decimal NAV { get; set; }
            public bool FullAmount { get; set; }
            public bool IsByPercent { get; set; }
            public bool IsFeeEdit { get; set; }
            public decimal PercentageFeeInput { get; set; }
            public bool Process { get; set; }
            public bool ByUnit { get; set; }
            public bool Debug { get; set; }
            public int ProcessTranId { get; set; }
            public int OutType { get; set; }
            public DateTime ValueDate { get; set; }
            public string CIFNo { get; set; }
        }
        public class GlobalFeeResponse
        {
            public string FeeCCY { get; set; }
            public decimal Fee { get; set; }
            public decimal PercentageFeeOutput { get; set; }
            public decimal FeeBased { get; set; }
            public decimal RedempUnit { get; set; }
            public decimal RedempDev { get; set; }
            public string ErrMsg { get; set; }
            public decimal TaxFeeBased { get; set; }
            public decimal FeeBased3 { get; set; }
            public decimal FeeBased4 { get; set; }
            public decimal FeeBased5 { get; set; }
            public int Period { get; set; }
            public int IsRDB { get; set; }
        }
        public class SwitchingRequest
        {
            public string ProdSwitchOut { get; set; }
            public string ProdSwitchIn { get; set; }
            public bool Jenis { get; set; }
            public decimal TranAmt { get; set; }
            public decimal Unit { get; set; }
            public int NIK { get; set; }
            public string Guid { get; set; }
            public decimal NAV { get; set; }
            public bool IsEdit { get; set; }
            public decimal PercentageInput { get; set; }
            public string IsEmployee { get; set; }
        }
        public class SwitchingResponses
        {
            public string FeeCCY { get; set; }
            public decimal Fee { get; set; }
            public decimal PercentageOutput { get; set; }
        }
        public class SwitchingRDBRequest
        {
            public int ProdSwitchOut { get; set; }
            public int ClientSwitchOut { get; set; }
            public decimal Unit { get; set; }
            public int NIK { get; set; }
            public string Guid { get; set; }
            public bool IsEdit { get; set; }
            public decimal PercentageInput { get; set; }
        }
        public class SwitchingRDBResponses
        {
            public string FeeCCY { get; set; }
            public decimal Fee { get; set; }
            public decimal PercentageOutput { get; set; }
        }
    }
}
