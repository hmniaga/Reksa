using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class ListClientModel
    {
        public bool Pilih { get; set; }
        public string ProdCode { get; set; }
        public string ProdName { get; set; }
        public long ClientId { get; set; }
        public string ClientCode { get; set; }
        public decimal NAV { get; set; }
        public decimal UnitBalance { get; set; }
        public decimal UnitNominal { get; set; }
        public bool Flag { get; set; }
        public string CIFStatus { get; set; }
        public string RDBNonRDB { get; set; }
        public string FlagClientCodeTA { get; set; }
    }
}
