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
        public IActionResult Transaksi()
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            return View("Transaksi", vModel);
        }

        public JsonResult RefreshTransaction(string RefID, string CIFNo, string idAccordions)
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            vModel.TransactionSubsDetail = new TransactionSubscriptionModel.SubscriptionDetail();
            if (idAccordions != null && !idAccordions.Equals(""))
            {
                RefreshTransaction(idAccordions, RefID, CIFNo,
                    out List<TransactionSubscriptionModel.SubscriptionDetail> listSubsDetail,
                    out List<TransactionSubscriptionModel.SubscriptionList> listSubsrption,
                    out List<TransactionSubscriptionModel.RedemptionList> listRedemption,
                    out List<TransactionSubscriptionModel.SubscriptionRDBList> listSubsRDB);
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

        public JsonResult RefreshSwitching(string RefID, string idAccordions)
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            vModel.TransactionSubsDetail = new TransactionSubscriptionModel.SubscriptionDetail();
            if (idAccordions != null && !idAccordions.Equals(""))
            {
                RefreshTransaction(idAccordions, RefID, CIFNo,
                    out List<TransactionSubscriptionModel.SubscriptionDetail> listSubsDetail,
                    out List<TransactionSubscriptionModel.SubscriptionList> listSubsrption,
                    out List<TransactionSubscriptionModel.RedemptionList> listRedemption,
                    out List<TransactionSubscriptionModel.SubscriptionRDBList> listSubsRDB);
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
            out List<TransactionSubscriptionModel.SubscriptionDetail> listSubsDetail,
            out List<TransactionSubscriptionModel.SubscriptionList> listSubscription,
            out List<TransactionSubscriptionModel.RedemptionList> listRedemption,
            out List<TransactionSubscriptionModel.SubscriptionRDBList> listSubsRDB)
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

                listSubsDetail = JsonConvert.DeserializeObject<List<TransactionSubscriptionModel.SubscriptionDetail>>(strJsonDetail);
                listSubscription = JsonConvert.DeserializeObject<List<TransactionSubscriptionModel.SubscriptionList>>(strJsonListSubs);
                listRedemption = JsonConvert.DeserializeObject<List<TransactionSubscriptionModel.RedemptionList>>(strJsonListRedemp);
                listSubsRDB = JsonConvert.DeserializeObject<List<TransactionSubscriptionModel.SubscriptionRDBList>>(strJsonListSubsRDB);
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


    }
}
