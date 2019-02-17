using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Data.OleDb;
using System.Reflection;
using System.Web;
using Microsoft.Extensions.Configuration;
using ReksaQuery;
using System.IO;
using ReksaAPI.Models;

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

        public bool ExecProc(string strProc, ref List<SqlParameter> dbParam)
        {
            DataSet dsResult = null;
            return ExecProc(strProc, ref dbParam, out dsResult);
        }

        private bool ExecProc(string strProc, ref List<SqlParameter> dbParam, out DataSet dsResult)
        {
            dsResult = null;
            _errorMessage = "";
            bool result = true;

            try
            {
                QueryReksa().ExecProc(strProc, ref dbParam, out dsResult);
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
        private bool ExecProc(string strProc, ref List<SqlParameter> dbParam, out DataSet dsResult, out SqlCommand cmdOut)
        {
            dsResult = null;
            _errorMessage = "";
            bool result = true;
            cmdOut = new SqlCommand();

            try
            {
                QueryReksa().ExecProc(strProc, ref dbParam, out dsResult, out cmdOut);
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

        #region "GLOBAL"
        public List<AgenModel> ReksaGetTreeView(int intNIK, string strModule, string strMenu)
        {
            DataSet dsOut = new DataSet();
            List<AgenModel> list = new List<AgenModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcModule", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcMenuName", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strModule, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc("UserGetTreeView", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<AgenModel> result = this.MapListOfObject<AgenModel>(dtOut);
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
        public List<AgenModel> ReksaSrcAgen(string Col1, string Col2, int Validate, int ProdId)
        {
            DataSet dsOut = new DataSet();
            List<AgenModel> list = new List<AgenModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cProdId", SqlDbType = System.Data.SqlDbType.Int, Value = ProdId, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc("ReksaSrcAgen", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<AgenModel> result = this.MapListOfObject<AgenModel>(dtOut);
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
        public List<BankModel> ReksaSrcBank(string Col1, string Col2, int Validate, int ProdId)
        {
            DataSet dsOut = new DataSet();
            List<BankModel> list = new List<BankModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cProdId", SqlDbType = System.Data.SqlDbType.Int, Value = ProdId, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc("ReksaSrcBank", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<BankModel> result = this.MapListOfObject<BankModel>(dtOut);
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
        public List<BookingModel> ReksaSrcBooking(string Col1, string Col2, int Validate, string criteria)
        {
            DataSet dsOut = new DataSet();
            List<BookingModel> list = new List<BookingModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cCriteria", SqlDbType = System.Data.SqlDbType.NVarChar, Value = criteria, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc("ReksaSrcBooking", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<BookingModel> result = this.MapListOfObject<BookingModel>(dtOut);
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
        public List<ClientModel> ReksaSrcClient(string Col1, string Col2, int Validate, int ProdId)
        {
            DataSet dsOut = new DataSet();
            List<ClientModel> list = new List<ClientModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cProdId", SqlDbType = System.Data.SqlDbType.Int, Value = ProdId, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc("ReksaSrcClient", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<ClientModel> result = this.MapListOfObject<ClientModel>(dtOut);
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
        public List<CityModel> ReksaSrcCity(string Col1, string Col2, int Validate)
        {
            DataSet dsOut = new DataSet();
            List<CityModel> list = new List<CityModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                };

                if (this.ExecProc("ReksaSrcCity", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<CityModel> result = this.MapListOfObject<CityModel>(dtOut);
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
        public List<CustomerModel> ReksaSrcCustomer(string Col1, string Col2, int Validate)
        {
            DataSet dsOut = new DataSet();
            List<CustomerModel> list = new List<CustomerModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                };

                if (this.ExecProc("ReksaSrcCIF", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<CustomerModel> result = this.MapListOfObject<CustomerModel>(dtOut);
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
        public List<OfficeModel> ReksaSrcOffice(string Col1, string Col2, int Validate)
        {
            DataSet dsOut = new DataSet();
            List<OfficeModel> list = new List<OfficeModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                };

                if (this.ExecProc("ReksaSrcOffice", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<OfficeModel> result = this.MapListOfObject<OfficeModel>(dtOut);
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
        public List<ProductModel> ReksaSrcProduct(string Col1, string Col2, int Validate, int Status)
        {
            DataSet dsOut = new DataSet();
            List<ProductModel> list = new List<ProductModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.NVarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@cStatus", SqlDbType = System.Data.SqlDbType.Int, Value = Status, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc("ReksaSrcProduct", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<ProductModel> result = this.MapListOfObject<ProductModel>(dtOut);
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

        public List<ReferentorModel> ReksaSrcReferentor(string Col1, string Col2, int Validate)
        {
            DataSet dsOut = new DataSet();
            List<ReferentorModel> list = new List<ReferentorModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@cCol1", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col1, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@cCol2", SqlDbType = System.Data.SqlDbType.VarChar, Value = Col2, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@bValidate", SqlDbType = System.Data.SqlDbType.Int, Value = Validate, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc("ReksaSrcReferentor", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<ReferentorModel> result = this.MapListOfObject<ReferentorModel>(dtOut);
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
        public void ReksaRefreshCustomer(string strCIFNo, int intNIK, string strGuid, ref List<CustomerIdentitasModel> listCutomer, ref List<RiskProfileModel> listRiskProfile)
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

                if (this.ExecProc("ReksaRefreshNasabah", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        DataTable dtOut1 = dsOut.Tables[1];
                        List<CustomerIdentitasModel> resultCust = this.MapListOfObject<CustomerIdentitasModel>(dtOut);
                        List<RiskProfileModel> resultRisk = this.MapListOfObject<RiskProfileModel>(dtOut1);

                        listCutomer.AddRange(resultCust);
                        listRiskProfile.AddRange(resultRisk);
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
                if (this.ExecProc("ReksaGenerateShareholderID", ref dbParam, out ds, out cmdOut))
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

        public void ReksaGetConfAddress(int intType, string strCIFNo, string strBranch, int intID, out string strMessage, int intNIK, string strGuid, ref List<KonfirmasiAddressModel> listKonfAdress, ref List<BranchModel> listBranch)
        {
            DataSet dsOut = new DataSet();
            strMessage = "";
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
                if (this.ExecProc("ReksaGetConfAddress", ref dbParam, out dsOut, out cmdOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOutKonfAddress = dsOut.Tables[1];
                        DataTable dtOutBranch = dsOut.Tables[2];
                        List<KonfirmasiAddressModel> resultKonfAdress = this.MapListOfObject<KonfirmasiAddressModel>(dtOutKonfAddress);
                        List<BranchModel> resultBranch = this.MapListOfObject<BranchModel>(dtOutBranch);

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

        public void ReksaPopulateAktivitas(int ClientId, DateTime dtStartDate, DateTime dtEndDate, int IsBalance, int intNIK, int IsAktivitasOnly, int isMFee, string strGuid, ref List<PopulateAktifitasModel> listPopAktifitas, out decimal decEffBal, out decimal decNomBal)
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

                if (this.ExecProc("ReksaPopulateAktivitas", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<PopulateAktifitasModel> resultPopAktifitas = this.MapListOfObject<PopulateAktifitasModel>(dtOut);
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

        public void ReksaGetListClient(string strCIFNo, ref List<ListClientModel> listClient)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcCIFNo", SqlDbType = System.Data.SqlDbType.VarChar, Value = strCIFNo, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc("ReksaGetListClient", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<ListClientModel> resultClient = this.MapListOfObject<ListClientModel>(dtOut);

                        listClient.AddRange(resultClient);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ReksaRefreshBlokir(int intClientId, int intNIK, string strGuid, ref List<BlokirModel> listBlokir, out decimal decTotal, out decimal decOutstandingUnit)
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

                if (this.ExecProc("ReksaRefreshBlokir", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<BlokirModel> resultBlokir = this.MapListOfObject<BlokirModel>(dtOut);
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

                if (this.ExecProc("ReksaGetCIFData", ref dbParam, out dsOut))
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

        public void ReksaGetAlamatCabang(string strKodeCabang, string strCIFNo, int intID, ref List<AlamatCabangModel> listAlamatCabang)
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

                if (this.ExecProc("ReksaGetAlamatCabang", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<AlamatCabangModel> resultAlamatCabang = this.MapListOfObject<AlamatCabangModel>(dtOut);
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

                if (this.ExecProc("ReksaGetDocStatus", ref dbParam, out dsOut))
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

                if (this.ExecProc("ReksaGetRiskProfile", ref dbParam, out dsOut))
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

        public void ReksaGetListClientRDB(string strClientCode, ref List<ClientRDBModel> listClientRDB)
        {
            DataSet dsOut = new DataSet();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pcClientCode", SqlDbType = System.Data.SqlDbType.VarChar, Value = strClientCode, Direction = System.Data.ParameterDirection.Input}
                };

                if (this.ExecProc("ReksaGetListClientRDB", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];
                        List<ClientRDBModel> resultClientRDB = this.MapListOfObject<ClientRDBModel>(dtOut);
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
                if (this.ExecProc("ReksaValidateOfficeId", ref dbParam, out dsOut, out cmdOut))
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
                if (this.ExecProc("ReksaFlagClientId", ref dbParam, out dsOut))
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
                { };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc("ReksaCekExpRiskProfileParam", ref dbParam, out dsOut))
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

        public void ReksaMaintainBlokir(int intType, int intClientId,
            int intBlockId, decimal decBlockAmount, string strBlockDesc,
            DateTime dtExpiryDate, bool isAccepted, int intNIK, string strGuid,
            out string strErrMsg)
        {
            DataSet dsOut = new DataSet();
            strErrMsg = "";
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@pnType", SqlDbType = System.Data.SqlDbType.Int, Value = intType, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnClientId", SqlDbType = System.Data.SqlDbType.Int, Value = intClientId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnBlockId", SqlDbType = System.Data.SqlDbType.Int, Value = intBlockId, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmBlockAmount", SqlDbType = System.Data.SqlDbType.Decimal, Value = decBlockAmount, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pmBlockDesc", SqlDbType = System.Data.SqlDbType.VarChar, Value = strBlockDesc, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pdExpiryDate", SqlDbType = System.Data.SqlDbType.DateTime, Value = dtExpiryDate, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pbAccepted", SqlDbType = System.Data.SqlDbType.Bit, Value = isAccepted, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input}
                };

                SqlCommand cmdOut = new SqlCommand();
                if (this.ExecProc("ReksaMaintainBlokir", ref dbParam, out dsOut))
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
                if (this.ExecProc("ReksaMaintainBlokir", ref dbParam, out dsOut))
                {
                    strErrMsg = _errorMessage;
                }
            }
            catch (Exception ex)
            {
                strErrMsg = ex.Message.ToString();
            }
        }

        public List<CustomerIdentitasModel> ReksaCekExpRiskProfile(DateTime dtpRiskProfile, long lngCIFNO)
        {
            DataSet dsOut = new DataSet();
            List<CustomerIdentitasModel> list = new List<CustomerIdentitasModel>();
            try
            {
                List<SqlParameter> dbParam = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@dtRiskProfile", SqlDbType = System.Data.SqlDbType.Date, Value = dtpRiskProfile, Direction = System.Data.ParameterDirection.Input},
                    new SqlParameter() { ParameterName = "@dtExpRiskProfile", SqlDbType = System.Data.SqlDbType.Date, Value = dtpRiskProfile, Direction = System.Data.ParameterDirection.Output },
                    new SqlParameter() { ParameterName = "@pnCIFNo", SqlDbType = System.Data.SqlDbType.BigInt, Value = lngCIFNO, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc("ReksaCekExpRiskProfile", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOut = dsOut.Tables[0];

                        List<CustomerIdentitasModel> result = this.MapListOfObject<CustomerIdentitasModel>(dtOut);
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

                if (this.ExecProc("ReksaRefreshParameter", ref dbParam, out dsOut))
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

                if (this.ExecProc("ReksaPopulateParamFee", ref dbParam, out dsOut))
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

                if (this.ExecProc("ReksaPopulateParamFee", ref dbParam, out dsOut))
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

                if (this.ExecProc("ReksaPopulateParamFee", ref dbParam, out dsOut))
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

                if (this.ExecProc("ReksaPopulateParamFee", ref dbParam, out dsOut))
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

                if (this.ExecProc("ReksaMaintainSubsFee", ref dbParam, out dsOut))
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

                if (this.ExecProc("ReksaMaintainMFee", ref dbParam, out dsOut))
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

                if (this.ExecProc("ReksaMaintainRedempFee", ref dbParam, out dsOut))
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

                if (this.ExecProc("ReksaMaintainUpfrontSellingFee", ref dbParam, out dsOut))
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

                if (this.ExecProc("ReksaMaintainSwcFee", ref dbParam, out dsOut))
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
                if (this.ExecProc("ReksaGetPercentTax", ref dbParam, out dsOut, out cmdOut))
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
                if (this.ExecProc("ReksaValidateGL", ref dbParam, out dsOut, out cmdOut))
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
    }
}

