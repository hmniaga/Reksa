using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Data;
using ReksaAPI.Models;
using Microsoft.AspNetCore.Authorization;
using System;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace ReksaAPI.Controllers
{
    public class ParameterController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;
        public ParameterController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }
        [Route("api/Parameter/Refresh")]
        [HttpGet("{id}")]
        public JsonResult Refresh([FromQuery]int ProdId, [FromQuery]string TreeInterface, [FromQuery]int NIK, [FromQuery]string Guid)
        {
            //List<ParameterModel> list = new List<ParameterModel>();
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();
            blnResult = cls.ReksaRefreshParameter(ProdId, TreeInterface, NIK, Guid, out ErrMsg, out dsResult);
            ErrMsg = ErrMsg.Replace("ReksaRefreshParameter - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/Parameter/RefreshWARPED")]
        [HttpGet("{id}")]
        public JsonResult RefreshWARPED([FromQuery]int NIK)
        {
            bool blnResult = false;
            string strErrMsg = "";
            string[] strData;
            blnResult = cls.ReksaGetDataPeopleSoft(NIK, ref strErrMsg, out strData);
            return Json(new { blnResult, strErrMsg, strData });
        }        
        [Route("api/Parameter/PopulateParamFee")]
        [HttpGet("{id}")]
        public JsonResult PopulateParamFee([FromQuery]int NIK, [FromQuery]string strModule, [FromQuery]int ProdId, [FromQuery]string TrxType)
        {
            bool blnResult;
            string ErrMsg;
            List<ReksaParamFeeSubs> listReksaParamFeeSubs = new List<ReksaParamFeeSubs>();
            List<ReksaTieringNotificationSubs> listReksaTieringNotificationSubs = new List<ReksaTieringNotificationSubs>();
            List<ReksaListGLFeeSubs> listReksaListGLFeeSubs = new List<ReksaListGLFeeSubs>();

            blnResult = cls.ReksaPopulateParamFee(NIK, strModule, ProdId, TrxType, ref listReksaParamFeeSubs, ref listReksaTieringNotificationSubs, ref listReksaListGLFeeSubs, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateParamFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listReksaParamFeeSubs, listReksaTieringNotificationSubs, listReksaListGLFeeSubs });
        }
        [Route("api/Parameter/MaintainSubsFee")]
        [HttpGet("{id}")]
        public JsonResult MaintainSubsFee([FromQuery]int NIK, [FromQuery]string Module, [FromBody]MaintainFeeSubs model)
        {
            bool blnResult = false ;
            string ErrMsg = "";

            model.intNIK = NIK;
            model.strModule = Module;

            blnResult = cls.ReksaMaintainSubsFee(model, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainSubsFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Parameter/ValidateGL")]
        [HttpGet("{id}")]
        public JsonResult ValidateGL([FromQuery]int NIK, [FromQuery]string Module, [FromQuery]string NomorGL)
        {
            bool blnResult;
            string ErrMsg;
            string strNamaGL;

            blnResult = cls.ReksaValidateGL(NIK, Module, NomorGL, out strNamaGL, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaValidateGL - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, strNamaGL });
        }        
        [Route("api/Parameter/PopulateVerifyGlobalParam")]
        [HttpGet("{id}")]
        public JsonResult PopulateVerifyGlobalParam([FromQuery]string ProdId, [FromQuery]string InterfaceId, [FromQuery]int NIK)
        {
            DataSet dsResult = new DataSet();
            bool blnResult = false;
            string ErrMsg = "";
            blnResult = cls.ReksaPopulateVerifyGlobalParam("", InterfaceId, NIK, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateVerifyGlobalParam - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/Parameter/MaintainParameterGlobal")]
        [HttpGet("{id}")]
        public JsonResult MaintainParameterGlobal([FromBody] MaintainParamGlobal MaintParamGlobal, [FromQuery]int NIK, [FromQuery] string GUID)
        {
            bool blnResult = false;            
            string strErrMsg;
            MaintainParameter model = new MaintainParameter();

            model.Type = MaintParamGlobal._intType;
            model.InterfaceId = MaintParamGlobal._strTreeInterface;
            model.ProdId = 0;
            if ((model.Type == 1) | (model.Type == 2))
            {
                if (model.InterfaceId != "RSB" && model.InterfaceId != "MSC" && model.InterfaceId != "SWC" && model.InterfaceId != "RPP" && model.InterfaceId != "CTR" && model.InterfaceId != "OFF")
                {
                    model.Code = MaintParamGlobal.txtbSP1;
                }
                else
                {
                    model.Code = MaintParamGlobal.cmpsrSearch1[0];
                }
            }
            else
            {
                model.Code = "";
                if (model.Type == 3 && (model.InterfaceId == "EVT" | model.InterfaceId == "WPR" | model.InterfaceId == "GFM" | model.InterfaceId == "ANP" | model.InterfaceId == "KNP"))
                    model.Code = MaintParamGlobal.txtbSP1;
                else if (model.Type == 3 && (model.InterfaceId == "RSB"))
                    model.Code = MaintParamGlobal.cmpsrSearch1[0];
                else if (model.Type == 3 && (model.InterfaceId == "PFP"))
                    model.Code = MaintParamGlobal.txtbSP1;
                else if (model.Type == 3 && (model.InterfaceId == "MSC"))
                    model.Code = MaintParamGlobal.cmpsrSearch1[0];
                else if (model.Type == 3 && (model.InterfaceId == "SWC"))
                    model.Code = MaintParamGlobal.cmpsrSearch1[0];
                else if (model.Type == 3 && (model.InterfaceId == "RPP"))
                    model.Code = MaintParamGlobal.cmpsrSearch1[0];
                else
                    model.Code = MaintParamGlobal.txtbSP1;
            }
            if (model.InterfaceId == "SWC")
            {
                model.Desc = MaintParamGlobal.cmpsrSearch2[0].Trim() + " #" + MaintParamGlobal.txtbSP3.Trim().Replace(",", "") + " #" + MaintParamGlobal.comboBox1.Trim() + "#" + MaintParamGlobal.txtbSP5.Trim() + "#" + MaintParamGlobal.textPctSwc.Trim();
            }
            else if (model.InterfaceId == "OFF" | model.InterfaceId == "CTR")
            {
                model.Desc = MaintParamGlobal.cmpsrSearch1[1].Trim();
            }
            else
            {
                if ((model.Type == 1) | (model.Type == 2) | (model.Type == 3))
                {
                    model.Desc = MaintParamGlobal.txtbSP2;
                    if (model.InterfaceId == "GFM")
                    {
                        if (MaintParamGlobal.txtbSP3 == "") MaintParamGlobal.txtbSP3 = "0";
                        model.Desc = model.Desc + "#" + MaintParamGlobal.txtbSP3;
                    }
                    if (model.InterfaceId == "RPP")
                    {
                        model.Desc = MaintParamGlobal.comboBox3;
                    }
                    if (model.InterfaceId == "RTY")
                    {
                        model.Desc = MaintParamGlobal.txtbSP2 + "#" + MaintParamGlobal.txtbSP3;
                    }
                    if (model.InterfaceId == "RSB")
                    {
                        model.Desc = MaintParamGlobal.txtbSP2 + "#" + MaintParamGlobal.txtbSP3 + "#" + MaintParamGlobal.textBox1 + "#" + MaintParamGlobal.textPctSwc + "#" + MaintParamGlobal.txtbSP5;
                    }
                    if (model.InterfaceId == "WPR")
                    {
                        model.Desc = MaintParamGlobal.txtbSP2.Trim() + "#" + MaintParamGlobal.txtbSP3.Trim() + "#" + MaintParamGlobal.txtbSP4.Trim() + "#" + MaintParamGlobal.dtpSP5.ToString();
                    }
                    if (model.InterfaceId == "PFP")
                    {
                        model.Desc = MaintParamGlobal.txtbSP2 + "#" + MaintParamGlobal.txtbSP3;
                    }
                    if (model.InterfaceId == "MNI" || model.InterfaceId == "CTD")
                    {
                        model.Desc = MaintParamGlobal.txtbSP2 + "#" + MaintParamGlobal.txtbSP3;
                    }
                }
            }
            if (model.InterfaceId == "MSC")
            {
                if (MaintParamGlobal.checkBox1)
                    model.ProdId = 1;
                else
                    model.ProdId = 0;
            }
            if ((model.Type == 2) | (model.Type == 3))
            {
                model.Id = MaintParamGlobal.Id;
            }
            else
            {
                model.Id = 0;
            }
            if ((model.Type == 1) | (model.Type == 2))
            {
                model.Value = MaintParamGlobal.dtpSP;
            }
            else
            {
                if (model.InterfaceId != "SWC")
                {
                    model.Value = MaintParamGlobal.TanggalValuta;
                }
                else
                {
                    model.Value = DateTime.Today;
                }
            }
            blnResult = cls.ReksaMaintainParameter(model , out strErrMsg);
            strErrMsg = strErrMsg.Replace("ReksaMaintainParameter - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, strErrMsg });
        }
        //Nico
        [Route("api/Parameter/PopulateMFee")]
        [HttpGet("{id}")]
        public JsonResult PopulateParamMFee([FromQuery]int NIK, [FromQuery]string strModule, [FromQuery]int ProdId, [FromQuery]string TrxType)
        {
            List<ReksaParamMFee> listReksaParamMFee = new List<ReksaParamMFee>();
            List<PercentTieringMFee> listReksaProductMFees = new List<PercentTieringMFee>();
            List<SettingGLMFee> listReksaListGLMFee = new List<SettingGLMFee>();

            bool blnResult = false;
            string ErrMsg = "";
            
            blnResult = cls.ReksaPopulateMFee(NIK, strModule, ProdId, TrxType, ref listReksaParamMFee, ref listReksaProductMFees, ref listReksaListGLMFee, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateParamFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listReksaParamMFee, listReksaProductMFees, listReksaListGLMFee });
        }
        //Nico End
        //indra start
        [Route("api/Parameter/PopulateRedempFee")]
        [HttpGet("{id}")]
        public JsonResult PopulateParamRedempFee([FromQuery]int NIK, [FromQuery]string strModule, [FromQuery]int ProdId, [FromQuery]string TrxType)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ParameterRedempFee> listRedempFee = new List<ParameterRedempFee>();
            List<ParameterRedempFeeTieringNotif> listRedempFeeTieringNotif = new List<ParameterRedempFeeTieringNotif>();
            List<ParameterRedempFeeGL> listRedempFeeGL = new List<ParameterRedempFeeGL>();
            List<ParameterRedempFeePercentageTiering> listRedempFeePercentageTiering = new List<ParameterRedempFeePercentageTiering>();

            blnResult = cls.ReksaPopulateRedempFee(NIK, strModule, ProdId, TrxType, ref listRedempFee, ref listRedempFeeTieringNotif, ref listRedempFeeGL, ref listRedempFeePercentageTiering, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateParamFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listRedempFee, listRedempFeeTieringNotif, listRedempFeeGL, listRedempFeePercentageTiering });
        }
        //indra end
        //Harja
        [Route("api/Parameter/PopulateUpFrontSellingFee")]
        [HttpGet("{id}")]
        public JsonResult PopulateParamUpFrontSelling([FromQuery]int NIK, [FromQuery]string strModule, [FromQuery]int ProdId, [FromQuery]string TrxType)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ReksaParamUpFrontSelling> listReksaParamFee = new List<ReksaParamUpFrontSelling>();
            List<ReksaListGLUpFrontSelling> listReksaListGL = new List<ReksaListGLUpFrontSelling>();

            DataSet dsOut = new DataSet();
            blnResult = cls.ReksaPopulateUpFrontSellFee(NIK, strModule, ProdId, TrxType, ref listReksaParamFee, ref listReksaListGL, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateParamFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listReksaParamFee, listReksaListGL });
        }
        //Harja End
        [Route("api/Parameter/PopulateSwcFee")]
        [HttpGet("{id}")]
        public JsonResult PopulateSwcFee([FromQuery]int NIK, [FromQuery]string strModule, [FromQuery]int ProdId, [FromQuery]string TrxType)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ReksaParamFeeSwc> listSwcFee = new List<ReksaParamFeeSwc>();
            List<ParameterSwcFeeTieringNotif> listSwcFeeTieringNotif = new List<ParameterSwcFeeTieringNotif>();
            List<SettingGLSwcFee> listSwcFeeGL = new List<SettingGLSwcFee>();

            blnResult = cls.ReksaPopulateSwcFee(NIK, strModule, ProdId, TrxType, ref listSwcFee, ref listSwcFeeTieringNotif, ref listSwcFeeGL, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateParamFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listSwcFee, listSwcFeeTieringNotif, listSwcFeeGL });
        }
        [Route("api/Parameter/GetDropDownList")]
        [HttpGet("{id}")]
        public JsonResult GetDropDownList([FromQuery]string ListName)
        {
            bool blnResult = false;
            string ErrMsg;
            List<ParamSinkronisasi> listParam = new List<ParamSinkronisasi>();
            blnResult = cls.ReksaGetDropDownList(ListName, out listParam, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetDropDownList - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listParam });
        }
        [Route("api/Parameter/MaintainRedempFee")]
        [HttpGet("{id}")]
        public JsonResult MaintainRedempFee([FromBody]MaintainRedempFee model)
        {
            bool blnResult = false;
            string ErrMsg = "";

            blnResult = cls.ReksaMaintainRedempFee(model, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainRedempFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Parameter/MaintainMFee")]
        [HttpGet("{id}")]
        public JsonResult MaintainMFee([FromBody]MaintainMaitencanceFee model)
        {
            bool blnResult = false;
            string ErrMsg = "";

            blnResult = cls.ReksaMaintainMFee(model, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainMFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Parameter/MaintainUpfrontSellingFee")]
        [HttpGet("{id}")]
        public JsonResult MaintainUpfrontSellingFee([FromBody]MaintainUpfrontSellingFee model)
        {
            bool blnResult = false;
            string ErrMsg = "";

            blnResult = cls.ReksaMaintainUpfrontSellingFee(model, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainUpfrontSellingFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Parameter/MaintainSwcFee")]
        [HttpGet("{id}")]
        public JsonResult MaintainSwcFee([FromBody]MaintainSwcFee model)
        {
            bool blnResult = false;
            string ErrMsg = "";

            blnResult = cls.ReksaMaintainSwcFee(model, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainUpfrontSellingFee - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Parameter/NonAktifClientId")]
        [HttpGet("{id}")]
        public JsonResult NonAktifClientId([FromQuery]int ClientId, [FromQuery]decimal UnitBalance, [FromQuery]int NIK)
        {
            bool blnResult = false;
            string ErrMsg = "";

            blnResult = cls.ReksaNonAktifClientId(ClientId, UnitBalance, NIK, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaNonAktifClientId - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }

        [Route("api/Parameter/UploadWAPERD")]
        [HttpGet("{id}")]
        public JsonResult UploadWAPERD([FromBody]UploadWaperd model, [FromQuery]int NIK, [FromQuery]string Module)
        {
            bool blnResult;
            string ErrMsg;
            DataSet dsError = new DataSet();
            blnResult = cls.ReksaUploadWAPERD(model, NIK, Module, out ErrMsg, out dsError);
            ErrMsg = ErrMsg.Replace("ReksaUploadWAPERD - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsError });
        }

        [Route("api/Parameter/PopulateAgentCode")]
        [HttpGet("{id}")]
        public JsonResult PopulateAgentCode([FromQuery]string OfficeId, [FromQuery]string Module, [FromQuery]int NIK)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();

            blnResult = cls.ReksaGetAgentCodeByOfficeId(NIK, Module, OfficeId, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetAgentCodeByOfficeId - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/Parameter/PindahOffice")]
        [HttpPost("{id}")]
        public JsonResult PindahOffice([FromQuery]string OfficeAsal, [FromQuery]string OfficeTujuan, [FromQuery]int NIK)
        {
            bool blnResult = false;
            string ErrMsg = "";
            blnResult = cls.ReksaPindahOffice(NIK, OfficeAsal, OfficeTujuan, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPindahOffice - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Parameter/MaintainParameter")]
        [HttpGet("{id}")]
        public JsonResult MaintainParameter([FromBody]MaintainParameter model)
        {
            bool blnResult = false;
            string ErrMsg = "";

            blnResult = cls.ReksaMaintainParameter(model, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainParameter - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
    }
}




