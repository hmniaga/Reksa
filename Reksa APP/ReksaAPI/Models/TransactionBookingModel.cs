using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class TransactionBookingModel
    {
        public class Detail
        {
            public string BookingId { get; set; }
            public string BookingCode { get; set; }
            public string BookingCCY { get; set; }
            public string BookingAmt { get; set; }
            public string ProdCode { get; set; }
            public string CIFNo { get; set; }
            public string RefID { get; set; }
            public string Referentor { get; set; }
            public string Status { get; set; }
            public string Inputter { get; set; }
            public string Seller { get; set; }
            public string Waperd { get; set; }
            public string PhoneOrder { get; set; }
            public string OfficeId { get; set; }
            public string JenisPerhitunganFee { get; set; }
            public string PercentageFee { get; set; }
            public string SubcFee { get; set; }
            public string BookingDate { get; set; }
            public string LastUpdate { get; set; }
            public string IsFeeEdit { get; set; }
            public string ClientCode { get; set; }
            public string CIFName { get; set; }
            public string TrxTaxAmnesty { get; set; }

        }
    }
}
