using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class TransactionSubscriptionModel
    {
        public class SubscriptionDetail
        {
            public string OfficeId { get; set; }
            public string RefID { get; set; }
            public string Status { get; set; }
            public string Inputter { get; set; }
            public string Seller { get; set; }
            public string Waperd { get; set; }
            public string Referentor { get; set; }
            public string CIFNo { get; set; }
            public string CIFName { get; set; }
            public int? Umur { get; set; }
        }
        public class SubscriptionList
        {
            public string NoTrx { get; set; }
            public string StatusTransaksi { get; set; }
            public string KodeProduk { get; set; }
            public string NamaProduk { get; set; }
            public string ClientCode { get; set; }
            public decimal Nominal { get; set; }
            public string EditFeeBy { get; set; }
            public decimal NominalFee { get; set; }
            public bool FullAmount { get; set; }
            public bool PhoneOrder { get; set; }
            public System.DateTime TglTrx { get; set; }
            public string CCY { get; set; }
            public bool EditFee { get; set; }
            public string JenisFee { get; set; }
            public decimal PctFee { get; set; }
            public string FeeCurr { get; set; }
            public string FeeKet { get; set; }
            public bool IsNew { get; set; }
            public decimal OutstandingUnit { get; set; }
            public bool ApaDiUpdate { get; set; }
            public bool TrxTaxAmnesty { get; set; }
        }
        public class RedemptionList
        {
            public string NoTrx { get; set; }
            public string StatusTransaksi { get; set; }
            public string KodeProduk { get; set; }
            public string NamaProduk { get; set; }
            public string ClientCode { get; set; }
            public decimal OutstandingUnit { get; set; }
            public decimal RedempUnit { get; set; }
            public bool IsRedempAll { get; set; }
            public string EditFeeBy { get; set; }
            public decimal NominalFee { get; set; }
            public bool PhoneOrder { get; set; }
            public System.DateTime TglTrx { get; set; }
            public bool EditFee { get; set; }
            public string JenisFee { get; set; }
            public decimal PctFee { get; set; }
            public string FeeCurr { get; set; }
            public string FeeKet { get; set; }
            public bool Period { get; set; }
            public bool ApaDiUpdate { get; set; }
            public bool TrxTaxAmnesty { get; set; }
        }
        public class SubscriptionRDBList
        {
            public string NoTrx { get; set; }
            public string StatusTransaksi { get; set; }
            public string KodeProduk { get; set; }
            public string NamaProduk { get; set; }
            public string ClientCode { get; set; }
            public decimal Nominal { get; set; }
            public string EditFeeBy { get; set; }
            public decimal NominalFee { get; set; }
            public int JangkaWaktu { get; set; }
            public System.DateTime JatuhTempo { get; set; }
            public int FrekPendebetan { get; set; }
            public int AutoRedemption { get; set; }
            public int Asuransi { get; set; }
            public bool PhoneOrder { get; set; }
            public System.DateTime TglTrx { get; set; }
            public string CCY { get; set; }
            public bool EditFee { get; set; }
            public string JenisFee { get; set; }
            public decimal PctFee { get; set; }
            public string FeeCurr { get; set; }
            public string FeeKet { get; set; }
            public bool ApaDiUpdate { get; set; }
            public bool TrxTaxAmnesty { get; set; }

        }
    }
}
