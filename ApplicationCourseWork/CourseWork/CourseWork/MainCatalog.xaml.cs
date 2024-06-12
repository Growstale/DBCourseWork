using Microsoft.SqlServer.Server;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity.Core.Common.EntitySql;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace CourseWork
{
    public partial class MainCatalog : Window
    {
        OracleConnection connection;
        string connectionString;
        private string login;
        private string password;
        private int role;
        private int selectedEventName;
        DataTable dataTable = new DataTable();
        public MainCatalog(string login, string password, int role)
        {
            InitializeComponent();
            connectionString = $"DATA SOURCE=localhost:1521/orcl.mshome.net;TNS_ADMIN=C:\\Users\\oracledatabase\\Oracle\\network\\admin;PERSIST SECURITY INFO=True;USER ID=C##{login};PASSWORD={password}";
            this.login = login;
            this.password = password;
            RefreshCategoryComboBox();
            RefreshLocationComboBox();
            RefreshCatalog();
            this.role = role;
            if (role == 3)
            {
                QuestionCreation_TextBox.Visibility = Visibility.Visible;
                UserQuestionTextBlock.Visibility = Visibility.Visible;
                UserQuestionButton.Visibility = Visibility.Visible;
            }
        }
        private void RefreshCatalog()
        {
            using (connection = new OracleConnection(connectionString))
            {
                connection.Open();
                try
                {
                    using (OracleCommand command = connection.CreateCommand())
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_ShowCatalog";
                        string selectedLocationsItemsString = LocationsComboBox.SelectedItem.ToString();
                        string selectedCategoriesItemsString = CategoriesComboBox.SelectedItem.ToString();
                        string selectedSubcategoriesItemsString = SubcategoriesComboBox.SelectedItem != null ? SubcategoriesComboBox.SelectedItem.ToString() : "All";
                        string dateformat = "yyyy-MM-dd";
                        bool boolresult1parse = true;
                        bool boolresult2parse = true;
                        bool boolresult3parse = true;
                        bool boolresult4parse = true;
                        DateTime? result1parse = null;
                        DateTime? result2parse = null;
                        int? result3parse = null;
                        int? result4parse = null;

                        if (!string.IsNullOrEmpty(StartDateSort.Text))
                        {
                            boolresult1parse = DateTime.TryParseExact(StartDateSort.Text, dateformat, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out DateTime tempResult1parse);
                            if (boolresult1parse)
                            {
                                result1parse = tempResult1parse;
                            }
                            else
                            {
                                throw new Exception($"StartDate format: {dateformat}");
                            }
                        }

                        if (!string.IsNullOrEmpty(EndDateSort.Text))
                        {
                            boolresult2parse = DateTime.TryParseExact(EndDateSort.Text, dateformat, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out DateTime tempResult2parse);
                            if (boolresult2parse)
                            {
                                result2parse = tempResult2parse;
                            }
                            else
                            {
                                throw new Exception($"EndDate format: {dateformat}");
                            }
                        }

                        if (!string.IsNullOrEmpty(MinCost.Text))
                        {
                            boolresult3parse = Int32.TryParse(MinCost.Text, out int tempResult3parse);
                            if (boolresult3parse)
                            {
                                result3parse = tempResult3parse;
                            }
                            else
                            {
                                throw new Exception($"Min Cost is incorrect");
                            }
                        }

                        if (!string.IsNullOrEmpty(MaxCost.Text))
                        {
                            boolresult4parse = Int32.TryParse(MaxCost.Text, out int tempResult4parse);
                            if (boolresult4parse)
                            {
                                result4parse = tempResult4parse;
                            }
                            else
                            {
                                throw new Exception($"Max Cost is incorrect");
                            }
                        }
                        Int32 selectedSortType = SortTypeCombobox.SelectedIndex;
                        Int32 selectedSortOrder = SortOrderCombobox.SelectedIndex;

                        if (!boolresult1parse || !boolresult2parse)
                        {
                            throw new Exception("Date isn't correct");
                        }

                        if (!boolresult3parse || !boolresult4parse)
                        {
                            throw new Exception("Price isn't correct");
                        }
                        DateTime dateTime = DateTime.Now;

                        command.Parameters.Add("timestamp_start_date", OracleDbType.TimeStamp).Value = new OracleTimeStamp(result1parse != null ? (DateTime)result1parse : DateTime.Now.AddDays(1));
                        command.Parameters.Add("timestamp_end_date", OracleDbType.TimeStamp).Value = new OracleTimeStamp(result2parse != null ? (DateTime)result2parse : DateTime.Now.AddYears(1));

                        command.Parameters.Add("min_price_in", OracleDbType.Int32).Value = result3parse != null ? result3parse : 0;
                        command.Parameters.Add("max_price_in", OracleDbType.Int32).Value = result4parse != null ? result4parse : int.MaxValue;

                        command.Parameters.Add("sorttype_in", OracleDbType.Int32).Value = selectedSortType;
                        command.Parameters.Add("sortorder_in", OracleDbType.Int32).Value = selectedSortOrder;
                        command.Parameters.Add("cursor_out", OracleDbType.RefCursor, ParameterDirection.Output);
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                        command.Parameters.Add("location_in", OracleDbType.NVarchar2).Value = selectedLocationsItemsString != "All" ? selectedLocationsItemsString : null;
                        command.Parameters.Add("category_in", OracleDbType.NVarchar2).Value = selectedCategoriesItemsString != "All" ? selectedCategoriesItemsString : null;
                        command.Parameters.Add("subcategory_in", OracleDbType.NVarchar2).Value = selectedSubcategoriesItemsString != "All" ? selectedSubcategoriesItemsString : null;

                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        dataTable.Clear();
                        adapter.Fill(dataTable);
                        LViewShop.ItemsSource = dataTable.DefaultView;
                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
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
                    MessageBox.Show(ex.Message);
                }
                connection.Close();
            }
        }
        private void FilterCatalog(object sender, RoutedEventArgs e)
        {
            RefreshCatalog();
        }
        private void RefreshCategoryComboBox()
        {
            using (connection = new OracleConnection(connectionString))
            {
                try
                {
                    using (OracleCommand command = connection.CreateCommand())
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_SelectFromCategories";
                        command.Parameters.Add("cursor_out", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        if (!CategoriesComboBox.Items.Contains("All"))
                        {
                            CategoriesComboBox.Items.Add("All");
                        }

                        foreach (DataRow row in dataTable.Rows)
                        {
                            string CategoryName = row["CategoryName"].ToString();
                            if (!CategoriesComboBox.Items.Contains(CategoryName))
                            {
                                CategoriesComboBox.Items.Add(CategoryName);
                            }
                        }
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
                    MessageBox.Show(ex.Message);
                }

                connection.Close();
            }
        }
        private void RefreshLocationComboBox()
        {
            using (connection = new OracleConnection(connectionString))
            {
                using (OracleCommand command = connection.CreateCommand())
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_SelectFromLocations";
                    command.Parameters.Add("cursor_out", OracleDbType.RefCursor, ParameterDirection.Output);
                    OracleDataAdapter adapter = new OracleDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    if (!LocationsComboBox.Items.Contains("All"))
                    {
                        LocationsComboBox.Items.Add("All");
                    }

                    foreach (DataRow row in dataTable.Rows)
                    {
                        string CategoryName = row["LocationName"].ToString();
                        if (!LocationsComboBox.Items.Contains(CategoryName))
                        {
                            LocationsComboBox.Items.Add(CategoryName);
                        }
                    }
                }
                connection.Close();
            }
        }
        private void RefreshTicketSection(int eventID)
        {
            using (connection = new OracleConnection(connectionString))
            {
                using (OracleCommand command = connection.CreateCommand())
                {
                    RowForBuyTicketCombobox.Items.Clear();
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_GetTicketPricesByEventName";
                    command.Parameters.Add("EventScheduleID_in", OracleDbType.Int32).Value = eventID;
                    command.Parameters.Add("cursor_out", OracleDbType.RefCursor, ParameterDirection.Output);
                    OracleDataAdapter adapter = new OracleDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    TicketPriceDataGrid.ItemsSource = dataTable.DefaultView;

                    foreach (DataRow row in dataTable.Rows)
                    {
                        string SectorRow = row["SectorRow"].ToString();
                        if (!RowForBuyTicketCombobox.Items.Contains(SectorRow))
                        {
                            RowForBuyTicketCombobox.Items.Add(SectorRow);
                        }
                    }

                }
                connection.Close();
            }
        }
        private void CategoriesComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            using (connection = new OracleConnection(connectionString))
            {
                string selectedItem = CategoriesComboBox.SelectedItem.ToString();
                if (selectedItem == "All")
                {
                    SubcategoriesComboBox.Items.Clear();
                }
                else
                {
                    using (OracleCommand command = connection.CreateCommand())
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_GetSubcategoriesByCategoryName";
                        command.Parameters.Add("CategoryName_in", OracleDbType.NVarchar2).Value = selectedItem;
                        command.Parameters.Add("cursor_out", OracleDbType.RefCursor, ParameterDirection.Output);
                        OracleDataAdapter adapter = new OracleDataAdapter(command);

                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        SubcategoriesComboBox.Items.Clear();
                        if (!SubcategoriesComboBox.Items.Contains("All"))
                        {
                            SubcategoriesComboBox.Items.Add("All");
                        }
                        foreach (DataRow row in dataTable.Rows)
                        {
                            string CategoryName = row["SubcategoryName"].ToString();
                            if (!SubcategoriesComboBox.Items.Contains(CategoryName))
                            {
                                SubcategoriesComboBox.Items.Add(CategoryName);
                            }
                        }
                    }

                }
                connection.Close();
            }
        }

        private void LViewShop_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            try
            {
                if (LViewShop.SelectedItem != null)
                {
                    int index = LViewShop.SelectedIndex;
                    string eventScheduleID = dataTable.Rows[index]["EVENTSCHEDULEID"].ToString();
                    if (index >= 0 && int.TryParse(eventScheduleID, out int parseresult))
                    {
                        selectedEventName = parseresult;
                        RefreshTicketSection(parseresult);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void RowForBuyTicketCombobox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    using (OracleCommand command = connection.CreateCommand())
                    {
                        if (RowForBuyTicketCombobox.SelectedIndex != -1)
                        {
                            string selectedItem = RowForBuyTicketCombobox.SelectedItem.ToString();
                            NumberOfSeatForBuyTicketCombobox.Items.Clear();
                            bool boolresultparse = Int32.TryParse(selectedItem, out int resultparse);
                            if (!boolresultparse)
                            {
                                throw new Exception("Sector Row is incorrect");
                            }

                            command.CommandType = CommandType.StoredProcedure;
                            command.CommandText = "TicketVibe_GetPlacesInRowByEventNameAndSectorRow";
                            command.Parameters.Add("EventScheduleID_in", OracleDbType.Int32).Value = selectedEventName;
                            command.Parameters.Add("SectorRow_in", OracleDbType.Int32).Value = resultparse;
                            command.Parameters.Add("Result_out", OracleDbType.RefCursor, ParameterDirection.Output);
                            command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;
                            OracleDataAdapter adapter = new OracleDataAdapter(command);

                            DataTable dataTable = new DataTable();
                            adapter.Fill(dataTable);

                            foreach (DataRow row in dataTable.Rows)
                            {
                                string PlaceInRow = row["PlaceInRow"].ToString();
                                if (!NumberOfSeatForBuyTicketCombobox.Items.Contains(PlaceInRow))
                                {
                                    NumberOfSeatForBuyTicketCombobox.Items.Add(PlaceInRow);
                                }
                            }
                            string message = command.Parameters["Message_out"].Value.ToString();
                            if (!string.IsNullOrEmpty(message) && message!= "null")
                            {
                                MessageBox.Show(message);
                            }
                        }
                    }
                    connection.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void NumberOfSeatForBuyTicketCombobox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    using (OracleCommand command = connection.CreateCommand())
                    {
                        if (NumberOfSeatForBuyTicketCombobox.SelectedIndex != -1)
                        {
                            connection.Open();
                            string selectedItemSeat = NumberOfSeatForBuyTicketCombobox.SelectedItem.ToString();
                            string selectedItemRow = RowForBuyTicketCombobox.SelectedItem.ToString();
                            bool boolresult1parse = Int32.TryParse(selectedItemRow, out int result1parse);
                            bool boolresult2parse = Int32.TryParse(selectedItemSeat, out int result2parse);
                            if (!boolresult1parse || !boolresult2parse)
                            {
                                throw new Exception("Values are incorrect");
                            }
                            command.CommandType = CommandType.StoredProcedure;
                            command.CommandText = "TicketVibe_FindTicketPrice";
                            command.Parameters.Add("EventScheduleID_in", OracleDbType.Int32).Value = selectedEventName;
                            command.Parameters.Add("SectorRow_in", OracleDbType.Int32).Value = result1parse;
                            command.Parameters.Add("PlaceInRow_in", OracleDbType.Int32).Value = result2parse;
                            command.Parameters.Add("Price_out", OracleDbType.Int32, ParameterDirection.Output);
                            command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                            command.ExecuteNonQuery();

                            FinalPrice_TextBlock.Text = command.Parameters["Price_out"].Value.ToString();
                            string message = command.Parameters["Message_out"].Value.ToString();
                            if (!string.IsNullOrEmpty(message) && message != "null")
                            {
                                MessageBox.Show(message);
                            }
                        }
                        else
                        {
                            FinalPrice_TextBlock.Text = string.Empty;
                        }
                    }
                    connection.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            if (role == 0)
            {
                UserPersonalAccount newwindow = new UserPersonalAccount(login, password, role);
                newwindow.Show();
                this.Close();
            }
            if (role == 1)
            {
                OrganizerPersonalAccount newwindow = new OrganizerPersonalAccount(login, password, role);
                newwindow.Show();
                this.Close();
            }
            if (role == 2)
            {
                ModeratorPersonalAccount newwindow = new ModeratorPersonalAccount(login, password, role);
                newwindow.Show();
                this.Close();
            }

        }

        private void AddTicketToShoppingCartProcedure(object sender, RoutedEventArgs e)
        {
            try
            {
                using (connection = new OracleConnection(connectionString))
                {
                    using (OracleCommand command = connection.CreateCommand())
                    {
                        connection.Open();
                        string selectedItemSeat = null;
                        string selectedItemRow = null;
                        if (RowForBuyTicketCombobox.SelectedIndex != -1)
                        {
                            selectedItemRow = RowForBuyTicketCombobox.SelectedItem.ToString();
                        }
                        else
                        {
                            throw new Exception("Select a row");
                        }

                        if (NumberOfSeatForBuyTicketCombobox.SelectedIndex != -1)
                        {
                            selectedItemSeat = NumberOfSeatForBuyTicketCombobox.SelectedItem.ToString();
                        }
                        else
                        {
                            throw new Exception("Select a seat");
                        }

                        bool boolresult1parse = Int32.TryParse(selectedItemRow, out int result1parse);
                        bool boolresult2parse = Int32.TryParse(selectedItemSeat, out int result2parse);
                        if (!boolresult1parse || !boolresult2parse)
                        {
                            throw new Exception("Values are incorrect");
                        }
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "TicketVibe_AddTicketToShoppingCart";
                        command.Parameters.Add("SectorRow_in", OracleDbType.Int32).Value = result1parse;
                        command.Parameters.Add("NumberOfSeat_in", OracleDbType.Int32).Value = result2parse;
                        command.Parameters.Add("EventScheduleID_in", OracleDbType.Int32).Value = selectedEventName;
                        command.Parameters.Add("Login_in", OracleDbType.NVarchar2).Value = login;
                        command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;
                        command.ExecuteNonQuery();

                        string message = command.Parameters["Message_out"].Value.ToString();
                        if (!string.IsNullOrEmpty(message) && message != "null")
                        {
                            MessageBox.Show(message);
                        }
                        RefreshTicketSection(selectedEventName);
                        NumberOfSeatForBuyTicketCombobox.Items.Clear();
                    }
                    connection.Close();
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
                MessageBox.Show(ex.Message);
            }
        }
        private void MoreDetailed(object sender, RoutedEventArgs e)
        {
            try
            {
                    if (selectedEventName < 999)
                    {
                        throw new Exception("Event Schedule ID is incorrect");
                    }
                
                ProdPage newwindow = new ProdPage(login, password, selectedEventName, role);
                newwindow.Show();
                this.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void Exit(object sender, RoutedEventArgs e)
        {
            MainWindow mainWindow = new MainWindow();
            mainWindow.Show();
            this.Close();
        }
        private void ProcedureSearchInCatalog(object sender, RoutedEventArgs e)
        {
            using (connection = new OracleConnection(connectionString))
            {
                connection.Open();

                using (OracleCommand command = connection.CreateCommand())
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "TicketVibe_SearchInCatalog";

                    command.Parameters.Add("SearchEventName_in", OracleDbType.NVarchar2).Value = TextBoxSearch.Text != null ? TextBoxSearch.Text : null;
                    command.Parameters.Add("cursor_out", OracleDbType.RefCursor, ParameterDirection.Output);
                    command.Parameters.Add("Message_out", OracleDbType.NVarchar2, ParameterDirection.Output).Size = 300;

                    OracleDataAdapter adapter = new OracleDataAdapter(command);
                    dataTable.Clear();
                    adapter.Fill(dataTable);
                    LViewShop.ItemsSource = dataTable.DefaultView;
                    string message = command.Parameters["Message_out"].Value.ToString();
                    if (!string.IsNullOrEmpty(message) && message != "null")
                    {
                        MessageBox.Show(message);
                    }
                    connection.Close();
                }
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
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка: {ex.Message}");
            }
        }
    }
}
