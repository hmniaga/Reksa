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

namespace Reksa.Controllers
{
    public class ParameterController : Controller
    {
        private IConfiguration _config;
        private string _strAPIUrl;

        public ParameterController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }

        public ActionResult Index(int ProdukId)
        {
            ViewData["Label0"] = "Produk";
            ViewData["Label1"] = "Kode";
            ViewData["Label2"] = "Deskripsi";
            ViewData["Label3"] = "Tanggal valuta";
            ViewData["Label4"] = "Kode Kantor";

            List<ParameterModel> list = new List<ParameterModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Parameter/Refresh?ProdId=" + ProdukId + "&TreeInterface=SAC&NIK=10137&Guid=a1b2").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ParameterModel>>(stringData);
            }

            ParameterListViewModel vModel = new ParameterListViewModel();
            vModel.Parameter = list;

            if (list.Count > 0)
            {
                //ViewData["Value0"] = listData[0].Kode;
                //ViewData["Value1"] = listData[0].Kode;
                //ViewData["Value2"] = listData[0].Deskripsi;
                //ViewData["Value3"] = listData[0].TanggalValuta;                
            }
            return View(vModel);
        }
        public IActionResult ParameterGlobal()
        {
            return View();
        }
        public IActionResult SubscriptionFee(int ProdukId)
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

            return View(vModel);
        }

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
            vModel.ProductMFee= listReksaProductMFees;
            vModel.ListGLMFee = listReksaListGLMFee;

            return View("MaintenanceFee",vModel);
        }

        // Nico end
        public IActionResult RedemptionFee()
        {
            return View();
        }
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

        public IActionResult RefreshMaintenanceUpFrontSelling(int ProdukId , string FeeType)
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

            while(listReksaListGL.Count < 5)
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
    }
}