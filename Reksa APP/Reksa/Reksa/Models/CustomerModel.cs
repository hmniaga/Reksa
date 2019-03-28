using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class CustomerModel
    {
        [Required(ErrorMessage = "Title is required.")]
        public string CIFNo { get; set; }
        public string CIFName { get; set; }
        public int NasabahId { get; set; }
    }

    public class CIFDataModel
    {
        public string CFCIF { get; set; }
        public string CIFName { get; set; }
        public string Address1 { get; set; }
        public string Address2 { get; set; }
        public string Address3 { get; set; }
        public string Kota { get; set; }
        public string Propinsi { get; set; }
        public string NegaraCode { get; set; }
        public string Telepon { get; set; }
        public string HP { get; set; }
        public string TempatLhr { get; set; }
        public System.DateTime TglLhr { get; set; }
        public string KTP { get; set; }
        public string NPWP { get; set; }
        public string NamaNPWP { get; set; }
        public System.DateTime TglNPWP { get; set; }
        public string JnsNas { get; set; }
        public string DocTermCondition { get; set; }
        public string ShareholderID { get; set; }
        public string CIFSID { get; set; }
        public string Segment { get; set; }
        public string SubSegment { get; set; }
        public string RiskProfile { get; set; }
        public System.DateTime LastUpdate { get; set; }
        public string WarnMsg { get; set; }
        public string IDExpireDate { get; set; }
        public string Kewarganegaraan { get; set; }
        public string Agama { get; set; }
        public int intJnsNas { get; set; }
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
        public List<KonfirmasiAddressModel> KonfirmasiAddressModel { get; set; }
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
