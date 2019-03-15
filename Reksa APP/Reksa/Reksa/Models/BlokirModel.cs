using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class BlokirModel
    {
        [DisplayFormat(ConvertEmptyStringToNull = false)]
        public string BlockId { get; set; }
        [DisplayFormat(ConvertEmptyStringToNull = false)]
        public string Status { get; set; }
        public System.DateTime TanggalBlokir { get; set; }
        [Required(ErrorMessage = "Please enter Expiry Date Blokir")]
        public DateTime TanggalExpiryBlokir { get; set; }
        [Required(ErrorMessage = "Please enter Unit Blokir")]
        public decimal UnitBlokir { get; set; }
        [DisplayFormat(ConvertEmptyStringToNull = false)]
        public string Inputter { get; set; }
        public string Supervisor { get; set; }
        public decimal? decTotal { get; set; }
        public decimal? decOutStanding { get; set; }

        public int ClientId { get; set; }
        public int intType { get; set; }
    }
}
