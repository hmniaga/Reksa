﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ReksaQuery
{
    public class ClsQuery
    {

        string m_strServer = "", m_strUserName = "", m_strPassword = "", m_strDatabase = "", m_strProvider = "SQLOLEDB", _strCon = "",
            _strGuid = System.Guid.NewGuid().ToString(),
            strShownUser = "[User]";

        string StartDate;

        public static System.Collections.Generic.Queue<string[]> queError = new Queue<string[]>();
        internal static System.Collections.Generic.Queue<string[]> queDebug = new Queue<string[]>();
        private static System.Collections.Generic.SortedList<string, string> ConDebug = new SortedList<string, string>();

        public enum SSL
        {
            SSLOn = 1,
            SSLOff = 0
        }

        private frmDebug frDebug;

        int m_intTimeout = 30;
        SSL m_UseSSL = 0;
        bool blnAlreadyLogin = false,
            _ErrorExtHandled = false,
            _ShowDebug = false,
            _ReplaceUser = true;

        public bool isReplaceUser
        {
            get { return _ReplaceUser; }
            set { _ReplaceUser = value; }
        }

        public System.Windows.Forms.Form OwnerForm
        {
            get { if (frDebug != null) return frDebug.Owner; else return null; }
            set { if (frDebug != null) frDebug.Owner = value; }
        }

        public string InitializeDate
        {
            get { return StartDate; }
            set { StartDate = value; }
        }

        public string Guid
        {
            get { return _strGuid; }
            set
            {
                _strGuid = value;
            }
        }

        public string ShownUser
        {
            get { return strShownUser; }
            set { strShownUser = value; }
        }

        public int TimeOut
        {
            get { return m_intTimeout; }
            set { if (value > 0) m_intTimeout = value; }
        }

        public SSL UseSSL
        {
            get { return m_UseSSL; }
            set { if (m_UseSSL != value) m_UseSSL = value; }
        }

        public string Password
        {
            get { return ""; }
            set { m_strPassword = value; }
        }

        public string Database
        {
            get { return m_strDatabase; }
            set { m_strDatabase = value; }
        }

        public string Server
        {
            get { return m_strServer; }
            set { m_strServer = value; }
        }

        public string UserName
        {
            get { return ""; }
            set { m_strUserName = value; }
        }

        public string Provider
        {
            get { return m_strProvider; }
            set { m_strProvider = value; }
        }

        public bool isErrorExtHandled
        {
            get { return _ErrorExtHandled; }
            set { _ErrorExtHandled = value; }
        }

        public bool ShowDebug
        {
            get { return _ShowDebug; }
            set
            {
                if (value != _ShowDebug)
                {
                    _ShowDebug = value;
                    if (_ShowDebug)
                        ShowDebugForm();
                    else
                        CloseDebugForm();
                }
            }
        }


        private void ShowDebugForm()
        {
            frDebug = new frmDebug();
            frDebug.onFormClose += new EventHandler(frDebug_onFormClose);
            frDebug.Show();
        }

        void frDebug_onFormClose(object sender, EventArgs e)
        {
            _ShowDebug = false;
            frDebug.Dispose();
            frDebug = null;
        }

        private void CloseDebugForm()
        {
            if (frDebug != null)
                frDebug.Close();
        }

        public void ShowDebugForm(System.Windows.Forms.Form frmParent)
        {
            if (frDebug == null)
            {
                _ShowDebug = true;
                ShowDebugForm();
                frDebug.Owner = frmParent;
            }
        }

        public ClsQuery()
        {
            return;
        }

        /// <summary>
        /// Saat ini hanya support OleDB -- ke SQL Server
        /// </summary>
        /// <param name="strServer">Server Name or Ip</param>
        /// <param name="strUserName">Username</param>
        /// <param name="strPassword"></param>
        /// <param name="strDatabase">Initial Catalog</param>
        public ClsQuery(string strServer, string strUserName, string strPassword,
            string strDatabase)
        {
            m_strServer = strServer;
            m_strUserName = strUserName;
            m_strPassword = strPassword;
            m_strDatabase = strDatabase;
        }

        /// <summary>
        /// utk create connection string
        /// </summary>
        /// <param name="strProvider">Provider, defauld SQLOLEDB.1</param>
        /// <param name="strServer">Server</param>
        /// <param name="strDatabase">initial Database</param>
        /// <param name="strUser">User name</param>
        /// <param name="strPass">Password</param>
        /// <param name="isSSL">penggunaan SSL / tidak (saat ini belum digunakan)</param>
        /// <returns></returns>
        public static string SetupConnection(string strProvider, string strServer, string strDatabase,
            string strUser, string strPass, SSL isSSL) // harus tambah SSL
        {
            if (strUser != "" && strPass != "")
            {
                return "Provider=" + strProvider + ";Initial Catalog=" + strDatabase + ";" +
                    "User Id=" + strUser + ";Password=" + strPass + ";Data Source = " + strServer;
            }
            else
            {
                return "Provider = " + strProvider + ";Server=" + strServer + ";Database=" + strDatabase + ";Trusted_Connection=Yes;";
            }
        }

        #region "Start Connection"
        private bool TryLogin()
        {
            System.Data.OleDb.OleDbConnection con = new System.Data.OleDb.OleDbConnection(_strCon);
            try
            {
                con.Open();
                blnAlreadyLogin = true;
            }
            catch (System.Data.OleDb.OleDbException oleEx)
            {
                SettingError(oleEx, _ErrorExtHandled, _ReplaceUser,
                    m_strUserName, strShownUser);
                blnAlreadyLogin = false;
            }

            catch (Exception ex)
            {
                blnAlreadyLogin = false;
                if (!_ErrorExtHandled)
                    InsertErrorMessage(ex.Source.ToString(), ex.Message.ToString());
                else
                {
                    string[] str = new string[2];
                    str[0] = ex.Source;
                    str[1] = ex.Message;
                    queError.Enqueue(str);
                }
            }

            if (con.State == System.Data.ConnectionState.Open) con.Close();
            con = null;
            return blnAlreadyLogin;
        }

        public bool StartConnection()
        {
            _strCon = SetupConnection(m_strProvider, m_strServer, m_strDatabase,
                m_strUserName, m_strPassword, m_UseSSL);

            string DefDebug = "Provider=" + m_strProvider + ";Initial Catalog=REG_SIBS;" +
                "User Id=" + m_strUserName + ";Password=" + m_strPassword + ";Data Source = " + m_strServer;
            ConDebug.Add(_strGuid, DefDebug);

            return TryLogin();
        }

        #endregion

        #region "Message"
        public static void InsertErrorMessage(string strSource, string strMessage)
        {
            object[] obj = new object[2];
            obj[0] = strSource;
            obj[1] = strMessage;
            FrmMessage frmMessage = new FrmMessage();
            frmMessage.ShowMessage(obj);
            frmMessage.ShowDialog();
            frmMessage = null;
        }

        public static void SetDebugCon(string Guid, string Provider, string Server,
            string Database, string UserName, string Password)
        {
            string Con = "Provider=" + Provider + ";Initial Catalog=" + Database + ";" +
                "User Id=" + UserName + ";Password=" + Password + ";Data Source = " + Server;

            if (!ConDebug.ContainsKey(Guid))
                ConDebug.Add(Guid, Con);
            else
                ConDebug[Guid] = Con;
        }
        #endregion

        #region "Exec Proc"

        public static String HexaToString(Byte[] Data)
        {
            String Hexa = "0123456789ABCDEF";
            String Result = "";
            for (int Loop = 0; Loop < Data.Length; ++Loop)
            {
                Result += Hexa[(Byte)(Data[Loop] / 16)];
                Result += Hexa[(Byte)(Data[Loop] % 16)];
            }
            return Result;
        }

        private static string GetParamValue(string strProc,
            System.Data.OleDb.OleDbParameter[] dbParam)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("exec " + strProc + " ");
            string strStart = "", strEnd = "", strValue;
            if (dbParam != null)
            {
                for (int i = 0; i < dbParam.Length; i++)
                {
                    strValue = "";
                    if ((dbParam[i].OleDbType == System.Data.OleDb.OleDbType.VarChar)
                        || (dbParam[i].OleDbType == System.Data.OleDb.OleDbType.Char)
                        || (dbParam[i].OleDbType == System.Data.OleDb.OleDbType.VarWChar))
                    {
                        if (dbParam[i].Value != null)
                        {
                            strStart = "'";
                            if (i < dbParam.Length - 1)
                                strEnd = "' , ";
                            else
                                strEnd = "'";

                            strValue = dbParam[i].Value.ToString();
                        }
                        else
                        {
                            strStart = "";
                            if (i < dbParam.Length - 1)
                                strEnd = " , ";
                            else
                                strEnd = "";

                            strValue = "NULL";
                        }
                        sb.Append(strStart + strValue + strEnd);
                    }
                    else
                    {
                        if (dbParam[i].Value != null)
                        {
                            if (dbParam[i].OleDbType == System.Data.OleDb.OleDbType.VarBinary ||
                                dbParam[i].OleDbType == System.Data.OleDb.OleDbType.Binary)
                                strValue = HexaToString((byte[])dbParam[i].Value);
                            else
                                strValue = dbParam[i].Value.ToString();
                        }
                        else
                            strValue = "NULL";

                        if (i < dbParam.Length - 1)
                            strEnd = ", ";
                        else
                            strEnd = "";
                        sb.Append(strValue + strEnd);
                    }
                }
            }
            return sb.ToString();
        }

        private static byte[] ConvertToByte(string strProc,
            System.Data.OleDb.OleDbParameter[] dbParam)
        {
            return System.Text.Encoding.Default.GetBytes(GetParamValue(strProc, dbParam));
        }

        private static bool ExecDebugCommand(string strDBName, string strParam, out int DebugNo,
            string Guid)
        {
            DebugNo = -1;
            System.Data.OleDb.OleDbParameter[] dbPrm = new System.Data.OleDb.OleDbParameter[3];
            bool blnConFound = false;
            string ConDefDebug = "";
            if (ConDebug.ContainsKey(Guid))
            {
                blnConFound = true;
                ConDefDebug = ConDebug[Guid];
            }
            if (!blnConFound)
            {
                DebugNo = -2;
                return true;
            }

            System.Data.OleDb.OleDbConnection con = new System.Data.OleDb.OleDbConnection(ConDefDebug);
            System.Data.OleDb.OleDbCommand cmd = new System.Data.OleDb.OleDbCommand();
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.CommandTimeout = 30;
            cmd.Connection = con;

            try
            {
                cmd.CommandText = "insert_debug";
                if (con.State == System.Data.ConnectionState.Closed)
                    con.Open();

                dbPrm[0] = new System.Data.OleDb.OleDbParameter("@bParam",
                    System.Data.OleDb.OleDbType.VarChar, strParam.Length);
                dbPrm[0].Direction = System.Data.ParameterDirection.Input;
                dbPrm[0].Value = strParam;

                dbPrm[1] = new System.Data.OleDb.OleDbParameter("@cDb",
                    System.Data.OleDb.OleDbType.VarChar, 150);
                dbPrm[1].Direction = System.Data.ParameterDirection.Input;
                dbPrm[1].Value = strDBName;

                dbPrm[2] = new System.Data.OleDb.OleDbParameter("@bDebugNo",
                    System.Data.OleDb.OleDbType.Integer);
                dbPrm[2].Direction = System.Data.ParameterDirection.Output;

                cmd.Parameters.Add(dbPrm[0]);
                cmd.Parameters.Add(dbPrm[1]);
                cmd.Parameters.Add(dbPrm[2]);

                cmd.ExecuteNonQuery();
                DebugNo = (int)dbPrm[2].Value;
                return true;
            }
            catch (Exception ex)
            {
                DebugNo = -1;
                throw ex;
                //return false;
            }
            finally
            {
                if (con.State == System.Data.ConnectionState.Open)
                    con.Close();
                cmd.Dispose();
                cmd = null;
            }
        }

        [Obsolete]
        private static bool ExecDebugCommand(string strCon,
            byte[] bytParam, out int DebugNo)
        {
            DebugNo = -1;

            System.Data.OleDb.OleDbParameter[] dbPrm = new System.Data.OleDb.OleDbParameter[3];
            System.Data.OleDb.OleDbConnection con = new System.Data.OleDb.OleDbConnection(strCon);
            System.Data.OleDb.OleDbCommand cmd = new System.Data.OleDb.OleDbCommand();
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.CommandTimeout = 30;
            cmd.Connection = con;

            try
            {
                cmd.CommandText = "insert_debug";
                if (con.State == System.Data.ConnectionState.Closed)
                    con.Open();

                dbPrm[0] = new System.Data.OleDb.OleDbParameter("@bParam",
                    System.Data.OleDb.OleDbType.VarBinary, 8000);
                dbPrm[0].Direction = System.Data.ParameterDirection.Input;
                dbPrm[0].Value = bytParam;

                dbPrm[1] = new System.Data.OleDb.OleDbParameter("@cDb",
                    System.Data.OleDb.OleDbType.VarChar, 150);
                dbPrm[1].Direction = System.Data.ParameterDirection.Input;
                dbPrm[1].Value = con.Database;

                dbPrm[2] = new System.Data.OleDb.OleDbParameter("@bDebugNo",
                    System.Data.OleDb.OleDbType.Integer);
                dbPrm[2].Direction = System.Data.ParameterDirection.Output;

                cmd.Parameters.Add(dbPrm[0]);
                cmd.Parameters.Add(dbPrm[1]);
                cmd.Parameters.Add(dbPrm[2]);

                cmd.ExecuteNonQuery();
                DebugNo = (int)dbPrm[2].Value;
                return true;
            }
            catch (Exception)
            {
                DebugNo = -1;
                return false;
            }
            finally
            {
                if (con.State == System.Data.ConnectionState.Open)
                    con.Close();
                cmd.Dispose();
                cmd = null;
            }
        }

        private static bool CheckTanggal(string Date)
        {
            if ((Date != null) && (Date != System.DateTime.Today.ToString("ddMMyyyy")))
            {
                InsertErrorMessage(" Query", "Tanggal Aplikasi berbeda, Mohon tutup dan buka ulang aplikasi ");
                return false;
            }
            return true;
        }

        private static void SettingError(System.Data.OleDb.OleDbException oleErr,
            bool ExtError, bool ReplaceError,
            string strUser, string strReplaced)
        {
            string[] str = new string[2];
            for (int i = 0; i < oleErr.Errors.Count; i++)
            {
                str[0] = oleErr.Errors[i].Source.ToString();
                str[1] = oleErr.Errors[i].Message.ToString();
                if (ReplaceError)
                    str[1] = str[1].Replace(strUser, strReplaced);

                if (!ExtError)
                    InsertErrorMessage(str[0], str[1]);
                else
                    queError.Enqueue(str);
            }
        }

        public bool ExecProc(string strProc, out System.Data.DataSet dsResult)
        {
            dsResult = null;
            if (!CheckTanggal(StartDate))
                return false;

            _strCon = SetupConnection(m_strProvider, m_strServer, m_strDatabase,
                m_strUserName, m_strPassword, m_UseSSL);
            return fnExecProc(_strGuid, strProc, _strCon, m_intTimeout, _ErrorExtHandled, out dsResult, _ReplaceUser,
                m_strUserName, strShownUser, _ShowDebug);
        }

        public bool ExecProc(string strProc, ref System.Data.OleDb.OleDbParameter[] dbParam)
        {
            if (!CheckTanggal(StartDate))
                return false;

            _strCon = SetupConnection(m_strProvider, m_strServer, m_strDatabase,
                m_strUserName, m_strPassword, m_UseSSL);
            return fnExecProc(_strGuid, strProc, _strCon, m_intTimeout, _ErrorExtHandled,
                ref dbParam, _ReplaceUser, m_strUserName, strShownUser, _ShowDebug);
        }
        public static bool fnExecProc(string _strGuid,
            string strProc, string strCon, int intTimeout,
            bool ExtError, out System.Data.DataSet dsResult,
            bool ReplaceError, string strUser, string strUserReplace, bool UseDebug)
        {
            bool iRet = true;
            int DebugNo = 0;
            System.Data.OleDb.OleDbConnection con = new System.Data.OleDb.OleDbConnection(strCon);
            System.Data.OleDb.OleDbCommand cmd = new System.Data.OleDb.OleDbCommand();
            dsResult = new System.Data.DataSet();
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.CommandTimeout = intTimeout;
            cmd.CommandText = strProc;
            cmd.Connection = con;

            try
            {
                if (UseDebug)
                    iRet = ExecDebugCommand(con.Database, GetParamValue(strProc, null), out DebugNo, _strGuid);

                if (iRet)
                {
                    System.Data.OleDb.OleDbDataAdapter sqlAdp = new System.Data.OleDb.OleDbDataAdapter(cmd);
                    sqlAdp.Fill(dsResult);
                }
            }
            catch (System.Data.OleDb.OleDbException oleEx)
            {
                SettingError(oleEx, ExtError, ReplaceError, strUser, strUserReplace);
                dsResult = null;
                iRet = false;
            }
            catch (Exception ex)
            {
                if (!ExtError)
                    InsertErrorMessage(ex.Source.ToString(), ex.Message.ToString());
                else
                {
                    string[] str = new string[2];
                    str[0] = ex.Source;
                    str[1] = ex.Message;
                    queError.Enqueue(str);
                }
                dsResult = null;
                iRet = false;
            }
            finally
            {
                if (UseDebug)
                {
                    string[] str = new string[2];
                    if (DebugNo != -2)
                    {
                        str[0] = _strGuid;
                        str[1] = "exec Debug " + DebugNo.ToString();
                    }
                    else
                    {
                        str = new string[3];
                        str[0] = _strGuid;
                        str[1] = "Warning : Default Connection for Debug not found, showing to screen !";
                        str[2] = "exec " + strProc;
                    }
                    queDebug.Enqueue(str);
                }
            }

            if (con.State == System.Data.ConnectionState.Open) con.Close();
            cmd = null;
            con = null;
            //}
            return iRet;
        }

        public static bool fnExecProc(string _strGuid, string strProc, string strCon, int intTimeout,
            bool ExtError, ref System.Data.OleDb.OleDbParameter[] dbParam,
            out System.Data.DataSet dsResult,
            bool ReplaceError, string strUser, string strUserReplace, bool UseDebug)
        {
            bool iRet = true;

            int DebugNo = 0;

            System.Data.OleDb.OleDbConnection con = new System.Data.OleDb.OleDbConnection(strCon);
            System.Data.OleDb.OleDbCommand cmd = new System.Data.OleDb.OleDbCommand();
            dsResult = new System.Data.DataSet();
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.CommandTimeout = intTimeout;
            cmd.CommandText = strProc;
            cmd.Connection = con;
            string Param = "";
            if (dbParam != null)
            {
                for (int i = 0; i < dbParam.Length; i++)
                    cmd.Parameters.Add(dbParam[i]);
            }
            try
            {
                if (UseDebug)
                {
                    Param = GetParamValue(strProc, dbParam);
                    iRet = ExecDebugCommand(con.Database, Param, out DebugNo, _strGuid);
                }

                if (iRet)
                {
                    System.Data.OleDb.OleDbDataAdapter sqlAdp = new System.Data.OleDb.OleDbDataAdapter(cmd);
                    sqlAdp.Fill(dsResult);
                }
            }
            catch (System.Data.OleDb.OleDbException oleEx)
            {
                SettingError(oleEx, ExtError, ReplaceError, strUser, strUserReplace);
                dsResult = null;
                iRet = false;
            }
            catch (Exception ex)
            {
                if (!ExtError)
                    InsertErrorMessage(ex.Source.ToString(), ex.Message.ToString());
                else
                {
                    string[] str = new string[2];
                    str[0] = ex.Source;
                    str[1] = ex.Message;
                    queError.Enqueue(str);
                }
                dsResult = null;
                iRet = false;
            }
            finally
            {
                if (UseDebug)
                {

                    string[] str = new string[2];
                    if (DebugNo != -2)
                    {
                        str[0] = _strGuid;
                        str[1] = "exec Debug " + DebugNo.ToString();
                    }
                    else
                    {
                        str = new string[3];
                        str[0] = _strGuid;
                        str[1] = "Warning : Default Connection for Debug not found, showing to screen !";
                        str[2] = Param;
                    }
                    queDebug.Enqueue(str);
                }
            }
            if (con.State == System.Data.ConnectionState.Open) con.Close();
            if (cmd != null) cmd.Dispose();
            cmd = null;
            con = null;
            //}
            return iRet;
        }

        /// <summary>
        /// Exec SQL procedure
        /// </summary>
        /// <param name="strProc">Nama stored proc yang akan di exec</param>
        /// <param name="dbParam">array OleDBParameter utk pengisian parameter</param>
        /// <param name="dsResult">output DataSet result dari exec stored proc</param>
        /// <returns>True --> berhasil, False --> gagal</returns>
        public bool ExecProc(string strProc,
                ref System.Data.OleDb.OleDbParameter[] dbParam,
                out System.Data.DataSet dsResult)
        {
            dsResult = null;
            if (!CheckTanggal(StartDate))
                return false;

            _strCon = SetupConnection(m_strProvider, m_strServer, m_strDatabase,
                m_strUserName, m_strPassword, m_UseSSL);
            return fnExecProc(_strGuid, strProc, _strCon, m_intTimeout,
                _ErrorExtHandled, ref dbParam, out dsResult, _ReplaceUser
                , m_strUserName, strShownUser, _ShowDebug);
        }
        /// <summary>
        /// Exec SQL procedure
        /// </summary>
        /// <param name="strProc">Nama stored proc yang akan di exec</param>
        /// <param name="dbParam">array OleDBParameter utk pengisian parameter</param>
        /// <param name="drResult">output DataSet result dari exec stored proc</param>
        /// <returns></returns>
        public bool ExecProc(string strProc,
                ref System.Data.OleDb.OleDbParameter[] dbParam,
                out System.Data.OleDb.OleDbDataReader drResult)
        {
            _strCon = SetupConnection(m_strProvider, m_strServer, m_strDatabase,
                m_strUserName, m_strPassword, m_UseSSL);
            return fnExecProc(_strGuid, strProc, _strCon, m_intTimeout, _ErrorExtHandled,
                ref dbParam, out drResult, _ReplaceUser, m_strUserName,
                strShownUser, _ShowDebug);
        }

        public static bool fnExecProc(string _strGuid, string strProc, string strCon,
            int intTimeout, bool ExtError,
            ref System.Data.OleDb.OleDbParameter[] dbParam,
            bool ReplaceError, string strUser, string strUserReplace, bool UseDebug)
        {
            bool iRet = true;

            int DebugNo = 0;
            System.Data.OleDb.OleDbConnection con = new System.Data.OleDb.OleDbConnection(strCon);
            System.Data.OleDb.OleDbCommand cmd = new System.Data.OleDb.OleDbCommand();
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.CommandTimeout = intTimeout;
            cmd.CommandText = strProc;
            cmd.Connection = con;
            string Param = "";
            if (dbParam != null)
            {
                for (int i = 0; i < dbParam.Length; i++)
                    cmd.Parameters.Add(dbParam[i]);
            }
            try
            {
                if (UseDebug)
                {
                    Param = GetParamValue(strProc, dbParam);
                    iRet = ExecDebugCommand(con.Database, Param, out DebugNo, _strGuid);
                }

                if (iRet)
                {
                    if (cmd.Connection.State == System.Data.ConnectionState.Closed) cmd.Connection.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (System.Data.OleDb.OleDbException oleEx)
            {
                SettingError(oleEx, ExtError, ReplaceError, strUser, strUserReplace);
                iRet = false;
            }
            catch (Exception ex)
            {
                if (!ExtError)
                    InsertErrorMessage(ex.Source.ToString(), ex.Message.ToString());
                else
                {
                    string[] str = new string[2];
                    str[0] = ex.Source;
                    str[1] = ex.Message;
                    queError.Enqueue(str);
                }
                iRet = false;
            }
            finally
            {
                if (UseDebug)
                {
                    string[] str = new string[2];
                    if (DebugNo != -2)
                    {
                        str[0] = _strGuid;
                        str[1] = "exec Debug " + DebugNo.ToString();
                    }
                    else
                    {
                        str = new string[3];
                        str[0] = _strGuid;
                        str[1] = "Warning : Default Connection for Debug not found, showing to screen !";
                        str[2] = Param;
                    }

                    queDebug.Enqueue(str);
                }
            }
            if (con.State == System.Data.ConnectionState.Open) con.Close();
            if (cmd != null) cmd.Dispose();
            cmd = null;
            con = null;
            //}
            return iRet;
        }

        public static bool fnExecProc(string _strGuid, string strProc, string strCon, int intTimeout,
            bool ExtError, ref System.Data.OleDb.OleDbParameter[] dbParam,
            out System.Data.OleDb.OleDbDataReader drResult,
            bool ReplaceError, string strUser, string strUserReplace, bool UseDebug)
        {
            bool iRet = true;
            int DebugNo = 0;
            System.Data.OleDb.OleDbConnection con = new System.Data.OleDb.OleDbConnection(strCon);
            System.Data.OleDb.OleDbCommand cmd = new System.Data.OleDb.OleDbCommand();
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.CommandTimeout = intTimeout;
            cmd.CommandText = strProc;
            cmd.Connection = con;
            drResult = null;
            string Param = "";
            if (dbParam != null)
            {
                for (int i = 0; i < dbParam.Length; i++)
                    cmd.Parameters.Add(dbParam[i]);
            }
            try
            {
                if (UseDebug)
                {
                    Param = GetParamValue(strProc, dbParam);
                    iRet = ExecDebugCommand(con.Database, Param, out DebugNo, _strGuid);
                }

                if (iRet)
                {
                    if (cmd.Connection.State == System.Data.ConnectionState.Closed) cmd.Connection.Open();
                    drResult = cmd.ExecuteReader();
                }
            }
            catch (System.Data.OleDb.OleDbException oleEx)
            {
                SettingError(oleEx, ExtError, ReplaceError, strUser, strUserReplace);
                drResult = null;
                iRet = false;
            }
            catch (Exception ex)
            {
                if (!ExtError)
                    InsertErrorMessage(ex.Source.ToString(), ex.Message.ToString());
                else
                {
                    string[] str = new string[2];
                    str[0] = ex.Source;
                    str[1] = ex.Message;
                    queError.Enqueue(str);
                }
                drResult = null;
                iRet = false;
            }
            finally
            {
                if (UseDebug)
                {
                    string[] str = new string[2];
                    if (DebugNo != -2)
                    {
                        str[0] = _strGuid;
                        str[1] = "exec Debug " + DebugNo.ToString();
                    }
                    else
                    {
                        str = new string[3];
                        str[0] = _strGuid;
                        str[1] = "Warning : Default Connection for Debug not found, showing to screen !";
                        str[2] = Param;
                    }

                    queDebug.Enqueue(str);
                }
            }
            if (con.State == System.Data.ConnectionState.Open) con.Close();
            if (cmd != null) cmd.Dispose();
            cmd = null;
            con = null;
            //}
            return iRet;
        }

        /// <summary>
        /// exec stored proc dengan output data reader
        /// </summary>
        /// <param name="strProc">Nama stored proc yang di exec</param>
        /// <param name="strCon">connection string</param>
        /// <param name="intTimeout">time out</param>
        /// <param name="ExtError">false --> error di show otomatis, true -- error di ambil dari queError</param>
        /// <param name="drResult">Data reader hasil exec proc</param>
        /// <returns></returns>
        public static bool fnExecProc(string _strGuid, string strProc, string strCon, int intTimeout,
            bool ExtError, out System.Data.OleDb.OleDbDataReader drResult,
            bool ReplaceError, string strUser, string strUserReplace, bool UseDebug)
        {
            bool iRet = true;
            int DebugNo = 0;

            System.Data.OleDb.OleDbConnection con = new System.Data.OleDb.OleDbConnection(strCon);
            System.Data.OleDb.OleDbCommand cmd = new System.Data.OleDb.OleDbCommand();
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.CommandTimeout = intTimeout;
            cmd.CommandText = strProc;
            cmd.Connection = con;
            drResult = null;

            try
            {
                if (cmd.Connection.State == System.Data.ConnectionState.Closed) cmd.Connection.Open();
                if (UseDebug)
                    iRet = ExecDebugCommand(con.Database, GetParamValue(strProc, null), out DebugNo, _strGuid);

                if (iRet)
                {
                    drResult = cmd.ExecuteReader();
                }
            }
            catch (System.Data.OleDb.OleDbException oleEx)
            {
                SettingError(oleEx, ExtError, ReplaceError, strUser, strUserReplace);
                drResult = null;
                iRet = false;
            }
            catch (Exception ex)
            {
                if (!ExtError)
                    InsertErrorMessage(ex.Source.ToString(), ex.Message.ToString());
                else
                {
                    string[] str = new string[2];
                    str[0] = ex.Source;
                    str[1] = ex.Message;
                    queError.Enqueue(str);
                }

                drResult = null;
                iRet = false;
            }
            finally
            {
                if (UseDebug)
                {
                    string[] str = new string[2];
                    if (DebugNo != -2)
                    {
                        str[0] = _strGuid;
                        str[1] = "exec Debug " + DebugNo.ToString();
                    }
                    else
                    {
                        str = new string[3];
                        str[0] = _strGuid;
                        str[1] = "Warning : Default Connection for Debug not found, showing to screen !";
                        str[2] = "exec " + strProc;
                    }
                    queDebug.Enqueue(str);
                }
            }
            if (con.State == System.Data.ConnectionState.Open) con.Close();
            if (cmd != null) cmd.Dispose();
            cmd = null;
            con = null;
            //}
            return iRet;
        }

        #endregion

        public static void ClearResource()
        {
            if (queError != null)
                queError.Clear();
        }

    }
}