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
        public IActionResult AdjustRedempDate()
        {
            return View();
        }
        public IActionResult AdjustNAVDate()
        {
            return View();
        }
        public IActionResult JurnalRTGS()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        public IActionResult SyncNAV()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        public IActionResult SyncFile()
        {
            POListViewModel vModel = new POListViewModel();
            List<ParamSinkronisasi> listParam = new List<ParamSinkronisasi>();
            PopulateDropDownList("TIPE", out listParam);
            vModel.TypeSinkronisasi = listParam;
            PopulateDropDownList("FORMAT", out listParam);
            vModel.FormatSinkronisasi = listParam;
            return View(vModel);
        }
        public IActionResult CancelTransaction()
        {
            return View();
        }
        public IActionResult CancelTransactionIBMB()
        {
            return View();
        }
        public IActionResult SubsLimitAlert()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        public IActionResult JurnalSKN()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        public IActionResult RejectBooking()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        public IActionResult OverrideMaintenanceFee()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        public IActionResult RecalculateMaintenanceFee()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        public IActionResult RevisiPencadanganFee()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        public IActionResult CutSellingFee()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        public IActionResult Transaction()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        public IActionResult CutOffPremiAsuransi()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        public JsonResult RefreshProdNAV(int ProdId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ProductNAV> listProductNAV = new List<ProductNAV>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/PO/RefreshProdNAV?ProductId=" + ProdId + "&NIK=" + _intNIK + "&GUID=" + _strGuid).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken TokenData = strObject["listProductNAV"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    listProductNAV = JsonConvert.DeserializeObject<List<ProductNAV>>(JsonData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, listProductNAV });
        }
        public JsonResult MaintainProdNAV(int ProdId, decimal NAV, string NAVValueDate, string DevidentDate, decimal Devident, decimal HargaUnit)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string RefID = "";
            try
            {
                DateTime dtNAVValueDate = new DateTime();
                DateTime dtDevidentDate = new DateTime();
                DateTime.TryParse(NAVValueDate, out dtNAVValueDate);
                DateTime.TryParse(DevidentDate, out dtDevidentDate);

                string strNAVValueDate = dtNAVValueDate.ToLongDateString();
                string strDevidentDate = dtDevidentDate.ToLongDateString();

                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/PO/MaintainProdNAV?ProductId=" + ProdId + "&NIK=" + _intNIK + "&NAV=" + NAV + "&NAVValueDate=" + strNAVValueDate + "&DevidentDate=" + strDevidentDate + "&Devident=" + Devident + "&HargaUnit=" + HargaUnit).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    RefID = strObject.SelectToken("strRefId").Value<string>(); 
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, RefID });
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
        public JsonResult GetListProducts()
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ListProduct> listProduct = new List<ListProduct>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/PO/GetListProducts").Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken TokenData = strObject["listProduct"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    listProduct = JsonConvert.DeserializeObject<List<ListProduct>>(JsonData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, listProduct });
        }
        public JsonResult PopulateCancelTrans()
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
                    HttpResponseMessage response = client.GetAsync("/api/PO/PopulateCancelTrans").Result;
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

        public JsonResult subCancelTransaction(string listTranId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(""));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/PO/CancelTransaction?listTranId=" + listTranId + "&NIK=" + _intNIK + "&GUID=" + _strGuid, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg });
        }

        private bool PopulateDropDownList(string ListName, out List<ParamSinkronisasi> listParam)
        {
            bool blnResult = false;
            string ErrMsg = "";
            listParam = new List<ParamSinkronisasi>();

            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Parameter/GetDropDownList?ListName=" + ListName).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken TokenParam = strObject["listParam"];
                    string JsonParam = JsonConvert.SerializeObject(TokenParam);
                    listParam = JsonConvert.DeserializeObject<List<ParamSinkronisasi>>(JsonParam);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }            
            return blnResult;
        }
    }
}
