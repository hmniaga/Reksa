﻿using System.Collections.Generic;
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
            List<ParameterModel> list = new List<ParameterModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaRefreshParameter(ProdId, TreeInterface, NIK, Guid);
            return Json(list);
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
            DataSet dsOut = new DataSet();
            dsOut = cls.ReksaPopulateVerifyGlobalParam("", InterfaceId, NIK);
            return Json(dsOut);
        }
        [Route("api/Parameter/MaintainParameterGlobal")]
        [HttpGet("{id}")]
        public JsonResult MaintainParameterGlobal([FromBody] MaintainParamGlobal MaintParamGlobal, [FromQuery]int NIK, [FromQuery] string GUID)
        {
            bool blnResult = false;
            int intType; string InterfaceId; string strCode=""; string strDesc=""; string strOfficeId="";
            int intProdId; int intId; DateTime dtValue; string strErrMsg;

            intType = MaintParamGlobal._intType;
            InterfaceId = MaintParamGlobal._strTreeInterface;
            intProdId = 0;
            if ((intType == 1) | (intType == 2))
            {
                if (InterfaceId != "RSB" && InterfaceId != "MSC" && InterfaceId != "SWC" && InterfaceId != "RPP"
                        && InterfaceId != "CTR" && InterfaceId != "OFF"
                        )
                {
                    strCode = MaintParamGlobal.txtbSP1;
                }
                else
                {
                    strCode = MaintParamGlobal.cmpsrSearch1[0];
                }
            }
            else
            {
                strCode = "";
                if (intType == 3 && (InterfaceId == "EVT" | InterfaceId == "WPR" | InterfaceId == "GFM" | InterfaceId == "ANP" | InterfaceId == "KNP"))
                    strCode = MaintParamGlobal.txtbSP1;
                else if (intType == 3 && (InterfaceId == "RSB"))
                    strCode = MaintParamGlobal.cmpsrSearch1[0];
                else if (intType == 3 && (InterfaceId == "PFP"))
                    strCode = MaintParamGlobal.txtbSP1;
                else if (intType == 3 && (InterfaceId == "MSC"))
                    strCode = MaintParamGlobal.cmpsrSearch1[0];
                else if (intType == 3 && (InterfaceId == "SWC"))
                    strCode = MaintParamGlobal.cmpsrSearch1[0];
                else if (intType == 3 && (InterfaceId == "RPP"))
                    strCode = MaintParamGlobal.cmpsrSearch1[0];
                else
                    strCode = MaintParamGlobal.txtbSP1;
            }
            if (InterfaceId == "SWC")
            {
                strDesc = MaintParamGlobal.cmpsrSearch2[0].Trim() + " #" + MaintParamGlobal.txtbSP3.Trim().Replace(",", "") + " #" + MaintParamGlobal.comboBox1.Trim() + "#" + MaintParamGlobal.txtbSP5.Trim() + "#" + MaintParamGlobal.textPctSwc.Trim();
            }
            else if (InterfaceId == "OFF" | InterfaceId == "CTR")
            {
                strDesc = MaintParamGlobal.cmpsrSearch1[1].Trim();
            }
            else
            {
                if ((intType == 1) | (intType == 2) | (intType == 3))
                {
                    strDesc = MaintParamGlobal.txtbSP2;
                    if (InterfaceId == "GFM")
                    {
                        if (MaintParamGlobal.txtbSP3 == "") MaintParamGlobal.txtbSP3 = "0";
                        strDesc = strDesc + "#" + MaintParamGlobal.txtbSP3;
                    }
                    if (InterfaceId == "RPP")
                    {
                        strDesc = MaintParamGlobal.comboBox3;
                    }
                    if (InterfaceId == "RTY")
                    {
                        strDesc = MaintParamGlobal.txtbSP2 + "#" + MaintParamGlobal.txtbSP3;
                    }
                    if (InterfaceId == "RSB")
                    {
                        strDesc = MaintParamGlobal.txtbSP2 + "#" + MaintParamGlobal.txtbSP3 + "#" + MaintParamGlobal.textBox1 + "#" + MaintParamGlobal.textPctSwc + "#" + MaintParamGlobal.txtbSP5;
                    }
                    if (InterfaceId == "WPR")
                    {
                        strDesc = MaintParamGlobal.txtbSP2.Trim() + "#" + MaintParamGlobal.txtbSP3.Trim() + "#" + MaintParamGlobal.txtbSP4.Trim() + "#" + MaintParamGlobal.dtpSP5.ToString();
                    }
                    if (InterfaceId == "PFP")
                    {
                        strDesc = MaintParamGlobal.txtbSP2 + "#" + MaintParamGlobal.txtbSP3;
                    }
                    if (InterfaceId == "MNI" || InterfaceId == "CTD")
                    {
                        strDesc = MaintParamGlobal.txtbSP2 + "#" + MaintParamGlobal.txtbSP3;
                    }
                }
            }
            if (InterfaceId == "MSC")
            {
                if (MaintParamGlobal.checkBox1)
                    intProdId = 1;
                else
                    intProdId = 0;
            }
            if ((intType == 2) | (intType == 3))
            {
                intId = MaintParamGlobal.Id;
            }
            else
            {
                intId = 0;
            }
            if ((intType == 1) | (intType == 2))
            {
                dtValue = MaintParamGlobal.dtpSP;
            }
            else
            {
                if (InterfaceId != "SWC")
                {
                    dtValue = MaintParamGlobal.TanggalValuta;
                }
                else
                {
                    dtValue = DateTime.Today;
                }
            }

            blnResult = cls.ReksaMaintainParameter(intType, InterfaceId, strCode, strDesc, strOfficeId,
            intProdId, intId, dtValue, NIK, GUID, out strErrMsg);

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
    }
}




