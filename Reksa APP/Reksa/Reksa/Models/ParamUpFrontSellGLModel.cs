using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class ParamUpFrontSellGLModel
    {
        public string TrxType { get; set; }
        public int ProdId { get; set; }
        public int Sequence { get; set; }
        public string GLName { get; set; }
        public int? GLNumber { get; set; }
        public decimal? Percentage { get; set; }
        public string OfficeId { get; set; }

        //public ParamUpFrontSellGLModel()
        //{
        //    TrxType = "";
        //    ProdId = 0;
        //    Sequence = 1;
        //    GLName = "";
        //    GLNumber = 0;
        //    Percentage = 0;
        //    OfficeId = "";
        //}
    }

}
