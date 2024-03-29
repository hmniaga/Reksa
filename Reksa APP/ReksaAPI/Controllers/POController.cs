﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ReksaAPI.Models;


namespace ReksaAPI.Controllers
{
    public class POController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;
        public POController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }
        [Route("api/PO/PopulateJurnalRTGS")]
        [HttpGet("{id}")]
        public JsonResult PopulateJurnalRTGS([FromQuery]int ClassificationId, [FromQuery]string Module)
        {
            bool blnResult;
            string ErrMsg;
            DataSet dsResult = new DataSet();
            blnResult = cls.ReksaPopulateJurnalRTGS(ClassificationId, Module, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateJurnalRTGS - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/PO/RefreshProdNAV")]
        [HttpGet("{id}")]
        public JsonResult RefreshProdNAV([FromQuery]int ProductId, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult;
            string ErrMsg;
            List<ProductNAV> listProductNAV = new List<ProductNAV>();
            blnResult = cls.ReksaRefreshProdNAV(ProductId, NIK, GUID, out listProductNAV, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaRefreshProdNAV - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listProductNAV });
        }
        [Route("api/PO/MaintainProdNAV")]
        [HttpGet("{id}")]
        public JsonResult MaintainProdNAV([FromQuery]int ProductId, [FromQuery]int NIK, [FromQuery]decimal NAV
            , [FromQuery]DateTime NAVValueDate, [FromQuery]DateTime DevidentDate, [FromQuery]decimal Devident
            , [FromQuery]decimal HargaUnit)
        {
            bool blnResult;
            string ErrMsg;
            string strRefId;
            blnResult = cls.ReksaMaintainProdNAV(ProductId, NAV, NAVValueDate, DevidentDate, Devident, NIK, HargaUnit, out ErrMsg, out strRefId);
            ErrMsg = ErrMsg.Replace("ReksaMaintainProdNAV - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, strRefId });
        }        
        [Route("api/PO/GetXmlRTGS")]
        [HttpGet("{id}")]
        public JsonResult GetXmlRTGS([FromQuery]string Guid, [FromQuery]int NIK, [FromQuery]string Module)
        {
            string strXML;
            strXML = cls.ReksaGetXmlRTGS(Guid, NIK, Module);
            return Json(new { strXML });
        }
        [Route("api/PO/ProsesJurnalRTGSSKN")]
        [HttpGet("{id}")]
        public JsonResult ProsesJurnalRTGSSKN([FromQuery]int NIK, [FromQuery]string Module, [FromQuery]string GUID)
        {
            bool blnResult;
            string ErrMsg;
            blnResult = cls.ReksaProsesJurnalRTGSSKN(NIK, Module, GUID, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaProsesJurnalRTGSSKN - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/PO/ProcessResponseXmlRTGS")]
        [HttpGet("{id}")]
        public JsonResult ProcessResponseXmlRTGS([FromQuery]int NIK, [FromQuery]string Module, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = ""; string strResult = "";
            try
            {
                string XMLInput = cls.ReksaGetXmlRTGS(GUID, NIK, Module);
                string strOutPut = "";
                if (XMLInput != "")
                {
                    blnResult = cls.ReksaProcessResponseXmlRTGS(NIK, Module, GUID, strOutPut, out strResult, out ErrMsg);
                    ErrMsg = ErrMsg.Replace("ReksaProcessResponseXmlRTGS - Core .Net SqlClient Data Provider\n", "");
                }
                else
                {
                    ErrMsg = "Error ReksaGetXmlRTGS : Result XML Kosong";
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, strResult });
        }
        [Route("api/PO/GetListProducts")]
        [HttpGet("{id}")]
        public JsonResult GetListProducts()
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ListProduct> listProduct = new List<ListProduct>();
            
            blnResult = cls.ReksaGetListProducts(out listProduct, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetListProducts - Core .Net SqlClient Data Provider\n", "");
             
            return Json(new { blnResult, ErrMsg, listProduct });
        }
        [Route("api/PO/PopulateCancelTrans")]
        [HttpGet("{id}")]
        public JsonResult PopulateCancelTrans()
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaPopulateCancelTrans(out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateCancelTrans - Core .Net SqlClient Data Provider\n", "");

            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/PO/CancelTransaction")]
        [HttpGet("{id}")]
        public JsonResult CancelTransaction([FromQuery]string listTranId, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";
            int intTranId = 0;

            string[] selectedTranId;
            listTranId = (listTranId + "***").Replace("|***", "");
            selectedTranId = listTranId.Split('|');

            foreach (string s in selectedTranId)
            {
                int.TryParse(s, out intTranId);
                blnResult = cls.ReksaCancelTransaction(intTranId, GUID, NIK, out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaCancelTransaction - Core .Net SqlClient Data Provider\n", "");
            }

            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/PO/CutSellingFee")]
        [HttpGet("{id}")]
        public JsonResult CutSellingFee([FromQuery]DateTime StartDate, [FromQuery]DateTime EndDate, [FromQuery]int ProdId, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";

            blnResult = cls.ReksaCutSellingFee(StartDate, EndDate, ProdId, GUID, NIK, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCutSellingFee - Core .Net SqlClient Data Provider\n", "");           

            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/PO/GetLastFeeDate")]
        [HttpGet("{id}")]
        public JsonResult GetLastFeeDate([FromQuery]int Type, [FromQuery]int ManId, [FromQuery]int ProdId, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DateTime dtStartDate = new DateTime();

            blnResult = cls.ReksaGetLastFeeDate(Type, ManId, ProdId, NIK, GUID, out dtStartDate , out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetLastFeeDate - Core .Net SqlClient Data Provider\n", "");

            return Json(new { blnResult, ErrMsg, dtStartDate });
        }
        [Route("api/PO/CutPremiAsuransi")]
        [HttpGet("{id}")]
        public JsonResult CutPremiAsuransi([FromQuery]string Period, [FromQuery]int NIK, [FromQuery]decimal TotalPremi)
        {
            bool blnResult = false;
            string ErrMsg = "";
            int BillID = 0;
            DateTime dtPeriod = new DateTime();
            DateTime.TryParseExact(Period, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtPeriod);

            blnResult = cls.ReksaCutPremiAsuransi(dtPeriod, NIK, TotalPremi, out BillID, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCutPremiAsuransi - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, BillID });
        }

        [Route("api/PO/PopulateSubscriptionLimitAlert")]
        [HttpPost("{id}")]
        public JsonResult PopulateSubscriptionLimitAlert([FromQuery]int NIK, [FromQuery]string Module)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaPopulateSubscriptionLimitAlert(NIK, Module, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateSubscriptionLimitAlert - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/PO/GetLastTanggalPencadangan")]
        [HttpPost("{id}")]
        public JsonResult GetLastTanggalPencadangan()
        {
            bool blnResult = false;
            string ErrMsg = "";
            DateTime StartDate = new DateTime();
            DateTime EndDate = new DateTime();

            blnResult = cls.ReksaGetLastTanggalPencadangan(ref StartDate, ref EndDate , out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetLastTanggalPencadangan - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, StartDate, EndDate });
        }
        [Route("api/PO/MaintainPencadangan")]
        [HttpPost("{id}")]
        public JsonResult MaintainPencadangan([FromQuery]string Tipe, [FromQuery]string ProdCode, [FromQuery]string StartDate, [FromQuery]string EndDate, [FromQuery]int NIK)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DateTime dtStartDate = new DateTime();
            DateTime dtEndDate = new DateTime();
            DateTime.TryParseExact(StartDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtStartDate);
            DateTime.TryParseExact(EndDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtEndDate);

            blnResult = cls.ReksaMaintainPencadangan(Tipe, ProdCode, dtStartDate, dtEndDate, NIK, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetLastTanggalPencadangan - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg});
        }
        [Route("api/PO/PopulateRejectBooking")]
        [HttpPost("{id}")]
        public JsonResult PopulateRejectBooking([FromQuery]string Jenis)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaPopulateRejectBooking(Jenis, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateRejectBooking - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/PO/SaveRejectBooking")]
        [HttpPost("{id}")]
        public JsonResult SaveRejectBooking([FromBody]List<MaintRejectBooking> model, [FromQuery]int NIK)
        {
            bool blnResult = false;
            string ErrMsg = "";
            for (int i = 0; i < model.Count; i++)
            {
                model[i].intNIK = NIK;
                blnResult = cls.ReksaSaveReject(model[i], out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaSaveReject - Core .Net SqlClient Data Provider\n", "");
            }
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/PO/SaveCancelTrans")]
        [HttpPost("{id}")]
        public JsonResult SaveCancelTrans([FromBody]List<MaintCancelTransaksi> model, [FromQuery]int NIK)
        {
            bool blnResult = false;
            string ErrMsg = "";

            for (int i = 0; i < model.Count; i++)
            {
                model[i].intNIK = NIK;
                blnResult = cls.ReksaSaveCancelTrans(model[i], out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaSaveCancelTrans - Core .Net SqlClient Data Provider\n", "");
            }
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/PO/PopulateDiscFee")]
        [HttpPost("{id}")]
        public JsonResult PopulateDiscFee([FromQuery]int NIK)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaPopulateDiscFee(NIK, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateDiscFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/PO/MaintainDiscRedempt")]
        [HttpGet("{id}")]
        public JsonResult MaintainDiscRedempt([FromQuery]int TranId, [FromQuery]decimal RedempDisc, [FromQuery]int NIK, [FromQuery]string Guid)
        {
            bool blnResult = false;
            string ErrMsg = "";

            blnResult = cls.ReksaMaintainDiscRedempt(TranId, RedempDisc, NIK, Guid, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainDiscRedempt - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/PO/ImportDataMFee")]
        [HttpGet("{id}")]
        public JsonResult ImportDataMFee([FromQuery]string FileName, [FromQuery]string XML, [FromQuery]int NIK, [FromQuery]int ProdId, [FromQuery]int BankCustody, [FromQuery]int isRecalculate, [FromQuery]string XMLRecalc)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsUpload = new DataSet();
            string RefId = "";

            blnResult = cls.ReksaImportDataMFee(FileName, NIK, XML, ProdId, BankCustody, isRecalculate, XMLRecalc, out ErrMsg, out dsUpload, out RefId);
            ErrMsg = ErrMsg.Replace("ReksaImportDataMFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsUpload, RefId });
        }
        [Route("api/PO/PopulateRedemptDate")]
        [HttpGet("{id}")]
        public JsonResult PopulateRedemptDate([FromQuery]int NIK)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaPopulateRedemptDate(NIK, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateRedemptDate - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/PO/MaintainSettleDate")]
        [HttpGet("{id}")]
        public JsonResult MaintainSettleDate([FromQuery]int TranId, [FromQuery]string NewSettleDate, [FromQuery]int NIK, [FromQuery]string Guid)
        {
            bool blnResult = false;
            string ErrMsg = "";

            DateTime dtNewSettleDate = new DateTime();
            DateTime.TryParseExact(NewSettleDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtNewSettleDate);

            blnResult = cls.ReksaMaintainSettleDate(TranId, dtNewSettleDate, NIK, Guid, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainSettleDate - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/PO/RecalcMFee")]
        [HttpPost("{id}")]
        public JsonResult RecalcMFee([FromQuery]string XML, [FromQuery]int ProdId, [FromQuery]int BankCustody)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsUpload = new DataSet();

            blnResult = cls.ReksaRecalcMFee(XML, ProdId, BankCustody, out dsUpload, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaRecalcMFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsUpload });
        }
        [Route("api/PO/PopulateValueDate")]
        [HttpGet("{id}")]
        public JsonResult PopulateValueDate([FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaPopulateValueDate(NIK, GUID, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateValueDate - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/PO/MaintainValueDate")]
        [HttpGet("{id}")]
        public JsonResult MaintainValueDate([FromQuery]string TranCode, [FromQuery]string NewValueDate, [FromQuery]int NIK, [FromQuery]string Guid, [FromQuery]int TranType)
        {
            bool blnResult = false;
            string ErrMsg = "";

            DateTime dtNewValueDate = new DateTime();
            DateTime.TryParseExact(NewValueDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtNewValueDate);

            blnResult = cls.ReksaMaintainValueDate(TranCode, dtNewValueDate, NIK, Guid, TranType, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainValueDate - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/PO/PreviewMaintenanceFee")]
        [HttpGet("{id}")]
        public JsonResult PreviewMaintenanceFee([FromQuery]string StartDate, [FromQuery]string EndDate, [FromQuery]string ProdId, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();

            DateTime dtStartDate = new DateTime();
            DateTime dtEndDate = new DateTime();
            DateTime.TryParseExact(StartDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtStartDate);
            DateTime.TryParseExact(EndDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtEndDate);

            blnResult = cls.ReksaPreviewMaintenanceFee(dtStartDate, dtEndDate, ProdId, NIK, GUID, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPreviewMaintenanceFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/PO/CutMaintenanceFee")]
        [HttpGet("{id}")]
        public JsonResult CutMaintenanceFee([FromQuery]string StartDate, [FromQuery]string EndDate, [FromQuery]string ProdId, [FromQuery]int ManId, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";

            DateTime dtStartDate = new DateTime();
            DateTime dtEndDate = new DateTime();
            DateTime.TryParseExact(StartDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtStartDate);
            DateTime.TryParseExact(EndDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtEndDate);

            blnResult = cls.ReksaCutMtncFee(dtStartDate, dtEndDate, ProdId, ManId, NIK, GUID, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCutMtncFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/PO/CutRedempFee")]
        [HttpGet("{id}")]
        public JsonResult CutRedempFee([FromQuery]string StartDate, [FromQuery]string EndDate, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";

            DateTime dtStartDate = new DateTime();
            DateTime dtEndDate = new DateTime();
            DateTime.TryParseExact(StartDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtStartDate);
            DateTime.TryParseExact(EndDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtEndDate);

            blnResult = cls.ReksaCutRedempFee(dtStartDate, dtEndDate, NIK, GUID, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCutRedempFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/PO/PopulateCancelTrxIBMB")]
        [HttpGet("{id}")]
        public JsonResult PopulateCancelTrxIBMB()
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaPopulateCancelTrxIBMB(out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateCancelTrxIBMB - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/PO/CancelTransactionIBMB")]
        [HttpPost("{id}")]
        public JsonResult CancelTransactionIBMB([FromBody]List<MaintCancelTransaksiIBMB> model, [FromQuery]int NIK)
        {
            bool blnResult = false;
            string ErrMsg = "";

            for (int i = 0; i < model.Count; i++)
            {
                model[i].NIK = NIK;
                blnResult = cls.ReksaCancelTransactionIBMB(model[i], out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaCancelTransactionIBMB - Core .Net SqlClient Data Provider\n", "");
            }
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/PO/GetFileColumns")]
        [HttpGet("{id}")]
        public JsonResult GetFileColumns([FromQuery] string FileType)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaGetFileColumns(FileType, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetFileColumns - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/PO/ImportData")]
        [HttpGet("{id}")]
        public JsonResult ImportData([FromBody]ImportData model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string strRefID = "";
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaImportData(model, out ErrMsg, out dsResult, out strRefID);
            ErrMsg = ErrMsg.Replace("ReksaImportData - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult, strRefID });
        }
        [Route("api/PO/RejectJurnalRTGSSKN")]
        [HttpGet("{id}")]
        public JsonResult RejectJurnalRTGSSKN([FromQuery]int NIK, [FromQuery]string Module, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";

            blnResult = cls.ReksaRejectJurnalRTGSSKN(NIK, Module, GUID, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaRejectJurnalRTGSSKN - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
    }
}
