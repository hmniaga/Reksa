using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;

namespace Reksa.ViewModels
{
    public class ParameterListViewModel
    {
        public List<ParameterModel> Parameter { get; set; }
        public ProductModel ProductModel { get; set; }
        public List<ActivityModel> CustomerActivity { get; set; }
    }
}
