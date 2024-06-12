ALTER SESSION SET "_oracle_script" = TRUE;

CREATE ROLE Programmer;

GRANT CREATE SESSION,
      CREATE TABLE,
      CREATE SYNONYM,
      CREATE PUBLIC SYNONYM,
      CREATE VIEW,
      CREATE USER,
      CREATE ROLE,
      DROP USER,
      AUDIT SYSTEM,
      GRANT ANY ROLE,
      GRANT ANY PRIVILEGE,
      CREATE ANY TRIGGER,
      SELECT ON DBA_AUDIT_TRAIL,
      SELECT ON DBA_AUDIT_SESSION,
      CREATE PROCEDURE TO Programmer;

CREATE TABLESPACE TicketVibe
    DATAFILE 'C:\Coursework\Tablespaces\TicketVibe.dbf'
    SIZE 20M
    AUTOEXTEND ON NEXT 10M
    MAXSIZE UNLIMITED
    EXTENT MANAGEMENT LOCAL;

CREATE TEMPORARY TABLESPACE TicketVibe_TEMP
    TEMPFILE 'C:\Coursework\Tablespaces\TicketVibe_TEMP.dbf'
    SIZE 20M
    AUTOEXTEND ON NEXT 10M
    MAXSIZE UNLIMITED
    EXTENT MANAGEMENT LOCAL;

CREATE USER Programmer_1 IDENTIFIED BY Qwerty99880
DEFAULT TABLESPACE TicketVibe
TEMPORARY TABLESPACE TicketVibe_TEMP
ACCOUNT UNLOCK;

GRANT Programmer TO Programmer_1;
ALTER USER Programmer_1 QUOTA UNLIMITED ON TicketVibe;


CREATE OR REPLACE DIRECTORY XML_DIRECTORY AS 'C:\Coursework\xml_directory';
GRANT READ, WRITE ON DIRECTORY XML_DIRECTORY TO Programmer;