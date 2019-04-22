using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class ProductModel
    {
        public string ProdCode { get; set; }
        public string ProdName { get; set; }
        public int? ProdId { get; set; }
        public string ProdCCY { get; set; }
        public string TypeCode { get; set; }
        public string ManInvCode { get; set; }
        public string CustodyCode { get; set; }
        public decimal NAV { get; set; }
        public decimal MinTotalUnit { get; set; }
        public decimal MaxTotalUnit { get; set; }
        public decimal MaxDailyUnit { get; set; }
        public decimal MaxDailyNom { get; set; }
        public long MaxDailyCust { get; set; }
        public DateTime PeriodStart { get; set; }
        public DateTime PeriodEnd { get; set; }
        public DateTime MatureDate { get; set; }
        public DateTime ChangeDate { get; set; }
        public DateTime ValueDate { get; set; }
        public long MaxMinUnit { get; set; }
        public int CloseEndBit { get; set; }
        public bool IsDeviden { get; set; }
        public int DevidenPeriod { get; set; }
        public long SubcFeeBased { get; set; }
        public long RedempFeeBased { get; set; }
        public long MaintenanceFee { get; set; }
        public string MIAccountId { get; set; }
        public string CTDAccountId { get; set; }
        public string CalcCode { get; set; }
        public int Status { get; set; }
        public int UpFrontFee { get; set; }
        public int SellingFee { get; set; }
        public string DevidentPct { get; set; }
        public int EffectiveAfter { get; set; }
        public string NFSFundCode { get; set; }
    }

    public class TransaksiProduct
    {
        public string ProdCode { get; set; }
        public string ProdName { get; set; }
        public string ProdId { get; set; }
        public string ProdCCY { get; set; }
    }    
}
