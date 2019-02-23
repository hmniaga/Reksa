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
    public class OtorisasiController : Controller
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

        public OtorisasiController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }

        public ActionResult ParameterFee()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            return View("AuthParamFee", vModel);
        }

        public ActionResult ParameterFeeDetail()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            return View("AuthParamFeeDetail", vModel);
        }

        public ActionResult ParameterReksaDana()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();            
            return View("AuthGlobalParam", vModel);
        }

        public ActionResult WM()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            return View("AuthGeneral", vModel);
        }

        public ActionResult NFS()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            return View("AuthNFSGenerateFileUpload", vModel);
        }
    }
}
