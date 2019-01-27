using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace Reksa.Models
{
    public class ParameterModel
    {
        public int Id { get; set; }
        public string Kode { get; set; }
        public string Deskripsi { get; set; }
        public string OfficeId { get; set; }
        public System.DateTime TanggalValuta { get; set; }
    }

}
