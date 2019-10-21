using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ReksaAPI.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace ReksaAPI.Controllers
{
    public class TransactionController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;

        public object JsonRequestBehavior { get; private set; }

        public TransactionController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }

        [Route("api/Transaction/RefreshTransactionNew")]
        [HttpGet("{id}")]
        public JsonResult RefreshTransactionNew([FromQuery]string RefID, [FromQuery]string CIFNO, [FromQuery]int NIK, [FromQuery]string Guid, [FromQuery]string TranType)
        {
            bool blnResult;
            string ErrMsg;
            List<TransactionModel.SubscriptionDetail> listSubsDetail = new List<TransactionModel.SubscriptionDetail>();
            List<TransactionModel.SubscriptionList> listSubs = new List<TransactionModel.SubscriptionList>();
            List<TransactionModel.SubscriptionRDBList> listSubsRDB = new List<TransactionModel.SubscriptionRDBList>();
            List<TransactionModel.RedemptionList> listRedemp = new List<TransactionModel.RedemptionList>();
            blnResult = cls.ReksaRefreshTransactionNew(RefID, NIK, Guid, TranType, ref listSubsDetail, ref listSubs, ref listSubsRDB, ref listRedemp, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaRefreshTransactionNew - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listSubsDetail, listSubs, listSubsRDB, listRedemp });
        }

        [Route("api/Transaction/PopulateVerifyDocuments")]
        [HttpGet("{id}")]
        public JsonResult PopulateVerifyDocuments([FromQuery]int TranId, [FromQuery]bool IsEdit, [FromQuery]bool IsSwitching, [FromQuery]bool IsBooking, [FromQuery]string strRefID)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();
            blnResult = cls.ReksaPopulateVerifyDocuments(TranId, IsEdit, IsSwitching, IsBooking, strRefID, out dsResult, out ErrMsg);
            return Json(new { blnResult, ErrMsg, dsResult });
        }

        [Route("api/Transaction/RefreshSwitching")]
        [HttpGet("{id}")]
        public JsonResult RefreshSwitching([FromQuery]string RefID, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult;
            string ErrMsg;
            List<TransactionModel.SwitchingNonRDBModel> listDetailSwcNonRDB = new List<TransactionModel.SwitchingNonRDBModel>();
            blnResult = cls.ReksaRefreshSwitching(RefID, NIK, GUID, ref listDetailSwcNonRDB, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaRefreshSwitching - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listDetailSwcNonRDB });
        }

        [Route("api/Transaction/RefreshSwitchingRDB")]
        [HttpGet("{id}")]
        public JsonResult RefreshSwitchingRDB([FromQuery]string RefID, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult;
            string ErrMsg;
            List<TransactionModel.SwitchingRDBModel> listDetailSwcRDB = new List<TransactionModel.SwitchingRDBModel>();
            blnResult = cls.ReksaRefreshSwitchingRDB(RefID, NIK, GUID, ref listDetailSwcRDB, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaRefreshSwitchingRDB - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listDetailSwcRDB });
        }

        [Route("api/Transaction/RefreshBookingNew")]
        [HttpGet("{id}")]
        public JsonResult RefreshBookingNew([FromQuery]string RefID, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<TransactionModel.BookingModel> listDetailBooking = new List<TransactionModel.BookingModel>();
            blnResult = cls.ReksaRefreshBookingNew(RefID, NIK, GUID, ref listDetailBooking, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaRefreshBookingNew - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listDetailBooking });
        }
        [Route("api/Transaction/GetLatestBalance")]
        [HttpGet("{id}")]
        public JsonResult GetLatestBalance([FromQuery]int ClientID, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult;
            string ErrMsg;
            decimal unitBalance;
            blnResult = cls.ReksaGetLatestBalance(ClientID, NIK, GUID, out unitBalance, out ErrMsg);
            return Json(new { blnResult, ErrMsg, unitBalance });
        }
        [Route("api/Transaction/GetLatestNAV")]
        [HttpGet("{id}")]
        public JsonResult GetLatestNAV([FromQuery]int ProdId, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";
            decimal decNAV;
            blnResult = cls.ReksaGetLatestNAV(ProdId, NIK, GUID, out decNAV, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetLatestNAV - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, decNAV });
        }

        [Route("api/Transaction/CheckSubsType")]
        [HttpGet("{id}")]
        public JsonResult CheckSubsType([FromQuery]string CIFNo, [FromQuery]int ProductId, [FromQuery]bool IsTrxTA, [FromQuery]bool IsRDB)
        {
            bool blnResult;
            string ErrMsg;
            blnResult = cls.ReksaCheckSubsType(CIFNo, ProductId, IsTrxTA, IsRDB, out bool IsSubsNew, out string strClientCode, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCheckSubsType - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, IsSubsNew, strClientCode });
        }        

        [Route("api/Transaction/GetImportantData")]
        [HttpGet("{id}")]
        public JsonResult GetImportantData([FromQuery]string CariApa, [FromQuery]string Input)
        {
            string value;
            value = cls.ReksaGetImportantData(CariApa, Input);
            return Json(new { value });
        }
     
        [Route("api/Transaction/CalculateFee")]
        [HttpGet("{id}")]
        public JsonResult CalculateFee([FromBody]CalculateFeeModel.CalculateFeeRequest model)
        {
            bool blnResult;
            string ErrMsg;
            CalculateFeeModel.CalculateFeeResponse resultFee = new CalculateFeeModel.CalculateFeeResponse();
            blnResult = cls.ReksaCalcFee(model, out resultFee, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCalcFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, resultFee });
        }

        [Route("api/Transaction/CalculateSwitchingFee")]
        [HttpGet("{id}")]
        public JsonResult CalculateSwitchingFee([FromBody]CalculateFeeModel.SwitchingRequest model)
        {
            bool blnResult;
            string ErrMsg;
            CalculateFeeModel.SwitchingResponses resultFee = new CalculateFeeModel.SwitchingResponses();
            blnResult = cls.ReksaCalcSwitchingFee(model, out resultFee, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCalcSwitchingFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, resultFee });
        }

        [Route("api/Transaction/CalculateSwitchingRDBFee")]
        [HttpGet("{id}")]
        public JsonResult CalculateSwitchingRDBFee([FromBody]CalculateFeeModel.SwitchingRDBRequest feeModel)
        {
            bool blnResult = false;
            string ErrMsg = "";
            CalculateFeeModel.SwitchingRDBResponses resultFee = new CalculateFeeModel.SwitchingRDBResponses();
            blnResult = cls.ReksaCalcSwitchingRDBFee(feeModel, out resultFee, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCalcSwitchingRDBFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, resultFee });
        }

        [Route("api/Transaction/CalculateBookingFee")]
        [HttpGet("{id}")]
        public JsonResult CalculateBookingFee([FromQuery]string CIFNo, [FromQuery]decimal Amount, 
            [FromQuery]string ProductCode, [FromQuery]bool IsByPercent, [FromQuery]bool IsFeeEdit, 
            [FromQuery]decimal PercentageFeeInput)
        {
            bool blnResult = false;
            string ErrMsg = "";
            blnResult  = cls.ReksaCalcBookingFee(CIFNo, Amount, ProductCode, IsByPercent, IsFeeEdit, PercentageFeeInput
            , out decimal PercentageFeeOutput, out string FeeCCY, out decimal Fee, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCalcBookingFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, PercentageFeeOutput, FeeCCY, Fee });
        }
        [Route("api/Transaction/MaintainAllTransaksiNew")]
        [HttpGet("{id}")]
        public JsonResult   MaintainAllTransaksiNew([FromQuery]int NIK, [FromQuery]string GUID, [FromBody]TransactionModel.MaintainTransaksi model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string strRefID = "";

            DataTable dtError = new DataTable();
            blnResult = cls.ReksaMaintainAllTransaksiNew(NIK, GUID, model, out ErrMsg, out strRefID, out dtError);

            ErrMsg = ErrMsg.Replace("ReksaMaintainAllTransaksiNew - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, strRefID, dtError });
        }
        [Route("api/Transaction/MaintainSwitching")]
        [HttpGet("{id}")]
        public JsonResult MaintainSwitching([FromBody]TransactionModel.MaintainSwitching model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string strRefID = "";

            DataTable dtError = new DataTable();
            blnResult = cls.ReksaMaintainSwitching(model, out ErrMsg, out strRefID, out dtError);

            ErrMsg = ErrMsg.Replace("ReksaMaintainSwitching - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, strRefID, dtError });
        }
        [Route("api/Transaction/MaintainSwitchingRDB")]
        [HttpGet("{id}")]
        public JsonResult MaintainSwitchingRDB([FromBody]TransactionModel.MaintainSwitchingRDB model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string strRefID = "";

            DataTable dtError = new DataTable();
            blnResult = cls.ReksaMaintainSwitchingRDB(model, out ErrMsg, out strRefID, out dtError);

            ErrMsg = ErrMsg.Replace("ReksaMaintainSwitchingRDB - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, strRefID, dtError });
        }
        [Route("api/Transaction/MaintainNewBooking")]
        [HttpGet("{id}")]
        public JsonResult MaintainNewBooking([FromBody]TransactionModel.MaintainBooking model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string strRefID = "";

            DataTable dtError = new DataTable();
            blnResult = cls.ReksaMaintainNewBooking(model, out ErrMsg, out strRefID, out dtError);

            ErrMsg = ErrMsg.Replace("ReksaMaintainNewBooking - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, strRefID, dtError });
        }
        

        [Route("api/Transaction/GenerateTranCodeClientCode")]
        [HttpGet("{id}")]
        public JsonResult GenerateTranCodeClientCode([FromBody]TransactionModel.GenerateClientCode model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string[] strData = new string[4];
            blnResult = cls.ReksaGenerateTranCodeClientCode(model, out strData[0], out strData[1], out ErrMsg, out strData[2], out strData[3]);

            ErrMsg = ErrMsg.Replace("ReksaGenerateTranCodeClientCode - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, strData });
        }
        [Route("api/Transaction/GetRegulerSubscriptionTunggakan")]
        [HttpGet("{id}")]
        public JsonResult GetRegulerSubscriptionTunggakan([FromQuery]int ClientId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<TransactionModel.Tunggakan> listTunggakan = new List<TransactionModel.Tunggakan>();
            blnResult = cls.ReksaRegulerSubscriptionTunggakan(ClientId, out ErrMsg, out listTunggakan);
            ErrMsg = ErrMsg.Replace("ReksaRegulerSubscriptionTunggakan - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listTunggakan });
        }
        [Route("api/Transaction/PopulateTTCompletion")]
        [HttpGet("{id}")]
        public JsonResult PopulateTTCompletion([FromQuery]int ProdId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            TransactionModel.TransactionTT listTTCompletion = new TransactionModel.TransactionTT();
            blnResult = cls.ReksaPopulateTTCompletion(ProdId, out ErrMsg, out listTTCompletion);
            ErrMsg = ErrMsg.Replace("ReksaPopulateTTCompletion - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listTTCompletion });
        }
        [Route("api/Transaction/MaintainCompletion")]
        [HttpGet("{id}")]
        public JsonResult MaintainCompletion([FromBody]TransactionModel.TransactionTT model)
        {
            bool blnResult = false;
            string ErrMsg = "";

            blnResult = cls.ReksaMaintainCompletion(model, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainCompletion - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Transaction/InitializeDataTTCompletion")]
        [HttpGet("{id}")]
        public JsonResult InitializeDataTTCompletion([FromQuery]int ProdId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            TransactionModel.TransactionTT listTTCompletion = new TransactionModel.TransactionTT();
            blnResult = cls.ReksaInitializeDataTTCompletion(ProdId, out ErrMsg, out listTTCompletion);
            ErrMsg = ErrMsg.Replace("ReksaInitializeDataTTCompletion - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listTTCompletion });
        }
        [Route("api/Transaction/PopulateOutgoingTT")]
        [HttpGet("{id}")]
        public JsonResult PopulateOutgoingTT([FromQuery]int ProdId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<TransactionModel.OutgoingTT> listOutgoingTT = new List<TransactionModel.OutgoingTT>();
            blnResult = cls.ReksaPopulateOutgoingTT(out ErrMsg, out listOutgoingTT);
            ErrMsg = ErrMsg.Replace("ReksaPopulateOutgoingTT - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listOutgoingTT });
        }
        [Route("api/Transaction/MaintainOutgoingTT")]
        [HttpGet("{id}")]
        public JsonResult MaintainOutgoingTT([FromQuery]int BillId, [FromQuery]bool isProcess, [FromQuery]string AlasanDelete, [FromQuery]int NIK)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string IsCurrencyHoliday;
            DateTime dtNewValueDate;

            blnResult = cls.ReksaMaintainOutgoingTT(BillId, isProcess, AlasanDelete, NIK, out IsCurrencyHoliday, out dtNewValueDate, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainOutgoingTT - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, IsCurrencyHoliday, dtNewValueDate });
        }
        [Route("api/Transaction/ManualUpdateRiskProfile")]
        [HttpGet("{id}")]
        public JsonResult ManualUpdateRiskProfile([FromQuery]string CIFNo, [FromQuery]string NewLastUpdate)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DateTime dtNewLastUpdate = new DateTime();
            DateTime.TryParseExact(NewLastUpdate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtNewLastUpdate);

            blnResult = cls.ReksaManualUpdateRiskProfile(CIFNo, dtNewLastUpdate, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaManualUpdateRiskProfile - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Transaction/PrepareDataJurnalTT")]
        [HttpGet("{id}")]
        public JsonResult PrepareDataJurnalTT([FromQuery]int NIK, [FromQuery]string Branch, [FromQuery]int BillId, [FromQuery]string JenisJurnal)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string IsCurrencyHoliday = "";
            string strNewValueDate = "";
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaPrepareDataJurnalTT(NIK, Branch, BillId, JenisJurnal, out ErrMsg, out IsCurrencyHoliday, out strNewValueDate, out dsResult);
            ErrMsg = ErrMsg.Replace("ReksaPrepareDataJurnalTT - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, IsCurrencyHoliday, strNewValueDate, dsResult });
        }
        [Route("api/Transaction/UpdateStatusJurnalTT")]
        [HttpGet("{id}")]
        public JsonResult UpdateStatusJurnalTT([FromBody]MaintainStatusJurnalTT model)
        {
            bool blnResult = false;
            string ErrMsg = "";

            blnResult = cls.ReksaUpdateStatusJurnalTT(model, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaUpdateStatusJurnalTT - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Transaction/AuthorizeOutgoingTT")]
        [HttpGet("{id}")]
        public JsonResult AuthorizeOutgoingTT([FromQuery]int NIK, [FromQuery]string JenisProses, [FromQuery]bool isProcess, [FromQuery]string BillId, [FromQuery]string RemittanceNumber)
        {
            bool blnResult = false;
            string ErrMsg = "";

            string[] selectedBillId;
            int intBillId = 0;
            BillId = (BillId + "***").Replace("|***", "");
            selectedBillId = BillId.Split('|');

            foreach (string s in selectedBillId)
            {
                int.TryParse(s, out intBillId);
                blnResult = cls.ReksaAuthorizeOutgoingTT(NIK, JenisProses, isProcess, intBillId, RemittanceNumber, out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaAuthorizeOutgoingTT - Core .Net SqlClient Data Provider\n", "");
            }
            return Json(new { blnResult, ErrMsg });
        }
        //[Route("api/Transaction/PopulateVerifyOutgoingTT")]
        //[HttpGet("{id}")]
        //public JsonResult PopulateVerifyOutgoingTT([FromQuery]string JenisProses)
        //{
        //    bool blnResult = false;
        //    string ErrMsg = "";
        //    DataSet dsResult = new DataSet();

        //    blnResult = cls.ReksaPopulateVerifyOutgoingTT(JenisProses, out ErrMsg, out dsResult);
        //    ErrMsg = ErrMsg.Replace("ReksaPopulateVerifyOutgoingTT - Core .Net SqlClient Data Provider\n", "");
        //    return Json(new { blnResult, ErrMsg, dsResult });
        //}
        //[Route("api/Transaction/ProcessTT")]
        //[HttpGet("{id}")]
        //public JsonResult ProcessTT([FromQuery]int NIK, [FromQuery]string Branch, [FromQuery]string BillId, [FromQuery]string JenisJurnal)
        //{
        //    bool blnResult = false;
        //    string ErrMsg = "";
        //    string strErr = "";
        //    string IsCurrencyHoliday = "";
        //    string strNewValueDate = "";
        //    DataSet dsResult = new DataSet();

        //    string strRemittanceNumber = "";
        //    string strGuidPB, strGuidTT;
        //    bool bStatusPB = true;
        //    bool bStatusTT = true;
        //    strGuidPB = System.Guid.NewGuid().ToString();
        //    strGuidTT = System.Guid.NewGuid().ToString();
        //    //20130614, liliana, ODKIB12036, begin
        //    //DataTable dtDataPB = PrepareDataPBGL(BillId, "PB");
        //    string isHolidayCurrency = "";
        //    DateTime NewValueDate = DateTime.Today;

        //    DataTable dtDataPB = PrepareDataPBGL(NIK, Branch, BillId, "PB", out isHolidayCurrency, out NewValueDate);

        //    if (dtDataPB == null)
        //    {
        //        ErrMsg = "Gagal generate data GL vs GNC (1)!";
        //        return;
        //    }

        //    if (dtDataPB.Rows.Count == 0)
        //    {
        //        ErrMsg = "Gagal generate data GL vs GNC (2)!";
        //        return;
        //    }

        //    DataTable dtDataTT = PrepareDataPBGL(NIK, Branch, BillId, "TT", out isHolidayCurrency, out NewValueDate);

        //    if (dtDataTT == null)
        //    {
        //        ErrMsg = "Gagal generate data TT (1)!";
        //        return;
        //    }

        //    if (dtDataTT.Rows.Count == 0)
        //    {
        //        ErrMsg = "Gagal generate data TT (2)!";
        //        return;
        //    }
        //    string Today = System.DateTime.Today.ToString("dd-MMM-yyyy");
        //    string strNewDate = NewValueDate.ToString("dd-MMM-yyyy");

        //    if (isHolidayCurrency != "")
        //    {
        //        ErrMsg = "Karena tanggal " + Today.ToString() + "adalah Currency Holiday. Tanggal valuta menggunakan tanggal " + strNewDate.ToString();
        //    }

        //    //lakukan transaksi GL vs GNC (valas)
        //    bStatusPB = TransactionGLvsGNC(BillId, dtDataPB, strGuidPB, strTTMasterGuid, out strErr);

        //    if (strErr.ToString() != "")
        //    {
        //        ErrMsg = strErr.ToString();
        //        TransactionCreateABCSReverse(strGuidPB, BillId);
        //        bStatusPB = false;
        //    }

        //    if (bStatusPB == true)
        //    {
        //        //lakukan transaksi TT
        //        bStatusTT = TransactionTT(BillId, dtDataTT, strGuidTT, strTTMasterGuid, out strErr, out strRemittanceNumber);

        //        if (strErr.ToString() != "")
        //        {
        //            ErrMsg = strErr.ToString();
        //            bStatusTT = false;
        //        }

        //    }

        //    //Kalau ke 2 nya sudah sukses
        //    if ((bStatusPB == true) && (bStatusTT == true))
        //    {
        //        //ubah status otor menjadi 1
        //        if (subAuthOutgoingTT("Proses Outgoing TT", true, BillId, strRemittanceNumber))
        //        {
        //            MessageBox.Show("Data berhasil diproses dan dijurnal! Remittance Number : " + strRemittanceNumber.ToString(), "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
        //        }
        //        else
        //        {
        //            MessageBox.Show("Error Melakukan Approve Data!", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        //        }
        //    }

        //    //refresh ulang tampilan
        //    subPopulate(JenisProses);




        //    blnResult = cls.ReksaPrepareDataJurnalTT(NIK, Branch, BillId, JenisJurnal, out ErrMsg, out IsCurrencyHoliday, out strNewValueDate, out dsResult);
        //    ErrMsg = ErrMsg.Replace("ReksaPrepareDataJurnalTT - Core .Net SqlClient Data Provider\n", "");
        //    return Json(new { blnResult, ErrMsg, IsCurrencyHoliday, strNewValueDate, dsResult });
        //}
        //private DataTable PrepareDataPBGL(int NIK, string Branch, string BillId, string JenisJurnal, out string IsCurrencyHoliday, out DateTime NewValueDate)
        //{
        //    string ErrMsg = "";

        //    IsCurrencyHoliday = "";
        //    NewValueDate = DateTime.Today;
        //    string strNewValueDate = "";
        //    DataSet dsResult = new DataSet();
        //    int intBillId;
        //    int.TryParse(BillId, out intBillId);

        //    if (cls.ReksaPrepareDataJurnalTT(NIK, Branch, intBillId, JenisJurnal, out ErrMsg, out IsCurrencyHoliday, out strNewValueDate, out dsResult))
        //    {
        //        DateTime.TryParse(strNewValueDate, out NewValueDate);
        //        return dsResult.Tables[0];
        //    }
        //    else
        //    {
        //        return null;
        //    }
        //}
        //private bool TransactionGLvsGNC(int NIK, string Branch, string BillId, DataTable dtDataPB, string strGuid, string strTTGuid, out string strErrorMsg)
        //{
        //    string StatusPB;
        //    bool bSuccess = true;
        //    strErrorMsg = "";
        //    StatusPB = dtDataPB.Rows[0]["StatusJurnal"].ToString();
        //    MaintainStatusJurnalTT model = new MaintainStatusJurnalTT();

        //    //lakukan jurnal, jika status sudah berhasil/suspect tidak dijurnal ulang  
        //    //lakukan jurnal GL vs GNC via trancode 7092
        //    if ((StatusPB != "1") && (StatusPB != "3"))
        //    {
        //        string strTransactionBranch = Branch;
        //        string strEffectiveDate = dtDataPB.Rows[0]["EffectiveDate"].ToString();                
        //        decimal dcChargeAmount = 0;
        //        decimal dcChargeRate = 0;
        //        string strChargesCurrency = "";
        //        string strBranchCodeDebitting = dtDataPB.Rows[0]["BranchCodeDebitting"].ToString();
        //        string strBranchCodeCreditting = dtDataPB.Rows[0]["BranchCodeCrediting"].ToString();
        //        string strRemark1 = dtDataPB.Rows[0]["Remark1"].ToString();
        //        string strRemark2 = "";
        //        string strRemark3 = "";
        //        string strDealNoCredit = "";
        //        string strDealNoDebit = "";
        //        string strSIBSTranCode = "7092";
        //        string strSupervisorId = NIK.ToString();
        //        string strLogDesc = "Online Journal GL vs GNC on authorization - Bill Id : " + BillId.ToString() + " - Debit Account No : " + model.DebitAccount + " - Credit Account No : " + model.CreditAccount;


        //        int intBillId;
        //        int.TryParse(BillId, out intBillId);
        //        model.BillId = intBillId;
        //        model.TTGuid = strTTGuid;
        //        model.Guid = strGuid;
        //        model.JenisJurnal = "PB";
        //        model.CreditAccount = dtDataPB.Rows[0]["CredittingAccount"].ToString();
        //        model.CreditCurrency = dtDataPB.Rows[0]["CredittingCurrency"].ToString();
        //        model.CreditAmount = decimal.Parse(dtDataPB.Rows[0]["CredittingAmount"].ToString());
        //        model.DebitAccount = dtDataPB.Rows[0]["DebittingAccount"].ToString();
        //        model.DebitCurrency = dtDataPB.Rows[0]["DebittingCurrency"].ToString();
        //        model.DebitAmount = decimal.Parse(dtDataPB.Rows[0]["DebittingAmount"].ToString());
        //        model.TTBuy = decimal.Parse(dtDataPB.Rows[0]["TTBuy"].ToString());
        //        model.TTSell = decimal.Parse(dtDataPB.Rows[0]["TTSell"].ToString());
        //        model.BNBuy = decimal.Parse(dtDataPB.Rows[0]["TTBuy"].ToString());
        //        model.BNSell = decimal.Parse(dtDataPB.Rows[0]["TTSell"].ToString());
        //        model.FeeFullAmount = 0;
        //        model.FeeCurrency = "";
        //        model.DebittingAccountFee = "";
        //        model.Status = bSuccess;
        //        model.ErrorMsg = strErrorMsg;

        //       //bSuccess = this._clsCoreBankMessaging.TransactionOverbooking7092(
        //       //this.ClQ, NIK
        //       //, strLogDesc, strGuid, strTransactionBranch, strEffectiveDate
        //       //, model.DebitAccount, model.DebitAmount, model.CreditAccount
        //       //, model.CreditAmount, model.TTBuy, model.TTSell
        //       //, dcChargeAmount, dcChargeRate, model.DebitCurrency
        //       //, model.CreditCurrency, strChargesCurrency
        //       //, strBranchCodeDebitting, strBranchCodeCreditting
        //       //, strRemark1, strRemark2, strRemark3, strDealNoCredit
        //       //, strDealNoDebit, strSIBSTranCode, strSupervisorId
        //       //, out strErrorMsg);

        //        if (strErrorMsg != "")
        //        {
        //            bSuccess = false;
        //        }                
        //        bSuccess = cls.ReksaUpdateStatusJurnalTT(model, out strErrorMsg);
        //    }
        //    return bSuccess;
        //}
        //private bool TransactionCreateABCSReverse(string Guid, string BillId)
        //{
        //    bool bOK = false;
        //    string strErrorMsg = "";
        //    string strLogDesc = "Reverse Online Journal GL vs GNC on authorization - Bill Id : " + BillId.ToString();

        //    //bOK = this._clsCoreBankMessaging.TransactionCreateABCSReverse(this.ClQ, strLogDesc, Guid, out strErrorMsg);

        //    return bOK;
        //}

        //private bool TransactionTT(string Branch, string BillId, DataTable dtDataTT, string strGuid, string strTTGuid, out string strErrorMsg, out string strResult)
        //{
        //    string StatusTT;
        //    bool bSuccess = true;
        //    strErrorMsg = "";
        //    strResult = "";
        //    StatusTT = dtDataTT.Rows[0]["StatusJurnal"].ToString();

        //    //lakukan jurnal, jika status sudah berhasil/suspect tidak dijurnal ulang  
        //    //lakukan jurnal transaksi TT
        //    if ((StatusTT != "1") && (StatusTT != "3"))
        //    {
        //        string strBankRef = dtDataTT.Rows[0]["BankRef"].ToString();
        //        string strClientRef = dtDataTT.Rows[0]["ClientRef"].ToString();
        //        string strValueDate = dtDataTT.Rows[0]["ValueDate"].ToString();
        //        string strRemittingCcy = dtDataTT.Rows[0]["RemittingCcy"].ToString();
        //        decimal dcRemittingAmt = decimal.Parse(dtDataTT.Rows[0]["RemittingAmt"].ToString());
        //        string strDebitAccountCcy = dtDataTT.Rows[0]["DebitAccountCcy"].ToString();
        //        string strDebittingAcctNo = dtDataTT.Rows[0]["DebittingAcctNo"].ToString();
        //        string strApplicantName = dtDataTT.Rows[0]["ApplicantName"].ToString();
        //        string strBeneficiaryName = dtDataTT.Rows[0]["BeneficiaryName"].ToString();
        //        string strBeneAcctNo = dtDataTT.Rows[0]["BeneAcctNo"].ToString();
        //        string strBeneAddr1 = dtDataTT.Rows[0]["BeneAddr1"].ToString();
        //        string strBeneAddr2 = dtDataTT.Rows[0]["BeneAddr2"].ToString();
        //        string strBeneAddr3 = dtDataTT.Rows[0]["BeneAddr3"].ToString();
        //        string strBeneBankSwiftId = dtDataTT.Rows[0]["BeneBankSwiftId"].ToString();
        //        string strBeneBankName = dtDataTT.Rows[0]["BeneBankName"].ToString();
        //        string strBeneBankAddr1 = dtDataTT.Rows[0]["BeneBankAddr1"].ToString();
        //        string strBeneBankAddr2 = dtDataTT.Rows[0]["BeneBankAddr2"].ToString();
        //        string strBeneBankAddr3 = dtDataTT.Rows[0]["BeneBankAddr3"].ToString();
        //        string strIntBankSwiftId = dtDataTT.Rows[0]["IntBankSwiftId"].ToString();
        //        string strIntBankName = dtDataTT.Rows[0]["IntBankName"].ToString();
        //        string strIntBankAddr1 = dtDataTT.Rows[0]["IntBankAddr1"].ToString();
        //        string strIntBankAddr2 = dtDataTT.Rows[0]["IntBankAddr2"].ToString();
        //        string strIntBankAddr3 = dtDataTT.Rows[0]["IntBankAddr3"].ToString();
        //        string strDescription = dtDataTT.Rows[0]["PayDetail1"].ToString() + ' ' + dtDataTT.Rows[0]["PayDetail2"].ToString();
        //        string strSenderRecvInfo1 = dtDataTT.Rows[0]["SenderRecvInfo1"].ToString();
        //        string strSenderRecvInfo2 = dtDataTT.Rows[0]["SenderRecvInfo2"].ToString();
        //        string strSenderRecvInfo3 = dtDataTT.Rows[0]["SenderRecvInfo3"].ToString();
        //        string strDetailsOfCharges = dtDataTT.Rows[0]["DetailsOfCharges"].ToString();
        //        string strOrderingCustAddr1 = dtDataTT.Rows[0]["OrderingCustAddr1"].ToString();
        //        string strOrderingCustAddr2 = dtDataTT.Rows[0]["OrderingCustAddr2"].ToString();
        //        string strOrderingCustAddr3 = dtDataTT.Rows[0]["OrderingCustAddr3"].ToString();
        //        string strSenderRecvInfo4 = dtDataTT.Rows[0]["SenderRecvInfo4"].ToString();
        //        string strSenderRecvInfo5 = dtDataTT.Rows[0]["SenderRecvInfo5"].ToString();
        //        string strSenderRecvInfo6 = dtDataTT.Rows[0]["SenderRecvInfo6"].ToString();
        //        string strResident = dtDataTT.Rows[0]["Resident"].ToString();
        //        string strRemitterCountryOfResidentCode = dtDataTT.Rows[0]["RemitterCountryOfResidentCode"].ToString();
        //        string strRemitterCategory = dtDataTT.Rows[0]["RemitterCategory"].ToString();
        //        string strBeneficiaryCountryOfResidentCode = dtDataTT.Rows[0]["BeneficiaryCountryOfResidentCode"].ToString();
        //        string strBeneficiaryCategory = dtDataTT.Rows[0]["BeneficiaryCategory"].ToString();
        //        string strBeneficiaryAffiliationStatus = dtDataTT.Rows[0]["BeneficiaryAffiliationStatus"].ToString();
        //        string strPaymentPurpose = dtDataTT.Rows[0]["PaymentPurpose"].ToString();
        //        decimal TTBuy = decimal.Parse(dtDataTT.Rows[0]["TTBuy"].ToString());
        //        decimal TTSell = decimal.Parse(dtDataTT.Rows[0]["TTSell"].ToString());
        //        decimal BNBuy = decimal.Parse(dtDataTT.Rows[0]["BNBuy"].ToString());
        //        decimal BNSell = decimal.Parse(dtDataTT.Rows[0]["BNSell"].ToString());
        //        decimal NostroFee = decimal.Parse(dtDataTT.Rows[0]["NostroFee"].ToString());
        //        decimal TaxFee = decimal.Parse(dtDataTT.Rows[0]["TaxFee"].ToString());
        //        decimal FullAmountFee = decimal.Parse(dtDataTT.Rows[0]["FullAmountFee"].ToString());
        //        decimal TransferFee = decimal.Parse(dtDataTT.Rows[0]["TransferFee"].ToString());
        //        decimal ProvFee = decimal.Parse(dtDataTT.Rows[0]["ProvFee"].ToString());
        //        decimal DebittingAmountWithoutFee = decimal.Parse(dtDataTT.Rows[0]["DebittingAmountWithoutFee"].ToString());
        //        string strCIFNumber = dtDataTT.Rows[0]["CIFNumber"].ToString();
        //        string strNostroBICCode = dtDataTT.Rows[0]["NostroBICCode"].ToString();
        //        string strDebittingAccountFee = dtDataTT.Rows[0]["DebittingAccountFee"].ToString();
        //        string strFeeCurrencyCode = dtDataTT.Rows[0]["FeeCurrencyCode"].ToString();

        //        string strLogDesc = "Online Journal TT on authorization - Bill Id : " + BillId.ToString() + " - Debit Account No : " + strDebittingAcctNo + " - Credit Account No : " + strBeneAcctNo;

        //        bSuccess = this._clsCoreBankMessaging.CallTransactionTTOrdering(
        //       this.ClQ, intNIK
        //       , strLogDesc, strGuid, strBankRef, strClientRef, strValueDate, strRemittingCcy, dcRemittingAmt
        //       , strDebitAccountCcy, strDebittingAcctNo, strApplicantName, strBeneficiaryName, strBeneAcctNo
        //       , strBeneAddr1, strBeneAddr2, strBeneAddr3, strBeneBankSwiftId, strBeneBankName, strBeneBankAddr1
        //       , strBeneBankAddr2, strBeneBankAddr3, strIntBankSwiftId, strIntBankName, strIntBankAddr1, strIntBankAddr2
        //       , strIntBankAddr3, strDescription, strSenderRecvInfo1, strSenderRecvInfo2, strSenderRecvInfo3, strDetailsOfCharges
        //       , strOrderingCustAddr1, strOrderingCustAddr2, strOrderingCustAddr3, strSenderRecvInfo4
        //       , strSenderRecvInfo5, strSenderRecvInfo6, strResident, strRemitterCountryOfResidentCode
        //       , strRemitterCategory, strBeneficiaryCountryOfResidentCode, strBeneficiaryCategory
        //       , strBeneficiaryAffiliationStatus, strPaymentPurpose, TTBuy, TTSell, BNBuy, BNSell, NostroFee
        //       , TaxFee, FullAmountFee, TransferFee, ProvFee, DebittingAmountWithoutFee, Branch
        //       , strCIFNumber, strNostroBICCode, strDebittingAccountFee, strFeeCurrencyCode
        //       , out strResult
        //       , out strErrorMsg);

        //        if (strErrorMsg != "")
        //        {
        //            bSuccess = false;
        //        }

        //        UpdateLogJurnalTransaction(BillId, strTTGuid, strGuid, "TT", strBeneAcctNo, strRemittingCcy, dcRemittingAmt,
        //            strDebittingAcctNo, strDebitAccountCcy, DebittingAmountWithoutFee, TTBuy, TTSell, BNBuy, BNSell,
        //            FullAmountFee, strFeeCurrencyCode, strDebittingAccountFee,
        //            bSuccess,
        //            strErrorMsg);
        //    }

        //    return bSuccess;
        //}
    }
}
