using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class POModel
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
    public class ListProduct
    {
        public bool CheckB { get; set; }
        public int ProdId { get; set; }
        public string ProdCode { get; set; }
        public string ProdName { get; set; }
        public string CustodyCode { get; set; }

    }
    public class MaintRejectBooking
    {
        public int BookingId { get; set; }
        public int KodeProduk { get; set; }
        public string NamaProduk { get; set; }
        public string BookingCode { get; set; }
        public string NamaNasabah { get; set; }
        public decimal NominalBooking { get; set; }
        public DateTime TanggalBooking { get; set; }
        public string RekeningRelasi { get; set; }
        public string NamaRekeningRelasi { get; set; }
        public string AgentCode { get; set; }
        public string NIKSeller { get; set; }
        public string NamaSeller { get; set; }
        public int intNIK { get; set; }
    }
    public class MaintCancelTransaksi
    {
        public int TranId { get; set; }
        public int KodeProduk { get; set; }
        public string NamaProduk { get; set; }
        public string ClientCode { get; set; }
        public string NamaNasabah { get; set; }
        public decimal NominalSubscription { get; set; }
        public DateTime ValueDate { get; set; }
        public string RekeningRelasi { get; set; }
        public string NamaRekeningRelasi { get; set; }
        public string AgentCode { get; set; }
        public string NIKSeller { get; set; }
        public string NamaSeller { get; set; }
        public int intNIK { get; set; }
    }
    public class MaintCancelTransaksiIBMB {
        public string TranCode { get; set; }
        public int TranType { get; set; }
        public int NIK { get; set; }
    }
    public class ImportData
    {
        public int Type { get; set; }
        public int BankCustody { get; set; }
        public int Period { get; set; }
        public string FileName { get; set; }
        public int NIK { get; set; }
        public string TableNames { get; set; }
        public List<SinkronisasiTransaksi> listTransaksi { get; set; }
        public List<OSUnitShareholderID> listOSUnitShareholderID { get; set; }
        public List<OSUnitClientCode> listOSUnitClientCode { get; set; }
    }
    public class SinkronisasiTransaksi
    {
        public DateTime TglTransaksi { get; set; }
        public DateTime TglNAV { get; set; }
        public string JenisTransaksi { get; set; }
        public string Produk { get; set; }
        public string ClientCode { get; set; }
        public string ClientName { get; set; }
        public string AgentCode { get; set; }
        public decimal Unit { get; set; }
        public decimal NAV { get; set; }
        public decimal Nominal { get; set; }
        public decimal UnitBalance { get; set; }
        public DateTime TglGoodFund { get; set; }
        public string ShareholderID { get; set; }
        public int TransID { get; set; }
    }
    public class OSUnitShareholderID
    {
        public DateTime TglEOD { get; set; }
        public string ShareholderID { get; set; }
        public decimal EndingBalance { get; set; }
        public string ProductCode { get; set; }
        public int TranId { get; set; }
    }
    public class OSUnitClientCode
    {
        public DateTime TglEOD { get; set; }
        public string ClientCode { get; set; }
        public decimal EndingBalance { get; set; }
        public string ProductCode { get; set; }
    }
}
