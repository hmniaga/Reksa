using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace ReksaQuery
{
    public class ClsQuery
    {

        string m_strServer = "", m_strUserName = "", m_strPassword = "", m_strDatabase = "", m_strProvider = "", _strCon = "",
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
        
        public ClsQuery()
        {
            return;
        }

        public ClsQuery(string strServer, string strUserName, string strPassword, string strDatabase)
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
                return "Server = " + strServer + ";Initial Catalog=" + strDatabase + ";" + "Persist Security Info=False" +
                    ";User ID=" + strUser + ";Password=" + strPass + ";MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";
            }
            else
            {
                return "Provider = " + strProvider + ";Server=" + strServer + ";Database=" + strDatabase + ";Trusted_Connection=Yes;";
            }
        }

        #region "Start Connection"
        private bool TryLogin()
        {
            SqlConnection con = new SqlConnection(_strCon);
            try
            {
                con.Open();
                blnAlreadyLogin = true;
            }
            catch (SqlException oleEx)
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
            List<SqlParameter> dbParam)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("exec " + strProc + " ");
            string strStart = "", strEnd = "", strValue;
            if (dbParam != null)
            {
                for (int i = 0; i < dbParam.Count; i++)
                {
                    strValue = "";
                    if ((dbParam[i].SqlDbType == System.Data.SqlDbType.VarChar)
                        || (dbParam[i].SqlDbType == System.Data.SqlDbType.Char)
                        || (dbParam[i].SqlDbType == System.Data.SqlDbType.NVarChar))
                    {
                        if (dbParam[i].Value != null)
                        {
                            strStart = "'";
                            if (i < dbParam.Count - 1)
                                strEnd = "' , ";
                            else
                                strEnd = "'";

                            strValue = dbParam[i].Value.ToString();
                        }
                        else
                        {
                            strStart = "";
                            if (i < dbParam.Count - 1)
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
                            if (dbParam[i].SqlDbType == System.Data.SqlDbType.VarBinary ||
                                dbParam[i].SqlDbType == System.Data.SqlDbType.Binary)
                                strValue = HexaToString((byte[])dbParam[i].Value);
                            else
                                strValue = dbParam[i].Value.ToString();
                        }
                        else
                            strValue = "NULL";

                        if (i < dbParam.Count - 1)
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
            List<SqlParameter> dbParam)
        {
            return System.Text.Encoding.Default.GetBytes(GetParamValue(strProc, dbParam));
        }

        private static bool ExecDebugCommand(string strDBName, string strParam, out int DebugNo,
            string Guid)
        {
            DebugNo = -1;
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

            SqlConnection con = new SqlConnection(ConDefDebug);
            SqlCommand cmd = new SqlCommand();
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.CommandTimeout = 30;
            cmd.Connection = con;

            try
            {
                cmd.CommandText = "insert_debug";
                if (con.State == System.Data.ConnectionState.Closed)
                    con.Open();

                List<SqlParameter> dbPrm = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@bParam", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strParam, Direction = System.Data.ParameterDirection.Input},
                new SqlParameter() { ParameterName = "@cDb", SqlDbType = System.Data.SqlDbType.NVarChar, Value = strDBName, Direction = System.Data.ParameterDirection.Input },
                new SqlParameter() { ParameterName = "@bDebugNo", SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Output }
                };

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

            SqlConnection con = new SqlConnection(strCon);
            SqlCommand cmd = new SqlCommand();
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.CommandTimeout = 30;
            cmd.Connection = con;

            try
            {
                cmd.CommandText = "insert_debug";
                if (con.State == System.Data.ConnectionState.Closed)
                    con.Open();

                List<SqlParameter> dbPrm = new List<SqlParameter>()
                {
                    new SqlParameter() { ParameterName = "@bParam", SqlDbType = System.Data.SqlDbType.VarBinary, Value = bytParam, Direction = System.Data.ParameterDirection.Input},
                new SqlParameter() { ParameterName = "@cDb", SqlDbType = System.Data.SqlDbType.NVarChar, Value = con.Database, Direction = System.Data.ParameterDirection.Input },
                new SqlParameter() { ParameterName = "@bDebugNo", SqlDbType = System.Data.SqlDbType.Int, Direction = System.Data.ParameterDirection.Output }
                };

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
        private static void SettingError(SqlException oleErr, bool ExtError, bool ReplaceError, string strUser, string strReplaced)
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
        public bool ExecProc(string strProc, ref List<SqlParameter> dbParam, out SqlCommand cmdOut, out string ErrMsg)
        {
            cmdOut = new SqlCommand();
            ErrMsg = "";

            if (!CheckTanggal(StartDate))
                return false;

            _strCon = SetupConnection(m_strProvider, m_strServer, m_strDatabase,
                m_strUserName, m_strPassword, m_UseSSL);
            return fnExecProc(_strGuid, strProc, _strCon, m_intTimeout, _ErrorExtHandled,
                ref dbParam, _ReplaceUser, m_strUserName, strShownUser, _ShowDebug, out cmdOut, out ErrMsg);
        }

        public static bool fnExecProc(string _strGuid, string strProc, string strCon, int intTimeout,
            bool ExtError, ref List<SqlParameter> dbParam,
            out System.Data.DataSet dsResult,
            bool ReplaceError, string strUser, string strUserReplace, bool UseDebug,
            out SqlCommand cmdOut, out string ErrMsg)
        {
            bool iRet = true;
            cmdOut = new SqlCommand();
            ErrMsg = "";
            int DebugNo = 0;

            SqlConnection con = new SqlConnection(strCon);
            SqlCommand cmd = new SqlCommand();
            dsResult = new System.Data.DataSet();
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.CommandTimeout = intTimeout;
            cmd.CommandText = strProc;
            cmd.Connection = con;
            string Param = "";
            if (dbParam != null)
            {
                for (int i = 0; i < dbParam.Count; i++)
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
                    SqlDataAdapter sqlAdp = new SqlDataAdapter(cmd);
                    sqlAdp.Fill(dsResult);
                    cmdOut = cmd;
                }
            }
            catch (SqlException oleEx)
            {
                SettingError(oleEx, ExtError, ReplaceError, strUser, strUserReplace);
                ErrMsg = oleEx.Errors[0].Message.ToString();
                cmdOut = cmd;
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
                    cmdOut = cmd;
                    ErrMsg = ex.Message;
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
        public bool ExecProc(string strProc, ref List<SqlParameter> dbParam,
            out System.Data.DataSet dsResult, out SqlCommand cmdOut, out string ErrMsg)
        {
            dsResult = null;
            cmdOut = new SqlCommand();
            ErrMsg = "";
            if (!CheckTanggal(StartDate))
                return false;

            _strCon = SetupConnection(m_strProvider, m_strServer, m_strDatabase,
                m_strUserName, m_strPassword, m_UseSSL);
            return fnExecProc(_strGuid, strProc, _strCon, m_intTimeout, _ErrorExtHandled, ref dbParam, out dsResult, _ReplaceUser
                , m_strUserName, strShownUser, _ShowDebug, out cmdOut, out ErrMsg);
        }

        public static bool fnExecProc(string _strGuid, string strProc, string strCon, int intTimeout,
            bool ExtError, ref List<SqlParameter> dbParam,
            bool ReplaceError, string strUser, string strUserReplace, bool UseDebug,
            out SqlCommand cmdOut, out string ErrMsg)
        {
            bool iRet = true;
            cmdOut = new SqlCommand();
            ErrMsg = "";

            int DebugNo = 0;

            SqlConnection con = new SqlConnection(strCon);
            SqlCommand cmd = new SqlCommand();
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.CommandTimeout = intTimeout;
            cmd.CommandText = strProc;
            cmd.Connection = con;
            string Param = "";
            if (dbParam != null)
            {
                for (int i = 0; i < dbParam.Count; i++)
                {
                    cmd.Parameters.Add(dbParam[i]);
                }
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
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException oleEx)
            {
                SettingError(oleEx, ExtError, ReplaceError, strUser, strUserReplace);
                ErrMsg = oleEx.Errors[0].Message.ToString();
                cmdOut = cmd;
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
                    cmdOut = cmd;
                    ErrMsg = ex.Message;
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
        #endregion

        public static void ClearResource()
        {
            if (queError != null)
                queError.Clear();
        }

        public bool ExecCommand(string strCommand, out DataSet dsOut, out string ErrMsg)
        {
            DataSet dsTemp = new DataSet();
            dsOut = new DataSet();
            SqlConnection myConn = new SqlConnection();
            SqlCommand myComm = new SqlCommand();
            ErrMsg = "";

            try
            {
                string ConnString = "Server = " + m_strServer + ";Initial Catalog=" + m_strDatabase + ";" + "Persist Security Info=False" +
                    ";User ID=" + m_strUserName + ";Password=" + m_strPassword + ";MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";

                myConn.ConnectionString = ConnString;
                myConn.Open();
                myComm.Connection = myConn;
                myComm.CommandType = CommandType.Text;
                myComm.CommandTimeout = 30;
                myComm.CommandText = strCommand;
                //20111024, indra_w, ODTJH11003, end

                SqlDataAdapter myAdapter = new SqlDataAdapter(myComm);
                myAdapter.Fill(dsTemp);
                myComm.Connection.Close();

                dsOut = dsTemp;
                return true;

            }
            catch (Exception ex)
            {
                if ((myComm.Connection != null) && (myComm.Connection.State == ConnectionState.Open))
                    myComm.Connection.Close();

                ErrMsg = ex.Message;
                return false;
            }
        }
        public bool ExecCommand(string strCommand, out string ErrMsg)
        {
            SqlConnection myConn = new SqlConnection();
            SqlCommand myComm = new SqlCommand();
            ErrMsg = "";

            string ConnString = "Server = " + m_strServer + ";Initial Catalog=" + m_strDatabase + ";" + "Persist Security Info=False" +
                ";User ID=" + m_strUserName + ";Password=" + m_strPassword + ";MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";

            try
            {
                myConn.ConnectionString = ConnString;
                myConn.Open();
                myComm.Connection = myConn;
                myComm.CommandType = CommandType.Text;
                myComm.CommandTimeout = 30;
                myComm.CommandText = strCommand;

                myComm.ExecuteNonQuery();
                myComm.Connection.Close();

                return true;
            }
            catch (Exception ex)
            {
                if ((myComm.Connection != null) && (myComm.Connection.State == ConnectionState.Open))
                    myComm.Connection.Close();

                ErrMsg = ex.Message;
                return false;
            }
        }
    }
}
