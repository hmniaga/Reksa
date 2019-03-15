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

        public JsonResult NFSGenerateFileUpload(string FileCode, string TranDate)
        {
            List<FileModel.NFSFileListType> listType = new List<FileModel.NFSFileListType>();
            int.TryParse(TranDate, out int intTrandate);
            NFSGenerateFileUpload(@"D:\", FileCode, intTrandate);
            return Json(listType);
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

        private void NFSGenerateFileUpload(string sPath, string strFileCode, int iTranDate)
        {
            string strErr = "";
            using (HttpClient client = new HttpClient())
            {
                DataSet dsData;
                string sSeparator, sFileName, sFormatFile, sFilterFile;
                bool bIsLog, bIsNeedAuth;
                bIsLog = false;
                bIsNeedAuth = false;
                try
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Report/NFSGenerateFileUpload?FileCode=" + strFileCode + "&TranDate=" + iTranDate).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    dsData = JsonConvert.DeserializeObject<System.Data.DataSet>(strJson);

                    if (Convert.ToBoolean(dsData.Tables[0].Rows[0]["IsdNeedApproval"]) == true)
                    {
                        if (dsData.Tables[2].Rows[0]["XMLData"].ToString() == "" || dsData.Tables[2].Rows[0]["XMLRawData"].ToString() == "")
                            throw new Exception("Data tidak tersedia.");
                    }
                    if (dsData.Tables[0].Rows.Count == 0)
                        throw new Exception("Data Parameter tidak tersedia.");

                    if (dsData.Tables[1].Rows.Count == 0)
                        throw new Exception("Data Upload tidak tersedia.");

                    if (dsData.Tables[1].Rows.Count <= 1)
                        throw new Exception("Data tidak tersedia.");

                    sSeparator = dsData.Tables[0].Rows[0][0].ToString();
                    sFileName = dsData.Tables[0].Rows[0][1].ToString();
                    sFormatFile = dsData.Tables[0].Rows[0][2].ToString();
                    sFilterFile = dsData.Tables[0].Rows[0][3].ToString();

                    bIsLog = bool.Parse(dsData.Tables[0].Rows[0]["IsLogged"].ToString());
                    bIsNeedAuth = bool.Parse(dsData.Tables[0].Rows[0]["IsdNeedApproval"].ToString());

                    if (!bIsNeedAuth)
                    {
                        if (!CreateFileUpload(sPath, sSeparator, sFileName, sFormatFile, sFilterFile, dsData))
                            throw new Exception("Gagal create file.");

                        strErr = "Sukses Generate File Upload.";
                    }
                    else
                    {
                        strErr = "Proses Generate Textfile memerlukan approval supervisor.";
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
                            throw new Exception("Data Ototisasi tidak tersedia.");

                        if (dsData.Tables[2].Rows.Count > 0)
                        {
                            sXMLDataGenerate = result;
                            sXMLRawData = dsData.Tables[2].Rows[0][1].ToString();
                        }

                        ReksaNFSInsertLogFile(strFileCode, sFileName, _intNIK.ToString(), iTranDate, sXMLDataGenerate, sXMLRawData, bIsLog, bIsNeedAuth);
                    }
                }
                catch (Exception e)
                {
                    strErr = e.ToString();
                }
            }
        }


        private void ReksaNFSInsertLogFile(string sFileCode, string sFileName, string strUserID, 
            int iTranDate, string sXMLDataGenerate, string sXMLRawData, bool bIsLog, bool bIsNeedAuth)
        {
            string strErr = "";
            using (HttpClient client = new HttpClient())
            {
                try
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Report/NFSInsertLogFile?FileCode=" + sFileCode + "&FileName=" + sFileName + "&UserID=" + strUserID + "&TranDate=" + iTranDate + "&XMLDataGenerate=" + sXMLDataGenerate + "&XMLRawData=" + sXMLRawData + "&IsLog=" + bIsLog + "&IsNeedAuth=" + bIsNeedAuth).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    strErr = JsonConvert.DeserializeObject<string>(strJson);
                }
                catch (Exception e)
                {
                    strErr = e.ToString();
                }
            }
        }

        private bool CreateFileUpload(string strPath, string sSeparator, string sFileName, string sFormatFile, string sFilterFile, DataSet dsData)
        {
            int row, col;
            bool CreateTextFile = false;
            string strError = "";

            try
            {
                if (strPath != "")
                {
                    skyWriter = Path.GetDirectoryName(strPath);
                    StreamWriter streamWriter1 = new StreamWriter(skyWriter + "\\" + sFileName + "." + sFormatFile);
                    this.sRealFileName = strPath;

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
            }

            catch (Exception ex)
            {
                strError = ex.Message;
                CreateTextFile = false;
            }

            return CreateTextFile;
        }
    }
}
