using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ReksaAPI.Models;
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
                blnResult = cls.ReksaGlobalQuery(false, strCommand, listParam, out dsResult, out ErrMsg);
                ErrMsg = ErrMsg.Replace(strCommand + " - Core .Net SqlClient Data Provider\n", "");
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
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaNFSFileCekPendingOtorisasi(TypeGet, LogId, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaNFSFileCekPendingOtorisasi - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/Otorisasi/NFSCekPendingDetailOtorisasi")]
        [HttpGet("{id}")]
        public JsonResult NFSCekPendingDetailOtorisasi([FromQuery]int CIFNo, [FromQuery]int LogId)
        {
            string ErrMsg = "";
            bool blnResult = false;
            DataSet dsResult = new DataSet();
            blnResult = cls.ReksaNFSCekPendingDetailOtorisasi(CIFNo, LogId, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaNFSCekPendingDetailOtorisasi - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/Otorisasi/UpdateFlagApprovalNFSGenerate")]
        [HttpGet("{id}")]
        public JsonResult UpdateFlagApprovalNFSGenerate([FromQuery]string Type, [FromQuery]int LogId, [FromQuery]string NIK)
        {
            string ErrMsg = "";
            bool blnResult = false;

            blnResult = cls.ReksaUpdateFlagApprovalNFSGenerate(LogId, Type, NIK, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaUpdateFlagApprovalNFSGenerate - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
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
        [Route("api/Otorisasi/AuthorizeBlocking")]
        [HttpPost("{id}")]
        public JsonResult AuthorizeBlocking([FromQuery]string listBlockId, [FromQuery]bool isApprove, [FromQuery]int NIK)
        {
            int intBlockId = 0;
            string ErrMsg = "";
            bool blnResult = false;

            string[] selectedBlockId;
            listBlockId = (listBlockId + "***").Replace("|***", "");
            selectedBlockId = listBlockId.Split('|');

            foreach (string s in selectedBlockId)
            {
                int.TryParse(s, out intBlockId);
                blnResult = cls.ReksaAuthorizeBlocking(intBlockId, NIK, isApprove, out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaAuthorizeBlocking - Core .Net SqlClient Data Provider\n", "");
            }

            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Otorisasi/AuthorizeTranReversal")]
        [HttpPost("{id}")]
        public JsonResult AuthorizeTranReversal([FromQuery]string listTranId, [FromQuery]bool isApprove, [FromQuery]int NIK)
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
                blnResult = cls.ReksaAuthorizeTranReversal(intTranId, NIK, isApprove, out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaAuthorizeTranReversal - Core .Net SqlClient Data Provider\n", "");
            }

            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Otorisasi/AuthorizeSwcReversal")]
        [HttpPost("{id}")]
        public JsonResult AuthorizeSwcReversal([FromQuery]string listTranId, [FromQuery]bool isApprove, [FromQuery]int NIK)
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
                blnResult = cls.ReksaAuthorizeSwcReversal(intTranId, NIK, isApprove, out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaAuthorizeSwcReversal - Core .Net SqlClient Data Provider\n", "");
            }

            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Otorisasi/AuthorizeTransaction_BS")]
        [HttpGet("{id}")]
        public JsonResult AuthorizeTransaction_BS([FromQuery]string listTranId, [FromQuery]bool isApprove, [FromQuery]int NIK)
        {
            int intTranId = 0; 
            string ErrMsg = "";
            bool blnResult = false;

            //string[] selectedTranId;
            //listTranId = (listTranId + "***").Replace("|***", "");
            //selectedTranId = listTranId.Split('|');

            //foreach (string s in selectedTranId)
            //{
                int.TryParse(listTranId, out intTranId);
                blnResult = cls.ReksaAuthorizeTransaction_BS(intTranId, NIK, isApprove, out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaAuthorizeTransaction_BS - Core .Net SqlClient Data Provider\n", "");
            //}
            
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Otorisasi/AuthorizeSwitching_BS")]
        [HttpPost("{id}")]
        public JsonResult AuthorizeSwitching_BS([FromQuery]string listTranId, [FromQuery]bool isApprove, [FromQuery]int NIK)
        {
            int intTranId = 0;
            string ErrMsg = "";
            bool blnResult = false;

            //string[] selectedTranId;
            //listTranId = (listTranId + "***").Replace("|***", "");
            //selectedTranId = listTranId.Split('|');

            //foreach (string s in selectedTranId)
            //{
            int.TryParse(listTranId, out intTranId);
            blnResult = cls.ReksaAuthorizeSwitching_BS(intTranId, NIK, isApprove, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaAuthorizeSwitching_BS - Core .Net SqlClient Data Provider\n", "");
            //}

            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Otorisasi/AuthorizeBooking")]
        [HttpPost("{id}")]
        public JsonResult AuthorizeBooking([FromQuery]string listBookingId, [FromQuery]bool isApprove, [FromQuery]int NIK)
        {
            int intBookingId = 0;
            string ErrMsg = "";
            bool blnResult = false;

            //string[] selectedTranId;
            //listTranId = (listTranId + "***").Replace("|***", "");
            //selectedTranId = listTranId.Split('|');

            //foreach (string s in selectedTranId)
            //{
            int.TryParse(listBookingId, out intBookingId);
            blnResult = cls.ReksaAuthorizeBooking(intBookingId, NIK, isApprove, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaAuthorizeBooking - Core .Net SqlClient Data Provider\n", "");
            //}
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Otorisasi/CheckValiditasData")]
        [HttpPost("{id}")]
        public JsonResult CheckValiditasData([FromQuery]int intTranId, [FromQuery]int intTranType, [FromQuery]double decNominal, [FromQuery]double decUnit,
            [FromQuery]bool FullAmount, [FromQuery]string ChannelDesc, [FromQuery]double FeeAmount, [FromQuery]double FeePercent, [FromQuery]int intJangkaWaktu,
            [FromQuery]bool AutoRedemp, [FromQuery]bool Asuransi, [FromQuery]int FrekPendebetan)
        {
            string ErrMsg = "";
            bool blnResult = false;

            blnResult = cls.ReksaCheckValiditasData(intTranId, intTranType, decNominal, decUnit,
            FullAmount, ChannelDesc, FeeAmount, FeePercent, intJangkaWaktu,
            AutoRedemp, Asuransi, FrekPendebetan, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCheckValiditasData - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Otorisasi/CekUmurNasabah")]
        [HttpPost("{id}")]
        public JsonResult CekUmurNasabah([FromQuery]string SelectedId, [FromQuery]string TreeId)
        {
            string ErrMsg = "";
            bool blnResult = false;

            blnResult = cls.ReksaCekNotifikasiBS(SelectedId, TreeId, "AGE", out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCekNotifikasiBS - Core .Net SqlClient Data Provider\n", "");        
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Otorisasi/CekRiskProfile")]
        [HttpPost("{id}")]
        public JsonResult CekRiskProfile([FromQuery]string SelectedId, [FromQuery]string TreeId)
        {
            string ErrMsg = "";
            bool blnResult = false;

            blnResult = cls.ReksaCekNotifikasiBS(SelectedId, TreeId, "RISKPROFILE", out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCekNotifikasiBS - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Otorisasi/CekTieringNotification")]
        [HttpPost("{id}")]
        public JsonResult CekTieringNotification([FromQuery]string SelectedId, [FromQuery]string TreeId)
        {
            string ErrMsg = "";
            bool blnResult = false;

            blnResult = cls.ReksaCekTieringNotification(SelectedId, TreeId, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCekTieringNotification - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Otorisasi/PopulateVerifyParamFeeDetail")]
        [HttpPost("{id}")]
        public JsonResult PopulateVerifyParamFeeDetail([FromQuery]int NIK, [FromQuery]string Module, [FromQuery]int SubsId, [FromQuery]string JenisFee)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaPopulateVerifyParamFeeDetail(NIK, Module, SubsId, JenisFee, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateVerifyParamFeeDetail - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
    }
}
