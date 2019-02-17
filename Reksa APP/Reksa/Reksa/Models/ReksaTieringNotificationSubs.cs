using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class ReksaTieringNotificationSubs
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public decimal? PercentFrom { get; set; }
        public decimal? PercentTo { get; set; }
        public string MustApproveBy { get; set; }
    }
}
