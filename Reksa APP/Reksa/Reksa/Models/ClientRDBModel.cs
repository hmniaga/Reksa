using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class ClientRDBModel
    {
        public int JangkaWaktu { get; set; }
        public System.DateTime JatuhTempo { get; set; }
        public bool AutoRedemption { get; set; }
        public bool Asuransi { get; set; }
        public int FrekPendebetan { get; set; }
        public int SisaJangkaWaktu { get; set; }
        public string IsDoneDebet { get; set; }
    }
}
