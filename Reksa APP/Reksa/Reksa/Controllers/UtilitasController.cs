using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using Reksa.Models;
using Reksa.ViewModels;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System.Data;
using System.Data.SqlClient;

namespace Reksa.Controllers
{
    public class UtilitasController : Controller
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

        public UtilitasController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }
        public ActionResult Process()
        {
            ViewBag.strBranch = _strBranch;
            UtilitasListViewModel vModel = new UtilitasListViewModel();
            return View("Process", vModel);
        }
        public JsonResult PopulateProcess()
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ProcessModel> listProcess = new List<ProcessModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Utilitas/PopulateProcess?NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken TokenData = strObject["listProcess"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    listProcess = JsonConvert.DeserializeObject<List<ProcessModel>>(JsonData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, listProcess });
        }

        public JsonResult subProcess(string SPName, int ProcessId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ProcessModel> listProcess = new List<ProcessModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Utilitas/SPProcess?SPName=" + SPName + "&ProcessId=" + ProcessId + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, listProcess });
        }
    }
}
