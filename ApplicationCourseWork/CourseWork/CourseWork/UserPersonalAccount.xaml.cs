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
    public partial class UserPersonalAccount : Window
    {
        private OracleConnection connection;
        private string connectionString;
        private string login;
        private string password;
        private int role;

        public UserPersonalAccount(string login, string password, int role)
        {
            InitializeComponent();
            connectionString = $"DATA SOURCE=localhost:1521/orcl.mshome.net;TNS_ADMIN=C:\\Users\\oracledatabase\\Oracle\\network\\admin;PERSIST SECURITY INFO=True;USER ID=C##{login};PASSWORD={password}";
            this.login = login;
            this.password = password;
            ShowShoppingCartProcedure();
            ShowPurchaseHistoryProcedure();
            RefreshUserQuestionsDataGrid();
            this.role = role;
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            MainCatalog newwindow = new MainCatalog(login, password, role);
            newwindow.Show();
            this.Close();
        }
        private void ShowShoppingCartProcedure()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_ShowShoppingCart";
                        command.Parameters.Add("Login_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);

                        OracleDataAdapter adapter = new OracleDataAdapter(command);

                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        ShoppingCartDataGrid.ItemsSource = dataTable.DefaultView;
                        ProcedureShoppingCartInfo();
                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void DeleteFromShoppingCartProcedure(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_DeleteTicketFromShoppingCart";

                        command.Parameters.Add("Login_in", OracleDbType.NVarchar2).Value = login;

                        bool boolresultparse = Int32.TryParse(TicketIDForDelete_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("Ticket ID isn't correct");
                        }

                        command.Parameters.Add("TicketID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                        ShowShoppingCartProcedure();
                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void ClearShoppingCartProcedure(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_ClearShoppingCart";

                        command.Parameters.Add("Login_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                        ShowShoppingCartProcedure();
                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void ProcedureBuyTicket(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_BuyTicket";

                        command.Parameters.Add("Login_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                        ShowShoppingCartProcedure();
                        ShowPurchaseHistoryProcedure();
                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void ShowPurchaseHistoryProcedure()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_GetPurchaseHistory";

                        command.Parameters.Add("Login_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;
                        OracleDataAdapter adapter = new OracleDataAdapter(command);

                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        PurchaseHistoryDataGrid.ItemsSource = dataTable.DefaultView;
                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message + ex.StackTrace);
            }
        }
        private void ProcedureAskForRefund(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_AskForRefund";
                        bool boolresultparse = Int32.TryParse(SaleIDForRefund.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("Sale ID isn't correct");
                        }
                        command.Parameters.Add("Login_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("SaleID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("Message_in", OracleDbType.NVarchar2).Value = MessageTextForRefund.Text;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                        ShowShoppingCartProcedure();
                        ShowPurchaseHistoryProcedure();
                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void ProcedureCreateUserQuestion(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_CreateUserQuestion";

                        command.Parameters.Add("UserLogin_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("QuestionText_in", OracleDbType.NVarchar2).Value = QuestionCreation_TextBox.Text;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshUserQuestionsDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }
        }
        private void ProcedureShoppingCartInfo()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_GetShoppingCartInfo";
                        command.Parameters.Add("UserLogin_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("ticket_count", OracleDbType.Int32, ParameterDirection.Output);
                        command.Parameters.Add("total_price", OracleDbType.Int32, ParameterDirection.Output);
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();
                        string message = command.Parameters["Message_out"].Value.ToString();
                        numberoftickets.Text = command.Parameters["ticket_count"].Value.ToString();
                        finalcost.Text = command.Parameters["total_price"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshUserQuestionsDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }
        }

        private void RefreshUserQuestionsDataGrid()
        {
            using (connection = new OracleConnection(connectionString))
            {
                connection.Open();

                using (OracleCommand command = connection.CreateCommand())
                {

                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_ShowUserQuestion";

                    command.Parameters.Add("Login_in", OracleDbType.NVarchar2).Value = login;
                    command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;
                    command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);

                    OracleDataAdapter adapter = new OracleDataAdapter(command);

                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    UserQuestionsDataGrid.ItemsSource = dataTable.DefaultView;

                    string message = command.Parameters["Message_out"].Value.ToString();
                    if (!string.IsNullOrEmpty(message) && message != "null")
                    {
                        MessageBox.Show(message);
                    }
                    connection.Close();
                }
            }
        }

        private void UserQuestionsDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }
    }
}