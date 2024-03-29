using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;

namespace AFReksa
{
    public class FunctionEOD
    {
        static clsDatabase cls;
        static FunctionEOD()
        {           
            cls = new clsDatabase();
        }

        [FunctionName("FunctionEOD")]
        public static async Task<HttpResponseMessage> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)]HttpRequestMessage req, TraceWriter log)
        {
            log.Info("AFReksa HTTP trigger function processed a request.");

            bool blnResult;
            string ErrMsg;
            DataSet dsResult = new DataSet();
            DataTable dt = new DataTable();
            List<SqlParameter> listParam = new List<SqlParameter>();
            string strCommand = "";
            blnResult = cls.ReksaEODQuery(true, strCommand, listParam, out dsResult, out ErrMsg);

            // parse query parameter
            string name = req.GetQueryNameValuePairs()
                .FirstOrDefault(q => string.Compare(q.Key, "name", true) == 0)
                .Value;

            if (name == null)
            {
                // Get request body
                dynamic data = await req.Content.ReadAsAsync<object>();
                name = data?.name;
            }

            return name == null
                ? req.CreateResponse(HttpStatusCode.BadRequest, "Please pass a name on the query string or in the request body")
                : req.CreateResponse(HttpStatusCode.OK, "Hello " + name);
        }
    }
}
