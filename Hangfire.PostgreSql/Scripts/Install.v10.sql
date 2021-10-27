SET search_path = 'hangfire';
--
-- Table structure for table `Schema`
--

--separator
DO
$$
BEGIN
    IF EXISTS (SELECT 1 FROM "schema" WHERE "version"::integer >= 10) THEN
        RAISE EXCEPTION 'version-already-applied';
    END IF;
END
$$;

--separator
ALTER TABLE "jobqueue" ALTER COLUMN "queue" TYPE TEXT;

--separator
RESET search_path;