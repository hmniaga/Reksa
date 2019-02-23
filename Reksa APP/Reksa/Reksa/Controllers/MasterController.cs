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

        public IActionResult InfoProduk()
        {
            return View();
        }
        public IActionResult UnitNasabah()
        {
            return View("UnitNasabahDitawarkan");
        }

        public IActionResult UnitDitawarkan()
        {
            return View("UnitDitawarkan");
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
