using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class POModel
    {
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
}
