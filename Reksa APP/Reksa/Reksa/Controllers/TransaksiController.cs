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

        public IActionResult Transaksi()
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            List<TransactionModel.FrekuensiDebet> frek = new List<TransactionModel.FrekuensiDebet>();
            frek = PopulateComboFrekDebet();
            vModel.FrekuensiDebet = frek;
            return View("Transaksi", vModel);
        }

        public JsonResult RefreshSwitching(string RefID, string CIFNo)
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            RefreshSwitchingData(RefID, out List<TransactionModel.SwitchingNonRDBModel> listSwitching);
            RefreshNasabah(CIFNo, out List<CustomerIdentitasModel> listCust, out List<RiskProfileModel> listRisk, out List<CustomerNPWPModel> listNPWP);
            if (listSwitching.Count > 0)
            {
                vModel.TransactionSwitching = listSwitching[0];
            }
            vModel.CustomerIdentitas = listCust[0];
            vModel.RiskProfileModel = listRisk[0];

            int intUmur = HitungUmur(CIFNo);
            vModel.CustomerIdentitas.Umur = intUmur;
            return Json(vModel);
        }
        public JsonResult RefreshSwitchingRDB(string RefID, string CIFNo)
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            RefreshSwitchingRDBData(RefID, out List<TransactionModel.SwitchingRDBModel> listSwitchingRDB);
            RefreshNasabah(CIFNo, out List<CustomerIdentitasModel> listCust, out List<RiskProfileModel> listRisk, out List<CustomerNPWPModel> listNPWP);
            vModel.TransactionSwitchingRDB = listSwitchingRDB[0];
            vModel.CustomerIdentitas = listCust[0];
            vModel.RiskProfileModel = listRisk[0];

            int intUmur = HitungUmur(CIFNo);
            vModel.CustomerIdentitas.Umur = intUmur;
            return Json(vModel);
        }

        public JsonResult RefreshBooking(string RefID, string CIFNo)
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            RefreshBookingData(RefID, out List<TransactionModel.BookingModel> listBooking);
            RefreshNasabah(CIFNo, out List<CustomerIdentitasModel> listCust, out List<RiskProfileModel> listRisk, out List<CustomerNPWPModel> listNPWP);
            vModel.TransactionBooking = listBooking[0];
            vModel.CustomerIdentitas = listCust[0];
            vModel.RiskProfileModel = listRisk[0];

            int intUmur = HitungUmur(CIFNo);
            vModel.CustomerIdentitas.Umur = intUmur;
            return Json(vModel);
        }

        public JsonResult RefreshTransaction(string RefID, string CIFNo, string idAccordions)
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            vModel.TransactionSubsDetail = new TransactionModel.SubscriptionDetail();
            if (idAccordions != null && !idAccordions.Equals(""))
            {
                RefreshTransaction(idAccordions, RefID, CIFNo,
                    out List<TransactionModel.SubscriptionDetail> listSubsDetail,
                    out List<TransactionModel.SubscriptionList> listSubsrption,
                    out List<TransactionModel.RedemptionList> listRedemption,
                    out List<TransactionModel.SubscriptionRDBList> listSubsRDB);
                RefreshNasabah(CIFNo, out List<CustomerIdentitasModel> listCust, out List<RiskProfileModel> listRisk, out List<CustomerNPWPModel> listNPWP);
                
                vModel.TransactionSubsDetail = listSubsDetail[0];
                vModel.ListSubscription = listSubsrption;
                vModel.ListRedemption = listRedemption;
                vModel.ListSubsRDB = listSubsRDB;
                vModel.CustomerIdentitas = listCust[0];
                vModel.RiskProfileModel = listRisk[0];

                int intUmur = HitungUmur(CIFNo);
                vModel.TransactionSubsDetail.Umur = intUmur;
            }
            return Json(vModel);
        }

        private void RefreshTransaction(string strTranType, string strRefID, string strCIFNo, 
            out List<TransactionModel.SubscriptionDetail> listSubsDetail,
            out List<TransactionModel.SubscriptionList> listSubscription,
            out List<TransactionModel.RedemptionList> listRedemption,
            out List<TransactionModel.SubscriptionRDBList> listSubsRDB)
        {
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                HttpResponseMessage response = client.GetAsync("/api/Transaction/RefreshTransactionNew?RefID="+ strRefID + "&CIFNO=" + strCIFNo + "&NIK="+ _intNIK +"&Guid="+ _strGuid +"&TranType=" + strTranType).Result;
                string strJson = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(strJson);
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

        private void RefreshSwitchingRDBData(string strRefID, out List<TransactionModel.SwitchingRDBModel> listSwitchingRDB)
        {
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                HttpResponseMessage response = client.GetAsync("/api/Transaction/RefreshSwitchingRDB?RefID=" + strRefID + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
                string strJson = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(strJson);
                JToken strTokenSwcRDB = strObject["listDetailSwcRDB"];
                string strJsonSwcRDB = JsonConvert.SerializeObject(strTokenSwcRDB);

                listSwitchingRDB = JsonConvert.DeserializeObject<List<TransactionModel.SwitchingRDBModel>>(strJsonSwcRDB);
            }
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

        private void RefreshNasabah(string strCIFNo, 
            out List<CustomerIdentitasModel> listCust, 
            out List<RiskProfileModel> listRisk, 
            out List<CustomerNPWPModel> listCustNPWP)
        {
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                HttpResponseMessage response = client.GetAsync("/api/Customer/Refresh?CIFNO=" + strCIFNo + "&NIK="+ _intNIK +"&Guid=" + _strGuid).Result;
                string strJson = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(strJson);
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

        private List<TransactionModel.FrekuensiDebet> PopulateComboFrekDebet()
        {
            List<TransactionModel.FrekuensiDebet> list = new List<TransactionModel.FrekuensiDebet>();

            using (HttpClient client = new HttpClient())
            {
                try
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
                catch (Exception e)
                {
                    list = new List<TransactionModel.FrekuensiDebet>();
                }
            }            
            
            return list;
        }


        private void HitungSwitchingFee()
        {
        }

        private void HitungSwitchingRDBFee()
        { }
        private void HitungBookingFee(string CIFNo, decimal BookingAmount, string ProductCode, bool ByPercent,
            bool IsFeeEdit, decimal PercentageFeeInput, out decimal PctFee,
            out string FeeCurr, out decimal NominalFee)
        {
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                HttpResponseMessage response = client.GetAsync("api/Transaction/CalculateBookingFee?CIFNo="+ CIFNo + "&Amount="+ BookingAmount + "&ProductCode="+ ProductCode + "&IsByPercent="+ ByPercent + "&IsFeeEdit=" + IsFeeEdit + "&PercentageFeeInput=" + PercentageFeeInput).Result;
                string strJson = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(strJson);
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

        
    }
}
