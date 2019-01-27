using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class ParameterGlobalModel
    {
        public int Id { get; set; }
        public string Kode { get; set; }
        public string Deskripsi { get; set; }
        public string OfficeId { get; set; }
        public System.DateTime TanggalValuta { get; set; }
    }
}
