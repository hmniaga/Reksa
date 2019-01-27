using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;
using Reksa.ViewModels;
using Reksa.Data;

namespace Reksa.Controllers
{
    //[Route("api/[controller]")]
    //[ApiController]
    public class ReportController : Controller
    {
        #region "Default Var"
        private readonly ReksaDBContext _ReksaDBContext;
        public string strModule;
        public int _intNIK;
        public string _strGuid;
        public string _strMenuName;
        public string _strBranch;
        public int _intClassificationId;
        #endregion

        public ReportController(ReksaDBContext Context)
        {
            _ReksaDBContext = Context;
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
