using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;

namespace Reksa.ViewModels
{
    public class TransaksiListViewModel
    {
        public IList<SubsciprionModel> Subscription { get; set; }
        public ProductModel ProductModel { get; set; }
        public OfficeModel OfficeModel { get; set; }
        public ClientModel ClientModel { get; set; }
        public TransaksiSubscriptionModel TransaksiSubscription { get; set; }
        public List<ListSubscriptionModel> ListSubscription { get; set; }
        public CustomerModel CustomerModel { get; set; }
    }
}
