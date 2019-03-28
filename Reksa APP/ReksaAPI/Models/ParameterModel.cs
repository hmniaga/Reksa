using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class ParameterModel
    {
        public int Id { get; set; }
        public string Kode { get; set; }
        public string Deskripsi { get; set; }
        public int ProdId { get; set; }
        public string Desc2 { get; set; }
        public string Desc5 { get; set; }
        public System.DateTime TglEfektif { get; set; }
        public System.DateTime TglExpire { get; set; }
        public string Keterangan { get; set; }
        public string MinSwitchRedempt { get; set; }
        public string JenisSwitchRedempt { get; set; }
        public string SwitchingFeeNonKaryawan { get; set; }
        public string SwitchingFeeKaryawan { get; set; }
        public string OfficeId { get; set; }
        public System.DateTime TanggalValuta { get; set; }
        public System.DateTime LastUpdate { get; set; }
        public string LastUser { get; set; }
    }

    public class MaintainParamGlobal
    {
        public int _intType { get; set; }
        public string _strTreeInterface { get; set; }
        public string txtbSP1 { get; set; }
        public string txtbSP2 { get; set; }
        public string txtbSP3 { get; set; }
        public string txtbSP4 { get; set; }
        public string txtbSP5 { get; set; }
        public string textBox1 { get; set; }
        public bool checkBox1 { get; set; }
        public System.DateTime dtpSP { get; set; }
        public System.DateTime dtpSP5 { get; set; }
        public string[] cmpsrSearch1 { get; set; }
        public string[] cmpsrSearch2 { get; set; }
        public string comboBox1 { get; set; }
        public string comboBox3 { get; set; }
        public string textPctSwc { get; set; }
        public System.DateTime TanggalValuta { get; set; }
        public int Id { get; set; }
    }

    public class ReksaParamFeeSubs
    {
        public string trxType { get; set; }
        public int prodId { get; set; }
        public decimal minPctFeeEmployee { get; set; }
        public decimal maxPctFeeEmployee { get; set; }
        public decimal minPctFeeNonEmployee { get; set; }
        public decimal maxPctFeeNonEmployee { get; set; }
    }

    public class ReksaTieringNotificationSubs
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public decimal PercentFrom { get; set; }
        public decimal PercentTo { get; set; }
        public string MustApproveBy { get; set; }
    }

    public class ReksaListGLFeeSubs
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public int Sequence { get; set; }
        public string GLName { get; set; }
        public int GLNumber { get; set; }
        public decimal Percentage { get; set; }
        public string OfficeId { get; set; }
    }

    public class MaintainFeeSubs
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public decimal minPctFeeEmployee { get; set; }
        public decimal maxPctFeeEmployee { get; set; }
        public decimal minPctFeeNonEmployee { get; set; }
        public decimal maxPctFeeNonEmployee { get; set; }
        public List<ListSettingGL> dtSettingGL { get; set; }
        public List<listTieringSubsFee> dtTieringSubsFee { get; set; }
    }
    public class ListSettingGL
    {
        public int Seq { get; set; }
        public string NamaGL { get; set; }
        public int NomorGL { get; set; }
        public decimal Persentase { get; set; }
        public string OfficeId { get; set; }
    }

    public class listTieringSubsFee
    {
        public decimal PercentFrom { get; set; }
        public decimal PercentTo { get; set; }
        public string Persetujuan { get; set; }
    }

    //Harja
    public class ReksaParamUpFrontSelling
    {
        public decimal PercentDefault { get; set; }
        public int ProdId { get; set; }
        public string TrxType { get; set; }
    }
    public class ReksaListGLUpFrontSelling
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public int Sequence { get; set; }
        public string GLName { get; set; }
        public int GLNumber { get; set; }
        public decimal Percentage { get; set; }
        public string OfficeId { get; set; }
    }
    //Harja End

    //NIco

    public class ReksaParamMFee
    {
        public string trxType { get; set; }
        public int prodId { get; set; }
        public int PeriodEfektif { get; set; }
    }
    
    public class ReksaProductMFee
    {
        public decimal AUMMin { get; set; }
        public decimal AUMMax { get; set; }
        public decimal NISPPct { get; set; }
        public decimal FundMgrPct { get; set; }
        public decimal MaintenanceFee { get; set; }
    }

    public class ReksaListGLMFee
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public int Sequence { get; set; }
        public string GLName { get; set; }
        public int GLNumber { get; set; }
        public decimal Percentage { get; set; }
        public string OfficeId { get; set; }
    }


    //end Nico


}
