using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using Reksa.Models;
using Kendo.Mvc.UI;
using Kendo.Mvc.Extensions;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json.Linq;

namespace Reksa.Controllers
{
    public class GlobalController : Controller
    {
        private IConfiguration _config;
        private string _strAPIUrl;
        public GlobalController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl =  _config.GetValue<string>("APIServices:url");
        }

        public ActionResult AlasanDelete()
        {
   
            return View();
        }

        public ActionResult Document(bool IsEdit, int TranId, bool IsSwitching, bool IsBooking, string RefID)
        {
            ViewBag.IsEdit = IsEdit;
            ViewBag.TranId = TranId;
            ViewBag.IsSwitching = IsSwitching;
            ViewBag.IsBooking = IsBooking;
            ViewBag.RefID = RefID;
            return View();
        }

        public ActionResult PopulateVerifyDocuments([DataSourceRequest]DataSourceRequest request, bool IsEdit, int TranId, bool IsSwitching, bool IsBooking, string RefID)
        {
            int total = 0;
            List<DocumentModel> list = new List<DocumentModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Transaction/PopulateVerifyDocuments?TranId=" + TranId + "&IsEdit=" + IsEdit + "&IsSwitching=" + IsSwitching + "&IsBooking=" + IsBooking + "&strRefID=" + RefID).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<DocumentModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        
        public ActionResult SearchBooking(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchBookingData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<BookingModel> list = new List<BookingModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcBooking?Col1=" + search + "&Col2=&Validate=0&Criteria=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<BookingModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }

        public ActionResult SearchBank(string search, string criteria, int ProdId)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            ViewBag.ProdId = ProdId;
            return View();
        }
        public ActionResult SearchBankData([DataSourceRequest]DataSourceRequest request, string search, int ProdId)
        {
            int total = 0;
            List<BankModel> list = new List<BankModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcBank?Col1=" + search + "&Col2=&Validate=0&ProdId=" + ProdId).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<BankModel>>(stringData);
            }
            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }
            return Json(result);
        }
        public ActionResult SearchBankCode(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchBankCodeData([DataSourceRequest]DataSourceRequest request, string search)
        {
            int total = 0;
            List<BankCodeModel> list = new List<BankCodeModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcBankCode?Col1=" + search + "&Col2=&Validate=0").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<BankCodeModel>>(stringData);
            }
            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;
                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }
            return Json(result);
        }
        public ActionResult SearchTrxClient(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            return View();
        }
        public ActionResult SearchTrxClientSwcOut(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            return View();
        }
        public ActionResult SearchTrxClientData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            var EncodedstrPopulate = System.Net.WebUtility.UrlDecode(criteria);
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<TransaksiClientNew> list = new List<TransaksiClientNew>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcTrxClientNew?Col1=" + search + "&Col2=&Validate=0&Criteria=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<TransaksiClientNew>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }

        public ActionResult SearchClientSwcIn(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            return View();
        }

        public ActionResult SearchClientSwcInData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            var EncodedstrPopulate = System.Net.WebUtility.UrlDecode(criteria);
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<ClientSwitchIn> list = new List<ClientSwitchIn>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcClientSwitchIn?Col1=" + search + "&Col2=&Validate=0&Criteria=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ClientSwitchIn>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }
            return Json(result);
        }

        public ActionResult SearchTrxProduct(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            return View();
        }  
        public ActionResult SearchTrxProductData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            var EncodedstrPopulate = System.Net.WebUtility.UrlDecode(criteria);
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<TransaksiProduct> list = new List<TransaksiProduct>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcTrxProduct?Col1=" + search + "&Col2=&Validate=0&JenisTrx=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<TransaksiProduct>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult SearchTrxProductSwcIn(string search, string criteria, bool isRDB)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            ViewBag.isRDB = isRDB;
            return View();
        }
        public ActionResult SearchTransSwitchInData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            var EncodedstrPopulate = System.Net.WebUtility.UrlDecode(criteria);
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<TransaksiProduct> list = new List<TransaksiProduct>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcTransSwitchIn?Col1=" + search + "&Col2=&Validate=0&ProdCode=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<TransaksiProduct>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult SearchTransSwitchOutData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            var EncodedstrPopulate = System.Net.WebUtility.UrlDecode(criteria);
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<TransaksiProduct> list = new List<TransaksiProduct>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcTransSwitchOut?Col1=" + search + "&Col2=&Validate=0").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<TransaksiProduct>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult ValidateBooking(string Col1, string Col2, int Validate, string criteria)
        {
            List<SwitchingModel> list = new List<SwitchingModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcBooking?Col1=" + Col1 + "&Col2=" + Col2 + "&Validate=" + Validate + "&Criteria=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<SwitchingModel>>(stringData);
            }
            return Json(list);
        }
        public ActionResult SearchCalcDev(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchCalcDevData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            string ErrMsg;
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<CalcDevident> list = new List<CalcDevident>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCalcDevident?Col1=&Col2=" + search + "&Validate=0").Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<CalcDevident>>(stringData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }
            return Json(result);

        }
        public ActionResult ValidateCalcDev(string Col1, string Col2, int Validate, string criteria)
        {
            List<CalcDevident> list = new List<CalcDevident>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCalcDevident?Col1=" + Col1 + "&Col2=" + Col2 + "&Validate=" + Validate + "&Criteria=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<CalcDevident>>(stringData);
            }
            return Json(list);
        }
        public ActionResult SearchCIF(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchCIFData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            string ErrMsg;
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<CustomerModel> list = new List<CustomerModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCIF?Col1=&Col2=" + search + "&Validate=0").Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<CustomerModel>>(stringData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }
            return Json(result);
        }
        public ActionResult SearchCIFAll(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchCIFAllData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            string ErrMsg;
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<CustomerModel> list = new List<CustomerModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCIFAll?Col1=&Col2=" + search + "&Validate=0").Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<CustomerModel>>(stringData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }
            return Json(result);

        }

        public ActionResult SearchClient(string search, string criteria, string ProdId)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            ViewBag.ProdId = ProdId;
            return View();
        }
        public ActionResult SearchClientData([DataSourceRequest]DataSourceRequest request, string search, string criteria, string ProdId)
        {
            int pageNum = request.Page;
            int pageSize = request.PageSize;

            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }

            int total = 0;
            List<ClientModel> list = new List<ClientModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcClient?Col1=&Col2=" + search + "&Validate=0&ProdId=" + ProdId).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ClientModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult ValidateClient(string Col1, string Col2, int Validate, int ProdId)
        {
            if (Col1 == null)
                Col1 = "";
            List<ClientModel> list = new List<ClientModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcClient?Col1="+ Col1.Trim() + "&Col2="+ Col2 + "&Validate="+ Validate + "&ProdId=" + ProdId).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ClientModel>>(stringData);
            }
            return Json(list);
        }

        public ActionResult SearchClientbyCIF(string search, string criteria, string CIFNo)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            ViewBag.CIFNo = CIFNo;
            return View();
        }
        public ActionResult SearchClientbyCIFData([DataSourceRequest]DataSourceRequest request, string search, string criteria, string CIFNo)
        {
            int pageNum = request.Page;
            int pageSize = request.PageSize;

            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }

            int total = 0;
            List<ClientModel> list = new List<ClientModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("api/Global/GetSrcClientbyCIF?Col1=&Col2=" + search + "&Validate=0&CIFNo=" + CIFNo).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ClientModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }
            return Json(result);
        }


        public ActionResult SearchCurrency(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchCurrencyData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<CurrencyModel> list = new List<CurrencyModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCurrency?Col1=" + search + "&Col2=&Validate=0").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<CurrencyModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult ValidateCurrency(string Col1, string Col2, int Validate)
        {
            List<CurrencyModel> list = new List<CurrencyModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCurrency?Col1=" + Col1 + "&Col2="+ Col2 +"&Validate=" + Validate).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<CurrencyModel>>(stringData);
            }
            return Json(list);
        }
        public ActionResult SearchCustody(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchCustodyData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            string ErrMsg;
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<SearchCustody> list = new List<SearchCustody>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCustody?Col1=&Col2=" + search + "&Validate=0").Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<SearchCustody>>(stringData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;
                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }
            return Json(result);
        }
        public ActionResult ValidateCustody(string Col1, string Col2, int Validate)
        {
            List<SearchCustody> list = new List<SearchCustody>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCustody?Col1=" + Col1 + "&Col2=" + Col2 + "&Validate=" + Validate).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<SearchCustody>>(stringData);
            }
            return Json(list);
        }
        public ActionResult SearchCustomer(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }        
        public ActionResult SearchCustomerData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            string ErrMsg;
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<CustomerModel> list = new List<CustomerModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCustomer?Col1=&Col2=" + search + "&Validate=0").Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<CustomerModel>>(stringData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }

            DataSourceResult result = null;
                if (list != null)
                {
                    request.Filters = null;

                    result = list.ToDataSourceResult(request);
                    result.Total = total;
                    result.Data = list;
                }
                return Json(result);                      
        }
        public ActionResult ValidateCustomer(string Col1, string Col2, int Validate)
        {
            string ErrMsg;
            List<CustomerModel> list = new List<CustomerModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCustomer?Col1=" + Col1 + "&Col2="+ Col2 + "&Validate="+ Validate).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<CustomerModel>>(stringData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(list);
        }
        public ActionResult SearchEmployee(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchGift(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchGiftData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            int pageNum = request.Page;
            int pageSize = request.PageSize;

            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }

            int total = 0;
            List<Gift> list = new List<Gift>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcGift?Col1=" + search + "&Col2=&Validate=0&Criteria=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<Gift>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }

        public ActionResult SearchKota(string search, string criteria, string type, int seq = 0)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            ViewBag.Seq = seq;
            ViewBag.Type = type;

            return View();
        }
        public ActionResult SearchKotaData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            int pageNum = request.Page;
            int pageSize = request.PageSize;

            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }

            int total = 0;
            List<CityModel> list = new List<CityModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCity?Col1=" + search + "&Col2=&Validate=0").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<CityModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult SearchOffice(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            
            return View();
        }
        public ActionResult SearchOfficeData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<OfficeModel> list = new List<OfficeModel>();
            using (HttpClient client = new HttpClient())
            {
                try
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcOffice?Col1=" + search + "&Col2=&Validate=0").Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<OfficeModel>>(stringData);
                }
                catch (Exception e)
                {
                    string strmessage = e.ToString();
                }
            }
    
            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult ValidateOffice(string Col1, string Col2, int Validate)
        {
            List<OfficeModel> list = new List<OfficeModel>();
            using (HttpClient client = new HttpClient())
            {
                try
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcOffice?Col1="+ Col1 +"&Col2="+ Col2 +"&Validate="+ Validate).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<OfficeModel>>(stringData);
                }
                catch (Exception e)
                {
                    string strmessage = e.ToString();
                }
            }
            return Json(list);
        }
        public ActionResult SearchProduct(string search, string criteria, string type, int seq = 0)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            ViewBag.Seq = seq;
            ViewBag.Type = type;

            return View();
        }
        public ActionResult SearchProductSubs(string search, string criteria, string type, int seq = 0)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            ViewBag.Seq = seq;
            ViewBag.Type = type;

            return View();
        }
        public ActionResult SearchProductData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            int pageNum = request.Page;
            int pageSize = request.PageSize;

            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }

            int total = 0;
            List<ProductModel> list = new List<ProductModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcProduct?Col1="+ search + "&Col2=&Validate=0&Status=1").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ProductModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public JsonResult ValidateProduct(string Col1, string Col2, int Validate)
        {
            string ErrMsg;
            List<ProductModel> list = new List<ProductModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcProduct?Col1="+ Col1 +"&Col2="+ Col2 +"&Validate=" + Validate + "&Status=1").Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<ProductModel>>(stringData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(list);
        }
        public ActionResult SearchProductSwitchOut(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            return View();
        }
        public ActionResult SearchProductSwitchOutData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            int pageNum = request.Page;
            int pageSize = request.PageSize;

            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }

            int total = 0;
            List<ProductModel> list = new List<ProductModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcProductSwitchOut?Col1=" + search + "&Col2=&Validate=0").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ProductModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult SearchProductSwitchIn(string search, string criteria, string prodcode)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            ViewBag.ProdCode = prodcode;
            return View();
        }
        public ActionResult SearchProductSwitchInData([DataSourceRequest]DataSourceRequest request, string search, string criteria, string prodcode)
        {
            int pageNum = request.Page;
            int pageSize = request.PageSize;

            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }

            int total = 0;
            List<ProductModel> list = new List<ProductModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcProductSwitchIn?Col1=" + search + "&Col2=&Validate=0&ProdCode=" + prodcode).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ProductModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult SearchReferentor(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchSeller(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchReferentorData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<ReferentorModel> list = new List<ReferentorModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcReferentor?Col1=" + search + "&Col2=&Validate=0").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ReferentorModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult ValidateReferentor(string Col1, string Col2, int Validate)
        {
            List<ReferentorModel> list = new List<ReferentorModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcReferentor?Col1="+ Col1 + "&Col2="+ Col2 + "&Validate=" + Validate).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ReferentorModel>>(stringData);
            }
            return Json(list);
        }
        public ActionResult SearchReferensi(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchReferensiData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<ReferensiModel> list = new List<ReferensiModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcTransaksiRefID?Col1=" + search + "&Col2=&Validate=0&Criteria=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<ReferensiModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult SearchSwitching(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchSwitchingData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<SwitchingModel> list = new List<SwitchingModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcSwitching?Col1=" + search + "&Col2=&Validate=0&Criteria=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<SwitchingModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult ValidateSwitching(string Col1, string Col2, int Validate, string criteria)
        {
            List<SwitchingModel> list = new List<SwitchingModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcSwitching?Col1=" + Col1 + "&Col2=" + Col2 + "&Validate=" + Validate + "&Criteria=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<SwitchingModel>>(stringData);
            }
            return Json(list);
        }
        public ActionResult SearchSwitchingRDB(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchSwitchingRDBData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<SwitchingModel> list = new List<SwitchingModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcSwitchingRDB?Col1=" + search + "&Col2=&Validate=0&Criteria=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<SwitchingModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult ValidateSwitchingRDB(string Col1, string Col2, int Validate, string criteria)
        {
            List<SwitchingModel> list = new List<SwitchingModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcSwitchingRDB?Col1=" + Col1 + "&Col2=" + Col2 + "&Validate=" + Validate + "&Criteria=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<SwitchingModel>>(stringData);
            }
            return Json(list);
        }
        public ActionResult SearchWaperd(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchWaperdData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<WaperdModel> list = new List<WaperdModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcWaperd?Col1=" + search + "&Col2=&Validate=0" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<WaperdModel>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult ValidateWaperd(string Col1, string Col2, int Validate)
        {
            List<WaperdModel> list = new List<WaperdModel>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcWaperd?Col1="+ Col1 + "&Col2=" + Col2 + "&Validate=" + Validate).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<WaperdModel>>(stringData);
            }
            return Json(list);
        }
        public JsonResult ValidateOfficeId(string OfficeId)
        {
            string strErrMsg = "";
            bool blnResult = false;
            bool isAllowed = false;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Global/ValidateOfficeId?OfficeId=" + OfficeId).Result;
                    string strResponse = response.Content.ReadAsStringAsync().Result;

                    JObject Object = JObject.Parse(strResponse);
                    JToken TokenResult = Object["blnResult"];
                    JToken TokenErrMsg = Object["ErrMsg"];
                    JToken TokenData = Object["isAllowed"];
                    string JsonResult = JsonConvert.SerializeObject(TokenResult);
                    string JsonErrMsg = JsonConvert.SerializeObject(TokenErrMsg);
                    string JsonData = JsonConvert.SerializeObject(TokenData);

                    blnResult = JsonConvert.DeserializeObject<bool>(JsonResult);
                    strErrMsg = JsonConvert.DeserializeObject<string>(JsonErrMsg);
                    isAllowed = JsonConvert.DeserializeObject<bool>(JsonData);
                }
            }
            catch (Exception e)
            {
                strErrMsg = e.Message;
                return Json(new { blnResult, strErrMsg, isAllowed });
            }
            return Json(new { blnResult, strErrMsg, isAllowed });
        }
        public JsonResult ValidasiCBOKodeKantor(string OfficeId)
        {
            string strErrMsg = "";
            bool blnResult = false;
            string strIsEnable = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Global/ValidateOfficeId?OfficeId=" + OfficeId).Result;
                    string strResponse = response.Content.ReadAsStringAsync().Result;

                    JObject Object = JObject.Parse(strResponse);
                    JToken TokenResult = Object["blnResult"];
                    JToken TokenErrMsg = Object["ErrMsg"];
                    JToken TokenData = Object["IsEnable"];
                    string JsonResult = JsonConvert.SerializeObject(TokenResult);
                    string JsonErrMsg = JsonConvert.SerializeObject(TokenErrMsg);
                    string JsonData = JsonConvert.SerializeObject(TokenData);

                    blnResult = JsonConvert.DeserializeObject<bool>(JsonResult);
                    strErrMsg = JsonConvert.DeserializeObject<string>(JsonErrMsg);
                    strIsEnable = JsonConvert.DeserializeObject<string>(JsonData);
                }
            }
            catch (Exception e)
            {
                strErrMsg = e.Message;
                return Json(new { blnResult, strErrMsg, strIsEnable });
            }
            return Json(new { blnResult, strErrMsg, strIsEnable });
        }

        public JsonResult GetNoNPWPCounter()
        {
            string ErrMsg = "";
            string strNoDocNPWP = "";
            bool blnResult = false;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Global/GetNoNPWPCounter").Result;
                    string strResponse = response.Content.ReadAsStringAsync().Result;

                    JObject Object = JObject.Parse(strResponse);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                    JToken TokenData = Object["strNoDocNPWP"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    strNoDocNPWP = JsonConvert.DeserializeObject<string>(JsonData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg, strNoDocNPWP });
            }
            return Json(new { blnResult, ErrMsg, strNoDocNPWP });
        }
        public ActionResult SearchTypeReksa(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchTypeReksaData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<SearchTypeReksa> list = new List<SearchTypeReksa>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcType?Col1=" + search + "&Col2=&Validate=0").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<SearchTypeReksa>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult ValidateTypeReksa(string Col1, string Col2, int Validate)
        {
            List<SearchTypeReksa> list = new List<SearchTypeReksa>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcType?Col1=" + Col1 + "&Col2=" + Col2 + "&Validate=" + Validate).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<SearchTypeReksa>>(stringData);
            }
            return Json(list);
        }
        public ActionResult SearchManInvestasi(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchManInvestasiData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<SearchManInv> list = new List<SearchManInv>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcManInv?Col1=" + search + "&Col2=&Validate=0").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<SearchManInv>>(stringData);
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;

                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }

            return Json(result);
        }
        public ActionResult ValidateManInv(string Col1, string Col2, int Validate)
        {
            List<SearchManInv> list = new List<SearchManInv>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcManInv?Col1=" + Col1 + "&Col2=" + Col2 + "&Validate=" + Validate).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<SearchManInv>>(stringData);
            }
            return Json(list);
        }

        public JsonResult ValidateReferensi(string Col1, string Col2, int Validate, string criteria)
        {
            string ErrMsg;
            List<ReferensiModel> list = new List<ReferensiModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcTransaksiRefID?Col1=" + Col1 + "&Col2=" + Col2 + "&Validate=1&Criteria=" + criteria).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<ReferensiModel>>(stringData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(list);
        }
        public JsonResult ValidateTrxClient(string Col1, string Col2, int Validate, string criteria)
        {

            if (Col1 == null)
                Col1 = "";
            List<TransaksiClientNew> list = new List<TransaksiClientNew>();
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcTrxClientNew?Col1=" + Col1.Trim() + "&Col2=" + Col2 + "&Validate=" + Validate + "&Criteria=" + criteria).Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<TransaksiClientNew>>(stringData);
            }
            return Json(list);
        }
        public JsonResult ValidateCBOOfficeId(string OfficeId)
        {
            string strErrMsg = "";
            bool blnResult = false;
            bool IsEnable = false;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Global/ValidateCBOOfficeId?OfficeId=" + OfficeId).Result;
                    string strResponse = response.Content.ReadAsStringAsync().Result;

                    JObject Object = JObject.Parse(strResponse);
                    JToken TokenResult = Object["blnResult"];
                    JToken TokenErrMsg = Object["ErrMsg"];
                    JToken TokenData = Object["IsEnable"];
                    string JsonResult = JsonConvert.SerializeObject(TokenResult);
                    string JsonErrMsg = JsonConvert.SerializeObject(TokenErrMsg);
                    string JsonData = JsonConvert.SerializeObject(TokenData);

                    blnResult = JsonConvert.DeserializeObject<bool>(JsonResult);
                    strErrMsg = JsonConvert.DeserializeObject<string>(JsonErrMsg);
                    IsEnable = JsonConvert.DeserializeObject<bool>(JsonData);
                }
            }
            catch (Exception e)
            {
                strErrMsg = e.Message;
            }
            return Json(new { blnResult, strErrMsg, IsEnable });
        }
        public ActionResult SearchCountry(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }
        public ActionResult SearchCountryData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
        {
            string ErrMsg;
            if (request.Filters.Count > 0)
            {
                string type = request.Filters[0].GetType().ToString();
                if (type == "Kendo.Mvc.FilterDescriptor")
                {
                    var filter = (Kendo.Mvc.FilterDescriptor)request.Filters[0];
                    criteria = filter.ConvertedValue.ToString();
                }
            }
            int total = 0;
            List<Country> list = new List<Country>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCountry?Col1=&Col2=" + search + "&Validate=0").Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<Country>>(stringData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }

            DataSourceResult result = null;
            if (list != null)
            {
                request.Filters = null;
                result = list.ToDataSourceResult(request);
                result.Total = total;
                result.Data = list;
            }
            return Json(result);
        }
        public JsonResult ValidateCountry(string Col1, string Col2, int Validate)
        {
            string ErrMsg;
            List<Country> list = new List<Country>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCountry?Col1=" + Col1 + "&Col2=" + Col2 + "&Validate=" + Validate).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<Country>>(stringData);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(list);
        }
    }
}
