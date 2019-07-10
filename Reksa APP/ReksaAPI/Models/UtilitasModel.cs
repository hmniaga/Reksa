using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class UtilitasModel
    {
    }
    public class ProcessModel
    {
        public bool CheckB { get; set; }
        public int ProcessId { get; set; }
        public string SPName { get; set; }
        public string ProcessName { get; set; }
        public int ProcessStatus { get; set; }
        public DateTime CutOffSystem { get; set; }
    }
    public class UploadNAV
    {
        public List<listNAV> listNAV { get; set; }
    }
    public class listNAV
    {
        public string Tanggal { get; set; }
        public string KodeProduk { get; set; }
        public string NAV { get; set; }
        public string Deviden { get; set; }
        public string Kurs { get; set; }
        public string NAVMFee { get; set; }
    }
}
