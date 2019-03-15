using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using Reksa.Models;
using Reksa.ViewModels;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json;
using System;
using Newtonsoft.Json.Linq;
using Kendo.Mvc.UI;

namespace Reksa.Controllers
{
    public class ParameterController : Controller
    {
        #region "Default Var"
        public string strModule = "Pro Reksa 2";
        public int _intNIK = 10137;
        public string _strGuid = "77bb8d13-22af-4233-880d-633dfdf16122";
        public string _strMenuName;
        public string _strBranch = "01010";
        public int _intClassificationId;
        private IConfiguration _config;
        private string _strAPIUrl;
        #endregion

        public ParameterController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }
        public ActionResult Index()
        {
            ViewData["label1"] = "Produk";
            ViewData["lblSP1"] = "Kode";
            ViewData["lblSP2"] = "Deskripsi";
            ViewData["lblSP4"] = "Tanggal valuta";
            ViewData["lblOffice"] = "Kode Kantor";
            ParameterListViewModel vModel = new ParameterListViewModel();
            List<TreeViewModel> listTree = new List<TreeViewModel>();
            listTree = GetTreeView("mnuSetupParameter");
            var items = new List<TreeViewModel>();
            var root = listTree[0];
            for (int i = 0; i < listTree.Count; i++)
            {                
                if (listTree[i].ParentId == "")
                {
                    root = listTree[i];
                    items.Add(root);
                }
                else
                {
                    root.Children.Add(listTree[i]);
                }                
            }
            this.ViewBag.Tree = items;
            return View(vModel);
        }
        public JsonResult RefreshParam(string InterfaceId, int ProdukId)
        {
            ViewData["label1"] = "Produk";
            ViewData["lblSP1"] = "Kode";
            ViewData["lblSP2"] = "Deskripsi";
            ViewData["lblSP4"] = "Tanggal valuta";
            ViewData["lblOffice"] = "Kode Kantor";
            List<ParameterModel> list = new List<ParameterModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Parameter/Refresh?ProdId=" + ProdukId + "&TreeInterface="+ InterfaceId + "&NIK="+ _intNIK +"&Guid=" + _strGuid).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ParameterModel>>(stringData);
            }
            ParameterListViewModel vModel = new ParameterListViewModel();             
            vModel.Parameter = list;
            return Json(vModel);
        }
        public ActionResult Global()
        {
            ViewData["label1"] = "Produk";
            ViewData["lblSP1"] = "Kode";
            ViewData["lblSP2"] = "Deskripsi";
            ViewData["lblSP4"] = "Tanggal valuta";
            ViewData["lblOffice"] = "Kode Kantor";
            ParameterListViewModel vModel = new ParameterListViewModel();
            List<TreeViewModel> listTree = new List<TreeViewModel>();
            listTree = GetTreeView("mnuParamGlobal");
            var items = new List<TreeViewModel>();

            var root = listTree[0];
            for (int i = 0; i < listTree.Count; i++)
            {
                if (listTree[i].ParentId == "")
                {
                    root = listTree[i];
                    items.Add(root);
                }
                else
                {
                    root.Children.Add(listTree[i]);
                }
            }
            this.ViewBag.Tree = items;
            return View(vModel);
        }
        public JsonResult RefreshParamGlobal(string InterfaceId, int ProdukId)
        {
            ViewData["label1"] = "Produk";
            ViewData["lblSP1"] = "Kode";
            ViewData["lblSP2"] = "Deskripsi";
            ViewData["lblSP4"] = "Tanggal valuta";
            List<ParameterModel> list = new List<ParameterModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Parameter/Refresh?ProdId=&TreeInterface=" + InterfaceId + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ParameterModel>>(stringData);
            }
            ParameterListViewModel vModel = new ParameterListViewModel();
            vModel.Parameter = list;
            return Json(vModel);
        }

        public ActionResult RefreshWARPED(int NIK)
        {
            bool blnResult = false;
            string strErrMsg = "";
            string Name = "", JobTittle = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Parameter/RefreshWARPED?NIK=" + NIK).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(stringData);
                    JToken TokenResult = strObject["blnResult"];
                    JToken TokenErrMsg = strObject["strErrMsg"];
                    JToken TokenData = strObject["strData"];
                    string JsonResult = JsonConvert.SerializeObject(TokenResult);
                    string JsonErrMsg = JsonConvert.SerializeObject(TokenErrMsg);
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    blnResult = JsonConvert.DeserializeObject<bool>(JsonResult);
                    string[] strData = JsonConvert.DeserializeObject<string[]>(JsonData);
                    strErrMsg = JsonConvert.DeserializeObject<string>(JsonErrMsg);
                    Name = strData[0];
                    JobTittle = strData[1];
                }
            }
            catch (Exception e)
            {
                strErrMsg = e.Message;
                return Json(new { blnResult, strErrMsg });
            }
            return Json(new { blnResult, strErrMsg, Name, JobTittle });
        }

        [HttpPost]
        public ActionResult MaintainParamGlobal([FromBody] MaintainParamGlobal MaintParamGlobal)
        {
            bool blnResult = false;
            string strErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(MaintParamGlobal));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Parameter/MaintainParameterGlobal?NIK=" + _intNIK + "&GUID=" + _strGuid, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    JToken TokenResult = strObject["blnResult"];
                    JToken TokenErrMsg = strObject["strErrMsg"];
                    string JsonResult = JsonConvert.SerializeObject(TokenResult);
                    string JsonErrMsg = JsonConvert.SerializeObject(TokenErrMsg);
                    blnResult = JsonConvert.DeserializeObject<bool>(JsonResult);
                    strErrMsg = JsonConvert.DeserializeObject<string>(JsonErrMsg);
                }
            }
            catch (Exception e)
            {
                strErrMsg = e.Message;
                return Json(new { blnResult, strErrMsg });
            }
            return Json(new { blnResult, strErrMsg });
        }
        
        //Alvin, begin
        public IActionResult SubscriptionFee()
        {
            ParameterSubscriptionFeeListViewModel vModel1 = new ParameterSubscriptionFeeListViewModel();
            return View(vModel1);
        }

        public IActionResult RefreshSubscriptionFee(int ProdukId)
        {
            List<ReksaParamFeeSubs> listReksaParamFeeSubs = new List<ReksaParamFeeSubs>();
            List<ReksaTieringNotificationSubs> listReksaTieringNotificationSubs = new List<ReksaTieringNotificationSubs>();
            List<ReksaListGLFeeSubs> listReksaListGLFeeSubs = new List<ReksaListGLFeeSubs>();
            ReksaParamFeeSubs listFee = new ReksaParamFeeSubs();

            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Parameter/PopulateParamFee?NIK=10001&strModule=Pro Reksa 2&ProdId=" + ProdukId + "&TrxType=SUBS").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(stringData);

                JToken strTokenParamFeeSubs = strObject["listReksaParamFeeSubs"];
                JToken strTokenTiering = strObject["listReksaTieringNotificationSubs"];
                JToken strTokenGL = strObject["listReksaListGLFeeSubs"];
                string strJsonParamFeeSubs = JsonConvert.SerializeObject(strTokenParamFeeSubs);
                string strJsonTiering = JsonConvert.SerializeObject(strTokenTiering);
                string strJsonGL = JsonConvert.SerializeObject(strTokenGL);

                listReksaParamFeeSubs = JsonConvert.DeserializeObject<List<ReksaParamFeeSubs>>(strJsonParamFeeSubs);
                listReksaTieringNotificationSubs = JsonConvert.DeserializeObject<List<ReksaTieringNotificationSubs>>(strJsonTiering);
                listReksaListGLFeeSubs = JsonConvert.DeserializeObject<List<ReksaListGLFeeSubs>>(strJsonGL);

            }

            ParameterSubscriptionFeeListViewModel vModel = new ParameterSubscriptionFeeListViewModel();
            if (listReksaParamFeeSubs.Count > 0)
            {
                listFee = listReksaParamFeeSubs[0];
                vModel.ReksaParamFeeSubs = listFee;
                vModel.ReksaTieringNotificationSubs = listReksaTieringNotificationSubs;
                vModel.ReksaListGLFeeSubs = listReksaListGLFeeSubs;
            }
            else
            {
                listFee.maxPctFeeEmployee = 0;
                listFee.maxPctFeeNonEmployee = 0;
                listFee.minPctFeeEmployee = 0;
                listFee.minPctFeeNonEmployee = 0;
            }

            vModel.ReksaParamFeeSubs = listFee;
            vModel.ReksaTieringNotificationSubs = listReksaTieringNotificationSubs;
            vModel.ReksaListGLFeeSubs = listReksaListGLFeeSubs;

            return View("SubscriptionFee", vModel);
        }
        //Alvin, end

        //Nico
        public IActionResult MaintenanceFee()
        {
            ParameterMFeeListViewModel vModel = new ParameterMFeeListViewModel();
            return View(vModel);
        }
        public IActionResult RefreshMaintenanceFee(int ProdukId)
        {
            List<ParamMFeeModel> listReksaParamMFee = new List<ParamMFeeModel>();
            List<ProductMFeeModel> listReksaProductMFees = new List<ProductMFeeModel>();
            List<ListGLMFeeModel> listReksaListGLMFee = new List<ListGLMFeeModel>();

            ParamMFeeModel listFee = new ParamMFeeModel();

            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Parameter/PopulateMFee?NIK=10001&strModule=Pro Reksa 2&ProdId=" + ProdukId + "&TrxType=MFEE").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(stringData);

                JToken strTokenParamMFee = strObject["listReksaParamMFee"];
                JToken strTokenProduct = strObject["listReksaProductMFees"];
                JToken strTokenGL = strObject["listReksaListGLMFee"];
                string strJsonParamMFee = JsonConvert.SerializeObject(strTokenParamMFee);
                string strJsonProduct = JsonConvert.SerializeObject(strTokenProduct);
                string strJsonGL = JsonConvert.SerializeObject(strTokenGL);

                listReksaParamMFee = JsonConvert.DeserializeObject<List<ParamMFeeModel>>(strJsonParamMFee);
                listReksaProductMFees = JsonConvert.DeserializeObject<List<ProductMFeeModel>>(strJsonProduct);
                listReksaListGLMFee = JsonConvert.DeserializeObject<List<ListGLMFeeModel>>(strJsonGL);

            }

            ParameterMFeeListViewModel vModel = new ParameterMFeeListViewModel();
            if (listReksaParamMFee.Count > 0)
            {
                listFee = listReksaParamMFee[0];
                vModel.ParamMFee = listFee;
                vModel.ProductMFee = listReksaProductMFees;
                vModel.ListGLMFee = listReksaListGLMFee;
            }
            else
            {
                listFee.PeriodEfektif = 0;
                listFee.prodId = 0;
            }

            vModel.ParamMFee = listFee;
            vModel.ProductMFee = listReksaProductMFees;
            vModel.ListGLMFee = listReksaListGLMFee;

            return View("MaintenanceFee", vModel);
        }

        // Nico end
        //Indra Start
        public IActionResult RedemptionFee(int ProdukId)
        {
            ParameterRedempFeeViewModel vModel = new ParameterRedempFeeViewModel();
            return View(vModel);
        }

        public IActionResult RefreshRedemptionFee(int ProdukId)
        {
            ParameterRedempFeeViewModel vModel = new ParameterRedempFeeViewModel();
            ParameterRedempFee redempFee = new ParameterRedempFee();
            List<ParameterRedempFee> listRedempFee = new List<ParameterRedempFee>();
            List<ParameterRedempFeeTieringNotif> listRedempFeeTieringNotif = new List<ParameterRedempFeeTieringNotif>();
            List<ParameterRedempFeeGL> listRedempFeeGL = new List<ParameterRedempFeeGL>();
            List<ParameterRedempFeePercentageTiering> listRedempFeePercentageTiering = new List<ParameterRedempFeePercentageTiering>();



            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Parameter/PopulateRedempFee?NIK=10137&strModule=ProReksa&ProdId=" + ProdukId + "&TrxType=REDEMP").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(stringData);

                JToken strTokenParameterRedempFee = strObject["listRedempFee"];
                JToken strTokenNotif = strObject["listRedempFeeTieringNotif"];
                JToken strTokenGL = strObject["listRedempFeeGL"];
                JToken strTokenTiering = strObject["listRedempFeePercentageTiering"];

                string strJsonParameterRedempFee = JsonConvert.SerializeObject(strTokenParameterRedempFee);
                string strJsonNotif = JsonConvert.SerializeObject(strTokenNotif);
                string strJsonGL = JsonConvert.SerializeObject(strTokenGL);
                string strJsonTiering = JsonConvert.SerializeObject(strTokenTiering);

                listRedempFee = JsonConvert.DeserializeObject<List<ParameterRedempFee>>(strJsonParameterRedempFee);
                listRedempFeeTieringNotif = JsonConvert.DeserializeObject<List<ParameterRedempFeeTieringNotif>>(strJsonNotif);
                listRedempFeeGL = JsonConvert.DeserializeObject<List<ParameterRedempFeeGL>>(strJsonGL);
                listRedempFeePercentageTiering = JsonConvert.DeserializeObject<List<ParameterRedempFeePercentageTiering>>(strJsonTiering);

            }

            if (listRedempFee.Count > 0)
            {
                redempFee = listRedempFee[0];
            }
            else
            {
                redempFee.MinPctFeeEmployee = 0;
                redempFee.MaxPctFeeEmployee = 0;
                redempFee.MinPctFeeNonEmployee = 0;
                redempFee.MaxPctFeeNonEmployee = 0;
            }

            vModel.RedempFee = redempFee;
            vModel.RedempFeeGL = listRedempFeeGL;
            vModel.RedempFeePercentageTiering = listRedempFeePercentageTiering;
            vModel.RedempFeeTieringNotif = listRedempFeeTieringNotif;
            return View("RedemptionFee", vModel);
        }
        //Indra End
        //public IActionResult MaintenanceFee()
        //{
        //    return View();
        //}

        //Harja
        public IActionResult UpFrontSellingFee()
        {
            ParameterUpFrontSellFeeListViewModel vModel = new ParameterUpFrontSellFeeListViewModel();
            return View(vModel);
        } //RefreshMaintenanceUpFrontSelling

        public IActionResult RefreshMaintenanceUpFrontSelling(int ProdukId, string FeeType)
        {
            List<ParamUpFrontSellingModel> listReksaParamUpFrontSelling = new List<ParamUpFrontSellingModel>();
            List<ParamUpFrontSellGLModel> listReksaListGL = new List<ParamUpFrontSellGLModel>();

            ParamUpFrontSellingModel listFee = new ParamUpFrontSellingModel();

            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Parameter/PopulateUpFrontSellingFee?NIK=10001&strModule=Pro Reksa 2&ProdId=" + ProdukId + "&TrxType=" + FeeType).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(stringData);

                JToken strTokenParam = strObject["listReksaParamFee"];
                JToken strTokenGL = strObject["listReksaListGL"];
                string strJsonParamMaintenance = JsonConvert.SerializeObject(strTokenParam);
                string strJsonGL = JsonConvert.SerializeObject(strTokenGL);

                listReksaParamUpFrontSelling = JsonConvert.DeserializeObject<List<ParamUpFrontSellingModel>>(strJsonParamMaintenance);
                listReksaListGL = JsonConvert.DeserializeObject<List<ParamUpFrontSellGLModel>>(strJsonGL);

            }

            ParameterUpFrontSellFeeListViewModel vModel = new ParameterUpFrontSellFeeListViewModel();
            if (listReksaParamUpFrontSelling.Count > 0)
            {
                listFee = listReksaParamUpFrontSelling[0];
            }
            else
            {
                listFee.PercentDefault = 0;
                listFee.ProdId = 0;
                listFee.TrxType = "";
            }

            while (listReksaListGL.Count < 5)
            {
                listReksaListGL.Add(new ParamUpFrontSellGLModel());
            }

            vModel.ListGL = listReksaListGL;
            vModel.ParamUpFrontSelling = listFee;

            return View("UpFrontSellingFee", vModel);
        }

        //Harja End
        public IActionResult SwitchingFee()
        {
            return View();
        }

        private List<TreeViewModel> GetTreeView(string strMenuName)
        {
            List<TreeViewModel> list = new List<TreeViewModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetTreeView?NIK=" + _intNIK + "&Module="+ strModule + "&MenuName=" + strMenuName).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<TreeViewModel>>(stringData);
            }
            return list;
        }
    }
}