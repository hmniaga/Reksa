using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class ReksaParamFeeSubs
    {
        public string trxType { get; set; }
        public int? prodId { get; set; }
        public decimal? minPctFeeEmployee { get; set; }
        public decimal? maxPctFeeEmployee { get; set; }
        public decimal? minPctFeeNonEmployee { get; set; }
        public decimal? maxPctFeeNonEmployee { get; set; }
    }
}
