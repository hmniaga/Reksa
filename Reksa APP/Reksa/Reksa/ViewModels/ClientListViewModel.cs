using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;

namespace Reksa.ViewModels
{
    public class ClientListViewModel
    {
        public IList<ActivityModel> ClientActivity { get; set; }
        public IList<BlokirModel> ClientBlokir { get; set; }

        public ClientModel ClientModel { get; set; }
        public ProductModel ProductModel { get; set; }
    }
}
