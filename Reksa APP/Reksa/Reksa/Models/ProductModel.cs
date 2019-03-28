using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class ProductModel
    {
        public string ProdCode { get; set; }
        public string ProdName { get; set; }
        public int? ProdId { get; set; }
    }

    public class TransaksiProduct
    {
        public string ProdCode { get; set; }
        public string ProdName { get; set; }
        public string ProdId { get; set; }
        public string ProdCCY { get; set; }
    }
}
