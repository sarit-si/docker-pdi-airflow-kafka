-- Create a TRIGGER function to update the modified_on column of any table
CREATE OR REPLACE FUNCTION update_modified()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    NEW.modified_on = now();
    RETURN NEW;
END;
$BODY$;

-- Create EMPLOYEE table
CREATE TABLE employee
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( START 1 ),
    empid character varying NOT NULL,
    name character varying NOT NULL,
    year integer NOT NULL,
    salary decimal NOT NULL,
    bonus_percent decimal NOT NULL,
    bonus_amount decimal NOT NULL,
    total_salary decimal NOT NULL,
    modified_on time with time zone,
    created_on time with time zone NOT NULL DEFAULT now(),
    PRIMARY KEY (empid)
);

-- Call TRIGGER function to update EMPLOYEE modified_on column whenever there is an update
CREATE TRIGGER update_employee_table_modified_on
    BEFORE UPDATE
    ON employee
    FOR EACH ROW
    EXECUTE FUNCTION update_modified();
