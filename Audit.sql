SELECT * FROM DBA_AUDIT_TRAIL;
SELECT owner, object_name, object_type, del, ins, upd, sel FROM dba_obj_audit_opts;

SELECT audit_option, success, failure FROM dba_stmt_audit_opts;


AUDIT session WHENEVER NOT SUCCESSFUL;
AUDIT INSERT ON TicketVibe_TicketRefund;
AUDIT EXECUTE ON TicketVibe_CreateEvent;
AUDIT EXECUTE ON TicketVibe_CreateEventSchedule;
AUDIT EXECUTE ON TicketVibe_DeleteEvent;
AUDIT EXECUTE ON TicketVibe_DeleteEventSchedule;