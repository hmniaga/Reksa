using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Reksa.Models;
using Reksa.ViewModels;
using System.Net.Http;
using Microsoft.Extensions.Configuration;
using System.Net.Http.Headers;
using Newtonsoft.Json;

namespace Reksa.Controllers
{
    public class ParameterController : Controller
    {
        private IConfiguration _config;
        private string _strAPIUrl;

        public ParameterController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }
        public ActionResult Index(int ProdukId)
        {
            ViewData["Label0"] = "Produk";
            ViewData["Label1"] = "Kode";
            ViewData["Label2"] = "Deskripsi";
            ViewData["Label3"] = "Tanggal valuta";
            ViewData["Label4"] = "Kode Kantor";

            List<ParameterModel> list = new List<ParameterModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Parameter/Refresh?ProdId=" + ProdukId + "&TreeInterface=SAC&NIK=10137&Guid=a1b2").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ParameterModel>>(stringData);
            }

            ParameterListViewModel vModel = new ParameterListViewModel();
            vModel.Parameter = list;

            if (list.Count > 0)
            {
                //ViewData["Value0"] = listData[0].Kode;
                //ViewData["Value1"] = listData[0].Kode;
                //ViewData["Value2"] = listData[0].Deskripsi;
                //ViewData["Value3"] = listData[0].TanggalValuta;                
            }
            return View(vModel);
        }
        public IActionResult ParameterGlobal()
        {
            return View();
        }
        public IActionResult SubscriptionFee()
        {
            return View();
        }
        public IActionResult RedemptionFee()
        {
            return View();
        }
        public IActionResult MaintenanceFee()
        {
            return View();
        }
        public IActionResult UpFrontSellingFee()
        {
            return View();
        }
        public IActionResult SwitchingFee()
        {
            return View();
        }
    }
}