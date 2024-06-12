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
using System.Windows.Shapes;

namespace CourseWork
{
    public partial class OrganizerPersonalAccount : Window
    {
        OracleConnection connection;
        string connectionString;
        string login;
        private int role;
        private string password;
        public OrganizerPersonalAccount(string login, string password, int role)
        {
            InitializeComponent();
            connectionString = $"DATA SOURCE=localhost:1521/orcl.mshome.net;TNS_ADMIN=C:\\Users\\oracledatabase\\Oracle\\network\\admin;PERSIST SECURITY INFO=True;USER ID=C##{login};PASSWORD={password}";
            this.login = login;
            RefreshOrganizerEventsDataGrid();
            RefreshOrganizerQuestionsDataGrid();
            RefreshEventsScheduleDataGrid();
            this.role = role;
            this.password = password;
        }
        private void RefreshOrganizerEventsDataGrid()
        {
            using (connection = new OracleConnection(connectionString))
            {
                connection.Open();

                using (OracleCommand command = connection.CreateCommand())
                {

                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_ShowOrganizerEvent";

                    command.Parameters.Add("CompanyName_in", OracleDbType.NVarchar2).Value = login;
                    command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;
                    command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                    
                    OracleDataAdapter adapter = new OracleDataAdapter(command);

                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    OrganizerEventsDataGrid.ItemsSource = dataTable.DefaultView;

                    string message = command.Parameters["Message_out"].Value.ToString();
                    if (!string.IsNullOrEmpty(message) && message != "null")
                    {
                        MessageBox.Show(message);
                    }
                    connection.Close();
                }
            }
        }
        private void RefreshOrganizerQuestionsDataGrid()
        {
            using (connection = new OracleConnection(connectionString))
            {
                connection.Open();

                using (OracleCommand command = connection.CreateCommand())
                {

                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_ShowOrganizerQuestion";

                    command.Parameters.Add("CompanyName_in", OracleDbType.NVarchar2).Value = login;
                    command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;
                    command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);

                    OracleDataAdapter adapter = new OracleDataAdapter(command);

                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    OrganizerQuestionsDataGrid.ItemsSource = dataTable.DefaultView;

                    string message = command.Parameters["Message_out"].Value.ToString();
                    if (!string.IsNullOrEmpty(message) && message != "null")
                    {
                        MessageBox.Show(message);
                    }
                    connection.Close();
                }
            }
        }

