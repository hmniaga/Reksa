using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class PopulateAktifitasModel
    {
        public string TanggalTransaksi { get; set; }
        public string KeteranganTransaksi { get; set; }
        public string DebetNom { get; set; }
        public string KreditNom { get; set; }
        public string Fee { get; set; }
        public string SaldoNom { get; set; }
        public string NAV { get; set; }
        public string UnitTransaction { get; set; }
        public string UnitBalance { get; set; }
        public string ChannelTransaksi { get; set; }
        public string Operator { get; set; }
        public string Checker { get; set; }

    }
}
