using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class TreeViewModel
    {
        public int SequenceNumber { get; set; }
        public string InterfaceTypeId { get; set; }
        public string Caption{ get; set; }
        public string UserControlName { get; set; }
        public string ParentId { get; set; }
        public string InterfaceCode { get; set; }
    }
    public class CommonTreeViewModel
    {
        public int common_id { get; set; }
        public string module { get; set; }
        public string menu { get; set; }
        public string tree_id { get; set; }
        public string tree_name { get; set; }
        public string parent_tree { get; set; }
        public bool end_level_bit { get; set; }
        public string populate_query { get; set; }
        public string detail_query { get; set; }
        public string button1_query { get; set; }
        public string button2_query { get; set; }
        public string button3_query { get; set; }
        public int button1 { get; set; }
        public int button2 { get; set; }
        public int button3 { get; set; }
        public string button1_hint { get; set; }
        public string button2_hint { get; set; }
        public string button3_hint { get; set; }
        public string button1_image_key { get; set; }
        public string button2_image_key { get; set; }
        public string button3_image_key { get; set; }
        public string column_mask { get; set; }
        public string column_hidden { get; set; }
        public int order_number { get; set; }
        public string form_name { get; set; }
    }
}
