using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{

    public class ProductMFeeModel
    {
        public decimal? AUMMin { get; set; }
        public decimal? AUMMax { get; set; }
        public decimal? NISPPct { get; set; }
        public decimal? FundMgrPct { get; set; }
        public decimal? MaintenanceFee { get; set; }
    }
}
