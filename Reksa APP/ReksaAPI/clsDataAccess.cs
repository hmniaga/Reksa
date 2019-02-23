using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;
using Microsoft.Extensions.Configuration;
using ReksaQuery;
using ReksaAPI.Models;
using Microsoft.AspNetCore.Mvc.Rendering;

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
        public bool ExecProc(ClsQuery clsQuery, string strProc, ref List<SqlParameter> dbParam)
        {
            DataSet dsResult = null;
            return ExecProc(clsQuery, strProc, ref dbParam, out dsResult);
        }
        private bool ExecProc(ClsQuery clsQuery, string strProc, ref List<SqlParameter> dbParam, out DataSet dsResult)
        {
            dsResult = null;
            _errorMessage = "";
            bool result = true;

            try
            {
                clsQuery.ExecProc(strProc, ref dbParam, out dsResult);
            }
            catch (Exception ex)
            {
                _errorMessage = ex.Message;
                result = false;
            }

            if (ClsQuery.queError.Count > 0)
            {
                string[] sErr = (string[])ClsQuery.queError.Dequeue();
                if (sErr.Length > 0)
                    _errorMessage = "";
                for (int i = 0; i < sErr.Length; i++)
                {
                    if (!sErr[i].Contains("Microsoft"))
                        _errorMessage = _errorMessage + sErr[i].ToString() + "\n";
                }
                ClsQuery.queError.Clear();
                result = false;
            }
            if (!_errorMessage.Equals(""))
            {
                throw new Exception(strProc + " - " + _errorMessage);
            }

            return result;
        }
        private bool ExecProc(ClsQuery clsQuery, string strProc, ref List<SqlParameter> dbParam, out DataSet dsResult, out SqlCommand cmdOut)
        {
            dsResult = null;
            _errorMessage = "";
            bool result = true;
            cmdOut = new SqlCommand();

            try
            {
                clsQuery.ExecProc(strProc, ref dbParam, out dsResult, out cmdOut);
            }
            catch (Exception ex)
            {
                _errorMessage = ex.Message;
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
        #endregion

        #region "REPLICATE DATA"
        public bool setCFADDR(string strCIFNo)
        {
            DataSet dsOut = new DataSet();
            bool blnReturn = false;
            try
            {
                List<SqlParameter> dbParamCust = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input}
                };
                if (this.ExecProc(QueryCustomer(), "CustomerGetCFADDR", ref dbParamCust, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        string strXMl = dsOut.GetXml();
                        List<SqlParameter> dbParam = new List<SqlParameter>()
                        {
                            new SqlParameter() { ParameterName = "@pcTable", SqlDbType = System.Data.SqlDbType.VarChar, Value = "CFADDR", Direction = System.Data.ParameterDirection.Input},
                            new SqlParameter() { ParameterName = "@pxData", SqlDbType = System.Data.SqlDbType.Xml, Value = strXMl, Direction = System.Data.ParameterDirection.Input}
                        };
                        if (this.ExecProc(QueryReksa(), "setDataCustomer", ref dbParam, out dsOut))
                        {
                            blnReturn = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return blnReturn;
        }
        public bool setCFAIDN(string strCIFNo)
        {
            DataSet dsOut = new DataSet();
            bool blnReturn = false;
            try
            {
                List<SqlParameter> dbParamCust = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input}
                };
                if (this.ExecProc(QueryCustomer(), "CustomerGetCFAIDN", ref dbParamCust, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        string strXMl = dsOut.GetXml();
                        List<SqlParameter> dbParam = new List<SqlParameter>()
                        {
                            new SqlParameter() { ParameterName = "@pcTable", SqlDbType = System.Data.SqlDbType.VarChar, Value = "CFAIDN", Direction = System.Data.ParameterDirection.Input},
                            new SqlParameter() { ParameterName = "@pxData", SqlDbType = System.Data.SqlDbType.Xml, Value = strXMl, Direction = System.Data.ParameterDirection.Input}
                        };
                        if (this.ExecProc(QueryReksa(), "setDataCustomer", ref dbParam, out dsOut))
                        {
                            blnReturn = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return blnReturn;
        }
        public bool setCFALTN(string strCIFNo)
        {
            DataSet dsOut = new DataSet();
            bool blnReturn = false;
            try
            {
                List<SqlParameter> dbParamCust = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input}
                };
                if (this.ExecProc(QueryCustomer(), "CustomerGetCFALTN", ref dbParamCust, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        string strXMl = dsOut.GetXml();
                        List<SqlParameter> dbParam = new List<SqlParameter>()
                        {
                            new SqlParameter() { ParameterName = "@pcTable", SqlDbType = System.Data.SqlDbType.VarChar, Value = "CFALTN", Direction = System.Data.ParameterDirection.Input},
                            new SqlParameter() { ParameterName = "@pxData", SqlDbType = System.Data.SqlDbType.Xml, Value = strXMl, Direction = System.Data.ParameterDirection.Input}
                        };
                        if (this.ExecProc(QueryReksa(), "setDataCustomer", ref dbParam, out dsOut))
                        {
                            blnReturn = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return blnReturn;
        }
        public bool setCFCONN(string strCIFNo)
        {
            DataSet dsOut = new DataSet();
            bool blnReturn = false;
            try
            {
                List<SqlParameter> dbParamCust = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input}
                };
                if (this.ExecProc(QueryCustomer(), "CustomerGetCFCONN", ref dbParamCust, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        string strXMl = dsOut.GetXml();
                        List<SqlParameter> dbParam = new List<SqlParameter>()
                        {
                            new SqlParameter() { ParameterName = "@pcTable", SqlDbType = System.Data.SqlDbType.VarChar, Value = "CFCONN", Direction = System.Data.ParameterDirection.Input},
                            new SqlParameter() { ParameterName = "@pxData", SqlDbType = System.Data.SqlDbType.Xml, Value = strXMl, Direction = System.Data.ParameterDirection.Input}
                        };
                        if (this.ExecProc(QueryReksa(), "setDataCustomer", ref dbParam, out dsOut))
                        {
                            blnReturn = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return blnReturn;
        }
        public bool setCFMAST(string strCIFNo)
        {
            DataSet dsOut = new DataSet();
            bool blnReturn = false;
            try
            {
                List<SqlParameter> dbParamCust = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input}
                };
                if (this.ExecProc(QueryCustomer(), "CustomerGetCFMAST", ref dbParamCust, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        string strXMl = dsOut.GetXml();
                        List<SqlParameter> dbParam = new List<SqlParameter>()
                        {
                            new SqlParameter() { ParameterName = "@pcTable", SqlDbType = System.Data.SqlDbType.VarChar, Value = "CFMAST", Direction = System.Data.ParameterDirection.Input},
                            new SqlParameter() { ParameterName = "@pxData", SqlDbType = System.Data.SqlDbType.Xml, Value = strXMl, Direction = System.Data.ParameterDirection.Input}
                        };
                        if (this.ExecProc(QueryReksa(), "setDataCustomer", ref dbParam, out dsOut))
                        {
                            blnReturn = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return blnReturn;
        }
        public void clearDATA(string strTable)
        {
            //bool blnReturn = false;
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcTable", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTable, Direction = System.Data.ParameterDirection.Input}
                };
                if (this.ExecProc(QueryReksa(), "clearDataCustomer", ref dbParam))
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
        public List<SearchModel.FrekuensiDebet> ReksaPopulateCombo()
        {
            DataSet dsOut = new DataSet();
            List<SearchModel.FrekuensiDebet> list = new List<SearchModel.FrekuensiDebet>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>();
                if (this.ExecProc(QueryReksa(), "ReksaPopulateCombo", ref dbParam, out dsOut))
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
                if (this.ExecProc(QueryReksa(), "ReksaHitungUmur", ref dbParam, out dsOut, out cmdOut))
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
        public string ReksaGetNoNPWPCounter()
        {
            string strNoDocNPWP = "";
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>();
                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaGetNoNPWPCounter", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        strNoDocNPWP = dsOut.Tables[0].Rows[0]["NoDocNPWP"].ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return strNoDocNPWP;
        }
        public List<SearchModel.Agen> ReksaGetTreeView(int intNIK, string strModule, string strMenu)
        {
            DataSet dsOut = new DataSet();
            List<SearchModel.Agen> list = new List<SearchModel.Agen>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcMenuName", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "UserGetTreeView", ref dbParam, out dsOut))
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

        public void ReksaValidateCBOOfficeId(string strOfficeID, out string IsEnable, out string strErrorMessage, out string strErrorCode)
        {
            DataSet dsOut = new DataSet();
            IsEnable = ""; strErrorMessage = ""; strErrorCode = "";
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
                if (this.ExecProc(QueryReksa(), "ReksaValidateCBOOfficeId", ref dbParam, out dsOut, out cmdOut))
                {
                    IsEnable = cmdOut.Parameters["@pcIsEnable"].Value.ToString();
                    strErrorMessage = cmdOut.Parameters["@pcErrorMessage"].Value.ToString();
                    strErrorCode = cmdOut.Parameters["@pcErrorCode"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public List<SearchModel.Agen> ReksaSrcAgen(string Col1, string Col2, int Validate, int ProdId)
        {
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcAgen", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcBank", ref dbParam, out dsOut))
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
        public List<SearchModel.Booking> ReksaSrcBooking(string Col1, string Col2, int Validate, string criteria)
        {
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcBooking", ref dbParam, out dsOut))
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
        public List<SearchModel.Client> ReksaSrcClient(string Col1, string Col2, int Validate, int ProdId)
        {
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcClient", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcCity", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcCIFAll", ref dbParam, out dsOut))
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
        public List<SearchModel.Customer> ReksaSrcCustomer(string Col1, string Col2, int Validate)
        {
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcCIF", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcCurrency", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcOffice", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcProduct", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcReferentor", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcSwitching", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcSwitchingRDB", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcTransaksiRefID", ref dbParam, out dsOut))
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
        public List<SearchModel.TransaksiClientNew> ReksaSrcTrxClientNew(string Col1, string Col2, int Validate, string Criteria)
        {
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcTrxClientNew", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcTrxProduct", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaSrcWaperd", ref dbParam, out dsOut))
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
        #endregion

        #region "CUSTOMER"
        public void ReksaRefreshCustomer(string strCIFNo, int intNIK, string strGuid, ref List<CustomerIdentitasModel.IdentitasDetail> listCutomer, ref List<CustomerIdentitasModel.RiskProfileDetail> listRiskProfile, ref List<CustomerNPWPModel> listCustNPWP)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaRefreshNasabah", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
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
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public string ReksaGenerateShareholderID()
        {
            string shareholderID = "";
            DataSet ds = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcShareholderID", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 12},
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaGenerateShareholderID", ref dbParam, out ds, out cmdOut))
                {
                    shareholderID = cmdOut.Parameters["@pcShareholderID"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return shareholderID;
        }

        public void ReksaGetConfAddress(int intType, string strCIFNo, string strBranch, int intID, out int intAddressType, out string strMessage, int intNIK, string strGuid,
            ref List<CustomerIdentitasModel.KonfirmAddressList> listKonfAdress,
            ref List<CustomerIdentitasModel.AlamatCabangDetail> listBranch)
        {
            DataSet dsOut = new DataSet();
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
                if (this.ExecProc(QueryReksa(), "ReksaGetConfAddress", ref dbParam, out dsOut, out cmdOut))
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
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ReksaPopulateAktivitas(int ClientId, DateTime dtStartDate, DateTime dtEndDate, int IsBalance, int intNIK, int IsAktivitasOnly, int isMFee, string strGuid, ref List<CustomerAktifitasModel.PopulateAktifitas> listPopAktifitas, out decimal decEffBal, out decimal decNomBal)
        {
            DataSet dsOut = new DataSet();
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

                if (this.ExecProc(QueryReksa(), "ReksaPopulateAktivitas", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<CustomerAktifitasModel.PopulateAktifitas> resultPopAktifitas = this.MapListOfObject<CustomerAktifitasModel.PopulateAktifitas>(dtOut);
                        listPopAktifitas.AddRange(resultPopAktifitas);
                        decimal.TryParse(dsOut.Tables[1].Rows[0]["EffBal"].ToString(), out decEffBal);
                        decimal.TryParse(dsOut.Tables[1].Rows[0]["NomBal"].ToString(), out decNomBal);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ReksaGetAccountRelationDetail (string strAccNumber, int intType)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcAccountNumber", SqlDbType = System.Data.SqlDbType.VarChar, Value = strAccNumber, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnType", SqlDbType = System.Data.SqlDbType.Int, Value = intType, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaGetAccountRelationDetail", ref dbParam, out dsOut))
                {
                    
                }
            }
            catch (Exception ex)
            {
                string strMesg = ex.ToString();                
            }

        }

        public void ReksaGetListClient(string strCIFNo, ref List<CustomerAktifitasModel.ClientList> listClient)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaGetListClient", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                       List<CustomerAktifitasModel.ClientList> resultClient = this.MapListOfObject<CustomerAktifitasModel.ClientList>(dtOut);

                        listClient.AddRange(resultClient);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ReksaRefreshBlokir(int intClientId, int intNIK, string strGuid, ref List<CustomerBlokirModel> listBlokir, out decimal decTotal, out decimal decOutstandingUnit)
        {
            DataSet dsOut = new DataSet();
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

                if (this.ExecProc(QueryReksa(), "ReksaRefreshBlokir", ref dbParam, out dsOut))
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

        public void ReksaGetCIFData(string strCIFNO, int intNIK, string strGuid, int intNPWP, ref List<CIFDataModel> listCIFData)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNO, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNPWP", SqlDbType = System.Data.SqlDbType.Int, Value = intNPWP, Direction = System.Data.ParameterDirection.Input}
               };

                if (this.ExecProc(QueryReksa(), "ReksaGetCIFData", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<CIFDataModel> resultCIFData = this.MapListOfObject<CIFDataModel>(dtOut);
                        listCIFData.AddRange(resultCIFData);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ReksaGetAlamatCabang(string strKodeCabang, string strCIFNo, int intID, ref List<CustomerIdentitasModel.AlamatCabangDetail> listAlamatCabang)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcKodeCabang", SqlDbType = System.Data.SqlDbType.VarChar, Value = strKodeCabang, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnId", SqlDbType = System.Data.SqlDbType.Int, Value = intID, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaGetAlamatCabang", ref dbParam, out dsOut))
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

        public void ReksaGetDocStatus(string strCIFNo, out string DocTermCondition, out string DocRiskProfile)
        {
            DataSet dsOut = new DataSet();
            DocTermCondition = "";
            DocRiskProfile = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaGetDocStatus", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DocTermCondition = dsOut.Tables[0].Rows[0]["DocTermCondition"].ToString();
                        DocRiskProfile = dsOut.Tables[0].Rows[0]["DocRiskProfile"].ToString();                       
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ReksaGetRiskProfile(string strCIFNo, ref string RiskProfile, ref DateTime LastUpdate, ref int IsRegistered, ref int ExpRiskProfileYear)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaGetRiskProfile", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        RiskProfile = dsOut.Tables[1].Rows[0]["RiskProfile"].ToString();
                        DateTime.TryParse(dsOut.Tables[1].Rows[0]["LastUpdate"].ToString(), out LastUpdate);
                        int.TryParse(dsOut.Tables[1].Rows[0]["IsRegistered"].ToString(), out IsRegistered);
                        int.TryParse(dsOut.Tables[1].Rows[0]["ExpRiskProfileYear"].ToString(), out ExpRiskProfileYear); 
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ReksaGetListClientRDB(string strClientCode, ref List<CustomerAktifitasModel.ClientRDB> listClientRDB)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcClientCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = strClientCode, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaGetListClientRDB", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<CustomerAktifitasModel.ClientRDB> resultClientRDB = this.MapListOfObject<CustomerAktifitasModel.ClientRDB>(dtOut);
                        listClientRDB.AddRange(resultClientRDB);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }            
        }

        public void ReksaValidateOfficeId(string strOfficeId, out int isAllowed)
        {
            DataSet dsOut = new DataSet();
            isAllowed = 0;
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcKodeKantor", SqlDbType = System.Data.SqlDbType.VarChar, Value = strOfficeId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsAllowed", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size= 1}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaValidateOfficeId", ref dbParam, out dsOut, out cmdOut ))
                {
                    int.TryParse(cmdOut.Parameters["@pbIsAllowed"].Value.ToString(), out isAllowed);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ReksaFlagClientId(int intClientId, int intNIK, int intFlag, out string strErrMsg)
        {
            DataSet dsOut = new DataSet();
            strErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnClientId", SqlDbType = System.Data.SqlDbType.Int, Value = intClientId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbFlag", SqlDbType = System.Data.SqlDbType.Bit, Value = intFlag, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaFlagClientId", ref dbParam, out dsOut))
                {
                    strErrMsg = _errorMessage;
                }
            }
            catch (Exception ex)
            {
                strErrMsg = ex.Message.ToString();                               
            }
        }

        public void ReksaCekExpRiskProfileParam(out int intExpRiskProfileYear, out int intExpRiskProfileDay, out string strErrMsg)
        {
            DataSet dsOut = new DataSet();
            intExpRiskProfileYear = 0;
            intExpRiskProfileDay = 0;
            strErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {};

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaCekExpRiskProfileParam", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        int.TryParse(dsOut.Tables[0].Rows[0]["ExpRiskProfileYear"].ToString(), out intExpRiskProfileYear);
                        int.TryParse(dsOut.Tables[0].Rows[0]["ExpRiskProfileDay"].ToString(), out intExpRiskProfileDay);
                    }
                }
            }
            catch (Exception ex)
            {
                strErrMsg = ex.Message.ToString();
            }
        }

        public void ReksaMaintainBlokir(CustomerBlokirModel Blokir, string strBlockDesc, bool isAccepted, int intNIK, string strGuid, 
            out string strErrMsg)
        {
            DataSet dsOut = new DataSet();
            strErrMsg = "";
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
                if (this.ExecProc(QueryReksa(), "ReksaMaintainBlokir", ref dbParam, out dsOut))
                {
                    strErrMsg = _errorMessage;
                }
            }
            catch (Exception ex)
            {
                strErrMsg = ex.Message.ToString();
            }
        }

        public void ReksaSaveExpRiskProfile(DateTime dtRiskProfile, DateTime dtExpRiskProfile,
            long lngCIFNo, out string strErrMsg)
        {
            DataSet dsOut = new DataSet();
            strErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@dtRiskProfile", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@dtExpRiskProfile", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnCIFNo", SqlDbType = System.Data.SqlDbType.BigInt, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaMaintainBlokir", ref dbParam, out dsOut))
                {
                    strErrMsg = _errorMessage;
                }
            }
            catch (Exception ex)
            {
                strErrMsg = ex.Message.ToString();
            }
        }

        public void ReksaCekExpRiskProfile(DateTime dtpRiskProfile, long lngCIFNO, out DateTime dtExpiredRiskProfile, out string strEmail)
        {
            DataSet dsOut = new DataSet();
            dtExpiredRiskProfile = new DateTime();
            strEmail = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@dtRiskProfile", SqlDbType = System.Data.SqlDbType.Date, Value = dtpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@dtExpRiskProfile", SqlDbType = System.Data.SqlDbType.Date, Direction = System.Data.ParameterDirection.Output },
                    new SqlParameter() { ParameterName = "@pnCIFNo", SqlDbType = System.Data.SqlDbType.BigInt, Value = lngCIFNO, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaCekExpRiskProfile", ref dbParam, out dsOut, out cmdOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0 && dsOut.Tables[0].Rows.Count > 0)
                    {
                        strEmail = dsOut.Tables[0].Rows[0]["Email"].ToString();
                        DateTime.TryParse(cmdOut.Parameters["@dtExpRiskProfile"].Value.ToString(), out dtExpiredRiskProfile);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool ReksaMaintainNasabah(DateTime dtRiskProfile, DateTime dtExpRiskProfile,
           long lngCIFNo, out string strErrMsg)
        {
            DataSet dsOut = new DataSet();
            strErrMsg = "";
            bool blnResult = false;
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnType", SqlDbType = System.Data.SqlDbType.TinyInt, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCIF", SqlDbType = System.Data.SqlDbType.Char, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCIFName", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcOfficeId", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCIFType", SqlDbType = System.Data.SqlDbType.TinyInt, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcShareholderID", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcCIFBirthPlace", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdCIFBirthDay", SqlDbType = System.Data.SqlDbType.DateTime, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdJoinDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsEmployee", SqlDbType = System.Data.SqlDbType.TinyInt, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnCIFNIK", SqlDbType = System.Data.SqlDbType.Int, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNISPAccId", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNISPAccName", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIKInputter", SqlDbType = System.Data.SqlDbType.Int, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbRiskProfile", SqlDbType = System.Data.SqlDbType.Bit, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbTermCondition", SqlDbType = System.Data.SqlDbType.Bit, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdRiskProfileLastUpdate", SqlDbType = System.Data.SqlDbType.DateTime, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAlamatConf", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNoNPWPKK", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNamaNPWPKK", SqlDbType = System.Data.SqlDbType.VarChar, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcKepemilikanNPWPKK", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcKepemilikanNPWPKKLainnya", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdTglNPWPKK", SqlDbType = System.Data.SqlDbType.DateTime, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAlasanTanpaNPWP", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNoDokTanpaNPWP", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdTglDokTanpaNPWP", SqlDbType = System.Data.SqlDbType.DateTime, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNoNPWPProCIF", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNamaNPWPProCIF", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNasabahId", SqlDbType = System.Data.SqlDbType.Int, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNISPAccIdUSD", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNISPAccNameUSD", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNISPAccIdMC", SqlDbType = System.Data.SqlDbType.VarChar, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcNISPAccNameMC", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAccountIdTA", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAccountNameTA", SqlDbType = System.Data.SqlDbType.VarChar, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAccountIdUSDTA", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAccountNameUSDTA", SqlDbType = System.Data.SqlDbType.VarChar, Value = dtExpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAccountIdMCTA", SqlDbType = System.Data.SqlDbType.VarChar, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcAccountNameMCTA", SqlDbType = System.Data.SqlDbType.VarChar, Value = lngCIFNo, Direction = System.Data.ParameterDirection.Input}
                };
                if (this.ExecProc(QueryReksa(), "ReksaMaintainNasabah", ref dbParam, out dsOut))
                {
                    strErrMsg = _errorMessage;
                    if (strErrMsg == "")
                        blnResult = true;
                    else
                        blnResult = false;
                }
            }
            catch (Exception ex)
            {
                strErrMsg = ex.Message.ToString();
                blnResult = false;
            }
            return blnResult;
        }
        #endregion

        #region "MASTER"
        public decimal ReksaInqUnitNasabahDitwrkan(string strCIFNo, string strProdCode, int intNIK, string strGUID, DateTime dtCurrDate)
        {
            decimal sisaUnit = 0;
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
                if (this.ExecProc(QueryReksa(), "ReksaInqUnitNasDitwrkan", ref dbParam, out ds, out cmdOut))
                {
                    decimal.TryParse(cmdOut.Parameters["@pnSisaUnit"].Value.ToString(), out sisaUnit);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return sisaUnit;
        }
        public decimal ReksaInqUnitDitwrkan(string strProdCode, int intNIK, string strGUID, DateTime dtCurrDate)
        {
            decimal sisaUnit = 0;
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
                if (this.ExecProc(QueryReksa(), "ReksaInqUnitDitwrkan", ref dbParam, out ds, out cmdOut))
                {
                    decimal.TryParse(cmdOut.Parameters["@pnSisaUnit"].Value.ToString(), out sisaUnit);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return sisaUnit;
        }
        #endregion

        #region "PARAMETER"
        public List<ParameterModel> ReksaRefreshParameter(int intProdId, string _strTreeInterface, int intNIK, string strGuid)
        {
            DataSet dsOut = new DataSet();
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

                if (this.ExecProc(QueryReksa(), "ReksaRefreshParameter", ref dbParam, out dsOut))
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

        public void ReksaPopulateParamFee(int intNIK, string strModule, int intProdId, string strTrxType, ref List<ReksaParamFeeSubs> listParamFeeSubs, ref List<ReksaTieringNotificationSubs> listReksaTieringNotificationSubs, ref List<ReksaListGLFeeSubs> listReksaListGLFeeSubs)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@nProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cTrxType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTrxType, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaPopulateParamFee", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
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
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        //Nico
        public void ReksaPopulateMFee(int intNIK, string strModule, int intProdId, string strTrxType, ref List<ReksaParamMFee> listReksaParamMFee, ref List<ReksaProductMFee> listReksaProductMFee, ref List<ReksaListGLMFee> listReksaListGLMFee)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@nProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cTrxType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTrxType, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaPopulateParamFee", ref dbParam, out dsOut))
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

                if (this.ExecProc(QueryReksa(), "ReksaPopulateParamFee", ref dbParam, out dsOut))
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
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.VarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@nProdId", SqlDbType = System.Data.SqlDbType.Int, Value = intProdId, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cTrxType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTrxType, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc(QueryReksa(), "ReksaPopulateParamFee", ref dbParam, out dsOut))
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

        public void ReksaMaintainSubsFee(int intNIK, string strModule, int intProdId,
            decimal decMinPctFeeEmployee, decimal decMaxPctFeeEmployee, decimal decMinPctFeeNonEmployee,
            decimal decMaxPctFeeNonEmployee, string XMLTieringNotif, string XMLSettingGL, string strProcessType,
            out string strErrMsg)
        {
            DataSet dsOut = new DataSet();
            strErrMsg = "";
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
                    new SqlParameter() { ParameterName = "@pcProcessType", SqlDbType = System.Data.SqlDbType.Char, Value = strProcessType, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaMaintainSubsFee", ref dbParam, out dsOut))
                {
                    strErrMsg = _errorMessage;
                }
            }
            catch (Exception ex)
            {
                strErrMsg = ex.Message.ToString();
            }
        }
        public void ReksaMaintainMFee(int intNIK, string strModule, int intProdId,
            int intPeriodEfektif, string XMLTieringMFee, string XMLSettingGL, string strProcessType,
            out string strErrMsg)
        {
            DataSet dsOut = new DataSet();
            strErrMsg = "";
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

                if (this.ExecProc(QueryReksa(), "ReksaMaintainMFee", ref dbParam, out dsOut))
                {
                    strErrMsg = _errorMessage;
                }
            }
            catch (Exception ex)
            {
                strErrMsg = ex.Message.ToString();
            }
        }

        public void ReksaMaintainRedempFee(int intNIK, string strModule, int intProdId,
            decimal decMinPctFeeEmployee, decimal decMaxPctFeeEmployee, decimal decMinPctFeeNonEmployee,
            decimal decMaxPctFeeNonEmployee, string XMLTieringNotif, string XMLSettingGL, string strProcessType,
            bool IsFlat, int intNonFlatPeriod, bool RedempIncFeeout, string XMLTieringPctRedemp, string strErrMsg)
        {
            DataSet dsOut = new DataSet();
            strErrMsg = "";
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

                if (this.ExecProc(QueryReksa(), "ReksaMaintainRedempFee", ref dbParam, out dsOut))
                {
                    strErrMsg = _errorMessage;
                }
            }
            catch (Exception ex)
            {
                strErrMsg = ex.Message.ToString();
            }
        }

        public void ReksaMaintainUpfrontSellingFee(int intNIK, string strModule, int intProdId,
          string XMLSettingGL, string strProcessType, string strJenisFee, decimal decPercentageDefault,
          out string strErrMsg)
        {
            DataSet dsOut = new DataSet();
            strErrMsg = "";
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

                if (this.ExecProc(QueryReksa(), "ReksaMaintainUpfrontSellingFee", ref dbParam, out dsOut))
                {
                    strErrMsg = _errorMessage;
                }
            }
            catch (Exception ex)
            {
                strErrMsg = ex.Message.ToString();
            }
        }

        public void ReksaMaintainSwcFee(int intNIK, string strModule, int intProdId,
            decimal decMinPctFeeEmployee, decimal decMaxPctFeeEmployee, decimal decMinPctFeeNonEmployee,
            decimal decMaxPctFeeNonEmployee, string XMLTieringNotif, string XMLSettingGL, string strProcessType,
            decimal decSwitchingFeeout, string strErrMsg)
        {
            DataSet dsOut = new DataSet();
            strErrMsg = "";
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

                if (this.ExecProc(QueryReksa(), "ReksaMaintainSwcFee", ref dbParam, out dsOut))
                {
                    strErrMsg = _errorMessage;
                }
            }
            catch (Exception ex)
            {
                strErrMsg = ex.Message.ToString();
            }
        }

        public void ReksaGetPercentTax(out decimal decPercentTax)
        {
            DataSet dsOut = new DataSet();
            decPercentTax = 0;
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pdPercentTax", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaGetPercentTax", ref dbParam, out dsOut, out cmdOut))
                {
                    decimal.TryParse(cmdOut.Parameters["@pdPercentTax"].Value.ToString(), out decPercentTax);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ReksaValidateGL(int intNIK, string strModule, string strNomorGL, out string strNamaGL)
        {
            DataSet dsOut = new DataSet();
            strNamaGL = "";
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
                if (this.ExecProc(QueryReksa(), "ReksaValidateGL", ref dbParam, out dsOut, out cmdOut))
                {
                    strNamaGL = cmdOut.Parameters["@pcNamaGL"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #endregion

        #region "TRANSACTION"
        public void ReksaRefreshTransactionNew(string strRefID, int intNIK, string strGuid, string strTranType, 
            ref List<TransactionModel.SubscriptionDetail> listSubsDetail, 
            ref List<TransactionModel.SubscriptionList> listSubs,
            ref List<TransactionModel.SubscriptionRDBList> listSubsRDB,
            ref List<TransactionModel.RedemptionList> listRedemp)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcRefID", SqlDbType = System.Data.SqlDbType.VarChar, Value = strRefID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcTranType", SqlDbType = System.Data.SqlDbType.VarChar, Value = strTranType, Direction = System.Data.ParameterDirection.Input}                    
                };

                if (this.ExecProc(QueryReksa(), "ReksaRefreshTransactionNew", ref dbParam, out dsOut))
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
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ReksaPopulateVerifyDocuments(int intTranId, bool IsEdit, bool IsSwitching, bool IsBooking, string strRefID,
            ref List<DocumentModel.VerifyDocument> listVerifyDoc)
        {
            DataSet dsOut = new DataSet();
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

                if (this.ExecProc(QueryReksa(), "ReksaPopulateVerifyDocuments", ref dbParam, out dsOut))
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

        public void ReksaRefreshSwitching(string strRefID, int intNIK, string strGUID,
            ref List<TransactionModel.SwitchingNonRDBModel> listDetailSwcNonRDB)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcRefID", SqlDbType = System.Data.SqlDbType.VarChar, Value = strRefID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGUID, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaRefreshSwitching", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<TransactionModel.SwitchingNonRDBModel> resultSwcNonRDB = this.MapListOfObject<TransactionModel.SwitchingNonRDBModel>(dtOut);
                        listDetailSwcNonRDB.AddRange(resultSwcNonRDB);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ReksaRefreshSwitchingRDB(string strRefID, int intNIK, string strGUID,
            ref List<TransactionModel.SwitchingRDBModel> listDetailSwcRDB)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcRefID", SqlDbType = System.Data.SqlDbType.VarChar, Value = strRefID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGUID, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaRefreshSwitchingRDB", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<TransactionModel.SwitchingRDBModel> resultSwcRBD = this.MapListOfObject<TransactionModel.SwitchingRDBModel>(dtOut);
                        listDetailSwcRDB.AddRange(resultSwcRBD);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ReksaRefreshBookingNew(string strRefID, int intNIK, string strGUID,
                    ref List<TransactionModel.BookingModel> listDetailBooking)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcRefID", SqlDbType = System.Data.SqlDbType.VarChar, Value = strRefID, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGUID, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc(QueryReksa(), "ReksaRefreshBookingNew", ref dbParam, out dsOut))
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
        public decimal ReksaGetLatestBalance(int intClientID, int intNIK, string strGUID)
        {
            decimal unitBalance = 0;
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
                if (this.ExecProc(QueryReksa(), "ReksaGetLatestBalance", ref dbParam, out ds, out cmdOut))
                {
                   decimal.TryParse(cmdOut.Parameters["@pmUnitBalance"].Value.ToString(), out unitBalance);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return unitBalance;
        }

        public decimal ReksaGetLatestNAV(int intProdId, int intNIK, string strGUID)
        {
            decimal NAV = 0;
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
                if (this.ExecProc(QueryReksa(), "ReksaGetLatestNAV", ref dbParam, out ds, out cmdOut))
                {
                    decimal.TryParse(cmdOut.Parameters["@pmNAV"].Value.ToString(), out NAV);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return NAV;
        }
        public void ReksaCheckSubsType(string strCIFNo, int intProductId, bool IsTrxTA, bool IsRDB,  out bool IsSubsNew, out string strClientCode)
        {
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
                if (this.ExecProc(QueryReksa(), "ReksaCheckSubsType", ref dbParam, out ds, out cmdOut))
                {
                    bool.TryParse(cmdOut.Parameters["@pbIsSubsNew"].Value.ToString(), out IsSubsNew);
                    strClientCode = cmdOut.Parameters["@pcClientCode"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public string ReksaGetImportantData(string strCariApa, string strInput)
        {
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
                if (this.ExecProc(QueryReksa(), "ReksaGetImportantData", ref dbParam, out ds, out cmdOut))
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

        public CalculateFeeModel.GlobalFeeResponse ReksaCalcFee(CalculateFeeModel.GlobalFeeRequest feeModel)
        {
            DataSet ds = new DataSet();
            CalculateFeeModel.GlobalFeeResponse resultFee = new CalculateFeeModel.GlobalFeeResponse();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnProdId", Value = feeModel.ProdId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnClientId", Value = feeModel.ClientId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pnTranType", Value = feeModel.TranType, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmTranAmt", Value = feeModel.TranAmt, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmUnit", Value = feeModel.Unit, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcFeeCCY", SqlDbType = System.Data.SqlDbType.Char, Direction = System.Data.ParameterDirection.Output, Size = 3},
                    new SqlParameter() { ParameterName = "@pnFee", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pnNIK", Value = feeModel.NIK, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", Value = feeModel.Guid, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmNAV", Value = feeModel.NAV, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbFullAmount", Value = feeModel.FullAmount, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbIsByPercent", Value = feeModel.IsByPercent, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbIsFeeEdit", Value = feeModel.IsFeeEdit, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdPercentageFeeInput", Value = feeModel.PercentageFeeInput, SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pdPercentageFeeOutput", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pbProcess", Value = feeModel.Process, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmFeeBased", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13 },
                    new SqlParameter() { ParameterName = "@pmRedempUnit", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pmRedempDev", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pbByUnit", Value = feeModel.ByUnit, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pbDebug", Value = feeModel.Debug, SqlDbType = System.Data.SqlDbType.Bit, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmProcessTranId", Value = feeModel.ProcessTranId, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmErrMsg", SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Output, Size = 100 },
                    new SqlParameter() { ParameterName = "@pnOutType", Value = feeModel.OutType, SqlDbType = System.Data.SqlDbType.TinyInt, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdValueDate", Value = feeModel.ValueDate, SqlDbType = System.Data.SqlDbType.DateTime, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmTaxFeeBased", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pmFeeBased3", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pmFeeBased4", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pmFeeBased5", SqlDbType = System.Data.SqlDbType.Decimal, Direction = System.Data.ParameterDirection.Output, Size = 25, Scale = 13},
                    new SqlParameter() { ParameterName = "@pnPeriod", SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Output},
                    new SqlParameter() { ParameterName = "@pnIsRDB", SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Output},
                    new SqlParameter() { ParameterName = "@pcCIFNo", Value = feeModel.CIFNo, SqlDbType = System.Data.SqlDbType.VarChar, Direction = System.Data.ParameterDirection.Input }
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc(QueryReksa(), "ReksaCalcFee", ref dbParam, out ds, out cmdOut))
                {
                    decimal Fee, PercentageFeeOutput, FeeBased, RedempUnit, RedempDev, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5;
                    int Period, IsRDB;
                    resultFee.FeeCCY = cmdOut.Parameters["@pcFeeCCY"].Value.ToString();                    
                    decimal.TryParse(cmdOut.Parameters["@pnFee"].Value.ToString(), out Fee);
                    resultFee.Fee = Fee;
                    decimal.TryParse(cmdOut.Parameters["@pdPercentageFeeOutput"].Value.ToString(), out PercentageFeeOutput);
                    resultFee.PercentageFeeOutput = PercentageFeeOutput;
                    decimal.TryParse(cmdOut.Parameters["@pmFeeBased"].Value.ToString(), out FeeBased);
                    resultFee.FeeBased = FeeBased;
                    decimal.TryParse(cmdOut.Parameters["@pmRedempUnit"].Value.ToString(), out RedempUnit);
                    resultFee.RedempUnit = RedempUnit;
                    decimal.TryParse(cmdOut.Parameters["@pmRedempDev"].Value.ToString(), out RedempDev);
                    resultFee.RedempDev = RedempDev;
                    resultFee.ErrMsg = cmdOut.Parameters["@pmErrMsg"].Value.ToString();
                    decimal.TryParse(cmdOut.Parameters["@pmTaxFeeBased"].Value.ToString(), out TaxFeeBased);
                    resultFee.TaxFeeBased = TaxFeeBased;
                    decimal.TryParse(cmdOut.Parameters["@pmFeeBased3"].Value.ToString(), out FeeBased3);
                    resultFee.FeeBased3 = FeeBased3;
                    decimal.TryParse(cmdOut.Parameters["@pmFeeBased4"].Value.ToString(), out FeeBased4);
                    resultFee.FeeBased4 = FeeBased4;
                    decimal.TryParse(cmdOut.Parameters["@pmFeeBased5"].Value.ToString(), out FeeBased5);
                    resultFee.FeeBased5 = FeeBased5;
                    int.TryParse(cmdOut.Parameters["@pnPeriod"].Value.ToString(), out Period);
                    resultFee.Period = Period;
                    int.TryParse(cmdOut.Parameters["@pnIsRDB"].Value.ToString(), out IsRDB);
                    resultFee.IsRDB = IsRDB;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return resultFee;
        }
        public CalculateFeeModel.SwitchingResponses ReksaCalcSwitchingFee(CalculateFeeModel.SwitchingRequest feeModel)
        {
            DataSet ds = new DataSet();
            CalculateFeeModel.SwitchingResponses resultFee = new CalculateFeeModel.SwitchingResponses();
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
                if (this.ExecProc(QueryReksa(), "ReksaCalcSwitchingFee", ref dbParam, out ds, out cmdOut))
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
                throw ex;
            }
            return resultFee;
        }

        public CalculateFeeModel.SwitchingRDBResponses ReksaCalcSwitchingRDBFee(CalculateFeeModel.SwitchingRDBRequest feeModel)
        {
            DataSet ds = new DataSet();
            CalculateFeeModel.SwitchingRDBResponses resultFee = new CalculateFeeModel.SwitchingRDBResponses();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcProdSwitchOut", Value = feeModel.ProdSwitchOut, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnClientSwitchOut", Value = feeModel.ClientSwitchOut, SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Input },
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
                if (this.ExecProc(QueryReksa(), "ReksaCalcSwitchingRDBFee", ref dbParam, out ds, out cmdOut))
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
                throw ex;
            }
            return resultFee;
        }


        public void ReksaCalcBookingFee(string strCIFNo, decimal decAmount, string strProductCode,
            bool IsByPercent, bool IsFeeEdit, decimal decPercentageFeeInput
            , out decimal PercentageFeeOutput, out string FeeCCY, out decimal Fee)
        {
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
                if (this.ExecProc(QueryReksa(), "ReksaCalcBookingFee", ref dbParam, out ds, out cmdOut))
                {
                    FeeCCY = cmdOut.Parameters["@pcFeeCCY"].Value.ToString();
                    decimal.TryParse(cmdOut.Parameters["@pmFee"].Value.ToString(), out Fee);
                    decimal.TryParse(cmdOut.Parameters["@pdPercentageFeeOutput"].Value.ToString(), out PercentageFeeOutput);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        #endregion
    }
}

