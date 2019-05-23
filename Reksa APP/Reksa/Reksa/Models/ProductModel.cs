using System;
using System.Collections.Generic;
using System.Data;
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
    public class ListProduct
    {
        public bool CheckB { get; set; }
        public int ProdId { get; set; }
        public string ProdCode { get; set; }
        public string ProdName { get; set; }
        public string CustodyCode { get; set; }

    }
    public class MaintainProduct
    {
        public int intType { get; set; }
        public int intProdId { get; set; }
        public string strProdCode { get; set; }
        public string strProdName { get; set; }
        public string strProdCCY { get; set; }
        public int intTypeId { get; set; }
        public int intManInvId { get; set; }
        public int intCustodyId { get; set; }
        public decimal decNAV { get; set; }
        public decimal decMinTotalUnit { get; set; }
        public decimal decMaxTotalUnit { get; set; }
        public decimal decMaxDailyUnit { get; set; }
        public decimal decMaxDailyCust { get; set; }
        public DateTime dtPeriodStart { get; set; }
        public DateTime dtPeriodEnd { get; set; }
        public DateTime dtMatureDate { get; set; }
        public DateTime dtChangeDate { get; set; }
        public DateTime dtValueDate { get; set; }
        public int intCloseEndBit { get; set; }
        public bool isDeviden { get; set; }
        public int intDevidenPeriod { get; set; }
        public DateTime dtDevidenDate { get; set; }
        public int intCalcId { get; set; }
        public DataSet dsNEmployeeSFee { get; set; }
        public DataSet dsEmployeeSFee { get; set; }
        public decimal decUpFrontFee { get; set; }
        public decimal decSubcFeeBased { get; set; }
        public decimal decRedempFeeBased { get; set; }
        public decimal decMaintenanceFee { get; set; }
        public DataSet dsNEmployeeRFee { get; set; }
        public DataSet dsEmployeeRFee { get; set; }
        public string strMIAccountId { get; set; }
        public string strCTDAccountId { get; set; }
        public int intNIK { get; set; }
        public string strGUID { get; set; }
        public DataSet dsMaintenanceFee { get; set; }
        public decimal decDevidentPct { get; set; }
        public int intEffectiveAfter { get; set; }
    }
    public class KinerjaProduk
    {
        public int ProdId { get; set; }
        public string ProdCode { get; set; }
        public string ProdName { get; set; }
        public string ProdCCY { get; set; }
        public string TypeName { get; set; }
        public DateTime ValueDate { get; set; }
        public bool IsVisible { get; set; }
        public decimal Sehari { get; set; }
        public decimal Seminggu { get; set; }
        public decimal Sebulan { get; set; }
        public decimal Setahun { get; set; }
        public int NIK { get; set; }
        public string Module { get; set; }
        public string ProcessType { get; set; }
    }
}
