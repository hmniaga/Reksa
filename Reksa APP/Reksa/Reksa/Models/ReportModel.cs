using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class ReportModel
    {
    }
    public class ProductNAV
    {
        public int ProdId { get; set; }
        public string ProdCCY { get; set; }
        public string Status { get; set; }
        public string CloseEndBit { get; set; }
        public string IsDeviden { get; set; }
        public decimal NAV { get; set; }
        public DateTime NAVValueDate { get; set; }
        public DateTime DevidenDate { get; set; }
        public string DevidenType { get; set; }
        public bool IsHargaUnitPerHari { get; set; }
    }
    public class JurnalRTGS
    {
        public string TranGuid { get; set; }
        public string TranDate { get; set; }
        public string TranStatus { get; set; }
        public string TranRemarks { get; set; }
        public string BillId { get; set; }
        public string DebitAccountId { get; set; }
        public string DebitCcy { get; set; }
        public string FeeAmount { get; set; }
        public string TransferAmount { get; set; }
        public string BeneficiaryAccountNumber { get; set; }
        public string BeneficiaryName { get; set; }
        public string BeneficiaryAddress1 { get; set; }
        public string BeneficiaryAddress2 { get; set; }
        public string BeneficiaryAddress3 { get; set; }
        public string BeneficiaryBankMemberCode { get; set; }
        public string BeneficiaryBankName { get; set; }
        public string BeneficiaryBankAddress1 { get; set; }
        public string BeneficiaryBankAddress2 { get; set; }
        public string BeneficiaryBankAddress3 { get; set; }
        public string PaymentDetails1 { get; set; }
        public string PaymentDetails2 { get; set; }
    }
}
