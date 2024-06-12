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
    public partial class ModeratorPersonalAccount : Window
    {
        OracleConnection connection;
        private string connectionString;
        private string login;
        private string password;
        private int role;

        public ModeratorPersonalAccount(string login, string password, int role)
        {
            InitializeComponent();
            this.login = login;
            this.password = password;
            connectionString = $"DATA SOURCE=localhost:1521/orcl.mshome.net;TNS_ADMIN=C:\\Users\\oracledatabase\\Oracle\\network\\admin;PERSIST SECURITY INFO=True;USER ID=C##{login};PASSWORD={password}";
            RefreshLocationDataGrid();
            RefreshCategoryDataGrid();
            RefreshSubategoryDataGrid();
            RefreshRowsDataGrid();
            RefreshOrganizersDataGrid();
            RefreshUserBlockDataGrid();
            RefreshOrganizerBlockDataGrid();
            RefreshRefundDataGrid();
            RefreshCommentsDataGrid();
            RefreshOrganizerQuestionsDataGrid();
            RefreshUserQuestionsDataGrid();
            RefreshOrganizerEventsDataGrid();
            RefreshEventsScheduleDataGrid();
            this.role = role;
        }
        private void ProcedureAddLocation(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_AddLocation";
                        bool boolresultparse = Int32.TryParse(SectorCountForCreation_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("Number Of Sectors isn't correct");
                        }

                        command.Parameters.Add("LocationName_in", OracleDbType.NVarchar2).Value = LocationNameForCreation_TextBox.Text;
                        command.Parameters.Add("NumberOfSectors_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                        RefreshLocationDataGrid();
                        RefreshRowsDataGrid();
                    }
                    connection.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }

        }

        private void ProcedureAddCategory(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_AddCategory";

                        command.Parameters.Add("CategoryName_in", OracleDbType.NVarchar2).Value = CategoryNameForCreation_TextBox.Text;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                        RefreshCategoryDataGrid();
                    }
                    connection.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureAddSubcategory(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_AddSubcategory";

                        string selectedCategory = CategoryListForSubcatogoryCombobox.SelectedItem != null ? CategoryListForSubcatogoryCombobox.SelectedItem.ToString() : "";

                        command.Parameters.Add("CategoryName_in", OracleDbType.NVarchar2).Value = selectedCategory;
                        command.Parameters.Add("SubcategoryName_in", OracleDbType.NVarchar2).Value = SubcategoryNameForCreation_TextBox.Text;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                        RefreshSubategoryDataGrid();
                    }
                    connection.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureAddRow(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_AddRow";

                        bool boolresult1parse = Int32.TryParse(CostFactorCreate_TextBox.Text, out int result1parse);
                        bool boolresult2parse = Int32.TryParse(NumberOfSeatsCreate_TextBox.Text, out int result2parse);

                        if (!boolresult1parse)
                        {
                            throw new Exception("Cost Factor isn't correct");
                        }
                        if (!boolresult2parse)
                        {
                            throw new Exception("Number Of Seats isn't correct");
                        }

                        string selectedCategory = LocationListForRowsCombobox.SelectedItem != null ? LocationListForRowsCombobox.SelectedItem.ToString() : "";
                        command.Parameters.Add("LocationName_in", OracleDbType.NVarchar2).Value = selectedCategory;
                        command.Parameters.Add("CostFactor_in", OracleDbType.Int32).Value = result1parse;
                        command.Parameters.Add("NumberOfSeats_in", OracleDbType.Int32).Value = result2parse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshRowsDataGrid();
                    RefreshLocationDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }

        }
        private void ProcedureUpdateLocation(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_UpdateLocation";

                        bool boolresult1parse = Int32.TryParse(SectorCountForUpdate_TextBox.Text, out int result1parse);
                        bool boolresult2parse = Int32.TryParse(LocationIDForUpdateDelete_TextBox.Text, out int result2parse);

                        if (!boolresult1parse)
                        {
                            throw new Exception("Number Of Sectors isn't correct");
                        }
                        if (!boolresult2parse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("LocationID_in", OracleDbType.Int32).Value = result2parse;
                        command.Parameters.Add("NumberOfSectors_in", OracleDbType.Int32).Value = result1parse;
                        command.Parameters.Add("LocationName_in", OracleDbType.NVarchar2).Value = LocationNameForUpdate_TextBox.Text;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshLocationDataGrid();
                    RefreshRowsDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureDeleteLocation(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_DeleteLocation";

                        bool boolresultparse = Int32.TryParse(LocationIDForUpdateDelete_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("LocationID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshLocationDataGrid();
                    RefreshRowsDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureUpdateCategory(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_UpdateCategory";

                        bool boolresultparse = Int32.TryParse(CategoryIDForUpdateDelete_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("CategoryID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("CategoryName_in", OracleDbType.NVarchar2).Value = CategoryNameForUpdate_TextBox.Text;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshCategoryDataGrid();
                    RefreshSubategoryDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureDeleteCategory(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_DeleteCategory";

                        bool boolresultparse = Int32.TryParse(CategoryIDForUpdateDelete_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("CategoryID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshCategoryDataGrid();
                    RefreshSubategoryDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureUpdateSubcategory(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_UpdateSubcategory";

                        bool boolresult1parse = Int32.TryParse(SubcategoryIDForUpdateDelete_TextBox.Text, out int result1parse);
                        bool boolresult2parse = Int32.TryParse(CategoryIDForUpdate_TextBox.Text, out int result2parse);

                        if (!boolresult1parse && !boolresult2parse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("SubcategoryID_in", OracleDbType.Int32).Value = result1parse;
                        command.Parameters.Add("SubcategoryName_in", OracleDbType.NVarchar2).Value = SubcategoryNameForUpdate_TextBox.Text;
                        command.Parameters.Add("CategoryID_in", OracleDbType.Int32).Value = result2parse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshSubategoryDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureDeleteSubcategory(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_DeleteSubcategory";

                        bool boolresultparse = Int32.TryParse(SubcategoryIDForUpdateDelete_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("SubcategoryID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshSubategoryDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureAcceptOrganizer(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_AcceptOrganizer";

                        bool boolresultparse = Int32.TryParse(OrganizerIDForAccept_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("OrganizerID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshOrganizersDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }

        }
        private void ProcedureDenyOrganizer(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_DenyOrganizer";

                        bool boolresultparse = Int32.TryParse(OrganizerIDForAccept_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("OrganizerID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshOrganizersDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureBlockUser(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_BlockUser";


                        string dateformat = "yyyy-MM-dd HH:mm";
                        bool boolresult2parse = true;
                        DateTime result2parse = DateTime.Today;

                        if (!string.IsNullOrEmpty(EndDateForBlock_TextBox.Text))
                        {
                            boolresult2parse = DateTime.TryParseExact(EndDateForBlock_TextBox.Text, dateformat, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out DateTime tempResult1parse);
                            if (boolresult2parse)
                            {
                                result2parse = tempResult1parse;
                            }
                            else
                            {
                                throw new Exception($"Date format: {dateformat}");
                            }
                        }
                        else
                        {
                            throw new Exception($"Date format: {dateformat}");
                        }

                        bool boolresult1parse = Int32.TryParse(UserIDFromBlock_TextBox.Text, out int result1parse);

                        if (!boolresult1parse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("UserID_in", OracleDbType.Int32).Value = result1parse;
                        command.Parameters.Add("ManagerLogin_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("Reason_in", OracleDbType.NVarchar2).Value = ReasonForBlock_TextBox.Text;
                        command.Parameters.Add("EndDate_in", OracleDbType.TimeStamp).Value = new OracleTimeStamp(result2parse);

                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;
                        
                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshUserBlockDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureBlockOrganizer(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_BlockOrganizer";

                        string dateformat = "yyyy-MM-dd HH:mm";
                        bool boolresult2parse = true;
                        DateTime result2parse = DateTime.Today;

                        if (!string.IsNullOrEmpty(EndDateFororganizerBlock_TextBox.Text))
                        {
                            boolresult2parse = DateTime.TryParseExact(EndDateFororganizerBlock_TextBox.Text, dateformat, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out DateTime tempResult1parse);
                            if (boolresult2parse)
                            {
                                result2parse = tempResult1parse;
                            }
                            else
                            {
                                throw new Exception($"Date format: {dateformat}");
                            }
                        }
                        else
                        {
                            throw new Exception($"Date format: {dateformat}");
                        }


                        bool boolresult1parse = Int32.TryParse(OrganizerIDForBlock_TextBox.Text, out int result1parse);

                        if (!boolresult1parse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("OrganizerID_in", OracleDbType.Int32).Value = result1parse;
                        command.Parameters.Add("ManagerLogin_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("Reason_in", OracleDbType.NVarchar2).Value = ReasonForOrganizerBlock_TextBox.Text;
                        command.Parameters.Add("EndDate_in", OracleDbType.TimeStamp).Value = new OracleTimeStamp(result2parse);

                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshOrganizerBlockDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }

        }
        private void ProcedureDeleteComment(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_DeleteComment";

                        bool boolresult1parse = Int32.TryParse(CommentIDForDelete_TextBox.Text, out int result1parse);

                        if (!boolresult1parse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("CommentID_in", OracleDbType.Int32).Value = result1parse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshCommentsDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureUnlockUser(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_UnlockUser";

                        bool boolresultparse = Int32.TryParse(UserIDFromBlock_TextBox.Text, out int resultparse);

                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }
                        command.Parameters.Add("UserID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshUserBlockDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureUpdateRow(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {
                        bool boolresult1parse = Int32.TryParse(RowIDForUpdateDelete_TextBox.Text, out int result1parse);
                        bool boolresult2parse = Int32.TryParse(NumberOfSeatsUpdate_TextBox.Text, out int result2parse);
                        bool boolresult3parse = Int32.TryParse(CostFactorUpdate_TextBox.Text, out int result3parse);

                        if (!boolresult1parse)
                        {
                            throw new Exception("RowID isn't correct");
                        }
                        if (!boolresult2parse)
                        {
                            throw new Exception("NumberOfSeats isn't correct");
                        }
                        if (!boolresult2parse)
                        {
                            throw new Exception("CostFactor isn't correct");
                        }

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_UpdateRow";

                        command.Parameters.Add("SectorRowID_in", OracleDbType.Int32).Value = result1parse;
                        command.Parameters.Add("NumberOfSeats_in", OracleDbType.Int32).Value = result2parse;
                        command.Parameters.Add("CostFactor_in", OracleDbType.Int32).Value = result3parse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshRowsDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }
        }
        private void ProcedureDeleteRow(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_DeleteRow";

                        bool boolresultparse = Int32.TryParse(RowIDForUpdateDelete_TextBox.Text, out int resultparse);

                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }
                        command.Parameters.Add("SectorRowID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                    }
                    connection.Close();
                    RefreshRowsDataGrid();
                    RefreshLocationDataGrid();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }
        }
        private void RefreshLocationDataGrid()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_SelectFromLocations";
                        command.Parameters.Add("Cursor_out", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        LocationDataGrid.ItemsSource = dataTable.DefaultView;

                        foreach (DataRow row in dataTable.Rows)
                        {
                            string CategoryName = row["LocationName"].ToString();
                            if (!LocationListForRowsCombobox.Items.Contains(CategoryName))
                            {
                                LocationListForRowsCombobox.Items.Add(CategoryName);
                            }
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
        private void RefreshCategoryDataGrid()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_SelectFromCategories";
                        command.Parameters.Add("Cursor_out", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        CategoryDataGrid.ItemsSource = dataTable.DefaultView;

                        foreach (DataRow row in dataTable.Rows)
                        {
                            string CategoryName = row["CategoryName"].ToString();
                            if (!CategoryListForSubcatogoryCombobox.Items.Contains(CategoryName))
                            {
                                CategoryListForSubcatogoryCombobox.Items.Add(CategoryName);
                            }
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
        private void RefreshSubategoryDataGrid()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_SelectFromSubcategories";
                        command.Parameters.Add("Cursor_out", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        SubcategoryDataGrid.ItemsSource = dataTable.DefaultView;
                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void RefreshRowsDataGrid()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_SelectFromSectorRows";
                        command.Parameters.Add("Cursor_out", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        RowsDataGrid.ItemsSource = dataTable.DefaultView;
                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void RefreshOrganizersDataGrid()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_SelectFromCheckingOrganizers";
                        command.Parameters.Add("Cursor_out", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        OrganizersDataGrid.ItemsSource = dataTable.DefaultView;
                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void RefreshUserBlockDataGrid()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_ShowUserBlock";
                        command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        UserBlockDataGrid.ItemsSource = dataTable.DefaultView;

                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void RefreshOrganizerBlockDataGrid()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_ShowOrganizerBlock";
                        command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        OrganizerBlockDataGrid.ItemsSource = dataTable.DefaultView;

                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void RefreshCommentsDataGrid()
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_ShowAllComments";
                        command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        CommentsDataGrid.ItemsSource = dataTable.DefaultView;

                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void ProcedureAcceptRefund(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_AcceptRefend";

                        bool boolresultparse = Int32.TryParse(SaleIDForRefund_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("Sale ID isn't correct");
                        }

                        command.Parameters.Add("SaleID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                        RefreshRefundDataGrid();
                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void ProcedureDenyRefund(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_DenyRefend";

                        bool boolresultparse = Int32.TryParse(SaleIDForRefund_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("Sale ID isn't correct");
                        }

                        command.Parameters.Add("SaleID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                        RefreshRefundDataGrid();
                        connection.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void RefreshRefundDataGrid()
        {
            using (connection = new OracleConnection(connectionString))
            {
                connection.Open();

                using (OracleCommand command = connection.CreateCommand())
                {

                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_ShowRefund";
                    command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);

                    OracleDataAdapter adapter = new OracleDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    TicketRefundDataGrid.ItemsSource = dataTable.DefaultView;
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
                    command.CommandText = "TicketVibe_ShowOrganizerQuestionForManager";
                    command.Parameters.Add("Login_in", OracleDbType.NVarchar2).Value = login;
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
        private void RefreshUserQuestionsDataGrid()
        {
            using (connection = new OracleConnection(connectionString))
            {
                connection.Open();

                using (OracleCommand command = connection.CreateCommand())
                {

                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_ShowUserQuestionForManager";
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

        private void ProcedureAcceptOrganizerQuestion(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_AcceptOrganizerQuestion";

                        bool boolresultparse = Int32.TryParse(OrganizerIDForQuestion_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("QuestionID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("ManagerLogin_in", OracleDbType.NVarchar2).Value = login;
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
        private void ProcedureAcceptUserQuestion(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_AcceptUserQuestion";

                        bool boolresultparse = Int32.TryParse(UserIDForQuestion_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("QuestionID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("ManagerLogin_in", OracleDbType.NVarchar2).Value = login;
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
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }

        private void ProcedureCommentOrganizerQuestion(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_CommentOrganizerQuestion";

                        bool boolresultparse = Int32.TryParse(OrganizerIDForQuestion_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("QuestionID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("ManagerLogin_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("AnswetText", OracleDbType.NVarchar2).Value = AnswerForQuestion_TextBox.Text;
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
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureCommentUserQuestion(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_CommentUserQuestion";

                        bool boolresultparse = Int32.TryParse(UserIDForQuestion_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("QuestionID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("ManagerLogin_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("AnswetText", OracleDbType.NVarchar2).Value = AnswerForUserQuestion_TextBox.Text;
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
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureCloseOrganizerQuestion(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_CloseOrganizerQuestion";

                        bool boolresultparse = Int32.TryParse(OrganizerIDForQuestion_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("QuestionID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("ManagerLogin_in", OracleDbType.NVarchar2).Value = login;
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
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void ProcedureCloseUserQuestion(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    connection.Open();

                    using (OracleCommand command = connection.CreateCommand())
                    {

                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_CloseUserQuestion";

                        bool boolresultparse = Int32.TryParse(UserIDForQuestion_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("ID isn't correct");
                        }

                        command.Parameters.Add("QuestionID_in", OracleDbType.Int32).Value = resultparse;
                        command.Parameters.Add("ManagerLogin_in", OracleDbType.NVarchar2).Value = login;
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
                MessageBox.Show($"Ошибка: {ex.Message} ");
            }

        }
        private void RefreshOrganizerEventsDataGrid()
        {
            using (connection = new OracleConnection(connectionString))
            {
                connection.Open();

                using (OracleCommand command = connection.CreateCommand())
                {

                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_ShowAllEvents";

                    command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);

                    OracleDataAdapter adapter = new OracleDataAdapter(command);

                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    OrganizerEventsDataGrid.ItemsSource = dataTable.DefaultView;

                    connection.Close();
                }
            }
        }

        private void RefreshEventsScheduleDataGrid()
        {
            using (connection = new OracleConnection(connectionString))
            {
                using (OracleCommand command = connection.CreateCommand())
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_ShowAllEventsSchedule";
                    command.Parameters.Add("result", OracleDbType.RefCursor, ParameterDirection.Output);
                    OracleDataAdapter adapter = new OracleDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    OrganizerEventsScheduleDataGrid.ItemsSource = dataTable.DefaultView;

                    connection.Close();
                }
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
                        command.CommandText = "TicketVibe_UpdateEventByManager";

                        command.Parameters.Add("Number_EventID", OracleDbType.NVarchar2).Value = resultparse;
                        command.Parameters.Add("EventName_in", OracleDbType.NVarchar2).Value = EventNameForUpdate_TextBox.Text;
                        command.Parameters.Add("EventDuration_in", OracleDbType.NVarchar2).Value = EventDurationForUpdate_TextBox.Text;
                        command.Parameters.Add("Number_SubcategoryID", OracleDbType.NVarchar2).Value = result1parse;
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
                        command.CommandText = "TicketVibe_DeleteEventByManager";
                        bool boolresultparse = Int32.TryParse(EventIDForUpdateDelete_TextBox.Text, out int resultparse);
                        if (!boolresultparse)
                        {
                            throw new Exception("Event ID isn't correct");
                        }
                        command.Parameters.Add("Number_EventID", OracleDbType.Int32).Value = resultparse;
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
                                throw new Exception($"Date format: {dateformat}");
                            }

                        }
                        else
                        {
                            throw new Exception("EventDate is incorrect");
                        }
                        if (!string.IsNullOrEmpty(EventScheduleIDForUpdateDeleteSchedule_TextBox.Text))
                        {
                            boolresult2parse = Int32.TryParse(EventScheduleIDForUpdateDeleteSchedule_TextBox.Text, out int tempResult2parse);
                            if (boolresult2parse)
                            {
                                result2parse = tempResult2parse;
                            }
                            else
                            {
                                throw new Exception("EventScheduleID is incorrect");
                            }
                        }
                        else
                        {
                            throw new Exception("EventScheduleID is incorrect");
                        }
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_UpdateEventScheduleByManager";
                        command.Parameters.Add("EventScheduleID_in", OracleDbType.Int32).Value = result2parse;
                        command.Parameters.Add("EventDate_in", OracleDbType.TimeStamp).Value = result1parse;
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
                            else
                            {
                                throw new Exception("EventScheduleID is incorrect");
                            }
                        }
                        else
                        {
                            throw new Exception("EventScheduleID is incorrect");
                        }
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_DeleteEventSchedule";

                        command.Parameters.Add("EventScheduleID_in", OracleDbType.Int32).Value = result2parse;
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
            MainCatalog mainWindow = new MainCatalog(login,password,role);
            mainWindow.Show();
            this.Close();
        }
        private void Audit(object sender, RoutedEventArgs e)
        {
            try
            {
                Audit mainWindow = new Audit(login, password, role);
                mainWindow.Show();
                this.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message + ex.StackTrace);
            }
        }

    }
}
