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
    public class MasterController : Controller
    {
        #region "Default Var"
        public string strModule;
        public int _intNIK = 10137;
        public string _strGuid = "77bb8d13-22af-4233-880d-633dfdf16122";
        public string _strMenuName;
        public string _strBranch = "01010";
        public int _intClassificationId;
        private IConfiguration _config;
        private string _strAPIUrl;
        #endregion

        public MasterController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }

        private enum JenisNasabah : int
        {
            INDIVIDUAL = 1,
            CORPORATE = 4
        }
        public IActionResult Client()
        {
            IList<ActivityModel> IlistCLientActivity = new List<ActivityModel>();
            IList<BlokirModel> IlistCLientBlokir = new List<BlokirModel>();
            ClientListViewModel vModel = new ClientListViewModel();
            //subRefreshBlokir(2, _intNIK, _strGuid, out IlistCLientBlokir);
            vModel.ClientActivity = IlistCLientActivity;
            vModel.ClientBlokir = IlistCLientBlokir;
            return View(vModel);
        }

        public IActionResult InfoProduk()
        {
            return View();
        }
        public JsonResult RefreshProduct(int ProdId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ProductModel> listProduct = new List<ProductModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Master/RefreshProduct?ProdId="+ ProdId + "&NIK=" + _intNIK + "&GUID=" + _strGuid).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken TokenData = strObject["listProduct"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    listProduct = JsonConvert.DeserializeObject<List<ProductModel>>(JsonData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, listProduct });
        }

        public IActionResult UnitNasabah()
        {
            return View("UnitNasabahDitawarkan");
        }

        public IActionResult UnitDitawarkan()
        {
            return View("UnitDitawarkan");
        }
        public IActionResult Booking()
        {
            return View();
        }

        public IActionResult Event()
        {
            return View();
        }
    }
}
