using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class MenuMasterService : IMenuMasterService
    {
        public IEnumerable<NavigationModel> GetMenuMaster()
        {
            List<NavigationModel> listMenu = new List<NavigationModel>();
            listMenu = NavBar();
            return listMenu;
        }

        public IEnumerable<NavigationModel> GetMenuMaster(string UserRole)
        {
            List<NavigationModel> listMenu = new List<NavigationModel>();
            listMenu = NavBar();
            return listMenu;
        }
        private IConfiguration AppSetting;
        private List<NavigationModel> NavBar()
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<NavigationModel> listMenu = new List<NavigationModel>();
            try
            {
                AppSetting = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(AppSetting.GetValue<string>("APIServices:url"));
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetMenuReksa").Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken Token = strObject["listMenu"];
                    string Json = JsonConvert.SerializeObject(Token);
                    listMenu = JsonConvert.DeserializeObject<List<NavigationModel>>(Json);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return listMenu;
        }
    }
}
