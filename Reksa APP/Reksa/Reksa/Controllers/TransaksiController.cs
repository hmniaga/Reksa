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
using Microsoft.AspNetCore.Authorization;

namespace Reksa.Controllers
{
    public class TransaksiController : Controller
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

        public TransaksiController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }
        [Authorize]
        public IActionResult Tunggakan()
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            return View("Tunggakan", vModel);
        }
        [Authorize]
        public IActionResult ParameterTT()
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            return View("ParameterTT", vModel);
        }
        [Authorize]
        public IActionResult OutgoingTT()
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            return View("OutgoingTT", vModel);
        }
        [Authorize]
        public IActionResult AuthOutgoingTT()
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            return View("AuthOutgoingTT", vModel);
        }
        [Authorize]
        public IActionResult Transaksi()
        {
            ViewBag.strBranch = _strBranch;
            ViewBag.intNIK = _intNIK;
            ViewBag.strMenuName = _strMenuName;
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            List<TransactionModel.FrekuensiDebet> frek = new List<TransactionModel.FrekuensiDebet>();
            return View("Transaksi", vModel);
        }
        public JsonResult CheckSubsType(string CIFNo, int ProductId, bool IsRDB)
        {
            bool blnResult = false;
            bool IsSubsNew = false;
            string ErrMsg = "";
            string strClientCode = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Transaction/CheckSubsType?CIFNO=" + CIFNo + "&ProductId=" + ProductId + "&IsTrxTA=false&IsRDB=" + IsRDB).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    IsSubsNew = strObject.SelectToken("isSubsNew").Value<bool>();
                    strClientCode = strObject.SelectToken("strClientCode").Value<string>();
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, IsSubsNew, strClientCode });
        }

        public JsonResult GetLatestBalance(int ClientID)
        {
            bool blnResult = false;
            string ErrMsg = "";
            decimal unitBalance = 0;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Transaction/GetLatestBalance?ClientID=" + ClientID + "&NIK=" + _intNIK + "&GUID=" + _strGuid).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    unitBalance = strObject.SelectToken("unitBalance").Value<decimal>();
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
                return Json(new { blnResult, ErrMsg, unitBalance });
            }
            return Json(new { blnResult, ErrMsg, unitBalance });
        }
        public JsonResult HitungFee(int ProdId, int ClientId, int TranType, decimal TranAmt, decimal TranUnit,
                bool FullAmount, bool IsFeeEdit, decimal PercentageFeeInput,
                int Jenis, string strCIFNo, bool ByPercent)
        {
            bool blnResult = false;
            string ErrMsg = "";
            decimal newFee = 0;
            decimal newPercentFee = 0;
            string FeeCurr = "";
            int intPeriod = 0;
            decimal NominalFee = 0;
            decimal PctFee = 0;
            decimal Fee = 0;
            decimal PercentFee = 0;

            TransactionModel.CalculateFeeRequest model = new TransactionModel.CalculateFeeRequest();
            model.ProdId = ProdId;
            model.ClientId = ClientId; model.TranType = TranType; model.TranAmt = TranAmt; model.Unit = TranUnit;
            model.FullAmount = FullAmount; model.IsFeeEdit = IsFeeEdit; model.PercentageFeeInput = PercentageFeeInput;
            model.CIFNo = strCIFNo;
            model.NIK = _intNIK; model.Guid = _strGuid;
            model.NAV = 0; model.IsByPercent = ByPercent; model.Process = false; model.ByUnit = false;
            model.Debug = false; model.ProcessTranId = 0;
            model.OutType = 0;
            model.ValueDate = DateTime.Now;
            TransactionModel.CalculateFeeResponse resultFee = new TransactionModel.CalculateFeeResponse();
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(model));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Transaction/CalculateFee", Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    JToken TokenResult = strObject["blnResult"];
                    JToken TokenErrMsg = strObject["errMsg"];
                    JToken TokenData = strObject["resultFee"];
                    string JsonResult = JsonConvert.SerializeObject(TokenResult);
                    string JsonErrMsg = JsonConvert.SerializeObject(TokenErrMsg);
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    blnResult = JsonConvert.DeserializeObject<bool>(JsonResult);
                    ErrMsg = JsonConvert.DeserializeObject<string>(JsonErrMsg);
                    resultFee = JsonConvert.DeserializeObject<TransactionModel.CalculateFeeResponse>(JsonData);

                    if (blnResult)
                    {
                        FeeCurr = resultFee.FeeCCY;
                        intPeriod = resultFee.Period;
                        if (Jenis == 1) //hitung fee tanpa edit fee
                        {
                            Fee = resultFee.Fee;
                            Fee = System.Math.Round(Fee, 2);
                            NominalFee = Fee;

                            PercentFee = resultFee.PercentageFeeOutput;
                            PctFee = PercentFee;
                            if (ByPercent == true)
                            {
                                NominalFee = PercentFee;
                                PctFee = Fee;
                            }
                            else if (ByPercent == false)
                            {
                                NominalFee = Fee;
                                PctFee = PercentFee;
                            }
                        }
                        else if (Jenis == 2) //hitung fee dengan edit fee 
                        {
                            if (ByPercent == true)
                            {
                                newFee = resultFee.Fee;
                                newFee = System.Math.Round(newFee, 2);
                                PctFee = newFee;
                            }
                            else if (ByPercent == false)
                            {
                                newPercentFee = resultFee.PercentageFeeOutput;
                                PctFee = newPercentFee;
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, PctFee, NominalFee, FeeCurr, intPeriod });
        }
        public JsonResult RefreshSwitching(string RefID, string CIFNo)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<TransactionModel.SwitchingNonRDBModel> listSwitching = new List<TransactionModel.SwitchingNonRDBModel>();
           
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Transaction/RefreshSwitching?RefID=" + RefID + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken strTokenSwcNonRDB = strObject["listDetailSwcNonRDB"];
                    string strJsonSwcNonRDB = JsonConvert.SerializeObject(strTokenSwcNonRDB);
                    listSwitching = JsonConvert.DeserializeObject<List<TransactionModel.SwitchingNonRDBModel>>(strJsonSwcNonRDB);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, listSwitching });
        }
        public JsonResult RefreshSwitchingRDB(string RefID, string CIFNo)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<TransactionModel.SwitchingRDBModel> listSwitchingRDB = new List<TransactionModel.SwitchingRDBModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Transaction/RefreshSwitchingRDB?RefID=" + RefID + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken strTokenSwcRDB = strObject["listDetailSwcRDB"];
                    string strJsonSwcRDB = JsonConvert.SerializeObject(strTokenSwcRDB);
                    listSwitchingRDB = JsonConvert.DeserializeObject<List<TransactionModel.SwitchingRDBModel>>(strJsonSwcRDB);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json( new { blnResult, ErrMsg, listSwitchingRDB });
        }
        public JsonResult RefreshBooking(string RefID, string CIFNo)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<TransactionModel.BookingModel> listBooking = new List<TransactionModel.BookingModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Transaction/RefreshBookingNew?RefID=" + RefID + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken strTokenBooking = strObject["listDetailBooking"];
                    string strJsonBooking = JsonConvert.SerializeObject(strTokenBooking);

                    listBooking = JsonConvert.DeserializeObject<List<TransactionModel.BookingModel>>(strJsonBooking);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, listBooking });
        }
        public JsonResult RefreshTransaction(string RefID, string CIFNo, string _strTabName)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<TransactionModel.SubscriptionDetail> listSubsDetail = new List<TransactionModel.SubscriptionDetail>();
            List<TransactionModel.SubscriptionList> listSubscription = new List<TransactionModel.SubscriptionList>();
            List<TransactionModel.RedemptionList> listRedemption = new List<TransactionModel.RedemptionList>();
            List<TransactionModel.SubscriptionRDBList> listSubsRDB = new List<TransactionModel.SubscriptionRDBList>();

            if (_strTabName != null && !_strTabName.Equals(""))
            {
                try
                {
                    using (HttpClient client = new HttpClient())
                    {
                        client.BaseAddress = new Uri(_strAPIUrl);
                        MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                        client.DefaultRequestHeaders.Accept.Add(contentType);

                        HttpResponseMessage response = client.GetAsync("/api/Transaction/RefreshTransactionNew?RefID=" + RefID + "&CIFNO=" + CIFNo + "&NIK=" + _intNIK + "&Guid=" + _strGuid + "&TranType=" + _strTabName).Result;
                        string strJson = response.Content.ReadAsStringAsync().Result;

                        JObject strObject = JObject.Parse(strJson);
                        blnResult = strObject.SelectToken("blnResult").Value<bool>();
                        ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                        JToken strTokenDetail = strObject["listSubsDetail"];
                        JToken strTokenListSubs = strObject["listSubs"];
                        JToken strTokenListRedemp = strObject["listRedemp"];
                        JToken strTokenListSubsRDB = strObject["listSubsRDB"];
                        string strJsonDetail = JsonConvert.SerializeObject(strTokenDetail);
                        string strJsonListSubs = JsonConvert.SerializeObject(strTokenListSubs);
                        string strJsonListRedemp = JsonConvert.SerializeObject(strTokenListRedemp);
                        string strJsonListSubsRDB = JsonConvert.SerializeObject(strTokenListSubsRDB);

                        listSubsDetail = JsonConvert.DeserializeObject<List<TransactionModel.SubscriptionDetail>>(strJsonDetail);
                        listSubscription = JsonConvert.DeserializeObject<List<TransactionModel.SubscriptionList>>(strJsonListSubs);
                        listRedemption = JsonConvert.DeserializeObject<List<TransactionModel.RedemptionList>>(strJsonListRedemp);
                        listSubsRDB = JsonConvert.DeserializeObject<List<TransactionModel.SubscriptionRDBList>>(strJsonListSubsRDB);
                        int intUmur = HitungUmur(CIFNo);
                        listSubsDetail[0].Umur = intUmur;
                    }
                }
                catch (Exception ex)
                {
                    ErrMsg = ex.Message;
                }                
            }
            return Json(new { blnResult, ErrMsg, listSubsDetail, listSubscription, listRedemption, listSubsRDB } );
        }
        public ActionResult GenerateTranCodeClientCode([FromBody] TransactionModel.GenerateClientCode model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string[] strData = new string[4];
            string strTrancode = "", strClientCode = "", strWarnMsg = "", strWarnMsg2 = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(model));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Transaction/GenerateTranCodeClientCode", Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    JToken TokenResult = strObject["blnResult"];
                    JToken TokenErrMsg = strObject["errMsg"];
                    JToken TokenData = strObject["strData"];
                    string JsonResult = JsonConvert.SerializeObject(TokenResult);
                    string JsonErrMsg = JsonConvert.SerializeObject(TokenErrMsg);
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    blnResult = JsonConvert.DeserializeObject<bool>(JsonResult);
                    ErrMsg = JsonConvert.DeserializeObject<string>(JsonErrMsg);
                    strData = JsonConvert.DeserializeObject<string[]>(JsonData);
                    strTrancode = strData[0];
                    strClientCode = strData[1];
                    strWarnMsg = strData[2];
                    strWarnMsg2 = strData[3];
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg, strTrancode, strClientCode, strWarnMsg, strWarnMsg2 });
            }
            return Json(new { blnResult, ErrMsg, strTrancode, strClientCode, strWarnMsg, strWarnMsg2 });
        }
        public ActionResult MaintainSwitching([FromBody] TransactionModel.MaintainSwitching model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string strRefID = "";
            DataTable dtError = new DataTable();
            try
            {
                model.intUserSuid = _intNIK;
                model.strGuid = _strGuid;
                var Content = new StringContent(JsonConvert.SerializeObject(model));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Transaction/MaintainSwitching", Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenError = strObject["dtError"];
                    JToken TokenRefID = strObject["strRefID"];
                    string JsonError = JsonConvert.SerializeObject(TokenError);
                    string JsonRefID = JsonConvert.SerializeObject(TokenRefID);
                    dtError = JsonConvert.DeserializeObject<DataTable>(JsonError);
                    strRefID = JsonConvert.DeserializeObject<string>(JsonRefID);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg, strRefID, dtError });
            }
            return Json(new { blnResult, ErrMsg, strRefID, dtError });
        }
        public ActionResult MaintainSwitchingRDB([FromBody] TransactionModel.MaintainSwitchingRDB model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string strRefID = "";
            DataTable dtError = new DataTable();
            try
            {
                model.intUserSuid = _intNIK;
                model.strGuid = _strGuid;
                var Content = new StringContent(JsonConvert.SerializeObject(model));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Transaction/MaintainSwitchingRDB", Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenError = strObject["dtError"];
                    JToken TokenRefID = strObject["strRefID"];
                    string JsonError = JsonConvert.SerializeObject(TokenError);
                    string JsonRefID = JsonConvert.SerializeObject(TokenRefID);
                    dtError = JsonConvert.DeserializeObject<DataTable>(JsonError);
                    strRefID = JsonConvert.DeserializeObject<string>(JsonRefID);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg, strRefID, dtError });
            }
            return Json(new { blnResult, ErrMsg, strRefID, dtError });
        }
        public ActionResult MaintainNewBooking([FromBody] TransactionModel.MaintainBooking model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string strRefID = "";
            DataTable dtError = new DataTable();
            try
            {
                model.intNIK = _intNIK;
                model.strGuid = _strGuid;
                var Content = new StringContent(JsonConvert.SerializeObject(model));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Transaction/MaintainNewBooking", Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenError = strObject["dtError"];
                    JToken TokenRefID = strObject["strRefID"];
                    string JsonError = JsonConvert.SerializeObject(TokenError);
                    string JsonRefID = JsonConvert.SerializeObject(TokenRefID);
                    dtError = JsonConvert.DeserializeObject<DataTable>(JsonError);
                    strRefID = JsonConvert.DeserializeObject<string>(JsonRefID);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg, strRefID, dtError });
            }
            return Json(new { blnResult, ErrMsg, strRefID, dtError });
        }
        public ActionResult MaintainAllTransaksi([FromBody] TransactionModel.MaintainTransaksi model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string strRefID = "";
            DataTable dtError = new DataTable();
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(model));
                var EncodedContent = System.Net.WebUtility.UrlEncode(Content.ToString());
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Transaction/MaintainAllTransaksiNew?NIK=" + _intNIK + "&GUID=" + _strGuid, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenError = strObject["dtError"];
                    JToken TokenRefID = strObject["strRefID"];
                    string JsonError = JsonConvert.SerializeObject(TokenError);
                    string JsonRefID = JsonConvert.SerializeObject(TokenRefID);
                    dtError = JsonConvert.DeserializeObject<DataTable>(JsonError);
                    strRefID = JsonConvert.DeserializeObject<string>(JsonRefID);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg, strRefID, dtError });
            }
            return Json(new { blnResult, ErrMsg, strRefID, dtError });
        } 
        private int HitungUmur(string strCIFNo)
        {
            int intUmur = 0;
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                HttpResponseMessage response = client.GetAsync("/api/Global/HitungUmur?CIFNo=" + strCIFNo + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
                string strJson = response.Content.ReadAsStringAsync().Result;

                intUmur = JsonConvert.DeserializeObject<int>(strJson);
            }
            return intUmur;
        }
        public JsonResult GetLatestNAV(string ProdId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            decimal NAV = 0;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Transaction/GetLatestNAV?ProdId=" + ProdId + "&NIK=" + _intNIK + "&GUID=" + _strGuid).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken strdecNAV = strObject["decNAV"];
                    string strJsonNAV = JsonConvert.SerializeObject(strdecNAV);
                    NAV = JsonConvert.DeserializeObject<decimal>(strJsonNAV);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, NAV });
        }
        public JsonResult HitungBookingFee(string CIFNo, decimal BookingAmount, string ProductCode, bool ByPercent,
            bool IsFeeEdit, decimal PercentageFeeInput)
        {
            bool blnResult = false;
            string ErrMsg = "";
            decimal PctFee = 0;
            string FeeCurr = "";
            decimal NominalFee = 0;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Transaction/CalculateBookingFee?CIFNo=" + CIFNo + "&Amount=" + BookingAmount + "&ProductCode=" + ProductCode + "&IsByPercent=" + ByPercent + "&IsFeeEdit=" + IsFeeEdit + "&PercentageFeeInput=" + PercentageFeeInput).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken strTokenPctFee = strObject["PercentageFeeOutput"];
                    JToken strTokenCCY = strObject["FeeCCY"];
                    JToken strTokenNomFee = strObject["Fee"];

                    string strJsonPctFee = JsonConvert.SerializeObject(strTokenPctFee);
                    string strJsonCCY = JsonConvert.SerializeObject(strTokenCCY);
                    string strJsonNomFee = JsonConvert.SerializeObject(strTokenNomFee);

                    PctFee = JsonConvert.DeserializeObject<decimal>(strJsonPctFee);
                    NominalFee = JsonConvert.DeserializeObject<decimal>(strJsonNomFee);
                    FeeCurr = JsonConvert.DeserializeObject<string>(strJsonCCY);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, PctFee, NominalFee, FeeCurr });
        }
        public ActionResult HitungSwitchingFee([FromBody]SwitchingRequest model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            SwitchingResponses calcFeeResult = new SwitchingResponses();
            try
            {
                if (model != null)
                {
                    model.NIK = _intNIK;
                    model.Guid = _strGuid;
                }
                var Content = new StringContent(JsonConvert.SerializeObject(model));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");

                    var request = client.PostAsync("/api/Transaction/CalculateSwitchingFee", Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken strFee = strObject["resultFee"];
                    string strJsonFee = JsonConvert.SerializeObject(strFee);

                    calcFeeResult = JsonConvert.DeserializeObject<SwitchingResponses>(strJsonFee);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, calcFeeResult });
        }
        public ActionResult HitungSwitchingRDBFee([FromBody]SwitchingRDBRequest model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            SwitchingRDBResponses calcFeeResult = new SwitchingRDBResponses();
            try
            {
                if (model != null)
                {
                    model.NIK = _intNIK;
                    model.Guid = _strGuid;
                }
                var Content = new StringContent(JsonConvert.SerializeObject(model));                
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");

                    var request = client.PostAsync("/api/Transaction/CalculateSwitchingRDBFee", Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken strFee = strObject["resultFee"];
                    string strJsonFee = JsonConvert.SerializeObject(strFee);

                    calcFeeResult = JsonConvert.DeserializeObject<SwitchingRDBResponses>(strJsonFee);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, calcFeeResult });
        }
        public JsonResult GetImportantData(string CariApa, string InputData)
        {
            string value = "";
            //bool blnResult = false;
            string ErrMsg = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Transaction/GetImportantData?CariApa=" + CariApa + "&Input=" + InputData).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(strJson);
                    JToken TokenData = Object["value"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);

                    value = JsonConvert.DeserializeObject<string>(JsonData);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
                return Json(new { value });
            }

            return Json(new { value });
        }
        public JsonResult PopulateComboFrekDebet()
        {
            string ErrMsg;
            List<TransactionModel.FrekuensiDebet> list = new List<TransactionModel.FrekuensiDebet>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Global/PopulateCombo").Result;
                    if (!response.IsSuccessStatusCode)
                        throw new HttpRequestException();

                    string strJson = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<TransactionModel.FrekuensiDebet>>(strJson);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { list });
            }
            return Json(new { list });
        }
        public JsonResult GetRegulerSubscriptionTunggakan(int intClientId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<TransactionModel.Tunggakan> listTunggakan = new List<TransactionModel.Tunggakan>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Transaction/GetRegulerSubscriptionTunggakan?ClientId=" + intClientId).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenTunggakan = strObject["listTunggakan"];
                    string JsonTunggakan = JsonConvert.SerializeObject(TokenTunggakan);
                    listTunggakan = JsonConvert.DeserializeObject<List<TransactionModel.Tunggakan>>(JsonTunggakan);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, listTunggakan });
        }
        public JsonResult PopulateTTCompletion(int intProdId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            TransactionModel.TransactionTT listTransactionTT = new TransactionModel.TransactionTT();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Transaction/PopulateTTCompletion?ProdId=" + intProdId).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenTTCompletion = strObject["listTTCompletion"];
                    string JsonTTCompletion = JsonConvert.SerializeObject(TokenTTCompletion);
                    listTransactionTT = JsonConvert.DeserializeObject<TransactionModel.TransactionTT>(JsonTTCompletion);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, listTransactionTT });
        }
        public ActionResult MaintainCompletion([FromBody] TransactionModel.TransactionTT model)
        {
            bool blnResult = false;
            string ErrMsg = "";

            try
            {
                model.InputterNIK = _intNIK;
                var Content = new StringContent(JsonConvert.SerializeObject(model));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Transaction/MaintainCompletion", Content);
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
        public JsonResult InitializeDataTTCompletion(int intProdId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            TransactionModel.TransactionTT listTransactionTT = new TransactionModel.TransactionTT();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Transaction/InitializeDataTTCompletion?ProdId=" + intProdId).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenTTCompletion = strObject["listTTCompletion"];
                    string JsonTTCompletion = JsonConvert.SerializeObject(TokenTTCompletion);
                    listTransactionTT = JsonConvert.DeserializeObject<TransactionModel.TransactionTT>(JsonTTCompletion);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, listTransactionTT });
        }
        public JsonResult PopulateOutgoingTT()
        {
            bool blnResult = false;
            string ErrMsg = "";
            List < TransactionModel.OutgoingTT> listOutgoingTT = new List<TransactionModel.OutgoingTT>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Transaction/PopulateOutgoingTT").Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenOutgoingTT = strObject["listOutgoingTT"];
                    string JsonOutgoingTT = JsonConvert.SerializeObject(TokenOutgoingTT);
                    listOutgoingTT = JsonConvert.DeserializeObject< List<TransactionModel.OutgoingTT>>(JsonOutgoingTT);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, listOutgoingTT });
        }
        public JsonResult ManualUpdateRiskProfile(string CIFNo, string NewLastUpdate)
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
                    HttpResponseMessage response = client.GetAsync("/api/Transaction/ManualUpdateRiskProfile?CIFNo=" + CIFNo + "&NewLastUpdate=" + NewLastUpdate).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg});
        }
        public JsonResult PopulateVerifyOutgoingTT(string JenisProses)
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
                    HttpResponseMessage response = client.GetAsync("/api/Transaction/PopulateVerifyOutgoingTT?JenisProses=" + JenisProses).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(stringData);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();

                    JToken TokenData = Object["dsResult"];
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
        public JsonResult AuthorizeOutgoingTT(string JenisProses, bool isProcess, string BillId, string RemittanceNumber)
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
                    HttpResponseMessage response = client.GetAsync("/api/Transaction/AuthorizeOutgoingTT?NIK=" + _intNIK + "&JenisProses=" + JenisProses + "&isProcess=" + isProcess + "&BillId=" + BillId + "&RemittanceNumber=" + RemittanceNumber).Result;
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
        public JsonResult PrepareDataJurnalTT(string BillId, bool JenisJurnal)
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
                    HttpResponseMessage response = client.GetAsync("/api/Transaction/PrepareDataJurnalTT?NIK=" + _intNIK + "&Branch=" + _strBranch + "&BillId=" + BillId + "&JenisJurnal=" + JenisJurnal).Result;
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
        public JsonResult PopulateVerifyDocuments(int TranId, bool IsEdit, bool IsSwitching, bool IsBooking, string RefID)
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
                    HttpResponseMessage response = client.GetAsync("/api/Transaction/PopulateVerifyDocuments?TranId=" + TranId + "&IsEdit=" + IsEdit + "&IsSwitching=" + IsSwitching + "&IsBooking=" + IsBooking + "&strRefID=" + RefID).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(stringData);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();

                    JToken TokenData = Object["dsResult"];
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
        public JsonResult MaintainOutgoingTT(int BillId, bool isProcess, string AlasanDelete)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string IsCurrencyHoliday = "";
            DateTime dtNewValueDate = new DateTime();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Transaction/MaintainOutgoingTT?BillId=" + BillId + "&isProcess=" + isProcess + "&AlasanDelete=" + AlasanDelete + "&NIK=" + _intNIK).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(stringData);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                    IsCurrencyHoliday = Object.SelectToken("isCurrencyHoliday").Value<string>();
                    dtNewValueDate = Object.SelectToken("dtNewValueDate").Value<DateTime>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, IsCurrencyHoliday, dtNewValueDate });
        }
    }
}
