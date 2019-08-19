using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class OtorisasiModel
    {
        public class NFSFilePendingDetailOtorisasi
        {
            public string Field { get; set; }
            public string OldValue { get; set; }
            public string NewValue { get; set; }
        }
    }
    public class CheckValiditasDataModel
    {
        public int TranId { get; set; }
        public int TranType { get; set; }
        public double Nominal { get; set; }
        public double Unit { get; set; }
        public bool FullAmount { get; set; }
        public string ChannelDesc { get; set; }
        public double FeeAmount { get; set; }
        public double FeePercent { get; set; }
        public int JangkaWaktu { get; set; }
        public bool AutoRedemp { get; set; }
        public bool Asuransi { get; set; }
        public int FrekPendebetan { get; set; }
    }
}
