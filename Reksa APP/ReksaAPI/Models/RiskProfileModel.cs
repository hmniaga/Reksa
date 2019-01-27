using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class RiskProfileModel
    {
        public string RiskProfile { get; set; }
        public DateTime LastUpdate { get; set; }
        public int IsRegistered { get; set; }
        public int ExpRiskProfileYear { get; set; }
    }
}
