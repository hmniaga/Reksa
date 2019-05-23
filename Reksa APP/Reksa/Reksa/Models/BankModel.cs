using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class BankModel
    {
        public string BankCode { get; set; }
        public string BankDesc { get; set; }
        public int BankId { get; set; }
    }
    public class BankCodeModel
    {
        public string KodeBank { get; set; }
        public string NamaBank { get; set; }
        public string Branch { get; set; }
        public string Alamat { get; set; }
    }
}
