using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;

namespace Reksa.ViewModels
{
    public class ParameterListViewModel
    {
        public List<ParameterModel> Parameter { get; set; }
        public ProductModel ProductModel { get; set; }
        public List<ActivityModel> CustomerActivity { get; set; }
    }

    public class ParameterSubscriptionFeeListViewModel
    {
        public ProductModel ProductModel { get; set; }
        public ReksaParamFeeSubs ReksaParamFeeSubs { get; set; }
        public List<ReksaTieringNotificationSubs> ReksaTieringNotificationSubs { get; set; }
        public List<ReksaListGLFeeSubs> ReksaListGLFeeSubs { get; set; }
    }
    //Nico
    public class ParameterMFeeListViewModel
    {
        public ProductModel ProductModel { get; set; }
        public ParamMFeeModel ParamMFee { get; set; }
        public List<ProductMFeeModel> ProductMFee { get; set; }
        public List<ListGLMFeeModel> ListGLMFee { get; set; }
        
    }
    //Nico end
}
