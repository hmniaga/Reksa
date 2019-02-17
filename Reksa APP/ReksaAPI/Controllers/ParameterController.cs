using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Data;
using ReksaAPI.Models;
using Microsoft.AspNetCore.Authorization;

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

        [Route("api/Parameter/PopulateParamFee")]
        [HttpGet("{id}")]
        public JsonResult PopulateParamFee([FromQuery]int NIK, [FromQuery]string strModule, [FromQuery]int ProdId, [FromQuery]string TrxType)
        {
            List<ReksaParamFeeSubs> listReksaParamFeeSubs = new List<ReksaParamFeeSubs>();
            List<ReksaTieringNotificationSubs> listReksaTieringNotificationSubs = new List<ReksaTieringNotificationSubs>();
            List<ReksaListGLFeeSubs> listReksaListGLFeeSubs = new List<ReksaListGLFeeSubs>();

            DataSet dsOut = new DataSet();
            cls.ReksaPopulateParamFee(NIK, strModule, ProdId, TrxType, ref listReksaParamFeeSubs, ref listReksaTieringNotificationSubs, ref listReksaListGLFeeSubs);
            //return Json(dsOut);
            return Json(new { listReksaParamFeeSubs, listReksaTieringNotificationSubs, listReksaListGLFeeSubs });
        }

        //Nico
        [Route("api/Parameter/PopulateMFee")]
        [HttpGet("{id}")]
        public JsonResult PopulateParamMFee([FromQuery]int NIK, [FromQuery]string strModule, [FromQuery]int ProdId, [FromQuery]string TrxType)
        {
            List<ReksaParamMFee> listReksaParamMFee = new List<ReksaParamMFee>();
            List<ReksaProductMFee> listReksaProductMFees = new List<ReksaProductMFee>();
            List<ReksaListGLMFee> listReksaListGLMFee = new List<ReksaListGLMFee>();

            DataSet dsOut = new DataSet();
            cls.ReksaPopulateMFee(NIK, strModule, ProdId, TrxType, ref listReksaParamMFee, ref listReksaProductMFees, ref listReksaListGLMFee);
            //return Json(dsOut);
            return Json(new { listReksaParamMFee, listReksaProductMFees, listReksaListGLMFee });
        }
        //Nico End
        //indra start
        [Route("api/Parameter/PopulateRedempFee")]
        [HttpGet("{id}")]
        public JsonResult PopulateParamRedempFee([FromQuery]int NIK, [FromQuery]string strModule, [FromQuery]int ProdId, [FromQuery]string TrxType)
        {
            List<ParameterRedempFee> listRedempFee = new List<ParameterRedempFee>();
            List<ParameterRedempFeeTieringNotif> listRedempFeeTieringNotif = new List<ParameterRedempFeeTieringNotif>();
            List<ParameterRedempFeeGL> listRedempFeeGL = new List<ParameterRedempFeeGL>();
            List<ParameterRedempFeePercentageTiering> listRedempFeePercentageTiering = new List<ParameterRedempFeePercentageTiering>();

            DataSet dsOut = new DataSet();
            cls.ReksaPopulateRedempFee(NIK, strModule, ProdId, TrxType, ref listRedempFee, ref listRedempFeeTieringNotif, ref listRedempFeeGL,ref listRedempFeePercentageTiering);
            //return Json(dsOut);
            return Json(new { listRedempFee, listRedempFeeTieringNotif, listRedempFeeGL, listRedempFeePercentageTiering });
        }
        //indra end
    }
}


    

