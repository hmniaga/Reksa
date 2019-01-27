using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class ListSubscriptionModel
    {
        public string NoTrx { get; set; }
        public string StatusTransaksi { get; set; }
        public string KodeProduk { get; set; }
        public string NamaProduk { get; set; }
        public string ClientCode { get; set; }
        public string Nominal { get; set; }
        public string EditFeeBy { get; set; }
        public string NominalFee { get; set; }
        public string FullAmount { get; set; }
        public string PhoneOrder { get; set; }
        public string TglTrx { get; set; }
        public string CCY { get; set; }
        public string EditFee { get; set; }
        public string JenisFee { get; set; }
        public string PctFee { get; set; }
        public string FeeCurr { get; set; }
        public string FeeKet { get; set; }
        public string IsNew { get; set; }
        public string OutstandingUnit { get; set; }
        public string ApaDiUpdate { get; set; }
    }
}
