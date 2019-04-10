using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
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
}
