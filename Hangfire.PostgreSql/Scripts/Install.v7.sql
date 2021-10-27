SET search_path = 'hangfire';
--
-- Table structure for table `Schema`
--

--separator
DO
$$
BEGIN
    IF EXISTS (SELECT 1 FROM "schema" WHERE "version"::integer >= 7) THEN
        RAISE EXCEPTION 'version-already-applied';
    END IF;
END
$$;

--separator
ALTER TABLE "lock" ADD COLUMN acquired timestamp without time zone;

--separator
RESET search_path;