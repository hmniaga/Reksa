using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using Reksa.Models;
using Reksa.ViewModels;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Data;
using System.IO;
using Rotativa.AspNetCore;
using System.Text;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Hosting;
using NPOI.SS.UserModel;
using NPOI.XSSF.UserModel;
using System.Threading.Tasks;
using NPOI.HSSF.UserModel;
using System.Reflection;
using Microsoft.AspNetCore.Authorization;

namespace Reksa.Controllers
{
    //[Route("api/[controller]")]
    //[ApiController]
    public class ReportController : Controller
    {
        #region "Default Var"
        public string strModule = "Pro Reksa 2";
        public int _intNIK = 10137;
        public string _strGuid = "77bb8d13-22af-4233-880d-633dfdf16122";
        public string _strMenuName;
        public string _strBranch = "01010";
        public int _intClassificationId;
        private IConfiguration _config;
        private string _strAPIUrl;
        #endregion

        private string sRealFileName;
        private string result;
        private clsCSVFormat csv;
        private string sSeparator = "", sFileName = "", sFormatFile = "", sFilterFile = "", sFieldKey = "";
        string sXMLData;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private ISession _session => _httpContextAccessor.HttpContext.Session;
        private IHostingEnvironment _hostingEnvironment;
        IFont font;
        
