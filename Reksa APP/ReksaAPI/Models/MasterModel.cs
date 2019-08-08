using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class MasterModel
    {
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
        public List<EmpolyeeSubsFee> dsNEmployeeSFee { get; set; }
        public List<EmpolyeeSubsFee> dsEmployeeSFee { get; set; }
        public decimal decUpFrontFee { get; set; }
        public decimal decSubcFeeBased { get; set; }
        public decimal decRedempFeeBased { get; set; }
        public decimal decMaintenanceFee { get; set; }
        public List<EmpolyeeRedempFee> dsNEmployeeRFee { get; set; }
        public List<EmpolyeeRedempFee> dsEmployeeRFee { get; set; }
        public string strMIAccountId { get; set; }
        public string strCTDAccountId { get; set; }
        public int intNIK { get; set; }
        public string strGUID { get; set; }
        public List<MaintFeeProduct> dsMaintenanceFee { get; set; }
        public decimal decDevidentPct { get; set; }
        public int intEffectiveAfter { get; set; }
    }
    public class EmpolyeeSubsFee
    {
        public decimal Fee { get; set; }
        public decimal Nominal { get; set; }
    }
    public class EmpolyeeRedempFee
    {
        public decimal Fee { get; set; }
        public int Period { get; set; }
        public decimal Nominal { get; set; }
    }
    public class MaintFeeProduct
    {
        public decimal AUMMin { get; set; }
        public decimal AUMMax { get; set; }
        public decimal NispPct { get; set; }
        public decimal FundMgrPct { get; set; }
        public decimal MaintFee { get; set; }
    }
}
