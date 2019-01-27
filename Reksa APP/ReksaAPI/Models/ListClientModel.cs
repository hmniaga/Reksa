using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class ListClientModel
    {
       public string Pilih { get; set; }
        public string ProdCode { get; set; }
        public string ProdName { get; set; }
        public string ClientId { get; set; }
        public string ClientCode { get; set; }
        public string NAV { get; set; }
        public string UnitBalance { get; set; }
        public string UnitNominal { get; set; }
        public string Flag { get; set; }
        public string CIFStatus { get; set; }
        public string RDBNonRDB { get; set; }
        public string FlagClientCodeTA { get; set; }
    }
}
