using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace CourseWork
{
    public partial class UserRegistration : Window
    {
        OracleConnection connection;
        string connectionString = "DATA SOURCE=localhost:1521/orcl.mshome.net;TNS_ADMIN=C:\\Users\\oracledatabase\\Oracle\\network\\admin;PERSIST SECURITY INFO=True;USER ID=Programmer_1;PASSWORD=Qwerty99880";
        public UserRegistration()
        {
            InitializeComponent();
        }

        private void OpenAuthorizationUser(object sender, RoutedEventArgs e)
        {
            MainWindow newWindow = new MainWindow();
            newWindow.Show();
            this.Close();
        }

        private void OpenRegistrationOrganizer(object sender, RoutedEventArgs e)
        {
            OrganizerRegistration newWindow = new OrganizerRegistration();
            newWindow.Show();
            this.Close();
        }

        private void OpenRegistrationManager(object sender, RoutedEventArgs e)
        {
            ManagerRegistration newWindow = new ManagerRegistration();
            newWindow.Show();
            this.Close();
        }

        private void CallRegisterUserProcedure(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "UserRegistration";

                        command.Parameters.Add("Login_in", OracleDbType.NVarchar2).Value = LoginForRegistration_TextBox.Text;
                        command.Parameters.Add("Password_in", OracleDbType.NVarchar2).Value = PasswordForRegistration_TextBox.Text;
                        command.Parameters.Add("FirstName_in", OracleDbType.NVarchar2).Value = FirstNameForRegistration_TextBox.Text;
                        command.Parameters.Add("LastName_in", OracleDbType.NVarchar2).Value = LastNameForRegistration_TextBox.Text;
                        command.Parameters.Add("Email_in", OracleDbType.NVarchar2).Value = EmailForRegistration_TextBox.Text;
                        command.Parameters.Add("Phone_in", OracleDbType.NVarchar2).Value = PhoneForRegistration_TextBox.Text;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"{ex.Message}");
            }
        }
    }
}