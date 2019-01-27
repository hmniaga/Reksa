using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;

namespace Reksa.ViewModels
{
    public class CustomerListViewModel
    {
        public List<ActivityModel> CustomerActivity { get; set; }
        public List<ListClientModel> CustomerListClient { get; set; }
        public List<KonfirmasiAddressModel> CustomerKonfirmasiAddress { get; set; }
        public List<BlokirModel> CustomerBlokir { get; set; }
        public ClientModel ClientModel { get; set; }
        public BlokirModel BlokirModel { get; set; }
        public OfficeModel OfficeModel { get; set; }
        public CustomerModel CustomerModel { get; set; }
        public ReferentorModel Referentor { get; set;}
        public CustomerIdentitasModel CustomerIdentitas { get; set; }
        public RiskProfileModel RiskProfileModel { get; set; }


    }
}
