using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace Reksa.Models
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
        public string cmpsrSearch1 { get; set; }
        public string cmpsrSearch2 { get; set; }
        public string comboBox1 { get; set; }
        public string comboBox3 { get; set; }
        public string textPctSwc { get; set; }
        public System.DateTime TanggalValuta { get; set; }
        public int Id { get; set; }
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
        public string NomorGL { get; set; }
        public decimal Persentase { get; set; }
        public string OfficeId { get; set; }
    }

    public class listTieringSubsFee
    {
        public decimal PercentFrom { get; set; }
        public decimal PercentTo { get; set; }
        public string Persetujuan { get; set; }
    }
    public class parameterKYC
    {
        public string ClientCode { get; set; }
        public string SII { get; set; }
        public string IFUA { get; set; }
    }
    public class ParamSinkronisasi
    {
        public int ParamId { get; set; }
        public string ParamDesc { get; set; }
    }
    public class ParameterRedempFee
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public double MinPctFeeNonEmployee { get; set; }
        public double MaxPctFeeNonEmployee { get; set; }
        public double MinPctFeeEmployee { get; set; }
        public double MaxPctFeeEmployee { get; set; }
        public bool IsFlat { get; set; }
        public int NonFlatPeriod { get; set; }
        public int RedempIncFee { get; set; }
        public bool IsRedempIncFeeTrue { get { return RedempIncFee == 1; } set { this.RedempIncFee = 1; } }
        public bool IsRedempIncFeeFalse { get { return RedempIncFee != 1; } set { this.RedempIncFee = 0; } }
    }
    public class ParameterRedempFeeGL
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public int Sequence { get; set; }
        public string GLName { get; set; }
        public string GLNumber { get; set; }
        public decimal Percentage { get; set; }
        public string OfficeId { get; set; }
    }
    public class ParameterRedempFeePercentageTiering
    {
        public int ProductId { get; set; }
        public string Status { get; set; }
        public decimal PercentageFee { get; set; }
        public int Period { get; set; }
        public double Nominal { get; set; }

    }
    public class ParameterRedempFeeTieringNotif
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public decimal PercentFrom { get; set; }
        public decimal PercentTo { get; set; }
        public string MustApproveBy { get; set; }
    }
    public class ParamMFeeModel
    {
        public string TrxType { get; set; }
        public int prodId { get; set; }
        public int PeriodEfektif { get; set; }

    }
    public class ParamUpFrontSellGLModel
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public int Sequence { get; set; }
        public string GLName { get; set; }
        public int GLNumber { get; set; }
        public decimal Percentage { get; set; }
        public string OfficeId { get; set; }
    }
    public class ParamUpFrontSellingModel
    {
        public decimal PercentDefault { get; set; }
        public int ProdId { get; set; }
        public string TrxType { get; set; }
    }
    public class ProductMFeeModel
    {
        public decimal AUMMin { get; set; }
        public decimal AUMMax { get; set; }
        public decimal NISPPct { get; set; }
        public decimal FundMgrPct { get; set; }
        public decimal MaintenanceFee { get; set; }
    }
    public class ListGLMFeeModel
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public int Sequence { get; set; }
        public string GLName { get; set; }
        public int GLNumber { get; set; }
        public decimal Percentage { get; set; }
        public string OfficeId { get; set; }
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
    public class MaintainRedempFee
    {
        public int intNIK { get; set; }
        public string strModule { get; set; }
        public int intProdId { get; set; }
        public decimal decMinPctFeeEmployee { get; set; }
        public decimal decMaxPctFeeEmployee { get; set; }
        public decimal decMinPctFeeNonEmployee { get; set; }
        public decimal decMaxPctFeeNonEmployee { get; set; }
        public List<ParameterRedempFeeTieringNotif> listTieringNotif { get; set; }
        public List<ListSettingGL> listSettingGL { get; set; }
        public List<ParameterRedempFeePercentageTiering> listTieringPct { get; set; }
        public string strProcessType { get; set; }
        public bool IsFlat { get; set; }
        public int intNonFlatPeriod { get; set; }
        public bool RedempIncFeeout { get; set; }
    }
    public class MaintainMaitencanceFee
    {
        public int intNIK { get; set; }
        public string strModule { get; set; }
        public int intProdId { get; set; }
        public int intPeriodEfektif { get; set; }
        public List<PercentTieringMFee> listPercentTiering { get; set; }
        public List<ListSettingGL> listSettingGL { get; set; }
        public string strProcessType { get; set; }
    }
    public class PercentTieringMFee
    {
        public decimal AUMMin { get; set; }
        public decimal AUMMax { get; set; }
        public decimal NISPPct { get; set; }
        public decimal FundMgrPct { get; set; }
        public decimal MaintenanceFee { get; set; }
    }

    public class SettingGLMFee
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public int Sequence { get; set; }
        public string GLName { get; set; }
        public int GLNumber { get; set; }
        public decimal Percentage { get; set; }
        public string OfficeId { get; set; }
    }
    public class MaintainUpfrontSellingFee
    {
        public int intNIK { get; set; }
        public string strModule { get; set; }
        public int intProdId { get; set; }
        public List<ListSettingGL> listSettingGL { get; set; }
        public string strProcessType { get; set; }
        public string strJenisFee { get; set; }
        public decimal decPercentageDefault { get; set; }
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
    public class MaintainSwcFee
    {
        public int intNIK { get; set; }
        public string strModule { get; set; }
        public int intProdId { get; set; }
        public decimal decMinPctFeeEmployee { get; set; }
        public decimal decMaxPctFeeEmployee { get; set; }
        public decimal decMinPctFeeNonEmployee { get; set; }
        public decimal decMaxPctFeeNonEmployee { get; set; }
        public List<ParameterSwcFeeTieringNotif> listTieringNotif { get; set; }
        public List<ListSettingGL> listSettingGL { get; set; }
        public string strProcessType { get; set; }
        public decimal decSwitchingFeeout { get; set; }
    }
    public class SettingGLSwcFee
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public int Sequence { get; set; }
        public string GLName { get; set; }
        public int GLNumber { get; set; }
        public decimal Percentage { get; set; }
        public string OfficeId { get; set; }
    }
    public class ParameterSwcFeeTieringNotif
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public decimal PercentFrom { get; set; }
        public decimal PercentTo { get; set; }
        public string MustApproveBy { get; set; }
    }
    public class ReksaParamFeeSwc
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public decimal MinPctFeeEmployee { get; set; }
        public decimal MaxPctFeeEmployee { get; set; }
        public decimal MinPctFeeNonEmployee { get; set; }
        public decimal MaxPctFeeNonEmployee { get; set; }
    }
    public class UploadWaperd
    {
        public List<listWaperd> listWaperd { get; set; }
    }
    public class listWaperd
    {
        public int NIK { get; set; }
        public string Deskripsi { get; set; }
        public string TanggalExpired { get; set; }
    }
    public class MaintainLimitFeeIBMB
    {
        public int NIK { get; set; }
        public string Module { get; set; }
        public int ProdId { get; set; }
        public decimal MinSubsNew { get; set; }
        public decimal MinSubsAdd { get; set; }
        public decimal MinRedemption { get; set; }
        public decimal MinSwitching { get; set; }
        public decimal PctFeeSubs { get; set; }
        public decimal PctFeeRedemp { get; set; }
        public decimal PctFeeSwitching { get; set; }
        public decimal PctHoldAmount { get; set; }
        public string ProcessType { get; set; }
        public bool CanSubsNew { get; set; }
        public bool CanTrxIBank { get; set; }
        public bool CanTrxMBank { get; set; }
        public bool IsVisibleIBMB { get; set; }
        public bool MinRedempByUnit { get; set; }
        public bool MinSwitchingByUnit { get; set; }
        public bool RDBBit { get; set; }
        public bool RDBRedeemBit { get; set; }
        public bool RDBSwitchBit { get; set; }
        public decimal RDBMinSubs { get; set; }
        public decimal RDBFeeSubsIns { get; set; }
        public decimal RDBFeeSubsNoIns { get; set; }
        public bool RDBFullRedeemBit { get; set; }
        public decimal RDBFeeRedempIns { get; set; }
        public decimal RDBFeeRedempNoIns { get; set; }
        public bool RDBFullSwitchBit { get; set; }
    }
    public class MaintainParameter
    {
        public int Type { get; set; }
        public string InterfaceId { get; set; }
        public string Code { get; set; }
        public string Desc { get; set; }
        public string OfficeId { get; set; }
        public int ProdId { get; set; }
        public int Id { get; set; }
        public DateTime Value { get; set; }
        public int NIK { get; set; }
        public string Guid { get; set; }
    }
}
