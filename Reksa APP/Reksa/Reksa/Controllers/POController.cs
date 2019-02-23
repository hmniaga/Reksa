using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Controllers
{
    public class POController : Controller
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

        public POController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }

        public IActionResult CutMaintenanceFee()
        {
            return View();
        }
        public IActionResult CutRedemptionFee()
        {
            return View();
        }
        public IActionResult DiscountRedempFee()
        {
            return View();
        }
        public IActionResult AdjustRedempFee()
        {
            return View();
        }      
            
            
    }
}
