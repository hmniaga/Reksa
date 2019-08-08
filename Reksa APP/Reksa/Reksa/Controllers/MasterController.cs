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
using Microsoft.AspNetCore.Authorization;
using System.Data;

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
        [Authorize]
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
        [Authorize]
        public IActionResult InfoProduk()
        {
            return View();
        }
        [Authorize]
        public IActionResult UnitNasabah()
        {
            return View("UnitNasabahDitawarkan");
        }
        [Authorize]
        public IActionResult UnitDitawarkan()
        {
            return View("UnitDitawarkan");
        }
        [Authorize]
        public IActionResult Booking()
        {
            return View();
        }
        [Authorize]
        public IActionResult Event()
        {
            return View();
        }
        public JsonResult InqUnitDitwrkan(string ProdCode)
        {
            bool blnResult = false;
            string ErrMsg = "";
            decimal sisaUnit = 0;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    string strdtNow = DateTime.Now.ToLongDateString();
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Master/InqUnitDitwrkan?ProdCode=" + ProdCode + "&NIK=" + _intNIK + "&GUID=" + _strGuid + "&CurrDate=" + strdtNow).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken TokenData = strObject["sisaUnit"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    sisaUnit = JsonConvert.DeserializeObject<decimal>(JsonData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, sisaUnit });
        }
        public JsonResult RefreshProduct(int ProdId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();
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

                    JToken TokenData = strObject["dsResult"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    dsResult = JsonConvert.DeserializeObject<DataSet>(JsonData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        public JsonResult InqUnitNasabahDitwrkan(string CIFNo, string ProdCode)
        {
            bool blnResult = false;
            string ErrMsg = "";
            decimal sisaUnit = 0;
            try
            {
                string strdtNow =  DateTime.Now.ToLongDateString();
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Master/InqUnitNasabahDitwrkan?CIFNo="+ CIFNo + "&ProdCode=" + ProdCode + "&NIK=" + _intNIK + "&GUID=" + _strGuid + "&CurrDate=" + strdtNow).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken TokenData = strObject["sisaUnit"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    sisaUnit = JsonConvert.DeserializeObject<decimal>(JsonData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, sisaUnit });
        }
        public JsonResult CalcEffectiveDate(string StartDate, int NumDays)
        {
            string ErrMsg = "";
            DateTime dateEnd = new DateTime();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Master/CalcEffectiveDate?StartDate=" + StartDate + "&NumDays=" + NumDays).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    dateEnd = JsonConvert.DeserializeObject<DateTime>(stringData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { ErrMsg, dateEnd });
        }
        public ActionResult MaintainProduct([FromBody] MaintainProduct model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                model.intNIK = _intNIK;
                model.strGUID = _strGuid;
                var Content = new StringContent(JsonConvert.SerializeObject(model));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Master/MaintainProduct", Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        
    }
}
