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

namespace Reksa.Controllers
{
    //[Route("api/[controller]")]
    //[ApiController]
    public class ReportController : Controller
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

        private string sRealFileName;
        private string result;
        private string skyWriter;
        private clsCSVFormat csv;
        private string sSeparator = "", sFileName = "", sFormatFile = "", sFilterFile = "", sFieldKey = "", sFileCode = "";
        string sXMLData;

        public ReportController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
        }

        public IActionResult NFSUpload()
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
        public JsonResult NFSGenerateFileUpload(string FileCode, string TranDate)
        {
            bool blnResult = false;
            string ErrMsg = "";
            using (HttpClient client = new HttpClient())
            {
                DataSet dsData;
                string sSeparator, sFileName, sFormatFile, sFilterFile;
                bool bIsLog, bIsNeedAuth;
                bIsLog = false;
                bIsNeedAuth = false;
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
                            }
                        }
                        if (dsData.Tables[0].Rows.Count == 0)
                        {
                            blnResult = false;
                            ErrMsg = "Data Parameter tidak tersedia.";
                        }
                        if (dsData.Tables[1].Rows.Count == 0)
                        {
                            blnResult = false;
                            ErrMsg = "Data Upload tidak tersedia.";
                        }
                        if (dsData.Tables[1].Rows.Count <= 1)
                        {
                            blnResult = false;
                            ErrMsg = "Data tidak tersedia.";
                        }

                        sSeparator = dsData.Tables[0].Rows[0][0].ToString();
                        sFileName = dsData.Tables[0].Rows[0][1].ToString();
                        sFormatFile = dsData.Tables[0].Rows[0][2].ToString();
                        sFilterFile = dsData.Tables[0].Rows[0][3].ToString();

                        bIsLog = bool.Parse(dsData.Tables[0].Rows[0]["IsLogged"].ToString());
                        bIsNeedAuth = bool.Parse(dsData.Tables[0].Rows[0]["IsdNeedApproval"].ToString());

                        if (!bIsNeedAuth)
                        {
                            if (!CreateFileUpload(sSeparator, sFileName, sFormatFile, sFilterFile, dsData))
                            {
                                blnResult = false;
                                ErrMsg = "Gagal create file.";
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
                return Json(new { blnResult, ErrMsg });
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

        private void NFSGenerateFileDownload(string strFileCode, int iTranDate)
        {
            
            
        }


        private bool ReksaNFSInsertLogFile(string sFileCode, string sFileName, string strUserID, 
            int iTranDate, string sXMLDataGenerate, string sXMLRawData, bool bIsLog, bool bIsNeedAuth, out string ErrMsg)
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

        private bool CreateFileUpload(string sSeparator, string sFileName, string sFormatFile, string sFilterFile, DataSet dsData)
        {
            int row, col;
            bool CreateTextFile = false;
            string strError = "";

            try
            {
                    skyWriter = Path.GetDirectoryName("C:\\Users\\Hp\\Documents\\- PROJECTS -\\RESULT");
                    StreamWriter streamWriter1 = new StreamWriter(skyWriter + "\\" + sFileName + "." + sFormatFile);
                    this.sRealFileName = "C:\\Users\\Hp\\Documents\\- PROJECTS -\\RESULT";

                    if (dsData.Tables[1].Rows.Count > 0)
                    {
                        for (row = 0; row < dsData.Tables[1].Rows.Count; row++)
                        {
                            for (col = 0; col < dsData.Tables[1].Columns.Count; col++)
                            {
                                if (col == dsData.Tables[1].Columns.Count - 1) //Data akhir
                                {
                                    streamWriter1.WriteLine(dsData.Tables[1].Rows[row][col].ToString());
                                }
                                else
                                    streamWriter1.Write(dsData.Tables[1].Rows[row][col].ToString() + sSeparator);
                            }
                        }

                        CreateTextFile = true;
                    }
                    else
                    {
                        strError = "Tidak ada data untuk periode tersebut. ";
                        CreateTextFile = false;
                    }
                    streamWriter1.Flush();
                    streamWriter1.Close();
                
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
    }
}