        public ReportController(IConfiguration iconfig, IHttpContextAccessor httpContextAccessor, IHostingEnvironment hostingEnvironment)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
            _httpContextAccessor = httpContextAccessor;
            _hostingEnvironment = hostingEnvironment;
        }
        [Authorize]
        public IActionResult ReportReksaDana()
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ReportMenuModel> listMenu = new List<ReportMenuModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Global/GetMenuReportRDN").Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken Token = strObject["listMenu"];
                    string Json = JsonConvert.SerializeObject(Token);
                    listMenu = JsonConvert.DeserializeObject<List<ReportMenuModel>>(Json);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return View(listMenu);
        }
        public IActionResult RDN07View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN07View");
        }        
        public IActionResult RDN08View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN08View");
        }
        public IActionResult RDN09View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN09View");
        }
        public IActionResult RDN10View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN10View");
        }
        public IActionResult RDN11View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN11View");
        }
        public IActionResult RDN12View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN12View");
        }
        public IActionResult RDN13View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN13View");
        }
        public IActionResult RDN14View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN14View");
        }
        public IActionResult RDN15View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN15View");
        }
        public IActionResult RDN16View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN16View");
        }
        public IActionResult RDN17View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN17View");
        }
        public IActionResult RDN18View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN18View");
        }
        public IActionResult RDN19View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN19View");
        }
        public IActionResult RDN20View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN20View");
        }
        public IActionResult RDN21View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN21View");
        }
        public IActionResult RDN22View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN22View");
        }
        public IActionResult RDN23View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN23View");
        }
        public IActionResult RDN24View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN24View");
        }
        public IActionResult RDN25View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN25View");
        }
        public IActionResult RDN26View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN26View");
        }
        public IActionResult RDN27View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN27View");
        }
        public IActionResult RDN28View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN28View");
        }
        public IActionResult RDN29View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN29View");
        }
        public IActionResult RDN30View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN30View");
        }
        public IActionResult RDN31View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN31View");
        }
        public IActionResult RDN32View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN32View");
        }
        public IActionResult RDN33View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN33View");
        }
        public IActionResult RDN34View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN34View");
        }
        public IActionResult RDN35View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN35View");
        }
        public IActionResult RDN36View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN36View");
        }
        public IActionResult RDN37View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN37View");
        }
        public IActionResult RDN38View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN38View");
        }
        public IActionResult RDN39View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN39View");
        }
        public IActionResult RDN40View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN40View");
        }
        public IActionResult RDN41View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN41View");
        }
        public IActionResult RDN42View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN42View");
        }
        public IActionResult RDN43View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN43View");
        }
        public IActionResult RDN44View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN44View");
        }
        public IActionResult RDN45View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN45View");
        }
        public IActionResult RDN46View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN46View");
        }
        public IActionResult RDN47View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN47View");
        }
        public IActionResult RDN48View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN48View");
        }
        public IActionResult RDN49View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN49View");
        }
        public IActionResult RDN50View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN50View");
        }
        public IActionResult RDN51View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN51View");
        }
        public IActionResult RDN52View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN52View");
        }
        public IActionResult RDN53View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN53View");
        }
        public IActionResult RDN54View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN54View");
        }
        public IActionResult RDN55View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN55View");
        }
        public IActionResult RDN56View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN56View");
        }
        public IActionResult RDN57View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN57View");
        }
        public IActionResult RDN58View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN58View");
        }
        public IActionResult RDN59View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN59View");
        }
        public IActionResult RDN60View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN60View");
        }
        public IActionResult RDN61View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN61View");
        }
        public IActionResult RDN62View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN62View");
        }
        public IActionResult RDN63View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN63View");
        }
        public IActionResult RDN64View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN64View");
        }
        public IActionResult RDN65View(string ReportCode, string ReportName)
        {
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;
            return View("_RDN65View");
        }
        public IActionResult ExportPDF(string ReportCode, string ReportName)
        {
            DataSet dsReport = new DataSet();
            Rotativa.AspNetCore.Options.Orientation orientation = new Rotativa.AspNetCore.Options.Orientation();
            switch (ReportCode)
            {
                case "RDN07":
                    {
                        var sessionHeader = _session.GetString("RDN07Header");
                        RDN07Header RDN07Header = JsonConvert.DeserializeObject<RDN07Header>(sessionHeader);
                        ViewData["PeriodStart"] = RDN07Header.PeriodStart;
                        ViewData["PeriodEnd"] = RDN07Header.PeriodEnd;
                        ViewData["CustodyName"] = RDN07Header.CustodyName;
                        orientation = Rotativa.AspNetCore.Options.Orientation.Landscape;
                        break;
                    }
                case "RDN08":
                    {
                        var sessionHeader = _session.GetString("RDN08Header");
                        RDN08Header RDN08Header = JsonConvert.DeserializeObject<RDN08Header>(sessionHeader);
                        ViewData["PeriodStart"] = RDN08Header.PeriodStart;
                        ViewData["PeriodEnd"] = RDN08Header.PeriodEnd;
                        ViewData["Branch"] = RDN08Header.Branch;
                        ViewData["ProdCode"] = RDN08Header.ProdCode;
                        orientation = Rotativa.AspNetCore.Options.Orientation.Landscape;
                        break;
                    }
                case "RDN09":
                    {
                        var sessionHeader = _session.GetString("RDN09Header");
                        RDN09Header RDN09Header = JsonConvert.DeserializeObject<RDN09Header>(sessionHeader);
                        ViewData["TranDate"] = RDN09Header.TranDate;
                        ViewData["ProductCode"] = RDN09Header.ProductCode;
                        ViewData["MataUang"] = RDN09Header.MataUang;
                        ViewData["RegionName"] = RDN09Header.RegionName;
                        orientation = Rotativa.AspNetCore.Options.Orientation.Portrait;
                        break;
                    }
                case "RDN10":
                    {
                        var sessionHeader = _session.GetString("RDN10Header");
                        RDN10Header RDN10Header = JsonConvert.DeserializeObject<RDN10Header>(sessionHeader);
                        ViewData["PeriodStart"] = RDN10Header.PeriodStart;
                        ViewData["PeriodEnd"] = RDN10Header.PeriodEnd;
                        ViewData["Branch"] = RDN10Header.Branch;
                        ViewData["ProdCode"] = RDN10Header.ProdCode;
                        orientation = Rotativa.AspNetCore.Options.Orientation.Portrait;
                        break;
                    }
                case "RDN11":
                    {
                        var sessionHeader = _session.GetString("RDN11Header");
                        RDN11Header RDN11Header = JsonConvert.DeserializeObject<RDN11Header>(sessionHeader);
                        ViewData["TranDate"] = RDN11Header.TranDate;
                        ViewData["ProductCode"] = RDN11Header.ProductCode;
                        ViewData["MataUang"] = RDN11Header.MataUang;
                        ViewData["RegionName"] = RDN11Header.RegionName;
                        orientation = Rotativa.AspNetCore.Options.Orientation.Portrait;
                        break;
                    }
                case "RDN12":
                    {
                        var sessionHeader = _session.GetString("RDN12Header");
                        RDN12Header RDN12Header = JsonConvert.DeserializeObject<RDN12Header>(sessionHeader);
                        ViewData["Period"] = RDN12Header.Period;
                        ViewData["ProductCode"] = RDN12Header.ProductCode;
                        ViewData["MataUang"] = RDN12Header.MataUang;
                        ViewData["RegionName"] = RDN12Header.RegionName;
                        orientation = Rotativa.AspNetCore.Options.Orientation.Landscape;
                        break;
                    }
                case "RDN13":
                    {
                        var sessionHeader = _session.GetString("RDN13Header");
                        RDN13Header RDN13Header = JsonConvert.DeserializeObject<RDN13Header>(sessionHeader);
                        ViewData["PeriodStart"] = RDN13Header.PeriodStart;
                        ViewData["PeriodEnd"] = RDN13Header.PeriodEnd;
                        ViewData["ProdCode"] = RDN13Header.ProdCode;
                        ViewData["MataUang"] = RDN13Header.MataUang;
                        ViewData["TipeProduk"] = RDN13Header.TipeProduk;
                        orientation = Rotativa.AspNetCore.Options.Orientation.Portrait;
                        break;
                    }
                case "RDN14":
                    {
                        break;
                    }
                case "RDN15":
                    {
                        break;
                    }
                case "RDN16":
                    {
                        break;
                    }
                case "RDN17":
                    {
                        break;
                    }
                case "RDN18":
                    {
                        break;
                    }
                case "RDN19":
                    {
                        break;
                    }
                case "RDN20":
                    {
                        break;
                    }
                case "RDN21":
                    {
                        break;
                    }
                case "RDN22":
                    {
                        break;
                    }
                case "RDN23":
                    {
                        break;
                    }
                case "RDN24":
                    {
                        orientation = Rotativa.AspNetCore.Options.Orientation.Landscape;
                        break;
                    }
                case "RDN26":
                    {
                        orientation = Rotativa.AspNetCore.Options.Orientation.Landscape;
                        break;
                    }
            }
            ViewData["ReportCode"] = ReportCode;
            ViewData["ReportName"] = ReportName;

            var sessionDataset = _session.GetString(ReportCode);
            dsReport = JsonConvert.DeserializeObject<DataSet>(sessionDataset);

            return new ViewAsPdf("_" + ReportCode, dsReport, ViewData)
            {
                PageSize = Rotativa.AspNetCore.Options.Size.A4,
                PageOrientation = orientation,
                CustomSwitches = "--footer-center \"  Print Date: " + DateTime.Now.Date.ToString("dd/MM/yyyy") + "  Page: [page]/[toPage]\"" + " --footer-line --footer-font-size \"6\" --footer-spacing 1 --footer-font-name \"Arial\""
            };
        }       
        public async Task<ActionResult> ExportExcel(string ReportCode, string ReportName)
        {
            string sWebRootFolder = _hostingEnvironment.WebRootPath;
            string sFileName = @""+ ReportCode + " - "+ ReportName + ".xlsx";
            string URL = string.Format("{0}://{1}/{2}", Request.Scheme, Request.Host, sFileName);
            FileInfo file = new FileInfo(Path.Combine(sWebRootFolder, sFileName));
            var memory = new MemoryStream();
            DataSet dsReport = new DataSet();
            int rowheader = 0;
            int colheader = 0;
            using (var fs = new FileStream(Path.Combine(sWebRootFolder, sFileName), FileMode.Create, FileAccess.Write))
            {
                IWorkbook workbook;
                workbook = new XSSFWorkbook();
                ISheet excelSheet = workbook.CreateSheet(ReportCode);

                XSSFCellStyle headerStyle = (XSSFCellStyle)workbook.CreateCellStyle();
                headerStyle = (XSSFCellStyle)workbook.CreateCellStyle();
                font = workbook.CreateFont();
                font.Boldweight = (short)FontBoldWeight.Bold;
                font.FontHeightInPoints = 18;
                headerStyle.SetFont(font);
                IRow row = excelSheet.CreateRow(1);
                row.CreateCell(0).SetCellValue(ReportCode + " - " + ReportName);
                row.Cells[0].CellStyle = headerStyle;

                XSSFCellStyle colHeaderStyle = (XSSFCellStyle)workbook.CreateCellStyle();
                colHeaderStyle = (XSSFCellStyle)workbook.CreateCellStyle();
                colHeaderStyle.FillForegroundColor = IndexedColors.Red.Index;
                colHeaderStyle.FillPattern = FillPattern.SolidForeground;
                colHeaderStyle.BorderTop = BorderStyle.Thin;
                colHeaderStyle.BorderBottom = BorderStyle.Thin;
                
                switch (ReportCode)
                {
                    case "RDN07":
                        {
                            //HEADER
                            RDN07Header RDN07Header = new RDN07Header();
                            var sessionHeader = _session.GetString("RDN07Header");
                            RDN07Header = JsonConvert.DeserializeObject<RDN07Header>(sessionHeader);
                            row = excelSheet.CreateRow(3);
                            row.CreateCell(0).SetCellValue("Periode  : " + RDN07Header.PeriodStart + " - " + RDN07Header.PeriodEnd);
                            row = excelSheet.CreateRow(4);
                            row.CreateCell(0).SetCellValue("Custody Name : " + RDN07Header.CustodyName);

                            //COLUMNS HEADER
                            var sessionDataset = _session.GetString("RDN07");
                            dsReport = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                            rowheader = 6;
                            row = excelSheet.CreateRow(rowheader);
                            row.CreateCell(0).SetCellValue("Trade Date");
                            row.CreateCell(1).SetCellValue("SHDID");
                            row.CreateCell(2).SetCellValue("Exchange Out - Currency");
                            row.CreateCell(3).SetCellValue("Exchange Out - Shares");
                            row.CreateCell(4).SetCellValue("Liquidation");
                            row.CreateCell(5).SetCellValue("Dealer Commision (CCY)");
                            row.CreateCell(6).SetCellValue("Dealer Commision Pct");
                            row.CreateCell(7).SetCellValue("Exchange IN FUND ID");
                            row.CreateCell(8).SetCellValue("Reference No 1");
                            row.CreateCell(9).SetCellValue("Reference No 2");
                            colheader = 10;
                            for (int i = 0; i < colheader; i++)
                            {
                                row.Cells[i].CellStyle = colHeaderStyle;
                            }
                            break;
                        }
                    case "RDN08":
                        {
                            //HEADER
                            RDN08Header RDN08Header = new RDN08Header();
                            var sessionHeader = _session.GetString("RDN08Header");
                            RDN08Header = JsonConvert.DeserializeObject<RDN08Header>(sessionHeader);
                            row = excelSheet.CreateRow(3);
                            row.CreateCell(0).SetCellValue("Tgl. Subscript  Awal  : " + RDN08Header.PeriodStart);
                            row = excelSheet.CreateRow(4);
                            row.CreateCell(0).SetCellValue("Tgl. Subscript Akhir : " + RDN08Header.PeriodEnd);
                            row = excelSheet.CreateRow(5);
                            row.CreateCell(0).SetCellValue("Product Code : " + RDN08Header.ProdCode);
                            row = excelSheet.CreateRow(6);
                            row.CreateCell(0).SetCellValue("Branch : " + RDN08Header.Branch);

                            //COLUMNS HEADER
                            var sessionDataset = _session.GetString("RDN08");
                            dsReport = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                            rowheader = 8;
                            row = excelSheet.CreateRow(rowheader);
                            row.CreateCell(0).SetCellValue("Joint Date");                            
                            row.CreateCell(1).SetCellValue("Agent Code");
                            row.CreateCell(2).SetCellValue("Agent Name");
                            row.CreateCell(3).SetCellValue("Shareholder ID");
                            row.CreateCell(4).SetCellValue("Client Code");
                            row.CreateCell(5).SetCellValue("Nama Nasabah");
                            row.CreateCell(6).SetCellValue("Jenis Transaksi");
                            row.CreateCell(7).SetCellValue("Nominal");
                            row.CreateCell(8).SetCellValue("NAV");
                            row.CreateCell(9).SetCellValue("Kurs");
                            row.CreateCell(10).SetCellValue("Jumlah Unit");
                            row.CreateCell(11).SetCellValue("Tanggal Tran");
                            row.CreateCell(12).SetCellValue("Value Date");
                            row.CreateCell(13).SetCellValue("Nama Inputer");
                            row.CreateCell(14).SetCellValue("Nama Checker");
                            row.CreateCell(15).SetCellValue("NIK Seller");
                            row.CreateCell(16).SetCellValue("Nama Seller");
                            colheader = 17;
                            for (int i = 0; i < colheader; i++)
                            {
                                row.Cells[i].CellStyle = colHeaderStyle;
                            }
                            break;
                        }
                    case "RDN09":
                        {
                            //HEADER
                            RDN09Header RDN09Header = new RDN09Header();
                            var sessionHeader = _session.GetString("RDN09Header");
                            RDN09Header = JsonConvert.DeserializeObject<RDN09Header>(sessionHeader);
                            row = excelSheet.CreateRow(3);
                            row.CreateCell(0).SetCellValue("Tran Date  : " + RDN09Header.TranDate);
                            row = excelSheet.CreateRow(4);
                            row.CreateCell(0).SetCellValue("Product Code : " + RDN09Header.ProductCode);
                            row = excelSheet.CreateRow(5);
                            row.CreateCell(0).SetCellValue("Mata Uang : " + RDN09Header.MataUang);
                            row = excelSheet.CreateRow(6);
                            row.CreateCell(0).SetCellValue("Regional : " + RDN09Header.RegionName);

                            //COLUMNS HEADER
                            var sessionDataset = _session.GetString("RDN09");
                            dsReport = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                            rowheader = 8;
                            row = excelSheet.CreateRow(rowheader);
                            row.CreateCell(0).SetCellValue("Agent Code");
                            row.CreateCell(1).SetCellValue("Agent Name");
                            row.CreateCell(2).SetCellValue("Nominal");
                            row.CreateCell(3).SetCellValue("NAV");
                            row.CreateCell(4).SetCellValue("Jumlah Unit");
                            row.CreateCell(5).SetCellValue("Jumlah Nasabah");
                            colheader = 6;
                            for (int i = 0; i < colheader; i++)
                            {
                                row.Cells[i].CellStyle = colHeaderStyle;
                            }
                            break;
                        }
                    case "RDN10":
                        {
                            //HEADER
                            RDN10Header RDN10Header = new RDN10Header();
                            var sessionHeader = _session.GetString("RDN10Header");
                            RDN10Header = JsonConvert.DeserializeObject<RDN10Header>(sessionHeader);
                            row = excelSheet.CreateRow(3);
                            row.CreateCell(0).SetCellValue("Tgl. Redemption  Awal  : " + RDN10Header.PeriodStart);
                            row = excelSheet.CreateRow(4);
                            row.CreateCell(0).SetCellValue("Tgl. Redemption Akhir : " + RDN10Header.PeriodEnd);
                            row = excelSheet.CreateRow(5);
                            row.CreateCell(0).SetCellValue("Product Code : " + RDN10Header.ProdCode);
                            row = excelSheet.CreateRow(6);
                            row.CreateCell(0).SetCellValue("Branch : " + RDN10Header.Branch);

                            //COLUMNS HEADER
                            var sessionDataset = _session.GetString("RDN10");
                            dsReport = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                            rowheader = 8;
                            row = excelSheet.CreateRow(rowheader);
                            row.CreateCell(0).SetCellValue("Joint Date");
                            row.CreateCell(1).SetCellValue("Agent Code");
                            row.CreateCell(2).SetCellValue("Agent Name");
                            row.CreateCell(3).SetCellValue("Shareholder ID");
                            row.CreateCell(4).SetCellValue("Client Code");
                            row.CreateCell(5).SetCellValue("Nama Nasabah");
                            row.CreateCell(6).SetCellValue("Jenis Transaksi");
                            row.CreateCell(7).SetCellValue("Nominal");
                            row.CreateCell(8).SetCellValue("NAV");
                            row.CreateCell(9).SetCellValue("Kurs");
                            row.CreateCell(10).SetCellValue("Jumlah Unit");
                            row.CreateCell(11).SetCellValue("Tanggal Tran");
                            row.CreateCell(12).SetCellValue("Value Date");
                            row.CreateCell(13).SetCellValue("Nama Inputer");
                            row.CreateCell(14).SetCellValue("Nama Checker");
                            row.CreateCell(15).SetCellValue("NIK Seller");
                            row.CreateCell(16).SetCellValue("Nama Seller");
                            colheader = 17;
                            for (int i = 0; i < colheader; i++)
                            {
                                row.Cells[i].CellStyle = colHeaderStyle;
                            }
                            break;
                        }
                    case "RDN11":
                        {
                            //HEADER
                            RDN11Header RDN11Header = new RDN11Header();
                            var sessionHeader = _session.GetString("RDN11Header");
                            RDN11Header = JsonConvert.DeserializeObject<RDN11Header>(sessionHeader);
                            row = excelSheet.CreateRow(3);
                            row.CreateCell(0).SetCellValue("Tran Date  : " + RDN11Header.TranDate);
                            row = excelSheet.CreateRow(4);
                            row.CreateCell(0).SetCellValue("Product Code : " + RDN11Header.ProductCode);
                            row = excelSheet.CreateRow(5);
                            row.CreateCell(0).SetCellValue("Mata Uang : " + RDN11Header.MataUang);
                            row = excelSheet.CreateRow(6);
                            row.CreateCell(0).SetCellValue("Regional : " + RDN11Header.RegionName);

                            //COLUMNS HEADER
                            var sessionDataset = _session.GetString("RDN11");
                            dsReport = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                            rowheader = 8;
                            row = excelSheet.CreateRow(rowheader);
                            row.CreateCell(0).SetCellValue("Agent Code");
                            row.CreateCell(1).SetCellValue("Agent Name");
                            row.CreateCell(2).SetCellValue("Nominal");
                            row.CreateCell(3).SetCellValue("NAV");
                            row.CreateCell(4).SetCellValue("Jumlah Unit");
                            row.CreateCell(5).SetCellValue("Jumlah Nasabah");
                            colheader = 6;
                            for (int i = 0; i < colheader; i++)
                            {
                                row.Cells[i].CellStyle = colHeaderStyle;
                            }
                            break;
                        }
                    case "RDN12":
                        {
                            //HEADER
                            RDN12Header RDN12Header = new RDN12Header();
                            var sessionHeader = _session.GetString("RDN12Header");
                            RDN12Header = JsonConvert.DeserializeObject<RDN12Header>(sessionHeader);
                            row = excelSheet.CreateRow(3);
                            row.CreateCell(0).SetCellValue("Period  : " + RDN12Header.Period);
                            row = excelSheet.CreateRow(4);
                            row.CreateCell(0).SetCellValue("Product Code : " + RDN12Header.ProductCode);
                            row = excelSheet.CreateRow(5);
                            row.CreateCell(0).SetCellValue("Mata Uang : " + RDN12Header.MataUang);
                            row = excelSheet.CreateRow(6);
                            row.CreateCell(0).SetCellValue("Regional : " + RDN12Header.RegionName);

                            //COLUMNS HEADER
                            var sessionDataset = _session.GetString("RDN12");
                            dsReport = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                            rowheader = 8;
                            row = excelSheet.CreateRow(rowheader);
                            row.CreateCell(0).SetCellValue("CIF No");
                            row.CreateCell(1).SetCellValue("Shareholder ID");
                            row.CreateCell(2).SetCellValue("Client Code");
                            row.CreateCell(3).SetCellValue("Join Date");
                            row.CreateCell(4).SetCellValue("Client Name");
                            row.CreateCell(5).SetCellValue("Client Address");
                            row.CreateCell(6).SetCellValue("Client Phone");
                            row.CreateCell(7).SetCellValue("NPWP");
                            row.CreateCell(8).SetCellValue("Institution");
                            row.CreateCell(9).SetCellValue("Agent Code");
                            row.CreateCell(10).SetCellValue("Agent Name");
                            row.CreateCell(11).SetCellValue("Regional Code");
                            row.CreateCell(12).SetCellValue("Account No");
                            row.CreateCell(13).SetCellValue("Account Name");
                            row.CreateCell(14).SetCellValue("NAV");
                            row.CreateCell(15).SetCellValue("Deviden (Nominal)");
                            row.CreateCell(16).SetCellValue("Kurs");
                            row.CreateCell(17).SetCellValue("Subcription (Nominal)");
                            row.CreateCell(18).SetCellValue("Redemption (Nominal)");
                            row.CreateCell(19).SetCellValue("Oustanding (Unit)");
                            row.CreateCell(20).SetCellValue("Subc Fee (Nominal)");
                            row.CreateCell(21).SetCellValue("Mntc Fee (Nominal)");
                            row.CreateCell(22).SetCellValue("Redemp Fee (Nominal)");
                            row.CreateCell(23).SetCellValue("User Name");
                            row.CreateCell(24).SetCellValue("Referral Name");
                            row.CreateCell(25).SetCellValue("Status Client Code");
                            row.CreateCell(26).SetCellValue("Flag");
                            row.CreateCell(27).SetCellValue("Flag RDB");
                            colheader = 28;
                            for (int i = 0; i < colheader; i++)
                            {
                                row.Cells[i].CellStyle = colHeaderStyle;
                            }
                            break;
                        }
                    case "RDN13":
                        {
                            //HEADER
                            RDN13Header RDN13Header = new RDN13Header();
                            var sessionHeader = _session.GetString("RDN13Header");
                            RDN13Header = JsonConvert.DeserializeObject<RDN13Header>(sessionHeader);
                            row = excelSheet.CreateRow(3);
                            row.CreateCell(0).SetCellValue("Periode  : " + RDN13Header.PeriodStart + " - " + RDN13Header.PeriodEnd);
                            row = excelSheet.CreateRow(4);
                            row.CreateCell(0).SetCellValue("Product Code : " + RDN13Header.ProdCode);
                            row = excelSheet.CreateRow(5);
                            row.CreateCell(0).SetCellValue("Mata Uang : " + RDN13Header.MataUang);
                            row = excelSheet.CreateRow(6);
                            row.CreateCell(0).SetCellValue("Tipe Produk : " + RDN13Header.TipeProduk);

                            //COLUMNS HEADER
                            var sessionDataset = _session.GetString("RDN13");
                            dsReport = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                            rowheader = 9;
                            row = excelSheet.CreateRow(rowheader);
                            row.CreateCell(0).SetCellValue("Value Date");
                            row.CreateCell(1).SetCellValue("Value");
                            colheader = 2;
                            for (int i = 0; i < colheader; i++)
                            {
                                row.Cells[i].CellStyle = colHeaderStyle;
                            }
                            break;
                        }
                    case "RDN14":
                        {
                            //HEADER
                            RDN14Header RDN14Header = new RDN14Header();
                            var sessionHeader = _session.GetString("RDN14Header");
                            RDN14Header = JsonConvert.DeserializeObject<RDN14Header>(sessionHeader);
                            row = excelSheet.CreateRow(3);
                            row.CreateCell(0).SetCellValue("Periode  : " + RDN14Header.PeriodStart + " - " + RDN14Header.PeriodEnd);
                            row = excelSheet.CreateRow(4);
                            row.CreateCell(0).SetCellValue("Product Code : " + RDN14Header.ProdCode);
                            row = excelSheet.CreateRow(5);
                            row.CreateCell(0).SetCellValue("Mata Uang : " + RDN14Header.MataUang);
                            row = excelSheet.CreateRow(6);
                            row.CreateCell(0).SetCellValue("Regional : " + RDN14Header.RegionName);

                            //COLUMNS HEADER
                            var sessionDataset = _session.GetString("RDN14");
                            dsReport = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                            rowheader = 9;
                            row = excelSheet.CreateRow(rowheader);
                            row.CreateCell(0).SetCellValue("City");
                            row.CreateCell(1).SetCellValue("Agent Description");
                            row.CreateCell(2).SetCellValue("Agent Code");
                            row.CreateCell(3).SetCellValue("Total Trans");
                            row.CreateCell(4).SetCellValue("Total Unit");
                            row.CreateCell(5).SetCellValue("Total Nominal");
                            row.CreateCell(6).SetCellValue("Fee");
                            colheader = 7;
                            for (int i = 0; i < colheader; i++)
                            {
                                row.Cells[i].CellStyle = colHeaderStyle;
                            }
                            break;
                        }
                    case "RDN24":
                        {
                            //HEADER
                            row = excelSheet.CreateRow(3);
                            row.CreateCell(0).SetCellValue("Tanggal  : " + DateTime.Now.ToString("dd/MM/yyyy"));

                            //COLUMNS HEADER
                            var sessionDataset = _session.GetString("RDN24");
                            dsReport = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                            rowheader = 3;
                            row = excelSheet.CreateRow(rowheader);
                            row.CreateCell(0).SetCellValue("Bill Id");
                            row.CreateCell(1).SetCellValue("TranCode");
                            row.CreateCell(2).SetCellValue("Client Code");
                            row.CreateCell(3).SetCellValue("CIFName");
                            row.CreateCell(4).SetCellValue("Jenis Transaksi");
                            row.CreateCell(5).SetCellValue("TranDate");
                            row.CreateCell(6).SetCellValue("NAV Value Date");
                            row.CreateCell(7).SetCellValue("Office Debit");
                            row.CreateCell(8).SetCellValue("Debit Currency");
                            row.CreateCell(9).SetCellValue("Account ID Debit");
                            row.CreateCell(10).SetCellValue("Debit Mutation");
                            row.CreateCell(11).SetCellValue("Office Kredit");
                            row.CreateCell(12).SetCellValue("Credit Currency");
                            row.CreateCell(13).SetCellValue("Account ID Credit");
                            row.CreateCell(14).SetCellValue("Credit Mutation");
                            row.CreateCell(15).SetCellValue("Status");
                            row.CreateCell(16).SetCellValue("Description");
                            colheader = 17;
                            for (int i = 0; i < colheader; i++)
                            {
                                row.Cells[i].CellStyle = colHeaderStyle;
                            }
                            break;
                        }
                    case "RDN26":
                        {
                            //COLUMNS HEADER
                            var sessionDataset = _session.GetString("RDN26");
                            dsReport = JsonConvert.DeserializeObject<DataSet>(sessionDataset);
                            rowheader = 2;
                            row = excelSheet.CreateRow(rowheader);
                            row.CreateCell(0).SetCellValue("DataType");
                            row.CreateCell(1).SetCellValue("ClCode");
                            row.CreateCell(2).SetCellValue("ClName");
                            row.CreateCell(3).SetCellValue("EmployeeFlag");
                            row.CreateCell(4).SetCellValue("AcNo");
                            row.CreateCell(5).SetCellValue("AcName");
                            row.CreateCell(6).SetCellValue("BkCode");
                            colheader = 7;
                            for (int i = 0; i < colheader; i++)
                            {
                                row.Cells[i].CellStyle = colHeaderStyle;
                            }
                            break;
                        }
                }

                //ROWS
                for (int i = 0; i < dsReport.Tables[0].Rows.Count; i++)
                {
                    row = excelSheet.CreateRow(i + rowheader + 1);
                    switch (ReportCode)
                    {
                        case "RDN07":
                            {
                                row.CreateCell(0).SetCellValue(dsReport.Tables[0].Rows[i]["tradeDate"].ToString());
                                row.CreateCell(1).SetCellValue(dsReport.Tables[0].Rows[i]["SHDID"].ToString());
                                row.CreateCell(2).SetCellValue(dsReport.Tables[0].Rows[i]["exchangeOutAmt"].ToString());
                                row.CreateCell(3).SetCellValue(dsReport.Tables[0].Rows[i]["exchangeOutUnit"].ToString());
                                row.CreateCell(4).SetCellValue(dsReport.Tables[0].Rows[i]["liquidate"].ToString());
                                row.CreateCell(5).SetCellValue(dsReport.Tables[0].Rows[i]["dealerCommision"].ToString());
                                row.CreateCell(6).SetCellValue(dsReport.Tables[0].Rows[i]["dealerCommisionPct"].ToString());
                                row.CreateCell(7).SetCellValue(dsReport.Tables[0].Rows[i]["exchangeInFundId"].ToString());
                                row.CreateCell(8).SetCellValue(dsReport.Tables[0].Rows[i]["clientCodeSwitchOut"].ToString());
                                row.CreateCell(9).SetCellValue(dsReport.Tables[0].Rows[i]["clientCodeSwitchIn"].ToString());
                                break;
                            }
                        case "RDN08":
                            {
                                row.CreateCell(0).SetCellValue(dsReport.Tables[0].Rows[i]["jointDate"].ToString());
                                row.CreateCell(1).SetCellValue(dsReport.Tables[0].Rows[i]["agentCode"].ToString());
                                row.CreateCell(2).SetCellValue(dsReport.Tables[0].Rows[i]["agentName"].ToString());
                                row.CreateCell(3).SetCellValue(dsReport.Tables[0].Rows[i]["shareholderID"].ToString());
                                row.CreateCell(4).SetCellValue(dsReport.Tables[0].Rows[i]["clientCode"].ToString());
                                row.CreateCell(5).SetCellValue(dsReport.Tables[0].Rows[i]["namaNasabah"].ToString());
                                row.CreateCell(6).SetCellValue(dsReport.Tables[0].Rows[i]["jenisTransaksi"].ToString());
                                row.CreateCell(7).SetCellValue(dsReport.Tables[0].Rows[i]["nominal"].ToString());
                                row.CreateCell(8).SetCellValue(dsReport.Tables[0].Rows[i]["nav"].ToString());
                                row.CreateCell(9).SetCellValue(dsReport.Tables[0].Rows[i]["kurs"].ToString());
                                row.CreateCell(10).SetCellValue(dsReport.Tables[0].Rows[i]["jumlahUnit"].ToString());
                                row.CreateCell(11).SetCellValue(dsReport.Tables[0].Rows[i]["tranDate"].ToString());
                                row.CreateCell(12).SetCellValue(dsReport.Tables[0].Rows[i]["valueDate"].ToString());
                                row.CreateCell(13).SetCellValue(dsReport.Tables[0].Rows[i]["namaInputer"].ToString());
                                row.CreateCell(14).SetCellValue(dsReport.Tables[0].Rows[i]["namaChecker"].ToString());
                                row.CreateCell(15).SetCellValue(dsReport.Tables[0].Rows[i]["seller"].ToString());
                                row.CreateCell(16).SetCellValue(dsReport.Tables[0].Rows[i]["namaSeller"].ToString());
                                break;
                            }
                        case "RDN09":
                            {
                                row.CreateCell(0).SetCellValue(dsReport.Tables[0].Rows[i]["AgentCode"].ToString());
                                row.CreateCell(1).SetCellValue(dsReport.Tables[0].Rows[i]["AgentName"].ToString());
                                row.CreateCell(2).SetCellValue(dsReport.Tables[0].Rows[i]["Nominal"].ToString());
                                row.CreateCell(3).SetCellValue(dsReport.Tables[0].Rows[i]["NAV"].ToString());
                                row.CreateCell(4).SetCellValue(dsReport.Tables[0].Rows[i]["JumlahUnit"].ToString());
                                row.CreateCell(5).SetCellValue(dsReport.Tables[0].Rows[i]["JumlahNasabah"].ToString());
                                break;
                            }
                        case "RDN10":
                            {
                                row.CreateCell(0).SetCellValue(dsReport.Tables[0].Rows[i]["jointDate"].ToString());
                                row.CreateCell(1).SetCellValue(dsReport.Tables[0].Rows[i]["agentCode"].ToString());
                                row.CreateCell(2).SetCellValue(dsReport.Tables[0].Rows[i]["agentName"].ToString());
                                row.CreateCell(3).SetCellValue(dsReport.Tables[0].Rows[i]["shareholderID"].ToString());
                                row.CreateCell(4).SetCellValue(dsReport.Tables[0].Rows[i]["clientCode"].ToString());
                                row.CreateCell(5).SetCellValue(dsReport.Tables[0].Rows[i]["namaNasabah"].ToString());
                                row.CreateCell(6).SetCellValue(dsReport.Tables[0].Rows[i]["jenisTransaksi"].ToString());
                                row.CreateCell(7).SetCellValue(dsReport.Tables[0].Rows[i]["nominal"].ToString());
                                row.CreateCell(8).SetCellValue(dsReport.Tables[0].Rows[i]["nav"].ToString());
                                row.CreateCell(9).SetCellValue(dsReport.Tables[0].Rows[i]["kurs"].ToString());
                                row.CreateCell(10).SetCellValue(dsReport.Tables[0].Rows[i]["jumlahUnit"].ToString());
                                row.CreateCell(11).SetCellValue(dsReport.Tables[0].Rows[i]["tranDate"].ToString());
                                row.CreateCell(12).SetCellValue(dsReport.Tables[0].Rows[i]["valueDate"].ToString());
                                row.CreateCell(13).SetCellValue(dsReport.Tables[0].Rows[i]["namaInputer"].ToString());
                                row.CreateCell(14).SetCellValue(dsReport.Tables[0].Rows[i]["namaChecker"].ToString());
                                row.CreateCell(15).SetCellValue(dsReport.Tables[0].Rows[i]["seller"].ToString());
                                row.CreateCell(16).SetCellValue(dsReport.Tables[0].Rows[i]["namaSeller"].ToString());
                                break;
                            }
                        case "RDN11":
                            {
                                row.CreateCell(0).SetCellValue(dsReport.Tables[0].Rows[i]["AgentCode"].ToString());
                                row.CreateCell(1).SetCellValue(dsReport.Tables[0].Rows[i]["AgentName"].ToString());
                                row.CreateCell(2).SetCellValue(dsReport.Tables[0].Rows[i]["Nominal"].ToString());
                                row.CreateCell(3).SetCellValue(dsReport.Tables[0].Rows[i]["NAV"].ToString());
                                row.CreateCell(4).SetCellValue(dsReport.Tables[0].Rows[i]["JumlahUnit"].ToString());
                                row.CreateCell(5).SetCellValue(dsReport.Tables[0].Rows[i]["JumlahNasabah"].ToString());
                                break;
                            }
                        case "RDN12":
                            {
                                row.CreateCell(0).SetCellValue(dsReport.Tables[0].Rows[i]["CIFNo"].ToString());
                                row.CreateCell(1).SetCellValue(dsReport.Tables[0].Rows[i]["ShareholderID"].ToString());
                                row.CreateCell(2).SetCellValue(dsReport.Tables[0].Rows[i]["ClientCode"].ToString());
                                row.CreateCell(3).SetCellValue(dsReport.Tables[0].Rows[i]["JoinDate"].ToString());
                                row.CreateCell(4).SetCellValue(dsReport.Tables[0].Rows[i]["ClientName"].ToString());
                                row.CreateCell(5).SetCellValue(dsReport.Tables[0].Rows[i]["ClientAddress"].ToString());
                                row.CreateCell(6).SetCellValue(dsReport.Tables[0].Rows[i]["ClientPhone"].ToString());
                                row.CreateCell(7).SetCellValue(dsReport.Tables[0].Rows[i]["CIFNPWP"].ToString());
                                row.CreateCell(8).SetCellValue(dsReport.Tables[0].Rows[i]["CIFType"].ToString());
                                row.CreateCell(9).SetCellValue(dsReport.Tables[0].Rows[i]["AgentCode"].ToString());
                                row.CreateCell(10).SetCellValue(dsReport.Tables[0].Rows[i]["AgentName"].ToString());
                                row.CreateCell(11).SetCellValue(dsReport.Tables[0].Rows[i]["RegionalCode"].ToString());
                                row.CreateCell(12).SetCellValue(dsReport.Tables[0].Rows[i]["AccountNo"].ToString());
                                row.CreateCell(13).SetCellValue(dsReport.Tables[0].Rows[i]["AccountName"].ToString());
                                row.CreateCell(14).SetCellValue(dsReport.Tables[0].Rows[i]["NAV"].ToString());
                                row.CreateCell(15).SetCellValue(dsReport.Tables[0].Rows[i]["Deviden"].ToString());
                                row.CreateCell(16).SetCellValue(dsReport.Tables[0].Rows[i]["Kurs"].ToString());
                                row.CreateCell(17).SetCellValue(dsReport.Tables[0].Rows[i]["Subscription"].ToString());
                                row.CreateCell(18).SetCellValue(dsReport.Tables[0].Rows[i]["Redemption"].ToString());
                                row.CreateCell(19).SetCellValue(dsReport.Tables[0].Rows[i]["Outstanding"].ToString());
                                row.CreateCell(20).SetCellValue(dsReport.Tables[0].Rows[i]["SubcFee"].ToString());
                                row.CreateCell(21).SetCellValue(dsReport.Tables[0].Rows[i]["MntcFee"].ToString());
                                row.CreateCell(22).SetCellValue(dsReport.Tables[0].Rows[i]["RedempFee"].ToString());
                                row.CreateCell(23).SetCellValue(dsReport.Tables[0].Rows[i]["UserName"].ToString());
                                row.CreateCell(24).SetCellValue(dsReport.Tables[0].Rows[i]["ReferralName"].ToString());
                                row.CreateCell(25).SetCellValue(dsReport.Tables[0].Rows[i]["StatusClientCode"].ToString());
                                row.CreateCell(26).SetCellValue(dsReport.Tables[0].Rows[i]["Flag"].ToString());
                                row.CreateCell(27).SetCellValue(dsReport.Tables[0].Rows[i]["FlagRDB"].ToString());      
                               break;
                            }
                        case "RDN13":
                            {
                                row.CreateCell(0).SetCellValue(dsReport.Tables[0].Rows[i]["valueDate"].ToString());
                                row.CreateCell(1).SetCellValue(dsReport.Tables[0].Rows[i]["value"].ToString());
                                break;
                            }
                        case "RDN14":
                            {
                                row.CreateCell(0).SetCellValue(dsReport.Tables[0].Rows[i]["City"].ToString());
                                row.CreateCell(1).SetCellValue(dsReport.Tables[0].Rows[i]["AgentDesc"].ToString());
                                row.CreateCell(2).SetCellValue(dsReport.Tables[0].Rows[i]["AgentCode"].ToString());
                                row.CreateCell(3).SetCellValue(dsReport.Tables[0].Rows[i]["TotalTrans"].ToString());
                                row.CreateCell(4).SetCellValue(dsReport.Tables[0].Rows[i]["TotalUnit"].ToString());
                                row.CreateCell(5).SetCellValue(dsReport.Tables[0].Rows[i]["TotalNom"].ToString());
                                row.CreateCell(6).SetCellValue(dsReport.Tables[0].Rows[i]["Fee"].ToString());
                                break;
                            }
                        case "RDN24":
                            {
                                row.CreateCell(0).SetCellValue(dsReport.Tables[0].Rows[i]["BillId"].ToString());
                                row.CreateCell(1).SetCellValue(dsReport.Tables[0].Rows[i]["TranCode"].ToString());
                                row.CreateCell(2).SetCellValue(dsReport.Tables[0].Rows[i]["ClientCode"].ToString());
                                row.CreateCell(3).SetCellValue(dsReport.Tables[0].Rows[i]["CIFName"].ToString());
                                row.CreateCell(4).SetCellValue(dsReport.Tables[0].Rows[i]["JenisTransaksi"].ToString());
                                row.CreateCell(5).SetCellValue(dsReport.Tables[0].Rows[i]["TranDate"].ToString());
                                row.CreateCell(6).SetCellValue(dsReport.Tables[0].Rows[i]["NAVValueDate"].ToString());
                                row.CreateCell(7).SetCellValue(dsReport.Tables[0].Rows[i]["OfficeDebit"].ToString());
                                row.CreateCell(8).SetCellValue(dsReport.Tables[0].Rows[i]["DebitCurrency"].ToString());
                                row.CreateCell(9).SetCellValue(dsReport.Tables[0].Rows[i]["AccountIDDebit"].ToString());
                                row.CreateCell(10).SetCellValue(dsReport.Tables[0].Rows[i]["DebitMutation"].ToString());
                                row.CreateCell(11).SetCellValue(dsReport.Tables[0].Rows[i]["OfficeKredit"].ToString());
                                row.CreateCell(12).SetCellValue(dsReport.Tables[0].Rows[i]["CreditCurrency"].ToString());
                                row.CreateCell(13).SetCellValue(dsReport.Tables[0].Rows[i]["AccountIDCredit"].ToString());
                                row.CreateCell(14).SetCellValue(dsReport.Tables[0].Rows[i]["CreditMutation"].ToString());
                                row.CreateCell(15).SetCellValue(dsReport.Tables[0].Rows[i]["Status"].ToString());
                                row.CreateCell(16).SetCellValue(dsReport.Tables[0].Rows[i]["Description"].ToString());
                                break;
                            }
                        case "RDN26":
                            {
                                row.CreateCell(0).SetCellValue(dsReport.Tables[0].Rows[i]["DataType"].ToString());
                                row.CreateCell(1).SetCellValue(dsReport.Tables[0].Rows[i]["ClCode"].ToString());
                                row.CreateCell(2).SetCellValue(dsReport.Tables[0].Rows[i]["ClName"].ToString());
                                row.CreateCell(3).SetCellValue(dsReport.Tables[0].Rows[i]["EmployeeFlag"].ToString());
                                row.CreateCell(4).SetCellValue(dsReport.Tables[0].Rows[i]["AcNo"].ToString());
                                row.CreateCell(5).SetCellValue(dsReport.Tables[0].Rows[i]["AcName"].ToString());
                                row.CreateCell(6).SetCellValue(dsReport.Tables[0].Rows[i]["BkCode"].ToString());
                                break;
                            }
                    }
                }
                for (int i = 0; i < colheader; i++)
                {
                    excelSheet.AutoSizeColumn(i);
                }
                workbook.Write(fs);
                
            }
            using (var stream = new FileStream(Path.Combine(sWebRootFolder, sFileName), FileMode.Open))
            {
                await stream.CopyToAsync(memory);
            }
            memory.Position = 0;
            return File(memory, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", sFileName);
        }
        [Authorize]
        public IActionResult NFSUpload()
        {
            ReportListViewModel vModel = new ReportListViewModel();
            return View();
        }
        [Authorize]
        public IActionResult ReportKYC()
        {
            ReportListViewModel vModel = new ReportListViewModel();
            return View();
        }
        public JsonResult GetFileTypeList(string FileType)
        {
            List<FileModel.NFSFileListType> listType = new List<FileModel.NFSFileListType>();
            NFSGetFileTypeList(FileType, out listType);
            return Json(listType);
        }
        public JsonResult OpenCsvFile(string strFileName, string sFileCode)
        {
            string ErrMsg = "";
            DataSet dsFile = new DataSet();
            csv = new clsCSVFormat(dsFile);
            if (GetFormatFile(sFileCode, out ErrMsg))
            {
                string[] sCol = this.sFieldKey.Trim().Split(new char[] { ',', ';' }, StringSplitOptions.None);
                this.sXMLData = "";
                if (!csv.GetCSVFile(strFileName, sCol, out sXMLData, out ErrMsg))
                {
                    return Json(new { ErrMsg, dsFile });
                }
            }
            return Json( new { ErrMsg, dsFile });
        }
        public ActionResult ReportKYCGenFile(string File, string Jenis, int Bulan, int Tahun)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string handle = "";
            DataSet dsKYC = new DataSet();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Report/KYCGenerateText?NIK=" + _intNIK + "&Module=" + strModule + "&Jenis=" + Jenis + "&Bulan=" + Bulan + "&Tahun=" + Tahun).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();

                    JToken TokenData = strObject["dsResult"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    dsKYC = JsonConvert.DeserializeObject<DataSet>(JsonData);

                    if (dsKYC.Tables[0].Rows.Count <= 0)
                    {
                        blnResult = false;
                        ErrMsg = "Tidak ada data untuk bulan dan tahun tersebut. ";
                        return Json(new { blnResult, ErrMsg, FileGuid = handle, FileName = File });
                    }

                    if (CreateTextFile(dsKYC, out handle, out ErrMsg))
                    {
                        blnResult = true;
                        ErrMsg = "File berhasil dibuat. ";
                    }
                    else
                    {
                        blnResult = false;
                        ErrMsg = "Gagal create file.";
                        return Json(new { blnResult, ErrMsg, FileGuid = handle, FileName = File });
                    }
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }

            return Json(new { blnResult, ErrMsg, FileGuid = handle, FileName = File });
        }
        public ActionResult NFSGenerateFileUpload(string FileCode, string TranDate)
        {
            bool blnResult = false;
            string ErrMsg = "";
            using (HttpClient client = new HttpClient())
            {
                DataSet dsData;
                string sSeparator, sFileName = "", sFormatFile, sFilterFile = "";
                bool bIsLog, bIsNeedAuth;
                bIsLog = false;
                bIsNeedAuth = false;
                string handle = "";
                try
                {
                    string[] s;
                    s = TranDate.Split('/');
                    string strTranDate = s[2] + s[1] + s[0];
                    int intTranDate;
                    int.TryParse(strTranDate, out intTranDate);
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Report/NFSGenerateFileUpload?FileCode=" + FileCode + "&TranDate=" + intTranDate).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);                    
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenData = strObject["ds"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    dsData = JsonConvert.DeserializeObject<System.Data.DataSet>(JsonData);
                    if (dsData != null)
                    {
                        if (Convert.ToBoolean(dsData.Tables[0].Rows[0]["IsdNeedApproval"]) == true)
                        {
                            if (dsData.Tables[2].Rows[0]["XMLData"].ToString() == "" || dsData.Tables[2].Rows[0]["XMLRawData"].ToString() == "")
                            {
                                blnResult = false;
                                ErrMsg = "Data tidak tersedia.";
                                return Json(new { blnResult, ErrMsg, FileGuid = handle, FileName = sFileName });
                            }
                        }
                        if (dsData.Tables[0].Rows.Count == 0)
                        {
                            blnResult = false;
                            ErrMsg = "Data Parameter tidak tersedia.";
                            return Json(new { blnResult, ErrMsg, FileGuid = handle, FileName = sFileName });
                        }
                        if (dsData.Tables[1].Rows.Count == 0)
                        {
                            blnResult = false;
                            ErrMsg = "Data Upload tidak tersedia.";
                            return Json(new { blnResult, ErrMsg, FileGuid = handle, FileName = sFileName });
                        }
                        if (dsData.Tables[1].Rows.Count <= 1)
                        {
                            blnResult = false;
                            ErrMsg = "Data tidak tersedia.";
                            return Json(new { blnResult, ErrMsg, FileGuid = handle, FileName = sFileName });
                        }

                        sSeparator = dsData.Tables[0].Rows[0][0].ToString();
                        sFileName = dsData.Tables[0].Rows[0][1].ToString();
                        sFormatFile = dsData.Tables[0].Rows[0][2].ToString();
                        sFilterFile = dsData.Tables[0].Rows[0][3].ToString();

                        bIsLog = bool.Parse(dsData.Tables[0].Rows[0]["IsLogged"].ToString());
                        bIsNeedAuth = bool.Parse(dsData.Tables[0].Rows[0]["IsdNeedApproval"].ToString());

                        if (!bIsNeedAuth)
                        {
                            if (!CreateFileUpload(sSeparator, sFileName, sFormatFile, sFilterFile, dsData, out handle, out ErrMsg))
                            {
                                blnResult = false;
                                ErrMsg = "Gagal create file.";
                                return Json(new { blnResult, ErrMsg, FileGuid = handle, FileName = sFileName });
                            }
                            else
                            {
                                blnResult = true;
                                ErrMsg = "Sukses Generate File Upload.";
                            }
                        }
                        else
                        {
                            ErrMsg = "Proses Generate Textfile memerlukan approval supervisor.";
                        }

                        if (bIsLog || bIsNeedAuth) // Insert Generate Log
                        {
                            if (this.sRealFileName == null)
                                this.sRealFileName = sFileName;

                            string sXMLDataGenerate = "";
                            string sXMLRawData = "";

                            using (StringWriter sw = new StringWriter())
                            {
                                dsData.Tables[1].WriteXml(sw);
                                result = sw.ToString();
                            }
                            if (dsData.Tables[2].Rows.Count == 0)
                            {
                                blnResult = false;
                                ErrMsg = "Data Ototisasi tidak tersedia.";
                                return Json(new { blnResult, ErrMsg, FileGuid = handle, FileName = sFileName });
                            }
                            if (dsData.Tables[2].Rows.Count > 0)
                            {
                                sXMLDataGenerate = result;
                                sXMLRawData = dsData.Tables[2].Rows[0][1].ToString();
                            }

                            blnResult = ReksaNFSInsertLogFile(FileCode, sFileName, _intNIK.ToString(), intTranDate, sXMLDataGenerate, sXMLRawData, bIsLog, bIsNeedAuth, out ErrMsg);
                            if (!blnResult)
                            {
                                ErrMsg = "Gagal Insert Log Data.";
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    ErrMsg = "Error Get Data Upload : " + e.Message;
                }
                return Json(new { blnResult, ErrMsg, FileGuid = handle, FileName = sFileName });
            }
        }     
        [HttpGet]
        public virtual ActionResult Download(string fileGuid, string fileName)
        {
            if (TempData[fileGuid] != null)
            {
                byte[] data = TempData[fileGuid] as byte[];
                return File(data, "text/plain", fileName+".txt");
            }
            else
            {
                // Problem - Log the error, generate a blank file,
                //           redirect to another controller action - whatever fits with your application
                return new EmptyResult();
            }
        }
        private void NFSGetFileTypeList(string strFileType, out List<FileModel.NFSFileListType> listType)
        {
            listType = new List<FileModel.NFSFileListType>();
            using (HttpClient client = new HttpClient())
            {
                try
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Report/NFSGetFileTypeList?FileType=" + strFileType).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    JToken strTokenFileType = strObject["listFileType"];
                    string strJsonFileType = JsonConvert.SerializeObject(strTokenFileType);
                    listType = JsonConvert.DeserializeObject<List<FileModel.NFSFileListType>>(strJsonFileType);
                }
                catch (Exception e)
                {
                    string strErr = e.ToString();
                }
            }
        }
        public ActionResult NFSGenerateFileDownload([FromBody] FileModel.CSVFormatFile model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string xmlData = "";
            DataSet dsXML = new DataSet();
            DataTable dtTable = new DataTable();
            dtTable.TableName = "Table";
            dtTable.Columns.Add("ClientCode");
            dtTable.Columns.Add("IFUA");
            dtTable.Columns.Add("SII");
            try
            {
                for (int i = 0; i < model.listKYC.Count; i++)
                {
                    DataRow dtrGL = dtTable.NewRow();
                    dtrGL["ClientCode"] = model.listKYC[i].ClientCode;
                    dtrGL["IFUA"] = model.listKYC[i].IFUA;
                    dtrGL["SII"] = model.listKYC[i].SII;
                    dtTable.Rows.Add(dtrGL);
                }
                dsXML.Tables.Add(dtTable);
                xmlData = dsXML.GetXml();

                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Report/NFSGenerateFileDownload?FileCode=" + model.FileCode + "&FileName=" + model.FileName + "&xmlData="+ xmlData + "&UserID=" + _intNIK).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg });
        }
        private bool ReksaNFSInsertLogFile(string sFileCode, string sFileName, string strUserID, int iTranDate, string sXMLDataGenerate, string sXMLRawData, bool bIsLog, bool bIsNeedAuth, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Report/NFSInsertLogFile?FileCode=" + sFileCode + "&FileName=" + sFileName + "&UserID=" + strUserID + "&TranDate=" + iTranDate + "&XMLDataGenerate=" + sXMLDataGenerate + "&XMLRawData=" + sXMLRawData + "&IsLog=" + bIsLog + "&IsNeedAuth=" + bIsNeedAuth).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
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
        private bool CreateFileUpload(string sSeparator, string sFileName, string sFormatFile, string sFilterFile, DataSet dsData, out string handle , out string strError)
        {
            int row, col;
            bool CreateTextFile = false;
            strError = "";
            handle = Guid.NewGuid().ToString();
            try
            {
                    //skyWriter = Path.GetDirectoryName("C:\\Users\\Hp\\Documents\\- PROJECTS -\\RESULT");
                    //StreamWriter streamWriter1 = new StreamWriter(skyWriter + "\\" + sFileName + "." + sFormatFile);
                    //this.sRealFileName = "C:\\Users\\Hp\\Documents\\- PROJECTS -\\RESULT";

                    if (dsData.Tables[1].Rows.Count > 0)
                    {
                    using (MemoryStream memoryStream = new MemoryStream())
                    using (var streamWriter = new StreamWriter(memoryStream))
                    {
                        for (row = 0; row < dsData.Tables[1].Rows.Count; row++)
                        {
                            for (col = 0; col < dsData.Tables[1].Columns.Count; col++)
                            {
                                if (col == dsData.Tables[1].Columns.Count - 1) //Data akhir
                                {
                                    streamWriter.WriteLine(dsData.Tables[1].Rows[row][col].ToString());
                                }
                                else
                                    streamWriter.Write(dsData.Tables[1].Rows[row][col].ToString() + sSeparator);
                            }
                        }
                        streamWriter.Flush();
                        TempData[handle] =  memoryStream.ToArray();
                    }
                    CreateTextFile = true;
                    }
                    else
                    {
                        strError = "Tidak ada data untuk periode tersebut. ";
                        CreateTextFile = false;
                    }                
            }

            catch (Exception ex)
            {
                strError = ex.Message;
                CreateTextFile = false;
            }
            return CreateTextFile;
        }
        private bool GetFormatFile(string strFileCode, out string ErrMsg)
        {
            bool bSuccess = false;
            ErrMsg = "";
            DataSet dsData = new DataSet();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Report/NFSGetFormatFile?FileCode=" + strFileCode).Result;
                    string stringData = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(stringData);
                    bSuccess = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenData = strObject["dsData"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);
                    dsData = JsonConvert.DeserializeObject<DataSet>(JsonData);
                }
                this.sSeparator = dsData.Tables[0].Rows[0][2].ToString();
                this.sFormatFile = dsData.Tables[0].Rows[0][3].ToString();
                this.sFilterFile = dsData.Tables[0].Rows[0][4].ToString();
                this.sFieldKey = dsData.Tables[0].Rows[0][5].ToString();
            }
            catch (Exception e)
            {
                ErrMsg = "Error Get Data Upload : " + e.Message;
            }
            return bSuccess;
        }
        private bool CreateTextFile(DataSet dsData, out string handle, out string strError)
        {
            int row;
            bool CreateTextFile = false;
            strError = "";
            handle = Guid.NewGuid().ToString();
            try
            {
                if (dsData.Tables[0].Rows.Count > 0)
                {
                    using (MemoryStream memoryStream = new MemoryStream())
                    using (var streamWriter = new StreamWriter(memoryStream))
                    {
                        for (row = 0; row < dsData.Tables[0].Rows.Count; row++)
                        {
                            streamWriter.WriteLine(dsData.Tables[0].Rows[row][0].ToString());
                        }
                        streamWriter.Flush();
                        TempData[handle] = memoryStream.ToArray();
                    }
                    CreateTextFile = true;
                }
                else
                {
                    strError = "Tidak ada data untuk bulan dan tahun tersebut. ";
                    CreateTextFile = false;
                }
            }

            catch (Exception ex)
            {
                strError = ex.Message;
                CreateTextFile = false;
            }
            return CreateTextFile;
        }
        public JsonResult PopulateOutgoingTT()
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<TransactionModel.OutgoingTT> listOutgoingTT = new List<TransactionModel.OutgoingTT>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Transaction/PopulateOutgoingTT").Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenOutgoingTT = strObject["listOutgoingTT"];
                    string JsonOutgoingTT = JsonConvert.SerializeObject(TokenOutgoingTT);
                    listOutgoingTT = JsonConvert.DeserializeObject<List<TransactionModel.OutgoingTT>>(JsonOutgoingTT);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, listOutgoingTT });
        }

        public JsonResult ReksaReportRDN07(string PeriodStart, string PeriodEnd, string CustodyName, int ProdId, string CustCode)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();
            try
            {
                RDN07Header RDN07Header = new RDN07Header();
                RDN07Header.PeriodStart = PeriodStart;
                RDN07Header.PeriodEnd = PeriodEnd;
                RDN07Header.CustodyName = CustodyName;
                _session.SetString("RDN07Header", JsonConvert.SerializeObject(RDN07Header));

                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Report/ReksaReportRDN07?PeriodStart=" + PeriodStart + "&PeriodEnd=" + PeriodEnd
                        + "&ProdId=" + ProdId + "&CustCode=" + CustCode).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken Token = strObject["dsReport"];
                    string Json = JsonConvert.SerializeObject(Token);
                    dsReport = JsonConvert.DeserializeObject<DataSet>(Json);
                    _session.SetString("RDN07", JsonConvert.SerializeObject(dsReport));
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        public JsonResult ReksaReportRDN08(string PeriodStart, string PeriodEnd, string ProdCode, int ProdId, string OfficeId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();
            try
            {
                RDN08Header RDN08Header = new RDN08Header();
                RDN08Header.PeriodStart = PeriodStart;
                RDN08Header.PeriodEnd = PeriodEnd;
                RDN08Header.ProdCode = ProdCode;
                RDN08Header.Branch = OfficeId;
                _session.SetString("RDN08Header", JsonConvert.SerializeObject(RDN08Header));
                
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Report/ReksaReportRDN08?PeriodStart=" + PeriodStart + "&PeriodEnd=" + PeriodEnd
                        + "&ProdCode=" + ProdId + "&OfficeId=" + OfficeId).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken Token = strObject["dsReport"];
                    string Json = JsonConvert.SerializeObject(Token);
                    dsReport = JsonConvert.DeserializeObject<DataSet>(Json);
                    _session.SetString("RDN08", JsonConvert.SerializeObject(dsReport));
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        public JsonResult ReksaReportRDN09(string TranDate, string ProdCode, int Region, string RegionName)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();
            try
            {
                RDN09Header RDN09Header = new RDN09Header();
                RDN09Header.TranDate = TranDate;
                RDN09Header.ProductCode = ProdCode;
                RDN09Header.RegionName = RegionName;
                _session.SetString("RDN09Header", JsonConvert.SerializeObject(RDN09Header));

                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Report/ReksaReportRDN09?TranDate=" + TranDate + "&Region=" + Region
                        + "&ProdCode=" + ProdCode).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken Token = strObject["dsReport"];
                    string Json = JsonConvert.SerializeObject(Token);
                    dsReport = JsonConvert.DeserializeObject<DataSet>(Json);
                    _session.SetString("RDN09", JsonConvert.SerializeObject(dsReport));
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        public JsonResult ReksaReportRDN10(string PeriodStart, string PeriodEnd, string ProdCode, int ProdId, string OfficeId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();
            try
            {
                RDN10Header RDN10Header = new RDN10Header();
                RDN10Header.PeriodStart = PeriodStart;
                RDN10Header.PeriodEnd = PeriodEnd;
                RDN10Header.ProdCode = ProdCode;
                RDN10Header.Branch = OfficeId;
                _session.SetString("RDN10Header", JsonConvert.SerializeObject(RDN10Header));

                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Report/ReksaReportRDN10?PeriodStart=" + PeriodStart + "&PeriodEnd=" + PeriodEnd
                        + "&ProdCode=" + ProdId + "&OfficeId=" + OfficeId).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken Token = strObject["dsReport"];
                    string Json = JsonConvert.SerializeObject(Token);
                    dsReport = JsonConvert.DeserializeObject<DataSet>(Json);
                    _session.SetString("RDN10", JsonConvert.SerializeObject(dsReport));
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        public JsonResult ReksaReportRDN11(string TranDate, string ProdCode, int Region, string RegionName)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();
            try
            {
                RDN11Header RDN11Header = new RDN11Header();
                RDN11Header.TranDate = TranDate;
                RDN11Header.ProductCode = ProdCode;
                RDN11Header.RegionName = RegionName;
                _session.SetString("RDN11Header", JsonConvert.SerializeObject(RDN11Header));

                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Report/ReksaReportRDN11?TranDate=" + TranDate + "&Region=" + Region
                        + "&ProdCode=" + ProdCode).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken Token = strObject["dsReport"];
                    string Json = JsonConvert.SerializeObject(Token);
                    dsReport = JsonConvert.DeserializeObject<DataSet>(Json);
                    _session.SetString("RDN11", JsonConvert.SerializeObject(dsReport));
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        public JsonResult ReksaReportRDN12(string Period, string ProdCode, int Region, string RegionName, string CIFStatus)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();
            try
            {
                RDN12Header RDN12Header = new RDN12Header();
                RDN12Header.Period = Period;
                RDN12Header.ProductCode = ProdCode;
                RDN12Header.RegionName = RegionName;
                _session.SetString("RDN12Header", JsonConvert.SerializeObject(RDN12Header));

                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Report/ReksaReportRDN12?Period=" + Period + "&Region=" + Region
                        + "&ProdCode=" + ProdCode + "&CIFStatus=" + CIFStatus).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken Token = strObject["dsReport"];
                    string Json = JsonConvert.SerializeObject(Token);
                    dsReport = JsonConvert.DeserializeObject<DataSet>(Json);
                    _session.SetString("RDN12", JsonConvert.SerializeObject(dsReport));
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        public JsonResult ReksaReportRDN13(string PeriodStart, string PeriodEnd, string ProdCode, int ProdId, string Type)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();
            try
            {
                RDN13Header RDN13Header = new RDN13Header();
                RDN13Header.PeriodStart = PeriodStart;
                RDN13Header.PeriodEnd = PeriodEnd;
                RDN13Header.ProdCode = ProdCode;
                RDN13Header.TipeProduk = Type;
                _session.SetString("RDN13Header", JsonConvert.SerializeObject(RDN13Header));

                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Report/ReksaReportRDN13?PeriodStart=" + PeriodStart + "&PeriodEnd=" + PeriodEnd
                        + "&ProdCode=" + ProdCode + "&Type=" + Type).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken Token = strObject["dsReport"];
                    string Json = JsonConvert.SerializeObject(Token);
                    dsReport = JsonConvert.DeserializeObject<DataSet>(Json);
                    _session.SetString("RDN13", JsonConvert.SerializeObject(dsReport));
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        public JsonResult ReksaReportRDN14(string PeriodStart, string PeriodEnd, string ProdCode, string Type, int Region, string RegionName)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();
            try
            {
                RDN14Header RDN14Header = new RDN14Header();
                RDN14Header.PeriodStart = PeriodStart;
                RDN14Header.PeriodEnd = PeriodEnd;
                RDN14Header.ProdCode = ProdCode;
                RDN14Header.RegionName = RegionName;
                _session.SetString("RDN14Header", JsonConvert.SerializeObject(RDN14Header));

                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Report/ReksaReportRDN14?PeriodStart=" + PeriodStart + "PeriodEnd=" + PeriodEnd + "&Region=" + Region
                        + "&ProdCode=" + ProdCode + "&Type=" + Type).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken Token = strObject["dsReport"];
                    string Json = JsonConvert.SerializeObject(Token);
                    dsReport = JsonConvert.DeserializeObject<DataSet>(Json);
                    _session.SetString("RDN14", JsonConvert.SerializeObject(dsReport));
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        public JsonResult ReksaReportRDN24()
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Report/ReksaReportRDN24").Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken Token = strObject["dsReport"];
                    string Json = JsonConvert.SerializeObject(Token);
                    dsReport = JsonConvert.DeserializeObject<DataSet>(Json);
                    _session.SetString("RDN24", JsonConvert.SerializeObject(dsReport));
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        public JsonResult ReksaReportRDN26()
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Report/ReksaReportRDN26").Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken Token = strObject["dsReport"];
                    string Json = JsonConvert.SerializeObject(Token);
                    dsReport = JsonConvert.DeserializeObject<DataSet>(Json);
                    _session.SetString("RDN26", JsonConvert.SerializeObject(dsReport));
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        public JsonResult ReksaReportRDN63(string Period)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();
            decimal TotalPremi = 0;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Report/ReksaReportRDN63?Period=" + Period).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    TotalPremi = strObject.SelectToken("totalPremi").Value<decimal>();
                    JToken Token = strObject["dsReport"];
                    string Json = JsonConvert.SerializeObject(Token);
                    dsReport = JsonConvert.DeserializeObject<DataSet>(Json);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, dsReport, TotalPremi });
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
    }
}
