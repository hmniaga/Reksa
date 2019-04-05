using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class DocumentModel
    {
        public string DocFCSubscriptionForm { get; set; }
        public string DocFCDevidentAuthLetter { get; set; }
        public string DocFCJoinAcctStatementLetter { get; set; }
        public string DocFCIDCopy { get; set; }
        public string DocFCOthers { get; set; }
        public string DocTCSubscriptionForm { get; set; }
        public string DocTCTermCondition { get; set; }
        public string DocTCProspectus { get; set; }
        public string DocTCFundFactSheet { get; set; }
        public string DocTCOthers { get; set; }
    }
}
