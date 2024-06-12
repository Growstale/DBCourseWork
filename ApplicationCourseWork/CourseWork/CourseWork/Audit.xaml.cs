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
    /// <summary>
    /// Логика взаимодействия для Audit.xaml
    /// </summary>
    public partial class Audit : Window
    {
        OracleConnection connection;
        private string connectionString;
        private string login;
        private string password;
        private int role;

        public Audit(string login, string password, int role)
        {
            InitializeComponent();
            this.login = login;
            this.password = password;
            this.role = role;
            connectionString = $"DATA SOURCE=localhost:1521/orcl.mshome.net;TNS_ADMIN=C:\\Users\\oracledatabase\\Oracle\\network\\admin;PERSIST SECURITY INFO=True;USER ID=C##{login};PASSWORD={password}";
            RefreshFailedLoginAttemption();
            RefreshRefundsOfTickets();
            RefreshLoggingInAfterHours();
            RefreshDeletingEvents();
        }
        private void Exit(object sender, RoutedEventArgs e)
        {
            ModeratorPersonalAccount mainWindow = new ModeratorPersonalAccount(login, password, role);
            mainWindow.Show();
            this.Close();
        }

        private void RefreshFailedLoginAttemption()
        {
            using (connection = new OracleConnection(connectionString))
            {
                using (OracleCommand command = connection.CreateCommand())
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_FailerLoginAttempts";
                    command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                    OracleDataAdapter adapter = new OracleDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    FailedLoginDataGrid.ItemsSource = dataTable.DefaultView;
                    connection.Close();
                }
            }

        }
        private void RefreshRefundsOfTickets() 
        {
            using (connection = new OracleConnection(connectionString))
            {
                using (OracleCommand command = connection.CreateCommand())
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_AuditTicketRefund";
                    command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                    OracleDataAdapter adapter = new OracleDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    TicketRefundsDataGrid.ItemsSource = dataTable.DefaultView;
                    connection.Close();
                }
            }

        }
        private void RefreshLoggingInAfterHours()
        {
            using (connection = new OracleConnection(connectionString))
            {
                using (OracleCommand command = connection.CreateCommand())
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_CreateEventAfterHours";
                    command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                    OracleDataAdapter adapter = new OracleDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    LogginAfterHoursDataGrid.ItemsSource = dataTable.DefaultView;
                    connection.Close();
                }
            }

        }

        private void RefreshDeletingEvents()
        {
            using (connection = new OracleConnection(connectionString))
            {
                using (OracleCommand command = connection.CreateCommand())
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_AuditEventDelete";
                    command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                    OracleDataAdapter adapter = new OracleDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    DeletingEventsDataGrid.ItemsSource = dataTable.DefaultView;
                    connection.Close();
                }
            }
        }
    }
}
