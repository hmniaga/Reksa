using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class TransaksiSubscriptionModel
    {
        public string CIFNo { get; set; }
        public string CIFName { get; set; }
        public int NasabahId { get; set; }
        public string Email { get; set; }
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
        public string CIFTypeName { get; set; }
        public string CIFNik { get; set; }
        public string CIFNikName { get; set; }
        public string RiskProfile { get; set; }
        public DateTime LastUpdate { get; set; }
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
        public DateTime DateExpRiskProfile { get; set; }
    }
}
