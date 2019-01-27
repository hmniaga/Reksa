using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace ReksaQuery
{
    public partial class FrmMessage : Form
    {
        public FrmMessage()
        {
            InitializeComponent();
        }

        public void ShowMessage(object[] obj)
        {
            dgMessage.Columns.Add("ErrorId", "Error");
            dgMessage.Columns.Add("Message", "Message");
            dgMessage.Rows.Add(obj);
            dgMessage.Columns[1].DefaultCellStyle.WrapMode = DataGridViewTriState.True;
            dgMessage.Columns[1].Width = dgMessage.Width - (dgMessage.Columns[0].Width + 40);
            dgMessage.AutoSizeRowsMode = DataGridViewAutoSizeRowsMode.AllCells;
            dgMessage.Columns[0].AutoSizeMode = DataGridViewAutoSizeColumnMode.DisplayedCells;
        }

        private void btnOk_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.OK;
        }

        private void dgMessage_Resize(object sender, EventArgs e)
        {
            try
            {
                dgMessage.Columns[1].Width = dgMessage.Width - (dgMessage.Columns[0].Width + 70);
            }
            catch (Exception)
            {
            }
        }

    }
}
