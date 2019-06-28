using System;
using System.Collections.Generic;
using System.Linq;
using ReksaQuery;
using System.Data.SqlClient;
using System.Data;

namespace AFReksa
{
    class clsDatabase
    {
        public clsDatabase()
        {
        }
        public ClsQuery QueryReksa()
        {
            ClsQuery _cq = new ClsQuery();
            _cq.Server = "tcp:reksa.database.windows.net,1433";
            _cq.Database = "SQL_REKSA";
            _cq.UserName = "reksa_admin";
            _cq.Password = "T3st1n9123!";
            _cq.isErrorExtHandled = true;
            ClsQuery.queError.Clear();
            return _cq;
        }
        public bool ExecProc(ClsQuery clsQuery, string strProc, ref List<SqlParameter> dbParam, out SqlCommand cmdOut, out string ErrMsg)
        {
            ErrMsg = "";
            bool result = true;
            cmdOut = new System.Data.SqlClient.SqlCommand();

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
        public bool ExecCommand(string strCommand, out DataSet dsResult, out string ErrMsg)
        {
            ClsQuery clsQuery = QueryReksa();
            ErrMsg = "";
            bool result = true;
            dsResult = new DataSet();

            try
            {
                result = clsQuery.ExecCommand(strCommand, out dsResult, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
                result = false;
            }
            return result;
        }
        public bool ExecCommand(string strCommand, out string ErrMsg)
        {
            ClsQuery clsQuery = QueryReksa();
            ErrMsg = "";
            bool result = true;

            try
            {
                result = clsQuery.ExecCommand(strCommand, out ErrMsg);
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
                result = false;
            }
            return result;
        }
        public bool ReksaEODQuery(bool hasResult, string strCommand, List<SqlParameter> listParam, out DataSet dsOut, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            dsOut = new DataSet();
            SqlCommand cmdOut = new SqlCommand();
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
                    blnResult = this.ExecProc(QueryReksa(), strCommand, ref listParam, out dsOut, out cmdOut, out ErrMsg);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
    }
}
