using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;
using Reksa.ViewModels;
using Reksa.Data;
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
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Global/GetSrcCustomer?Col1=&Col2=&Validate=0").Result;
                string stringData = response.Content.ReadAsStringAsync().Result;
                list = JsonConvert.DeserializeObject<List<CustomerModel>>(stringData);
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

        
    }
}
