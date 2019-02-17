using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;

namespace Reksa.ViewModels
{
    public class ParameterRedempFeeViewModel
    {
        public ProductModel ProductModel { get; set; }
        public ParameterRedempFee RedempFee { get; set; }
        public List<ParameterRedempFeeGL> RedempFeeGL { get; set; }
        public List<ParameterRedempFeePercentageTiering> RedempFeePercentageTiering { get; set; }
        public List<ParameterRedempFeeTieringNotif> RedempFeeTieringNotif { get; set; }
    }
}
