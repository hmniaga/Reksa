using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace AFReksa
{
    public static class FunctionBatch
    {
        static clsDatabase cls;
        static FunctionBatch()
        {
            cls = new clsDatabase();
        }
        /// <summary>
        /// CRON expressions how often a trigger/the Azure function
        /// </summary>
        /// <param name="0 * * * * *">every minute</param>
        /// <param name="0 */5 * * * *">every 5 minutes</param>
        /// <param name="0 0 * * * *">every hour (hourly)</param>
        /// <param name="0 0 */6 * * *">every 6 hours</param>
        /// <param name="0 0 8-18 * * *">every hour between 8-18</param>
        /// <param name="0 0 0 * * *">every day (daily)</param>
        /// <param name="0 0 10 * * *">every day at 10:00:00</param>
        /// <param name="0 0 * * * 1-5">every hour on workdays</param>
        /// <param name="0 0 0 * * 0">every sunday (weekly)</param>
        /// <param name="0 0 9 * * MON">every monday at 09:00:00</param>
        /// <param name="0 0 0 1 * *">every 1st of month (monthly)</param>
        /// <param name="0 0 0 1 1 *">every 1st of january (yearly)</param>
        /// <param name="0 0 * * * SUN">every hour on sunday</param>
        /// <param name="0 0 0 * * SAT,SUN">every saturday and sunday</param>
        /// <param name="0 0 0 * * 6,0">every saturday and sunday</param>
        /// <param name="0 0 0 1-7 * SUN">every first sunday of the month at 00:00:00</param>
        /// <param name="11 5 23 * * *">daily at 23:05:11</param>
        /// <param name="30 5 /6 * * *">every 6 hours at 5 minutes and 30 seconds</param>
        /// <param name="*/15 * * * * *">every 15 seconds</param>

        [FunctionName("FunctionBatch")]
        public static void Run([TimerTrigger("0 0 0 * * *")]TimerInfo myTimer, ILogger log)
        {
            bool blnResult = false;
            string ErrMsg = "";
            log.LogInformation($"AF Reksa Timer trigger function executed at: {DateTime.Now}");
            string strCommand = "update dbo.control_table set current_working_date = getdate()\n\n" +
                "update dbo.control_table " +
                                "set previous_working_date = dateadd(dd, -1, current_working_date), " +
                                "next_working_date = dateadd(dd, 1, current_working_date) ";
            blnResult = cls.ExecCommand(strCommand, out ErrMsg);
            if (blnResult)
            {
                log.LogInformation($"AF Reksa Timer trigger function success executed at: {DateTime.Now}");
            }
            else
            {
                log.LogInformation($"AF Reksa Timer trigger function error : {ErrMsg}");
            }
        }
    }
}
