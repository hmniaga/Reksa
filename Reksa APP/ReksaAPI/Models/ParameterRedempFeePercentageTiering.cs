using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class ParameterRedempFeePercentageTiering
    {
        public int ProductId { get; set; }
        public string Status { get; set; }
        public decimal PercentageFee { get; set; }
        public int Period { get; set; }
        public double Nominal { get; set; }
        
    }
}
