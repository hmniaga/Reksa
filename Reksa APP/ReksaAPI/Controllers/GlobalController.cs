using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Data;
using ReksaAPI.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Rendering;
using System.Data.SqlClient;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace ReksaAPI.Controllers
{

    public class GlobalController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;
        public GlobalController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }

        [Route("api/Global/GetTreeView")]
        [HttpGet("{id}")]
        public JsonResult GetTreeView([FromQuery]int NIK, [FromQuery]string Module, [FromQuery]string MenuName)
        {
            List<TreeViewModel> list = new List<TreeViewModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaGetTreeView(NIK, Module, MenuName);
            return Json(list);
        }

        [Route("api/Global/GetCommonTreeView")]
        [HttpGet("{id}")]
        public JsonResult GetCommonTreeView([FromQuery]int NIK, [FromQuery]string Module, [FromQuery]string MenuName)
        {
            List<CommonTreeViewModel> list = new List<CommonTreeViewModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaGetCommonTreeView(NIK, Module, MenuName);
            return Json(list);
        }

        [Route("api/Global/GlobalQuery")]
        [HttpGet("{id}")]
        public JsonResult GlobalQuery(string strPopulate, [FromQuery]string SelectedId, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult;
            string ErrMsg;
            DataSet dsResult = new DataSet();
            DataTable dt = new DataTable();
            List<SqlParameter> listParam = new List<SqlParameter>();
            string strCommand = cls.fnCreateCommand1(strPopulate, dt, NIK, GUID, out listParam, out string selectedId, 0);
            blnResult = cls.ReksaGlobalQuery(true, strCommand, listParam, out dsResult, out ErrMsg);
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/Global/GlobalQuery2")]
        [HttpGet("{id}")]
        public JsonResult GlobalQuery2(string strPopulate, [FromQuery]string SelectedId, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult;
            string ErrMsg;
            DataSet dsResult = new DataSet();
            DataTable dt = new DataTable();
            List<SqlParameter> listParam = new List<SqlParameter>();
            string strCommand = cls.fnCreateCommand2(SelectedId, strPopulate, dt, NIK, GUID, out listParam, out string selectedId, 0);
            blnResult = cls.ReksaGlobalQuery(true, strCommand, listParam, out dsResult, out ErrMsg);
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/Global/PopulateCombo")]
        [HttpGet]
        public JsonResult PopulateCombo()
        {
            List<SearchModel.FrekuensiDebet> list = new List<SearchModel.FrekuensiDebet>();
            list = cls.ReksaPopulateCombo();
            return Json(list);
        }        
        [Route("api/Global/HitungUmur")]
        [HttpGet("{id}")]
        public JsonResult HitungUmur([FromQuery]string CIFNo)
        {
            int intUmur = 0;
            DataSet dsOut = new DataSet();
            intUmur = cls.ReksaHitungUmur(CIFNo);
            return Json(intUmur);
        }
        [Route("api/Global/GetNoNPWPCounter")]
        [HttpGet]
        public JsonResult GetNoNPWPCounter()
        {
            bool blnResult;
            string strNoDocNPWP, ErrMsg;
            blnResult = cls.ReksaGetNoNPWPCounter(out strNoDocNPWP, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetNoNPWPCounter - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, strNoDocNPWP });
        }
        [Route("api/Global/ValidateOfficeId")]
        [HttpGet("{id}")]
        public JsonResult ValidateOfficeId([FromQuery]string OfficeId)
        {
            int isAllowed;
            bool blnResult;
            string ErrMsg;
            blnResult = cls.ReksaValidateOfficeId(OfficeId, out isAllowed, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaValidateOfficeId - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, isAllowed });
        }
        [Route("api/Global/ValidateCBOOfficeId")]
        [HttpGet("{id}")]
        public JsonResult ValidateCBOOfficeId([FromQuery]string OfficeID)
        {
            bool blnResult;
            string IsEnable = ""; string ErrMsg = "";
            blnResult = cls.ReksaValidateCBOOfficeId(OfficeID, out IsEnable, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaValidateCBOOfficeId - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, IsEnable});
        }       
        [Route("api/Global/GetSrcAgen")]
        [HttpGet("{id}")]
        public JsonResult GetSrcAgen([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]int ProdId)
        {
            List<SearchModel.Agen> list = new List<SearchModel.Agen>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcAgen(Col1, Col2, Validate, ProdId);
            return Json(list);
        }
        [Route("api/Global/GetSrcBank")]
        [HttpGet("{id}")]
        public JsonResult GetSrcBank([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]int ProdId)
        {
            List<SearchModel.Bank> list = new List<SearchModel.Bank>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcBank(Col1, Col2, Validate, ProdId);
            return Json(list);
        }
        [Route("api/Global/GetSrcBankCode")]
        [HttpGet("{id}")]
        public JsonResult GetSrcBankCode([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.BankCode> list = new List<SearchModel.BankCode>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcBankCode(Col1, Col2, Validate);
            return Json(list);
        }        
        [Route("api/Global/GetSrcBooking")]
        [HttpGet("{id}")]
        public JsonResult GetSrcBooking([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery] int Validate, [FromQuery]string Criteria)
        {
            List<SearchModel.Booking> list = new List<SearchModel.Booking>();
            list = cls.ReksaSrcBooking(Col1, Col2, Validate, Criteria);
            return Json(list);
        }
        [Route("api/Global/GetSrcCIF")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCIF([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Customer> list = new List<SearchModel.Customer>();
            //if (cls.setCFMAST(""))
            //{
            list = cls.ReksaSrcCIF(Col1, Col2, Validate);
            //cls.clearDATA("CFMAST_v");
            //}
            return Json(list);
        }
        [Route("api/Global/GetSrcCustody")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCustody([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Custody> list = new List<SearchModel.Custody>();
            //if (cls.setCFMAST(""))
            //{
            list = cls.ReksaSrcCustody(Col1, Col2, Validate);
            //cls.clearDATA("CFMAST_v");
            //}
            return Json(list);
        }
        [Route("api/Global/GetSrcCalcDevident")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCalcDevident([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.CalcDevident> list = new List<SearchModel.CalcDevident>();
            //if (cls.setCFMAST(""))
            //{
            list = cls.ReksaSrcCalc(Col1, Col2, Validate);
            //cls.clearDATA("CFMAST_v");
            //}
            return Json(list);
        }
        [Route("api/Global/GetSrcCustomer")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCustomer([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Customer> list = new List<SearchModel.Customer>();
            //if (cls.setCFMAST(""))
            //{
                list = cls.ReksaSrcCustomer(Col1, Col2, Validate);
                //cls.clearDATA("CFMAST_v");
            //}
            return Json(list);
        }
        [Route("api/Global/GetSrcClient")]
        [HttpGet("{id}")]
        public JsonResult GetSrcClient([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string ProdId)
        {
            List<SearchModel.Client> list = new List<SearchModel.Client>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcClient(Col1, Col2, Validate, ProdId);
            return Json(list);
        }

        [Route("api/Global/GetSrcClientbyCIF")]
        [HttpGet("{id}")]
        public JsonResult GetSrcClientbyCIF([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string CIFNo)
        {
            List<SearchModel.Client> list = new List<SearchModel.Client>();
            list = cls.ReksaSrcClientbyCIF(Col1, Col2, Validate, CIFNo);
            return Json(list);
        }

        [Route("api/Global/GetSrcCity")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCity([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.City> list = new List<SearchModel.City>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcCity(Col1, Col2, Validate);
            return Json(list);
        }
        [Route("api/Global/GetSrcCIFAll")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCIFAll([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Customer> list = new List<SearchModel.Customer>();
            list = cls.ReksaSrcCIFAll(Col1, Col2, Validate);
            return Json(list);
        }
        [Route("api/Global/GetSrcCurrency")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCurrency([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Currency> list = new List<SearchModel.Currency>();
            list = cls.ReksaSrcCurrency(Col1, Col2, Validate);
            return Json(list);
        }
        [Route("api/Global/GetSrcProduct")]
        [HttpGet("{id}")]
        public JsonResult GetSrcProduct([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]int Status)
        {
            List<SearchModel.Product> list = new List<SearchModel.Product>();
            list = cls.ReksaSrcProduct(Col1, Col2, Validate, Status);
            return Json(list);
        }
        [Route("api/Global/GetSrcManInv")]
        [HttpGet("{id}")]
        public JsonResult GetSrcManInv([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.ManInvestasi> list = new List<SearchModel.ManInvestasi>();
            list = cls.ReksaSrcManInv(Col1, Col2, Validate);
            return Json(list);
        }
        [Route("api/Global/GetSrcOffice")]
        [HttpGet("{id}")]
        public JsonResult GetSrcOffice([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Office> list = new List<SearchModel.Office>();
            list = cls.ReksaSrcOffice(Col1, Col2, Validate);
            return Json(list);
        }
        [Route("api/Global/GetSrcReferentor")]
        [HttpGet("{id}")]
        public JsonResult GetSrcReferentor([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Referentor> list = new List<SearchModel.Referentor>();
            list = cls.ReksaSrcReferentor(Col1, Col2, Validate);
            return Json(list);
        }

        [Route("api/Global/GetSrcSwitching")]
        [HttpGet("{id}")]
        public JsonResult GetSrcSwitching([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string Criteria)
        {
            List<SearchModel.Switching> list = new List<SearchModel.Switching>();
            list = cls.ReksaSrcSwitching(Col1, Col2, Validate, Criteria);
            return Json(list);
        }
        [Route("api/Global/GetSrcSwitchingRDB")]
        [HttpGet("{id}")]
        public JsonResult GetSrcSwitchingRDB([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string Criteria)
        {
            List<SearchModel.Switching> list = new List<SearchModel.Switching>();
            list = cls.ReksaSrcSwitchingRDB(Col1, Col2, Validate, Criteria);
            return Json(list);
        }
        [Route("api/Global/GetSrcClientSwitchIn")]
        [HttpGet("{id}")]
        public JsonResult GetSrcClientSwitchIn([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string Criteria)
        {
            List<SearchModel.ClientSwitchIn> list = new List<SearchModel.ClientSwitchIn>();
            list = cls.ReksaSrcClientSwitchIn(Col1, Col2, Validate, Criteria);
            return Json(list);
        }        
        [Route("api/Global/GetSrcTrxClientNew")]
        [HttpGet("{id}")]
        public JsonResult GetSrcTrxClientNew([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string Criteria)
        {
            List<SearchModel.TransaksiClientNew> list = new List<SearchModel.TransaksiClientNew>();
            list = cls.ReksaSrcTrxClientNew(Col1, Col2, Validate, Criteria);
            return Json(list);
        }
        [Route("api/Global/GetSrcTransaksiRefID")]
        [HttpGet("{id}")]
        public JsonResult GetSrcTransaksiRefID([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string Criteria)
        {
            List<SearchModel.TransaksiRefID> list = new List<SearchModel.TransaksiRefID>();
            list = cls.ReksaSrcTransaksiRefID(Col1, Col2, Validate, Criteria);
            return Json(list);
        }
        [Route("api/Global/GetSrcTrxProduct")]
        [HttpGet("{id}")]
        public JsonResult GetSrcTrxProduct([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string JenisTrx)
        {
            List<SearchModel.TransaksiProduct> list = new List<SearchModel.TransaksiProduct>();
            list = cls.ReksaSrcTrxProduct(Col1, Col2, Validate, JenisTrx);
            return Json(list);
        }
        [Route("api/Global/GetSrcTransSwitchIn")]
        [HttpGet("{id}")]
        public JsonResult GetSrcTransSwitchIn([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string ProdCode)
        {
            List<SearchModel.TransaksiProduct> list = new List<SearchModel.TransaksiProduct>();
            list = cls.ReksaSrcTransSwitchIn(Col1, Col2, Validate, ProdCode);
            return Json(list);
        }
        [Route("api/Global/GetSrcTransSwitchOut")]
        [HttpGet("{id}")]
        public JsonResult GetSrcTransSwitchOut([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.TransaksiProduct> list = new List<SearchModel.TransaksiProduct>();
            list = cls.ReksaSrcTransSwitchOut(Col1, Col2, Validate);
            return Json(list);
        }
        [Route("api/Global/GetSrcType")]
        [HttpGet("{id}")]
        public JsonResult GetSrcType([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.TypeReksadana> list = new List<SearchModel.TypeReksadana>();
            list = cls.ReksaSrcType(Col1, Col2, Validate);
            return Json(list);
        }
        [Route("api/Global/GetSrcWaperd")]
        [HttpGet("{id}")]
        public JsonResult GetSrcWaperd([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Waperd> list = new List<SearchModel.Waperd>();
            list = cls.ReksaSrcWaperd(Col1, Col2, Validate);
            return Json(list);
        }
        [Route("api/Global/GetMenuReportRDN")]
        [HttpGet("{id}")]
        public JsonResult GetMenuReportRDN()
        {
            bool blnResult;
            string ErrMsg;
            List<ReportMenuModel> listMenu = new List<ReportMenuModel>();
            blnResult = cls.ReksaGetMenuReportRDN(out listMenu, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetMenuReportRDN - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listMenu });
        }
    }
}
