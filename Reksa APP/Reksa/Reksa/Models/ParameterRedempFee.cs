using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class ParameterRedempFee
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public double? MinPctFeeNonEmployee { get; set; }
        public double? MaxPctFeeNonEmployee { get; set; }
        public double? MinPctFeeEmployee { get; set; }
        public double? MaxPctFeeEmployee { get; set; }
        public bool IsFlat { get; set; }
        public int NonFlatPeriod { get; set; }
        public int RedempIncFee { get; set; }
        public bool IsRedempIncFeeTrue { get { return RedempIncFee == 1; } set { this.RedempIncFee = 1; } }
        public bool IsRedempIncFeeFalse { get { return RedempIncFee != 1; } set { this.RedempIncFee = 0; } }
    }
}
