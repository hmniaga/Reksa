using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class TransactionSwitchingNonRDBModel
    {
        public class Detail
        {
            public string TranType { get; set; }
            public string TranDate { get; set; }
            public string ProdCodeSwcOut { get; set; }
            public string ProdCodeSwcIn { get; set; }
            public string ClientCodeSwcOut { get; set; }
            public string ClientCodeSwcIn { get; set; }
            public string FundCodeSwcOut { get; set; }
            public string FundCodeSwcIn { get; set; }
            public string AgentCode { get; set; }
            public string TranCCY { get; set; }
            public string TranAmt { get; set; }
            public string TranUnit { get; set; }
            public string SwitchingFee { get; set; }
            public string ByUnit { get; set; }
            public string Status { get; set; }
            public string SalesCode { get; set; }
            public string SelectedAccNo { get; set; }
            public string Inputter { get; set; }
            public string Seller { get; set; }
            public string Waperd { get; set; }
            public string IsFeeEdit { get; set; }
            public string Percentage { get; set; }
            public string RefID { get; set; }
            public string OfficeId { get; set; }
            public string Referentor { get; set; }
            public string CIFNo { get; set; }
            public string TranCode { get; set; }
            public string CIFName { get; set; }
            public string PhoneOrder { get; set; }
            public string CheckerSuid { get; set; }
            public string TrxTaxAmnesty { get; set; }
        }
    }
}
