CREATE TABLE Categories (
    CategoryID NUMBER PRIMARY KEY,
    CategoryName NVARCHAR2(40) NOT NULL UNIQUE
);
CREATE PUBLIC SYNONYM TicketVibe_Categories FOR Programmer_1.Categories;

CREATE TABLE CheckingOrganizers (
    OrganizerID NUMBER PRIMARY KEY,
    CompanyName NVARCHAR2(40) NOT NULL UNIQUE,    
    Password NVARCHAR2(30) NOT NULL,
    FirstName NVARCHAR2(20) NOT NULL,
    LastName NVARCHAR2(25) NOT NULL,
    Email NVARCHAR2(50) NOT NULL UNIQUE,
    Phone NVARCHAR2(30) NOT NULL UNIQUE,
    RoleID NUMBER NOT NULL,
    CONSTRAINT fk_RoleCheckingOrganizer FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
CREATE PUBLIC SYNONYM TicketVibe_CheckingOrganizers FOR Programmer_1.CheckingOrganizers;

CREATE TABLE Comments (
    CommentID NUMBER PRIMARY KEY,
    UserID NUMBER NOT NULL,
    EventID NUMBER NOT NULL,
    CommentText NVARCHAR2(400) NOT NULL,
    CommentDate DATE NOT NULL,
    FivePointRating NUMBER NOT NULL CHECK (FivePointRating IN (0, 1, 2, 3, 4, 5)),
    CONSTRAINT fk_CommentUser FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT fk_CommentEvent FOREIGN KEY (EventID) REFERENCES Events(EventID)
);
CREATE PUBLIC SYNONYM TicketVibe_Comments FOR Programmer_1.Comments;

CREATE TABLE Events (
    EventID NUMBER PRIMARY KEY,
    EventName NVARCHAR2(50) NOT NULL UNIQUE,
    LocationID NUMBER NOT NULL,
    EventDuration INTERVAL DAY TO SECOND NOT NULL,
    SubcategoryID NUMBER NOT NULL,
    OrganizerID NUMBER NOT NULL,
    Description NVARCHAR2(400),
    Cost NUMBER NOT NULL,
    CONSTRAINT fk_LocationForEvents FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    CONSTRAINT fk_SubcategoryForEvents FOREIGN KEY (SubcategoryID) REFERENCES Subcategories(SubcategoryID),
    CONSTRAINT fk_OrganizerForEvents FOREIGN KEY (OrganizerID) REFERENCES Organizers(OrganizerID)
);
CREATE PUBLIC SYNONYM TicketVibe_Events FOR Programmer_1.Events;

CREATE TABLE EventsSchedule (
    EventScheduleID NUMBER PRIMARY KEY,
    EventDate TIMESTAMP NOT NULL,
    EventID NUMBER NOT NULL,
    CONSTRAINT fk_EventsScheduleEvents FOREIGN KEY (EventID) REFERENCES Events(EventID)
);
CREATE PUBLIC SYNONYM TicketVibe_EventsSchedule FOR Programmer_1.EventsSchedule;

CREATE TABLE Locations (
    LocationID NUMBER PRIMARY KEY,
    LocationName NVARCHAR2(60) NOT NULL UNIQUE,
    NumberOfSectors NUMBER NOT NULL
);
CREATE PUBLIC SYNONYM TicketVibe_Locations FOR Programmer_1.Locations;

CREATE TABLE Managers (
    ManagerID NUMBER PRIMARY KEY,
    FirstName NVARCHAR2(20) NOT NULL,
    LastName NVARCHAR2(25) NOT NULL,
    Email NVARCHAR2(50) NOT NULL UNIQUE,
    Phone NVARCHAR2(30) NOT NULL UNIQUE,
    DateOfEmployment DATE NOT NULL,
    Password NVARCHAR2(30) NOT NULL,
    RoleID NUMBER NOT NULL,
    Login NVARCHAR2(40) NOT NULL UNIQUE,
    CONSTRAINT fk_RoleManager FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
CREATE PUBLIC SYNONYM TicketVibe_Managers FOR Programmer_1.Managers;

CREATE TABLE OrganizerBlocks (
    BlockID NUMBER PRIMARY KEY,
    OrganizerID NUMBER NOT NULL,
    ManagerID NUMBER NOT NULL,
    Reason NVARCHAR2(200) NOT NULL,
    EndDate DATE,
    CONSTRAINT fk_OrganizerBlocks FOREIGN KEY (OrganizerID) REFERENCES Organizers(OrganizerID),
    CONSTRAINT fk_ManagerBlocks_Organizer FOREIGN KEY (ManagerID) REFERENCES Managers(ManagerID)
);
CREATE PUBLIC SYNONYM TicketVibe_OrganizerBlocks FOR Programmer_1.OrganizerBlocks;

CREATE TABLE OrganizerQuestions (
    QuestionID NUMBER PRIMARY KEY,
    OrganizerID NUMBER NOT NULL,
    QuestionText NVARCHAR2(500) NOT NULL,
    QuestionDate DATE NOT NULL,
    AnswerText NVARCHAR2(500),
    Status NVARCHAR2(30) NOT NULL CHECK (Status IN ('Not Viewed', 'In processing', 'closed')),
    ManagerID NUMBER NOT NULL,
    CONSTRAINT fk_OrganizerQuestion FOREIGN KEY (OrganizerID) REFERENCES Organizers(OrganizerID),
    CONSTRAINT fk_ManagerQuestion_Organizer FOREIGN KEY (ManagerID) REFERENCES Managers(ManagerID)
);
CREATE PUBLIC SYNONYM TicketVibe_OrganizerQuestions FOR Programmer_1.OrganizerQuestions;

CREATE TABLE Organizers (
    OrganizerID NUMBER PRIMARY KEY,
    CompanyName NVARCHAR2(40) NOT NULL UNIQUE,    
    Password NVARCHAR2(30) NOT NULL,
    FirstName NVARCHAR2(20) NOT NULL,
    LastName NVARCHAR2(25) NOT NULL,
    Email NVARCHAR2(50) NOT NULL UNIQUE,
    Phone NVARCHAR2(30) NOT NULL UNIQUE,
    RoleID NUMBER NOT NULL,
    CONSTRAINT fk_RoleOrganizer FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
CREATE PUBLIC SYNONYM TicketVibe_Organizers FOR Programmer_1.Organizers;

CREATE TABLE Roles (
    RoleID NUMBER PRIMARY KEY,
    RoleName NVARCHAR2(50) NOT NULL CHECK (RoleName IN ('User', 'Manager', 'Organizer'))
);
CREATE PUBLIC SYNONYM TicketVibe_Roles FOR Programmer_1.Roles;

CREATE TABLE Sales (
    SaleID NUMBER PRIMARY KEY,
    UserID NUMBER NOT NULL,
    TicketID NUMBER NOT NULL,
    SaleDate DATE NOT NULL,
    Status NVARCHAR2(50) NOT NULL CHECK (Status IN ('Valid', 'Refund')),
    CONSTRAINT fk_UserOfSale FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT fk_TicketOfSale FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID),
);
CREATE PUBLIC SYNONYM TicketVibe_Sales FOR Programmer_1.Sales;


CREATE TABLE SectorRows (
    SectorRowID NUMBER PRIMARY KEY,
    SectorRow NUMBER NOT NULL,
    NumberOfSeats NUMBER NOT NULL,
    LocationID NUMBER NOT NULL,
    CostFactor NUMBER NOT NULL,
    CONSTRAINT fk_Location FOREIGN KEY (LocationID) REFERENCES Locations(LocationID);
);
CREATE PUBLIC SYNONYM TicketVibe_SectorRows FOR Programmer_1.SectorRows;


CREATE TABLE ShoppingCart (
    UserID NUMBER NOT NULL,
    TicketID NUMBER NOT NULL,
    CONSTRAINT fk_UserShoppingCart FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT fk_TicketShoppingCart FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID)
);
CREATE PUBLIC SYNONYM TicketVibe_ShoppingCart FOR Programmer_1.ShoppingCart;

CREATE TABLE Subcategories (
    SubcategoryID NUMBER PRIMARY KEY,
    SubcategoryName NVARCHAR2(40) NOT NULL,
    CategoryID NUMBER NOT NULL,
    CONSTRAINT fk_Category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
CREATE PUBLIC SYNONYM TicketVibe_Subcategories FOR Programmer_1.Subcategories;

CREATE TABLE TicketRefund (
    SaleID NUMBER NOT NULL,
    UserID NUMBER NOT NULL,
    Message NVARCHAR2(400) NOT NULL,
    RefundDate DATE NOT NULL,
    CONSTRAINT fk_UserOfTicketRefund FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT fk_SaleOfTicketRefund FOREIGN KEY (SaleID) REFERENCES Sales(SaleID)
);
CREATE PUBLIC SYNONYM TicketVibe_TicketRefund FOR Programmer_1.TicketRefund;

CREATE TABLE Tickets (
    TicketID NUMBER PRIMARY KEY,
    EventScheduleID NUMBER NOT NULL,
    Status NVARCHAR2(50) NOT NULL CHECK (Status IN ('On sale', 'Booked', 'Purchased')),
    Price NUMBER NOT NULL,
    SectorRowID NUMBER NOT NULL,
    PlaceInRow NUMBER NOT NULL,
    CONSTRAINT fk_TicketsEventsScheduleID FOREIGN KEY (EventScheduleID) REFERENCES EventsSchedule(EventScheduleID),
    CONSTRAINT fk_SectorRowOfTicket FOREIGN KEY (SectorRowID) REFERENCES SectorRows(SectorRowID)
);
CREATE PUBLIC SYNONYM TicketVibe_Tickets FOR Programmer_1.Tickets;

CREATE TABLE UserBlocks (
    BlockID NUMBER PRIMARY KEY,
    UserID NUMBER NOT NULL,
    ManagerID NUMBER NOT NULL,
    Reason NVARCHAR2(200) NOT NULL,
    EndDate DATE,
    CONSTRAINT fk_UserBlocks FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT fk_ManagerBlocks_User FOREIGN KEY (ManagerID) REFERENCES Managers(ManagerID)
);
CREATE PUBLIC SYNONYM TicketVibe_UserBlocks FOR Programmer_1.UserBlocks;

CREATE TABLE UserQuestions (
    QuestionID NUMBER PRIMARY KEY,
    UserID NUMBER NOT NULL,
    QuestionText NVARCHAR2(500) NOT NULL,
    QuestionDate DATE NOT NULL,
    AnswerText NVARCHAR2(500),
    Status NVARCHAR2(30) NOT NULL CHECK (Status IN ('Not Viewed', 'In processing', 'closed')),
    ManagerID NUMBER NOT NULL,
    CONSTRAINT fk_UserQuestion FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT fk_ManagerQuestion_User FOREIGN KEY (ManagerID) REFERENCES Managers(ManagerID)
);
CREATE PUBLIC SYNONYM TicketVibe_UserQuestions FOR Programmer_1.UserQuestions;

CREATE TABLE Users (
    UserID NUMBER PRIMARY KEY, 
    Login NVARCHAR2(40) NOT NULL UNIQUE,
    Password NVARCHAR2(30) NOT NULL,
    FirstName NVARCHAR2(20) NOT NULL,
    LastName NVARCHAR2(25) NOT NULL,
    Email NVARCHAR2(50) NOT NULL UNIQUE,
    Phone NVARCHAR2(30) NOT NULL UNIQUE,
    RoleID NUMBER NOT NULL,
    CONSTRAINT fk_RoleUser FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
CREATE PUBLIC SYNONYM TicketVibe_Users FOR Programmer_1.Users;

DELETE FROM TicketVibe_Categories;
DELETE FROM TicketVibe_CheckingOrganizers;
DELETE FROM TicketVibe_Comments;
DELETE FROM TicketVibe_Events;
DELETE FROM TicketVibe_EventsSchedule;
DELETE FROM TicketVibe_Locations;
DELETE FROM TicketVibe_Managers;
DELETE FROM TicketVibe_OrganizerBlocks;
DELETE FROM TicketVibe_OrganizerQuestions;
DELETE FROM TicketVibe_Organizers;
DELETE FROM TicketVibe_Roles;
DELETE FROM TicketVibe_Sales;
DELETE FROM TicketVibe_SectorRows;
DELETE FROM TicketVibe_ShoppingCart;
DELETE FROM TicketVibe_Subcategories;
DELETE FROM TicketVibe_TicketRefund;
DELETE FROM TicketVibe_Tickets;
DELETE FROM TicketVibe_UserBlocks;
DELETE FROM TicketVibe_UserQuestions;
DELETE FROM TicketVibe_Users;
COMMIT;

INSERT INTO Users VALUES (999, 'Quest', 123, 'Quest', 'Quest', 'Quest', 'Quest', 1000);
Commit;