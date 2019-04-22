using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class OtorisasiModel
    {
        public class Detail
        {
            public bool CheckB { get; set; }
            public string TranId { get; set; }
            public string TranCode { get; set; }
            public string ValueDate { get; set; }
            public string ClientCode { get; set; }
            public string CIFName { get; set; }
            public string FullAmount { get; set; }
            public string ProdCode { get; set; }
            public string AgentCode { get; set; }
        }     
        public class AuthParamGlobal
        {
            public bool CheckB { get; set; }
            public string TipeAction { get; set; }
            public string Id { get; set; }
            public string ProdId { get; set; }
            public string ProductCode { get; set; }
            public string Kode { get; set; }
            public string Deskripsi { get; set; }
            public string Desc2 { get; set; }
            public string Desc5 { get; set; }
            public System.DateTime TglEfektif { get; set; }
            public System.DateTime TglExpire { get; set; }
            public string Keterangan { get; set; }
            public string MinSwitchRedempt { get; set; }
            public string JenisSwitchRedempt { get; set; }
            public string SwitchingFeeNonKaryawan { get; set; }
            public string SwitchingFeeKaryawan { get; set; }
            public string OfficeId { get; set; }
            public System.DateTime TanggalValuta { get; set; }
            public System.DateTime LastUpdate { get; set; }
            public string LastUser { get; set; }
        }

        public class AuthTransaction
        {
            public bool CheckB {get;set;}
            public string NoReferensi { get; set; }
            public string OfficeId { get; set; }
            public string NoSID { get; set; }
            public string ShareholderID { get; set; }
            public string RiskProfile { get; set; }
            public DateTime LastUpdateRiskProfile { get; set; }
            public string TransaksiMelaluiTelepon { get; set; }
            public string KaryawanOCBCNISP { get; set; }
            public string NoCIF { get; set; }
            public string NamaNasabah { get; set; }
            public string NoRekRelasiIDR { get; set; }
            public string NamaRekRelasiIDR { get; set; }
            public string NoRekRelasiUSD { get; set; }
            public string NamaRekRelasiUSD { get; set; }
            public string NoRekRelasiMulticurrency { get; set; }
            public string NamaRekRelasiMulticurrency { get; set; }
            public string AlamatKonfirmasi { get; set; }
            public string NIKWAPERD { get; set; }
            public string NamaWAPERD { get; set; }
            public string NIKSeller { get; set; }
            public string NamaSeller { get; set; }
            public string NIKReferentor { get; set; }
            public string NamaReferentor { get; set; }
            public string UserInput { get; set; }
            public DateTime TanggalInput { get; set; }
            public string NasabahId { get; set; }
            public string UserName { get; set; }
            public string TranType { get; set; }
            public string NoCIFBigInt { get; set; }
            public string NoCIF19 { get; set; }
            public string NoRekRelasiIDRTAX { get; set; }
            public string NoRekRelasiUSDTAX { get; set; }
            public string NoRekRelasiMulticurrencyTAX { get; set; }
        }
        public class AuthTransactionDetail
        {
            public bool CheckB { get; set; }
            public string NoReferensi { get; set; }
            public string JenisTransaksi { get; set; }
            public string KodeTransaksi { get; set; }
            public DateTime TglTransaksi { get; set; }
            public DateTime TglValuta { get; set; }
            public string KodeProduk { get; set; }
            public string KodeProdukSwcOut { get; set; }
            public string KodeProdukSwcIn { get; set; }
            public string ClientCode { get; set; }
            public string ClientCodeSwcOut { get; set; }
            public string ClientCodeSwcIn { get; set; }
            public string MataUang { get; set; }
            public decimal NominalTransaksi { get; set; }
            public decimal UnitTransaksi { get; set; }
            public bool FullAmount { get; set; }
            public int JangkaWaktu { get; set; }
            public string JatuhTempo { get; set; }
            public string FrekPendebetan { get; set; }
            public string Asuransi { get; set; }
            public bool AutoRedemption { get; set; }
            public bool FeeEdit { get; set; }
            public decimal FeeNominal { get; set; }
            public decimal PctFee { get; set; }
            public string Channel { get; set; }
            public int TranType { get; set; }
            public int TranId { get; set; }
            public int TrxTaxAmnesty { get; set; }
            public DateTime Today { get; set; }
        }
    }
}
