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

namespace Reksa.Controllers
{
    public class CustomerController : Controller
    {
        #region "Default Var"
        public string strModule;
        public int _intNIK;
        public string _strGuid;
        public string _strMenuName;
        public string _strBranch;
        public int _intClassificationId;
        private IConfiguration _config;
        private string _strAPIUrl;
        #endregion

        public CustomerController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }

        private enum JenisNasabah : int
        {
            INDIVIDUAL = 1,
            CORPORATE = 4
        }

        public ActionResult Customer()
        {
            CustomerListViewModel vModel = new CustomerListViewModel();
            return View(vModel);
        }

        public ActionResult RefreshCustomer(string strCIFNo)
        {
            CustomerListViewModel vModel = new CustomerListViewModel();
            List<ActivityModel> listCLientActivity = new List<ActivityModel>();
            List<BlokirModel> listCLientBlokir = new List<BlokirModel>();
            CustomerIdentitasModel custModel = new CustomerIdentitasModel();

            List<CustomerIdentitasModel> listCust = new List<CustomerIdentitasModel>();
            List<RiskProfileModel> listRisk = new List<RiskProfileModel>();

            int intClientId = 7;
            RefreshNasabah(strCIFNo, out listCust, out listRisk);
            RefreshBlokir(intClientId, 10137, "", out listCLientBlokir);

            if (listCust.Count > 0)
            {
                custModel = listCust[0];
                int intJnsNas = custModel.CIFType;
                custModel.CIFTypeName = Enum.GetName(typeof(JenisNasabah), intJnsNas);
            }
            else
            {
                custModel.CIFTypeName = "";
            }
            vModel.CustomerIdentitas = custModel;
            vModel.RiskProfileModel = listRisk[0];
            vModel.CustomerActivity = listCLientActivity;
            vModel.CustomerBlokir = listCLientBlokir;

            return View("Customer",vModel);
        }

        private void RefreshNasabah(string strCIFNo, out List<CustomerIdentitasModel> listCust, out List<RiskProfileModel> listRisk)
        {           
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                HttpResponseMessage response = client.GetAsync("/api/Customer/Refresh?CIFNO=" + strCIFNo + "&NIK=10137&Guid='77bb8d13-22af-4233-880d-633dfdf16122'").Result;
                string strJson = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(strJson);
                JToken strTokenCust = strObject["listCust"];
                JToken strTokenRisk = strObject["listRisk"];
                string strJsonCust = JsonConvert.SerializeObject(strTokenCust);
                string strJsonRisk = JsonConvert.SerializeObject(strTokenRisk);

                listCust = JsonConvert.DeserializeObject<List<CustomerIdentitasModel>>(strJsonCust);
                listRisk = JsonConvert.DeserializeObject<List<RiskProfileModel>>(strJsonRisk);
            }
        }

        private void RefreshBlokir(int intClientId, int intNIK, string strGuid, out List<BlokirModel> listCLientBlokir)
        {
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                HttpResponseMessage response = client.GetAsync("/api/Customer/RefreshBlokir?intClientId=7&intNIK=10137&strGuid='77bb8d13-22af-4233-880d-633dfdf16122'").Result;
                string strJson = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(strJson);
                JToken strTokenBlokir = strObject["listBlokir"];
                JToken strTokendecTotal = strObject["decTotal"];
                JToken strTokendecOutstandingUnit = strObject["decOutstandingUnit"];
                
                string strJsonBlokir = JsonConvert.SerializeObject(strTokenBlokir);
                

                listCLientBlokir = JsonConvert.DeserializeObject<List<BlokirModel>>(strJsonBlokir);
            }
        }
    }
}
