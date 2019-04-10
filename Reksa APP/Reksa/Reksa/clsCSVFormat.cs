using Kendo.Mvc.UI;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Xml;
using static System.Net.Mime.MediaTypeNames;

namespace Reksa
{
    class clsCSVFormat
    {
        private DataSet _dsData;
        public clsCSVFormat(DataSet dsData)
        {
            _dsData = dsData;
        }
        public bool GetCSVFile(string txtFilePath, string[] dataColumn, out string sXMLData, out string ErrMsg)
        {
            bool bSuccess;
            GetCSVFile(txtFilePath, dataColumn, 0, out sXMLData, out bSuccess, out ErrMsg);

            return bSuccess;
        }
        public void GetCSVFile(string txtFilePath, string[] dataColumn, int limitRow, out string sXMLDataSet, out bool bSuccess, out string ErrMsg)
        {
            bSuccess = true;
            sXMLDataSet = "";
            ErrMsg = "";

            StreamReader sRead = null;
            XmlTextReader xXMLReader = null;
            XmlReader xReader = null;
            try
            {
                sRead = new StreamReader(txtFilePath);
                string[] sColumns = null;
                string sLine = "";
                sXMLDataSet = "<NewDataSet>" + Environment.NewLine;

                int i = 0;

                while ((sLine = sRead.ReadLine()) != null)
                {
                    i++;
                    string[] sRecords = sLine.Trim().Split(new char[] { ',', ';' }, StringSplitOptions.None);
                    if (i.Equals(1))
                    {
                        sColumns = new string[sRecords.Length];
                        for (int idx = 0; idx < sRecords.Length; idx++)
                            sColumns[idx] = sRecords[idx];
                        continue;
                    }

                    sXMLDataSet += "<Table>" + Environment.NewLine;
                    for (int idx = 0; idx < sRecords.Length; idx++)
                    {
                        sXMLDataSet += "<" + this.XMLCompatible(sColumns[idx]) + ">" + this.XMLCompatible(sRecords[idx]) + "</" + this.XMLCompatible(sColumns[idx]) + ">" + Environment.NewLine;
                        //Application.DoEvents();
                    }
                    sXMLDataSet += "</Table>" + Environment.NewLine;

                    if (!limitRow.Equals(0) && i.Equals(limitRow + 1)) break;
                    //Application.DoEvents();
                }

                sXMLDataSet += "</NewDataSet>";
                sRead.Close();
                sRead.Dispose();
                sRead = null;
                _dsData.Reset();
                XmlReaderSettings xSettings = new XmlReaderSettings();
                xSettings.ValidationType = ValidationType.None;

                xXMLReader = new XmlTextReader(new StringReader(sXMLDataSet));
                xReader = XmlReader.Create(xXMLReader, xSettings);
                _dsData.Clear();
                _dsData.ReadXml(xReader);

                xXMLReader.Close();
                xReader.Close();
                xXMLReader = null;
                xReader = null;

                if (!_dsData.Tables[0].Columns.Count.Equals(dataColumn.Length))
                {
                    string strEx = "Jumlah Data Column Salah!" + Environment.NewLine;
                    for (int idx = 0; idx < dataColumn.Length; idx++)
                        strEx += "Kolom " + (idx + 1).ToString() + ": " + dataColumn[idx] + Environment.NewLine;

                    throw new Exception(strEx);
                }

                string strExc = "";
                for (int idx = 0; idx < dataColumn.Length; idx++)
                {
                    if (!_dsData.Tables[0].Columns[idx].ColumnName.Equals(dataColumn[idx].ToString()))
                        strExc += "Kolom " + (idx + 1).ToString() + ": " + dataColumn[idx] + " ( Actual in File Upload: " + _dsData.Tables[0].Columns[idx].ColumnName + " )" + Environment.NewLine;
                    //Application.DoEvents();
                }
                if (!strExc.Equals("")) throw new Exception("Field Data Column Salah!" + Environment.NewLine + strExc);
            }
            catch (NullReferenceException)
            {
                _dsData.Reset();
                bSuccess = false;
            }
            catch (Exception ex)
            {
                ErrMsg = "Pengambilan data gagal ! " + ex.Message;
                _dsData.Reset();
                bSuccess = false;
            }
        }
        private string XMLCompatible(string strData)
        {
            strData = strData.Replace("&amp;", "&").Replace("&gt;", ">").Replace("&lt;", "<").Replace("&apos;", "'").Replace("&quot;", "\"");
            strData = strData.Replace("&", "&amp;").Replace(">", "&gt;").Replace("<", "&lt;").Replace("'", "&apos;").Replace("\"", "&quot;");
            return strData;
        }
    }
}
