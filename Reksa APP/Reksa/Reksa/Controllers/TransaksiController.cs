using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;
using Reksa.Data;
using Reksa.ViewModels;

namespace Reksa.Controllers
{
    public class TransaksiController : Controller
    {

        #region "Default Var"
        private readonly ReksaDBContext _ReksaDBContext;
        public string strModule;
        public int intNIK;
        public string strGuid;
        public string strMenuName;
        public string strBranch;
        public int intClassificationId;
        #endregion

        public TransaksiController(ReksaDBContext Context)
        {
            _ReksaDBContext = Context;
        }
        public IActionResult Transaksi()
        {
            TransaksiListViewModel vModel = new TransaksiListViewModel();
            return View(vModel);
        }
        public IActionResult Tunggakan()
        {
            return View();
        }
    }
}
