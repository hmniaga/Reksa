using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;


namespace Reksa.ViewModels
{
    public class OtorisasiListViewModel
    {
        public List<OtorisasiModel.AuthParamGlobal> AuthParamGlobal { get; set; }
        public List<OtorisasiModel.Detail> Detail{ get; set; }
        public List<OtorisasiModel.AuthTransaction> AuthTransaction { get; set; }
        
    }
}