        private void ProcedureCreateEvent(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_CreateEvent";

                        bool boolresultparse = Int32.TryParse(LocationIDForCreation_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("Location ID isn't correct");
                        }
                        bool boolresult1parse = Int32.TryParse(SubCategoryIDForCreation_TextBox.Text, out int result1parse);
                        if (!boolresult1parse)
                        {
                            throw new Exception("SubCategory ID isn't correct");
                        }
                        bool boolresult2parse = Int32.TryParse(CostForCreation_TextBox.Text, out int result2parse);
                        if (!boolresult2parse)
                        {
                            throw new Exception("Cost isn't correct");
                        }

                        command.Parameters.Add("EventName_in", OracleDbType.NVarchar2).Value = EventNameForCreation_TextBox.Text;
                        command.Parameters.Add("Number_LocationID", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("EventDuration_in", OracleDbType.NVarchar2).Value = EventDurationForCreation_TextBox.Text;
                        command.Parameters.Add("SubcategoryID_in", OracleDbType.Int32).Value = result1parse;
                        command.Parameters.Add("OrganizerCompany_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("Description_in", OracleDbType.NVarchar2).Value = DescriptionCreation_TextBox.Text;
                        command.Parameters.Add("Number_Cost", OracleDbType.Int32).Value = result2parse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshOrganizerEventsDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }
        }
        private void ProcedureUpdateEvent(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {
                        bool boolresultparse = Int32.TryParse(EventIDForUpdateDelete_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("Event ID isn't correct");
                        }
                        bool boolresult1parse = Int32.TryParse(SubCategoryIDForUpdate_TextBox.Text, out int result1parse);
                        if (!boolresult1parse)
                        {
                            throw new Exception("SubCategory ID isn't correct");
                        }
                        bool boolresult2parse = Int32.TryParse(CostForUpdate_TextBox.Text, out int result2parse);
                        if (!boolresult2parse)
                        {
                            throw new Exception("Cost isn't correct");
                        }

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_UpdateEvent";

                        command.Parameters.Add("Number_EventID", OracleDbType.NVarchar2).Value = resultparse;
                        command.Parameters.Add("EventName_in", OracleDbType.NVarchar2).Value = EventNameForUpdate_TextBox.Text;
                        command.Parameters.Add("EventDuration_in", OracleDbType.NVarchar2).Value = EventDurationForUpdate_TextBox.Text;
                        command.Parameters.Add("Number_SubcategoryID", OracleDbType.NVarchar2).Value = result1parse;
                        command.Parameters.Add("OrganizerCompany_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("Description_in", OracleDbType.NVarchar2).Value = DescriptionForUpdate_TextBox.Text;
                        command.Parameters.Add("Number_Cost", OracleDbType.NVarchar2).Value = result2parse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshOrganizerEventsDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }
        }
        private void ProcedureDeleteEvent(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_DeleteEvent";
                        bool boolresultparse = Int32.TryParse(EventIDForUpdateDelete_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("Event ID isn't correct");
                        }
                        command.Parameters.Add("Number_EventID", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("OrganizerCompany_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshOrganizerEventsDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }
        }
        private void ProcedureCreateOrganizerQuestion(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_CreateOrganizerQuestion";

                        command.Parameters.Add("OrganizerCompany_in", OracleDbType.NVarchar2).Value = login;
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
                    RefreshOrganizerQuestionsDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }
        }
        private void ProcedureCreateEventSchedule(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {
                        string dateformat = "yyyy-MM-dd HH:mm";
                        bool boolresult1parse = true;
                        bool boolresult2parse = true;
                        DateTime? result1parse = null;
                        int? result2parse = null;

                        if (!string.IsNullOrEmpty(EventDateForCreationSchedule_TextBox.Text))
                        {
                            boolresult1parse = DateTime.TryParseExact(EventDateForCreationSchedule_TextBox.Text, dateformat, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out DateTime tempResult1parse);
                            if (boolresult1parse)
                            {
                                result1parse = tempResult1parse;
                            }
                            else
                            {
                                throw new Exception($"Date format: {dateformat}");
                            }
                        }
                        if (!string.IsNullOrEmpty(EventIDForCreationSchedule_TextBox.Text))
                        {
                            boolresult2parse = Int32.TryParse(EventIDForCreationSchedule_TextBox.Text, out int tempResult2parse);
                            if (boolresult2parse)
                            {
                                result2parse = tempResult2parse;
                            }
                            else
                            {
                                throw new Exception("Event ID is incorrect");
                            }
                        }
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_CreateEventSchedule";

                        command.Parameters.Add("EventID_in", OracleDbType.Int32).Value = result2parse;
                        command.Parameters.Add("EventDate_in", OracleDbType.TimeStamp).Value = result1parse;
                        command.Parameters.Add("OrganizerCompany_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 500;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        { 
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshEventsScheduleDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }

        }
        private void RefreshEventsScheduleDataGrid()
        {
            using (connection = new OracleConnection(connectionString))
            {
                using (OracleCommand command = connection.CreateCommand())
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_ShowEventsSchedule";
                    command.Parameters.Add("CompanyName_in", OracleDbType.NVarchar2).Value = login;
                    command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                    command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;
                    OracleDataAdapter adapter = new OracleDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    OrganizerEventsScheduleDataGrid.ItemsSource = dataTable.DefaultView;
                    string message = command.Parameters["Message_out"].Value.ToString();
                    if (!string.IsNullOrEmpty(message) && message != "null")
                    {
                        MessageBox.Show(message);
                    }
                    connection.Close();
                }
            }
        }
        private void ProcedureUpdateEventSchedule(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {
                        string dateformat = "yyyy-MM-dd HH:mm";
                        bool boolresult1parse = true;
                        bool boolresult2parse = true;
                        DateTime? result1parse = null;
                        int? result2parse = null;

                        if (!string.IsNullOrEmpty(EventDateForUpdateSchedule_TextBox.Text))
                        {
                            boolresult1parse = DateTime.TryParseExact(EventDateForUpdateSchedule_TextBox.Text, dateformat, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out DateTime tempResult1parse);
                            if (boolresult1parse)
                            {
                                result1parse = tempResult1parse;
                            }
                            else
                            {
                                throw new Exception($"Date format: {dateformat} . {EventDateForUpdateSchedule_TextBox.Text} ");
                            }
                        }
                        else
                        {
                            throw new Exception($"Date format: {dateformat}. {EventDateForUpdateSchedule_TextBox.Text}");
                        }
                        if (!string.IsNullOrEmpty(EventScheduleIDForUpdateDeleteSchedule_TextBox.Text))
                        {
                            boolresult2parse = Int32.TryParse(EventScheduleIDForUpdateDeleteSchedule_TextBox.Text, out int tempResult2parse);
                            if (boolresult2parse)
                            {
                                result2parse = tempResult2parse;
                            }
                        }
                        else
                        {
                            throw new Exception("EventScheduleID is incorrect");
                        }
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_UpdateEventSchedule";
                        command.Parameters.Add("EventScheduleID_in", OracleDbType.Int32).Value = result2parse;
                        command.Parameters.Add("EventDate_in", OracleDbType.TimeStamp).Value = result1parse;
                        command.Parameters.Add("OrganizerCompany_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 500;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshEventsScheduleDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }

        }
        private void ProcedureDeleteEventSchedule(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {
                        bool boolresult2parse = true;
                        int? result2parse = null;

                        if (!string.IsNullOrEmpty(EventScheduleIDForUpdateDeleteSchedule_TextBox.Text))
                        {
                            boolresult2parse = Int32.TryParse(EventScheduleIDForUpdateDeleteSchedule_TextBox.Text, out int tempResult2parse);
                            if (boolresult2parse)
                            {
                                result2parse = tempResult2parse;
                            }
                        }
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_DeleteEventSchedule";

                        command.Parameters.Add("EventScheduleID_in", OracleDbType.Int32).Value = result2parse;
                        command.Parameters.Add("OrganizerCompany_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshEventsScheduleDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }

        }
        private void Exit(object sender, RoutedEventArgs e)
        {
            MainCatalog mainWindow = new MainCatalog(login, password, role);
            mainWindow.Show();
            this.Close();
        }
    }
}
