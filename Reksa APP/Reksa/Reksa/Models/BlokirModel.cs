using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class BlokirModel
    {
        public string BlockId { get; set; }
        public string Status { get; set; }
        public System.DateTime TanggalBlokir { get; set; }
        public System.DateTime TanggalExpiryBlokir { get; set; }
        public decimal UnitBlokir { get; set; }
        public string Inputter { get; set; }
        public string Supervisor { get; set; }
    }
}
