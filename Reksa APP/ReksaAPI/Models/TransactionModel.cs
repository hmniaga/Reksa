using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class TransactionModel
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
            public DateTime TglTrx { get; set; }
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
        public class SwitchingNonRDBModel
        {
            public string TranType { get; set; }
            public System.DateTime TranDate { get; set; }
            public string ProdCodeSwcOut { get; set; }
            public string ProdCodeSwcIn { get; set; }
            public string ClientCodeSwcOut { get; set; }
            public string ClientCodeSwcIn { get; set; }
            public string FundCodeSwcOut { get; set; }
            public string FundCodeSwcIn { get; set; }
            public string AgentCode { get; set; }
            public string TranCCY { get; set; }
            public decimal TranAmt { get; set; }
            public string TranUnit { get; set; }
            public decimal SwitchingFee { get; set; }
            public string ByUnit { get; set; }
            public string Status { get; set; }
            public string SalesCode { get; set; }
            public string SelectedAccNo { get; set; }
            public string Inputter { get; set; }
            public string Seller { get; set; }
            public string Waperd { get; set; }

            public bool IsFeeEdit { get; set; }
            public decimal Percentage { get; set; }
            public string RefID { get; set; }
            public string OfficeId { get; set; }
            public string Referentor { get; set; }
            public string CIFNo { get; set; }
            public string TranCode { get; set; }
            public string CIFName { get; set; }
            public bool PhoneOrder { get; set; }
            public string CheckerSuid { get; set; }
            public bool TrxTaxAmnesty { get; set; }
        }
        public class SwitchingRDBModel
        {
            public string TranType { get; set; }
            public System.DateTime TranDate { get; set; }
            public string ProdCodeSwcOut { get; set; }
            public string ProdCodeSwcIn { get; set; }
            public string ClientCodeSwcOut { get; set; }
            public string ClientCodeSwcIn { get; set; }
            public string TranCCY { get; set; }
            public decimal TranAmt { get; set; }
            public string TranUnit { get; set; }
            public decimal SwitchingFee { get; set; }
            public string ByUnit { get; set; }
            public string Status { get; set; }
            public string SelectedAccNo { get; set; }
            public string Inputter { get; set; }
            public string Seller { get; set; }
            public string Waperd { get; set; }
            public bool IsFeeEdit { get; set; }
            public decimal Percentage { get; set; }
            public string RefID { get; set; }
            public string OfficeId { get; set; }
            public string Referentor { get; set; }
            public string CIFNo { get; set; }
            public string CIFName { get; set; }
            public string TranCode { get; set; }
            public int JangkaWaktu { get; set; }
            public System.DateTime JatuhTempo { get; set; }
            public int FrekPendebetan { get; set; }
            public bool AutoRedemption { get; set; }
            public bool Asuransi { get; set; }
            public string IsNew { get; set; }
            public bool PhoneOrder { get; set; }
            public string CheckerSuid { get; set; }
            public bool TrxTaxAmnesty { get; set; }
        }
        public class BookingModel
        {
            public string BookingId { get; set; }
            public string BookingCode { get; set; }
            public string BookingCCY { get; set; }
            public decimal BookingAmt { get; set; }
            public string ProdCode { get; set; }
            public string CIFNo { get; set; }
            public string RefID { get; set; }
            public string Referentor { get; set; }
            public string Status { get; set; }
            public string Inputter { get; set; }
            public string Seller { get; set; }
            public string Waperd { get; set; }
            public bool PhoneOrder { get; set; }
            public string OfficeId { get; set; }
            public string JenisPerhitunganFee { get; set; }
            public decimal PercentageFee { get; set; }
            public decimal SubcFee { get; set; }
            public System.DateTime BookingDate { get; set; }
            public System.DateTime LastUpdate { get; set; }
            public bool IsFeeEdit { get; set; }
            public string ClientCode { get; set; }
            public string CIFName { get; set; }
            public bool TrxTaxAmnesty { get; set; }
        }
        public class MaintainTransaksi
        {
            public int intType { get; set; }
            public string strTranType { get; set; }
            public string RefID { get; set; }
            public string CIFNo { get; set; }
            public string OfficeId { get; set; }
            public string NoRekening { get; set; }
            public List<SubscriptionList> dtSubs { get; set; }
            //public List<RedemptionList> dtRedemp { get; set; }
            //public List<SubscriptionRDBList> dtRDB { get; set; }
            //public string writerSubs { get; set; }
            //public string writerRedemp { get; set; }
            //public string writerRDB { get; set; }
            public string Inputter { get; set; }
            public int Seller { get; set; }
            public int Waperd { get; set; }
            public string NoRekeningUSD { get; set; }
            public string NoRekeningMC { get; set; }
            public int Referentor { get; set; }
            public bool pbDocFCSubscriptionForm { get; set; }
            public bool pbDocFCDevidentAuthLetter { get; set; }
            public bool pbDocFCJoinAcctStatementLetter { get; set; }
            public bool pbDocFCIDCopy { get; set; }
            public bool pbDocFCOthers { get; set; }
            public bool pbDocTCSubscriptionForm { get; set; }
            public bool pbDocTCTermCondition { get; set; }
            public bool pbDocTCProspectus { get; set; }
            public bool pbDocTCFundFactSheet { get; set; }
            public bool pbDocTCOthers { get; set; }
            public string pcDocFCOthersList { get; set; }
            public string pcDocTCOthersList { get; set; }
        }
        public class GenerateClientCode
        {
            public string JenisTrx { get; set; }
            public bool IsSubsNew { get; set; }
            public string ProductCode { get; set; }
            public string ClientCode { get; set; }
            public string CIFNo { get; set; }
            public bool IsFeeEdit { get; set; }
            public decimal PercentageFee { get; set; }
            public int Period { get; set; }
            public bool FullAmount { get; set; }
            public double Fee { get; set; }
            public double TranAmt { get; set; }
            public double TranUnit { get; set; }
            public bool IsRedempAll { get; set; }
            public int FrekuensiPendebetan { get; set; }
            public int JangkaWaktu { get; set; }
            public int intTypeTrx { get; set; }
            public string TranCode { get; set; }
            public string NewClientCode { get; set; }
        }
    }
}
