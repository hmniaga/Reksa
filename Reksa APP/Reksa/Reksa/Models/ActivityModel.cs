using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class ActivityModel
    {
        public System.DateTime TanggalTransaksi { get; set; }
        public string KeteranganTransaksi { get; set; }
        public decimal DebetNom { get; set; }
        public decimal KreditNom { get; set; }
        public decimal Fee { get; set; }
        public decimal SaldoNom { get; set; }
        public string NAV { get; set; }
        public string UnitTransaction { get; set; }
        public string UnitBalance { get; set; }
        public string ChannelTransaksi { get; set; }
        public string Operator { get; set; }
        public string Checker { get; set; }
    }
}
