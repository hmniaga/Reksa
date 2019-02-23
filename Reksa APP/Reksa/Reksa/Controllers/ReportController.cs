using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;
using Reksa.ViewModels;
using Reksa.Data;
using Microsoft.Extensions.Configuration;

namespace Reksa.Controllers
{
    //[Route("api/[controller]")]
    //[ApiController]
    public class ReportController : Controller
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

        public ReportController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }

        public IActionResult NFSUpload()
        {
            return View();
        }
        public IActionResult ReportKYC()
        {
            return View();
        }
    }
}
