using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class BookingModel
    {
        public string RefID { get; set; }
        public System.DateTime TanggalTransaksi { get; set; }
        public int BookingId { get; set; }
    }
}
