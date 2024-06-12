TRIGGER AFTER_DELETE_CATEGORY
AFTER DELETE ON TicketVibe_Categories
FOR EACH ROW 
DECLARE
    subcategory_count NUMBER;
BEGIN    
    SELECT COUNT(*) SubcategoryID INTO subcategory_count FROM TicketVibe_Subcategories WHERE CategoryID = :OLD.CategoryID;
    IF subcategory_count > 0 THEN
        DELETE FROM TicketVibe_Subcategories WHERE CategoryID = :OLD.CategoryID;
    END IF;
END;




TRIGGER AFTER_DELETE_EVENT
AFTER DELETE ON TicketVibe_Events
FOR EACH ROW
BEGIN
	DELETE FROM TicketVibe_EventsSchedule WHERE EventID = :OLD.EventID;
END;




TRIGGER AFTER_DELETE_EVENTSCHEDULE
AFTER DELETE ON TicketVibe_EventsSchedule
FOR EACH ROW
BEGIN
    DELETE FROM TicketVibe_Tickets WHERE EventScheduleID = :OLD.EventScheduleID;
END;





TRIGGER AFTER_DELETE_LOCATION
AFTER DELETE ON TicketVibe_Locations
FOR EACH ROW 
BEGIN
    DELETE FROM TicketVibe_SectorRows WHERE LocationID = :OLD.LocationID;
	DELETE FROM TicketVibe_Events WHERE LocationID = :OLD.LocationID;
END;






TRIGGER AFTER_DELETE_SECTORROWS
AFTER DELETE ON TicketVibe_SectorRows
FOR EACH ROW
DECLARE
BEGIN
    DELETE FROM TicketVibe_Tickets WHERE SectorRowID = :OLD.SectorRowID;    
END;





CREATE OR REPLACE TRIGGER AFTER_DELETE_SALES
AFTER DELETE ON TicketVibe_Sales
FOR EACH ROW
BEGIN
    DELETE FROM TicketVibe_TicketRefund WHERE SaleID = :OLD.SaleID;
END;




TRIGGER AFTER_DELETE_TICKET
AFTER DELETE ON TicketVibe_Tickets
FOR EACH ROW
BEGIN
    DELETE FROM TicketVibe_Sales WHERE TicketID = :OLD.TicketID;
	DELETE FROM TicketVibe_ShoppingCart WHERE TicketID = :OLD.TicketID;
END;





TRIGGER AFTER_INSERT_EVENTSCHEDULE
AFTER INSERT ON TicketVibe_EventsSchedule
FOR EACH ROW
DECLARE
    LocationID_in NUMBER;
    EventID_in NUMBER;
    EventScheduleID_in NUMBER;
    SectorRowID_f NUMBER;
    Price_in NUMBER;
    Price_f NUMBER;
    NumberOfSeats_f NUMBER;
    max_TicketID NUMBER;
BEGIN
    EventID_in := :NEW.EventID;
	EventScheduleID_in := :NEW.EventScheduleID;
    SELECT LocationID INTO LocationID_in FROM TicketVibe_Events WHERE EventID = EventID_in;

    FOR row_rec IN (SELECT sr.SectorRowID, sr.NumberOfSeats, sr.CostFactor
                    FROM TicketVibe_SectorRows sr
                    WHERE sr.LocationID = LocationID_in
                    ORDER BY sr.SectorRowID)
    LOOP
	    SELECT NVL(MAX(TicketID), 1000) INTO max_TicketID FROM TicketVibe_Tickets;
        SectorRowID_f := row_rec.SectorRowID;
        NumberOfSeats_f := row_rec.NumberOfSeats;
        SELECT Cost INTO Price_in FROM TicketVibe_Events WHERE EventID = EventID_in;
        Price_f := Price_in * row_rec.CostFactor; 

        FOR i IN 1..NumberOfSeats_f LOOP
            INSERT INTO TicketVibe_Tickets (TicketID, EventScheduleID, Status, Price, SectorRowID, PlaceInRow)
            VALUES (max_TicketID + i, EventScheduleID_in, 'On sale', Price_f, SectorRowID_f, i); 
        END LOOP;
    END LOOP;
END;




TRIGGER AFTER_INSERT_LOCATION
AFTER INSERT ON TicketVibe_Locations
FOR EACH ROW 
DECLARE
    n NUMBER;
    max_SectorRowID NUMBER;
BEGIN
    SELECT NVL(MAX(SectorRowID) + 1, 999) INTO max_SectorRowID FROM TicketVibe_SectorRows;

    SELECT :NEW.NumberOfSectors INTO n FROM dual;

    FOR i IN 1..n LOOP
        INSERT INTO TicketVibe_SectorRows (SectorRowID, SectorRow, NumberOfSeats, LocationID, CostFactor)
        VALUES (max_SectorRowID + i, i, 30, :NEW.LocationID, 1); 
    END LOOP;
