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
        public IActionResult Tunggakan()
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            return View("Tunggakan", vModel);
        }
        public IActionResult ParameterTT()
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            return View("ParameterTT", vModel);
        }
        public IActionResult OutgoingTT()
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            return View("OutgoingTT", vModel);
        }
        public IActionResult AuthOutgoingTT()
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            return View("AuthOutgoingTT", vModel);
        }
        public IActionResult Transaksi()
        {
            ViewBag.strBranch = _strBranch;
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            List<TransactionModel.FrekuensiDebet> frek = new List<TransactionModel.FrekuensiDebet>();
            return View("Transaksi", vModel);
        }
        public JsonResult GetDataCIF(string CIFNo)
        {
            bool blnResult;
            string ErrMsg;
            int intUmur = 0;
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            blnResult = RefreshNasabah(CIFNo, out List<CustomerIdentitasModel> listCust, out List<RiskProfileModel> listRisk, out List<CustomerNPWPModel> listNPWP, out ErrMsg);
            if(blnResult)
            {
                vModel.CustomerIdentitas = listCust[0];
                vModel.RiskProfileModel = listRisk[0];
                intUmur = HitungUmur(CIFNo);
            }
            return Json(new { blnResult, ErrMsg, vModel.CustomerIdentitas, vModel.RiskProfileModel, intUmur });
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
        public JsonResult CalculateFee(int ProdId, int ClientId, int TranType, decimal TranAmt, decimal TranUnit,
                bool FullAmount, bool IsFeeEdit, decimal PercentageFeeInput,
                int Jenis, string strCIFNo, bool ByPercent)
        {
            bool blnResult = false;
            string ErrMsg = "";
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
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg, resultFee });
            }
            return Json(new { blnResult, ErrMsg, resultFee });
        }
        public JsonResult RefreshSwitching(string RefID, string CIFNo)
        {
            bool blnResult;
            string ErrMsg;
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            RefreshSwitchingData(RefID, out List<TransactionModel.SwitchingNonRDBModel> listSwitching);
            blnResult = RefreshNasabah(CIFNo, out List<CustomerIdentitasModel> listCust, out List<RiskProfileModel> listRisk, out List<CustomerNPWPModel> listNPWP, out ErrMsg);
            if (listSwitching.Count > 0)
            {
                vModel.TransactionSwitching = listSwitching[0];
            }
            vModel.CustomerIdentitas = listCust[0];
            vModel.RiskProfileModel = listRisk[0];

            int intUmur = HitungUmur(CIFNo);
            vModel.CustomerIdentitas.Umur = intUmur;
            return Json(new { blnResult, ErrMsg, vModel.TransactionSwitching, vModel.CustomerIdentitas, vModel.RiskProfileModel });
        }
        public JsonResult RefreshSwitchingRDB(string RefID, string CIFNo)
        {
            bool blnResult = false;
            string ErrMsg = "";
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            blnResult = RefreshSwitchingRDBData(RefID, out List<TransactionModel.SwitchingRDBModel> listSwitchingRDB, out ErrMsg);
            blnResult = RefreshNasabah(CIFNo, out List<CustomerIdentitasModel> listCust, out List<RiskProfileModel> listRisk, out List<CustomerNPWPModel> listNPWP, out ErrMsg);
            vModel.TransactionSwitchingRDB = listSwitchingRDB[0];
            vModel.CustomerIdentitas = listCust[0];
            vModel.RiskProfileModel = listRisk[0];

            int intUmur = HitungUmur(CIFNo);
            vModel.CustomerIdentitas.Umur = intUmur;
            return Json( new { blnResult, ErrMsg, vModel.TransactionSwitchingRDB, vModel.CustomerIdentitas, vModel.RiskProfileModel });
        }
        public JsonResult RefreshBooking(string RefID, string CIFNo)
        {
            bool blnResult = false;
            string ErrMsg = "";
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            RefreshBookingData(RefID, out List<TransactionModel.BookingModel> listBooking);
            blnResult = RefreshNasabah(CIFNo, out List<CustomerIdentitasModel> listCust, out List<RiskProfileModel> listRisk, out List<CustomerNPWPModel> listNPWP, out ErrMsg);
            vModel.TransactionBooking = listBooking[0];
            vModel.CustomerIdentitas = listCust[0];
            vModel.RiskProfileModel = listRisk[0];

            int intUmur = HitungUmur(CIFNo);
            vModel.CustomerIdentitas.Umur = intUmur;
            return Json(new { blnResult, ErrMsg, vModel.TransactionBooking, vModel.CustomerIdentitas, vModel.RiskProfileModel });
        }
        public JsonResult RefreshTransaction(string RefID, string CIFNo, string _strTabName)
        {
            bool blnResult = false;
            string ErrMsg = "";
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            vModel.TransactionSubsDetail = new TransactionModel.SubscriptionDetail();
            List<CustomerIdentitasModel> listCust = new List<CustomerIdentitasModel>();
            List<RiskProfileModel> listRisk = new List<RiskProfileModel>();
            if (_strTabName != null && !_strTabName.Equals(""))
            {
                blnResult = RefreshTransaction(_strTabName, RefID, CIFNo,
                    out List<TransactionModel.SubscriptionDetail> listSubsDetail,
                    out List<TransactionModel.SubscriptionList> listSubsrption,
                    out List<TransactionModel.RedemptionList> listRedemption,
                    out List<TransactionModel.SubscriptionRDBList> listSubsRDB,
                    out ErrMsg);
                if (CIFNo != null)
                {
                    blnResult = RefreshNasabah(CIFNo, out listCust, out listRisk, out List<CustomerNPWPModel> listNPWP, out ErrMsg);
                }

                vModel.TransactionSubsDetail = listSubsDetail[0];
                vModel.ListSubscription = listSubsrption;
                vModel.ListRedemption = listRedemption;
                vModel.ListSubsRDB = listSubsRDB;
                if (vModel.CustomerIdentitas != null) {
                    vModel.CustomerIdentitas = listCust[0];
                }
                if (vModel.RiskProfileModel != null)
                {
                    vModel.RiskProfileModel = listRisk[0];
                }

                int intUmur = HitungUmur(CIFNo);
                vModel.TransactionSubsDetail.Umur = intUmur;
            }
            return Json(new { blnResult, ErrMsg, vModel.TransactionSubsDetail, vModel.ListSubscription, vModel.ListRedemption, vModel.ListSubsRDB, vModel.CustomerIdentitas, vModel.RiskProfileModel } );
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

        public ActionResult MaintainAllTransaksi([FromBody] TransactionModel.MaintainTransaksi model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string strRefID = "";
            DataTable dtError = new DataTable();
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(model));
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

        private bool RefreshTransaction(string strTranType, string strRefID, string strCIFNo, 
            out List<TransactionModel.SubscriptionDetail> listSubsDetail,
            out List<TransactionModel.SubscriptionList> listSubscription,
            out List<TransactionModel.RedemptionList> listRedemption,
            out List<TransactionModel.SubscriptionRDBList> listSubsRDB,
            out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            listSubsDetail = new List<TransactionModel.SubscriptionDetail>();
            listSubscription = new List<TransactionModel.SubscriptionList>();
            listRedemption = new List<TransactionModel.RedemptionList>();
            listSubsRDB = new List<TransactionModel.SubscriptionRDBList>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Transaction/RefreshTransactionNew?RefID=" + strRefID + "&CIFNO=" + strCIFNo + "&NIK=" + _intNIK + "&Guid=" + _strGuid + "&TranType=" + strTranType).Result;
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
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        private void RefreshSwitchingData(string strRefID, out List<TransactionModel.SwitchingNonRDBModel> listSwitching)
        {
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                HttpResponseMessage response = client.GetAsync("/api/Transaction/RefreshSwitching?RefID=" + strRefID + "&NIK=" + _intNIK + "&Guid=" + _strGuid ).Result;
                string strJson = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(strJson);
                JToken strTokenSwcNonRDB = strObject["listDetailSwcNonRDB"];
                string strJsonSwcNonRDB = JsonConvert.SerializeObject(strTokenSwcNonRDB);

                listSwitching = JsonConvert.DeserializeObject<List<TransactionModel.SwitchingNonRDBModel>>(strJsonSwcNonRDB);
            }
        }
        private bool RefreshSwitchingRDBData(string strRefID, out List<TransactionModel.SwitchingRDBModel> listSwitchingRDB, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            listSwitchingRDB = new List<TransactionModel.SwitchingRDBModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Transaction/RefreshSwitchingRDB?RefID=" + strRefID + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
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
            return blnResult;
        }
        private void RefreshBookingData(string strRefID, out List<TransactionModel.BookingModel> listBooking)
        {
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                HttpResponseMessage response = client.GetAsync("/api/Transaction/RefreshBookingNew?RefID=" + strRefID + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
                string strJson = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(strJson);
                JToken strTokenBooking = strObject["listDetailBooking"];
                string strJsonBooking = JsonConvert.SerializeObject(strTokenBooking);

                listBooking = JsonConvert.DeserializeObject<List<TransactionModel.BookingModel>>(strJsonBooking);
            }
        }
        private bool RefreshNasabah(string strCIFNo, 
            out List<CustomerIdentitasModel> listCust, 
            out List<RiskProfileModel> listRisk, 
            out List<CustomerNPWPModel> listCustNPWP,
            out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            listCust = new List<CustomerIdentitasModel>();
            listRisk = new List<RiskProfileModel>();
            listCustNPWP = new List<CustomerNPWPModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/Refresh?CIFNO=" + strCIFNo + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken strTokenCust = strObject["listCust"];
                    JToken strTokenRisk = strObject["listRisk"];
                    JToken strTokenCustNPWP = strObject["listCustNPWP"];
                    string strJsonCust = JsonConvert.SerializeObject(strTokenCust);
                    string strJsonRisk = JsonConvert.SerializeObject(strTokenRisk);
                    string strJsonCustNPWP = JsonConvert.SerializeObject(strTokenCustNPWP);

                    listCust = JsonConvert.DeserializeObject<List<CustomerIdentitasModel>>(strJsonCust);
                    listRisk = JsonConvert.DeserializeObject<List<RiskProfileModel>>(strJsonRisk);
                    listCustNPWP = JsonConvert.DeserializeObject<List<CustomerNPWPModel>>(strJsonCustNPWP);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
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

                    HttpResponseMessage response = client.GetAsync("api/Transaction/GetLatestNAV?ProdId=" + ProdId + "&NIK=" + _intNIK + "&GUID=" + _strGuid).Result;
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

                    HttpResponseMessage response = client.GetAsync("api/Transaction/CalculateBookingFee?CIFNo=" + CIFNo + "&Amount=" + BookingAmount + "&ProductCode=" + ProductCode + "&IsByPercent=" + ByPercent + "&IsFeeEdit=" + IsFeeEdit + "&PercentageFeeInput=" + PercentageFeeInput).Result;
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

                    var request = client.PostAsync("api/Transaction/CalculateSwitchingFee", Content);
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

                    var request = client.PostAsync("api/Transaction/CalculateSwitchingRDBFee", Content);
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
                    JToken TokenTunggakan = strObject["listTTCompletion"];
                    string JsonTunggakan = JsonConvert.SerializeObject(TokenTunggakan);
                    listTransactionTT = JsonConvert.DeserializeObject<TransactionModel.TransactionTT>(JsonTunggakan);
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
                    JToken TokenTunggakan = strObject["listTTCompletion"];
                    string JsonTunggakan = JsonConvert.SerializeObject(TokenTunggakan);
                    listTransactionTT = JsonConvert.DeserializeObject<TransactionModel.TransactionTT>(JsonTunggakan);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, listTransactionTT });
        }
    }
}
