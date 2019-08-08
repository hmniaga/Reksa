using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Reksa
{
    public static class clsConvert
    {
        public static List<T> MapListOfObject<T>(DataTable dt)
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
        public static DataTable ToDataTable<T>(this IList<T> data)
        {
            PropertyDescriptorCollection props =
                TypeDescriptor.GetProperties(typeof(T));
            DataTable table = new DataTable();
            for (int i = 0; i < props.Count; i++)
            {
                PropertyDescriptor prop = props[i];
                table.Columns.Add(prop.Name, prop.PropertyType);
            }
            object[] values = new object[props.Count];
            foreach (T item in data)
            {
                for (int i = 0; i < values.Length; i++)
                {
                    values[i] = props[i].GetValue(item);
                }
                table.Rows.Add(values);
            }
            return table;
        }
        public static string GetXML(DataTable dt)
        {
            StringBuilder sb = new StringBuilder();
            string Result;

            sb.Append("<A>");
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (dt.Rows[i][0] != null)
                {
                    sb.Append("<I ");

                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        if (dt.Rows[i][j].ToString().Trim() != "")
                        {
                            sb.Append(dt.Columns[j].ColumnName);
                            sb.Append("=\"");
                            sb.Append(EncodeXML(dt.Rows[i][j].ToString().Trim()));
                            sb.Append("\" ");
                        }
                    }

                    sb.Append(" />");
                }
            }

            sb.Append("</A>");
            Result = sb.ToString();

            return Result;
        }
        private static string EncodeXML(string Data)
        {
            Data = Data.Replace("&", "&amp;").Replace(">", "&gt;").Replace("<", "&lt;").Replace("\"", "&quot;");

            return Data;
        }
    }
}
