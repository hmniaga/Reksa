using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class CustomerModel
    {
        [Required(ErrorMessage = "Title is required.")]
        public string CIFNo { get; set; }
        public string CIFName { get; set; }
        public int NasabahId { get; set; }
    }
}
