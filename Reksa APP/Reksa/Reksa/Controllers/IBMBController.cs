using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Reksa.Models;
using Reksa.ViewModels;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace Reksa.Controllers
{
    public class IBMBController : Controller
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

        public IBMBController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }
        [Authorize]
        public IActionResult SettingLimitFee()
        {
            return View();
        }
        [Authorize]
        public IActionResult MaintainKinerja()
        {
            return View();
        }
        [Authorize]
        public IActionResult UploadPDFFundFactProspectus()
        {
            return View();
        }
        public JsonResult RefreshKinerjaProduk()
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<KinerjaProduk> listKinerjaProduk = new List<KinerjaProduk>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/IBMB/RefreshKinerjaProduk?NIK=" + _intNIK + "&Module=" + strModule).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenKinerjaProduk = strObject["listKinerjaProduk"];
                    string JsonKinerjaProduk = JsonConvert.SerializeObject(TokenKinerjaProduk);
                    listKinerjaProduk = JsonConvert.DeserializeObject<List<KinerjaProduk>>(JsonKinerjaProduk);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, listKinerjaProduk });
        }
        public ActionResult MaintainKinerjaProduk([FromBody] KinerjaProduk model)
        {
            bool blnResult = false;
            string ErrMsg = "";

            try
            {
                model.NIK = _intNIK;
                model.Module = strModule;
                var Content = new StringContent(JsonConvert.SerializeObject(model));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/IBMB/MaintainKinerja", Content);
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
