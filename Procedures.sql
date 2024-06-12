PROCEDURE AcceptOrganizer (
    OrganizerID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    OrganizerID_exist NUMBER;
    AcceptOrganizerID_exists NUMBER;
	CompanyName_f NVARCHAR2(40);
	Password_f NVARCHAR2(30);
	Ex_Invalid_Organizer_Exist EXCEPTION;
	Ex_Invalid_AcceptOrganizer_Exist EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO OrganizerID_exist FROM TicketVibe_CheckingOrganizers WHERE OrganizerID = OrganizerID_in;
    SELECT COUNT(*) INTO AcceptOrganizerID_exists FROM TicketVibe_Organizers WHERE OrganizerID = OrganizerID_in;
    IF OrganizerID_exist != 1 THEN
		RAISE Ex_Invalid_Organizer_Exist;
    END IF;
    IF AcceptOrganizerID_exists != 0 THEN
		RAISE Ex_Invalid_AcceptOrganizer_Exist;
    END IF;
		SELECT CompanyName INTO CompanyName_f FROM TicketVibe_CheckingOrganizers WHERE OrganizerID = OrganizerID_in; 
		SELECT Password INTO Password_f FROM TicketVibe_CheckingOrganizers WHERE OrganizerID = OrganizerID_in; 
        INSERT INTO TicketVibe_Organizers SELECT * FROM TicketVibe_CheckingOrganizers WHERE OrganizerID = OrganizerID_in;
        DELETE FROM TicketVibe_CheckingOrganizers WHERE OrganizerID = OrganizerID_in;
		EXECUTE IMMEDIATE 'CREATE USER C##' || CompanyName_f || ' IDENTIFIED BY "' || Password_f || '"';
		EXECUTE IMMEDIATE 'GRANT OrganizerRole TO C##' || CompanyName_f;
		COMMIT;
         Message_out := 'The organizer has been successfully accepted';
EXCEPTION
	WHEN Ex_Invalid_Organizer_Exist THEN
        Message_out := 'Organizer ID is incorrect';
	WHEN Ex_Invalid_AcceptOrganizer_Exist THEN
        Message_out := 'This organizer already exists';
	WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during organizer acception';
	WHEN OTHERS THEN 
        Message_out := 'Error during organizer acception';
END;

//////////////////////////

PROCEDURE AcceptOrganizerQuestion(
    QuestionID_in IN NUMBER,
    ManagerLogin_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
) 
AS
    ManagerID_f NUMBER;
    MatchesNumber NUMBER;
    CurrentStatus NVARCHAR2(15);
    Ex_Invalid_MatchesNumber EXCEPTION;
    Ex_Invalid_Closed EXCEPTION;
BEGIN
    SELECT ManagerID INTO ManagerID_f FROM TicketVibe_Managers WHERE Login = ManagerLogin_in;
    SELECT COUNT (*) INTO MatchesNumber FROM TicketVibe_OrganizerQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    IF MatchesNumber = 0 THEN
        RAISE Ex_Invalid_MatchesNumber;
    END IF;
    SELECT Status INTO CurrentStatus FROM TicketVibe_OrganizerQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    IF CurrentStatus = 'closed' THEN
        RAISE Ex_Invalid_Closed;
    END IF;
    UPDATE TicketVibe_OrganizerQuestions SET Status = 'In processing' WHERE QuestionID = QuestionID_in;  
	COMMIT;
EXCEPTION
    WHEN Ex_Invalid_MatchesNumber THEN
        Message_out := 'This manager is not responsible for this question';
    WHEN Ex_Invalid_Closed THEN
        Message_out := 'This question is closed';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'The question was not found';
    WHEN OTHERS THEN
        Message_out := 'Error during organizer question acception';
END;

///////////////////////////////

PROCEDURE AcceptRefend (
    SaleID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    SaleID_exist NUMBER;
    TicketID_f NUMBER;
    Ex_Invalid_SaleID EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO SaleID_exist FROM TicketVibe_TicketRefund WHERE SaleID = SaleID_in;
    IF SaleID_exist != 1 THEN
	        RAISE Ex_Invalid_SaleID;
    END IF;
        UPDATE TicketVibe_Sales SET Status = 'Refund' WHERE SaleID = SaleID_in;
        SELECT TicketID INTO TicketID_f FROM TicketVibe_Sales WHERE SaleID = SaleID_in;
        UPDATE TicketVibe_Tickets SET Status = 'On sale' WHERE TicketID = TicketID_f;
        DELETE FROM TicketVibe_TicketRefund WHERE SaleID = SaleID_in;
        COMMIT;
        Message_out := 'The refund has been successfully accepted';
EXCEPTION
    WHEN Ex_Invalid_SaleID THEN
        Message_out := 'Sale ID is incorrect';    
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during acception';  
    WHEN OTHERS THEN
        Message_out := 'Error during acception';    
END;

//////////////////////////////////////

PROCEDURE AcceptUserQuestion(
    QuestionID_in IN NUMBER,
    ManagerLogin_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
) 
AS
    ManagerID_f NUMBER;
    MatchesNumber NUMBER;
    CurrentStatus NVARCHAR2(15);
    Ex_Invalid_MatchesNumber EXCEPTION;
    Ex_Invalid_Closed EXCEPTION;
BEGIN
    SELECT ManagerID INTO ManagerID_f FROM TicketVibe_Managers WHERE Login = ManagerLogin_in;
    SELECT COUNT (*) INTO MatchesNumber FROM TicketVibe_UserQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    IF MatchesNumber = 0 THEN
        RAISE Ex_Invalid_MatchesNumber;
    END IF;
    SELECT Status INTO CurrentStatus FROM TicketVibe_UserQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    IF CurrentStatus = 'closed' THEN
        RAISE Ex_Invalid_Closed;
    END IF;
    UPDATE TicketVibe_UserQuestions SET Status = 'In processing' WHERE QuestionID = QuestionID_in;    
EXCEPTION
    WHEN Ex_Invalid_MatchesNumber THEN
        Message_out := 'This manager is not responsible for this question';
    WHEN Ex_Invalid_Closed THEN
        Message_out := 'This question is closed';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'The question was not found';
    WHEN OTHERS THEN
        Message_out := 'Error during user question acception' ;
END;

///////////////////////////////

PROCEDURE AddCategory (
    CategoryName_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
)
IS
    max_CategoryID NUMBER;
    Category_exists NUMBER;
	Ex_Invalid_Category_Exist EXCEPTION;
	Ex_Invalid_Category_Lenght EXCEPTION;
BEGIN
    SELECT NVL(MAX(CategoryID) + 1, 1000) INTO max_CategoryID FROM TicketVibe_Categories;
    SELECT COUNT(*) INTO Category_exists FROM TicketVibe_Categories WHERE CategoryName = CategoryName_in;

	IF Category_exists > 0 THEN
		RAISE Ex_Invalid_Category_Exist;
    END IF;
	IF LENGTH(CategoryName_in) < 4 OR CategoryName_in IS NULL THEN
		RAISE Ex_Invalid_Category_Lenght;
    END IF;

        INSERT INTO TicketVibe_Categories VALUES (max_CategoryID, CategoryName_in);
        Message_out := 'Category created';
		COMMIT;
EXCEPTION
    WHEN Ex_Invalid_Category_Exist THEN
        Message_out := 'This Category already exists';    
    WHEN Ex_Invalid_Category_Lenght THEN
        Message_out := 'Incorrect category length';    
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during category creation';  
    WHEN OTHERS THEN
        Message_out := 'Error during category creation';    
END;

////////////////////////////////////////

PROCEDURE AddLocation (
    LocationName_in IN NVARCHAR2,
	NumberOfSectors_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    max_LocationID NUMBER;
    Location_exists NUMBER;
	Ex_Invalid_Location_Exist EXCEPTION;
	Ex_Invalid_Location_Lenght EXCEPTION;
	Ex_Invalid_NumberOfSectors EXCEPTION;
BEGIN
    SELECT NVL(MAX(LocationID) + 1, 1000) INTO max_LocationID FROM TicketVibe_Locations;
    SELECT COUNT(*) INTO Location_exists FROM TicketVibe_Locations WHERE LocationName = LocationName_in;
	IF Location_exists > 0 THEN
        RAISE Ex_Invalid_Location_Exist;
    END IF;
	IF LENGTH(LocationName_in) < 4 OR LocationName_in IS NULL THEN
        RAISE Ex_Invalid_Location_Lenght;
    END IF;
	IF NumberOfSectors_in < 1 THEN
        RAISE Ex_Invalid_NumberOfSectors;
	END IF;

        INSERT INTO TicketVibe_Locations VALUES (max_LocationID, LocationName_in, NumberOfSectors_in);
        Message_out := 'Location created';
		COMMIT;
EXCEPTION
    WHEN Ex_Invalid_Location_Exist THEN
        Message_out := 'This location already exists';    
    WHEN Ex_Invalid_Location_Lenght THEN
        Message_out := 'Incorrect location length';    
    WHEN Ex_Invalid_NumberOfSectors THEN
        Message_out := 'Incorrect number of rows';    
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during category creation';  
    WHEN OTHERS THEN
        Message_out := 'Error during category creation';    
END;

///////////////////////////////////

PROCEDURE AddRow (
    LocationName_in IN NVARCHAR2,
	CostFactor_in IN NUMBER,
    NumberOfSeats_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    max_SectorRowID NUMBER;
    max_SectorRow NUMBER;
    LocationID_find NUMBER;
	Ex_Invalid_Location_Name EXCEPTION;
	Ex_Invalid_Values EXCEPTION;
BEGIN
	IF (LocationName_in IS NOT NULL AND LENGTH(LocationName_in) > 3) THEN
		SELECT LocationID INTO LocationID_find FROM TicketVibe_Locations WHERE LocationName = LocationName_in;
		SELECT NVL(MAX(SectorRowID) + 1, 1000) INTO max_SectorRowID FROM TicketVibe_SectorRows;
		SELECT NVL(MAX(SectorRow), 0) INTO max_SectorRow FROM TicketVibe_SectorRows WHERE LocationID = LocationID_find;
		IF NumberOfSeats_in > 1 AND NumberOfSeats_in < 500 AND CostFactor_in  > 0 AND CostFactor_in < 50 THEN
			INSERT INTO TicketVibe_SectorRows VALUES (max_SectorRowID, max_SectorRow + 1, NumberOfSeats_in, LocationID_find, CostFactor_in);
			Message_out := 'The row has been added successfully';
			COMMIT;
		ELSE
			RAISE Ex_Invalid_Values;
		END IF;
	ELSE 
		RAISE Ex_Invalid_Location_Name;
	END IF;
EXCEPTION
    WHEN Ex_Invalid_Location_Name THEN
			Message_out := 'Location name is incorrect';
    WHEN Ex_Invalid_Values THEN
			Message_out := 'Invalid values were passed';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during category creation';  
    WHEN OTHERS THEN
        Message_out := 'Error during category creation';    
END;

//////////////////////////////////////////

PROCEDURE AddSubcategory (
    CategoryName_in IN NVARCHAR2,
    SubcategoryName_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
)
IS
    max_SubcategoryID NUMBER;
    Subcategory_exists NUMBER;
    CategoryID_find NUMBER;
	Ex_Invalid_Subcategory_Exist EXCEPTION;
	Ex_Invalid_Subcategory_Lenght EXCEPTION;
	Ex_Invalid_Category_Lenght EXCEPTION;
BEGIN
    SELECT NVL(MAX(SubcategoryID) + 1, 1000) INTO max_SubcategoryID FROM TicketVibe_Subcategories;

    SELECT CategoryID INTO CategoryID_find FROM TicketVibe_Categories WHERE CategoryName = CategoryName_in; 
    SELECT COUNT(*) INTO Subcategory_exists FROM TicketVibe_Subcategories WHERE CategoryID = CategoryID_find AND SubcategoryName = SubcategoryName_in;

	IF Subcategory_exists > 0 THEN
		RAISE Ex_Invalid_Subcategory_Exist;
    END IF;
	IF LENGTH(SubcategoryName_in) < 3 THEN
		RAISE Ex_Invalid_Subcategory_Lenght;
    END IF;
	IF LENGTH(CategoryName_in) < 4 THEN
		RAISE Ex_Invalid_Category_Lenght;
	END IF;
	    INSERT INTO TicketVibe_Subcategories VALUES (max_SubcategoryID, SubcategoryName_in, CategoryID_find);
        Message_out := 'Subcategory created';
		COMMIT;
EXCEPTION
	    WHEN Ex_Invalid_Subcategory_Exist THEN
			Message_out := 'This Subcategory already exists';
	    WHEN Ex_Invalid_Subcategory_Lenght THEN
			Message_out := 'Incorrect subcategory length';
	    WHEN Ex_Invalid_Category_Lenght THEN
			Message_out := 'The category is not selected';
	    WHEN NO_DATA_FOUND THEN
			Message_out := 'There is not enough data to create a subcategory';
		WHEN Others THEN
			Message_out := 'Error during creation category';
END;

//////////////////////////////////////////

PROCEDURE AddTicketToShoppingCart(
    SectorRow_in IN NUMBER,
    NumberOfSeat_in IN NUMBER,
    EventScheduleID_in IN NUMBER,
    Login_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
) 
AS
    UserID_f NUMBER;
    TicketID_f NUMBER;
	Ex_Invalid_Ticket_Exist EXCEPTION;
BEGIN
    SELECT UserID INTO UserID_f FROM TicketVibe_Users WHERE Login = Login_in;

    SELECT t.TicketID INTO TicketID_f
    FROM TicketVibe_Tickets t
    JOIN TicketVibe_SectorRows sr ON t.SectorRowID = sr.SectorRowID
    JOIN TicketVibe_EventsSchedule es ON t.EventScheduleID = es.EventScheduleID
    WHERE sr.SectorRow = SectorRow_in
    AND t.PlaceInRow = NumberOfSeat_in
    AND es.EventScheduleID = EventScheduleID_in
    AND t.Status = 'On sale';

    IF TicketID_f IS NULL THEN
	RAISE Ex_Invalid_Ticket_Exist;
    END IF;

        INSERT INTO ShoppingCart (UserID, TicketID)
        VALUES (UserID_f, TicketID_f);
        UPDATE TicketVibe_Tickets SET Status = 'Booked' WHERE TicketID = TicketID_f;
		COMMIT;
        Message_out := 'The ticket has been successfully added to the shopping cart';

EXCEPTION
    WHEN Ex_Invalid_Ticket_Exist THEN
        Message_out := 'The ticket was not found';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'The ticket was not found';
    WHEN OTHERS THEN
        Message_out := 'Error during ticket selection';
END;

///////////////////////////////////////////

PROCEDURE AskForRefund (
    Login_in IN NVARCHAR2,
    SaleID_in IN NUMBER,
    Message_in IN NVARCHAR2,
	Message_out OUT NVARCHAR2
)
IS
    SaleBelongsToUser NUMBER;
    UserID_f NUMBER;
    Ex_Invalid_Sale_Exist EXCEPTION;
BEGIN
    SELECT UserID INTO UserID_f FROM TicketVibe_Users WHERE Login = Login_in;
    SELECT COUNT(*) INTO SaleBelongsToUser FROM TicketVibe_Sales WHERE SaleID = SaleID_in AND UserID = UserID_f;
    IF SaleBelongsToUser = 1 THEN
        INSERT INTO TicketRefund (SaleID, UserID, Message, RefundDate)
        VALUES (SaleID_in, UserID_f, Message_in, SYSDATE);
        COMMIT;
        Message_out := 'The request was successfully submitted';
    ELSE
        RAISE Ex_Invalid_Sale_Exist;
    END IF;
EXCEPTION
    WHEN Ex_Invalid_Sale_Exist THEN
        Message_out := 'Sale ID is incorrect';
    WHEN OTHERS THEN
        Message_out := 'Error during refunding';
END;

//////////////////////////////////////////

PROCEDURE Authorization(
    Login_in IN NVARCHAR2,
    Password_in IN NVARCHAR2,
	Role_in IN NUMBER,
    Message_out OUT NVARCHAR2,
	Success_out OUT BOOLEAN
)
IS
    Correct_Password NVARCHAR2(30);
	BlockEndDate TIMESTAMP;
	UserBlock_count NUMBER;
	OrganizerBlock_count NUMBER;
	UserID_f NUMBER;
	OrganizerID_f NUMBER;
	Ex_Invalid_User_Blocked EXCEPTION;
	Ex_Invalid_Organizer_Blocked EXCEPTION;
BEGIN

	IF (Role_in = 0) THEN
		SELECT UserID INTO UserID_f FROM TicketVibe_Users WHERE Login = Login_in;
		SELECT COUNT (*) INTO UserBlock_count FROM TicketVibe_UserBlocks WHERE UserID = UserID_f;
		IF (UserBlock_count > 0) THEN
			SELECT EndDate INTO BlockEndDate FROM TicketVibe_UserBlocks WHERE UserID = UserID_f;
				IF BlockEndDate < SYSDATE THEN
					DELETE FROM TicketVibe_UserBlocks WHERE UserID = UserID_f;
					COMMIT;
					Message_out := 'The User was unlocked';
				ELSE
					RAISE Ex_Invalid_User_Blocked;
				END IF;
		END IF;
		SELECT Password INTO Correct_Password FROM TicketVibe_Users WHERE Login = Login_in;
	END IF;

	IF (Role_in = 1) THEN
		SELECT OrganizerID INTO OrganizerID_f FROM TicketVibe_Organizers WHERE CompanyName = Login_in;
		SELECT COUNT (*) INTO OrganizerBlock_count FROM TicketVibe_OrganizerBlocks WHERE OrganizerID = OrganizerID_f;
		IF (OrganizerBlock_count > 0) THEN
			SELECT EndDate INTO BlockEndDate FROM TicketVibe_OrganizerBlocks WHERE OrganizerID = OrganizerID_f;
				IF BlockEndDate < SYSDATE THEN
					DELETE FROM TicketVibe_OrganizerBlocks WHERE OrganizerID = OrganizerID_f;
					COMMIT;
					Message_out := 'The Organizer was unlocked';
				ELSE
					RAISE Ex_Invalid_Organizer_Blocked;
				END IF;
		END IF;
		SELECT Password INTO Correct_Password FROM TicketVibe_Organizers WHERE CompanyName = Login_in;
	END IF;

	IF (Role_in = 2) THEN
		SELECT Password INTO Correct_Password FROM TicketVibe_Managers WHERE Login = Login_in;
	END IF;

    IF Password_in = Correct_Password THEN
        Message_out := 'Authorization is successful';
		Success_out := TRUE;
    ELSE
		Success_out := FALSE;
    END IF;

EXCEPTION
	WHEN Ex_Invalid_User_Blocked THEN
        Message_out := 'This User is blocked';
	WHEN Ex_Invalid_Organizer_Blocked THEN
        Message_out := 'This Organizer is blocked';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during authorization';
    WHEN OTHERS THEN
        Message_out := 'Error during authorization';
	Success_out := FALSE;
END;

///////////////////////////////////////////

PROCEDURE BlockOrganizer (
    OrganizerID_in IN NUMBER,
    ManagerLogin_in IN NVARCHAR2,
    Reason_in IN NVARCHAR2,
    EndDate_in IN TIMESTAMP,
    Message_out OUT NVARCHAR2
)
IS
    OrganizerID_exist NUMBER;
    ManagerID_f NUMBER;
    max_BlockID NUMBER;
	Block_count NUMBER;
    Ex_Invalid_Organizer_Exist EXCEPTION;
    Ex_Invalid_Manager_Exist EXCEPTION;
    Ex_Invalid_Reason_Exist EXCEPTION;
    Ex_Invalid_EndDate EXCEPTION;
	Ex_Invalid_Block_Exist EXCEPTION;
BEGIN
    SELECT ManagerID INTO ManagerID_f FROM TicketVibe_Managers WHERE Login = ManagerLogin_in;
    SELECT COUNT(*) INTO OrganizerID_exist FROM TicketVibe_Organizers WHERE OrganizerID = OrganizerID_in;
    SELECT NVL(MAX(BlockID) + 1, 1000) INTO max_BlockID FROM TicketVibe_OrganizerBlocks;
	SELECT COUNT (*) INTO Block_count FROM TicketVibe_OrganizerBlocks WHERE OrganizerID = OrganizerID_in;
	IF Block_count > 0 THEN
		RAISE Ex_Invalid_Block_Exist;
	END IF;
	IF EndDate_in < SYSDATE THEN
		RAISE Ex_Invalid_EndDate;
	END IF;
    IF OrganizerID_exist != 1 THEN
        RAISE Ex_Invalid_Organizer_Exist;
    END IF;
    IF ManagerID_f IS NULL THEN
        RAISE Ex_Invalid_Manager_Exist;
    END IF;
    IF LENGTH(Reason_in) < 4 THEN
        RAISE Ex_Invalid_Reason_Exist;
    END IF;
    IF OrganizerID_exist = 1 AND ManagerID_f IS NOT NULL AND LENGTH(Reason_in) > 3 AND EndDate_in IS NOT NULL THEN
        INSERT INTO TicketVibe_OrganizerBlocks VALUES(max_BlockID, OrganizerID_in, ManagerID_f, Reason_in, EndDate_in);
         Message_out := 'The Organizer has been successfully blocked';
		 COMMIT;
    END IF;
    IF OrganizerID_exist = 1 AND ManagerID_f IS NOT NULL AND Reason_in IS NOT NULL AND LENGTH(Reason_in) > 3 AND EndDate_in IS NULL THEN
        INSERT INTO TicketVibe_OrganizerBlocks (BlockID, OrganizerID, ManagerID, Reason) VALUES(max_BlockID, OrganizerID_in, ManagerID_f, Reason_in);
         Message_out := 'The Organizer has been successfully blocked';
		 COMMIT;
    END IF;
EXCEPTION
    WHEN Ex_Invalid_Block_Exist THEN
        Message_out := 'This Organizer is already blocked';
    WHEN Ex_Invalid_EndDate THEN
        Message_out := 'End Date is incorrect';
    WHEN Ex_Invalid_Organizer_Exist THEN
        Message_out := 'Organizer ID is incorrect';
    WHEN Ex_Invalid_Manager_Exist THEN
        Message_out := 'Manager ID is incorrect';
    WHEN Ex_Invalid_Reason_Exist THEN
        Message_out := 'Reason is incorrect';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during organizer blocking';
    WHEN OTHERS THEN
        Message_out := 'Error during organizer blocking';
END;

//////////////////////////////////////////

PROCEDURE BlockUser (
    UserID_in IN NUMBER,
    ManagerLogin_in IN NVARCHAR2,
    Reason_in IN NVARCHAR2,
    EndDate_in IN TIMESTAMP,
    Message_out OUT NVARCHAR2
)
IS
    UserID_exist NUMBER;
    ManagerID_f NUMBER;
	Block_count NUMBER;
    max_BlockID NUMBER;
	Ex_Invalid_User_Exist EXCEPTION;
    Ex_Invalid_Manager_Exist EXCEPTION;
    Ex_Invalid_Reason_Exist EXCEPTION;
    Ex_Invalid_EndDate EXCEPTION;
	Ex_Invalid_Block_Exist EXCEPTION;
BEGIN
    SELECT ManagerID INTO ManagerID_f FROM TicketVibe_Managers WHERE Login = ManagerLogin_in;
    SELECT COUNT(*) INTO UserID_exist FROM TicketVibe_Users WHERE UserID = UserID_in;
    SELECT NVL(MAX(BlockID) + 1, 1000) INTO max_BlockID FROM TicketVibe_UserBlocks;
	SELECT COUNT (*) INTO Block_count FROM TicketVibe_UserBlocks WHERE UserID = UserID_in;
	IF Block_count > 0 THEN
		RAISE Ex_Invalid_Block_Exist;
	END IF;
	IF EndDate_in < SYSDATE THEN
		RAISE Ex_Invalid_EndDate;
	END IF;
    IF UserID_exist != 1 THEN
        RAISE Ex_Invalid_User_Exist;
    END IF;
    IF ManagerID_f IS NULL THEN
        RAISE Ex_Invalid_Manager_Exist;
    END IF;
    IF LENGTH(Reason_in) < 4 THEN
        RAISE Ex_Invalid_Reason_Exist;
    END IF;
    IF UserID_exist = 1 AND ManagerID_f IS NOT NULL AND LENGTH(Reason_in) > 3 AND EndDate_in IS NOT NULL THEN
        INSERT INTO TicketVibe_UserBlocks VALUES(max_BlockID, UserID_in, ManagerID_f, Reason_in, EndDate_in);
         Message_out := 'The user has been successfully blocked';
		 COMMIT;
    END IF;
    IF UserID_exist = 1 AND ManagerID_f IS NOT NULL AND LENGTH(Reason_in) > 3 AND EndDate_in IS NULL THEN
        INSERT INTO TicketVibe_UserBlocks (BlockID, UserID, ManagerID, Reason) VALUES(max_BlockID, UserID_in, ManagerID_f, Reason_in);
         Message_out := 'The user has been successfully blocked';
		 COMMIT;
    END IF;
EXCEPTION
    WHEN Ex_Invalid_Block_Exist THEN
        Message_out := 'This User is already blocked';
    WHEN Ex_Invalid_EndDate THEN
        Message_out := 'End Date is incorrect';
    WHEN Ex_Invalid_User_Exist THEN
        Message_out := 'User ID is incorrect';
    WHEN Ex_Invalid_Manager_Exist THEN
        Message_out := 'Manager ID is incorrect';
    WHEN Ex_Invalid_Reason_Exist THEN
        Message_out := 'Reason is incorrect';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during user blocking';
    WHEN OTHERS THEN
        Message_out := 'Error during user blocking';
END;

///////////////////////////////////////////

PROCEDURE BuyTicket (
    UserLogin_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
)
IS
    max_SaleID NUMBER;
    UserID_f NUMBER;
    TicketsCount_f NUMBER;
	Ex_Invalid_Shopping_Cart EXCEPTION;
    Cursor cart_cursor IS
        SELECT TicketID
        FROM TicketVibe_ShoppingCart
        WHERE UserID = UserID_f;
BEGIN
    SELECT UserID INTO UserID_f FROM TicketVibe_Users WHERE Login = UserLogin_in;
    SELECT COUNT (*) INTO TicketsCount_f FROM TicketVibe_ShoppingCart WHERE UserID = UserID_f;

    IF TicketsCount_f < 1 THEN
		RAISE Ex_Invalid_Shopping_Cart;
    END IF;

        FOR cart_rec IN cart_cursor LOOP
            SELECT NVL(MAX(SaleID) + 1, 1000) INTO max_SaleID FROM TicketVibe_Sales;
            INSERT INTO TicketVibe_Sales (SaleID, UserID, TicketID, SaleDate, Status)
            VALUES (max_SaleID, UserID_f, cart_rec.TicketID, SYSDATE, 'Valid');

            UPDATE TicketVibe_Tickets t
            SET Status = 'Purchased'
            WHERE TicketID = cart_rec.TicketID;
        END LOOP;

        DELETE FROM TicketVibe_ShoppingCart WHERE UserID = UserID_f;
		COMMIT;
        Message_out := 'Success';
        COMMIT;

EXCEPTION
	WHEN Ex_Invalid_Shopping_Cart THEN
        Message_out := 'Shopping Cart is empty';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'No data found';
    WHEN OTHERS THEN
        Message_out := 'Error during buying tickets';
END;

//////////////////////////////////////////

PROCEDURE ClearShoppingCart (
    Login_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
)
IS
    UserID_f NUMBER;
	TicketsCount_f NUMBER;
	Ex_Invalid_Shopping_Cart EXCEPTION;
BEGIN
    SELECT UserID INTO UserID_f FROM TicketVibe_Users WHERE Login = Login_in;
	SELECT COUNT (*) INTO TicketsCount_f FROM TicketVibe_ShoppingCart WHERE UserID = UserID_f;

    IF TicketsCount_f < 1 THEN
		RAISE Ex_Invalid_Shopping_Cart;
    END IF;

		UPDATE TicketVibe_Tickets SET Status = 'On sale' WHERE TicketID IN (
		    SELECT TicketID FROM TicketVibe_ShoppingCart WHERE UserID = UserID_f
		);
		DELETE FROM TicketVibe_ShoppingCart WHERE UserID = UserID_f;
		Message_out := 'Shopping Cart successfully was cleared';
		COMMIT;
EXCEPTION
	WHEN Ex_Invalid_Shopping_Cart THEN
        Message_out := 'Shopping Cart is empty';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Shopping Cart was not found';
    WHEN OTHERS THEN
        Message_out := 'Error during Shopping Cart cleaning';    
END;

//////////////////////////////////////////

PROCEDURE CloseOrganizerQuestion(
    QuestionID_in IN NUMBER,
    ManagerLogin_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
) 
AS
    ManagerID_f NUMBER;
    MatchesNumber NUMBER;
    CurrentStatus NVARCHAR2(15);
    CurrentAnswer NVARCHAR2(500);
    Ex_Invalid_MatchesNumber EXCEPTION;
    Ex_Invalid_Closed EXCEPTION;
BEGIN
    SELECT ManagerID INTO ManagerID_f FROM TicketVibe_Managers WHERE Login = ManagerLogin_in;
    SELECT COUNT (*) INTO MatchesNumber FROM TicketVibe_OrganizerQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    IF MatchesNumber = 0 THEN
        RAISE Ex_Invalid_MatchesNumber;
    END IF;
    SELECT Status INTO CurrentStatus FROM TicketVibe_OrganizerQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    IF CurrentStatus = 'closed' THEN
        RAISE Ex_Invalid_Closed;
    END IF;
    UPDATE TicketVibe_OrganizerQuestions SET Status = 'closed' WHERE QuestionID = QuestionID_in;    
	COMMIT;

EXCEPTION
    WHEN Ex_Invalid_MatchesNumber THEN
        Message_out := 'This manager is not responsible for this question';
    WHEN Ex_Invalid_Closed THEN
        Message_out := 'This question has already been closed';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'The question was not found';
    WHEN OTHERS THEN
        Message_out := 'Error during closing organizer question';
END;

///////////////////////////////

PROCEDURE CloseUserQuestion(
    QuestionID_in IN NUMBER,
    ManagerLogin_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
) 
AS
    ManagerID_f NUMBER;
    MatchesNumber NUMBER;
    CurrentStatus NVARCHAR2(15);
    CurrentAnswer NVARCHAR2(500);
    Ex_Invalid_MatchesNumber EXCEPTION;
    Ex_Invalid_Closed EXCEPTION;
BEGIN
    SELECT ManagerID INTO ManagerID_f FROM TicketVibe_Managers WHERE Login = ManagerLogin_in;
    SELECT COUNT (*) INTO MatchesNumber FROM TicketVibe_UserQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    IF MatchesNumber = 0 THEN
        RAISE Ex_Invalid_MatchesNumber;
    END IF;
    SELECT Status INTO CurrentStatus FROM TicketVibe_UserQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    IF CurrentStatus = 'closed' THEN
        RAISE Ex_Invalid_Closed;
    END IF;
    UPDATE TicketVibe_UserQuestions SET Status = 'closed' WHERE QuestionID = QuestionID_in;    
	COMMIT;

EXCEPTION
    WHEN Ex_Invalid_MatchesNumber THEN
        Message_out := 'This manager is not responsible for this question';
    WHEN Ex_Invalid_Closed THEN
        Message_out := 'This question has already been closed';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'The question was not found';
    WHEN OTHERS THEN
        Message_out := 'Error during closing user question';
END;

/////////////////////////////////////////

PROCEDURE CommentOrganizerQuestion(
    QuestionID_in IN NUMBER,
    ManagerLogin_in IN NVARCHAR2,
    AnswerText IN NVARCHAR2,
    Message_out OUT NVARCHAR2
) 
AS
    ManagerID_f NUMBER;
    MatchesNumber NUMBER;
    CurrentStatus NVARCHAR2(15);
    CurrentAnswer NVARCHAR2(500);
    Ex_Invalid_MatchesNumber EXCEPTION;
    Ex_Invalid_Closed EXCEPTION;
BEGIN
    SELECT ManagerID INTO ManagerID_f FROM TicketVibe_Managers WHERE Login = ManagerLogin_in;
    SELECT COUNT (*) INTO MatchesNumber FROM TicketVibe_OrganizerQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    IF MatchesNumber = 0 THEN
        RAISE Ex_Invalid_MatchesNumber;
    END IF;
    SELECT Status INTO CurrentStatus FROM TicketVibe_OrganizerQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    IF CurrentStatus = 'Not Viewed' THEN
        UPDATE TicketVibe_OrganizerQuestions SET Status = 'In processing' WHERE QuestionID = QuestionID_in;    
    END IF;
    IF CurrentStatus = 'closed' THEN
        RAISE Ex_Invalid_Closed;
    END IF;
    SELECT AnswerText INTO CurrentAnswer FROM TicketVibe_OrganizerQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    CurrentAnswer := CurrentAnswer || ' '  || TO_CHAR(SYSDATE, 'DD.MM.YYYY HH24:MM:SS');
    CurrentAnswer := CurrentAnswer || ' '  || AnswerText;
    UPDATE TicketVibe_OrganizerQuestions SET AnswerText = CurrentAnswer WHERE QuestionID = QuestionID_in;    
	COMMIT;
EXCEPTION
    WHEN Ex_Invalid_MatchesNumber THEN
        Message_out := 'This manager is not responsible for this question';
    WHEN Ex_Invalid_Closed THEN
        Message_out := 'This question is closed';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'The question was not found';
    WHEN OTHERS THEN
        Message_out := 'Error during commenting';
END;

////////////////////////////////////////

PROCEDURE CommentUserQuestion(
    QuestionID_in IN NUMBER,
    ManagerLogin_in IN NVARCHAR2,
    AnswerText IN NVARCHAR2,
    Message_out OUT NVARCHAR2
) 
AS
    ManagerID_f NUMBER;
    MatchesNumber NUMBER;
    CurrentStatus NVARCHAR2(15);
    CurrentAnswer NVARCHAR2(500);
    Ex_Invalid_MatchesNumber EXCEPTION;
    Ex_Invalid_Closed EXCEPTION;
BEGIN
    SELECT ManagerID INTO ManagerID_f FROM TicketVibe_Managers WHERE Login = ManagerLogin_in;
    SELECT COUNT (*) INTO MatchesNumber FROM TicketVibe_UserQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    IF MatchesNumber = 0 THEN
        RAISE Ex_Invalid_MatchesNumber;
    END IF;
    SELECT Status INTO CurrentStatus FROM TicketVibe_UserQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    IF CurrentStatus = 'Not Viewed' THEN
        UPDATE TicketVibe_UserQuestions SET Status = 'In processing' WHERE QuestionID = QuestionID_in;    
    END IF;
    IF CurrentStatus = 'closed' THEN
        RAISE Ex_Invalid_Closed;
    END IF;
    SELECT AnswerText INTO CurrentAnswer FROM TicketVibe_UserQuestions WHERE ManagerID = ManagerID_f AND QuestionID = QuestionID_in;
    CurrentAnswer := CurrentAnswer || ' '  || TO_CHAR(SYSDATE, 'DD.MM.YYYY HH24:MM:SS');
    CurrentAnswer := CurrentAnswer || ' '  || AnswerText;
    UPDATE TicketVibe_UserQuestions SET AnswerText = CurrentAnswer WHERE QuestionID = QuestionID_in;    
	COMMIT;

EXCEPTION
    WHEN Ex_Invalid_MatchesNumber THEN
        Message_out := 'This manager is not responsible for this question';
    WHEN Ex_Invalid_Closed THEN
        Message_out := 'This question is closed';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'The question was not found';
    WHEN OTHERS THEN
        Message_out := 'Error during commenting';
END;

///////////////////////////////////////

PROCEDURE CreateComment(
    Login_in IN NVARCHAR2,
    EventScheduleID_in IN NUMBER,
    CommentText_in IN NVARCHAR2,
    FivePointRating_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    max_CommentID NUMBER;
    UserID_f NUMBER;
    EventID_f NUMBER;
	Number_event_visits NUMBER;
    Ex_Invalid_Comment_Max EXCEPTION;
    Ex_Invalid_Comment_Min EXCEPTION;
    Ex_Invalid_Rating_Max EXCEPTION;
    Ex_Invalid_Rating_Min EXCEPTION;
	Ex_Invalid_Event_Visit EXCEPTION;
BEGIN
    SELECT NVL(MAX(CommentID) + 1, 1000) INTO max_CommentID FROM TicketVibe_Comments;
    SELECT UserID INTO UserID_f FROM TicketVibe_Users WHERE Login = Login_in;
    SELECT EventID INTO EventID_f FROM TicketVibe_EventsSchedule WHERE EventScheduleID = EventScheduleID_in;
    IF LENGTH(CommentText_in) > 400 THEN
        RAISE Ex_Invalid_Comment_Max;
    END IF;
    IF  LENGTH(CommentText_in) < 4 THEN
        RAISE Ex_Invalid_Comment_Min;
    END IF;
    IF FivePointRating_in > 5 THEN
        RAISE Ex_Invalid_Rating_Max;
    END IF;
    IF  FivePointRating_in < 1 THEN
        RAISE Ex_Invalid_Rating_Min;
    END IF;
	SELECT COUNT(*) INTO Number_event_visits FROM TicketVibe_Sales s
		INNER JOIN TicketVibe_Tickets t ON t.TicketID = s.TicketID
		INNER JOIN EventsSchedule es ON t.EventScheduleID = es.EventScheduleID
		WHERE s.UserID = UserID_f AND t.Status = 'Purchased'
		AND es.EventID = EventID_f AND es.EventDate < SYSDATE;

    IF  Number_event_visits < 1 THEN
        RAISE Ex_Invalid_Event_Visit;
    END IF;

    INSERT INTO TicketVibe_Comments VALUES (max_CommentID, UserID_f, EventID_f, CommentText_in, SYSDATE, FivePointRating_in);
    COMMIT;

    Message_out := 'Comment is written';

EXCEPTION
    WHEN Ex_Invalid_Comment_Max THEN
        Message_out := 'Comment exceeds maximum length 400';
    WHEN Ex_Invalid_Comment_Min THEN
        Message_out := 'Comment less than minimum length 4';
    WHEN Ex_Invalid_Rating_Max THEN
        Message_out := 'The rating is carried out on a five-point scale';
    WHEN Ex_Invalid_Rating_Min THEN
        Message_out := 'The rating is carried out on a five-point scale';
    WHEN Ex_Invalid_Event_Visit THEN
        Message_out := 'Only those who have already attended the event can leave comments';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Date was not found during comment creation';
    WHEN OTHERS THEN
        Message_out := 'Error during comment creation';
END;

//////////////////////////////////////

PROCEDURE CreateEvent(
    EventName_in IN NVARCHAR2,
    Number_LocationID IN NUMBER,
    EventDuration_in IN NVARCHAR2,
    Number_SubcategoryID IN NUMBER,
    OrganizerCompany_in IN NVARCHAR2,
    Description_in IN NVARCHAR2,
	Number_Cost IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
	interval_EventDuration INTERVAL DAY TO SECOND;
    OrganizerID_f NUMBER;
    max_EventID NUMBER;
    EventName_exists NUMBER;
    LocationID_exists NUMBER;
    SubcategoryID_exists NUMBER;
    OrganizerID_exists NUMBER;
    Ex_Invalid_EventName_Max EXCEPTION;
    Ex_Invalid_EventName_Min EXCEPTION;
    Ex_Invalid_EventName_Exist EXCEPTION;
    Ex_Invalid_EventDuration_Max EXCEPTION;
    Ex_Invalid_EventDuration_Min EXCEPTION;
    Ex_Invalid_LocationID_Exist EXCEPTION;
    Ex_Invalid_OrganizerID_Exist EXCEPTION;
    Ex_Invalid_Subcategory_Exist EXCEPTION;
    Ex_Invalid_SubcategoryID_Exist EXCEPTION;
    Ex_Invalid_TimeStamp EXCEPTION;
    Ex_Invalid_Interval EXCEPTION;

BEGIN
	IF REGEXP_LIKE(EventDuration_in, '^\d+ \d{2}:\d{2}:\d{2}$') THEN
        interval_EventDuration := TO_DSINTERVAL(EventDuration_in);
	ELSE
		RAISE Ex_Invalid_Interval;
	END IF;


    SELECT OrganizerID INTO OrganizerID_f FROM TicketVibe_Organizers WHERE CompanyName = OrganizerCompany_in;
    SELECT NVL(MAX(EventID) + 1, 1000) INTO max_EventID FROM TicketVibe_Events;

    SELECT COUNT(*) INTO EventName_exists FROM TicketVibe_Events WHERE EventName = EventName_in;
    SELECT COUNT(*) INTO LocationID_exists FROM TicketVibe_Locations WHERE LocationID = Number_LocationID;
    SELECT COUNT(*) INTO SubcategoryID_exists FROM TicketVibe_Subcategories WHERE SubcategoryID = Number_SubcategoryID;
    SELECT COUNT(*) INTO OrganizerID_exists FROM TicketVibe_Organizers WHERE OrganizerID = OrganizerID_f;

    IF LENGTH(EventName_in) > 50 THEN
        RAISE Ex_Invalid_EventName_Max;
    END IF;
    IF  EventName_in IS NULL OR LENGTH(EventName_in) < 4 THEN
        RAISE Ex_Invalid_EventName_Min;
    END IF;
    IF EventName_exists > 0 THEN
        RAISE Ex_Invalid_EventName_Exist;
    END IF;

    IF LocationID_exists < 1 THEN
        RAISE Ex_Invalid_LocationID_Exist;
    END IF;

    IF interval_EventDuration < INTERVAL '0 00:15:00' DAY TO SECOND THEN
        RAISE Ex_Invalid_EventDuration_Min;
    END IF;
    IF interval_EventDuration > INTERVAL '1 00:00:00' DAY TO SECOND THEN
        RAISE Ex_Invalid_EventDuration_Max;
    END IF;

    IF SubcategoryID_exists < 1 THEN
        RAISE Ex_Invalid_SubcategoryID_Exist;
    END IF;

    IF OrganizerID_exists < 1 THEN
        RAISE Ex_Invalid_OrganizerID_Exist;
    END IF;

    IF (Description_in IS NULL OR LENGTH(Description_in) < 3) THEN
        INSERT INTO TicketVibe_Events (EventID, EventName, LocationID, EventDuration, SubcategoryID, OrganizerID, Cost)
        VALUES (max_EventID, EventName_in, Number_LocationID, interval_EventDuration, Number_SubcategoryID, OrganizerID_f, Number_Cost);
        COMMIT;
    END IF;
    IF (LENGTH(Description_in) > 2) THEN
        INSERT INTO TicketVibe_Events (EventID, EventName, LocationID, EventDuration, SubcategoryID, OrganizerID, Cost, Description)
        VALUES (max_EventID, EventName_in, Number_LocationID, interval_EventDuration, Number_SubcategoryID, OrganizerID_f, Number_Cost, Description_in);
        COMMIT;
    END IF;

    Message_out := 'The event is created';

    EXCEPTION
    WHEN Ex_Invalid_EventName_Max THEN
        Message_out := 'Event Name exceeds maximum length 50';
        RETURN;
    WHEN Ex_Invalid_EventName_Min THEN
        Message_out := 'Event Name less than minimum length 4';
        RETURN;
    WHEN Ex_Invalid_EventName_Exist THEN
        Message_out := 'The event with the specified Event Name already exist';
    WHEN Ex_Invalid_LocationID_Exist THEN
        Message_out := 'There is no Location with this ID';
    WHEN Ex_Invalid_EventDuration_Min THEN
        Message_out := 'Event Duration less than minimum: 15 minutes';
    WHEN Ex_Invalid_EventDuration_Max THEN
        Message_out := 'Event Duration exceeds maximum: one day';
    WHEN Ex_Invalid_SubcategoryID_Exist THEN
        Message_out := 'There is no Subcategory with this ID';
    WHEN Ex_Invalid_OrganizerID_Exist THEN
        Message_out := 'There is no Organizer with this ID';
	WHEN Ex_Invalid_TimeStamp THEN
        Message_out := 'The date is entered in the format YYYY-MM-DD HH24:MI';
	WHEN Ex_Invalid_Interval THEN
        Message_out := 'The interval is entered in the format 3 10:25:30';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Date was not found during event creation';
    WHEN OTHERS THEN
        Message_out := 'Error during event creation';
END;

///////////////////////////////////////////

PROCEDURE CreateEventSchedule (
    EventID_in NUMBER,
    EventDate_in TIMESTAMP,
    Message_out OUT NVARCHAR2
)
IS
    EventScheduleID_max NUMBER;
	v_overlap_count NUMBER;
    tomorrow TIMESTAMP;
    next_year TIMESTAMP;
	v_event_start TIMESTAMP;
	v_event_end TIMESTAMP;
	v_eventDuration INTERVAL DAY TO SECOND;
	Ex_Invalid_EventDate_Interval EXCEPTION;
    Ex_Invalid_EventDate_Max EXCEPTION;
    Ex_Invalid_EventDate_Min EXCEPTION;
BEGIN
	SELECT EventDuration INTO v_eventDuration FROM TicketVibe_Events WHERE EventID = EventID_in;

    tomorrow := TRUNC(SYSDATE) + 1;
    next_year := ADD_MONTHS(TRUNC(SYSDATE), 12);
    SELECT NVL(MAX(EventScheduleID) + 1, 1000) INTO EventScheduleID_max FROM TicketVibe_EventsSchedule;
    IF  EventDate_in < tomorrow THEN
        RAISE Ex_Invalid_EventDate_Min;
    END IF;
    IF  EventDate_in > next_year THEN
        RAISE Ex_Invalid_EventDate_Max;
    END IF;

	v_event_start := EventDate_in;
	v_event_end := EventDate_in + v_eventDuration;

	SELECT COUNT(*)
    INTO v_overlap_count
    FROM TicketVibe_EventsSchedule es
    JOIN TicketVibe_Events e ON es.EventID = e.EventID
    WHERE e.LocationID = (SELECT LocationID FROM TicketVibe_Events WHERE EventID = EventID_in)
    AND ((v_event_start <= es.EventDate AND v_event_end > es.EventDate)
         OR (v_event_start < es.EventDate + e.EventDuration AND v_event_end >= es.EventDate + e.EventDuration)
		 OR (v_event_start < es.EventDate AND v_event_end >= es.EventDate + e.EventDuration));

    IF v_overlap_count > 0 THEN
		RAISE Ex_Invalid_EventDate_Interval;
	END IF;


    INSERT INTO TicketVibe_EventsSchedule (EventScheduleID, EventDate, EventID) VALUES (EventScheduleID_max, EventDate_in, EventID_in);
    COMMIT;
EXCEPTION
    WHEN Ex_Invalid_EventDate_Max THEN
        Message_out := 'Event Date exceeds maximum date: year later';
    WHEN Ex_Invalid_EventDate_Min THEN
        Message_out := 'Event Date less than minimum date: tomorrow';
    WHEN Ex_Invalid_EventDate_Interval THEN
        Message_out := 'Location is busy at this time';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during event schedule creation';    
    WHEN OTHERS THEN
        Message_out := 'Error during event schedule creation';
END;

///////////////////////////////////////////////

PROCEDURE CreateOrganizerQuestion(
    OrganizerCompany_in IN NVARCHAR2,
    QuestionText_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
)
IS
    OrganizerID_f NUMBER;
    max_QuestionID NUMBER;
    ManagerID_f NUMBER;
BEGIN

    SELECT OrganizerID INTO OrganizerID_f FROM TicketVibe_Organizers WHERE CompanyName = OrganizerCompany_in;
    SELECT NVL(MAX(QuestionID) + 1, 1000) INTO max_QuestionID FROM TicketVibe_OrganizerQuestions;

    TicketVibe_FindManagerWithLeastQuestions(ManagerID_f);

    INSERT INTO TicketVibe_OrganizerQuestions (QuestionID, OrganizerID, QuestionText, QuestionDate, Status, ManagerID) 
        VALUES (max_QuestionID, OrganizerID_f, QuestionText_in, SYSTIMESTAMP, 'Not Viewed', ManagerID_f);
    COMMIT;

    Message_out := 'The question is created';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during question creation';
    WHEN OTHERS THEN
        Message_out := 'Error during question creation';
END;

/////////////////////////////////////

PROCEDURE CreateUserQuestion(
    UserLogin_in IN NVARCHAR2,
    QuestionText_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
)
IS
    UserID_f NUMBER;
    max_QuestionID NUMBER;
    ManagerID_f NUMBER;
BEGIN

    SELECT UserID INTO UserID_f FROM TicketVibe_Users WHERE Login = UserLogin_in;
    SELECT NVL(MAX(QuestionID) + 1, 1000) INTO max_QuestionID FROM TicketVibe_UserQuestions;

    TicketVibe_FindManagerWithLeastQuestions(ManagerID_f);

    INSERT INTO TicketVibe_UserQuestions (QuestionID, UserID, QuestionText, QuestionDate, Status, ManagerID) 
        VALUES (max_QuestionID, UserID_f, QuestionText_in, SYSTIMESTAMP, 'Not Viewed', ManagerID_f);
    COMMIT;

    Message_out := 'The question is created';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during question creation';
    WHEN OTHERS THEN
        Message_out := 'Error during question creation';
END;

/////////////////////////////

PROCEDURE DeleteCategory (
    CategoryID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    CategoryID_exist NUMBER;
	Ex_Invalid_Category_Exist EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO CategoryID_exist FROM TicketVibe_Categories WHERE CategoryID = CategoryID_in;
    IF CategoryID_exist < 1 THEN
		RAISE Ex_Invalid_Category_Exist;
    END IF;
        DELETE FROM TicketVibe_Categories WHERE CategoryID = CategoryID_in;
        Message_out := 'The category has been successfully deleted';
		COMMIT;
EXCEPTION
	WHEN Ex_Invalid_Category_Exist THEN
        Message_out := 'Category ID is incorrect';    
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during category deletion';
    WHEN OTHERS THEN
        Message_out := 'Error during category deletion';
END;

////////////////////////////////////

PROCEDURE DeleteComment (
    CommentID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
AS
BEGIN
    DELETE FROM TicketVibe_Comments WHERE CommentID = CommentID_in;
	COMMIT;
EXCEPTION    
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during deletion of comments';    
    WHEN OTHERS THEN
        Message_out := 'Error during deletion of comments';
END;

//////////////////////////////////////

PROCEDURE DeleteEvent (
    Number_EventID IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    EventID_exists NUMBER;
    Ex_Invalid_EventID_Exist EXCEPTION;

BEGIN
    SELECT COUNT(*) INTO EventID_exists FROM TicketVibe_Events WHERE EventID = Number_EventID;

    IF EventID_exists < 1 THEN
        RAISE Ex_Invalid_EventID_Exist;
    END IF;
    DELETE FROM TicketVibe_Events WHERE EventID = Number_EventID;
    COMMIT;

    Message_out := 'The event is deleted';

    EXCEPTION
    WHEN Ex_Invalid_EventID_Exist THEN
        Message_out := 'There is no Event with this ID';
    WHEN OTHERS THEN
        Message_out := 'Error during event deletion';
END;

//////////////////////////////////////////

PROCEDURE DeleteEventByManager (
    Number_EventID IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    EventID_exists NUMBER;
    Ex_Invalid_EventID_Exist EXCEPTION;

BEGIN
    SELECT COUNT(*) INTO EventID_exists FROM TicketVibe_Events WHERE EventID = Number_EventID;

    IF EventID_exists < 1 THEN
        RAISE Ex_Invalid_EventID_Exist;
    END IF;
    DELETE FROM TicketVibe_Events WHERE EventID = Number_EventID;
    COMMIT;

    Message_out := 'The event is deleted';

    EXCEPTION
    WHEN Ex_Invalid_EventID_Exist THEN
        Message_out := 'There is no Event with this ID';
    WHEN OTHERS THEN
        Message_out := 'Error during event deletion';
END;

/////////////////////////////////////////

PROCEDURE DeleteEventSchedule (
    EventScheduleID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
AS
BEGIN
    DELETE FROM TicketVibe_EventsSchedule WHERE EventScheduleID = EventScheduleID_in;
	COMMIT;
EXCEPTION    
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found';    
    WHEN OTHERS THEN
        Message_out := 'Error during event showing:';
END;

//////////////////////////////////////////

PROCEDURE DeleteEventScheduleByManager (
    EventScheduleID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
AS
BEGIN
    DELETE FROM TicketVibe_EventsSchedule WHERE EventScheduleID = EventScheduleID_in;
	COMMIT;
EXCEPTION    
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found';    
    WHEN OTHERS THEN
        Message_out := 'Error during event showing:';
END;

///////////////////////////////////////////

PROCEDURE DeleteLocation (
    LocationID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    LocationID_exist NUMBER;
	Ex_Invalid_LocationExist EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO LocationID_exist FROM TicketVibe_Locations WHERE LocationID = LocationID_in;
    IF LocationID_exist < 1 THEN
		RAISE Ex_Invalid_LocationExist;
    END IF;
        DELETE FROM TicketVibe_Locations WHERE LocationID = LocationID_in;
        Message_out := 'The location has been successfully deleted';
		COMMIT;
EXCEPTION
    WHEN Ex_Invalid_LocationExist THEN
        Message_out := 'Location ID is incorrect';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during location deletion';    
    WHEN OTHERS THEN
        Message_out := 'Error during location deletion';
END;

//////////////////////////////////////////

PROCEDURE DeleteRow (
    SectorRowID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    SectorRowID_exist NUMBER;
    SectorRow_f NUMBER;
    LocationID_f NUMBER;
	Ex_Invalid_Row_Exist EXCEPTION;
	Ex_Invalid_Row_Value EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO SectorRowID_exist FROM TicketVibe_SectorRows  WHERE SectorRowID = SectorRowID_in;
    SELECT LocationID INTO LocationID_f FROM TicketVibe_SectorRows WHERE SectorRowID = SectorRowID_in;
    SELECT SectorRow INTO SectorRow_f FROM TicketVibe_SectorRows WHERE SectorRowID = SectorRowID_in;
    IF SectorRowID_exist < 1 THEN
		RAISE Ex_Invalid_Row_Exist;
    END IF;
	IF SectorRow_f < 1 THEN
		RAISE Ex_Invalid_Row_Value;
	END IF;
        DELETE FROM TicketVibe_SectorRows WHERE SectorRowID = SectorRowID_in;
        UPDATE TicketVibe_SectorRows SET SectorRow = SectorRow - 1 WHERE LocationID = LocationID_f AND SectorRow > SectorRow_f;
        UPDATE TicketVibe_Locations SET NumberOfSectors = NumberOfSectors - 1 WHERE LocationID = LocationID_f;
		COMMIT;
        Message_out := 'The row has been successfully deleted';
EXCEPTION
    WHEN Ex_Invalid_Row_Value THEN
        Message_out := 'Row is incorrect';
    WHEN Ex_Invalid_Row_Exist THEN
        Message_out := 'Row ID is incorrect';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during row deletion';    
    WHEN OTHERS THEN
        Message_out := 'Error during row deletion';
END;

////////////////////////////////////////

PROCEDURE DeleteSubcategory (
    SubcategoryID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    SubcategoryID_exist NUMBER;
	Ex_Invalid_Subcategory_Exist EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO SubcategoryID_exist FROM TicketVibe_Subcategories WHERE SubcategoryID = SubcategoryID_in;
    IF SubcategoryID_exist < 1 THEN
		RAISE Ex_Invalid_Subcategory_Exist;
    END IF;
    DELETE FROM TicketVibe_Subcategories WHERE SubcategoryID = SubcategoryID_in;
	COMMIT;
    Message_out := 'The Subcategory has been successfully deleted';
EXCEPTION
	WHEN Ex_Invalid_Subcategory_Exist THEN
        Message_out := 'Subcategory ID is incorrect';    
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during Subcategory deletion';
    WHEN OTHERS THEN
        Message_out := 'Error during Subcategory deletion';
END;

////////////////////////////////////

PROCEDURE DeleteTicketFromShoppingCart (
    Login_in IN NVARCHAR2,
    TicketID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    UserID_f NUMBER;
BEGIN
    SELECT UserID INTO UserID_f FROM TicketVibe_Users WHERE Login = Login_in;
    DELETE FROM TicketVibe_ShoppingCart WHERE UserID = UserID_f AND TicketID = TicketID_in;
    UPDATE TicketVibe_Tickets SET Status = 'On sale' WHERE TicketID = TicketID_in;
	COMMIT;
    Message_out := 'Ticket successfully was deleted';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Ticket was not found';
    WHEN OTHERS THEN
        Message_out := 'Error during ticket deletion';    
END;

//////////////////////////////////////////

PROCEDURE DenyOrganizer (
    OrganizerID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    OrganizerID_exist NUMBER;
	Ex_Invalid_Organizer_Exist EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO OrganizerID_exist FROM TicketVibe_CheckingOrganizers WHERE OrganizerID = OrganizerID_in;
	IF OrganizerID_exist != 1 THEN
		RAISE Ex_Invalid_Organizer_Exist;
    END IF;
    IF OrganizerID_exist = 1 THEN
        DELETE FROM TicketVibe_CheckingOrganizers WHERE OrganizerID = OrganizerID_in;
		COMMIT;
        Message_out := 'The organizer has been successfully denied';
    END IF;
EXCEPTION
	WHEN Ex_Invalid_Organizer_Exist THEN
        Message_out := 'Organizer ID is incorrect';    
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during Organizer denied';
    WHEN OTHERS THEN
        Message_out := 'Error during Organizer denied';
END;

//////////////////////////////////////////

PROCEDURE DenyRefend (
    SaleID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    SaleID_exist NUMBER;
    TicketID_f NUMBER;
    Ex_Invalid_SaleID EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO SaleID_exist FROM TicketVibe_TicketRefund WHERE SaleID = SaleID_in;
    IF SaleID_exist = 1 THEN
        DELETE FROM TicketVibe_TicketRefund WHERE SaleID = SaleID_in;
        COMMIT;
        Message_out := 'The refund has been successfully denied';
    ELSE
        RAISE Ex_Invalid_SaleID;
    END IF;
EXCEPTION
    WHEN Ex_Invalid_SaleID THEN
        Message_out := 'Sale ID is incorrect';    
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during denied';  
    WHEN OTHERS THEN
        Message_out := 'Error during denied';    
END;

//////////////////////////////////////////

PROCEDURE FindManagerWithLeastQuestions (
    ManagerID_out OUT NUMBER
)
AS
BEGIN
    SELECT ManagerID INTO ManagerID_out
    FROM (
        SELECT m.ManagerID, COUNT(uq.QuestionID) AS total_user_questions, COUNT(oq.QuestionID) AS total_organizer_questions
        FROM TicketVibe_Managers m
        LEFT JOIN TicketVibe_UserQuestions uq ON m.ManagerID = uq.ManagerID
        LEFT JOIN TicketVibe_OrganizerQuestions oq ON m.ManagerID = oq.ManagerID
		WHERE uq.Status != 'closed' AND oq.Status != 'closed'
        GROUP BY m.ManagerID
        ORDER BY (COALESCE(COUNT(uq.QuestionID), 0) + COALESCE(COUNT(oq.QuestionID), 0)) ASC
    )
    WHERE ROWNUM = 1;

END;

/////////////////////////////////////////

PROCEDURE FindTicketPrice (
    EventScheduleID_in IN NUMBER,
    SectorRow_in IN NUMBER,
    PlaceInRow_in IN NUMBER,
    Price_out OUT NUMBER,
	Message_out OUT NVARCHAR2
)
IS
BEGIN
    SELECT Price INTO Price_out
    FROM TicketVibe_Tickets t
    JOIN TicketVibe_EventsSchedule es ON t.EventScheduleID = es.EventScheduleID
    JOIN TicketVibe_SectorRows sr ON t.SectorRowID = sr.SectorRowID
    WHERE es.EventScheduleID = EventScheduleID_in
    AND sr.SectorRow = SectorRow_in
    AND t.PlaceInRow = PlaceInRow_in;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
		Message_out := 'Data was not found during ticket price finding';
    WHEN OTHERS THEN
		Message_out := 'Erroe during ticket price finding';
END;

////////////////////////////////////////

PROCEDURE GetPlacesInRowByEventNameAndSectorRow (
    EventScheduleID_in IN NUMBER,
    SectorRow_in IN NUMBER,
    Result_out OUT SYS_REFCURSOR,
	Message_out OUT NVARCHAR2
)
IS
BEGIN
    OPEN Result_out FOR
        SELECT PlaceInRow
        FROM TicketVibe_Tickets t
        JOIN TicketVibe_EventsSchedule es ON t.EventScheduleID = es.EventScheduleID
        JOIN TicketVibe_SectorRows sr ON t.SectorRowID = sr.SectorRowID
        WHERE es.EventScheduleID = EventScheduleID_in
        AND sr.SectorRow = SectorRow_in
		AND t.Status = 'On sale';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
		Message_out := 'Data was not found during getting places on row';
    WHEN OTHERS THEN
		Message_out := 'Error during getting places on row';
END;

//////////////////////////////////////////

PROCEDURE GetPurchaseHistory(
    Login_in IN VARCHAR2,
    Cursor_out OUT SYS_REFCURSOR,
	Message_out OUT NVARCHAR2
)
IS
    UserID_f NUMBER;
BEGIN
    SELECT UserID INTO UserID_f FROM TicketVibe_Users WHERE Login = Login_in;
    OPEN Cursor_out FOR
    SELECT s.SaleID, s.SaleDate, s.Status, t.PlaceInRow, t.Price, sr.SectorRow, e.EventName
    FROM TicketVibe_Sales s
        INNER JOIN TicketVibe_Tickets t ON s.TicketID = t.TicketID
        INNER JOIN TicketVibe_SectorRows sr ON sr.SectorRowID = t.SectorRowID
        INNER JOIN TicketVibe_EventsSchedule es ON es.EventScheduleID = t.EventScheduleID
		INNER JOIN TicketVibe_Events e ON es.EventID = e.EventID
    WHERE s.UserID = UserID_f;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
		Message_out := 'Data was not found during getting purchase history';
    WHEN OTHERS THEN
		Message_out := 'Error during getting purchase history';
END;

/////////////////////////////////////////

PROCEDURE GetSubcategoriesByCategoryName(
    CategoryName_in IN VARCHAR2,
    Cursor_out OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN Cursor_out FOR
    SELECT s.SubcategoryName
    FROM TicketVibe_Subcategories s
    JOIN TicketVibe_Categories c ON s.CategoryID = c.CategoryID
    WHERE c.CategoryName = CategoryName_in;
END;

///////////////////////////////////////////

PROCEDURE GetTicketPricesByEventName (
    EventScheduleID_in IN NUMBER,
    result OUT SYS_REFCURSOR
)
IS
    EventID_f NUMBER;
BEGIN
        OPEN result FOR
        SELECT 
            s.SectorRow, 
            t.Price,
            COUNT(DISTINCT t.PlaceInRow) AS PlacesInRowCount
        FROM TicketVibe_Tickets t
        INNER JOIN TicketVibe_SectorRows s ON t.SectorRowID = s.SectorRowID
        WHERE t.EventScheduleID = EventScheduleID_in
		AND t.Status = 'On sale'
        GROUP BY s.SectorRow, t.Price
		ORDER BY s.SectorRow;
END;

////////////////////////////////////////////

PROCEDURE ManagerRegistration (
    Login_in IN NVARCHAR2,
    Password_in IN NVARCHAR2,
    FirstName_in IN NVARCHAR2,
    LastName_in IN NVARCHAR2,
    Email_in IN NVARCHAR2,
    Phone_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
)
IS
    max_ManagerID NUMBER;
    CompanyName_exists NUMBER;
    UserLogin_exists NUMBER;
    ManagerLogin_exists NUMBER;
	CheckingCompanyName_exists NUMBER;
    Email_exists NUMBER;
    Phone_exists NUMBER;
    Ex_Invalid_Login_Max EXCEPTION;
    Ex_Invalid_Login_Min EXCEPTION;
    Ex_Invalid_Login_Exist EXCEPTION;
    Ex_Invalid_Password_Max EXCEPTION;
    Ex_Invalid_Password_Min EXCEPTION;
    Ex_Invalid_FirstName_Max EXCEPTION;
    Ex_Invalid_FirstName_Min EXCEPTION;
    Ex_Invalid_LastName_Max EXCEPTION;
    Ex_Invalid_LastName_Min EXCEPTION;
    Ex_Invalid_Email_Max EXCEPTION;
    Ex_Invalid_Email_Min EXCEPTION;
    Ex_Invalid_Email_Exist EXCEPTION;
    Ex_Invalid_Email_Reg EXCEPTION;
    Ex_Invalid_Phone_Max EXCEPTION;
    Ex_Invalid_Phone_Min EXCEPTION;
    Ex_Invalid_Phone_Exist EXCEPTION;
    Ex_Invalid_Phone_Reg EXCEPTION;
    current_date DATE;
BEGIN
    SELECT NVL(MAX(ManagerID) + 1, 1000) INTO max_ManagerID FROM TicketVibe_Managers;

	SELECT COUNT(*) INTO CompanyName_exists FROM TicketVibe_Organizers WHERE CompanyName = Login_in;
	SELECT COUNT(*) INTO CheckingCompanyName_exists FROM TicketVibe_CheckingOrganizers WHERE CompanyName = Login_in;
	SELECT COUNT(*) INTO UserLogin_exists FROM TicketVibe_Users WHERE Login = Login_in;
    SELECT COUNT(*) INTO ManagerLogin_exists FROM TicketVibe_Managers WHERE Login = Login_in;

    SELECT COUNT(*) INTO Email_exists FROM TicketVibe_Managers WHERE Email = Email_in;
    SELECT COUNT(*) INTO Phone_exists FROM TicketVibe_Managers WHERE Phone = Phone_in;

    IF LENGTH(Login_in) > 40 THEN
        RAISE Ex_Invalid_Login_Max;
    END IF;
    IF Login_in IS NULL OR LENGTH(Login_in) < 4 THEN
        RAISE Ex_Invalid_Login_Min;
    END IF;
    IF (CompanyName_exists + UserLogin_exists + ManagerLogin_exists + CheckingCompanyName_exists) > 0 THEN
        RAISE Ex_Invalid_Login_Exist;
    END IF;

    IF LENGTH(Password_in) > 30 THEN
        RAISE Ex_Invalid_Password_Max;
    END IF;
    IF Password_in IS NULL OR LENGTH(Password_in) < 5 THEN
        RAISE Ex_Invalid_Password_Min;
    END IF;

    IF LENGTH(FirstName_in) > 20 THEN
        RAISE Ex_Invalid_FirstName_Max;
    END IF;
    IF FirstName_in IS NULL OR LENGTH(FirstName_in) < 2 THEN
        RAISE Ex_Invalid_FirstName_Min;
    END IF;

    IF LENGTH(LastName_in) > 25 THEN
        RAISE Ex_Invalid_LastName_Max;
    END IF;
    IF LastName_in IS NULL OR LENGTH(LastName_in) < 2 THEN
        RAISE Ex_Invalid_LastName_Min;
    END IF;

    IF LENGTH(Email_in) > 50 THEN
        RAISE Ex_Invalid_Email_Max;
    END IF;
    IF Email_in IS NULL OR LENGTH(Email_in) < 5 THEN
        RAISE Ex_Invalid_Email_Min;
    END IF;
    IF Email_exists > 0 THEN
        RAISE Ex_Invalid_Email_Exist;
    END IF;
    IF NOT REGEXP_LIKE(Email_in, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE Ex_Invalid_Email_Reg;
    END IF;

    IF LENGTH(Phone_in) > 30 THEN
        RAISE Ex_Invalid_Phone_Max;
    END IF;
    IF Phone_in IS NULL OR LENGTH(Phone_in) < 8 THEN    
        RAISE Ex_Invalid_Phone_Min;
    END IF;
    IF Phone_exists > 0 THEN
        RAISE Ex_Invalid_Phone_Exist;
    END IF;
    IF NOT REGEXP_LIKE(Phone_in, '^\+375\s(?:33|25|17|44|29)\s\d{3}\s\d{2}\s\d{2}$') THEN
        RAISE Ex_Invalid_Phone_Reg;
    END IF;

        current_date := SYSDATE;
	    INSERT INTO TicketVibe_Managers (ManagerID, Login, Password, FirstName, LastName, Email, Phone, DateOfEmployment, RoleID)
        VALUES (max_ManagerID, Login_in, Password_in, FirstName_in, LastName_in, Email_in, Phone_in, current_date, 1001);
        EXECUTE IMMEDIATE 'CREATE USER C##' || Login_in || ' IDENTIFIED BY "' || Password_in || '"';
		EXECUTE IMMEDIATE 'GRANT ManagerRole TO C##' || Login_in;

        COMMIT;

    Message_out := 'The manager has been successfully registered';
    EXCEPTION
    WHEN Ex_Invalid_Login_Max THEN
        Message_out := 'Login exceeds maximum length 40';
        RETURN;
    WHEN Ex_Invalid_Login_Min THEN
        Message_out := 'Login less than minimum length 4';
        RETURN;
    WHEN Ex_Invalid_Login_Exist THEN
        Message_out := 'The manager with the specified Login already exist';
    WHEN Ex_Invalid_Password_Max THEN
        Message_out := 'Password exceeds maximum length 30';
    WHEN Ex_Invalid_Password_Min THEN
        Message_out := 'Password less than minimum length 5';
    WHEN Ex_Invalid_FirstName_Max THEN
        Message_out := 'First name exceeds maximum length 20';
    WHEN Ex_Invalid_FirstName_Min THEN
        Message_out := 'First name less than minimum length 2';
    WHEN Ex_Invalid_LastName_Max THEN
        Message_out := 'Last name exceeds maximum length 25';
    WHEN Ex_Invalid_LastName_Min THEN
        Message_out := 'Last name less than minimum length 2';
    WHEN Ex_Invalid_Email_Max THEN
        Message_out := 'Email exceeds maximum length 50';
    WHEN Ex_Invalid_Email_Min THEN
        Message_out := 'Email less than minimum length 5';
	WHEN Ex_Invalid_Email_Reg THEN
        Message_out := 'The email must be in the format email@gmail.com';
    WHEN Ex_Invalid_Email_Exist THEN
        Message_out := 'The user with the specified Email already exist';
    WHEN Ex_Invalid_Phone_Max THEN
        Message_out := 'Phone number exceeds maximum length 30';
    WHEN Ex_Invalid_Phone_Min THEN
        Message_out := 'Phone less than minimum length 8';
    WHEN Ex_Invalid_Phone_Reg THEN
        Message_out := 'The phone must be in the format +375 29 111 22 33';
    WHEN OTHERS THEN
        Message_out := 'Error during manager registration';
END;

//////////////////////////////////////////

PROCEDURE OrganizerRegistration (
    CompanyName_in IN NVARCHAR2,
    Password_in IN NVARCHAR2,
    FirstName_in IN NVARCHAR2,
    LastName_in IN NVARCHAR2,
    Email_in IN NVARCHAR2,
    Phone_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
)
IS
    max_OrganizerID NUMBER;
    CompanyName_exists NUMBER;
	CheckingCompanyName_exists NUMBER;
    UserLogin_exists NUMBER;
    ManagerLogin_exists NUMBER;
    Email_exists1 NUMBER;
    Phone_exists1 NUMBER;
    Email_exists2 NUMBER;
    Phone_exists2 NUMBER;
    Ex_Invalid_CompanyName_Max EXCEPTION;
    Ex_Invalid_CompanyName_Min EXCEPTION;
    Ex_Invalid_CompanyName_Exist EXCEPTION;
    Ex_Invalid_Password_Max EXCEPTION;
    Ex_Invalid_Password_Min EXCEPTION;
    Ex_Invalid_FirstName_Max EXCEPTION;
    Ex_Invalid_FirstName_Min EXCEPTION;
    Ex_Invalid_LastName_Max EXCEPTION;
    Ex_Invalid_LastName_Min EXCEPTION;
    Ex_Invalid_Email_Max EXCEPTION;
    Ex_Invalid_Email_Min EXCEPTION;
    Ex_Invalid_Email_Exist EXCEPTION;
    Ex_Invalid_Email_Reg EXCEPTION;
    Ex_Invalid_Phone_Max EXCEPTION;
    Ex_Invalid_Phone_Min EXCEPTION;
    Ex_Invalid_Phone_Exist EXCEPTION;
    Ex_Invalid_Phone_Reg EXCEPTION;

BEGIN

	SELECT MAX(max_OrganizerID) + 1 INTO max_OrganizerID
		FROM (
			SELECT GREATEST(MAX(OrganizerID), 999) AS max_OrganizerID FROM TicketVibe_CheckingOrganizers
			UNION ALL
			SELECT GREATEST(MAX(OrganizerID), 999) AS max_OrganizerID FROM TicketVibe_Organizers
		);

    SELECT COUNT(*) INTO CompanyName_exists FROM TicketVibe_Organizers WHERE CompanyName = CompanyName_in;
	SELECT COUNT(*) INTO CheckingCompanyName_exists FROM TicketVibe_CheckingOrganizers WHERE CompanyName = CompanyName_in;
	SELECT COUNT(*) INTO UserLogin_exists FROM TicketVibe_Users WHERE Login = CompanyName_in;
    SELECT COUNT(*) INTO ManagerLogin_exists FROM TicketVibe_Managers WHERE Login = CompanyName_in;

    SELECT COUNT(*) INTO Email_exists1 FROM TicketVibe_Organizers WHERE Email = Email_in;
    SELECT COUNT(*) INTO Phone_exists1 FROM TicketVibe_Organizers WHERE Phone = Phone_in;
    SELECT COUNT(*) INTO Email_exists2 FROM TicketVibe_CheckingOrganizers WHERE Email = Email_in;
    SELECT COUNT(*) INTO Phone_exists2 FROM TicketVibe_CheckingOrganizers WHERE Phone = Phone_in;

    IF LENGTH(CompanyName_in) > 40 THEN
        RAISE Ex_Invalid_CompanyName_Max;
    END IF;
    IF CompanyName_in IS NULL OR LENGTH(CompanyName_in) < 5 THEN
        RAISE Ex_Invalid_CompanyName_Min;
    END IF;
    IF (CompanyName_exists + UserLogin_exists + ManagerLogin_exists + CheckingCompanyName_exists) > 0 THEN
        RAISE Ex_Invalid_CompanyName_Exist;
    END IF;

    IF LENGTH(Password_in) > 30 THEN
        RAISE Ex_Invalid_Password_Max;
    END IF;
    IF Password_in IS NULL OR LENGTH(Password_in) < 5 THEN
        RAISE Ex_Invalid_Password_Min;
    END IF;

    IF LENGTH(FirstName_in) > 20 THEN
        RAISE Ex_Invalid_FirstName_Max;
    END IF;
    IF FirstName_in IS NULL OR LENGTH(FirstName_in) < 2 THEN
        RAISE Ex_Invalid_FirstName_Min;
    END IF;

    IF LENGTH(LastName_in) > 25 THEN
        RAISE Ex_Invalid_LastName_Max;
    END IF;
    IF LastName_in IS NULL OR LENGTH(LastName_in) < 2 THEN
        RAISE Ex_Invalid_LastName_Min;
    END IF;

    IF LENGTH(Email_in) > 50 THEN
        RAISE Ex_Invalid_Email_Max;
    END IF;
    IF Email_in IS NULL OR LENGTH(Email_in) < 5 THEN
        RAISE Ex_Invalid_Email_Min;
    END IF;
    IF (Email_exists1 + Email_exists2)  > 0 THEN
        RAISE Ex_Invalid_Email_Exist;
    END IF;
    IF NOT REGEXP_LIKE(Email_in, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE Ex_Invalid_Email_Reg;
    END IF;

    IF LENGTH(Phone_in) > 30 THEN
        RAISE Ex_Invalid_Phone_Max;
    END IF;
    IF Phone_in IS NULL OR LENGTH(Phone_in) < 8 THEN    
        RAISE Ex_Invalid_Phone_Min;
    END IF;
    IF (Phone_exists1 + Phone_exists2) > 0 THEN
        RAISE Ex_Invalid_Phone_Exist;
    END IF;
    IF NOT REGEXP_LIKE(Phone_in, '^\+375\s(?:33|25|17|44|29)\s\d{3}\s\d{2}\s\d{2}$') THEN
        RAISE Ex_Invalid_Phone_Reg;
    END IF;

	    INSERT INTO TicketVibe_CheckingOrganizers (OrganizerID, CompanyName, Password, FirstName, LastName, Email, Phone, RoleID)
        VALUES (max_OrganizerID, CompanyName_in, Password_in, FirstName_in, LastName_in, Email_in, Phone_in, 1002);
		COMMIT;

    Message_out := 'Registration is completed, expect your account to be reviewed by managers';
    EXCEPTION
    WHEN Ex_Invalid_CompanyName_Max THEN
        Message_out := 'Company Name exceeds maximum length 40';
    WHEN Ex_Invalid_CompanyName_Min THEN
        Message_out := 'Company Name less than minimum length 5';
    WHEN Ex_Invalid_CompanyName_Exist THEN
        Message_out := 'The organizer or user with the specified Company Name already exist';
    WHEN Ex_Invalid_Password_Max THEN
        Message_out := 'Password exceeds maximum length 30';
    WHEN Ex_Invalid_Password_Min THEN
        Message_out := 'Password less than minimum length 5';
    WHEN Ex_Invalid_FirstName_Max THEN
        Message_out := 'First name exceeds maximum length 20';
    WHEN Ex_Invalid_FirstName_Min THEN
        Message_out := 'First name less than minimum length 2';
    WHEN Ex_Invalid_LastName_Max THEN
        Message_out := 'Last name exceeds maximum length 25';
    WHEN Ex_Invalid_LastName_Min THEN
        Message_out := 'Last name less than minimum length 2';
    WHEN Ex_Invalid_Email_Max THEN
        Message_out := 'Email exceeds maximum length 50';
    WHEN Ex_Invalid_Email_Min THEN
        Message_out := 'Email less than minimum length 5';
	WHEN Ex_Invalid_Email_Reg THEN
        Message_out := 'The email must be in the format email@gmail.com';
    WHEN Ex_Invalid_Email_Exist THEN
        Message_out := 'The user with the specified Email already exist';
    WHEN Ex_Invalid_Phone_Max THEN
        Message_out := 'Phone number exceeds maximum length 30';
    WHEN Ex_Invalid_Phone_Min THEN
        Message_out := 'Phone less than minimum length 8';
    WHEN Ex_Invalid_Phone_Reg THEN
        Message_out := 'The phone must be in the format +375 29 111 22 33';
    WHEN OTHERS THEN
        Message_out := 'Error during organizer registration';
END;

//////////////////////////////////////////

PROCEDURE SearchInCatalog(
    SearchEventName_in IN NVARCHAR2 DEFAULT NULL,
    cursor_out OUT SYS_REFCURSOR,
    Message_out OUT NVARCHAR2
)
IS
BEGIN    
    OPEN cursor_out FOR
    SELECT * FROM TicketVibe_EventsSchedule es
	LEFT JOIN TicketVibe_Events e ON es.EventID = e.EventID
	LEFT JOIN TicketVibe_Locations l ON e.LocationID = l.LocationID
	LEFT JOIN TicketVibe_Subcategories s ON e.SubcategoryID = s.SubcategoryID
	LEFT JOIN TicketVibe_Categories c ON s.CategoryID = c.CategoryID
    WHERE (SearchEventName_in IS NULL OR e.EventName LIKE '%' || SearchEventName_in || '%')
    ORDER BY EventDate ASC;

EXCEPTION
    WHEN OTHERS THEN
        Message_out := 'Error during user event creation: ' || SQLERRM || ' Stack Trace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
END;

/////////////////////////////////////////

PROCEDURE SelectFromCategories (
    Cursor_out OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN Cursor_out FOR
    SELECT * FROM TicketVibe_Categories;
END;

///////////////////////////////////////////

PROCEDURE SelectFromCheckingOrganizers (
    Cursor_out OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN Cursor_out FOR
    SELECT * FROM TicketVibe_CheckingOrganizers;
END;

///////////////////////////////////////////

PROCEDURE SelectFromLocations (
    Cursor_out OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN Cursor_out FOR
    SELECT * FROM TicketVibe_Locations;
END;

/////////////////////////////////////////

PROCEDURE SelectFromSectorRows (
    Cursor_out OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN Cursor_out FOR
    SELECT * FROM TicketVibe_SectorRows;
END;

///////////////////////////////////////////

PROCEDURE SelectFromSubcategories (
    Cursor_out OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN Cursor_out FOR
    SELECT * FROM TicketVibe_Subcategories;
END;

////////////////////////////////////////

PROCEDURE ShowAllComments (
    result OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN result FOR SELECT * FROM TicketVibe_Comments;
END;

/////////////////////////////////////

CREATE OR REPLACE PROCEDURE ShowAllEvents (
    result OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN result FOR SELECT * FROM TicketVibe_Events;
END;

///////////////////////////////////////

CREATE OR REPLACE PROCEDURE ShowAllEventsSchedule (
    result OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN result FOR SELECT * FROM TicketVibe_EventsSchedule;
END;

////////////////////////////////////////

PROCEDURE ShowCatalog(
    timestamp_start_date IN TIMESTAMP := NULL,
    timestamp_end_date IN TIMESTAMP := NULL,
    min_price_in IN NUMBER DEFAULT NULL,
    max_price_in IN NUMBER DEFAULT NULL,
    sorttype_in IN NUMBER DEFAULT 0,
    sortorder_in IN NUMBER DEFAULT 0,
    cursor_out OUT SYS_REFCURSOR,
    Message_out OUT NVARCHAR2,
	location_in IN NVARCHAR2 DEFAULT NULL,
    category_in IN NVARCHAR2 DEFAULT NULL,
    subcategory_in IN NVARCHAR2 DEFAULT NULL
)
IS
    LocationID_f NUMBER;
    CategoryID_f NUMBER;
    SubcategoryID_f NUMBER;
BEGIN    
	IF location_in IS NOT NULL THEN
		SELECT LocationID INTO LocationID_f FROM TicketVibe_Locations WHERE LocationName = location_in;
	END IF;
	IF category_in IS NOT NULL THEN
		SELECT CategoryID INTO CategoryID_f FROM TicketVibe_Categories WHERE CategoryName = category_in;
	END IF;
	IF subcategory_in IS NOT NULL THEN
		SELECT SubcategoryID INTO SubcategoryID_f FROM TicketVibe_Subcategories WHERE SubcategoryName = subcategory_in;
	END IF;

    IF (sorttype_in = 0) THEN
    OPEN cursor_out FOR
    SELECT * FROM TicketVibe_EventsSchedule es
	LEFT JOIN TicketVibe_Events e ON es.EventID = e.EventID
	LEFT JOIN TicketVibe_Locations l ON e.LocationID = l.LocationID
	LEFT JOIN TicketVibe_Subcategories s ON e.SubcategoryID = s.SubcategoryID
	LEFT JOIN TicketVibe_Categories c ON s.CategoryID = c.CategoryID
        WHERE (timestamp_start_date IS NULL OR es.EventDate >= timestamp_start_date)
        AND (timestamp_end_date IS NULL OR es.EventDate <= timestamp_end_date)
        AND (location_in IS NULL OR e.LocationID = LocationID_f)
        AND (category_in IS NULL OR EXISTS (
            SELECT 1
            FROM TicketVibe_Subcategories s
            JOIN TicketVibe_Categories c ON s.CategoryID = c.CategoryID
            WHERE  c.CategoryID = CategoryID_f))
        AND (subcategory_in IS NULL OR e.SubcategoryID = SubcategoryID_f)
        AND (min_price_in IS NULL OR e.Cost >= min_price_in) 
        AND (max_price_in IS NULL OR e.Cost <= max_price_in)
        ORDER BY 
            CASE 
                WHEN sortorder_in = 0 THEN EventDate END ASC,
            CASE 
                WHEN sortorder_in = 1 THEN EventDate END DESC;
    END IF;
    IF (sorttype_in = 1) THEN
    OPEN cursor_out FOR
    SELECT * FROM TicketVibe_EventsSchedule es
	LEFT JOIN TicketVibe_Events e ON es.EventID = e.EventID
	LEFT JOIN TicketVibe_Locations l ON e.LocationID = l.LocationID
	LEFT JOIN TicketVibe_Subcategories s ON e.SubcategoryID = s.SubcategoryID
	LEFT JOIN TicketVibe_Categories c ON s.CategoryID = c.CategoryID
        WHERE (timestamp_start_date IS NULL OR es.EventDate >= timestamp_start_date)
        AND (timestamp_end_date IS NULL OR es.EventDate <= timestamp_end_date)
        AND (location_in IS NULL OR e.LocationID = LocationID_f)
        AND (category_in IS NULL OR EXISTS (
            SELECT 1
            FROM TicketVibe_Subcategories s
            JOIN TicketVibe_Categories c ON s.CategoryID = c.CategoryID
            WHERE  c.CategoryID = CategoryID_f))
        AND (subcategory_in IS NULL OR e.SubcategoryID = SubcategoryID_f)
        AND (min_price_in IS NULL OR e.Cost >= min_price_in) 
        AND (max_price_in IS NULL OR e.Cost <= max_price_in)
        ORDER BY 
            CASE 
                WHEN sortorder_in = 0 THEN Cost END ASC,
            CASE 
                WHEN sortorder_in = 1 THEN Cost END DESC;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
        Message_out := 'Error during catalog showing';
END;

//////////////////////////////////////////

PROCEDURE ShowComments (
    EventScheduleID_in IN NUMBER,
    Message_out OUT NVARCHAR2,
    result OUT SYS_REFCURSOR
)
IS
    EventID_f NUMBER;
BEGIN
    SELECT EventID INTO EventID_f FROM TicketVibe_EventsSchedule WHERE EventScheduleID = EventScheduleID_in;

        OPEN result FOR
        SELECT u.Login, c.CommentText, c.CommentDate, c.FivePointRating
        FROM TicketVibe_Comments c
        INNER JOIN TicketVibe_Users u ON c.UserID = u.UserID
        WHERE c.EventID = EventID_f;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    Message_out := 'Data was not found during displaying comments';
    WHEN OTHERS THEN
    Message_out := 'Error not found during displaying comments';
END;

//////////////////////////////////////////

PROCEDURE ShowEventByEventScheduleID (
    EventScheduleID_in IN NUMBER,
    Message_out OUT NVARCHAR2,
    result OUT SYS_REFCURSOR
)
IS
    EventID_f NUMBER;
BEGIN
    SELECT EventID INTO EventID_f FROM TicketVibe_EventsSchedule WHERE EventScheduleID = EventScheduleID_in;

        OPEN result FOR
        SELECT e.EventName, l.LocationName, c.CategoryName, sc.SubcategoryName, o.CompanyName, e.Description, e.Cost
        FROM TicketVibe_Events e
        INNER JOIN TicketVibe_Locations l ON e.LocationID = l.LocationID
        INNER JOIN TicketVibe_Subcategories sc ON e.SubcategoryID = sc.SubcategoryID
        INNER JOIN TicketVibe_Categories c ON sc.CategoryID = c.CategoryID
        INNER JOIN TicketVibe_Organizers o ON e.OrganizerID = o.OrganizerID
        WHERE e.EventID = EventID_f;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    Message_out := 'Data was not found during displaying the event';
    WHEN OTHERS THEN
    Message_out := 'Error not found during displaying the event';
END;

///////////////////////////////////////

PROCEDURE ShowEventsSchedule (
    CompanyName_in IN NVARCHAR2,
    result OUT SYS_REFCURSOR,
    Message_out OUT NVARCHAR2
)
IS
    OrganizerID_f NUMBER;
BEGIN
    SELECT OrganizerID INTO OrganizerID_f FROM TicketVibe_Organizers WHERE CompanyName = CompanyName_in;
        OPEN result FOR
        SELECT *
        FROM TicketVibe_EventsSchedule es
        INNER JOIN TicketVibe_Events e ON es.EventID = e.EventID
        WHERE e.OrganizerID = OrganizerID_f;
EXCEPTION    
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found';    
    WHEN OTHERS THEN
        Message_out := 'Error during event showing';
END;

////////////////////////////

PROCEDURE ShowFullScheduleOfEventByEventScheduleID (
    EventScheduleID_in IN NUMBER,
    Message_out OUT NVARCHAR2,
    result OUT SYS_REFCURSOR
)
IS
    EventID_f NUMBER;
BEGIN
    SELECT EventID INTO EventID_f FROM TicketVibe_EventsSchedule WHERE EventScheduleID = EventScheduleID_in;

        OPEN result FOR
        SELECT EventScheduleID, EventDate
        FROM TicketVibe_EventsSchedule
        WHERE EventID = EventID_f;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    Message_out := 'Data was not found during displaying the event schedule';
    WHEN OTHERS THEN
    Message_out := 'Error not found during displaying the event schedule';
END;

//////////////////////////////////////

PROCEDURE ShowOrganizerBlock (
    result OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN result FOR SELECT * FROM TicketVibe_OrganizerBlocks;
END;

/////////////////////////////////////

PROCEDURE ShowOrganizerEvent (
    CompanyName_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2,
    result OUT SYS_REFCURSOR
)
IS
    OrganizerID_f NUMBER;
	Ex_Invalid_Organizer_Exist EXCEPTION;
BEGIN

    SELECT OrganizerID INTO OrganizerID_f FROM TicketVibe_Organizers WHERE CompanyName = CompanyName_in;
    IF OrganizerID_f < 1 OR LENGTH(CompanyName_in) < 4 THEN
        RAISE Ex_Invalid_Organizer_Exist;
    END IF;
        OPEN result FOR SELECT * FROM TicketVibe_Events WHERE OrganizerID = OrganizerID_f;
EXCEPTION
	WHEN Ex_Invalid_Organizer_Exist THEN
        Message_out := 'OrganizerID is incorrect';    
	WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during showing organizer event';    
	WHEN OTHERS THEN
        Message_out := 'Error during showing organizer event';    
END;

///////////////////////////

PROCEDURE ShowOrganizerQuestion (
    CompanyName_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2,
    result OUT SYS_REFCURSOR
)
IS
    OrganizerID_f NUMBER;
	Ex_Invalid_Organizer_Exist EXCEPTION;
BEGIN

    SELECT OrganizerID INTO OrganizerID_f FROM TicketVibe_Organizers WHERE CompanyName = CompanyName_in;
    IF OrganizerID_f < 1 OR LENGTH(CompanyName_in) < 4 THEN
        RAISE Ex_Invalid_Organizer_Exist;
    END IF;
        OPEN result FOR SELECT * FROM TicketVibe_OrganizerQuestions WHERE OrganizerID = OrganizerID_f;
EXCEPTION
	WHEN Ex_Invalid_Organizer_Exist THEN
        Message_out := 'OrganizerID is incorrect';    
	WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during showing organizer question';    
	WHEN OTHERS THEN
        Message_out := 'Error during showing organizer question';    
END;

//////////////////////////////

PROCEDURE ShowOrganizerQuestionForManager (
    Login_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2,
    result OUT SYS_REFCURSOR
)
IS
    ManagerID_f NUMBER;
BEGIN
    SELECT ManagerID INTO ManagerID_f FROM TicketVibe_Managers WHERE Login = Login_in;
    OPEN result FOR SELECT * FROM TicketVibe_OrganizerQuestions WHERE ManagerID = ManagerID_f;
EXCEPTION
    WHEN NO_DATA_FOUND THEN 
        Message_out := 'Data was not found during showing organizer questions';
    WHEN OTHERS THEN
        Message_out := 'Error during showing organizer questions';
END;

///////////////////////////////////

PROCEDURE ShowRefund (
    result OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN result FOR SELECT * FROM TicketVibe_TicketRefund;
END;

//////////////////////////////////////

PROCEDURE ShowShoppingCart (
    Login_in IN NVARCHAR2,
    result OUT SYS_REFCURSOR
)
IS
    UserID_f NUMBER;
BEGIN
    SELECT UserID INTO UserID_f FROM TicketVibe_Users WHERE Login = Login_in;

        OPEN result FOR
        SELECT sc.TicketID, t.PlaceInRow, t.Price, sr.SectorRow, e.EventName
        FROM TicketVibe_ShoppingCart sc
        INNER JOIN TicketVibe_Tickets t ON sc.TicketID = t.TicketID
        INNER JOIN TicketVibe_SectorRows sr ON sr.SectorRowID = t.SectorRowID
        INNER JOIN TicketVibe_EventsSchedule es ON es.EventScheduleID = t.EventScheduleID
		INNER JOIN TicketVibe_Events e ON es.EventID = e.EventID
        WHERE sc.UserID = UserID_f;
END;

//////////////////////////////////////////

PROCEDURE ShowUserBlock (
    result OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN result FOR SELECT * FROM TicketVibe_UserBlocks;
END;

///////////////////////////////////////////

PROCEDURE ShowUserQuestion (
    Login_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2,
    result OUT SYS_REFCURSOR
)
IS
    UserID_f NUMBER;
    Ex_Invalid_UserID_Exist EXCEPTION;
BEGIN
    SELECT UserID INTO UserID_f FROM TicketVibe_Users WHERE Login = Login_in;
    IF UserID_f < 999 THEN
        RAISE Ex_Invalid_UserID_Exist;
    END IF;
        OPEN result FOR SELECT * FROM TicketVibe_UserQuestions WHERE UserID = UserID_f;
EXCEPTION
    WHEN Ex_Invalid_UserID_Exist THEN
        Message_out := 'User ID is incorrect';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during showing user questions';
    WHEN OTHERS THEN
        Message_out := 'Error during user question showing';
END;

///////////////////////////////////////////

PROCEDURE ShowUserQuestionForManager (
    Login_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2,
    result OUT SYS_REFCURSOR
)
IS
    ManagerID_f NUMBER;
BEGIN
    SELECT ManagerID INTO ManagerID_f FROM TicketVibe_Managers WHERE Login = Login_in;
    OPEN result FOR SELECT * FROM TicketVibe_UserQuestions WHERE ManagerID = ManagerID_f;
EXCEPTION
    WHEN NO_DATA_FOUND THEN 
        Message_out := 'Data was not found during showing organizer questions';
    WHEN OTHERS THEN
        Message_out := 'Error during showing organizer questions';
END;

//////////////////////////////////////////

PROCEDURE UpdateCategory (
    CategoryID_in IN NUMBER,
    CategoryName_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
)
IS
    CategoryID_exist NUMBER;
	Ex_Invalid_Category_Length EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO CategoryID_exist FROM TicketVibe_Categories WHERE CategoryID = CategoryID_in;
    IF LENGTH(CategoryName_in) < 3 THEN
        RAISE Ex_Invalid_Category_Length;
    END IF;
        UPDATE TicketVibe_Categories SET CategoryName = CategoryName_in WHERE CategoryID = CategoryID_in;
        Message_out := 'The category has been successfully updated';
		COMMIT;
EXCEPTION
	WHEN Ex_Invalid_Category_Length THEN
        Message_out := 'Category Name is incorrect';    
	WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found during category updating';    
	WHEN OTHERS THEN
        Message_out := 'Error during category updating';    
END;

///////////////////////////////////////

PROCEDURE UpdateEvent (
    Number_EventID IN NUMBER,
    EventName_in IN NVARCHAR2,
    EventDuration_in IN NVARCHAR2,
    Number_SubcategoryID IN NUMBER,
    OrganizerCompany_in IN NVARCHAR2,
    Description_in IN NVARCHAR2,
	Number_Cost IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
	interval_EventDuration INTERVAL DAY TO SECOND;
    OrganizerID_f NUMBER;
    max_EventID NUMBER;
    EventName_exists NUMBER;
    EventID_exists NUMBER;
    SubcategoryID_exists NUMBER;
    OrganizerID_exists NUMBER;
    Ex_Invalid_EventName_Max EXCEPTION;
    Ex_Invalid_EventName_Min EXCEPTION;
    Ex_Invalid_EventName_Exist EXCEPTION;
    Ex_Invalid_EventDuration_Max EXCEPTION;
    Ex_Invalid_EventDuration_Min EXCEPTION;
    Ex_Invalid_OrganizerID_Exist EXCEPTION;
    Ex_Invalid_Subcategory_Exist EXCEPTION;
    Ex_Invalid_SubcategoryID_Exist EXCEPTION;
    Ex_Invalid_TimeStamp EXCEPTION;
    Ex_Invalid_Interval EXCEPTION;
    Ex_Invalid_EventID_Exist EXCEPTION;

BEGIN

    SELECT OrganizerID INTO OrganizerID_f FROM TicketVibe_Organizers WHERE CompanyName = OrganizerCompany_in;
    SELECT NVL(MAX(EventID) + 1, 1000) INTO max_EventID FROM TicketVibe_Events;

    SELECT COUNT(*) INTO EventName_exists FROM TicketVibe_Events WHERE EventName = EventName_in;
    SELECT COUNT(*) INTO EventID_exists FROM TicketVibe_Events WHERE EventID = Number_EventID;
    SELECT COUNT(*) INTO SubcategoryID_exists FROM TicketVibe_Subcategories WHERE SubcategoryID = Number_SubcategoryID;
    SELECT COUNT(*) INTO OrganizerID_exists FROM TicketVibe_Organizers WHERE OrganizerID = OrganizerID_f;

    IF EventID_exists < 1 THEN
        RAISE Ex_Invalid_EventID_Exist;
    END IF;

    IF LENGTH(EventName_in) > 50 THEN
        RAISE Ex_Invalid_EventName_Max;
    END IF;
    IF  EventName_in IS NULL OR LENGTH(EventName_in) < 4 THEN
        RAISE Ex_Invalid_EventName_Min;
    END IF;
    IF EventName_exists > 1 THEN
        RAISE Ex_Invalid_EventName_Exist;
    END IF;

    IF interval_EventDuration < INTERVAL '0 00:15:00' DAY TO SECOND THEN
        RAISE Ex_Invalid_EventDuration_Min;
    END IF;
    IF interval_EventDuration > INTERVAL '1 00:00:00' DAY TO SECOND THEN
        RAISE Ex_Invalid_EventDuration_Max;
    END IF;

    IF SubcategoryID_exists < 1 THEN
        RAISE Ex_Invalid_SubcategoryID_Exist;
    END IF;

    IF OrganizerID_exists < 1 THEN
        RAISE Ex_Invalid_OrganizerID_Exist;
    END IF;

    IF (LENGTH(Description_in) < 3) THEN
        UPDATE TicketVibe_Events SET EventName = EventName_in,
            EventDuration = interval_EventDuration, SubcategoryID = Number_SubcategoryID, OrganizerID = OrganizerID_f, Cost = Number_Cost
			WHERE EventID = Number_EventID;
		COMMIT;
    END IF;
    IF (LENGTH(Description_in) > 2) THEN
        UPDATE TicketVibe_Events SET EventName = EventName_in, EventDuration = interval_EventDuration,
            SubcategoryID = Number_SubcategoryID, OrganizerID = OrganizerID_f, Cost = Number_Cost, Description = Description_in
			WHERE EventID = Number_EventID;
        COMMIT;
    END IF;

    Message_out := 'The event is updated';

    EXCEPTION
    WHEN Ex_Invalid_EventName_Max THEN
        Message_out := 'Event Name exceeds maximum length 50';
        RETURN;
    WHEN Ex_Invalid_EventName_Min THEN
        Message_out := 'Event Name less than minimum length 4';
        RETURN;
    WHEN Ex_Invalid_EventName_Exist THEN
        Message_out := 'The event with the specified Event Name already exist';
    WHEN Ex_Invalid_EventID_Exist THEN
        Message_out := 'There is no Event with this ID';
    WHEN Ex_Invalid_EventDuration_Min THEN
        Message_out := 'Event Duration less than minimum: 15 minutes';
    WHEN Ex_Invalid_EventDuration_Max THEN
        Message_out := 'Event Duration exceeds maximum: one day';
    WHEN Ex_Invalid_SubcategoryID_Exist THEN
        Message_out := 'There is no Subcategory with this ID';
    WHEN Ex_Invalid_OrganizerID_Exist THEN
        Message_out := 'There is no Organizer with this ID';
	WHEN Ex_Invalid_TimeStamp THEN
        Message_out := 'The date is entered in the format YYYY-MM-DD HH24:MI';
	WHEN Ex_Invalid_Interval THEN
        Message_out := 'The interval is entered in the format 3 10:25:30';
    WHEN OTHERS THEN
        Message_out := 'Error during event update';
END;

//////////////////////////////

CREATE OR REPLACE PROCEDURE UpdateEventByManager (
    Number_EventID IN NUMBER,
    EventName_in IN NVARCHAR2,
    EventDuration_in IN NVARCHAR2,
    Number_SubcategoryID IN NUMBER,
    Description_in IN NVARCHAR2,
	Number_Cost IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
	interval_EventDuration INTERVAL DAY TO SECOND;
    max_EventID NUMBER;
    EventName_exists NUMBER;
    EventID_exists NUMBER;
    SubcategoryID_exists NUMBER;
    Ex_Invalid_EventName_Max EXCEPTION;
    Ex_Invalid_EventName_Min EXCEPTION;
    Ex_Invalid_EventName_Exist EXCEPTION;
    Ex_Invalid_EventDuration_Max EXCEPTION;
    Ex_Invalid_EventDuration_Min EXCEPTION;
    Ex_Invalid_Subcategory_Exist EXCEPTION;
    Ex_Invalid_SubcategoryID_Exist EXCEPTION;
    Ex_Invalid_TimeStamp EXCEPTION;
    Ex_Invalid_Interval EXCEPTION;
    Ex_Invalid_EventID_Exist EXCEPTION;

BEGIN

    SELECT NVL(MAX(EventID) + 1, 1000) INTO max_EventID FROM TicketVibe_Events;

    SELECT COUNT(*) INTO EventName_exists FROM TicketVibe_Events WHERE EventName = EventName_in;
    SELECT COUNT(*) INTO EventID_exists FROM TicketVibe_Events WHERE EventID = Number_EventID;
    SELECT COUNT(*) INTO SubcategoryID_exists FROM TicketVibe_Subcategories WHERE SubcategoryID = Number_SubcategoryID;

    IF EventID_exists < 1 THEN
        RAISE Ex_Invalid_EventID_Exist;
    END IF;

    IF LENGTH(EventName_in) > 50 THEN
        RAISE Ex_Invalid_EventName_Max;
    END IF;
    IF  EventName_in IS NULL OR LENGTH(EventName_in) < 4 THEN
        RAISE Ex_Invalid_EventName_Min;
    END IF;
    IF EventName_exists > 1 THEN
        RAISE Ex_Invalid_EventName_Exist;
    END IF;

    IF interval_EventDuration < INTERVAL '0 00:15:00' DAY TO SECOND THEN
        RAISE Ex_Invalid_EventDuration_Min;
    END IF;
    IF interval_EventDuration > INTERVAL '1 00:00:00' DAY TO SECOND THEN
        RAISE Ex_Invalid_EventDuration_Max;
    END IF;

    IF SubcategoryID_exists < 1 THEN
        RAISE Ex_Invalid_SubcategoryID_Exist;
    END IF;

    IF (LENGTH(Description_in) < 3) THEN
        UPDATE TicketVibe_Events SET EventName = EventName_in,
            EventDuration = interval_EventDuration, SubcategoryID = Number_SubcategoryID, Cost = Number_Cost
			WHERE EventID = Number_EventID;
		COMMIT;
    END IF;
    IF (LENGTH(Description_in) > 2) THEN
        UPDATE TicketVibe_Events SET EventName = EventName_in, EventDuration = interval_EventDuration,
            SubcategoryID = Number_SubcategoryID, Cost = Number_Cost, Description = Description_in
			WHERE EventID = Number_EventID;
        COMMIT;
    END IF;

    Message_out := 'The event is updated';

    EXCEPTION
    WHEN Ex_Invalid_EventName_Max THEN
        Message_out := 'Event Name exceeds maximum length 50';
        RETURN;
    WHEN Ex_Invalid_EventName_Min THEN
        Message_out := 'Event Name less than minimum length 4';
        RETURN;
    WHEN Ex_Invalid_EventName_Exist THEN
        Message_out := 'The event with the specified Event Name already exist';
    WHEN Ex_Invalid_EventID_Exist THEN
        Message_out := 'There is no Event with this ID';
    WHEN Ex_Invalid_EventDuration_Min THEN
        Message_out := 'Event Duration less than minimum: 15 minutes';
    WHEN Ex_Invalid_EventDuration_Max THEN
        Message_out := 'Event Duration exceeds maximum: one day';
    WHEN Ex_Invalid_SubcategoryID_Exist THEN
        Message_out := 'There is no Subcategory with this ID';
	WHEN Ex_Invalid_TimeStamp THEN
        Message_out := 'The date is entered in the format YYYY-MM-DD HH24:MI';
	WHEN Ex_Invalid_Interval THEN
        Message_out := 'The interval is entered in the format 3 10:25:30';
    WHEN OTHERS THEN
        Message_out := 'Error during event update';
END;

/////////////////////////////////

PROCEDURE UpdateEventSchedule (
    EventScheduleID_in IN NUMBER,
    EventDate_in IN TIMESTAMP,
    Message_out OUT NVARCHAR2
)
IS
    tomorrow TIMESTAMP;
    next_year TIMESTAMP;
	v_overlap_count NUMBER;
	EventID_f NUMBER;
	v_event_start TIMESTAMP;
	v_event_end TIMESTAMP;
	v_eventDuration INTERVAL DAY TO SECOND;
    Ex_Invalid_EventDate_Max EXCEPTION;
    Ex_Invalid_EventDate_Min EXCEPTION;
	Ex_Invalid_EventDate_Interval EXCEPTION;
BEGIN
    tomorrow := TRUNC(SYSDATE) + 1;
    next_year := ADD_MONTHS(TRUNC(SYSDATE), 12);

	SELECT EventID INTO EventID_f FROM TicketVibe_EventsSchedule WHERE EventScheduleID = EventScheduleID_in;
	SELECT EventDuration INTO v_eventDuration FROM TicketVibe_Events WHERE EventID = EventID_f;

    IF EventDate_in IS NULL OR EventDate_in < tomorrow THEN
        RAISE Ex_Invalid_EventDate_Min;
    END IF;
    IF  EventDate_in > next_year THEN
        RAISE Ex_Invalid_EventDate_Max;
    END IF;

	v_event_start := EventDate_in;
	v_event_end := EventDate_in + v_eventDuration;
	
	SELECT COUNT(*)
    INTO v_overlap_count
    FROM TicketVibe_EventsSchedule es
    JOIN TicketVibe_Events e ON es.EventID = e.EventID
    WHERE e.LocationID = (SELECT LocationID FROM TicketVibe_Events WHERE EventID = EventID_f)
    AND ((v_event_start <= es.EventDate AND v_event_end > es.EventDate)
         OR (v_event_start < es.EventDate + e.EventDuration AND v_event_end >= es.EventDate + e.EventDuration)
		 OR (v_event_start < es.EventDate AND v_event_end >= es.EventDate + e.EventDuration));

    IF v_overlap_count > 0 THEN
		RAISE Ex_Invalid_EventDate_Interval;
	END IF;

    UPDATE TicketVibe_EventsSchedule SET EventDate = EventDate_in WHERE EventScheduleID = EventScheduleID_in;
	Message_out := 'Success';  
	COMMIT;
EXCEPTION    
    WHEN Ex_Invalid_EventDate_Max THEN
        Message_out := 'Event Date exceeds maximum date: year later';
    WHEN Ex_Invalid_EventDate_Min THEN
        Message_out := 'Event Date less than minimum date: tomorrow';
    WHEN Ex_Invalid_EventDate_Interval THEN
        Message_out := 'Location is busy at this time';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found';  
    WHEN OTHERS THEN
        Message_out := 'Error during event updating';
END;

////////////////////////////////////////

CREATE OR REPLACE PROCEDURE UpdateEventScheduleByManager (
    EventScheduleID_in IN NUMBER,
    EventDate_in IN TIMESTAMP,
    Message_out OUT NVARCHAR2
)
IS
    tomorrow TIMESTAMP;
    next_year TIMESTAMP;
	v_overlap_count NUMBER;
	EventID_f NUMBER;
	v_event_start TIMESTAMP;
	v_event_end TIMESTAMP;
	v_eventDuration INTERVAL DAY TO SECOND;
    Ex_Invalid_EventDate_Max EXCEPTION;
    Ex_Invalid_EventDate_Min EXCEPTION;
    Ex_Invalid_OrganizerID_Exist EXCEPTION;
	Ex_Invalid_EventDate_Interval EXCEPTION;
BEGIN
    tomorrow := TRUNC(SYSDATE) + 1;
    next_year := ADD_MONTHS(TRUNC(SYSDATE), 12);

	SELECT EventID INTO EventID_f FROM TicketVibe_EventsSchedule WHERE EventScheduleID = EventScheduleID_in;
	SELECT EventDuration INTO v_eventDuration FROM TicketVibe_Events WHERE EventID = EventID_f;

    IF EventDate_in IS NULL OR EventDate_in < tomorrow THEN
        RAISE Ex_Invalid_EventDate_Min;
    END IF;
    IF  EventDate_in > next_year THEN
        RAISE Ex_Invalid_EventDate_Max;
    END IF;

	v_event_start := EventDate_in;
	v_event_end := EventDate_in + v_eventDuration;
	
	SELECT COUNT(*)
    INTO v_overlap_count
    FROM TicketVibe_EventsSchedule es
    JOIN TicketVibe_Events e ON es.EventID = e.EventID
    WHERE e.LocationID = (SELECT LocationID FROM TicketVibe_Events WHERE EventID = EventID_f)
    AND ((v_event_start <= es.EventDate AND v_event_end > es.EventDate)
         OR (v_event_start < es.EventDate + e.EventDuration AND v_event_end >= es.EventDate + e.EventDuration)
		 OR (v_event_start < es.EventDate AND v_event_end >= es.EventDate + e.EventDuration));

    IF v_overlap_count > 0 THEN
		RAISE Ex_Invalid_EventDate_Interval;
	END IF;

    UPDATE TicketVibe_EventsSchedule SET EventDate = EventDate_in WHERE EventScheduleID = EventScheduleID_in;
	Message_out := 'Success';  
	COMMIT;
EXCEPTION    
    WHEN Ex_Invalid_EventDate_Max THEN
        Message_out := 'Event Date exceeds maximum date: year later';
    WHEN Ex_Invalid_EventDate_Min THEN
        Message_out := 'Event Date less than minimum date: tomorrow';
    WHEN Ex_Invalid_EventDate_Interval THEN
        Message_out := 'Location is busy at this time';
    WHEN NO_DATA_FOUND THEN
        Message_out := 'Data was not found';  
    WHEN OTHERS THEN
        Message_out := 'Error during event updating';
END;

///////////////////////////////////////

PROCEDURE UpdateLocation (
    LocationID_in IN NUMBER,
    NumberOfSectors_in IN NUMBER,
    LocationName_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
)
IS
    LocationID_exist NUMBER;
	Ex_Invalid_Location_Name EXCEPTION;
	Ex_Invalid_NumberOfRows EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO LocationID_exist FROM TicketVibe_Locations WHERE LocationID = LocationID_in;
    IF LENGTH(LocationName_in) < 3 THEN
        RAISE Ex_Invalid_Location_Name;  
    END IF;
    IF NumberOfSectors_in < 1 THEN
        RAISE Ex_Invalid_NumberOfRows;  
    END IF;
        UPDATE TicketVibe_Locations SET LocationName = LocationName_in, NumberOfSectors = NumberOfSectors_in WHERE LocationID = LocationID_in;
        Message_out := 'The location has been successfully updated';
		COMMIT;
EXCEPTION
	WHEN Ex_Invalid_Location_Name THEN
        Message_out := 'Location Name is incorrect';    
	WHEN Ex_Invalid_NumberOfRows THEN
        Message_out := 'Number of rows is incorrect';    
    WHEN NO_DATA_FOUND THEN 
        Message_out := 'Data was not found during location update';
    WHEN OTHERS THEN
        Message_out := 'Error during location update';
END;

////////////////////////////////////////

PROCEDURE UpdateRow (
    Number_SectorRowID IN NVARCHAR2,
    Number_NumberOfSeats IN NVARCHAR2,
	Number_CostFactor IN NVARCHAR2,
    Message_out OUT NVARCHAR2
)
IS
    SectorRowID_exist NUMBER;
	Ex_Invalid_RowID EXCEPTION;
	Ex_Invalid_Values EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO SectorRowID_exist FROM TicketVibe_SectorRows WHERE SectorRowID = Number_SectorRowID;

	IF SectorRowID_exist < 1 THEN
        RAISE Ex_Invalid_RowID;
    END IF;

	IF Number_NumberOfSeats < 1 OR Number_NumberOfSeats > 500 OR Number_CostFactor < 1 OR Number_CostFactor > 50 THEN
        RAISE Ex_Invalid_Values;
	END IF;

	UPDATE TicketVibe_SectorRows SET NumberOfSeats = Number_NumberOfSeats, CostFactor = Number_CostFactor WHERE SectorRowID = Number_SectorRowID;
	Message_out := 'The row has been successfully updated';
	COMMIT;

EXCEPTION
	WHEN Ex_Invalid_RowID THEN
        Message_out := 'Row ID is incorrect';    
	WHEN Ex_Invalid_Values THEN
		Message_out := 'Invalid values were passed';
	WHEN NO_DATA_FOUND THEN
		Message_out := 'Data was not found during row update';
	WHEN OTHERS THEN
		Message_out := 'Error during row update';
END;

////////////////////////////////////////

PROCEDURE UpdateSubcategory (
    SubcategoryID_in IN NUMBER,
    SubcategoryName_in IN NVARCHAR2,
    CategoryID_in IN NUMBER,
    Message_out OUT NVARCHAR2
)
IS
    SubcategoryID_exist NUMBER;
    CategoryID_exist NUMBER;
    Subcategory_exist NUMBER;
	Ex_Invalid_Subcategory_Exist EXCEPTION;
	Ex_Invalid_SubcategoryID_Exist EXCEPTION;
	Ex_Invalid_CategotyID_Exist EXCEPTION;
	Ex_Invalid_Subcategory_Correct EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO SubcategoryID_exist FROM TicketVibe_Subcategories WHERE SubcategoryID = SubcategoryID_in;
    SELECT COUNT(*) INTO CategoryID_exist FROM TicketVibe_Categories WHERE CategoryID = CategoryID_in;

    SELECT COUNT(*) INTO Subcategory_exist FROM TicketVibe_Subcategories WHERE CategoryID = CategoryID_in 
		AND SubcategoryName = SubcategoryName_in;

	IF (Subcategory_exist > 1) THEN
		RAISE Ex_Invalid_Subcategory_Exist;
	END IF;
    IF SubcategoryID_exist < 1 THEN
		RAISE Ex_Invalid_SubcategoryID_Exist;
    END IF;
    IF CategoryID_exist < 1 THEN
		RAISE Ex_Invalid_CategotyID_Exist;
    END IF;
    IF LENGTH(SubcategoryName_in) < 3 THEN
		RAISE Ex_Invalid_Subcategory_Correct;
    END IF;
    UPDATE TicketVibe_Subcategories SET SubcategoryName = SubcategoryName_in, CategoryID = CategoryID_in 
		WHERE SubcategoryID = SubcategoryID_in;
	Message_out := 'The subcategory has been successfully updated';
	COMMIT;
EXCEPTION
	WHEN Ex_Invalid_Subcategory_Exist THEN
        Message_out := 'This category already has such a subcategory';	
	WHEN Ex_Invalid_SubcategoryID_Exist THEN
        Message_out := 'Subcategory ID is incorrect';	
	WHEN Ex_Invalid_CategotyID_Exist THEN
        Message_out := 'Category ID is incorrect';	
	WHEN Ex_Invalid_Subcategory_Correct THEN
        Message_out := 'Subcategory Name is incorrect';	
    WHEN NO_DATA_FOUND THEN 
        Message_out := 'Data was not found during subcategory update';
    WHEN OTHERS THEN
        Message_out := 'Error during subcategory update';
END;

//////////////////////////////////////////

PROCEDURE UserRegistration (
    Login_in IN NVARCHAR2,
    Password_in IN NVARCHAR2,
    FirstName_in IN NVARCHAR2,
    LastName_in IN NVARCHAR2,
    Email_in IN NVARCHAR2,
    Phone_in IN NVARCHAR2,
    Message_out OUT NVARCHAR2
)
IS
    max_UserID NUMBER;
    CompanyName_exists NUMBER;
    UserLogin_exists NUMBER;
    ManagerLogin_exists NUMBER;
	CheckingCompanyName_exists NUMBER;
    Email_exists NUMBER;
    Phone_exists NUMBER;
    Ex_Invalid_Login_Max EXCEPTION;
    Ex_Invalid_Login_Min EXCEPTION;
    Ex_Invalid_Login_Exist EXCEPTION;
    Ex_Invalid_Password_Max EXCEPTION;
    Ex_Invalid_Password_Min EXCEPTION;
    Ex_Invalid_FirstName_Max EXCEPTION;
    Ex_Invalid_FirstName_Min EXCEPTION;
    Ex_Invalid_LastName_Max EXCEPTION;
    Ex_Invalid_LastName_Min EXCEPTION;
    Ex_Invalid_Email_Max EXCEPTION;
    Ex_Invalid_Email_Min EXCEPTION;
    Ex_Invalid_Email_Exist EXCEPTION;
    Ex_Invalid_Email_Reg EXCEPTION;
    Ex_Invalid_Phone_Max EXCEPTION;
    Ex_Invalid_Phone_Min EXCEPTION;
    Ex_Invalid_Phone_Exist EXCEPTION;
    Ex_Invalid_Phone_Reg EXCEPTION;

BEGIN
    SELECT NVL(MAX(UserID) + 1, 1000) INTO max_UserID FROM TicketVibe_Users;

	SELECT COUNT(*) INTO CompanyName_exists FROM TicketVibe_Organizers WHERE CompanyName = Login_in;
	SELECT COUNT(*) INTO UserLogin_exists FROM TicketVibe_Users WHERE Login = Login_in;
	SELECT COUNT(*) INTO CheckingCompanyName_exists FROM TicketVibe_CheckingOrganizers WHERE CompanyName = Login_in;
    SELECT COUNT(*) INTO ManagerLogin_exists FROM TicketVibe_Managers WHERE Login = Login_in;

    SELECT COUNT(*) INTO Email_exists FROM TicketVibe_Users WHERE Email = Email_in;
    SELECT COUNT(*) INTO Phone_exists FROM TicketVibe_Users WHERE Phone = Phone_in;

    IF LENGTH(Login_in) > 40 THEN
        RAISE Ex_Invalid_Login_Max;
    END IF;
    IF Login_in IS NULL OR LENGTH(Login_in) < 4 THEN
        RAISE Ex_Invalid_Login_Min;
    END IF;
    IF (CompanyName_exists + UserLogin_exists + ManagerLogin_exists + CheckingCompanyName_exists) > 0 THEN
        RAISE Ex_Invalid_Login_Exist;
    END IF;

    IF LENGTH(Password_in) > 30 THEN
        RAISE Ex_Invalid_Password_Max;
    END IF;
    IF Password_in IS NULL OR LENGTH(Password_in) < 5 THEN
        RAISE Ex_Invalid_Password_Min;
    END IF;

    IF LENGTH(FirstName_in) > 20 THEN
        RAISE Ex_Invalid_FirstName_Max;
    END IF;
    IF FirstName_in IS NULL OR LENGTH(FirstName_in) < 2 THEN
        RAISE Ex_Invalid_FirstName_Min;
    END IF;

    IF LENGTH(LastName_in) > 25 THEN
        RAISE Ex_Invalid_LastName_Max;
    END IF;
    IF LastName_in IS NULL OR LENGTH(LastName_in) < 2 THEN
        RAISE Ex_Invalid_LastName_Min;
    END IF;

    IF LENGTH(Email_in) > 50 THEN
        RAISE Ex_Invalid_Email_Max;
    END IF;
    IF Email_in IS NULL OR LENGTH(Email_in) < 5 THEN
        RAISE Ex_Invalid_Email_Min;
    END IF;
    IF Email_exists > 0 THEN
        RAISE Ex_Invalid_Email_Exist;
    END IF;
    IF NOT REGEXP_LIKE(Email_in, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE Ex_Invalid_Email_Reg;
    END IF;

    IF LENGTH(Phone_in) > 30 THEN
        RAISE Ex_Invalid_Phone_Max;
    END IF;
    IF Phone_in IS NULL OR LENGTH(Phone_in) < 8 THEN    
        RAISE Ex_Invalid_Phone_Min;
    END IF;
    IF Phone_exists > 0 THEN
        RAISE Ex_Invalid_Phone_Exist;
    END IF;
    IF NOT REGEXP_LIKE(Phone_in, '^\+375\s(?:33|25|17|44|29)\s\d{3}\s\d{2}\s\d{2}$') THEN
        RAISE Ex_Invalid_Phone_Reg;
    END IF;

	    INSERT INTO TicketVibe_Users (UserID, Login, Password, FirstName, LastName, Email, Phone, RoleID)
        VALUES (max_UserID, Login_in, Password_in, FirstName_in, LastName_in, Email_in, Phone_in, 1000);
        EXECUTE IMMEDIATE 'CREATE USER C##' || Login_in || ' IDENTIFIED BY "' || Password_in || '"';
		EXECUTE IMMEDIATE 'GRANT UserRole TO C##' || Login_in;
        COMMIT;

    Message_out := 'The user has been successfully registered';
    EXCEPTION
    WHEN Ex_Invalid_Login_Max THEN
        Message_out := 'Login exceeds maximum length 40';
    WHEN Ex_Invalid_Login_Min THEN
        Message_out := 'Login less than minimum length 4';
    WHEN Ex_Invalid_Login_Exist THEN
        Message_out := 'The user with the specified Login already exist';
    WHEN Ex_Invalid_Password_Max THEN
        Message_out := 'Password exceeds maximum length 30';
    WHEN Ex_Invalid_Password_Min THEN
        Message_out := 'Password less than minimum length 5';
    WHEN Ex_Invalid_FirstName_Max THEN
        Message_out := 'First name exceeds maximum length 20';
    WHEN Ex_Invalid_FirstName_Min THEN
        Message_out := 'First name less than minimum length 2';
    WHEN Ex_Invalid_LastName_Max THEN
        Message_out := 'Last name exceeds maximum length 25';
    WHEN Ex_Invalid_LastName_Min THEN
        Message_out := 'Last name less than minimum length 2';
    WHEN Ex_Invalid_Email_Max THEN
        Message_out := 'Email exceeds maximum length 50';
    WHEN Ex_Invalid_Email_Min THEN
        Message_out := 'Email less than minimum length 5';
	WHEN Ex_Invalid_Email_Reg THEN
        Message_out := 'The email must be in the format email@gmail.com';
    WHEN Ex_Invalid_Email_Exist THEN
        Message_out := 'The user with the specified Email already exist';
    WHEN Ex_Invalid_Phone_Max THEN
        Message_out := 'Phone number exceeds maximum length 30';
    WHEN Ex_Invalid_Phone_Min THEN
        Message_out := 'Phone less than minimum length 8';
    WHEN Ex_Invalid_Phone_Reg THEN
        Message_out := 'The phone must be in the format +375 29 111 22 33';
    WHEN OTHERS THEN
        Message_out := 'Error during user registration';
END;

////////////

CREATE OR REPLACE PROCEDURE FailerLoginAttempts (
    Cursor_out OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN Cursor_out FOR
    SELECT username,
           terminal,
           timestamp
      FROM dba_audit_session
     WHERE returncode <> 0
     GROUP BY username, terminal, TO_CHAR(timestamp, 'dd/mm/yyyy');
END;

CREATE OR REPLACE PROCEDURE AuditTicketRefund (
    Cursor_out OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN Cursor_out FOR
    SELECT username, terminal, timestamp, action_name
        FROM dba_audit_trail
        WHERE action_name = 'INSERT'
        AND obj_name = 'TICKETREFUND';
END;


CREATE OR REPLACE PROCEDURE CreateEventAfterHours (
    Cursor_out OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN Cursor_out FOR
    SELECT username, terminal, timestamp, action_name
        FROM dba_audit_trail a
        WHERE action_name = 'EXECUTE PROCEDURE'
        AND ( obj_name = 'CREATEEVENTSCHEDULE' OR obj_name = 'CREATEEVENT')
      AND TO_NUMBER(TO_CHAR(a.timestamp, 'HH24')) NOT BETWEEN 8 AND 22;
END;


CREATE OR REPLACE PROCEDURE AuditEventDelete (
    Cursor_out OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN Cursor_out FOR
    SELECT username, terminal, timestamp, action_name
        FROM dba_audit_trail
        WHERE action_name = 'EXECUTE PROCEDURE'
        AND ( obj_name = 'DELETEEVENTSCHEDULE' OR obj_name = 'DELETEEVENT');
END;



//////////////////////////////////////////

CREATE OR REPLACE PROCEDURE GetShoppingCartInfo (
    UserLogin_in IN NVARCHAR2,
    ticket_count OUT NUMBER,
    total_price OUT NUMBER,
    Message_out OUT NVARCHAR2
)
AS
    UserID_f NUMBER;
BEGIN
  SELECT UserID INTO UserID_f FROM TicketVibe_Users WHERE Login = UserLogin_in;
    
  SELECT COUNT(*)
  INTO ticket_count
  FROM ShoppingCart
  WHERE UserID = UserID_f;

  SELECT SUM(t.Price)
  INTO total_price
  FROM ShoppingCart sc
  JOIN Tickets t ON sc.TicketID = t.TicketID
  WHERE sc.UserID = UserID_f;
  
  IF ticket_count IS NULL THEN
    ticket_count := 0;
  END IF;
  
  IF total_price IS NULL THEN
    total_price := 0;
  END IF;
EXCEPTION
    WHEN OTHERS THEN
        Message_out := 'Error during finding shopping cart info';
END;