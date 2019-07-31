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
        public string TanggalTransaksi { get; set; }
        public string TranId { get; set; }
    }
    public class SwitchingRDBRequest
    {
        public int ProdSwitchOut { get; set; }
        public int ClientSwitchOut { get; set; }
        public decimal Unit { get; set; }
        public int NIK { get; set; }
        public string Guid { get; set; }
        public bool IsEdit { get; set; }
        public decimal PercentageInput { get; set; }
    }
    public class SwitchingRDBResponses
    {
        public string FeeCCY { get; set; }
        public decimal Fee { get; set; }
        public decimal PercentageOutput { get; set; }
    }
    public class SwitchingRequest
    {
        public string ProdSwitchOut { get; set; }
        public string ProdSwitchIn { get; set; }
        public bool Jenis { get; set; }
        public decimal TranAmt { get; set; }
        public decimal Unit { get; set; }
        public int NIK { get; set; }
        public string Guid { get; set; }
        public decimal NAV { get; set; }
        public bool IsEdit { get; set; }
        public decimal PercentageInput { get; set; }
        public string IsEmployee { get; set; }
    }
    public class SwitchingResponses
    {
        public string FeeCCY { get; set; }
        public decimal Fee { get; set; }
        public decimal PercentageOutput { get; set; }
    }
}
