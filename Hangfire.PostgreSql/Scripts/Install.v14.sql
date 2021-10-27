SET search_path = 'hangfire';

--separator
DO
$$
BEGIN
  IF EXISTS (SELECT 1 FROM "schema" WHERE "version"::integer >= 14) THEN
    RAISE EXCEPTION 'version-already-applied';
  END IF;
END
$$;

--separator
DO
$$
DECLARE
BEGIN
 	EXECUTE('ALTER SEQUENCE ' || 'hangfire' || '.job_id_seq AS bigint MAXVALUE 9223372036854775807');
EXCEPTION WHEN syntax_error THEN
	EXECUTE('ALTER SEQUENCE ' || 'hangfire' || '.job_id_seq MAXVALUE 9223372036854775807');
END;
$$;

--separator
RESET search_path;
