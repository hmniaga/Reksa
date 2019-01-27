using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class SubsciprionModel
    {
        public int Id { get; set; }
        public string BlockId { get; set; }
        public string Status { get; set; }
        public System.DateTime BlockDate { get; set; }
        public System.DateTime BlockExpiry { get; set; }
        public decimal BlockAmount { get; set; }
        public string Inputter { get; set; }
        public string Supervisor { get; set; }
    }
}
