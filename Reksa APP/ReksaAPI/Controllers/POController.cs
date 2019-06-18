using System;
using System.Collections.Generic;
using System.Data;
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
            List<JurnalRTGS> listJurnalRTGS = new List<JurnalRTGS>();
            blnResult = cls.ReksaPopulateJurnalRTGS(ClassificationId, Module, out listJurnalRTGS, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateJurnalRTGS - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listJurnalRTGS });
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
            string ErrMsg = "";
            try
            {
                string XMLInput = cls.ReksaGetXmlRTGS(GUID, NIK, Module);
                string strOutPut = "";
                if (XMLInput != "")
                {
                    blnResult = cls.ReksaProcessResponseXmlRTGS(NIK, Module, GUID, strOutPut,out ErrMsg);
                    ErrMsg = ErrMsg.Replace("ReksaProcessResponseXmlRTGS - Core .Net SqlClient Data Provider\n", "");
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg });
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
    }
}
