using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class CustomerNPWPModel
    {
        public string Opsi { get; set; }
        public string NoNPWPKK { get; set; }
        public string NamaNPWPKK { get; set; }
        public string KepemilikanNPWPKK { get; set; }
        public string KepemilikanNPWPKKLainnya { get; set; }
        public DateTime? TglNPWPKK { get; set; }
        public string AlasanTanpaNPWP { get; set; }
        public string NoDokTanpaNPWP { get; set; }
        public DateTime? TglDokTanpaNPWP { get; set; }
        public string NoNPWPProCIF { get; set; }
        public string NamaNPWPProCIF { get; set; }
        public string EditDate { get; set; }
        public DateTime? TglNPWP { get; set; }
    }
}
