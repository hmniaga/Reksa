using System;
using System.Collections.Generic;
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
            List<TransactionModel.SubscriptionDetail> listSubsDetail = new List<TransactionModel.SubscriptionDetail>();
            List<TransactionModel.SubscriptionList> listSubs = new List<TransactionModel.SubscriptionList>();
            List<TransactionModel.SubscriptionRDBList> listSubsRDB = new List<TransactionModel.SubscriptionRDBList>();
            List<TransactionModel.RedemptionList> listRedemp = new List<TransactionModel.RedemptionList>();
            cls.ReksaRefreshTransactionNew(RefID, NIK, Guid, TranType, ref listSubsDetail, ref listSubs, ref listSubsRDB, ref listRedemp);
            return Json(new { listSubsDetail, listSubs, listSubsRDB, listRedemp });
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
            List<TransactionModel.SwitchingNonRDBModel> listDetailSwcNonRDB = new List<TransactionModel.SwitchingNonRDBModel>();
            cls.ReksaRefreshSwitching(RefID, NIK, GUID, ref listDetailSwcNonRDB);
            return Json(new { listDetailSwcNonRDB });
        }

        [Route("api/Transaction/RefreshSwitchingRDB")]
        [HttpGet("{id}")]
        public JsonResult RefreshSwitchingRDB([FromQuery]string RefID, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            List<TransactionModel.SwitchingRDBModel> listDetailSwcRDB = new List<TransactionModel.SwitchingRDBModel>();
            cls.ReksaRefreshSwitchingRDB(RefID, NIK, GUID, ref listDetailSwcRDB);
            return Json(new { listDetailSwcRDB });
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
            decimal unitBalance;
            unitBalance = cls.ReksaGetLatestBalance(ClientID, NIK, GUID);
            return Json(new { unitBalance });
        }
        

        [Route("api/Transaction/GetLatestNAV")]
        [HttpGet("{id}")]
        public JsonResult GetLatestNAV([FromQuery]int ProdId, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            decimal NAV;
            NAV = cls.ReksaGetLatestNAV(ProdId, NIK, GUID);
            return Json(new { NAV });
        }

        [Route("api/Transaction/CheckSubsType")]
        [HttpGet("{id}")]
        public JsonResult CheckSubsType([FromQuery]string CIFNo, [FromQuery]int ProductId, [FromQuery]bool IsTrxTA, [FromQuery]bool IsRDB)
        {
            cls.ReksaCheckSubsType(CIFNo, ProductId, IsTrxTA, IsRDB, out bool IsSubsNew, out string strClientCode);
            return Json(new { IsSubsNew, strClientCode });
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
        public JsonResult CalculateFee([FromBody]CalculateFeeModel.GlobalFeeRequest feeModel)
        {
            CalculateFeeModel.GlobalFeeResponse resultFee = new CalculateFeeModel.GlobalFeeResponse();
            resultFee = cls.ReksaCalcFee(feeModel);
            return Json(new { resultFee });
        }

        [Route("api/Transaction/CalculateSwitchingFee")]
        [HttpGet]
        public JsonResult CalculateSwitchingFee([FromBody]CalculateFeeModel.SwitchingRequest feeModel)
        {
            CalculateFeeModel.SwitchingResponses resultFee = new CalculateFeeModel.SwitchingResponses();
            resultFee = cls.ReksaCalcSwitchingFee(feeModel);
            return Json(new { resultFee });
        }

        [Route("api/Transaction/CalculateSwitchingRDBFee")]
        [HttpGet("{id}")]
        public JsonResult CalculateSwitchingRDBFee([FromBody]CalculateFeeModel.SwitchingRDBRequest feeModel)
        {
            CalculateFeeModel.SwitchingRDBResponses resultFee = new CalculateFeeModel.SwitchingRDBResponses();
            resultFee = cls.ReksaCalcSwitchingRDBFee(feeModel);
            return Json(new { resultFee });
        }

        [Route("api/Transaction/CalculateBookingFee")]
        [HttpGet("{id}")]
        public JsonResult CalculateBookingFee([FromQuery]string CIFNo, [FromQuery]decimal Amount, 
            [FromQuery]string ProductCode, [FromQuery]bool IsByPercent, [FromQuery]bool IsFeeEdit, 
            [FromQuery]decimal PercentageFeeInput)
        {
            cls.ReksaCalcBookingFee(CIFNo, Amount, ProductCode, IsByPercent, IsFeeEdit, PercentageFeeInput
            , out decimal PercentageFeeOutput, out string FeeCCY, out decimal Fee);
            return Json(new { PercentageFeeOutput, FeeCCY, Fee });
        }
        
        private JsonResult Json(object p, object allowGet)
        {
            throw new NotImplementedException();
        }

    }
}
