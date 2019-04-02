using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Controllers
{
    public class OtorisasiController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;

        public OtorisasiController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }
        [Route("api/Otorisasi/AuthorizeGlobalParam")]
        [HttpPost("{id}")]
        public JsonResult AuthorizeGlobalParam([FromQuery] string InterfaceId, [FromQuery] bool isApprove, [FromQuery]int NIK, [FromQuery]string GUID, [FromBody]DataTable dtData)
        {
            string ErrMessage = "";
            bool blnResult = false;
            for (int i = 0; i < dtData.Rows.Count; i++)
            {
                blnResult = cls.ReksaAuthorizeGlobalParam(dtData.Rows[i]["Id"].ToString(), InterfaceId, NIK, isApprove, ref ErrMessage);
            }
            return Json(new { ErrMessage });
        }
        [Route("api/Otorisasi/ApproveReject")]
        [HttpPost("{id}")]
        public JsonResult ApproveReject([FromQuery]string strPopulate, [FromQuery] string treeid, [FromQuery] bool isApprove, [FromQuery]int NIK, [FromQuery]string GUID, [FromBody]DataTable dtData)
        {
            DataSet dsResult = new DataSet();
            string strCommand = "";
            string selectedId = "";
            string SuccessMessage = "";
            string ErrMessage = "";
            string ErrMessage2 = "";
            string ErrMessage3 = "";
            List<SqlParameter> listParam = new List<SqlParameter>();
            for (int i = 0; i < dtData.Rows.Count; i++)
            {
                strCommand = cls.fnCreateCommand1(strPopulate, dtData, NIK, GUID, out listParam, out selectedId, i);
                if (isApprove)
                {
                    if (treeid == "REKSA2" || treeid == "REKSA7")
                    {
                        cls.CekUmurNasabah(selectedId, treeid, out ErrMessage);
                    }
                    if (treeid == "REKSA3")
                    {
                    }
                    dsResult = cls.ReksaGlobalQuery(strCommand, listParam);
                }
            }
            return Json(new { SuccessMessage, ErrMessage });
        }
        [Route("api/Otorisasi/PopulateVerifyAuthBS")]
        [HttpGet("{id}")]
        public JsonResult PopulateVerifyAuthBS([FromQuery]string Authorization, [FromQuery]string TypeTrx, [FromQuery]string Action, [FromQuery]string NoReferensi, [FromQuery]int NIK)
        {
            string ErrMsg = "";
            bool blnResult = false;
            DataSet dsOut = new DataSet();
            blnResult = cls.ReksaPopulateVerifyAuthBS(Authorization, TypeTrx, Action, NoReferensi, NIK, out dsOut, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateVerifyAuthBS - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsOut });
        }
        [Route("api/Otorisasi/AuthorizeTransaction_BS")]
        [HttpPost("{id}")]
        public JsonResult AuthorizeTransaction_BS([FromQuery]string listTranId, [FromQuery]bool isApprove, [FromQuery]int NIK)
        {
            int intTranId = 0; 
            string ErrMsg = "";
            bool blnResult = false;

            string[] selectedTranId;
            listTranId = (listTranId + "***").Replace("|***", "");
            selectedTranId = listTranId.Split('|');

            foreach (string s in selectedTranId)
            {
                int.TryParse(s, out intTranId);
                blnResult = cls.ReksaAuthorizeTransaction_BS(intTranId, NIK, isApprove, out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaAuthorizeTransaction_BS - Core .Net SqlClient Data Provider\n", "");
            }
            
            return Json(new { blnResult, ErrMsg });
        }
        

    }
}
