using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;

namespace Reksa.ViewModels
{
    public class TransaksiListViewModel
    {
        public TransactionModel.SubscriptionDetail TransactionSubsDetail { get; set; }
        public List<TransactionModel.SubscriptionList> ListSubscription { get; set; }
        public List<TransactionModel.RedemptionList> ListRedemption { get; set; }
        public List<TransactionModel.SubscriptionRDBList> ListSubsRDB { get; set; }
        public List<TransactionModel.ErrorListSubs> ListErrorSubs { get; set; }
        public TransactionModel.SwitchingNonRDBModel TransactionSwitching { get; set; }
        public TransactionModel.SwitchingRDBModel TransactionSwitchingRDB { get; set; }
        public TransactionModel.BookingModel TransactionBooking { get; set; }
        public List<TransactionModel.FrekuensiDebet> FrekuensiDebet{ get; set; }
        public CustomerIdentitasModel CustomerIdentitas { get; set; }
        public RiskProfileModel RiskProfileModel { get; set; }
        public ProductModel ProductModel { get; set; }
        public TransaksiProduct TransaksiProduct { get; set; }
        public OfficeModel OfficeModel { get; set; }
        public ClientModel ClientModel { get; set; }        
        public CustomerModel CustomerModel { get; set; }
        public CurrencyModel CurrencyModel { get; set; }
        public ReferensiModel ReferensiModel { get; set; }
        public ReferentorModel ReferentorModel { get; set; }
        public BookingModel BookingModel { get; set; }
        public SwitchingModel SwitchingModel { get; set; }
        public WaperdModel WaperdModel { get; set; }
    }
}
