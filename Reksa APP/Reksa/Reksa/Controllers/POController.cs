using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Reksa.Models;
using Reksa.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace Reksa.Controllers
{
    public class POController : Controller
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

        public POController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }

        public IActionResult CutMaintenanceFee()
        {
            return View();
        }
        public IActionResult CutRedemptionFee()
        {
            return View();
        }
        public IActionResult DiscountRedempFee()
        {
            return View();
        }
        public IActionResult AdjustRedempFee()
        {
            return View();
        }
        public IActionResult JurnalRTGS()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        public JsonResult PopulateJurnalRTGS()
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<JurnalRTGS> listJurnalRTGS = new List<JurnalRTGS>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/PO/PopulateJurnalRTGS?ClassificationId=" + _intClassificationId + "&Module=" + strModule).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken TokenData = strObject["listJurnalRTGS"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    listJurnalRTGS = JsonConvert.DeserializeObject<List<JurnalRTGS>>(JsonData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, listJurnalRTGS });
        }
        public JsonResult Process(string Guid1)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                if (_intClassificationId == 71)
                {
                    using (HttpClient client = new HttpClient())
                    {
                        client.BaseAddress = new Uri(_strAPIUrl);
                        MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                        client.DefaultRequestHeaders.Accept.Add(contentType);
                        HttpResponseMessage response = client.GetAsync("/api/PO/PopulateJurnalRTGS?ClassificationId=" + _intClassificationId + "&Module=" + strModule).Result;
                        string stringData = response.Content.ReadAsStringAsync().Result;

                        JObject strObject = JObject.Parse(stringData);
                        blnResult = strObject.SelectToken("blnResult").Value<bool>();
                        ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                        JToken TokenData = strObject["listJurnalRTGS"];
                        string JsonData = JsonConvert.SerializeObject(TokenData);
                    }
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg });
        }
    }
}
