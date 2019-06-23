using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;
using Microsoft.Extensions.Configuration;
using ReksaQuery;
using ReksaAPI.Models;
using Microsoft.AspNetCore.Mvc.Rendering;
using System.Linq;

namespace ReksaAPI
{
    public class clsDataAccess
    {
        private IConfiguration _config;
        private string _errorMessage = "";

        public clsDataAccess(IConfiguration config)
        {
            _config = config;
        }

        #region "SETTINGS"
        public ClsQuery QueryReksa()
        {
            ClsQuery _cq = new ClsQuery();
            //AppSettingsReader _app = new AppSettingsReader();
            //int SCPAuth;
            //string[] str;
            string _ReksaUserName, _ReksaPassword, _ReksaServer;

            try
            {
                //int.TryParse(_app.GetValue("DBServerIDSCP", Type.GetType("System.String")).ToString(), out SCPAuth);
                //using (InitializeUserDB initUser = new InitializeUserDB())
                //{
                //    str = initUser.GetUserLogin(SCPAuth);
                //}
                _ReksaUserName = _config.GetValue<string>("SQLConnection:Username");
                _ReksaPassword = _config.GetValue<string>("SQLConnection:Password");
                _ReksaServer = _config.GetValue<string>("SQLConnection:Server");
            }
            catch (Exception ex)
            {
                throw new Exception("QueryReksa - " + ex.Message);
            }

            _cq.Server = _ReksaServer;
            _cq.Database = _config.GetValue<string>("SQLConnection:Database");
            _cq.UserName = _ReksaUserName;
            _cq.Password = _ReksaPassword;
            _cq.isErrorExtHandled = true;
            ClsQuery.queError.Clear();

            return _cq;
        }
        public ClsQuery QueryCustomer()
        {
            ClsQuery _cq = new ClsQuery();
            //AppSettingsReader _app = new AppSettingsReader();
            //int SCPAuth;
            //string[] str;
            string _CustUserName, _CustPassword, _CustServer;

            try
            {
                //int.TryParse(_app.GetValue("DBServerIDSCP", Type.GetType("System.String")).ToString(), out SCPAuth);
                //using (InitializeUserDB initUser = new InitializeUserDB())
                //{
                //    str = initUser.GetUserLogin(SCPAuth);
                //}
                _CustUserName = _config.GetValue<string>("SQLConnectionCust:Username");
                _CustPassword = _config.GetValue<string>("SQLConnectionCust:Password");
                _CustServer = _config.GetValue<string>("SQLConnectionCust:Server");
            }
            catch (Exception ex)
            {
                throw new Exception("QueryReksa - " + ex.Message);
            }

            _cq.Server = _CustServer;
            _cq.Database = _config.GetValue<string>("SQLConnectionCust:Database");
            _cq.UserName = _CustUserName;
            _cq.Password = _CustPassword;
            _cq.isErrorExtHandled = true;
            ClsQuery.queError.Clear();
            return _cq;
        }
        public bool ExecProc(ClsQuery clsQuery, string strProc, ref List<SqlParameter> dbParam, out SqlCommand cmdOut, out string ErrMsg)
        {
            ErrMsg = "";
            bool result = true;
            cmdOut = new SqlCommand();

            try
            {
                result = clsQuery.ExecProc(strProc, ref dbParam, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
                result = false;
            }

            return result;
        }
        //private bool ExecProc(ClsQuery clsQuery, string strProc, ref List<SqlParameter> dbParam, out DataSet dsResult)
        //{
        //    dsResult = null;
        //    _errorMessage = "";
        //    bool result = true;

        //    try
        //    {
        //        clsQuery.ExecProc(strProc, ref dbParam, out dsResult);
        //    }
        //    catch (Exception ex)
        //    {
        //        _errorMessage = ex.Message;
        //        result = false;
        //    }

        //    if (ClsQuery.queError.Count > 0)
        //    {
        //        string[] sErr = (string[])ClsQuery.queError.Dequeue();
        //        if (sErr.Length > 0)
        //            _errorMessage = "";
        //        for (int i = 0; i < sErr.Length; i++)
        //        {
        //            if (!sErr[i].Contains("Microsoft"))
        //                _errorMessage = _errorMessage + sErr[i].ToString() + "\n";
        //        }
        //        ClsQuery.queError.Clear();
        //        result = false;
        //    }
        //    if (!_errorMessage.Equals(""))
        //    {
        //        throw new Exception(strProc + " - " + _errorMessage);
        //    }

        //    return result;
        //}
        private bool ExecProc(ClsQuery clsQuery, string strProc, ref List<SqlParameter> dbParam, out DataSet dsResult, out SqlCommand cmdOut, out string ErrMsg)
        {
            dsResult = null;
            ErrMsg = "";
            bool result = true;
            cmdOut = new SqlCommand();

            try
            {
                result = clsQuery.ExecProc(strProc, ref dbParam, out dsResult, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
                result = false;
            }

            return result;
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


        public string fnCreateCommand1(string strCmd, DataTable SelectedTable, int intNIK, string strGuid, 
            out List<SqlParameter> parameters, out string selectedId, Int32 intDSMainRow)
        {
            selectedId = "";
            string[] strArCmd = strCmd.Split('&');
            string[] strParams;

            parameters = new List<SqlParameter>();
            
            Int32 intCounter = 0;

            for (intCounter = 1; intCounter < strArCmd.Length; intCounter++)
            {
                SqlParameter param = new SqlParameter();
                strParams = strArCmd[intCounter].Split('|');

                if (strParams[0] == "I")
                {
                    param.ParameterName = strParams[3];
                    param.SqlDbType = System.Data.SqlDbType.Int;
                }

                else if (strParams[0] == "V")
                {
                    param.ParameterName = strParams[3];
                    param.SqlDbType = System.Data.SqlDbType.VarChar;
                    param.Size = System.Convert.ToInt32(strParams[1]);
                }
                else if (strParams[0] == "M")
                {
                    param.ParameterName = strParams[3];
                    param.SqlDbType = System.Data.SqlDbType.Decimal;
                }
                else if (strParams[0] == "B")
                {
                    param.ParameterName = strParams[3];
                    param.SqlDbType = System.Data.SqlDbType.TinyInt;
                }

                if (strParams[2] == "I")
                    param.Direction = System.Data.ParameterDirection.Input;
                else if (strParams[2] == "O")
                    param.Direction = System.Data.ParameterDirection.Output;
                else if (strParams[2] == "IO")
                    param.Direction = System.Data.ParameterDirection.InputOutput;

                if ((strParams[3] == "@cNik") || (strParams[3] == "@pnNIK"))
                {
                    param.Value = intNIK;
                }
                else if (strParams[3] == "@pcGuid")
                {
                    param.Value = strGuid;
                }
                else if (strParams[4].Substring(0, 1) == "!")
                {
                    string strColName = strParams[4].Replace("!", "");
                    param.Value = SelectedTable.Rows[intDSMainRow][strColName].ToString();
                    selectedId = SelectedTable.Rows[intDSMainRow][strColName].ToString();
                }
                else if (strParams[4].Substring(0, 1) != "")
                    param.Value = strParams[4];

                parameters.Add(param);
            }
            strCmd = strArCmd[0];
            return strCmd;

        }
        #endregion

        #region "REPLICATE DATA"
        public bool GetParameterTableCustomer(string strProcedure, out DataSet dsOut, out string ErrMsg)
        {
            bool blnReturn = false;
            ErrMsg = "";

           dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParamCust = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcProcedureName", SqlDbType = System.Data.SqlDbType.VarChar, Value = strProcedure, Direction = System.Data.ParameterDirection.Input}
                };
                blnReturn = this.ExecProc(QueryReksa(), "GetParameterTableCustomer", ref dbParamCust, out dsOut, out cmdOut, out ErrMsg);
                if (blnReturn)
                {
                    if (dsOut == null && dsOut.Tables.Count <= 0 && dsOut.Tables[0].Rows.Count <= 0)
                    {
                        blnReturn = false;
                        ErrMsg = "GetParameterTableCustomer : Procedure - " + strProcedure + " Data tidak di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnReturn;
        }
        public bool setDataCustomerByTable(string strID, string strTableName, string strKey, out string ErrMsg)
        {
            bool blnReturn = false;
            ErrMsg = "";

            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParamCust = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcID", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcTable", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strTableName, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcKey", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strKey, Direction = System.Data.ParameterDirection.Input}
                };
                blnReturn = this.ExecProc(QueryCustomer(), "GetDataCustomer", ref dbParamCust, out dsOut, out cmdOut, out ErrMsg);
                if (blnReturn)
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        string strXMl = dsOut.GetXml();
                        List<SqlParameter> dbParam = new List<SqlParameter>()
                        {
                            new SqlParameter() { ParameterName = "@pcTable", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTableName, Direction = System.Data.ParameterDirection.Input},
                            new SqlParameter() { ParameterName = "@pxData", SqlDbType = System.Data.SqlDbType.Xml, Value = strXMl, Direction = System.Data.ParameterDirection.Input}
                        };
                        blnReturn = this.ExecProc(QueryReksa(), "setDataCustomer", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
                    }
                    else
                    {
                        blnReturn = false;
                        ErrMsg = "Error : Data Customer Table" + strTableName + " Kosong";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnReturn;
        }
        public bool setDataCustomerByProcedure(string strID, string strProcedure, out string ErrMsg)
        {
            bool blnReturn = false;
            ErrMsg = "";
            
            DataSet dsOut = new DataSet();
            DataSet dsParam = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                blnReturn = this.GetParameterTableCustomer(strProcedure, out dsParam, out ErrMsg);
                if (blnReturn && dsParam != null && dsParam.Tables.Count > 0 && dsParam.Tables[0].Rows.Count > 0)
                {
                    for (int i = 0; i <= dsParam.Tables[0].Rows.Count; i++)
                    {
                        List<SqlParameter> dbParamCust = new List<SqlParameter>()
                        {
                            new SqlParameter() { ParameterName = "@pcID", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strID, Direction = System.Data.ParameterDirection.Input},
                            new SqlParameter() { ParameterName = "@pcTable", SqlDbType = System.Data.SqlDbType.NVarChar, Value = dsParam.Tables[0].Rows[i]["TablesName"].ToString(), Direction = System.Data.ParameterDirection.Input},
                            new SqlParameter() { ParameterName = "@pcKey", SqlDbType = System.Data.SqlDbType.NVarChar, Value = dsParam.Tables[0].Rows[i]["Keys"].ToString(), Direction = System.Data.ParameterDirection.Input}
                        };
                        blnReturn = this.ExecProc(QueryCustomer(), "GetDataCustomer", ref dbParamCust, out dsOut, out cmdOut, out ErrMsg);
                        if (blnReturn)
                        {
                            string strXMl = dsOut.GetXml();
                            List<SqlParameter> dbParam = new List<SqlParameter>()
                            {
                                new SqlParameter() { ParameterName = "@pcTable", SqlDbType = System.Data.SqlDbType.VarChar, Value = dsParam.Tables[0].Rows[i]["TablesName"].ToString(), Direction = System.Data.ParameterDirection.Input},
                                new SqlParameter() { ParameterName = "@pxData", SqlDbType = System.Data.SqlDbType.Xml, Value = strXMl, Direction = System.Data.ParameterDirection.Input}
                            };
                            blnReturn = this.ExecProc(QueryReksa(), "setDataCustomer", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
                            if (!blnReturn)
                            {
                                return blnReturn;
                            }
                        }
                        else
                        {
                            return blnReturn;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnReturn;
        }
        public void clearDATA(string strTable)
        {
            //bool blnReturn = false;
            string ErrMsg = "";
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcTable", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTable, Direction = System.Data.ParameterDirection.Input}
                };
                if (this.ExecProc(QueryReksa(), "clearDataCustomer", ref dbParam, out cmdOut, out ErrMsg))
                {
                    //blnReturn = true;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            //return blnReturn;
        }
        #endregion

        #region "GLOBAL"
        public bool ReksaGetMenuReportRDN(out List<ReportMenuModel> list, out string ErrMsg)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            bool blnResult = false;
            ErrMsg = "";
            list = new List<ReportMenuModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>();
                if (this.ExecProc(QueryReksa(), "ReksaGetMenuReportRDN", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    DataTable dtOut = dsOut.Tables[0];
                    List<ReportMenuModel> result = this.MapListOfObject<ReportMenuModel>(dtOut);
                    list.AddRange(result);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaGetDataPeopleSoft(int intNIK, ref string ErrMessage, out string[] strData)
        {
            ErrMessage = "";
            strData = new string[2];
            bool blnResult = false;

            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input}
                };                
                if (this.ExecProc(QueryReksa(), "ReksaGetDataPeopleSoft", ref dbParam, out dsOut, out cmdOut, out ErrMessage))
                {
                    strData[0] = dsOut.Tables[0].Rows[0]["NAME"].ToString();
                    strData[1] = dsOut.Tables[0].Rows[0]["JOBTITLE"].ToString();
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                ErrMessage = ex.Message;
                throw ex;
            }
            return blnResult;
        }
        public bool ReksaCekNotifikasiBS(string SelectedId, string TreeId, string strCheckType, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            int intSelectedId;
            int.TryParse(SelectedId, out intSelectedId);
            
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnId", SqlDbType = System.Data.SqlDbType.Int, Value = intSelectedId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcTreeId", SqlDbType = System.Data.SqlDbType.VarChar, Value = TreeId, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcErrMessage", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 500},
                    new SqlParameter() { ParameterName = "@pcCheckingType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCheckType, Direction = System.Data.ParameterDirection.Input }
                };
                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaCekNotifikasiBS", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    ErrMsg = cmdOut.Parameters["@pcErrMessage"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaCekTieringNotification(string SelectedId, string TreeId, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            int intSelectedId;
            int.TryParse(SelectedId, out intSelectedId);

            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnTranId", SqlDbType = System.Data.SqlDbType.Int, Value = intSelectedId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcTreeId", SqlDbType = System.Data.SqlDbType.VarChar, Value = TreeId, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcErrMessage", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 500}
                };
                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaCekTieringNotification", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    ErrMsg = cmdOut.Parameters["@pcErrMessage"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public List<SearchModel.FrekuensiDebet> ReksaPopulateCombo()
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            List<SearchModel.FrekuensiDebet> list = new List<SearchModel.FrekuensiDebet>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>();
                if (this.ExecProc(QueryReksa(), "ReksaPopulateCombo", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    DataTable dtOut = dsOut.Tables[0];

                    List<SearchModel.FrekuensiDebet> result = this.MapListOfObject<SearchModel.FrekuensiDebet>(dtOut);
                    list.AddRange(result);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public int ReksaHitungUmur(string strCIFNo)
        {
            string ErrMsg = "";
            int intUmur = 0;
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnUmur", SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Output }
                };
                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaHitungUmur", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    int.TryParse(cmdOut.Parameters["@pnUmur"].Value.ToString(), out intUmur);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return intUmur;
        }
        public bool ReksaGetNoNPWPCounter(out string strNoDocNPWP, out string ErrMsg)
        {
            bool blnResult = false;
            strNoDocNPWP = "";
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>();
                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaGetNoNPWPCounter", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        strNoDocNPWP = dsOut.Tables[0].Rows[0]["NoDocNPWP"].ToString();
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Gagal ambil data NPWP Counter";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public List<TreeViewModel> ReksaGetTreeView(int intNIK, string strModule, string strMenu)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<TreeViewModel> list = new List<TreeViewModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcMenuName", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strMenu, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "UserGetTreeView", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<TreeViewModel> result = this.MapListOfObject<TreeViewModel>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<CommonTreeViewModel> ReksaGetCommonTreeView(int intNIK, string strModule, string strMenu)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";

            DataSet dsOut = new DataSet();
            List<CommonTreeViewModel> list = new List<CommonTreeViewModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cMenu", SqlDbType = System.Data.SqlDbType.VarChar, Value = strMenu, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@nNik", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "common2_populate_tree", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<CommonTreeViewModel> result = this.MapListOfObject<CommonTreeViewModel>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public bool ReksaGlobalQuery(bool hasResult, string strCommand, List<SqlParameter> listParam, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            List<CommonTreeViewModel> list = new List<CommonTreeViewModel>();
            try
            {
                if (hasResult)
                {
                    if (this.ExecProc(QueryReksa(), strCommand, ref listParam, out dsOut, out cmdOut, out ErrMsg))
                    {
                        if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                        {
                            blnResult = true;
                        }
                        else
                        {
                            ErrMsg = "Data tidak ada di database";
                        }
                    }
                }
                else
                {
                    blnResult = this.ExecProc(QueryReksa(), strCommand, ref listParam, out cmdOut, out ErrMsg);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaValidateCBOOfficeId(string strOfficeID, out string IsEnable, out string strErrorMessage)
        {
            DataSet dsOut = new DataSet();
            IsEnable = ""; strErrorMessage = ""; string strErrorCode = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcOfficeId", SqlDbType = System.Data.SqlDbType.VarChar, Value = strOfficeID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcIsEnable", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 1},
                    new SqlParameter() { ParameterName = "@pcErrorMessage", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 500},
                    new SqlParameter() { ParameterName = "@pcErrorCode", SqlDbType = System.Data.SqlDbType.Char, Direction = System.Data.ParameterDirection.Output, Size = 2}
                };
                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaValidateCBOOfficeId", ref dbParam, out dsOut, out cmdOut, out strErrorMessage))
                {
                    IsEnable = cmdOut.Parameters["@pcIsEnable"].Value.ToString();
                    strErrorMessage = cmdOut.Parameters["@pcErrorMessage"].Value.ToString();
                    strErrorCode = cmdOut.Parameters["@pcErrorCode"].Value.ToString();

                    if (strErrorCode != "00")
                        return false;
                    else
                        return true;
                }
            }
            catch (Exception ex)
            {
                strErrorMessage = ex.Message;
                return false;
            }
            return false;
        }

        public List<SearchModel.Agen> ReksaSrcAgen(string Col1, string Col2, int Validate, int ProdId)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Agen> list = new List<SearchModel.Agen>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cProdId", SqlDbType = System.Data.SqlDbType.Int, Value = ProdId, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcAgen", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<SearchModel.Agen> result = this.MapListOfObject<SearchModel.Agen>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Bank> ReksaSrcBank(string Col1, string Col2, int Validate, int ProdId)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Bank> list = new List<SearchModel.Bank>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cProdId", SqlDbType = System.Data.SqlDbType.Int, Value = ProdId, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcBank", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.Bank> result = this.MapListOfObject<SearchModel.Bank>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.BankCode> ReksaSrcBankCode(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.BankCode> list = new List<SearchModel.BankCode>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaScrBankCode", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.BankCode> result = this.MapListOfObject<SearchModel.BankCode>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Booking> ReksaSrcBooking(string Col1, string Col2, int Validate, string criteria)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Booking> list = new List<SearchModel.Booking>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cCriteria", SqlDbType = System.Data.SqlDbType.NVarChar, Value = criteria, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcBooking", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.Booking> result = this.MapListOfObject<SearchModel.Booking>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.CalcDevident> ReksaSrcCalc(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.CalcDevident> list = new List<SearchModel.CalcDevident>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcCalc", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.CalcDevident> result = this.MapListOfObject<SearchModel.CalcDevident>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Client> ReksaSrcClient(string Col1, string Col2, int Validate, int ProdId)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Client> list = new List<SearchModel.Client>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cProdId", SqlDbType = System.Data.SqlDbType.Int, Value = ProdId, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcClient", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.Client> result = this.MapListOfObject<SearchModel.Client>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }

        public List<SearchModel.Client> ReksaSrcClientbyCIF(string Col1, string Col2, int Validate, string strCIFNo)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Client> list = new List<SearchModel.Client>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcClientbyCIF", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.Client> result = this.MapListOfObject<SearchModel.Client>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.City> ReksaSrcCity(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.City> list = new List<SearchModel.City>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcCity", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<SearchModel.City> result = this.MapListOfObject<SearchModel.City>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Customer> ReksaSrcCIFAll(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Customer> list = new List<SearchModel.Customer>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcCIFAll", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.Customer> result = this.MapListOfObject<SearchModel.Customer>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }

        public List<SearchModel.Customer> ReksaSrcCIF(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Customer> list = new List<SearchModel.Customer>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                };

                if (this.ExecProc(QueryCustomer(), "SIBSSrcCIF", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<SearchModel.Customer> result = this.MapListOfObject<SearchModel.Customer>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Custody> ReksaSrcCustody(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Custody> list = new List<SearchModel.Custody>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcCustody", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<SearchModel.Custody> result = this.MapListOfObject<SearchModel.Custody>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Customer> ReksaSrcCustomer(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Customer> list = new List<SearchModel.Customer>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcCIF", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<SearchModel.Customer> result = this.MapListOfObject<SearchModel.Customer>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Currency> ReksaSrcCurrency(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Currency> list = new List<SearchModel.Currency>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcCurrency", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.Currency> result = this.MapListOfObject<SearchModel.Currency>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Office> ReksaSrcOffice(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            List<SearchModel.Office> list = new List<SearchModel.Office>();
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcOffice", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.Office> result = this.MapListOfObject<SearchModel.Office>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Product> ReksaSrcProduct(string Col1, string Col2, int Validate, int Status)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Product> list = new List<SearchModel.Product>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cStatus", SqlDbType = System.Data.SqlDbType.Int, Value = Status, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcProduct", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.Product> result = this.MapListOfObject<SearchModel.Product>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Referentor> ReksaSrcReferentor(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Referentor> list = new List<SearchModel.Referentor>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcReferentor", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.Referentor> result = this.MapListOfObject<SearchModel.Referentor>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Switching> ReksaSrcSwitching(string Col1, string Col2, int Validate, string Criteria)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Switching> list = new List<SearchModel.Switching>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCriteria", SqlDbType = System.Data.SqlDbType.VarChar, Value = Criteria, Direction = System.Data.ParameterDirection.Input}
                 };

                if (this.ExecProc(QueryReksa(), "ReksaSrcSwitching", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.Switching> result = this.MapListOfObject<SearchModel.Switching>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Switching> ReksaSrcSwitchingRDB(string Col1, string Col2, int Validate, string Criteria)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Switching> list = new List<SearchModel.Switching>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCriteria", SqlDbType = System.Data.SqlDbType.VarChar, Value = Criteria, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcSwitchingRDB", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.Switching> result = this.MapListOfObject<SearchModel.Switching>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.TransaksiRefID> ReksaSrcTransaksiRefID(string Col1, string Col2, int Validate, string Criteria)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.TransaksiRefID> list = new List<SearchModel.TransaksiRefID>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCriteria", SqlDbType = System.Data.SqlDbType.VarChar, Value = Criteria, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcTransaksiRefID", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.TransaksiRefID> result = this.MapListOfObject<SearchModel.TransaksiRefID>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.ClientSwitchIn> ReksaSrcClientSwitchIn(string Col1, string Col2, int Validate, string Criteria)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.ClientSwitchIn> list = new List<SearchModel.ClientSwitchIn>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCriteria", SqlDbType = System.Data.SqlDbType.VarChar, Value = Criteria, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcClientSwitchIn", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.ClientSwitchIn> result = this.MapListOfObject<SearchModel.ClientSwitchIn>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.TransaksiClientNew> ReksaSrcTrxClientNew(string Col1, string Col2, int Validate, string Criteria)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.TransaksiClientNew> list = new List<SearchModel.TransaksiClientNew>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCriteria", SqlDbType = System.Data.SqlDbType.VarChar, Value = Criteria, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcTrxClientNew", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.TransaksiClientNew> result = this.MapListOfObject<SearchModel.TransaksiClientNew>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.TransaksiProduct> ReksaSrcTrxProduct(string Col1, string Col2, int Validate, string JenisTrx)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.TransaksiProduct> list = new List<SearchModel.TransaksiProduct>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cJenisTrx", SqlDbType = System.Data.SqlDbType.VarChar, Value = JenisTrx, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcTrxProduct", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.TransaksiProduct> result = this.MapListOfObject<SearchModel.TransaksiProduct>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.TransaksiProduct> ReksaSrcTransSwitchIn(string Col1, string Col2, int Validate, string ProdCode)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.TransaksiProduct> list = new List<SearchModel.TransaksiProduct>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cProdCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = ProdCode, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcTransSwitchIn", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.TransaksiProduct> result = this.MapListOfObject<SearchModel.TransaksiProduct>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.TransaksiProduct> ReksaSrcTransSwitchOut(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.TransaksiProduct> list = new List<SearchModel.TransaksiProduct>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcTransSwitchOut", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.TransaksiProduct> result = this.MapListOfObject<SearchModel.TransaksiProduct>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public List<SearchModel.Waperd> ReksaSrcWaperd(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.Waperd> list = new List<SearchModel.Waperd>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcWaperd", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.Waperd> result = this.MapListOfObject<SearchModel.Waperd>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }

        public List<SearchModel.TypeReksadana> ReksaSrcType(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.TypeReksadana> list = new List<SearchModel.TypeReksadana>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcType", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.TypeReksadana> result = this.MapListOfObject<SearchModel.TypeReksadana>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }

        public List<SearchModel.ManInvestasi> ReksaSrcManInv(string Col1, string Col2, int Validate)
        {
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            List<SearchModel.ManInvestasi> list = new List<SearchModel.ManInvestasi>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaSrcManInv", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<SearchModel.ManInvestasi> result = this.MapListOfObject<SearchModel.ManInvestasi>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }

        #endregion

        #region "CUSTOMER"
        public bool ReksaRefreshNasabah(string strCIFNo, int intNIK, string strGuid, 
            ref List<CustomerIdentitasModel.IdentitasDetail> listCutomer, 
            ref List<CustomerIdentitasModel.RiskProfileDetail> listRiskProfile,
            ref List<CustomerNPWPModel> listCustNPWP, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaRefreshNasabah", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        DataTable dtOut1 = dsOut.Tables[1];
                        DataTable dtOut2 = dsOut.Tables[2];
                        List<CustomerIdentitasModel.IdentitasDetail> resultCust = this.MapListOfObject<CustomerIdentitasModel.IdentitasDetail>(dtOut);
                        List<CustomerIdentitasModel.RiskProfileDetail> resultRisk = this.MapListOfObject<CustomerIdentitasModel.RiskProfileDetail>(dtOut1);
                        List<CustomerNPWPModel> resultCustNPWP = this.MapListOfObject<CustomerNPWPModel>(dtOut2);

                        listCutomer.AddRange(resultCust);
                        listRiskProfile.AddRange(resultRisk);
                        listCustNPWP.AddRange(resultCustNPWP);
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data Nasabah tidak ditemukan";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaGenerateShareholderID(out string shareholderID, out string ErrMsg)
        {
            shareholderID = "";
            ErrMsg = "";
            bool blnResult = false;
            DataSet ds = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcShareholderID", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 12},
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaGenerateShareholderID", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                    shareholderID = cmdOut.Parameters["@pcShareholderID"].Value.ToString();
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                blnResult = false;
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public bool ReksaGetConfAddress(int intType, string strCIFNo, string strBranch, int intID, int intNIK, string strGuid,
            out int intAddressType, out string strMessage, out string ErrMsg,
            ref List<CustomerIdentitasModel.KonfirmAddressList> listKonfAdress,
            ref List<CustomerIdentitasModel.AlamatCabangDetail> listBranch)
        {
            DataSet dsOut = new DataSet();
            bool blnResult = false;
            ErrMsg = "";
            strMessage = "";
            intAddressType = 0;
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnType", SqlDbType = System.Data.SqlDbType.Int, Value = intType, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcBranch", SqlDbType = System.Data.SqlDbType.VarChar, Value = strBranch, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnId", SqlDbType = System.Data.SqlDbType.Int, Value = intID, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcMessage", SqlDbType = System.Data.SqlDbType.VarChar, Value = strMessage, Direction = System.Data.ParameterDirection.Output, Size = 100 },
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaGetConfAddress", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOutKonfAddress = dsOut.Tables[1];
                        DataTable dtOutBranch = dsOut.Tables[2];
                        List<CustomerIdentitasModel.KonfirmAddressList> resultKonfAdress = this.MapListOfObject<CustomerIdentitasModel.KonfirmAddressList>(dtOutKonfAddress);
                        List<CustomerIdentitasModel.AlamatCabangDetail> resultBranch = this.MapListOfObject<CustomerIdentitasModel.AlamatCabangDetail>(dtOutBranch);

                        if (dsOut.Tables[0].Rows.Count > 0)
                        {
                            int.TryParse(dsOut.Tables[0].Rows[0]["AddressType"].ToString(), out intAddressType);
                        }
                        listKonfAdress.AddRange(resultKonfAdress);
                        listBranch.AddRange(resultBranch);
                        strMessage = cmdOut.Parameters["@pcMessage"].Value.ToString();
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public bool ReksaPopulateAktivitas(int ClientId, DateTime dtStartDate, DateTime dtEndDate, 
            int IsBalance, int intNIK, int IsAktivitasOnly, int isMFee, string strGuid, 
            ref List<CustomerAktifitasModel.PopulateAktifitas> listPopAktifitas, 
            out decimal decEffBal, out decimal decNomBal, out string ErrMsg)
        {
            ErrMsg = "";
            bool blnResult = false;
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            decEffBal = 0;
            decNomBal = 0;
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnClientId", SqlDbType = System.Data.SqlDbType.Int, Value = ClientId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdStartDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtStartDate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pdEndDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtEndDate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbIsBalance", SqlDbType = System.Data.SqlDbType.Bit, Value = IsBalance, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbAktivitasOnly", SqlDbType = System.Data.SqlDbType.Bit, Value = IsAktivitasOnly, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@isMFee", SqlDbType = System.Data.SqlDbType.Bit, Value = isMFee, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaPopulateAktivitas", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<CustomerAktifitasModel.PopulateAktifitas> resultPopAktifitas = this.MapListOfObject<CustomerAktifitasModel.PopulateAktifitas>(dtOut);
                        listPopAktifitas.AddRange(resultPopAktifitas);
                        decimal.TryParse(dsOut.Tables[1].Rows[0]["EffBal"].ToString(), out decEffBal);
                        decimal.TryParse(dsOut.Tables[1].Rows[0]["NomBal"].ToString(), out decNomBal);
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public bool ReksaGetAccountRelationDetail (string strAccNumber, int intType, 
            out string strNoRek, out string strNama, out string strNIK, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            strNoRek = "";
            strNama = "";
            strNIK = "";
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcAccountNumber", SqlDbType = System.Data.SqlDbType.VarChar, Value = strAccNumber, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnType", SqlDbType = System.Data.SqlDbType.Int, Value = intType, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaGetAccountRelationDetail", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        strNoRek = dsOut.Tables[0].Rows[0]["NoRek"].ToString();
                        strNama = dsOut.Tables[0].Rows[0]["Nama"].ToString();
                        if(intType == 2)
                            strNIK = dsOut.Tables[0].Rows[0]["NIK"].ToString();
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Error mengambil detail rekening!";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;                
            }
            return blnResult;
        }

        public bool ReksaGetListClient(string strCIFNo, ref List<CustomerAktifitasModel.ClientList> listClient, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaGetListClient", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<CustomerAktifitasModel.ClientList> resultClient = this.MapListOfObject<CustomerAktifitasModel.ClientList>(dtOut);
                        listClient.AddRange(resultClient);
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public void ReksaRefreshBlokir(int intClientId, int intNIK, string strGuid, ref List<CustomerBlokirModel> listBlokir, out decimal decTotal, out decimal decOutstandingUnit)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            decTotal = 0;
            decOutstandingUnit = 0;
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnClientId", SqlDbType = System.Data.SqlDbType.Int, Value = intClientId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaRefreshBlokir", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<CustomerBlokirModel> resultBlokir = this.MapListOfObject<CustomerBlokirModel>(dtOut);
                        listBlokir.AddRange(resultBlokir);
                        decimal.TryParse(dsOut.Tables[1].Rows[0]["Total"].ToString(), out decTotal);
                        decimal.TryParse(dsOut.Tables[2].Rows[0]["Outstanding Unit"].ToString(), out decOutstandingUnit);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool ReksaGetCIFData(string strCIFNO, int intNIK, string strGuid, int intNPWP, ref List<CIFDataModel> listCIFData, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNO, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNPWP", SqlDbType = System.Data.SqlDbType.Int, Value = intNPWP, Direction = System.Data.ParameterDirection.Input}
               };

                if (this.ExecProc(QueryReksa(), "ReksaGetCIFData", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<CIFDataModel> resultCIFData = this.MapListOfObject<CIFDataModel>(dtOut);
                        listCIFData.AddRange(resultCIFData);
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                blnResult = false;
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public void ReksaGetAlamatCabang(string strKodeCabang, string strCIFNo, int intID, ref List<CustomerIdentitasModel.AlamatCabangDetail> listAlamatCabang)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcKodeCabang", SqlDbType = System.Data.SqlDbType.VarChar, Value = strKodeCabang, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnId", SqlDbType = System.Data.SqlDbType.Int, Value = intID, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaGetAlamatCabang", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<CustomerIdentitasModel.AlamatCabangDetail> resultAlamatCabang = this.MapListOfObject<CustomerIdentitasModel.AlamatCabangDetail>(dtOut);
                        listAlamatCabang.AddRange(resultAlamatCabang);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool ReksaGetDocStatus(string strCIFNo, out string DocTermCondition, out string DocRiskProfile, out string ErrMsg)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            bool blnResult = false;
            ErrMsg = "";
            DocTermCondition = "";
            DocRiskProfile = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaGetDocStatus", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DocTermCondition = dsOut.Tables[0].Rows[0]["DocTermCondition"].ToString();
                        DocRiskProfile = dsOut.Tables[0].Rows[0]["DocRiskProfile"].ToString();
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public bool ReksaGetRiskProfile(string strCIFNo, out string RiskProfile, out DateTime LastUpdate, out int IsRegistered, out int ExpRiskProfileYear, out string ErrMsg)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            bool blnResult = false;
            ErrMsg = "";
            RiskProfile = "";
            LastUpdate = new DateTime();
            IsRegistered = 0;
            ExpRiskProfileYear = 0;
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaGetRiskProfile", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        RiskProfile = dsOut.Tables[0].Rows[0]["RiskProfile"].ToString();
                        DateTime.TryParse(dsOut.Tables[0].Rows[0]["LastUpdate"].ToString(), out LastUpdate);
                        int.TryParse(dsOut.Tables[0].Rows[0]["IsRegistered"].ToString(), out IsRegistered);
                        int.TryParse(dsOut.Tables[0].Rows[0]["ExpRiskProfileYear"].ToString(), out ExpRiskProfileYear);
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public bool ReksaGetListClientRDB(string strClientCode, ref List<CustomerAktifitasModel.ClientRDB> listClientRDB, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcClientCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = strClientCode, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaGetListClientRDB", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<CustomerAktifitasModel.ClientRDB> resultClientRDB = this.MapListOfObject<CustomerAktifitasModel.ClientRDB>(dtOut);
                        listClientRDB.AddRange(resultClientRDB);
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public bool ReksaValidateOfficeId(string strOfficeId, out int isAllowed, out string ErrMsg)
        {
            DataSet dsOut = new DataSet();
            bool blnResult = false;
            ErrMsg = "";
            isAllowed = 0;
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcKodeKantor", SqlDbType = System.Data.SqlDbType.VarChar, Value = strOfficeId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsAllowed", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size= 1}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaValidateOfficeId", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    int.TryParse(cmdOut.Parameters["@pbIsAllowed"].Value.ToString(), out isAllowed);
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
                blnResult = false;
            }
            return blnResult;
        }

        public void ReksaFlagClientId(int intClientId, int intNIK, int intFlag, out string ErrMsg)
        {
            SqlCommand cmdOut = new SqlCommand();
            DataSet dsOut = new DataSet();
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnClientId", SqlDbType = System.Data.SqlDbType.Int, Value = intClientId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbFlag", SqlDbType = System.Data.SqlDbType.Bit, Value = intFlag, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaFlagClientId", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    ErrMsg = _errorMessage;
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message.ToString();                               
            }
        }

        public bool ReksaCekExpRiskProfileParam(out int intExpRiskProfileYear, out int intExpRiskProfileDay, out string ErrMsg)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            bool blnResult = false;
            intExpRiskProfileYear = 0;
            intExpRiskProfileDay = 0;
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>(){};
                if (this.ExecProc(QueryReksa(), "ReksaCekExpRiskProfileParam", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        int.TryParse(dsOut.Tables[0].Rows[0]["ExpRiskProfileYear"].ToString(), out intExpRiskProfileYear);
                        int.TryParse(dsOut.Tables[0].Rows[0]["ExpRiskProfileDay"].ToString(), out intExpRiskProfileDay);
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public bool ReksaMaintainBlokir(CustomerBlokirModel Blokir, string strBlockDesc, bool isAccepted, int intNIK, string strGuid, 
            out string ErrMsg)
        {
            bool blnResult = false;
            DataSet dsOut = new DataSet();
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnType", SqlDbType = System.Data.SqlDbType.Int, Value = Blokir.intType, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnClientId", SqlDbType = System.Data.SqlDbType.Int, Value = Blokir.ClientId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnBlockId", SqlDbType = System.Data.SqlDbType.Int, Value = Blokir.BlockId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmBlockAmount", SqlDbType = System.Data.SqlDbType.Decimal, Value = Blokir.UnitBlokir, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmBlockDesc", SqlDbType = System.Data.SqlDbType.VarChar, Value = strBlockDesc, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdExpiryDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = Blokir.TanggalExpiryBlokir, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbAccepted", SqlDbType = System.Data.SqlDbType.Bit, Value = isAccepted, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaMaintainBlokir", ref dbParam, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message.ToString();
            }
            return blnResult;
        }

        public bool ReksaSaveExpRiskProfile(DateTime dtRiskProfile, DateTime dtExpRiskProfile,
            long lngCIFNo, out string ErrMsg)
        {
            bool blnResult = false;
            DataSet dsOut = new DataSet();
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@dtRiskProfile", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@dtExpRiskProfile", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnCIFNo", SqlDbType = System.Data.SqlDbType.BigInt, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaSaveExpRiskProfile", ref dbParam, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public bool ReksaCekExpRiskProfile(DateTime dtpRiskProfile, long lngCIFNO, out DateTime dtExpiredRiskProfile, out string strEmail, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            dtExpiredRiskProfile = new DateTime();
            strEmail = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@dtRiskProfile", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@dtExpRiskProfile", SqlDbType = System.Data.SqlDbType.DateTime, Direction = System.Data.ParameterDirection.Output },
                    new SqlParameter() { ParameterName = "@pnCIFNo", SqlDbType = System.Data.SqlDbType.BigInt, Value = lngCIFNO, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaCekExpRiskProfile", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    DateTime.TryParse(cmdOut.Parameters["@dtExpRiskProfile"].Value.ToString(), out dtExpiredRiskProfile);
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        strEmail = dsOut.Tables[0].Rows[0]["Email"].ToString();
                    }
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }        
        public bool ReksaMaintainNasabah(MaintainNasabah model, int NIK, string GUID, out string ErrMsg, out DataTable dtError)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            dtError = new DataTable();
            ErrMsg = "";
            bool blnResult = false;

            string strData = "";
            try
            {
                string strHeader = "";
                DataSet dsHeader = new DataSet("Header");
                DataTable dtHeader = new DataTable("HeaderData");

                DataSet dsClient = new DataSet("Client");
                DataTable dtClient = new DataTable();

                dtHeader = ListConverter.ToDataTable<HeaderAddress>(model.HeaderAddress);
                dtClient = ListConverter.ToDataTable<CustomerIdentitasModel.KonfirmAddressList>(model.KonfirmasiAddressModel);

                dsHeader.Tables.Add(dtHeader);
                dsClient.Tables.Add(dtClient);

                strHeader = dsHeader.GetXml().Trim();
                string strHeaderLength = strHeader.Length.ToString().Trim().PadLeft(5, '0');
                strData = strHeaderLength + strHeader + dsClient.GetXml();
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnType", SqlDbType = System.Data.SqlDbType.Int, Value = model.Type, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = GUID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCIF", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.CIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCIFName", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.CIFName, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcOfficeId", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.OfficeId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCIFType", SqlDbType = System.Data.SqlDbType.TinyInt, Value = model.CIFType, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcShareholderID", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.ShareholderID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCIFBirthPlace", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.CIFBirthPlace, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdCIFBirthDay", SqlDbType = System.Data.SqlDbType.DateTime, Value = model.CIFBirthDay, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdJoinDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = model.JoinDate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsEmployee", SqlDbType = System.Data.SqlDbType.TinyInt, Value = model.IsEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnCIFNIK", SqlDbType = System.Data.SqlDbType.Int, Value = model.CIFNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNISPAccId", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.AccountId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNISPAccName", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.AccountName, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIKInputter", SqlDbType = System.Data.SqlDbType.Int, Value = NIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbRiskProfile", SqlDbType = System.Data.SqlDbType.Bit, Value = model.isRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbTermCondition", SqlDbType = System.Data.SqlDbType.Bit, Value = model.isTermCondition, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdRiskProfileLastUpdate", SqlDbType = System.Data.SqlDbType.DateTime, Value = model.RiskProfileLastUpdate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAlamatConf", SqlDbType = System.Data.SqlDbType.VarChar, Value = strData, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNoNPWPKK", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.NoNPWPKK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNamaNPWPKK", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.NamaNPWPKK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcKepemilikanNPWPKK", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.KepemilikanNPWPKK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcKepemilikanNPWPKKLainnya", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.KepemilikanNPWPKKLainnya, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdTglNPWPKK", SqlDbType = System.Data.SqlDbType.DateTime, Value = model.TglNPWPKK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAlasanTanpaNPWP", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.AlasanTanpaNPWP, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNoDokTanpaNPWP", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.NoDokTanpaNPWP, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdTglDokTanpaNPWP", SqlDbType = System.Data.SqlDbType.DateTime, Value = model.TglDokTanpaNPWP, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNoNPWPProCIF", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.NoNPWPProCIF, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNamaNPWPProCIF", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.NamaNPWPProCIF, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNasabahId", SqlDbType = System.Data.SqlDbType.Int, Value = model.NasabahId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNISPAccIdUSD", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.AccountIdUSD, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNISPAccNameUSD", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.AccountNameUSD, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNISPAccIdMC", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.AccountIdMC, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNISPAccNameMC", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.AccountNameMC, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAccountIdTA", SqlDbType = System.Data.SqlDbType.VarChar, Value = "", Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAccountNameTA", SqlDbType = System.Data.SqlDbType.VarChar, Value = "", Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAccountIdUSDTA", SqlDbType = System.Data.SqlDbType.VarChar, Value = "", Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAccountNameUSDTA", SqlDbType = System.Data.SqlDbType.VarChar, Value = "", Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAccountIdMCTA", SqlDbType = System.Data.SqlDbType.VarChar, Value = "", Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAccountNameMCTA", SqlDbType = System.Data.SqlDbType.VarChar, Value = "", Direction = System.Data.ParameterDirection.Input}
                };
                if (this.ExecProc(QueryReksa(), "ReksaMaintainNasabah", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut.Tables.Count > 0)
                    {
                        ErrMsg = "Data gagal disimpan!!";
                        dtError = dsOut.Tables[0];
                    }
                    else
                    {
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message.ToString();
                blnResult = false;
            }
            return blnResult;
        }
        #endregion

        #region "IBMB"
        public bool ReksaRefreshKinerjaProduk(int intNIK, string strModule, out string ErrMsg, out List<KinerjaProduk> listKinerjaProduk)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet ds = new DataSet();
            listKinerjaProduk = new List<KinerjaProduk>();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", Value = intNIK, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", Value = strModule, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaRefreshKinerjaProduk", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                    if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                    {
                        DataTable dtOut = ds.Tables[0];
                        List<KinerjaProduk> Process = this.MapListOfObject<KinerjaProduk>(dtOut);
                        listKinerjaProduk.AddRange(Process);
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaMaintainKinerja(KinerjaProduk model, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet ds = new DataSet();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", Value = model.NIK, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", Value = model.Module, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnProdId", Value = model.ProdId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbIsVisible", Value = model.IsVisible, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmSehari", Value = model.Sehari, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmSeminggu", Value = model.Seminggu, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pmSebulan", Value = model.Sebulan, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmSetahun", Value = model.Setahun, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdNAVValueDate", Value = model.ValueDate, SqlDbType = System.Data.SqlDbType.Date, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProcessType", Value = model.ProcessType, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaMaintainKinerja", ref dbParam, out ds, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        #endregion

        #region "MASTER"
        public bool ReksaMaintainProduct(MaintainProduct model, out string ErrMsg)
        {
            bool blnResult = false;
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            ErrMsg = "";
            string strxmlNEmployeeSFee = "", strxmlEmployeeSFee = "", strxmlNEmployeeRFee = "", strxmlEmployeeRFee = "", strxmlMaintenanceFee = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnType", SqlDbType = System.Data.SqlDbType.TinyInt, Value = model.intType, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = model.intProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProdCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.strProdCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProdName", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.strProdName, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProdCCY", SqlDbType = System.Data.SqlDbType.Char, Value = model.strProdCCY, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnTypeId", SqlDbType = System.Data.SqlDbType.Int, Value = model.intTypeId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnManInvId", SqlDbType = System.Data.SqlDbType.Int, Value = model.intManInvId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnCustodyId", SqlDbType = System.Data.SqlDbType.Int, Value = model.intCustodyId.ToString(), Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmNAV", SqlDbType = System.Data.SqlDbType.Decimal, Value = model.decNAV, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmMinTotalUnit", SqlDbType = System.Data.SqlDbType.Decimal, Value = model.decMinTotalUnit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmMaxTotalUnit", SqlDbType = System.Data.SqlDbType.Decimal, Value = model.decMaxTotalUnit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmMaxDailyUnit", SqlDbType = System.Data.SqlDbType.Decimal, Value = model.decMaxDailyUnit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMaxDailyCust", SqlDbType = System.Data.SqlDbType.Decimal, Value = model.decMaxDailyCust, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPeriodStart", SqlDbType = System.Data.SqlDbType.Date, Value = model.dtPeriodStart, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPeriodEnd", SqlDbType = System.Data.SqlDbType.Date, Value = model.dtPeriodEnd, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdMatureDate", SqlDbType = System.Data.SqlDbType.Date, Value = model.dtMatureDate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdChangeDate", SqlDbType = System.Data.SqlDbType.Date, Value = model.dtChangeDate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdValueDate", SqlDbType = System.Data.SqlDbType.Date, Value = model.dtValueDate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnCloseEndBit", SqlDbType = System.Data.SqlDbType.TinyInt, Value = model.intCloseEndBit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsDeviden", SqlDbType = System.Data.SqlDbType.Bit, Value = model.isDeviden, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnDevidenPeriod", SqlDbType = System.Data.SqlDbType.TinyInt, Value = model.intDevidenPeriod, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdDevidenDate", SqlDbType = System.Data.SqlDbType.Date, Value = model.dtDevidenDate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnCalcId", SqlDbType = System.Data.SqlDbType.Int, Value = model.intCalcId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pxmlNEmployeeSFee", SqlDbType = System.Data.SqlDbType.VarChar, Value = strxmlNEmployeeSFee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pxmlEmployeeSFee", SqlDbType = System.Data.SqlDbType.VarChar, Value = strxmlEmployeeSFee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmUpFrontFee", SqlDbType = System.Data.SqlDbType.Decimal, Value = model.decUpFrontFee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmSubcFeeBased", SqlDbType = System.Data.SqlDbType.Decimal, Value = model.decSubcFeeBased, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmRedempFeeBased", SqlDbType = System.Data.SqlDbType.Decimal, Value = model.decRedempFeeBased, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmMaintenanceFee", SqlDbType = System.Data.SqlDbType.Decimal, Value = model.decMaintenanceFee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pxmlNEmployeeRFee", SqlDbType = System.Data.SqlDbType.VarChar, Value = strxmlNEmployeeRFee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pxmlEmployeeRFee", SqlDbType = System.Data.SqlDbType.VarChar, Value = strxmlEmployeeRFee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcMIAccountId", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.strMIAccountId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCTDAccountId", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.strCTDAccountId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = model.intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = model.strGUID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pxmlMaintenanceFee", SqlDbType = System.Data.SqlDbType.VarChar, Value = strxmlMaintenanceFee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnDevidentPct", SqlDbType = System.Data.SqlDbType.Decimal, Value = model.decDevidentPct, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnEffectiveAfter", SqlDbType = System.Data.SqlDbType.Int, Value = model.intEffectiveAfter, Direction = System.Data.ParameterDirection.Input}
                };

                blnResult = this.ExecProc(QueryReksa(), "ReksaMaintainProduct", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public DateTime ReksaCalcEffectiveDate(DateTime dateStart, int numDays)
        {
            //bool blnResult = false;
            string ErrMsg = "";
            DataSet dsOut = new DataSet();
            DateTime dateEnd = new DateTime();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pdStartDate", SqlDbType = System.Data.SqlDbType.Date, Value = dateStart, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNumDays", SqlDbType = System.Data.SqlDbType.Int, Value = numDays, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pdEndDate", SqlDbType = System.Data.SqlDbType.Date, Direction = System.Data.ParameterDirection.Output }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaCalcEffectiveDate", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    DateTime.TryParse(cmdOut.Parameters["@pdEndDate"].Value.ToString(), out dateEnd);
                }
                else
                {
                    dateEnd = dateStart;
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return dateEnd;
        }
        public bool ReksaRefreshProduct(int intProdId, int intNIK, string strGUID, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.VarChar, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGUID, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaRefreshProduct", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data Tidak Ada di Database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        
        public bool ReksaInqUnitNasabahDitwrkan(string strCIFNo, string strProdCode, int intNIK, string strGUID, DateTime dtCurrDate, out decimal sisaUnit, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            sisaUnit = 0;
            DataSet ds = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", Value = strCIFNo, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProdCode", Value = strProdCode, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnSisaUnit", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13 },
                    new SqlParameter() { ParameterName = "@pnNIK", Value = intNIK, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", Value = strGUID, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdCurrDate", Value = dtCurrDate, SqlDbType = System.Data.SqlDbType.DateTime, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaInqUnitNasDitwrkan", ref dbParam, out ds, out cmdOut, out ErrMsg);
                if(blnResult)
                {
                    decimal.TryParse(cmdOut.Parameters["@pnSisaUnit"].Value.ToString(), out sisaUnit);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaInqUnitDitwrkan(string strProdCode, int intNIK, string strGUID, DateTime dtCurrDate, out decimal sisaUnit, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            sisaUnit = 0;
            DataSet ds = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcProdCode", Value = strProdCode, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnSisaUnit", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13 },
                    new SqlParameter() { ParameterName = "@pnNIK", Value = intNIK, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", Value = strGUID, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdCurrDate", Value = dtCurrDate, SqlDbType = System.Data.SqlDbType.DateTime, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaInqUnitDitwrkan", ref dbParam, out ds, out cmdOut, out ErrMsg);
                if(blnResult)
                {
                    decimal.TryParse(cmdOut.Parameters["@pnSisaUnit"].Value.ToString(), out sisaUnit);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        #endregion

        #region "PARAMETER"
        public DataSet ReksaPopulateVerifyGlobalParam(string strProdId, string strInterfaceId, int intNIK)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.VarChar, Value = strProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcInterfaceId", SqlDbType = System.Data.SqlDbType.VarChar, Value = strInterfaceId, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaPopulateVerifyGlobalParam", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dsOut;
        }
        public List<ParameterModel> ReksaRefreshParameter(int intProdId, string _strTreeInterface, int intNIK, string strGuid)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            List<ParameterModel> list = new List<ParameterModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.BigInt, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcInterfaceId", SqlDbType = System.Data.SqlDbType.NVarChar, Value = _strTreeInterface, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaRefreshParameter", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<ParameterModel> result = this.MapListOfObject<ParameterModel>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public bool ReksaPopulateParamFee(int intNIK, string strModule, int intProdId, string strTrxType, ref List<ReksaParamFeeSubs> listParamFeeSubs, ref List<ReksaTieringNotificationSubs> listReksaTieringNotificationSubs, ref List<ReksaListGLFeeSubs> listReksaListGLFeeSubs,
            out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@nProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cTrxType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTrxType, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaPopulateParamFee", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        DataTable dtOut1 = dsOut.Tables[0];
                        DataTable dtOut2 = dsOut.Tables[1];
                        DataTable dtOut3 = dsOut.Tables[2];

                        List<ReksaParamFeeSubs> resultParamFeeSubs = this.MapListOfObject<ReksaParamFeeSubs>(dtOut1);
                        List<ReksaTieringNotificationSubs> resultTieringNotificationSubs = this.MapListOfObject<ReksaTieringNotificationSubs>(dtOut2);
                        List<ReksaListGLFeeSubs> resultListGLFeeSubs = this.MapListOfObject<ReksaListGLFeeSubs>(dtOut3);

                        listParamFeeSubs.AddRange(resultParamFeeSubs);
                        listReksaTieringNotificationSubs.AddRange(resultTieringNotificationSubs);
                        listReksaListGLFeeSubs.AddRange(resultListGLFeeSubs);
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        //Nico
        public void ReksaPopulateMFee(int intNIK, string strModule, int intProdId, string strTrxType, ref List<ReksaParamMFee> listReksaParamMFee, ref List<ReksaProductMFee> listReksaProductMFee, ref List<ReksaListGLMFee> listReksaListGLMFee)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@nProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cTrxType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTrxType, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaPopulateParamFee", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut1 = dsOut.Tables[0];
                        DataTable dtOut2 = dsOut.Tables[1];
                        DataTable dtOut3 = dsOut.Tables[2];

                        List<ReksaParamMFee> resultReksaParamMFee = this.MapListOfObject<ReksaParamMFee>(dtOut1);
                        List<ReksaProductMFee> resultReksaProductMFee = this.MapListOfObject<ReksaProductMFee>(dtOut2);
                        List<ReksaListGLMFee> resultReksaListGLMFee = this.MapListOfObject<ReksaListGLMFee>(dtOut3);

                        listReksaParamMFee.AddRange(resultReksaParamMFee);
                        listReksaProductMFee.AddRange(resultReksaProductMFee);
                        listReksaListGLMFee.AddRange(resultReksaListGLMFee);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        //End Nico

        //Harja
        public void ReksaPopulateUpFrontSellFee(int intNIK, string strModule, int intProdId, string strTrxType,
            ref List<ReksaParamUpFrontSelling> listReksaParamFee,
            ref List<ReksaListGLUpFrontSelling> listReksaListGL)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            try
            {
                strTrxType = strTrxType.ToUpper().Replace("FEE", "").Trim();
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@nProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cTrxType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTrxType, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaPopulateParamFee", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut1 = dsOut.Tables[0];
                        DataTable dtOut2 = dsOut.Tables[1];

                        List<ReksaParamUpFrontSelling> resultReksaParam = this.MapListOfObject<ReksaParamUpFrontSelling>(dtOut2);
                        List<ReksaListGLUpFrontSelling> resultReksaListGL = this.MapListOfObject<ReksaListGLUpFrontSelling>(dtOut1);

                        listReksaParamFee.AddRange(resultReksaParam);
                        listReksaListGL.AddRange(resultReksaListGL);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        //Harja End
        //Indra
        public void ReksaPopulateRedempFee(int intNIK, string strModule, int intProdId, string strTrxType, ref List<ParameterRedempFee> listRedempFee, ref List<ParameterRedempFeeTieringNotif> listRedempFeeTieringNotif, ref List<ParameterRedempFeeGL> listRedempFeeGL, ref List<ParameterRedempFeePercentageTiering> listRedempFeePercentageTiering)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@nProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cTrxType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTrxType, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaPopulateParamFee", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut1 = dsOut.Tables[0];
                        DataTable dtOut2 = dsOut.Tables[1];
                        DataTable dtOut3 = dsOut.Tables[2];
                        DataTable dtOut4 = dsOut.Tables[3];

                        List<ParameterRedempFee> resultRedempFee = this.MapListOfObject<ParameterRedempFee>(dtOut1);
                        List<ParameterRedempFeeTieringNotif> resultRedempFeeTieringNotif = this.MapListOfObject<ParameterRedempFeeTieringNotif>(dtOut2);
                        List<ParameterRedempFeeGL> resultRedempFeeGL = this.MapListOfObject<ParameterRedempFeeGL>(dtOut3);
                        List<ParameterRedempFeePercentageTiering> resultRedempFeePercentageTiering = this.MapListOfObject<ParameterRedempFeePercentageTiering>(dtOut3);

                        listRedempFee.AddRange(resultRedempFee);
                        listRedempFeeTieringNotif.AddRange(resultRedempFeeTieringNotif);
                        listRedempFeeGL.AddRange(resultRedempFeeGL);
                        listRedempFeePercentageTiering.AddRange(resultRedempFeePercentageTiering);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        //Indra end
        public bool ReksaMaintainSubsFee(int intNIK, string strModule, int intProdId,
            decimal decMinPctFeeEmployee, decimal decMaxPctFeeEmployee, decimal decMinPctFeeNonEmployee,
            decimal decMaxPctFeeNonEmployee, System.IO.StringWriter XMLTieringNotif, System.IO.StringWriter XMLSettingGL, 
            string strProcessType,
            out string ErrMsg)
        {
            bool blnResult = false;
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMinPctFeeEmployee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decMinPctFeeEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMaxPctFeeEmployee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decMaxPctFeeEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMinPctFeeNonEmployee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decMinPctFeeNonEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMaxPctFeeNonEmployee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decMaxPctFeeNonEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pvcXMLTieringNotif", SqlDbType = System.Data.SqlDbType.NVarChar, Value = XMLTieringNotif.ToString(), Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pvcXMLSettingGL", SqlDbType = System.Data.SqlDbType.NVarChar, Value = XMLSettingGL.ToString(), Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProcessType", SqlDbType = System.Data.SqlDbType.Char, Value = strProcessType, Direction = System.Data.ParameterDirection.Input}
                };

                blnResult = this.ExecProc(QueryReksa(), "ReksaMaintainSubsFee", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public void ReksaMaintainMFee(int intNIK, string strModule, int intProdId,
            int intPeriodEfektif, string XMLTieringMFee, string XMLSettingGL, string strProcessType,
            out string ErrMsg)
        {
            bool blnResult = false;
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnPeriodEfektif", SqlDbType = System.Data.SqlDbType.Int, Value = intPeriodEfektif, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pvcXMLTieringMFee", SqlDbType = System.Data.SqlDbType.Xml, Value = XMLTieringMFee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pvcXMLSettingGL", SqlDbType = System.Data.SqlDbType.Xml, Value = XMLSettingGL, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProcessType", SqlDbType = System.Data.SqlDbType.Char, Value = strProcessType, Direction = System.Data.ParameterDirection.Input}
                };

                blnResult = this.ExecProc(QueryReksa(), "ReksaMaintainMFee", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message.ToString();
            }
        }
        public void ReksaMaintainRedempFee(int intNIK, string strModule, int intProdId,
            decimal decMinPctFeeEmployee, decimal decMaxPctFeeEmployee, decimal decMinPctFeeNonEmployee,
            decimal decMaxPctFeeNonEmployee, string XMLTieringNotif, string XMLSettingGL, string strProcessType,
            bool IsFlat, int intNonFlatPeriod, bool RedempIncFeeout, string XMLTieringPctRedemp, string ErrMsg)
        {
            bool blnResult = false;
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMinPctFeeEmployee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decMinPctFeeEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMaxPctFeeEmployee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decMaxPctFeeEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMinPctFeeNonEmployee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decMinPctFeeNonEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMaxPctFeeNonEmployee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decMaxPctFeeNonEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pvcXMLTieringNotif", SqlDbType = System.Data.SqlDbType.Xml, Value = XMLTieringNotif, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pvcXMLSettingGL", SqlDbType = System.Data.SqlDbType.Xml, Value = XMLSettingGL, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProcessType", SqlDbType = System.Data.SqlDbType.Char, Value = strProcessType, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsFlat", SqlDbType = System.Data.SqlDbType.Bit, Value = IsFlat, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNonFlatPeriod", SqlDbType = System.Data.SqlDbType.Int, Value = intNonFlatPeriod, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbRedempIncFee", SqlDbType = System.Data.SqlDbType.Bit, Value = RedempIncFeeout, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pvcXMLTieringPctRedemp", SqlDbType = System.Data.SqlDbType.Xml, Value = XMLTieringPctRedemp, Direction = System.Data.ParameterDirection.Input}
                 };

                blnResult = this.ExecProc(QueryReksa(), "ReksaMaintainRedempFee", ref dbParam, out dsOut, out cmdOut, out ErrMsg);

            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
        }
        public void ReksaMaintainUpfrontSellingFee(int intNIK, string strModule, int intProdId,
          string XMLSettingGL, string strProcessType, string strJenisFee, decimal decPercentageDefault,
          out string ErrMsg)
        {
            bool blnResult = false;
            SqlCommand cmdOut = new SqlCommand();
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pvcXMLSettingGL", SqlDbType = System.Data.SqlDbType.Xml, Value = XMLSettingGL, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProcessType", SqlDbType = System.Data.SqlDbType.Char, Value = strProcessType, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcJenisFee", SqlDbType = System.Data.SqlDbType.VarChar, Value = strJenisFee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPercentageDefault", SqlDbType = System.Data.SqlDbType.Decimal, Value = decPercentageDefault, Direction = System.Data.ParameterDirection.Input}
               };

                blnResult = this.ExecProc(QueryReksa(), "ReksaMaintainUpfrontSellingFee", ref dbParam, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
        }
        public void ReksaMaintainSwcFee(int intNIK, string strModule, int intProdId,
            decimal decMinPctFeeEmployee, decimal decMaxPctFeeEmployee, decimal decMinPctFeeNonEmployee,
            decimal decMaxPctFeeNonEmployee, string XMLTieringNotif, string XMLSettingGL, string strProcessType,
            decimal decSwitchingFeeout, string ErrMsg)
        {
            bool blnResult = false;
            SqlCommand cmdOut = new SqlCommand();
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMinPctFeeEmployee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decMinPctFeeEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMaxPctFeeEmployee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decMaxPctFeeEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMinPctFeeNonEmployee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decMinPctFeeNonEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnMaxPctFeeNonEmployee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decMaxPctFeeNonEmployee, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pvcXMLTieringNotif", SqlDbType = System.Data.SqlDbType.Xml, Value = XMLTieringNotif, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pvcXMLSettingGL", SqlDbType = System.Data.SqlDbType.Xml, Value = XMLSettingGL, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProcessType", SqlDbType = System.Data.SqlDbType.Char, Value = strProcessType, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdSwitchingFee", SqlDbType = System.Data.SqlDbType.Decimal, Value = decSwitchingFeeout, Direction = System.Data.ParameterDirection.Input}
                };

                blnResult = this.ExecProc(QueryReksa(), "ReksaMaintainSwcFee", ref dbParam, out cmdOut, out ErrMsg);
                {
                    ErrMsg = _errorMessage;
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
        }
        public void ReksaGetPercentTax(out decimal decPercentTax)
        {
            string ErrMsg;
            DataSet dsOut = new DataSet();
            decPercentTax = 0;
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pdPercentTax", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaGetPercentTax", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    decimal.TryParse(cmdOut.Parameters["@pdPercentTax"].Value.ToString(), out decPercentTax);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public bool ReksaValidateGL(int intNIK, string strModule, string strNomorGL, out string strNamaGL, out string ErrMsg)
        {
            bool blnResult = false;
            DataSet dsOut = new DataSet();
            strNamaGL = "";
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK,Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNomorGL", SqlDbType = System.Data.SqlDbType.VarChar, Value = strNomorGL, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNamaGL", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 100}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaValidateGL", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    strNamaGL = cmdOut.Parameters["@pcNamaGL"].Value.ToString();
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaMaintainParameter(int intType, string InterfaceId, string strCode, string strDesc, string strOfficeId,
            int intProdId, int intId, DateTime dtValue, int intNIK, string strGuid, out string ErrMsg
            )
        {
            bool blnResult = false;
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnType", SqlDbType = System.Data.SqlDbType.TinyInt, Value = intType, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcInterfaceId", SqlDbType = System.Data.SqlDbType.VarChar, Value = InterfaceId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcDesc", SqlDbType = System.Data.SqlDbType.VarChar, Value = strDesc, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcOfficeId", SqlDbType = System.Data.SqlDbType.Char, Value = strOfficeId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnId", SqlDbType = System.Data.SqlDbType.Int, Value = intId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcValueDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtValue, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input}
                };

                blnResult = this.ExecProc(QueryReksa(), "ReksaMaintainParameter", ref dbParam, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaGetDropDownList(string ListName, out List<ParamSinkronisasi> listParam, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            listParam = new List<ParamSinkronisasi>();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcDropDownType", SqlDbType = System.Data.SqlDbType.VarChar, Value = ListName, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaGetDropDownList", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
                if (dsOut != null && dsOut.Tables.Count > 0)
                {
                    DataTable dtOut = dsOut.Tables[0];
                    List<ParamSinkronisasi> result = this.MapListOfObject<ParamSinkronisasi>(dtOut);
                    listParam.AddRange(result);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        #endregion

        #region "PO"        
        public bool ReksaGetListProducts(out List<ListProduct> listProduct, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            listProduct = new List<ListProduct>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>();
                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaGetListProducts", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
                if (blnResult)
                {
                    List<ListProduct> resultListRTGS = this.MapListOfObject<ListProduct>(dsOut.Tables[0]);
                    listProduct.AddRange(resultListRTGS);                    
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaMaintainProdNAV(int intProdId, decimal NAV, DateTime NAVValueDate, DateTime DevidentDate, decimal Deviden, int intNIK, decimal HargaUnitPerHari, out string ErrMsg, out string strRefId)
        {
            bool blnResult = false;
            ErrMsg = "";
            strRefId = "";
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNAV", SqlDbType = System.Data.SqlDbType.Decimal, Value = NAV, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pdNAVValueDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = NAVValueDate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pdDevidentDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = DevidentDate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnDeviden", SqlDbType = System.Data.SqlDbType.Decimal, Value = Deviden, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pfHargaUnitPerHari", SqlDbType = System.Data.SqlDbType.Decimal, Value = HargaUnitPerHari, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaMaintainProdNAV", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
                if (blnResult)
                {
                    strRefId = dsOut.Tables[0].Rows[0]["RefId"].ToString();
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaRefreshProdNAV(int intProdId, int intNIK, string strGUID, out List<ProductNAV> listProductNAV, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            listProductNAV = new List<ProductNAV>();
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGUID, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaRefreshProdNAV", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        List<ProductNAV> resultListRTGS = this.MapListOfObject<ProductNAV>(dsOut.Tables[0]);
                        listProductNAV.AddRange(resultListRTGS);
                        blnResult = true;
                    }
                }
                else
                {
                    ErrMsg = "Data tidak ada di database";
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaPopulateJurnalRTGS(int intClassificationId, string strModule, out List<JurnalRTGS> listJurnalRTGS, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            listJurnalRTGS = new List<JurnalRTGS>();
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnClassificationId", SqlDbType = System.Data.SqlDbType.Int, Value = intClassificationId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcErrMsg", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 100 }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaPopulateJurnalRTGS", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        ErrMsg = cmdOut.Parameters["@pcErrMsg"].Value.ToString();
                        List<JurnalRTGS> resultListRTGS = this.MapListOfObject<JurnalRTGS>(dsOut.Tables[0]);
                        listJurnalRTGS.AddRange(resultListRTGS);
                        blnResult = true;
                    }
                }
                else
                {
                    ErrMsg = cmdOut.Parameters["@pcErrMsg"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public string ReksaGetXmlRTGS(string Guid1, int intNIK, string strModule)
        {
            string Result = "";
            string ErrMsg;
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcErrMsg", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.InputOutput, Size = 100 },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcXmlOutput", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.InputOutput, Size = 800 }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaGetXmlRTGS", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        ErrMsg = cmdOut.Parameters["@pcErrMsg"].Value.ToString();
                        Result = cmdOut.Parameters["@pcXmlOutput"].Value.ToString();
                    }
                }
                else
                {
                    ErrMsg = cmdOut.Parameters["@pcErrMsg"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                Result = ex.Message;
            }
            return Result;
        }
        public bool ReksaProsesJurnalRTGSSKN(int intNIK, string strModule, string Guid1, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = Guid1, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaProsesJurnalRTGSSKN", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaProcessResponseXmlRTGS(int intNIK, string strModule, string Guid1, string strOutput, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            string strResult = "";
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcErrMsg", SqlDbType = System.Data.SqlDbType.VarChar, Value = "", Direction = System.Data.ParameterDirection.InputOutput, Size = 100 },
                    new SqlParameter() { ParameterName = "@pcXmlInput", SqlDbType = System.Data.SqlDbType.VarChar, Value = strOutput, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcRemittanceNumber", SqlDbType = System.Data.SqlDbType.VarChar, Value = strResult, Direction = System.Data.ParameterDirection.InputOutput, Size = 50 }
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaProcessResponseXmlRTGS", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaPopulateCancelTrans(out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>();

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaPopulateCancelTrans", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
                if (blnResult)
                {
                    if (dsOut == null && dsOut.Tables.Count <= 0 && dsOut.Tables[0].Rows.Count <= 0 )
                    {
                        blnResult = false;
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaCancelTransaction(int intTrandId, string strGUID, int intNIK, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@nTranId", SqlDbType = System.Data.SqlDbType.Int, Value = intTrandId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@nNik", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cPcguid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGUID, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaCancelTransaction", ref dbParam, out cmdOut, out ErrMsg);
             }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaCutSellingFee(DateTime dtStart, DateTime dtEnd, int intProdId, string strGUID, int intNIK, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pdStartDate", SqlDbType = System.Data.SqlDbType.Date, Value = dtStart, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdEndDate", SqlDbType = System.Data.SqlDbType.Date, Value = dtEnd, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGUID, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaCutSellingFee", ref dbParam, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaGetLastFeeDate(int intType, int intManId, int intProdId, int intNIK, string strGUID, out DateTime dtStartDate, out string ErrMsg)
        {
            dtStartDate = new DateTime();
            ErrMsg = "";
            bool blnResult = false;
            DataSet ds = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnType", SqlDbType = System.Data.SqlDbType.Int, Value = intType, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdStartDate", SqlDbType = System.Data.SqlDbType.Date, Direction = System.Data.ParameterDirection.Output},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGUID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnManId", SqlDbType = System.Data.SqlDbType.Int, Value = intManId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaGetLastFeeDate", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                    DateTime.TryParse(cmdOut.Parameters["@pdStartDate"].Value.ToString(), out dtStartDate);
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                blnResult = false;
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        #endregion

        #region "TRANSACTION"
        public bool ReksaRefreshTransactionNew(string strRefID, int intNIK, string strGuid, string strTranType, 
            ref List<TransactionModel.SubscriptionDetail> listSubsDetail, 
            ref List<TransactionModel.SubscriptionList> listSubs,
            ref List<TransactionModel.SubscriptionRDBList> listSubsRDB,
            ref List<TransactionModel.RedemptionList> listRedemp,
            out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcRefID", SqlDbType = System.Data.SqlDbType.VarChar, Value = strRefID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcTranType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTranType, Direction = System.Data.ParameterDirection.Input}                    
                };

                if (this.ExecProc(QueryReksa(), "ReksaRefreshTransactionNew", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        DataTable dtOut1 = dsOut.Tables[1];
                        DataTable dtOut2 = dsOut.Tables[2];
                        DataTable dtOut3 = dsOut.Tables[3];
                        List<TransactionModel.SubscriptionDetail> resultSubs = this.MapListOfObject<TransactionModel.SubscriptionDetail>(dtOut);
                        List<TransactionModel.SubscriptionList> resultSubsList = this.MapListOfObject<TransactionModel.SubscriptionList>(dtOut1);
                        List<TransactionModel.RedemptionList> resultRedempList = this.MapListOfObject<TransactionModel.RedemptionList>(dtOut2);
                        List<TransactionModel.SubscriptionRDBList> resultSubsRDBList = this.MapListOfObject<TransactionModel.SubscriptionRDBList>(dtOut3);

                        listSubsDetail.AddRange(resultSubs);
                        listSubs.AddRange(resultSubsList);
                        listSubsRDB.AddRange(resultSubsRDBList);
                        listRedemp.AddRange(resultRedempList);
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public void ReksaPopulateVerifyDocuments(int intTranId, bool IsEdit, bool IsSwitching, bool IsBooking, string strRefID,
            ref List<DocumentModel.VerifyDocument> listVerifyDoc)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnTranId", SqlDbType = System.Data.SqlDbType.Int, Value = intTranId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsEdit", SqlDbType = System.Data.SqlDbType.Bit, Value = IsEdit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsSwitching", SqlDbType = System.Data.SqlDbType.Bit, Value = IsSwitching, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsBooking", SqlDbType = System.Data.SqlDbType.Bit, Value = IsBooking, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcRefID", SqlDbType = System.Data.SqlDbType.VarChar, Value = strRefID, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaPopulateVerifyDocuments", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<DocumentModel.VerifyDocument> resultVerDoc = this.MapListOfObject<DocumentModel.VerifyDocument>(dtOut);
                        listVerifyDoc.AddRange(resultVerDoc);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool ReksaRefreshSwitching(string strRefID, int intNIK, string strGUID,
            ref List<TransactionModel.SwitchingNonRDBModel> listDetailSwcNonRDB, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcRefID", SqlDbType = System.Data.SqlDbType.VarChar, Value = strRefID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGUID, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaRefreshSwitching", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<TransactionModel.SwitchingNonRDBModel> resultSwcNonRDB = this.MapListOfObject<TransactionModel.SwitchingNonRDBModel>(dtOut);
                        listDetailSwcNonRDB.AddRange(resultSwcNonRDB);
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public bool ReksaRefreshSwitchingRDB(string strRefID, int intNIK, string strGUID,
            ref List<TransactionModel.SwitchingRDBModel> listDetailSwcRDB, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcRefID", SqlDbType = System.Data.SqlDbType.VarChar, Value = strRefID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGUID, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaRefreshSwitchingRDB", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<TransactionModel.SwitchingRDBModel> resultSwcRBD = this.MapListOfObject<TransactionModel.SwitchingRDBModel>(dtOut);
                        listDetailSwcRDB.AddRange(resultSwcRBD);
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public void ReksaRefreshBookingNew(string strRefID, int intNIK, string strGUID,
                    ref List<TransactionModel.BookingModel> listDetailBooking)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcRefID", SqlDbType = System.Data.SqlDbType.VarChar, Value = strRefID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGUID, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaRefreshBookingNew", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<TransactionModel.BookingModel> resultBooking = this.MapListOfObject<TransactionModel.BookingModel>(dtOut);
                        listDetailBooking.AddRange(resultBooking);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public bool ReksaGetLatestBalance(int intClientID, int intNIK, string strGUID, out decimal unitBalance, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            unitBalance = 0;
            DataSet ds = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnClientId", Value = intClientID, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", Value = intNIK, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", Value = strGUID, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmUnitBalance", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13 }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaGetLatestBalance", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                   decimal.TryParse(cmdOut.Parameters["@pmUnitBalance"].Value.ToString(), out unitBalance);
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaGetLatestNAV(int intProdId, int intNIK, string strGUID, out decimal NAV, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            NAV = 0;
            DataSet ds = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnProdId", Value = intProdId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", Value = intNIK, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", Value = strGUID, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmNAV", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13}
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaGetLatestNAV", ref dbParam, out ds, out cmdOut, out ErrMsg);

                if (blnResult)
                {
                    decimal.TryParse(cmdOut.Parameters["@pmNAV"].Value.ToString(), out NAV);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaCheckSubsType(string strCIFNo, int intProductId, bool IsTrxTA, bool IsRDB,  out bool IsSubsNew, out string strClientCode, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            IsSubsNew = false;
            strClientCode = "";
            DataSet ds = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", Value = strCIFNo, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProductId", Value = intProductId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsRDB", Value = IsRDB, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsSubsNew", SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Output},
                    new SqlParameter() { ParameterName = "@pcClientCode", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 20},
                    new SqlParameter() { ParameterName = "@pbIsTrxTA", Value = IsTrxTA, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaCheckSubsType", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                    bool.TryParse(cmdOut.Parameters["@pbIsSubsNew"].Value.ToString(), out IsSubsNew);
                    strClientCode = cmdOut.Parameters["@pcClientCode"].Value.ToString();
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                ErrMsg =  ex.Message;
            }
            return blnResult;
        }
        public string ReksaGetImportantData(string strCariApa, string strInput)
        {
            string ErrMsg;
            string strValue = "";
            DataSet ds = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCariApa", Value = strCariApa, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcInput", Value = strInput, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cValue", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 100}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaGetImportantData", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                    strValue = cmdOut.Parameters["@cValue"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return strValue;
        }
        public bool ReksaCalcFee(CalculateFeeModel.CalculateFeeRequest model, out CalculateFeeModel.CalculateFeeResponse resultFee, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet ds = new DataSet();
            resultFee = new CalculateFeeModel.CalculateFeeResponse();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnProdId", Value = model.ProdId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnClientId", Value = model.ClientId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnTranType", Value = model.TranType, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmTranAmt", Value = model.TranAmt, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmUnit", Value = model.Unit, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcFeeCCY", SqlDbType = System.Data.SqlDbType.Char, Direction = System.Data.ParameterDirection.Output, Size = 3},
                    new SqlParameter() { ParameterName = "@pnFee", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pnNIK", Value = model.NIK, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", Value = model.Guid, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmNAV", Value = model.NAV, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbFullAmount", Value = model.FullAmount, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbIsByPercent", Value = model.IsByPercent, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsFeeEdit", Value = model.IsFeeEdit, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPercentageFeeInput", Value = model.PercentageFeeInput, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pdPercentageFeeOutput", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pbProcess", Value = model.Process, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmFeeBased", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13 },
                    new SqlParameter() { ParameterName = "@pmRedempUnit", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pmRedempDev", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pbByUnit", Value = model.ByUnit, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbDebug", Value = model.Debug, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmProcessTranId", Value = model.ProcessTranId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmErrMsg", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 100 },
                    new SqlParameter() { ParameterName = "@pnOutType", Value = model.OutType, SqlDbType = System.Data.SqlDbType.TinyInt, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdValueDate", Value = model.ValueDate, SqlDbType = System.Data.SqlDbType.DateTime, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmTaxFeeBased", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pmFeeBased3", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pmFeeBased4", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pmFeeBased5", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pnPeriod", SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Output},
                    new SqlParameter() { ParameterName = "@pnIsRDB", SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Output},
                    new SqlParameter() { ParameterName = "@pcCIFNo", Value = model.CIFNo, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaCalcFee", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                    double Fee, PercentageFeeOutput, FeeBased, RedempUnit, RedempDev, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5;
                    int Period, IsRDB;
                    resultFee.FeeCCY = cmdOut.Parameters["@pcFeeCCY"].Value.ToString();
                    double.TryParse(cmdOut.Parameters["@pnFee"].Value.ToString(), out Fee);
                    Fee = System.Math.Round(Fee, 2);
                    resultFee.Fee = (decimal)Fee;
                    double.TryParse(cmdOut.Parameters["@pdPercentageFeeOutput"].Value.ToString(), out PercentageFeeOutput);
                    resultFee.PercentageFeeOutput = (decimal)PercentageFeeOutput;
                    double.TryParse(cmdOut.Parameters["@pmFeeBased"].Value.ToString(), out FeeBased);
                    resultFee.FeeBased = (decimal)FeeBased;
                    double.TryParse(cmdOut.Parameters["@pmRedempUnit"].Value.ToString(), out RedempUnit);
                    resultFee.RedempUnit = (decimal)RedempUnit;
                    double.TryParse(cmdOut.Parameters["@pmRedempDev"].Value.ToString(), out RedempDev);
                    resultFee.RedempDev = (decimal)RedempDev;
                    resultFee.ErrMsg = cmdOut.Parameters["@pmErrMsg"].Value.ToString();
                    double.TryParse(cmdOut.Parameters["@pmTaxFeeBased"].Value.ToString(), out TaxFeeBased);
                    resultFee.TaxFeeBased = (decimal)TaxFeeBased;
                    double.TryParse(cmdOut.Parameters["@pmFeeBased3"].Value.ToString(), out FeeBased3);
                    resultFee.FeeBased3 = (decimal)FeeBased3;
                    double.TryParse(cmdOut.Parameters["@pmFeeBased4"].Value.ToString(), out FeeBased4);
                    resultFee.FeeBased4 = (decimal)FeeBased4;
                    double.TryParse(cmdOut.Parameters["@pmFeeBased5"].Value.ToString(), out FeeBased5);
                    resultFee.FeeBased5 = (decimal)FeeBased5;
                    int.TryParse(cmdOut.Parameters["@pnPeriod"].Value.ToString(), out Period);
                    resultFee.Period = Period;
                    int.TryParse(cmdOut.Parameters["@pnIsRDB"].Value.ToString(), out IsRDB);
                    resultFee.IsRDB = IsRDB;
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaCalcSwitchingFee(CalculateFeeModel.SwitchingRequest feeModel, out CalculateFeeModel.SwitchingResponses resultFee, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet ds = new DataSet();
            resultFee = new CalculateFeeModel.SwitchingResponses();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcProdSwitchOut", Value = feeModel.ProdSwitchOut, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProdSwitchIn", Value = feeModel.ProdSwitchIn, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbJenis", Value = feeModel.Jenis, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmTranAmt", Value = feeModel.TranAmt, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmUnit", Value = feeModel.Unit, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcFeeCCY", SqlDbType = System.Data.SqlDbType.Char, Direction = System.Data.ParameterDirection.Output, Size = 3},
                    new SqlParameter() { ParameterName = "@pnFee", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pnNIK", Value = feeModel.NIK, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", Value = feeModel.Guid, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmNAV", Value = feeModel.NAV, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcIsEdit", Value = feeModel.IsEdit, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pdPercentageInput", Value = feeModel.PercentageInput, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPercentageOutput", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@bIsEmployee", Value = feeModel.IsEmployee, SqlDbType = System.Data.SqlDbType.Char, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaCalcSwitchingFee", ref dbParam, out ds, out cmdOut, out ErrMsg);
                if (blnResult)
                {
                    decimal Fee, PercentageFeeOutput;
                    resultFee.FeeCCY = cmdOut.Parameters["@pcFeeCCY"].Value.ToString();
                    decimal.TryParse(cmdOut.Parameters["@pnFee"].Value.ToString(), out Fee);
                    resultFee.Fee = Fee;
                    decimal.TryParse(cmdOut.Parameters["@pdPercentageOutput"].Value.ToString(), out PercentageFeeOutput);
                    resultFee.PercentageOutput = PercentageFeeOutput;
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaCalcSwitchingRDBFee(CalculateFeeModel.SwitchingRDBRequest feeModel, out CalculateFeeModel.SwitchingRDBResponses resultFee, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet ds = new DataSet();
            resultFee = new CalculateFeeModel.SwitchingRDBResponses();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcProdSwitchOut", Value = feeModel.ProdSwitchOut, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnClientSwitchOut", Value = feeModel.ClientSwitchOut, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmUnit", Value = feeModel.Unit, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcFeeCCY", SqlDbType = System.Data.SqlDbType.Char, Direction = System.Data.ParameterDirection.Output, Size = 3},
                    new SqlParameter() { ParameterName = "@pnFee", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pnNIK", Value = feeModel.NIK, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", Value = feeModel.Guid, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcIsEdit", Value = feeModel.IsEdit, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pdPercentageInput", Value = feeModel.PercentageInput, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPercentageOutput", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13}
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaCalcSwitchingRDBFee", ref dbParam, out ds, out cmdOut, out ErrMsg);

                if (blnResult)
                {
                    decimal Fee, PercentageFeeOutput;
                    resultFee.FeeCCY = cmdOut.Parameters["@pcFeeCCY"].Value.ToString();
                    decimal.TryParse(cmdOut.Parameters["@pnFee"].Value.ToString(), out Fee);
                    resultFee.Fee = Fee;
                    decimal.TryParse(cmdOut.Parameters["@pdPercentageFeeOutput"].Value.ToString(), out PercentageFeeOutput);
                    resultFee.PercentageOutput = PercentageFeeOutput;
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaCalcBookingFee(string strCIFNo, decimal decAmount, string strProductCode,
            bool IsByPercent, bool IsFeeEdit, decimal decPercentageFeeInput
            , out decimal PercentageFeeOutput, out string FeeCCY, out decimal Fee, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet ds = new DataSet();
            PercentageFeeOutput = 0;
            FeeCCY = "";
            Fee = 0;
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", Value = strCIFNo, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnAmount", Value = decAmount, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcProductCode", Value = strProductCode, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbIsByPercent", Value = IsByPercent, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsFeeEdit", Value = IsFeeEdit, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPercentageFeeInput", Value = decPercentageFeeInput, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pdPercentageFeeOutput", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pcFeeCCY", SqlDbType = System.Data.SqlDbType.Char, Direction = System.Data.ParameterDirection.Output, Size = 3 },
                    new SqlParameter() { ParameterName = "@pmFee", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaCalcBookingFee", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                    FeeCCY = cmdOut.Parameters["@pcFeeCCY"].Value.ToString();
                    decimal.TryParse(cmdOut.Parameters["@pmFee"].Value.ToString(), out Fee);
                    decimal.TryParse(cmdOut.Parameters["@pdPercentageFeeOutput"].Value.ToString(), out PercentageFeeOutput);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaGenerateTranCodeClientCode(TransactionModel.GenerateClientCode model, 
            out string TranCode, out string NewClientCode, out string ErrMsg, out string strWarnMsg, out string strWarnMsg2)
        {
            bool blnResult = false;
            ErrMsg = "";
            TranCode = ""; NewClientCode = ""; strWarnMsg = ""; strWarnMsg2 = "";
            DataSet ds = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcJenisTrx", Value = model.JenisTrx, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsSubsNew", Value = model.IsSubsNew, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcProdCode", Value = model.ProductCode, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcClientCode", Value = model.ClientCode, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcTranCode", Value = model.TranCode, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.InputOutput, Size = 20},
                    new SqlParameter() { ParameterName = "@pcNewClientCode", Value = model.NewClientCode, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.InputOutput, Size = 20 },
              
                    new SqlParameter() { ParameterName = "@pcCIFNo", Value = model.CIFNo, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbIsFeeEdit", Value = model.IsFeeEdit, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pdPercentageFee", Value = model.PercentageFee, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnPeriod", Value = model.Period , SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbFullAmount", Value =  model.FullAmount, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pmFee", Value = model.Fee ,SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmTranAmt", Value = model.TranAmt, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmTranUnit", Value = model.TranUnit, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsRedempAll", Value = model.IsRedempAll, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnFrekuensiPendebetan", Value = model.FrekuensiPendebetan, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnJangkaWaktu", Value = model.JangkaWaktu, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcType", Value = model.intTypeTrx, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcWarnMsg", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 8000},
                    new SqlParameter() { ParameterName = "@pcWarnMsg2", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 8000},
                    new SqlParameter() { ParameterName = "@piTrxTA", Value = 0, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaGenerateTranCodeClientCode", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                    if (cmdOut.Parameters.Count > 0)
                    {
                        TranCode = cmdOut.Parameters["@pcTranCode"].Value.ToString();
                        NewClientCode = cmdOut.Parameters["@pcNewClientCode"].Value.ToString();
                        strWarnMsg = cmdOut.Parameters["@pcWarnMsg"].Value.ToString();
                        strWarnMsg2 = cmdOut.Parameters["@pcWarnMsg2"].Value.ToString();
                        blnResult = true;
                    }
                    else
                    {
                        TranCode = "";
                        NewClientCode = "";
                        strWarnMsg = "";
                        strWarnMsg2 = "";
                        ErrMsg = "Error Generate Trancode dan ClientCode";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaMaintainAllTransaksiNew(int intNIK, string strGUID, TransactionModel.MaintainTransaksi model, out string ErrMsg, out string strRefID, out DataTable dtError)
        {
            bool blnResult = false;
            dtError = new DataTable();
            ErrMsg = "";
            DataSet ds = new DataSet();
            string strXMLSubs = "";
            string strXMLRedemp = "";
            string strXMLRDB = "";
            strRefID = "";

            SetDataXMLMaintainTransaksi(model, out strXMLSubs, out strXMLRedemp, out strXMLRDB);

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnType", Value = model.intType, SqlDbType = System.Data.SqlDbType.TinyInt, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcTranType", Value = model.strTranType, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcRefID", Value = model.RefID, SqlDbType = System.Data.SqlDbType.Char, Direction = System.Data.ParameterDirection.InputOutput, Size = 20 },
                    new SqlParameter() { ParameterName = "@pcCIFNo", Value = model.CIFNo, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcOfficeId", Value = model.OfficeId, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNoRekening", Value = model.NoRekening, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pvcXMLTrxSubscription", Value = strXMLSubs, SqlDbType = System.Data.SqlDbType.NVarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pvcXMLTrxRedemption", Value = strXMLRedemp, SqlDbType = System.Data.SqlDbType.NVarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pvcXMLTrxRDB", Value = strXMLRDB, SqlDbType = System.Data.SqlDbType.NVarChar, Direction = System.Data.ParameterDirection.Input},

                    new SqlParameter() { ParameterName = "@pcInputter", Value = model.Inputter, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnSeller", Value = model.Seller, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnWaperd", Value = model.Waperd, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", Value = intNIK , SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnReferentor", Value =  model.Referentor, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", Value = strGUID ,SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcWarnMsg", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 200 },
                    new SqlParameter() { ParameterName = "@pcWarnMsg2", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 200},
                    new SqlParameter() { ParameterName = "@pcWarnMsg3", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 200},
                    new SqlParameter() { ParameterName = "@pbDocFCSubscriptionForm", Value = model.pbDocFCSubscriptionForm, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocFCDevidentAuthLetter", Value = model.pbDocFCDevidentAuthLetter, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocFCJoinAcctStatementLetter", Value = model.pbDocFCJoinAcctStatementLetter, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocFCIDCopy", Value = model.pbDocFCIDCopy, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocFCOthers", Value = model.pbDocFCOthers, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocTCSubscriptionForm", Value = model.pbDocTCSubscriptionForm, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocTCTermCondition", Value = model.pbDocTCTermCondition, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocTCProspectus", Value = model.pbDocTCProspectus, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocTCFundFactSheet", Value = model.pbDocTCFundFactSheet, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocTCOthers", Value = model.pbDocTCOthers, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcDocFCOthersList", Value = model.pcDocFCOthersList, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcDocTCOthersList", Value = model.pcDocTCOthersList, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcWarnMsg4", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 400}
                };

                SqlCommand cmdOut = new SqlCommand();                
                if (this.ExecProc(QueryReksa(), "ReksaMaintainAllTransaksiNew", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                   
                    if (ds.Tables.Count > 0)
                    {
                        ErrMsg = "Data gagal disimpan!!";
                        dtError = ds.Tables[0];
                    }
                    else
                    {
                        if (cmdOut.Parameters["@pcWarnMsg4"].Value.ToString() != "") {
                            ErrMsg = cmdOut.Parameters["@pcWarnMsg4"].Value.ToString();
                        }
                        if (cmdOut.Parameters["@pcWarnMsg3"].Value.ToString() != "")
                        {
                            ErrMsg = "Umur nasabah 55 tahun atau lebih, Mohon dipastikan nasabah menandatangani pernyataan pada kolom yang disediakan di Formulir Subscription/Switching";
                        }
                        if (cmdOut.Parameters["@pcWarnMsg"].Value.ToString() != "")
                        {
                            ErrMsg = "Transaksi Telah Tersimpan, No Referensi: " + cmdOut.Parameters["@pcRefID"].Value.ToString() + ".Perlu Otorisasi Supervisor!\n" + cmdOut.Parameters["@pcWarnMsg"].Value.ToString();
                        }
                        else
                        {
                            ErrMsg = "Transaksi Telah Tersimpan, No Referensi: " + cmdOut.Parameters["@pcRefID"].Value.ToString() + ".Perlu Otorisasi Supervisor!\n";
                        }

                        strRefID = cmdOut.Parameters["@pcRefID"].Value.ToString();
                        blnResult = true;
                    }                    
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        private void SetDataXMLMaintainTransaksi(TransactionModel.MaintainTransaksi model, 
            out string strXMLSubs, out string strXMLRedemp, out string strXMLRDB)
        {
            strXMLSubs = ""; strXMLRedemp = ""; strXMLRDB = "";
            DataTable dttSubscription = new DataTable();
            DataTable dttRedemption = new DataTable();
            DataTable dttSubsRDB = new DataTable();

            dttSubscription = ListConverter.ToDataTable<TransactionModel.SubscriptionList>(model.dtSubs);
            dttRedemption = ListConverter.ToDataTable<TransactionModel.RedemptionList>(model.dtRedemp);
            dttSubsRDB = ListConverter.ToDataTable<TransactionModel.SubscriptionRDBList>(model.dtRDB);

            System.IO.StringWriter writer = new System.IO.StringWriter();
            dttSubscription.TableName = "Subscription";
            dttSubscription.WriteXml(writer, System.Data.XmlWriteMode.IgnoreSchema, false);
            strXMLSubs = writer.ToString();

            writer = new System.IO.StringWriter();
            dttRedemption.TableName = "Redemption";
            dttRedemption.WriteXml(writer, System.Data.XmlWriteMode.IgnoreSchema, false);
            strXMLRedemp = writer.ToString();

            writer = new System.IO.StringWriter();
            dttSubsRDB.TableName = "SubsRDB";
            dttSubsRDB.WriteXml(writer, System.Data.XmlWriteMode.IgnoreSchema, false);
            strXMLRDB = writer.ToString();
        }
        public bool ReksaMaintainSwitching(TransactionModel.MaintainSwitching model, out string ErrMsg, out string strRefID, out DataTable dtError)
        {
            bool blnResult = false;
            dtError = new DataTable();
            ErrMsg = "";
            DataSet ds = new DataSet();
            strRefID = "";

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnType", Value = model.intType, SqlDbType = System.Data.SqlDbType.TinyInt, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcTranType", Value = model.strTranType, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcTranCode", Value = model.strTranCode, SqlDbType = System.Data.SqlDbType.Char, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnTranId", Value = model.intTranId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Output},
                    new SqlParameter() { ParameterName = "@pdTranDate", Value = model.dtTranDate, SqlDbType = System.Data.SqlDbType.DateTime, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProdIdSwcOut", Value = model.intProdIdSwcOut, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnProdIdSwcIn", Value = model.intProdIdSwcIn, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnClientIdSwcOut", Value = model.intClientIdSwcOut, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnClientIdSwcIn", Value = model.intClientIdSwcIn, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnFundIdSwcOut", Value = model.intFundIdSwcOut, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnFundIdSwcIn", Value = model.intFundIdSwcIn, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcSelectedAccNo", Value = model.strSelectedAccNo, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnAgentIdSwcOut", Value = model.intAgentIdSwcOut , SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnAgentIdSwcIn", Value =  model.intAgentIdSwcIn, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcTranCCY", Value = model.strTranCCY ,SqlDbType = System.Data.SqlDbType.Char, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmTranAmt", Value = model.decTranAmt, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmTranUnit", Value = model.decTranUnit, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmSwitchingFee", Value = model.decSwitchingFee, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmNAVSwcOut", Value = model.decNAVSwcOut, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmNAVSwcIn", Value = model.decNAVSwcIn, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdNAVValueDate", Value = model.dtNAVValueDate, SqlDbType = System.Data.SqlDbType.DateTime, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmUnitBalanceSwcOut", Value = model.decUnitBalanceSwcOut, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmUnitBalanceNomSwcOut", Value = model.decUnitBalanceNomSwcOut, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmUnitBalanceSwcIn", Value = model.decUnitBalanceSwcIn, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmUnitBalanceNomSwcIn", Value = model.decUnitBalanceNomSwcIn, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnUserSuid", Value = model.intUserSuid, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbByUnit", Value = model.isByUnit, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnSalesId", Value = model.intSalesId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", Value = model.strGuid, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcWarnMsg", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 100},
                    new SqlParameter() { ParameterName = "@pcInputter", Value = model.strInputter, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnSeller", Value = model.intSeller, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnWaperd", Value = model.intWaperd, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsFeeEdit", Value = model.isFeeEdit, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocFCSubscriptionForm", Value = model.isDocFCSubscriptionForm, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocFCDevidentAuthLetter", Value = model.isDocFCDevidentAuthLetter, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocFCJoinAcctStatementLetter", Value = model.isDocFCJoinAcctStatementLetter, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocFCIDCopy", Value = model.isDocFCIDCopy, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocFCOthers", Value = model.isDocFCOthers, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocTCSubscriptionForm", Value = model.isDocTCSubscriptionForm, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocTCTermCondition", Value = model.isDocTCTermCondition, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocTCProspectus", Value = model.isDocTCProspectus, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocTCFundFactSheet", Value = model.isDocTCFundFactSheet, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDocTCOthers", Value = model.isDocTCOthers, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcDocFCOthersList", Value = model.strDocFCOthersList, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcDocTCOthersList", Value = model.strDocTCOthersList, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcWarnMsg2", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 100},
                    new SqlParameter() { ParameterName = "@pdPercentageFee", Value = model.decPercentageFee, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbByPhoneOrder", Value = model.isByPhoneOrder, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcWarnMsg3", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 100},
                    new SqlParameter() { ParameterName = "@pcCIFNo", Value = model.strCIFNo, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcOfficeId", Value = model.strOfficeId, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcRefID", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 20},
                    new SqlParameter() { ParameterName = "@pbIsNew", Value = model.isNew, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcClientCodeSwitchInNew", Value = model.strClientCodeSwitchInNew, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnReferentor", Value = model.intReferentor, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcWarnMsg4", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 500},
                    new SqlParameter() { ParameterName = "@pcWarnMsg5", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 500},
                    new SqlParameter() { ParameterName = "@pbTrxTaxAmnesty", Value = model.isTrxTaxAmnesty, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaMaintainSwitching", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {

                    if (ds.Tables.Count > 0)
                    {
                        ErrMsg = "Data gagal disimpan!!";
                        dtError = ds.Tables[0];
                    }
                    else
                    {
                        if (cmdOut.Parameters["@pcWarnMsg4"].Value.ToString() != "")
                        {
                            ErrMsg = cmdOut.Parameters["@pcWarnMsg4"].Value.ToString();
                        }
                        if (cmdOut.Parameters["@pcWarnMsg5"].Value.ToString() != "")
                        {
                            ErrMsg = cmdOut.Parameters["@pcWarnMsg5"].Value.ToString();
                        }
                        if (cmdOut.Parameters["@pcWarnMsg2"].Value.ToString() != "")
                        {
                            ErrMsg = "Profil Risiko produk lebih tinggi dari Profil Risiko Nasabah . PASTIKAN Nasabah sudah menandatangani kolom Profil Risiko pada Subscription/Switching Form";
                        }
                        if (cmdOut.Parameters["@pcWarnMsg3"].Value.ToString() != "")
                        {
                            ErrMsg = "Umur nasabah 55 tahun atau lebih, Mohon dipastikan nasabah menandatangani pernyataan pada kolom yang disediakan di Formulir Subscription/Switching";
                        }
                        if (cmdOut.Parameters["@pcWarnMsg"].Value.ToString() != "")
                        {
                            ErrMsg = "Transaksi Telah Tersimpan, No Referensi: " + cmdOut.Parameters["@pcRefID"].Value.ToString() + ".Perlu Otorisasi Supervisor!\n" + cmdOut.Parameters["@pcWarnMsg"].Value.ToString();
                        }
                        else
                        {
                            ErrMsg = "Transaksi Telah Tersimpan, No Referensi: " + cmdOut.Parameters["@pcRefID"].Value.ToString() + ".Perlu Otorisasi Supervisor!\n";
                        }

                        strRefID = cmdOut.Parameters["@pcRefID"].Value.ToString();
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaRegulerSubscriptionTunggakan(int intClientId, out string ErrMsg, out List<TransactionModel.Tunggakan> listTunggakan)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet ds = new DataSet();
            listTunggakan = new List<TransactionModel.Tunggakan>();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnClientId", Value = intClientId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbDebug", Value = 0, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaRegulerSubscriptionTunggakan", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                    if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                    {
                        DataTable dtOut = ds.Tables[0];
                        List<TransactionModel.Tunggakan> Process = this.MapListOfObject<TransactionModel.Tunggakan>(dtOut);
                        listTunggakan.AddRange(Process);
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaPopulateTTCompletion(int intProdId, out string ErrMsg, out TransactionModel.TransactionTT listTransactionTT)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet ds = new DataSet();
            listTransactionTT = new TransactionModel.TransactionTT();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnProdId", Value = intProdId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaPopulateTTCompletion", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                    if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                    {
                        DataTable dtOut = ds.Tables[0];
                        List<TransactionModel.TransactionTT> Process = this.MapListOfObject<TransactionModel.TransactionTT>(dtOut);
                        listTransactionTT = Process[0];
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaMaintainCompletion(TransactionModel.TransactionTT model, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet ds = new DataSet();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnProdId", Value = model.ProdId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProdCurr", Value = model.ProdCurr, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcNamaPemohon", Value = model.NamaPemohon, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcAlamatPemohon1", Value = model.AlamatPemohon1, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAlamatPemohon2", Value = model.AlamatPemohon2, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNamaPenerima", Value = model.NamaPenerima, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcAlamatPenerima1", Value = model.AlamatPenerima1, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAlamatPenerima2", Value = model.AlamatPenerima2, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAlamatPenerima3", Value = model.AlamatPenerima3, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcBeneficiaryBankCode", Value = model.BeneficiaryBankCode, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcBeneficiaryAccNo", Value = model.BeneficiaryAccNo, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcBeneficiaryBankName", Value = model.BeneficiaryBankName, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcBeneficiaryBankAddress", Value = model.BeneficiaryBankAddress , SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcPaymentRemarks1", Value =  model.PaymentRemarks1, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcPaymentRemarks2", Value = model.PaymentRemarks2 ,SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNoRekProduk", Value = model.NoRekProduk, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGLBiayaFullAmt", Value = model.GLBiayaFullAmt, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnInputterNIK", Value = model.InputterNIK, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcActionType", Value = model.ActionType, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaMaintainCompletion", ref dbParam, out ds, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaInitializeDataTTCompletion(int intProdId, out string ErrMsg, out TransactionModel.TransactionTT listTransactionTT)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet ds = new DataSet();
            listTransactionTT = new TransactionModel.TransactionTT();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnProdId", Value = intProdId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaInitializeDataTTCompletion", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                    if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                    {
                        DataTable dtOut = ds.Tables[0];
                        List<TransactionModel.TransactionTT> Process = this.MapListOfObject<TransactionModel.TransactionTT>(dtOut);
                        listTransactionTT = Process[0];
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaPopulateOutgoingTT(out string ErrMsg, out List<TransactionModel.OutgoingTT> listOutgoingTT)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet ds = new DataSet();
            listOutgoingTT = new List<TransactionModel.OutgoingTT>();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>();
                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaPopulateOutgoingTT", ref dbParam, out ds, out cmdOut, out ErrMsg))
                {
                    if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                    {
                        DataTable dtOut = ds.Tables[0];
                        List<TransactionModel.OutgoingTT> Process = this.MapListOfObject<TransactionModel.OutgoingTT>(dtOut);
                        listOutgoingTT.AddRange(Process);
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaMaintainOutgoingTT(int intBillId, bool isProcess, string strAlasanDelete, int intNIK, out string IsCurrencyHoliday, out DateTime dtNewValueDate, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet ds = new DataSet();
            IsCurrencyHoliday = "";
            dtNewValueDate = new DateTime();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", Value = intNIK, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnBillId", Value = intBillId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                     new SqlParameter() { ParameterName = "@pbIsProcess", Value = isProcess, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input },
                     new SqlParameter() { ParameterName = "@pcAlasanDelete", Value = strAlasanDelete, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input },
                     new SqlParameter() { ParameterName = "@pbIsCurrencyHoliday", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 1 },
                     new SqlParameter() { ParameterName = "@pdNewValueDate", SqlDbType = System.Data.SqlDbType.Date, Direction = System.Data.ParameterDirection.Output }
                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaMaintainOutgoingTT", ref dbParam, out ds, out cmdOut, out ErrMsg);
                if (blnResult)
                {
                    IsCurrencyHoliday = cmdOut.Parameters["@pbIsCurrencyHoliday"].Value.ToString();
                    DateTime.TryParse(cmdOut.Parameters["@pdNewValueDate"].Value.ToString(), out dtNewValueDate);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        #endregion

        #region "REPORT"
        public List<FileModel.NFSFileListType> ReksaNFSGetFileTypeList(string strFileType)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            string ErrMsg = "";
            List<FileModel.NFSFileListType> list = new List<FileModel.NFSFileListType>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcFileType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strFileType, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaNFSGetFileTypeList", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<FileModel.NFSFileListType> result = this.MapListOfObject<FileModel.NFSFileListType>(dtOut);
                        list.AddRange(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return list;
        }
        public bool ReksaGenerateText(int intNIK, string strModule, string Jenis, int Bulan, int Tahun, out string ErrMsg, out DataSet dsOut)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcJenisNasabah", SqlDbType = System.Data.SqlDbType.VarChar, Value = Jenis, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnBulan", SqlDbType = System.Data.SqlDbType.Int, Value = Bulan, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnTahun", SqlDbType = System.Data.SqlDbType.Int, Value = Tahun, Direction = System.Data.ParameterDirection.Input}
                };

                blnResult = this.ExecProc(QueryReksa(), "ReksaGenerateText", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
                if(blnResult)
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaNFSGetFormatFile(string strFileCode, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcFileCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = strFileCode, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaNFSGetFormatFile", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaNFSGenerateFileUpload(string sFileCode, int iTranDate, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcFileCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = sFileCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnDate", SqlDbType = System.Data.SqlDbType.Int, Value = iTranDate, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaNFSGenerateFileUpload", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        blnResult = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public bool ReksaNFSGenerateFileDownload(string sFileCode, string sFileName, string xmlData, string sUserID, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcFileCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = sFileCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcFileName", SqlDbType = System.Data.SqlDbType.VarChar, Value = sFileName, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pxXMLData", SqlDbType = System.Data.SqlDbType.Xml, Value = xmlData, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcUserId", SqlDbType = System.Data.SqlDbType.VarChar, Value = sUserID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcErrMsg", SqlDbType = System.Data.SqlDbType.VarChar,  Direction = System.Data.ParameterDirection.Output, Size=500}

                };

                SqlCommand cmdOut = new SqlCommand();
                blnResult = this.ExecProc(QueryReksa(), "ReksaNFSGenerateFileDownload", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
                if(ErrMsg == "")
                    ErrMsg = cmdOut.Parameters["@pcErrMsg"].Value.ToString();
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public bool ReksaNFSInsertLogFile(string sFileCode, string sFileName, string strUserID,
            int iTranDate, string sXMLDataGenerate, string sXMLRawData, bool bIsLog, bool bIsNeedAuth, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcFileCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = sFileCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcFileName", SqlDbType = System.Data.SqlDbType.VarChar, Value = sFileName, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcUserId", SqlDbType = System.Data.SqlDbType.VarChar, Value = strUserID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnDate", SqlDbType = System.Data.SqlDbType.Int, Value = iTranDate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pxXMLData", SqlDbType = System.Data.SqlDbType.Xml, Value = sXMLDataGenerate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pxRawXMLData", SqlDbType = System.Data.SqlDbType.Xml, Value = sXMLRawData, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsLog", SqlDbType = System.Data.SqlDbType.Bit, Value = bIsLog, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsNeedAuth", SqlDbType = System.Data.SqlDbType.Bit,  Value = bIsNeedAuth, Direction = System.Data.ParameterDirection.Input}
                };

                blnResult = this.ExecProc(QueryReksa(), "ReksaNFSInsertLogFile", ref dbParam, out dsOut, out cmdOut, out ErrMsg);                
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN07(DateTime dtPeriodStart, DateTime dtPeriodEnd, int intProdId, string strCustodyCode, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pdPeriodStartDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtPeriodStart, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPeriodEndDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtPeriodEnd, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCustodyCode ", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCustodyCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN07", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN08(DateTime dtPeriodStart, DateTime dtPeriodEnd, int intProdCode, string strOfficeId, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pdPeriodStart", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtPeriodStart, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPeriodEnd", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtPeriodEnd, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProdCode", SqlDbType = System.Data.SqlDbType.Int, Value = intProdCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcOfficeId", SqlDbType = System.Data.SqlDbType.VarChar, Value = strOfficeId, Direction = System.Data.ParameterDirection.Input},
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN08", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN09(DateTime dtTranDate, int intRegion, string strProdCode, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pdTranDate ", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtTranDate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProdCode ", SqlDbType = System.Data.SqlDbType.VarChar, Value = strProdCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnRegion", SqlDbType = System.Data.SqlDbType.Int, Value = intRegion, Direction = System.Data.ParameterDirection.Input},
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN09", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN10(DateTime dtPeriodStart, DateTime dtPeriodEnd, int intProdId, string strOfficeId, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pdPeriodStart", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtPeriodStart, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPeriodEnd", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtPeriodEnd, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcOfficeId", SqlDbType = System.Data.SqlDbType.VarChar, Value = strOfficeId, Direction = System.Data.ParameterDirection.Input},
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN10", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN11(DateTime dtTranDate, int intRegion, string strProdCode, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                     new SqlParameter() { ParameterName = "@pdTranDate ", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtTranDate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProdCode ", SqlDbType = System.Data.SqlDbType.VarChar, Value = strProdCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnRegion", SqlDbType = System.Data.SqlDbType.Int, Value = intRegion, Direction = System.Data.ParameterDirection.Input},
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN11", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN12(DateTime dtPeriod, int intRegion, string strProdCode, string strCIFStatus, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                     new SqlParameter() { ParameterName = "@pdPeriodStartDate ", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtPeriod, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProdCode ", SqlDbType = System.Data.SqlDbType.VarChar, Value = strProdCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnRegion", SqlDbType = System.Data.SqlDbType.Int, Value = intRegion, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCIFStatus", SqlDbType = System.Data.SqlDbType.Char, Value = intRegion, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN12", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN13(DateTime dtStart, DateTime dtEnd, string strProdCode, string strType, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pdPeriodStartDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtStart, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPeriodEndDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtEnd, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProdCode ", SqlDbType = System.Data.SqlDbType.VarChar, Value = strProdCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strType, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN13", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN14(DateTime dtStart, DateTime dtEnd, string strProdCode, string strType, int intRegion, string strAgentCode, string strClientCode,  out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pdPeriodStartDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtStart, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPeriodEndDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtEnd, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProdCode ", SqlDbType = System.Data.SqlDbType.VarChar, Value = strProdCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strType, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnRegion", SqlDbType = System.Data.SqlDbType.Int, Value = intRegion, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAgentCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = strAgentCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcClientCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = strClientCode, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN14", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN15(int intRegion, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnRegion", SqlDbType = System.Data.SqlDbType.Int, Value = intRegion, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN15", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN16(int intRegion, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnRegion", SqlDbType = System.Data.SqlDbType.Int, Value = intRegion, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN16", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN17(DateTime dtStart, DateTime dtEnd, string strProdCode, int intRegion, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pdPeriodStartDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtStart, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPeriodEndDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtEnd, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcProdCode ", SqlDbType = System.Data.SqlDbType.VarChar, Value = strProdCode, Direction = System.Data.ParameterDirection.Input},                    
                    new SqlParameter() { ParameterName = "@pnRegion", SqlDbType = System.Data.SqlDbType.Int, Value = intRegion, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN17", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN18(string strCIFNO, string strShareholderID, string isTA, string strStatusClientCode, DateTime dtOutstandingDate, string strUserIDAD, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNO, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcShareholderID", SqlDbType = System.Data.SqlDbType.VarChar, Value = strShareholderID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsTA ", SqlDbType = System.Data.SqlDbType.VarChar, Value = isTA, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcStatusClientCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = strStatusClientCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdOutstandingDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtOutstandingDate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cUserIDAD", SqlDbType = System.Data.SqlDbType.VarChar, Value = strUserIDAD, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN18", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN19(DateTime dtStart, DateTime dtEnd, string strClientCode, int intRegion, string strShareholderID, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pdPeriodStartDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtStart, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPeriodEndDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtEnd, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcClientCode ", SqlDbType = System.Data.SqlDbType.VarChar, Value = strClientCode, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnRegion", SqlDbType = System.Data.SqlDbType.Int, Value = intRegion, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcShareholderID ", SqlDbType = System.Data.SqlDbType.VarChar, Value = strShareholderID, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN19", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN20(out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>();

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN20", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN24(out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>();

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN24", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaReportRDN26(out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>();

                if (this.ExecProc(QueryReksa(), "ReksaReportRDN26", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        #endregion

        #region "OTORISASI"
        public bool ReksaNFSFileCekPendingOtorisasi(string strTypeGet, int intLogId, out DataSet dsOut, out string ErrMsg)
        {
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            bool blnResult = false;
            ErrMsg = "";

            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcTypeGet", SqlDbType = System.Data.SqlDbType.Char, Value = strTypeGet, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@LogId", SqlDbType = System.Data.SqlDbType.Int, Value = intLogId, Direction = System.Data.ParameterDirection.Input }
               };

                blnResult = this.ExecProc(QueryReksa(), "ReksaNFSFileCekPendingOtorisasi", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
                {
                    if (dsOut == null && dsOut.Tables.Count <= 0 && dsOut.Tables[0].Rows.Count <= 0)
                    {
                        blnResult = false;
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaNFSCekPendingDetailOtorisasi(int intCIFNo, int intLogId, out DataSet dsOut, out string ErrMsg)
        {
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            bool blnResult = false;
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnCIFNumber", SqlDbType = System.Data.SqlDbType.BigInt, Value = intCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@LogId", SqlDbType = System.Data.SqlDbType.Int, Value = intLogId, Direction = System.Data.ParameterDirection.Input }
               };

                blnResult = this.ExecProc(QueryReksa(), "ReksaNFSCekPendingDetailOtorisasi", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
                if(blnResult)
                {
                    if (dsOut == null && dsOut.Tables.Count <= 0 && dsOut.Tables[0].Rows.Count <= 0)
                    {
                        blnResult = false;
                        ErrMsg = "Data tidak ada di database";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaUpdateFlagApprovalNFSGenerate(int intLogId, string strType, string strNIK, out string ErrMsg)
        {
            SqlCommand cmdOut = new SqlCommand();
            bool blnResult = false;
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnLogId", SqlDbType = System.Data.SqlDbType.Int, Value = intLogId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.VarChar, Value = strNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strType, Direction = System.Data.ParameterDirection.Input }
               };

                blnResult = this.ExecProc(QueryReksa(), "ReksaUpdateFlagApprovalNFSGenerate", ref dbParam, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaPopulateVerifyAuthBS(string strAuthorization, string strTypeTrx, string strAction, string strNoReferensi, int intNIK, out DataSet dsOut, out string ErrMsg)
        {
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            bool blnResult = false;
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cNik", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cAuthorization", SqlDbType = System.Data.SqlDbType.VarChar, Value = strAuthorization, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cTypeTrx", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTypeTrx, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cAction", SqlDbType = System.Data.SqlDbType.VarChar, Value = strAction, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cNoReferensi", SqlDbType = System.Data.SqlDbType.VarChar, Value = strNoReferensi, Direction = System.Data.ParameterDirection.Input }
               };
                blnResult = this.ExecProc(QueryReksa(), "ReksaPopulateVerifyAuthBS", ref dbParam, out dsOut, out cmdOut, out ErrMsg);
                if (blnResult)
                {
                    if (!(dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0))
                    {
                        blnResult = false;
                        ErrMsg = "Data tidak ada di database";
                    }
                }
                else
                {
                    ErrMsg = "Data tidak ada di database";
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        public bool ReksaAuthorizeNasabah(int intNasabahId, int intNIK, bool isApprove, out string strError)
        {
            DataSet dsOut = new DataSet();
            bool blnResult = false;
            strError = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cNik", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bAccepted", SqlDbType = System.Data.SqlDbType.Bit, Value = isApprove, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@nNasabahId", SqlDbType = System.Data.SqlDbType.Int, Value = intNasabahId, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaAuthorizeNasabah", ref dbParam, out dsOut, out cmdOut, out strError))
                {
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                strError = ex.ToString();
            }
            return blnResult;
        }
        public bool ReksaAuthorizeBlocking(int intBlockId, int intNIK, bool isApprove, out string strError)
        {
            DataSet dsOut = new DataSet();
            bool blnResult = false;
            strError = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@nBlockId", SqlDbType = System.Data.SqlDbType.Int, Value = intBlockId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bAccepted", SqlDbType = System.Data.SqlDbType.Bit, Value = isApprove, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cNik", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaAuthorizeBlocking", ref dbParam, out dsOut, out cmdOut, out strError))
                {
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                strError = ex.ToString();
            }
            return blnResult;
        }
        public bool ReksaAuthorizeTranReversal(int intTranId, int intNIK, bool isApprove, out string strError)
        {
            DataSet dsOut = new DataSet();
            bool blnResult = false;
            strError = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@nTranId", SqlDbType = System.Data.SqlDbType.Int, Value = intTranId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bAccepted", SqlDbType = System.Data.SqlDbType.Bit, Value = isApprove, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cNik", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaAuthorizeTranReversal", ref dbParam, out dsOut, out cmdOut, out strError))
                {
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                strError = ex.ToString();
            }
            return blnResult;
        }
        public bool ReksaAuthorizeSwcReversal(int intTranId, int intNIK, bool isApprove, out string strError)
        {
            DataSet dsOut = new DataSet();
            bool blnResult = false;
            strError = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@nTranId", SqlDbType = System.Data.SqlDbType.Int, Value = intTranId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bAccepted", SqlDbType = System.Data.SqlDbType.Bit, Value = isApprove, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cNik", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaAuthorizeSwcReversal", ref dbParam, out dsOut, out cmdOut, out strError))
                {
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                strError = ex.ToString();
            }
            return blnResult;
        }
        public bool ReksaAuthorizeTransaction_BS(int intTranId, int intNIK, bool isApprove, out string strError)
        {
            DataSet dsOut = new DataSet();
            bool blnResult = false;
            strError = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@nTranId", SqlDbType = System.Data.SqlDbType.Int, Value = intTranId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bAccepted", SqlDbType = System.Data.SqlDbType.Bit, Value = isApprove, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cNik", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaAuthorizeTransaction_BS", ref dbParam, out dsOut, out cmdOut, out strError))
                    //if (this.ExecProc(QueryReksa(), "ReksaAuthorizeTransaction_BS", ref dbParam, out dsOut))
                {
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                strError = ex.ToString();
            }
            return blnResult;
        }
        public bool ReksaAuthorizeSwitching_BS(int intTranId, int intNIK, bool isApprove, out string strError)
        {
            DataSet dsOut = new DataSet();
            bool blnResult = false;
            strError = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@nTranId", SqlDbType = System.Data.SqlDbType.Int, Value = intTranId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bAccepted", SqlDbType = System.Data.SqlDbType.Bit, Value = isApprove, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cNik", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaAuthorizeSwitching_BS", ref dbParam, out dsOut, out cmdOut, out strError))
                //if (this.ExecProc(QueryReksa(), "ReksaAuthorizeTransaction_BS", ref dbParam, out dsOut))
                {
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                strError = ex.ToString();
            }
            return blnResult;
        }
        public bool ReksaAuthorizeBooking(int intBookingId, int intNIK, bool isApprove, out string strError)
        {
            DataSet dsOut = new DataSet();
            bool blnResult = false;
            strError = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@nBookingId", SqlDbType = System.Data.SqlDbType.Int, Value = intBookingId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@bAccepted", SqlDbType = System.Data.SqlDbType.Bit, Value = isApprove, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cNik", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaAuthorizeBooking", ref dbParam, out dsOut, out cmdOut, out strError))
                //if (this.ExecProc(QueryReksa(), "ReksaAuthorizeTransaction_BS", ref dbParam, out dsOut))
                {
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                strError = ex.ToString();
            }
            return blnResult;
        }
        public bool ReksaCheckValiditasData(int intTranId, int intTranType, double decNominal, double decUnit,
            bool FullAmount, string ChannelDesc, double FeeAmount, double FeePercent, int intJangkaWaktu,
            bool AutoRedemp, bool Asuransi, int FrekPendebetan, out string ErrMsg)
        {
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            bool blnResult = false;
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnTranId", SqlDbType = System.Data.SqlDbType.Int, Value = intTranId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnTranType", SqlDbType = System.Data.SqlDbType.Int, Value = intTranType, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pmNominal", SqlDbType = System.Data.SqlDbType.Decimal, Value = decNominal, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pmUnit", SqlDbType = System.Data.SqlDbType.Decimal, Value = decUnit, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbFullAmount", SqlDbType = System.Data.SqlDbType.Bit, Value = FullAmount, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcChannelDesc", SqlDbType = System.Data.SqlDbType.VarChar, Value = ChannelDesc, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pmFeeAmount", SqlDbType = System.Data.SqlDbType.Decimal, Value = FeeAmount, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pmFeePercent", SqlDbType = System.Data.SqlDbType.Decimal, Value = FeePercent, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnJangkaWaktu", SqlDbType = System.Data.SqlDbType.Int, Value = intJangkaWaktu, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbAutoRedemp", SqlDbType = System.Data.SqlDbType.Bit, Value = AutoRedemp, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbAsuransi", SqlDbType = System.Data.SqlDbType.Bit, Value = Asuransi, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnFrekPendebetan", SqlDbType = System.Data.SqlDbType.Int, Value = FrekPendebetan, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaCheckValiditasData", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                //if (this.ExecProc(QueryReksa(), "ReksaAuthorizeTransaction_BS", ref dbParam, out dsOut))
                {
                    blnResult = true;
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        
        public bool ReksaAuthorizeGlobalParam(string strId, string strTreeInterface, int intNIK, bool isApprove, out string ErrMsg)
        {
            SqlCommand cmdOut = new SqlCommand();
            bool blnResult = false;
            ErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnId", SqlDbType = System.Data.SqlDbType.Int, Value = strId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcInterfaceId", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTreeInterface, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbIsApprove", SqlDbType = System.Data.SqlDbType.Bit, Value = isApprove, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnNIKAuthorizer", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input }
                };

                blnResult = this.ExecProc(QueryReksa(), "ReksaAuthorizeGlobalParam", ref dbParam, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        #endregion
        
        #region "UTILITAS"
        public bool ReksaPopulateProcess(int intNIK, string strGuid, ref List<ProcessModel> listProcess, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            DataSet dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNik", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaPopulateProcess", ref dbParam, out dsOut, out cmdOut, out ErrMsg))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<ProcessModel> Process = this.MapListOfObject<ProcessModel>(dtOut);

                        listProcess.AddRange(Process);
                        blnResult = true;
                    }
                    else
                    {
                        ErrMsg = "Data Process tidak ditemukan";
                    }
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }

        public bool SPProcess(string SPName, int ProcessId, int intNIK, string strGuid, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            SqlCommand cmdOut = new SqlCommand();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnProcessId", SqlDbType = System.Data.SqlDbType.Int, Value = ProcessId, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input }
                };
                blnResult = this.ExecProc(QueryReksa(), SPName, ref dbParam, out cmdOut, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        #endregion
    }
}

