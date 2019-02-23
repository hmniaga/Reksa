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
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcBooking?Col1=&Col2=&Validate=0&Criteria=" + criteria).Result;
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


        public ActionResult SearchClient(string search, string criteria, string type, int seq = 0)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;
            ViewBag.Seq = seq;
            ViewBag.Type = type;
            return View();
        }
        public ActionResult SearchClientData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
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
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcClient?Col1=&Col2=&Validate=0&ProdId=51").Result;
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
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCurrency?Col1=&Col2=&Validate=0").Result;
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
        public ActionResult SearchCustomer(string search, string criteria)
        {
            ViewBag.Search = search;
            ViewBag.Criteria = criteria;

            return View();
        }

        public ActionResult SearchCustomerData([DataSourceRequest]DataSourceRequest request, string search, string criteria)
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
            List<CustomerModel> list = new List<CustomerModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCustomer?Col1=&Col2=&Validate=0").Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;
                    list = JsonConvert.DeserializeObject<List<CustomerModel>>(stringData);
                }
            }
            catch (Exception e)
            {

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

            }
            return Json(list);
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
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCity?Col1=&Col2=&Validate=0").Result;
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
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcOffice?Col1=&Col2=&Validate=0").Result;
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
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcProduct?Col1=&Col2=&Validate=0&Status=1").Result;
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

            }
            return Json(list);
        }
        public ActionResult SearchReferentor(string search, string criteria)
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
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcReferentor?Col1=&Col2=&Validate=0").Result;
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
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcTransaksiRefID?Col1=&Col2=&Validate=0&Criteria="+ criteria).Result;
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
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcSwitching?Col1=&Col2=&Validate=0&Criteria=" + criteria).Result;
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
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcSwitchingRDB?Col1=&Col2=&Validate=0&Criteria=" + criteria).Result;
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
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcWaperd?Col1=&Col2=&Validate=0" + criteria).Result;
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


    }
}
