using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
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

namespace Reksa.Controllers
{
    public class POController : Controller
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

        private ISession _session => _httpContextAccessor.HttpContext.Session;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private clsConvert clsConvert;

        public POController(IConfiguration iconfig, IHttpContextAccessor httpContextAccessor)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
            _httpContextAccessor = httpContextAccessor;
            clsConvert = new clsConvert();
        }
        [Authorize]
        public IActionResult CutMaintenanceFee()
        {
            return View();
        }
        [Authorize]
        public IActionResult CutRedemptionFee()
        {
            return View();
        }
        [Authorize]
        public IActionResult DiscountRedempFee()
        {
            return View();
        }
        [Authorize]
        public IActionResult AdjustRedempDate()
        {
            return View();
        }
        [Authorize]
        public IActionResult AdjustNAVDate()
        {
            return View();
        }
        [Authorize]
        public IActionResult JurnalRTGS()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        [Authorize]
        public IActionResult SyncNAV()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        [Authorize]
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
        [Authorize]
        public IActionResult CancelTransaction()
        {
            return View();
        }
        [Authorize]
        public IActionResult CancelTransactionIBMB()
        {
            return View();
        }
        [Authorize]
        public IActionResult SubsLimitAlert()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        [Authorize]
        public IActionResult JurnalSKN()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        [Authorize]
        public IActionResult RejectBooking()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        [Authorize]
        public IActionResult OverrideMaintenanceFee()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        [Authorize]
        public IActionResult RecalculateMaintenanceFee()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        [Authorize]
        public IActionResult RevisiPencadanganFee()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        [Authorize]
        public IActionResult CutSellingFee()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        [Authorize]
        public IActionResult Transaction()
        {
            POListViewModel vModel = new POListViewModel();
            return View(vModel);
        }
        [Authorize]
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
        public JsonResult ProcessCutSellingFee(string StartDate, string EndDate, int ProdId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                DateTime dtStartDate = new DateTime();
                DateTime dtEndDate = new DateTime();
                DateTime.TryParse(StartDate, out dtStartDate);
                DateTime.TryParse(EndDate, out dtEndDate);

                string strStartDate = dtStartDate.ToLongDateString();
                string strEndDate = dtEndDate.ToLongDateString();
                var Content = new StringContent(JsonConvert.SerializeObject(""));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/PO/CutSellingFee?StartDate=" + strStartDate + "&EndDate=" + strEndDate + "&ProdId=" + ProdId + "&NIK=" + _intNIK + "&GUID=" + _strGuid, Content);
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
        public JsonResult GetLastFeeDate(int Type, int ManId, int ProdId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DateTime dtStartDate = new DateTime();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/PO/GetLastFeeDate?Type=" + Type + "&ManId=" + ManId + "&ProdId=" + ProdId + "&NIK=" + _intNIK + "&GUID=" + _strGuid).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken TokenData = strObject["dtStartDate"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    dtStartDate = JsonConvert.DeserializeObject<DateTime>(JsonData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, dtStartDate });
        }
        public JsonResult CutPremiAsuransi(string Period, decimal TotalPremi)
        {
            bool blnResult = false;
            string ErrMsg = "";
            int BillID = 0;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/PO/CutPremiAsuransi?Period=" + Period + "&NIK=" + _intNIK + "&TotalPremi=" + TotalPremi).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    BillID = strObject.SelectToken("BillID").Value<int>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, BillID });
        }
        public JsonResult PopulateSubscriptionLimitAlert()
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
                    HttpResponseMessage response = client.GetAsync("/api/PO/PopulateSubscriptionLimitAlert?NIK=" + _intNIK + "&Module=" + strModule).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(stringData);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();

                    JToken TokenData = Object["dsResult"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    dsResult = JsonConvert.DeserializeObject<DataSet>(JsonData);
                    if (dsResult.Tables.Count == 0)
                    {
                        blnResult = false;
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        public JsonResult GetLastTanggalPencadangan()
        {
            bool blnResult = false;
            string ErrMsg = "";
            DateTime StartDate = new DateTime();
            DateTime EndDate = new DateTime();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/PO/GetLastTanggalPencadangan").Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(stringData);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                    StartDate = Object.SelectToken("startDate").Value<DateTime>();
                    EndDate = Object.SelectToken("endDate").Value<DateTime>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, StartDate, EndDate });
        }
        public JsonResult MaintainPencadangan(string Tipe, string ProdCode, string StartDate, string EndDate)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/PO/MaintainPencadangan?Tipe=" + Tipe + "&ProdCode=" + ProdCode + "&StartDate=" + StartDate + "&EndDate="+ EndDate +"&NIK=" + _intNIK).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(stringData);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg });
        }
        public JsonResult PopulateRejectBooking(string strJenis)
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
                    HttpResponseMessage response = client.GetAsync("/api/PO/PopulateRejectBooking?Jenis=" + strJenis).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(stringData);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();

                    JToken TokenData = Object["dsResult"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    dsResult = JsonConvert.DeserializeObject<DataSet>(JsonData);
                    if (dsResult == null || dsResult.Tables.Count == 0 || dsResult.Tables[0].Rows.Count == 0)
                    {
                        blnResult = false;
                        ErrMsg = "Data tidak ada di database";
                    }
                    else
                    {
                        _session.SetString("DataSetJson", JsonConvert.SerializeObject(dsResult));
                    }
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        public ActionResult SaveRejectBooking(string listId, string strJenis)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                string[] _SelectedId;
                listId = (listId + "***").Replace("|***", "");
                _SelectedId = listId.Split('|');

                var sessionDataset = _session.GetString("DataSetJson");
                DataSet dsSelected = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                DataView dv1 = dsSelected.Tables[0].DefaultView;
                var filter = string.Join(',', _SelectedId);
                if (strJenis == "A")
                {
                    dv1.RowFilter = " bookingId in (" + filter + ")";
                }
                else
                {
                    dv1.RowFilter = " tranId in (" + filter + ")";
                }                

                DataTable dtNew = dv1.ToTable();
                if (dtNew == null || dtNew.Columns.Count == 0)
                {
                    ErrMsg = "No data to save!";
                    return Json(new { blnResult, ErrMsg });
                }

                List<MaintRejectBooking> model1 = clsConvert.MapListOfObject<MaintRejectBooking>(dtNew);
                List<MaintCancelTransaksi> model2 = clsConvert.MapListOfObject<MaintCancelTransaksi>(dtNew);

                if (strJenis == "A")
                {

                    var Content = new StringContent(JsonConvert.SerializeObject(model1));
                    using (HttpClient client = new HttpClient())
                    {
                        client.BaseAddress = new Uri(_strAPIUrl);
                        Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                        var request = client.PostAsync("/api/PO/SaveRejectBooking?NIK=" + _intNIK, Content);
                        var response = request.Result.Content.ReadAsStringAsync().Result;
                        JObject strObject = JObject.Parse(response);
                        blnResult = strObject.SelectToken("blnResult").Value<bool>();
                        ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    }
                }
                else
                {
                    var Content = new StringContent(JsonConvert.SerializeObject(model2));
                    using (HttpClient client = new HttpClient())
                    {
                        client.BaseAddress = new Uri(_strAPIUrl);
                        Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                        var request = client.PostAsync("/api/PO/SaveCancelTrans?NIK=" + _intNIK, Content);
                        var response = request.Result.Content.ReadAsStringAsync().Result;
                        JObject strObject = JObject.Parse(response);
                        blnResult = strObject.SelectToken("blnResult").Value<bool>();
                        ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    }
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg });
        }
        public JsonResult PopulateDiscFee()
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
                    HttpResponseMessage response = client.GetAsync("/api/PO/PopulateDiscFee?NIK=" + _intNIK).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(stringData);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();

                    JToken TokenData = Object["dsResult"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    dsResult = JsonConvert.DeserializeObject<DataSet>(JsonData);
                    if (dsResult == null || dsResult.Tables.Count == 0 || dsResult.Tables[0].Rows.Count == 0)
                    {
                        blnResult = false;
                        ErrMsg = "Data tidak ada di database";
                    }
                    else
                    {
                        _session.SetString("DataSetJson", JsonConvert.SerializeObject(dsResult));
                    }
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        public JsonResult MaintainDiscRedempt(int TranId, decimal RedempDisc)
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
                    HttpResponseMessage response = client.GetAsync("/api/PO/MaintainDiscRedempt?TranId=" + TranId + "&RedempDisc=" + RedempDisc + "&NIK=" + _intNIK + "&Guid=" + _strGuid ).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(stringData);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg });
        }
        public JsonResult ImportDataMFee(string FileName,int ProdId, int BankCustody, int isRecalculate)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string XML = "";

            DataSet dsUpload = new DataSet();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/PO/ImportDataMFee?FileName=" + FileName + "&XML=" + XML + "&NIK=" + _intNIK + "&ProdId=" + ProdId + "&BankCustody=" + BankCustody + "&isRecalculate=" + isRecalculate).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(stringData);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();

                    JToken TokenData = Object["dsUpload"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    dsUpload = JsonConvert.DeserializeObject<DataSet>(JsonData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, dsUpload });
        }
    }
}
