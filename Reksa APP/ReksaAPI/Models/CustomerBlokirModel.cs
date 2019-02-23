using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class CustomerBlokirModel
    {
        public int BlockId { get; set; }
        public string Status { get; set; }
        public System.DateTime TanggalBlokir { get; set; }
        public System.DateTime TanggalExpiryBlokir { get; set; }
        public decimal UnitBlokir { get; set; }
        public string Inputter { get; set; }
        public string Supervisor { get; set; }
        public int ClientId { get; set; }

        public int intType { get; set; }
    }
}
