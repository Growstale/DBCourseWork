using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
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
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace CourseWork
{
    public partial class MainWindow : Window
    {
        OracleConnection connection;
        string connectionString = "DATA SOURCE=localhost:1521/orcl.mshome.net;TNS_ADMIN=C:\\Users\\oracledatabase\\Oracle\\network\\admin;PERSIST SECURITY INFO=True;USER ID=Programmer_1;PASSWORD=Qwerty99880";

        public MainWindow()
        {
            InitializeComponent();
        }
        private void OpenRegistrationUser(object sender, RoutedEventArgs e)
        {
            UserRegistration newWindow = new UserRegistration();
            newWindow.Show();
            this.Close();
        }
        private void CallAuthoricationUserProcedure(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "Authorization";

                        command.Parameters.Add("Login_in", OracleDbType.NVarchar2).Value = LoginForAuthorization_TextBox.Text;
                        command.Parameters.Add("Password_in", OracleDbType.NVarchar2).Value = PasswordForAuthorization_TextBox.Text;
                        command.Parameters.Add("Role_in", OracleDbType.Int32).Value = AuthorizationSelectionCombobox.SelectedIndex;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;
                        command.Parameters.Add("Success_out", OracleDbType.Boolean, ParameterDirection.Output);

                        command.ExecuteNonQuery();

                        OracleBoolean oracleBoolean = (OracleBoolean)command.Parameters["Success_out"].Value;
                        string message = command.Parameters["Message_out"].Value.ToString();
                        bool success = oracleBoolean.IsTrue;
                        if (success)
                        {
                            if (AuthorizationSelectionCombobox.SelectedIndex == 0)
                            {
                                MainCatalog newwindow = new MainCatalog(LoginForAuthorization_TextBox.Text, PasswordForAuthorization_TextBox.Text, AuthorizationSelectionCombobox.SelectedIndex);
                                newwindow.Show();
                                this.Close();
                            }
                            if (AuthorizationSelectionCombobox.SelectedIndex == 1)
                            {
                                MainCatalog newwindow = new MainCatalog(LoginForAuthorization_TextBox.Text, PasswordForAuthorization_TextBox.Text, AuthorizationSelectionCombobox.SelectedIndex);
                                newwindow.Show();
                                this.Close();
                            }
                            if (AuthorizationSelectionCombobox.SelectedIndex == 2)
                            {
                                MainCatalog newwindow = new MainCatalog(LoginForAuthorization_TextBox.Text, PasswordForAuthorization_TextBox.Text, AuthorizationSelectionCombobox.SelectedIndex);
                                newwindow.Show();
                                this.Close();
                            }
                        }
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                }
            }
            catch (OracleException ex)
            {
                if (ex.Number == 1017)
                {
                    MessageBox.Show("Login or password is entered incorrectly");
                }
            }
        }
        private void Window_Cloding(object sender, System.ComponentModel.CancelEventArgs e)
        {
            connection.Close();
        }
        private void GuestLogIn(object sender, RoutedEventArgs e)
        {
            MainCatalog newwindow = new MainCatalog("Quest", "123", 3);
            newwindow.Show();
            this.Close();
        }
    }
}
