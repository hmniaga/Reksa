using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class SwitchingModel
    {
        public string RefID { get; set; }
        public System.DateTime TanggalTransaksi { get; set; }
        public string TranId { get; set; }
    }
}
