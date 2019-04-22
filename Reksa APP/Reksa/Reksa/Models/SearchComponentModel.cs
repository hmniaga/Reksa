namespace Reksa.Models
{
    public class SearchComponentModel
    {
        private string _title;
        private int _width;
        private int _height;
        private bool _enabled;
        private bool _displayText2;

        public SearchComponentModel()
        {
            _width = 750;
            _height = 500;
            _title = "Search";
            _enabled = true;
            _displayText2 = true;
        }

        public string Name { get; set; }
        public string Value { get; set; }
        public string Value2 { get; set; }
        public string Title
        {
            get { return _title; }
            set { _title = value; }
        }
        public int Width
        {
            get { return _width; }
            set { _width = value; }
        }
        public int Height
        {
            get { return _height; }
            set { _height = value; }
        }
        public string ContentController { get; set; }
        public string ContentAction { get; set; }
        public object ContentRouteValues { get; set; }
        public bool Enabled
        {
            get { return _enabled; }
            set { _enabled = value; }
        }
        public bool DisplayText2
        {
            get { return _displayText2; }
            set { _displayText2 = value; }
        }

    }
    public class SearchTypeReksa
    {
        public string TypeCode { get; set; }
        public string TypeName { get; set; }
        public int TypeId { get; set; }
    }
    public class SearchManInv
    {
        public string ManInvCode { get; set; }
        public string ManInvName { get; set; }
        public int ManInvId { get; set; }
    }
    public class SearchCustody
    {
        public string CustodyCode { get; set; }
        public string CustodyName { get; set; }
        public int CustodyId { get; set; }
    }
    public class MIAccount
    {
        public string MIAccountId { get; set; }
        public string MIAccountName { get; set; }
    }
    public class CTDAccount
    {
        public string CTDAccountId { get; set; }
        public string CTDAccountName { get; set; }
    }
    public class CalcDevident
    {
        public string CalcCode { get; set; }
        public string CalcName { get; set; }
        public string CalcId { get; set; }
    }
}
