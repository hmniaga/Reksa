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
            string ErrMsg = "";
            bool blnResult = false;
            for (int i = 0; i < dtData.Rows.Count; i++)
            {
                blnResult = cls.ReksaAuthorizeGlobalParam(dtData.Rows[i]["Id"].ToString(), InterfaceId, NIK, isApprove, out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaAuthorizeGlobalParam - Core .Net SqlClient Data Provider\n", "");
            }
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Otorisasi/ApproveReject")]
        [HttpPost("{id}")]
        public JsonResult ApproveReject([FromQuery]string strPopulate, [FromQuery] string treeid, [FromQuery] bool isApprove, [FromQuery]int NIK, [FromQuery]string GUID, [FromBody]DataTable dtData)
        {
            bool blnResult = false;
            DataSet dsResult = new DataSet();
            string strCommand = "";
            string selectedId = "";
            string ErrMsg = "";
            List<SqlParameter> listParam = new List<SqlParameter>();
            for (int i = 0; i < dtData.Rows.Count; i++)
            {
                strCommand = cls.fnCreateCommand1(strPopulate, dtData, NIK, GUID, out listParam, out selectedId, i);
                if (isApprove)
                {
                    blnResult = cls.ReksaGlobalQuery(strCommand, listParam, out dsResult, out ErrMsg);
                    ErrMsg = ErrMsg.Replace(strCommand + " - Core .Net SqlClient Data Provider\n", "");
                }
            }
            return Json(new { blnResult, ErrMsg });
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
        [Route("api/Otorisasi/NFSFileCekPendingOtorisasi")]
        [HttpGet("{id}")]
        public JsonResult NFSFileCekPendingOtorisasi([FromQuery]string TypeGet, [FromQuery]int LogId)
        {
            string ErrMsg = "";
            bool blnResult = false;
            DataSet dsOut = new DataSet();
            blnResult = cls.ReksaNFSFileCekPendingOtorisasi(TypeGet, LogId, out dsOut, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaNFSFileCekPendingOtorisasi - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsOut });
        }
        [Route("api/Otorisasi/AuthorizeNasabah")]
        [HttpPost("{id}")]
        public JsonResult AuthorizeNasabah([FromQuery]string listNasabahId, [FromQuery]bool isApprove, [FromQuery]int NIK)
        {
            int intNasabahId = 0;
            string ErrMsg = "";
            bool blnResult = false;

            string[] selectedNasabahId;
            listNasabahId = (listNasabahId + "***").Replace("|***", "");
            selectedNasabahId = listNasabahId.Split('|');

            foreach (string s in selectedNasabahId)
            {
                int.TryParse(s, out intNasabahId);
                blnResult = cls.ReksaAuthorizeNasabah(intNasabahId, NIK, isApprove, out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaAuthorizeNasabah - Core .Net SqlClient Data Provider\n", "");
            }

            return Json(new { blnResult, ErrMsg });
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
