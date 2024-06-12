set serveroutput on;

CREATE OR REPLACE FUNCTION export_events_to_xml(p_filename IN VARCHAR2) RETURN VARCHAR2 IS
    l_xml XMLTYPE;
    l_file_handle UTL_FILE.file_type;
    l_clob CLOB;
    l_amount BINARY_INTEGER := 32767;
    l_offset INTEGER := 1;
    l_raw RAW(32767);
BEGIN
    SELECT XMLELEMENT("Events",
        XMLAGG(
        XMLELEMENT("Event",
        XMLELEMENT("EventID", EventID),
        XMLELEMENT("EventName", EventName),
        XMLELEMENT("LocationID", LocationID),
        XMLELEMENT("EventDuration", EventDuration),
        XMLELEMENT("SubcategoryID", SubcategoryID),
        XMLELEMENT("OrganizerID", OrganizerID),
        XMLELEMENT("Description", Description),
        XMLELEMENT("Cost", Cost))
        )
    )
    INTO l_xml FROM TicketVibe_Events;

    l_clob := l_xml.getClobVal();
    l_file_handle := UTL_FILE.fopen('XML_DIRECTORY', p_filename, 'wb');

    WHILE l_offset < DBMS_LOB.getlength(l_clob) LOOP
        l_raw := UTL_RAW.cast_to_raw(DBMS_LOB.substr(l_clob, l_amount, l_offset));
        UTL_FILE.put_raw(l_file_handle, l_raw);
        l_offset := l_offset + l_amount;
    END LOOP;

    UTL_FILE.fclose(l_file_handle);
RETURN 'Events exported to ' || p_filename || ' successfully.';
END;




CREATE OR REPLACE FUNCTION import_events_from_xml(p_filename IN VARCHAR2) RETURN VARCHAR2 IS
    l_file_handle UTL_FILE.file_type;
    l_raw RAW(32767);
    l_clob CLOB;
    l_amount BINARY_INTEGER := 32767;
    l_offset INTEGER := 1;
    l_xml XMLTYPE;
    l_event_id NUMBER;
    l_event_name NVARCHAR2(50);
    l_message VARCHAR2(1000);
BEGIN
    l_file_handle := UTL_FILE.fopen('XML_DIRECTORY', p_filename, 'rb');

    WHILE TRUE LOOP
        UTL_FILE.get_raw(l_file_handle, l_raw, l_amount);
        l_clob := l_clob || UTL_RAW.cast_to_varchar2(l_raw);
        EXIT WHEN LENGTH(l_raw) < l_amount;
    END LOOP;
    UTL_FILE.fclose(l_file_handle);

    l_xml := XMLTYPE(l_clob);

    FOR r IN (
        SELECT extractvalue(value(t), '/Event/EventID') AS EventID,
        extractvalue(value(t), '/Event/EventName') AS EventName,
        extractvalue(value(t), '/Event/LocationID') AS LocationID,
        extractvalue(value(t), '/Event/EventDuration') AS EventDuration,
        extractvalue(value(t), '/Event/SubcategoryID') AS SubcategoryID,
        extractvalue(value(t), '/Event/OrganizerID') AS OrganizerID,
        extractvalue(value(t), '/Event/Description') AS Description,
        extractvalue(value(t), '/Event/Cost') AS Cost
        FROM TABLE(XMLSEQUENCE(extract(l_xml, '/Events/Event'))) t
    ) LOOP
        l_event_id := r.EventID;
        l_event_name := r.EventName;

        BEGIN
            SELECT 1 INTO l_event_id FROM TicketVibe_Events WHERE EventID = r.EventID;
            l_message := l_message || 'Event with ID ' || r.EventID || ' already exists. ';
            CONTINUE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
            END;

        BEGIN
            SELECT 1 INTO l_event_name FROM TicketVibe_Events WHERE EventName = r.EventName;
            l_message := l_message || 'Event with name ' || r.EventName || ' already exists. ';
            CONTINUE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
            END;

        INSERT INTO TicketVibe_Events (EventID, EventName, LocationID, EventDuration, SubcategoryID, OrganizerID, Description, Cost)
            VALUES (r.EventID, r.EventName, r.LocationID, r.EventDuration, r.SubcategoryID, r.OrganizerID, r.Description, r.Cost);
    END LOOP;
    COMMIT;
RETURN l_message;
END;






DECLARE
l_message VARCHAR2(1000);
BEGIN
l_message := import_events_from_xml('example.xml');
DBMS_OUTPUT.put_line(l_message);
END;

DECLARE
l_message VARCHAR2(1000);
BEGIN
l_message := export_events_to_xml('example.xml');
DBMS_OUTPUT.put_line(l_message);
END;