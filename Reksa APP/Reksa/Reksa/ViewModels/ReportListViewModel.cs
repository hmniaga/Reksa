using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;

namespace Reksa.ViewModels
{
    public class ReportListViewModel
    {
        public List<FileModel.NFSFileListType> NFSFileListType { get; set; }
        public ProductModel ProductModel { get; set; }
        public OfficeModel OfficeModel { get; set; }
        public SearchCustody CustodyModel { get; set; }
        public SearchManInv ManInvestasiModel { get; set; }
    }
}
