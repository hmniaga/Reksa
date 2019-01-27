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
    public class MasterController : Controller
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

        public IActionResult Customer()
        {
            CustomerListViewModel vModel = new CustomerListViewModel();
            List<ActivityModel> listCLientActivity = new List<ActivityModel>();
            List<BlokirModel> listCLientBlokir = new List<BlokirModel>();
            CustomerIdentitasModel custModel = new CustomerIdentitasModel();

            List<CustomerIdentitasModel> listCust = new List<CustomerIdentitasModel>();
            List<RiskProfileModel> listRisk = new List<RiskProfileModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Customer/Refresh?CIFNO=0000000000123&NIK=10137&Guid='77bb8d13-22af-4233-880d-633dfdf16122'").Result;
                string strJson = response.Content.ReadAsStringAsync().Result;
             
                JObject strObject = JObject.Parse(strJson);
                JToken strTokenCust = strObject["listCust"];
                JToken strTokenRisk = strObject["listRisk"];
                string strJsonCust = JsonConvert.SerializeObject(strTokenCust);
                string strJsonRisk = JsonConvert.SerializeObject(strTokenRisk);

                listCust = JsonConvert.DeserializeObject<List<CustomerIdentitasModel>>(strJsonCust);
                listRisk = JsonConvert.DeserializeObject<List<RiskProfileModel>>(strJsonRisk);
            }

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

            return View(vModel);
        }
        public IActionResult InfoProduk()
        {
            return View();
        }
        public IActionResult UnitNasabah()
        {
            return View();
        }
        public IActionResult Booking()
        {
            return View();
        }

        public IActionResult Event()
        {
            return View();
        }
    }
}
