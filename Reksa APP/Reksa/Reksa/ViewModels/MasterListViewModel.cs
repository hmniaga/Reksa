using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;


namespace Reksa.ViewModels
{
    public class MasterListViewModel
    {
        public ProductModel ProductModel { get; set; }
        public CustomerModel CustomerModel { get; set; }
        public SearchTypeReksa TypeReksaModel { get; set; }
        public SearchManInv ManInvestasiModel { get; set; }
        public SearchCustody CustodyModel { get; set; }
        public CurrencyModel CurrencyModel { get; set; }
        public MIAccount MIAccountModel { get; set; }
        public CTDAccount CTDAccountModel { get; set; }
        public CalcDevident CalcDevidentModel { get; set; }
    }
}
