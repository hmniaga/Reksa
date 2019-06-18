using System;
using System.Collections.Generic;
using System.Data;
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
            List<DocumentModel.VerifyDocument> listVerDoc = new List<DocumentModel.VerifyDocument>();
            cls.ReksaPopulateVerifyDocuments(TranId, IsEdit, IsSwitching, IsBooking, strRefID, ref listVerDoc);
            return Json(new { listVerDoc });
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
            List<TransactionModel.BookingModel> listDetailBooking = new List<TransactionModel.BookingModel>();
            cls.ReksaRefreshBookingNew(RefID, NIK, GUID, ref listDetailBooking);
            return Json(new { listDetailBooking });
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
        [HttpGet]
        public JsonResult CalculateSwitchingFee([FromBody]CalculateFeeModel.SwitchingRequest feeModel)
        {
            bool blnResult;
            string ErrMsg;
            CalculateFeeModel.SwitchingResponses resultFee = new CalculateFeeModel.SwitchingResponses();
            blnResult = cls.ReksaCalcSwitchingFee(feeModel, out resultFee, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCalcSwitchingFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { resultFee });
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
            return Json(new { blnResult, ErrMsg });
        }        
        private JsonResult Json(object p, object allowGet)
        {
            throw new NotImplementedException();
        }

    }
}
