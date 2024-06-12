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
    public partial class ProdPage : Window
    {
        OracleConnection connection;
        string connectionString;
        private string login;
        private string password;
        private int eventid;
        private int role;
        public ProdPage(string login, string password, int eventid, int role)
        {
            InitializeComponent();
            connectionString = $"DATA SOURCE=localhost:1521/orcl.mshome.net;TNS_ADMIN=C:\\Users\\oracledatabase\\Oracle\\network\\admin;PERSIST SECURITY INFO=True;USER ID=C##{login};PASSWORD={password}";
            this.login = login;
            this.password = password;
            this.eventid = eventid;
            ProcedureShowEventByEventSchedule();
            ProcedureShowFullScheduleOfEvent();
            ProcedureShowComments();
            this.role = role;
        }
        private void ProcedureShowEventByEventSchedule()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_ShowEventByEventScheduleID";

                        command.Parameters.Add("EventScheduleID_in", OracleDbType.Int32).Value = eventid;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;
                        command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        EventDataGrid.ItemsSource = dataTable.DefaultView;
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
                MessageBox.Show(ex.Message);
            }

        }
        private void ProcedureShowFullScheduleOfEvent()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_ShowFullScheduleOfEventByEventScheduleID";

                        command.Parameters.Add("EventScheduleID_in", OracleDbType.Int32).Value = eventid;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;
                        command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        EventScheduleDataGrid.ItemsSource = dataTable.DefaultView;
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
        private void ProcedureShowComments()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_ShowComments";

                        command.Parameters.Add("EventScheduleID_in", OracleDbType.Int32).Value = eventid;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;
                        command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        CommentsDataGrid.ItemsSource = dataTable.DefaultView;
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
                MessageBox.Show(ex.Message);
            }
        }
        private void ProcedureCreateComment(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_CreateComment";
                        bool boolresultparse = true;
                        int? resultparse = null;
                        if (!string.IsNullOrEmpty(RatingForCreation_TextBox.Text))
                        {
                            boolresultparse = Int32.TryParse(RatingForCreation_TextBox.Text, out int tempResultparse);
                            if (boolresultparse)
                            {
                                resultparse = tempResultparse;
                            }
                        }
                        else
                        {
                            throw new Exception("Assessment is incorrect");
                        }
                        command.Parameters.Add("Login_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("EventScheduleID_in", OracleDbType.Int32).Value = eventid;
                        command.Parameters.Add("CommentText_in", OracleDbType.NVarchar2).Value = TextOfCommentForCreation_TextBox.Text;
                        command.Parameters.Add("FivePoint_in", OracleDbType.NVarchar2).Value = resultparse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    ProcedureShowComments();
                }
            }
            catch (OracleException ex)
            {
                if (ex.Number == 6550)
                {
                    MessageBox.Show("You don't have enough privileges to perform this action");
                }
                else
                {
                    MessageBox.Show(ex.Message);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }
        }
        private void Exit(object sender, RoutedEventArgs e)
        {
            MainCatalog newwindow = new MainCatalog(login, password, role);
            newwindow.Show();
            this.Close();
        }

    }
}
