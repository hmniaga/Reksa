using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;

namespace Reksa.ViewModels
{
    public class POListViewModel
    {
        public List<JurnalRTGS> JurnalRTGS { get; set; }
        public ProductModel ProductModel { get; set; }
        public CurrencyModel CurrencyModel { get; set; }
        public List<ParamSinkronisasi> TypeSinkronisasi { get; set; }
        public List<ParamSinkronisasi> FormatSinkronisasi { get; set; }
        public SearchCustody CustodyModel { get; set; }
    }
}
