using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class WaperdModel
    {
        public int employee_id { get; set; }
        public string WaperdNo { get; set; }
        public System.DateTime? DateExpire { get; set; }
    }
}
