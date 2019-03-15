using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class FileModel
    {
        public class NFSFileListType
        {
            public string FileCode { get; set; }
            public string FileDesc { get; set; }
        }

        public class NFSFormatFile
        {
            public string FileCode { get; set; }
            public string FileDesc { get; set; }
            public string FieldSeparator { get; set; }
            public string FormatFile { get; set; }
            public string FilterFileDialog { get; set; }
            public string FieldKey1 { get; set; }
        }
    }
}
