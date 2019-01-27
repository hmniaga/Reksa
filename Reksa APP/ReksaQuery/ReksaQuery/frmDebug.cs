using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ReksaQuery
{
    public partial class frmDebug : Form
    {
        public frmDebug()
        {
            InitializeComponent();
        }

        public event EventHandler onFormClose;

        public void AddText(string strText)
        {
            txtDebug.AppendText(strText + "\r\n");
        }

        private void tmrDebug_Tick(object sender, EventArgs e)
        {
            if (ClsQuery.queDebug.Count > 0)
            {
                string[] str = ClsQuery.queDebug.Dequeue();
                for (int i = 1; i < str.Length; i++)
                    txtDebug.AppendText(str[i] + "\r\n");
            }
        }

        private void BtnOk_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void frmDebug_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (onFormClose != null)
                onFormClose(sender, e);
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            txtDebug.Clear();
        }

    }
}