END;




TRIGGER AFTER_UPDATE_EVENT
AFTER UPDATE ON TicketVibe_Events
FOR EACH ROW
DECLARE
    EventID_f NUMBER;
    ScheduleIDs SYS.ODCINUMBERLIST;
BEGIN
    IF :OLD.Cost <> :NEW.Cost THEN
        EventID_f := :NEW.EventID;

        SELECT EventScheduleID BULK COLLECT INTO ScheduleIDs
        FROM EventsSchedule
        WHERE EventID = EventID_f;

        FOR i IN 1..ScheduleIDs.COUNT LOOP
            UPDATE TicketVibe_Tickets
            SET Price = :NEW.Cost * (
                SELECT sr.CostFactor
                FROM SectorRows sr
                WHERE sr.SectorRowID = TicketVibe_Tickets.SectorRowID
            )
            WHERE EventScheduleID = ScheduleIDs(i)
            AND Status = 'On sale';
        END LOOP;
    END IF;
END;





TRIGGER AFTER_UPDATE_LOCATION
AFTER UPDATE ON TicketVibe_Locations
FOR EACH ROW 
DECLARE
    max_SectorRow NUMBER;
    max_SectorRowID NUMBER;
BEGIN    
    SELECT NVL(MAX(SectorRowID) + 1, 1000) INTO max_SectorRowID FROM TicketVibe_SectorRows;
    IF :OLD.NumberOfSectors <> :NEW.NumberOfSectors THEN
        IF :OLD.NumberOfSectors > :NEW.NumberOfSectors THEN
            DELETE FROM TicketVibe_SectorRows WHERE LocationID = :NEW.LocationID
            AND SectorRow > :NEW.NumberOfSectors;
        ELSE
            DECLARE
                v_maxRowNumber NUMBER;
            BEGIN
                SELECT MAX(SectorRow) INTO max_SectorRow FROM TicketVibe_SectorRows WHERE LocationID = :NEW.LocationID;
                FOR i IN (max_SectorRow + 1)..:NEW.NumberOfSectors LOOP
                    INSERT INTO TicketVibe_SectorRows (SectorRowID, SectorRow, NumberOfSeats, LocationID, CostFactor)
                    VALUES (max_SectorRowID, i, 50, :NEW.LocationID, 1);
					max_SectorRowID := max_SectorRowID + 1;
                END LOOP;
            END;
        END IF;
    END IF;
END;



TRIGGER AFTER_UPDATE_SECTORROWS
AFTER UPDATE OF NumberOfSeats ON TicketVibe_SectorRows
FOR EACH ROW
DECLARE
    EventScheduleID_in NUMBER;
    SectorRowID_in NUMBER := :NEW.SectorRowID;
    CurrentNumberOfSeats NUMBER := :NEW.NumberOfSeats;
    CurrentTicketsCount NUMBER;
    Price_f NUMBER;
    Cost_in NUMBER;
    max_TicketID NUMBER;
BEGIN
    FOR event_rec IN (SELECT DISTINCT EventScheduleID
                       FROM TicketVibe_Tickets
                       WHERE SectorRowID = SectorRowID_in)
    LOOP
        EventScheduleID_in := event_rec.EventScheduleID;

        SELECT COUNT(*) INTO CurrentTicketsCount
        FROM TicketVibe_Tickets
        WHERE EventScheduleID = EventScheduleID_in
        AND SectorRowID = SectorRowID_in;

        IF CurrentTicketsCount > CurrentNumberOfSeats THEN
            DELETE FROM TicketVibe_Tickets
                WHERE EventScheduleID = EventScheduleID_in
                AND SectorRowID = SectorRowID_in
                AND PlaceInRow < CurrentNumberOfSeats;

        ELSIF CurrentTicketsCount < CurrentNumberOfSeats THEN
            FOR i IN CurrentTicketsCount + 1..CurrentNumberOfSeats LOOP
                SELECT Cost INTO Cost_in FROM TicketVibe_Events e
                    INNER JOIN TicketVibe_EventsSchedule es ON es.EventID = e.EventID
                    WHERE es.EventScheduleID = EventScheduleID_in;
                Price_f := :NEW.CostFactor * Cost_in;
                SELECT NVL(MAX(TicketID), 1000) INTO max_TicketID FROM TicketVibe_Tickets;
                INSERT INTO TicketVibe_Tickets (TicketID, EventScheduleID, Status, Price, SectorRowID, PlaceInRow)
                VALUES (max_TicketID, EventScheduleID_in, 'On sale', Price_f, SectorRowID_in, i);
            END LOOP;
        END IF;
    END LOOP;
END;