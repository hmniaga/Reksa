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
                    new SqlParameter() { ParameterName = "@pcShareholderID", SqlDbType = System.Data.SqlDbType.VarChar, Value = shareholderID, Direction = System.Data.ParameterDirection.InputOutput},
                };

                if (this.ExecProc("ReksaGenerateShareholderID", ref dbParam, out ds))
                {
                    shareholderID = ds.Tables[0].Rows[1][1].ToString();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return shareholderID;
        }

        public void ReksaGetConfAddress(int intType, string strCIFNo, string strBranch,int intID, out string strMessage, int intNIK, string strGuid, ref List<KonfirmasiAddressModel> listKonfAdress, ref List<BranchModel> listBranch)
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
                    new SqlParameter() { ParameterName = "@pcMessage", SqlDbType = System.Data.SqlDbType.VarChar, Value = strMessage, Direction = System.Data.ParameterDirection.Output },
                    new SqlParameter() { ParameterName = "@pnNIK", SqlDbType = System.Data.SqlDbType.Int, Value = intNIK, Direction = System.Data.ParameterDirection.Input },
                    new SqlParameter() { ParameterName = "@pcGuid", SqlDbType = System.Data.SqlDbType.VarChar, Value = strGuid, Direction = System.Data.ParameterDirection.Input }
                };

                if (this.ExecProc("ReksaGetConfAddress", ref dbParam, out dsOut))
                {
                    if (dsOut != null && dsOut.Tables.Count > 0)
                    {
                        DataTable dtOutKonfAddress = dsOut.Tables[1];
                        DataTable dtOutBranch = dsOut.Tables[2];
                        List<KonfirmasiAddressModel> resultKonfAdress = this.MapListOfObject<KonfirmasiAddressModel>(dtOutKonfAddress);
                        List<BranchModel> resultBranch = this.MapListOfObject<BranchModel>(dtOutBranch);

                        listKonfAdress.AddRange(resultKonfAdress);
                        listBranch.AddRange(resultBranch);
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

        public void ReksaGetCIFData(int intClientId, int intNIK, string strGuid, ref List<BlokirModel> listBlokir, out decimal decTotal, out decimal decOutstandingUnit)
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

                if (this.ExecProc("ReksaGetCIFData", ref dbParam, out dsOut))
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

        public void ReksaGetAlamatCabang(int intClientId, int intNIK, string strGuid, ref List<BlokirModel> listBlokir, out decimal decTotal, out decimal decOutstandingUnit)
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

                if (this.ExecProc("ReksaGetAlamatCabang", ref dbParam, out dsOut))
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

        public void ReksaGetDocStatus(int intClientId, int intNIK, string strGuid, ref List<BlokirModel> listBlokir, out decimal decTotal, out decimal decOutstandingUnit)
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

                if (this.ExecProc("ReksaGetDocStatus", ref dbParam, out dsOut))
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

        #endregion      
    }
}

