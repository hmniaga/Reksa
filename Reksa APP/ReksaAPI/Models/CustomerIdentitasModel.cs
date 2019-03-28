using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class CustomerIdentitasModel
    {
        public class AlamatCabangDetail
        {
            public string Branch { get; set; }
            public string BranchName { get; set; }
            public string AddressLine1 { get; set; }
            public string AddressLine2 { get; set; }
            public string PostalCode { get; set; }
            public string Kelurahan { get; set; }
            public string Kecamatan { get; set; }
            public string Kota { get; set; }
            public string Province { get; set; }
            public System.DateTime LastUpdated { get; set; }
        }
        public class IdentitasDetail
        {
            public string CIFNo { get; set; }
            public string CIFName { get; set; }
            public int NasabahId { get; set; }

            public string OfficeId { get; set; }
            public string ShareholderID { get; set; }
            public string CIFBirthPlace { get; set; }
            public DateTime CIFBirthDay { get; set; }
            public DateTime CreateDate { get; set; }
            public string AccountId { get; set; }
            public string AccountName { get; set; }
            public string AccountIdUSD { get; set; }
            public string AccountNameUSD { get; set; }
            public string AccountIdMC { get; set; }
            public string AccountNameMC { get; set; }
            public string CIFIDNo { get; set; }
            public string HP { get; set; }
            public string CIFSID { get; set; }
            public string SubSegment { get; set; }
            public string Segment { get; set; }
            public int IsEmployee { get; set; }
            public int CIFType { get; set; }
            public string CIFNik { get; set; }
            public string NoNPWPProCIF { get; set; }
            public string NamaNPWPProCIF { get; set; }
            public string TglNPWP { get; set; }
            public string NoNPWPKK { get; set; }
            public string NamaNPWPKK { get; set; }
            public string KepemilikanNPWPKK { get; set; }
            public string KepemilikanNPWPKKLainnya { get; set; }
            public string TglNPWPKK { get; set; }
            public string AlasanTanpaNPWP { get; set; }
            public string NoDokTanpaNPWP { get; set; }
            public string TglDokTanpaNPWP { get; set; }
            public string Opsi { get; set; }
            public string ApprovalStatus { get; set; }
            public string CIFNPWP { get; set; }
            public string NamaNPWP { get; set; }
            public string Email { get; set; }
            public DateTime DateExpRiskProfile { get; set; }
        }
        public class KonfirmAddressList
        {
            public string Pilih { get; set; }
            public string Sequence { get; set; }
            public string AddressLine1 { get; set; }
            public string Address { get; set; }
            public string AddressLine2 { get; set; }
            public string AddressLine3 { get; set; }
            public string AddressLine4 { get; set; }
            public string KodePos { get; set; }
            public string AlamatLuarNegeri { get; set; }
            public string Keterangan { get; set; }
            public string AlamatUtama { get; set; }
            public string KodeAlamat { get; set; }
            public string AlamatSID { get; set; }
            public string PeriodThere { get; set; }
            public string PeriodThereCode { get; set; }
            public string JenisAlamat { get; set; }
            public string StaySince { get; set; }
            public string Kelurahan { get; set; }
            public string Kecamatan { get; set; }
            public string Kota { get; set; }
            public string Provinsi { get; set; }
            public string LastUpdatedDate { get; set; }
        }
        public class RiskProfileDetail
        {
            public string RiskProfile { get; set; }
            public DateTime LastUpdate { get; set; }
            public int IsRegistered { get; set; }
            public int ExpRiskProfileYear { get; set; }
        }
    }
    public class MaintainNasabah
    {
        public int Type { get; set; }
        public string CIFNo { get; set; }
        public string CIFName { get; set; }
        public string OfficeId { get; set; }
        public int CIFType { get; set; }
        public string ShareholderID { get; set; }
        public string CIFBirthPlace { get; set; }
        public DateTime CIFBirthDay { get; set; }
        public DateTime JoinDate { get; set; }
        public int IsEmployee { get; set; }
        public int CIFNIK { get; set; }
        public string AccountId { get; set; }
        public string AccountName { get; set; }
        public bool isRiskProfile { get; set; }
        public bool isTermCondition { get; set; }
        public DateTime RiskProfileLastUpdate { get; set; }
        public string AlamatConf { get; set; }
        public string NoNPWPKK { get; set; }
        public string NamaNPWPKK { get; set; }
        public string KepemilikanNPWPKK { get; set; }
        public string KepemilikanNPWPKKLainnya { get; set; }
        public DateTime TglNPWPKK { get; set; }
        public string AlasanTanpaNPWP { get; set; }
        public string NoDokTanpaNPWP { get; set; }
        public DateTime TglDokTanpaNPWP { get; set; }
        public string NoNPWPProCIF { get; set; }
        public string NamaNPWPProCIF { get; set; }
        public int NasabahId { get; set; }
        public string AccountIdUSD { get; set; }
        public string AccountNameUSD { get; set; }
        public string AccountIdMC { get; set; }
        public string AccountNameMC { get; set; }
        public string SelectedId { get; set; }
        public List<CustomerIdentitasModel.KonfirmAddressList> KonfirmasiAddressModel { get; set; }
        public List<HeaderAddress> HeaderAddress { get; set; }        
    }

    public class HeaderAddress
    {
        public int Type { get; set; }
        public string CIFNo { get; set; }
        public int DataType { get; set; }
        public string Branch { get; set; }
        public int Id { get; set; }
    }
}
