using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;

namespace Reksa.ViewModels
{
    public class TransaksiListViewModel
    {
        public TransactionSubscriptionModel.SubscriptionDetail TransactionSubsDetail { get; set; }
        public List<TransactionSubscriptionModel.SubscriptionList> ListSubscription { get; set; }
        public List<TransactionSubscriptionModel.RedemptionList> ListRedemption { get; set; }
        public List<TransactionSubscriptionModel.SubscriptionRDBList> ListSubsRDB { get; set; }
        public CustomerIdentitasModel CustomerIdentitas { get; set; }
        public RiskProfileModel RiskProfileModel { get; set; }
        public ProductModel ProductModel { get; set; }
        public OfficeModel OfficeModel { get; set; }
        public ClientModel ClientModel { get; set; }        
        public CustomerModel CustomerModel { get; set; }
        public CurrencyModel CurrencyModel { get; set; }
        public ReferensiModel ReferensiModel { get; set; }
        public ReferentorModel ReferentorModel { get; set; }
        public WaperdModel WaperdModel { get; set; }
    }
}
