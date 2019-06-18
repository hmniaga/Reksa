using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class ReportModel
    {
    }
    public class ReportMenuModel
    {
        public int ReportId { get; set; }
        public string ReportCode { get; set; }
        public string ReportName { get; set; }
        public string ReportAction { get; set; }
        public string ReportController { get; set; }
    }
}
