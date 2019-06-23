using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;
using Reksa.ViewModels;
using Reksa.Data;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json;
using System.Data;
using System.Reflection;
using Microsoft.AspNetCore.Http;
using Newtonsoft.Json.Linq;
using Microsoft.AspNetCore.Authorization;

namespace Reksa.Controllers
{
    public class OtorisasiController : Controller
    {
        #region "Default Var"
        public string strModule = "Pro Reksa 2";
        public int _intNIK = 10035;
        public string _strGuid = "77bb8d13-22af-4233-880d-633dfdf16122";
        public string _strMenuName;
        public string _strBranch = "01010";
        public int _intClassificationId;
        private IConfiguration _config;
        private string _strAPIUrl;
        #endregion
        System.Data.DataSet dsTree = new System.Data.DataSet();
        System.Data.DataTable dtSelectedTree = new DataTable();
        private readonly IHttpContextAccessor _httpContextAccessor;
        private ISession _session => _httpContextAccessor.HttpContext.Session;

        public OtorisasiController(IConfiguration iconfig, IHttpContextAccessor httpContextAccessor)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
            _httpContextAccessor = httpContextAccessor;
        }
        [Authorize(Policy = "SPV")]
        public ActionResult AuthRejectBooking()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            return View("AuthRejectBooking", vModel);
        }
        [Authorize(Policy = "SPV")]
        public ActionResult AuthDeleteTransaksi()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            return View("AuthDeleteTransaksi", vModel);
        }
        [Authorize(Policy = "SPV")]
        public ActionResult ParameterFee()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            List<CommonTreeViewModel> listTree = new List<CommonTreeViewModel>();
            listTree = GetCommonTreeView("mnuAuthorizeParamFee");
            var items = new List<CommonTreeViewModel>();
            var root = listTree[0];
            for (int i = 0; i < listTree.Count; i++)
            {
                if (listTree[i].parent_tree == "")
                {
                    root = listTree[i];
                    items.Add(root);
                }
                else
                {
                    root.Children.Add(listTree[i]);
                }
            }
            this.ViewBag.Tree = items;
            return View("AuthParamFee", vModel);
        }
        [Authorize(Policy = "SPV")]
        public ActionResult ParameterFeeDetail()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            return View("AuthParamFeeDetail", vModel);
        }
        [Authorize(Policy = "SPV")]
        public ActionResult ParameterReksaDana()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            List<TreeViewModel> listTree = new List<TreeViewModel>();
            listTree = GetTreeView("mnuAuthorizeParamGlobal");
            var items = new List<TreeViewModel>();
            var root = listTree[0];
            for (int i = 0; i < listTree.Count; i++)
            {
                if (listTree[i].ParentId == "")
                {
                    root = listTree[i];
                    items.Add(root);
                }
                else
                {
                    root.Children.Add(listTree[i]);
                }
            }
            this.ViewBag.Tree = items;
            return View("AuthGlobalParam", vModel);
        }
        [Authorize(Policy = "SPV")]
        public ActionResult Transaksi()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            return View("AuthGeneralNew", vModel);
        }
        [Authorize(Policy = "SPV")]
        public ActionResult WM()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            List<CommonTreeViewModel> listTree = new List<CommonTreeViewModel>();
            listTree = GetCommonTreeView("mnuAuthorizeWM");
            _session.SetString("listTreeJson", JsonConvert.SerializeObject(listTree));
            var items = new List<CommonTreeViewModel>();
            var root = listTree[0];
            for (int i = 0; i < listTree.Count; i++)
            {
                if (listTree[i].parent_tree == "")
                {
                    root = listTree[i];
                    items.Add(root);
                }
                else
                {
                    root.Children.Add(listTree[i]);
                }
            }
            this.ViewBag.Tree = items;
            return View("AuthGeneral", vModel);
        }
        [Authorize(Policy = "SPV")]
        public ActionResult WMSupervisor()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            List<CommonTreeViewModel> listTree = new List<CommonTreeViewModel>();
            listTree = GetCommonTreeView("mnuAuthorizeWMSPV");
            _session.SetString("listTreeJson", JsonConvert.SerializeObject(listTree));
            var items = new List<CommonTreeViewModel>();
            var root = listTree[0];
            for (int i = 0; i < listTree.Count; i++)
            {
                if (listTree[i].parent_tree == "")
                {
                    root = listTree[i];
                    items.Add(root);
                }
                else
                {
                    root.Children.Add(listTree[i]);
                }
            }
            this.ViewBag.Tree = items;
            return View("AuthGeneral", vModel);
        }
        [Authorize(Policy = "SPV")]
        public ActionResult POSupervisor()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            List<CommonTreeViewModel> listTree = new List<CommonTreeViewModel>();
            listTree = GetCommonTreeView("mnuAuthorizePOSPV");
            _session.SetString("listTreeJson", JsonConvert.SerializeObject(listTree));
            var items = new List<CommonTreeViewModel>();
            var root = listTree[0];
            for (int i = 0; i < listTree.Count; i++)
            {
                if (listTree[i].parent_tree == "")
                {
                    root = listTree[i];
                    items.Add(root);
                }
                else
                {
                    root.Children.Add(listTree[i]);
                }
            }
            this.ViewBag.Tree = items;
            return View("AuthGeneral", vModel);
        }
        [Authorize(Policy = "SPV")]
        public ActionResult Bill()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            List<CommonTreeViewModel> listTree = new List<CommonTreeViewModel>();
            listTree = GetCommonTreeView("mnuAuthorizeBill");
            _session.SetString("listTreeJson", JsonConvert.SerializeObject(listTree));
            var items = new List<CommonTreeViewModel>();
            var root = listTree[0];
            for (int i = 0; i < listTree.Count; i++)
            {
                if (listTree[i].parent_tree == "")
                {
                    root = listTree[i];
                    items.Add(root);
                }
                else
                {
                    root.Children.Add(listTree[i]);
                }
            }
            this.ViewBag.Tree = items;
            return View("AuthGeneral", vModel);
        }
        [Authorize(Policy = "SPV")]
        public ActionResult Sinkronisasi()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            List<CommonTreeViewModel> listTree = new List<CommonTreeViewModel>();
            listTree = GetCommonTreeView("mnuAuthorizeBill");
            _session.SetString("listTreeJson", JsonConvert.SerializeObject(listTree));
            var items = new List<CommonTreeViewModel>();
            var root = listTree[0];
            for (int i = 0; i < listTree.Count; i++)
            {
                if (listTree[i].parent_tree == "")
                {
                    root = listTree[i];
                    items.Add(root);
                }
                else
                {
                    root.Children.Add(listTree[i]);
                }
            }
            this.ViewBag.Tree = items;
            return View("AuthSync", vModel);
        }
        [Authorize(Policy = "SPV")]
        public ActionResult NFS()
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();

            return View("AuthNFSGenerateFileUpload", vModel);
        }
        public JsonResult PopulateVerifyGlobalParam(string InterfaceId)
        {
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            List<OtorisasiModel.AuthParamGlobal> list = new List<OtorisasiModel.AuthParamGlobal>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Parameter/PopulateVerifyGlobalParam?ProdId=&InterfaceId=" + InterfaceId + "&NIK=" + _intNIK).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                DataSet dsResult = JsonConvert.DeserializeObject<DataSet>(stringData);
                _session.SetString("dsPopulateParamGlobal", JsonConvert.SerializeObject(dsResult));
                List<OtorisasiModel.AuthParamGlobal> result = this.MapListOfObject<OtorisasiModel.AuthParamGlobal>(dsResult.Tables[0]);
                list.AddRange(result);
                vModel.AuthParamGlobal = list;
            }
            return Json(vModel);
        }
        public JsonResult AuthorizeGlobalParam(string listId, string InterfaceId, bool isApprove)
        {
            bool blnResult = false;
            string ErrMsg = "";
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            try
            {
                string[] _SelectedId;
                listId = (listId + "***").Replace("|***", "");
                _SelectedId = listId.Split('|');

                var sessionDataset = _session.GetString("dsPopulateParamGlobal");
                DataSet dsSelected = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                DataView dv1 = dsSelected.Tables[0].DefaultView;
                var filter = string.Join(',', _SelectedId);
                dv1.RowFilter = " Id in (" + filter + ")";
                DataTable dtNew = dv1.ToTable();
                if (dtNew == null || dtNew.Columns.Count == 0)
                {
                    ErrMsg = "No data to save!";
                    return Json(new { blnResult, ErrMsg });
                }
                blnResult = subApproveParamGlobal(dtNew, InterfaceId, isApprove, out ErrMsg);
            }
            catch
            {
                ErrMsg = "Approve data failed!";
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        private bool subApproveParamGlobal(DataTable dtData, string InterfaceId, bool isApprove, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(dtData));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Otorisasi/AuthorizeGlobalParam?InterfaceId=" + InterfaceId + "&isApprove=" + isApprove + "&NIK=" + _intNIK + "&GUID=" + _strGuid, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return blnResult;
        }
        
        public JsonResult ApproveReject(string listId, string treeid, bool isApprove)
        {
            bool blnResult = false;
            string ErrMsg = "";
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            try
            {
                var sessionTree = _session.GetString("listTreeJson");
                List<CommonTreeViewModel> ListTree = JsonConvert.DeserializeObject<List<CommonTreeViewModel>>(sessionTree);
                ListTree = ListTree.Where(x => treeid.Contains(x.tree_id)).ToList();

                if (ListTree == null || ListTree.Count == 0)
                {
                    ErrMsg = "No query to save!";
                    return Json(new { blnResult, ErrMsg });
                }
                string strQueryApprove = ListTree[0].button1_query.ToString();
                string strQueryReject = ListTree[0].button2_query.ToString();
                string strQuery = "";
                if (isApprove)
                    strQuery = strQueryApprove;
                else
                    strQuery = strQueryReject;

                string[] _SelectedId;
                listId = (listId + "***").Replace("|***", "");
                _SelectedId = listId.Split('|');

                var sessionDataset = _session.GetString("DataSetJson");
                DataSet dsSelected = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                DataView dv1 = dsSelected.Tables[0].DefaultView;
                var filter = string.Join(',', _SelectedId);
                if (treeid == "REKWM1")
                {
                    dv1.RowFilter = " tranId in (" + filter + ")";
                }
                else if (treeid == "REKWM2")
                {
                    dv1.RowFilter = " prodId in (" + filter + ")";
                }
                else if (treeid == "REKBI1" || treeid == "REKBI4" || treeid == "REKBI8")
                {
                    dv1.RowFilter = " billId in (" + filter + ")";
                }
                else if (treeid == "REKPO4" || treeid == "REKWS3")
                {
                    dv1.RowFilter = " id in (" + filter + ")";
                }
                DataTable dtNew = dv1.ToTable();
                if (dtNew == null || dtNew.Columns.Count == 0)
                {
                    ErrMsg = "No data to save!";
                    return Json(new { blnResult, ErrMsg });
                }
                blnResult = subApproveReject(strQuery, dtNew, treeid, isApprove, out ErrMsg);                
            }
            catch(Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg } );
        }
        private bool subApproveReject(string strPopulate, DataTable dtData, string treeid, bool isApprove, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            try
            {
                var EncodedstrPopulate = System.Net.WebUtility.UrlEncode(strPopulate);
                var Content = new StringContent(JsonConvert.SerializeObject(dtData));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Otorisasi/ApproveReject?strPopulate=" + EncodedstrPopulate + "&treeid=" + treeid + "&isApprove=" + isApprove + "&NIK=" + _intNIK + "&GUID=" + _strGuid, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return blnResult;
        }
        public JsonResult PopulateGridMain(string treename, string strPopulate, string SelectedId)
        {
            bool blnResult = false;
            string ErrMsg = "";

            DataSet dsResult = new DataSet();
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            var EncodedstrPopulate = System.Net.WebUtility.UrlEncode(strPopulate);
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GlobalQuery?strPopulate=" + EncodedstrPopulate + "&SelectedId=" + SelectedId + "&NIK=" + _intNIK + "&GUID=" + _strGuid).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(stringData);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();

                    JToken TokenData = Object["dsResult"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    dsResult = JsonConvert.DeserializeObject<DataSet>(JsonData);
                    _session.SetString("DataSetJson", JsonConvert.SerializeObject(dsResult));
                    if (dsResult.Tables.Count == 0)
                    {
                        blnResult = false;
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch(Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg, dsResult });
            }
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        public JsonResult PopulateVerifyAuthBS(string Authorization, string TypeTrx, string strAction, string NoReferensi)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();
            OtorisasiListViewModel vModel = new OtorisasiListViewModel();
            List<OtorisasiModel.AuthTransaction> list = new List<OtorisasiModel.AuthTransaction>();
            List<OtorisasiModel.AuthTransactionDetail> list1 = new List<OtorisasiModel.AuthTransactionDetail>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Otorisasi/PopulateVerifyAuthBS?Authorization=" + Authorization + "&TypeTrx=" + TypeTrx + "&Action=" + strAction + "&NoReferensi=" + NoReferensi + "&NIK=" + _intNIK).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(stringData);
                blnResult = strObject.SelectToken("blnResult").Value<bool>();
                ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                JToken TokenData = strObject["dsOut"];
                string JsonData = JsonConvert.SerializeObject(TokenData);
                dsResult = JsonConvert.DeserializeObject<DataSet>(JsonData);

                _session.SetString("dsVerifyGlobalParam", JsonConvert.SerializeObject(dsResult));
                //List<OtorisasiModel.AuthTransaction> result = this.MapListOfObject<OtorisasiModel.AuthTransaction>(dsResult.Tables[0]);
                //List<OtorisasiModel.AuthTransactionDetail> result1 = this.MapListOfObject<OtorisasiModel.AuthTransactionDetail>(dsResult.Tables[1]);
                //list.AddRange(result);
                //list1.AddRange(result1);
                //vModel.AuthTransaction = list;
            }
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        public ActionResult AuthorizeNasabah(string listNasabahId, bool isApprove)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(""));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Otorisasi/AuthorizeNasabah?listNasabahId=" + listNasabahId + "&isApprove=" + isApprove + "&NIK=" + _intNIK, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        public ActionResult AuthorizeBlocking(string listBlockId, bool isApprove)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(""));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Otorisasi/AuthorizeBlocking?listBlockId=" + listBlockId + "&isApprove=" + isApprove + "&NIK=" + _intNIK, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        public ActionResult AuthorizeTranReversal(string listTranId, bool isApprove)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(""));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Otorisasi/AuthorizeTranReversal?listTranId=" + listTranId + "&isApprove=" + isApprove + "&NIK=" + _intNIK, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        public ActionResult AuthorizeSwcReversal(string listTranId, bool isApprove)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(""));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Otorisasi/AuthorizeSwcReversal?listTranId=" + listTranId + "&isApprove=" + isApprove + "&NIK=" + _intNIK, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        public ActionResult CekUmurNasabah(string SelectedId, string TreeId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(""));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Otorisasi/CekUmurNasabah?SelectedId=" + SelectedId + "&TreeId=" + TreeId, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        public ActionResult CekRiskProfile(string SelectedId, string TreeId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(""));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Otorisasi/CekRiskProfile?SelectedId=" + SelectedId + "&TreeId=" + TreeId, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        public ActionResult CekTieringNotification(string SelectedId, string TreeId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(""));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Otorisasi/CekTieringNotification?SelectedId=" + SelectedId + "&TreeId=" + TreeId, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        public ActionResult AuthorizeTransaction_BS(string listTranId, bool isApprove)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(""));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Otorisasi/AuthorizeTransaction_BS?listTranId=" + listTranId + "&isApprove=" + isApprove + "&NIK=" + _intNIK, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        public ActionResult AuthorizeSwitching_BS(string listTranId, bool isApprove)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(""));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Otorisasi/AuthorizeSwitching_BS?listTranId=" + listTranId + "&isApprove=" + isApprove + "&NIK=" + _intNIK, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        public ActionResult AuthorizeBooking(string listBookingId, bool isApprove)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                var Content = new StringContent(JsonConvert.SerializeObject(""));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Otorisasi/AuthorizeBooking?listBookingId=" + listBookingId + "&isApprove=" + isApprove + "&NIK=" + _intNIK, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        private List<TreeViewModel> GetTreeView(string strMenuName)
        {
            List<TreeViewModel> list = new List<TreeViewModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetTreeView?NIK=" + _intNIK + "&Module=" + strModule + "&MenuName=" + strMenuName).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<TreeViewModel>>(stringData);
            }
            return list;
        }
        private List<CommonTreeViewModel> GetCommonTreeView(string strMenuName)
        {
            List<CommonTreeViewModel> list = new List<CommonTreeViewModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetCommonTreeView?NIK=" + _intNIK + "&Module=" + strModule + "&MenuName=" + strMenuName).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<CommonTreeViewModel>>(stringData);
            }
            return list;
        }
        public List<T> MapListOfObject<T>(DataTable dt)
        {
            List<T> list = new List<T>();
            if ((dt == null) || (dt.Rows.Count == 0))
            {
                //list = default(List<T>);
            }
            else
            {

                List<PropertyInfo> fields = new List<PropertyInfo>();
                fields.AddRange(typeof(T).GetProperties());

                for (int i = fields.Count - 1; i >= 0; i--)
                {
                    if (!dt.Columns.Contains(fields[i].Name))
                    {
                        fields.RemoveAt(i);
                    }
                }

                foreach (DataRow dr in dt.Rows)
                {
                    T t = Activator.CreateInstance<T>();
                    foreach (PropertyInfo fi in fields)
                    {
                        try
                        {
                            string propertyTypeName = fi.PropertyType.Name;
                            string propertyTypeFullName = fi.PropertyType.FullName;
                            if (!(dr[fi.Name].ToString() == "" && propertyTypeName == "Int32"))
                            {
                                if (propertyTypeName == "Boolean")
                                {
                                    string strValue = dr[fi.Name].ToString().Trim().ToLower();
                                    bool bValue = strValue != "" && strValue != "false" && strValue != "0";
                                    fi.SetValue(t, bValue);
                                }
                                else if (propertyTypeName == "Nullable`1" && propertyTypeFullName.Contains("System.DateTime"))
                                {
                                    DateTime? dtValue = null;
                                    DateTime dtTemp;
                                    if (dr[fi.Name] != null && DateTime.TryParse(dr[fi.Name].ToString(), out dtTemp))
                                    {
                                        dtValue = dtTemp;
                                    }

                                    fi.SetValue(t, dtValue);
                                }
                                else
                                {
                                    object objectValue = System.Convert.ChangeType(dr[fi.Name], fi.PropertyType);
                                    fi.SetValue(t, objectValue, null);
                                }
                            }
                        }
                        catch
                        {
                        }
                    }

                    list.Add(t);
                }
            }
            return list;
        }
        public JsonResult NFSFileCekPendingOtorisasi(string TypeGet, int LogId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Otorisasi/NFSFileCekPendingOtorisasi?TypeGet=" + TypeGet + "&LogId=" + LogId).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenData = strObject["dsResult"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    dsResult = JsonConvert.DeserializeObject<DataSet>(JsonData);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        public JsonResult NFSCekPendingDetailOtorisasi(int CIFNo, int LogId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();

            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Otorisasi/NFSCekPendingDetailOtorisasi?CIFNo=" + CIFNo + "&LogId=" + LogId).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenData = strObject["dsResult"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    dsResult = JsonConvert.DeserializeObject<DataSet>(JsonData);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        public JsonResult UpdateFlagApprovalNFSGenerate(string Type, int LogId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Otorisasi/UpdateFlagApprovalNFSGenerate?Type=" + Type + "&LogId=" + LogId + "&NIK=" + _intNIK).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg });
        }
    }
}
