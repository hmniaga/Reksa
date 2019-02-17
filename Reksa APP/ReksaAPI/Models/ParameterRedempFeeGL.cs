using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class ParameterRedempFeeGL
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public int Sequence { get; set; }
        public string GLName { get; set; }
        public string GLNumber { get; set; }
        public decimal Percentage { get; set; }
        public string OfficeId { get; set; }
    }
}
