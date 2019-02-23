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
        public DateTime TanggalExpiryBlokir { get; set; }
        public decimal UnitBlokir { get; set; }
        public string Inputter { get; set; }
        public string Supervisor { get; set; }
        public decimal? decTotal { get; set; }
        public decimal? decOutStanding { get; set; }

        public int ClientId { get; set; }
        public int intType { get; set; }
    }
}
