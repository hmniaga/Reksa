using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class ClientRDBModel
    {
        public string JangkaWaktu { get; set; }
        public string JatuhTempo { get; set; }
        public string AutoRedemption { get; set; }
        public string Asuransi { get; set; }
        public string FrekPendebetan { get; set; }
        public string SisaJangkaWaktu { get; set; }
        public string IsDoneDebet { get; set; }
    }
}
