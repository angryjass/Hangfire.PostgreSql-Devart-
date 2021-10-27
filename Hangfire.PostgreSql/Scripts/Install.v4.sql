SET search_path = 'hangfire';
--
-- Table structure for table `Schema`
--

--separator
DO
$$
BEGIN
    IF EXISTS (SELECT 1 FROM "schema" WHERE "version"::integer >= 4) THEN
        RAISE EXCEPTION 'version-already-applied';
    END IF;
END
$$;

--separator
ALTER TABLE "counter" ADD COLUMN "updatecount" integer NOT NULL DEFAULT 0;
--separator
ALTER TABLE "lock" ADD COLUMN "updatecount" integer NOT NULL DEFAULT 0;
--separator
ALTER TABLE "hash" ADD COLUMN "updatecount" integer NOT NULL DEFAULT 0;
--separator
ALTER TABLE "job" ADD COLUMN "updatecount" integer NOT NULL DEFAULT 0;
--separator
ALTER TABLE "jobparameter" ADD COLUMN "updatecount" integer NOT NULL DEFAULT 0;
--separator
ALTER TABLE "jobqueue" ADD COLUMN "updatecount" integer NOT NULL DEFAULT 0;
--separator
ALTER TABLE "list" ADD COLUMN "updatecount" integer NOT NULL DEFAULT 0;
--separator
ALTER TABLE "server" ADD COLUMN "updatecount" integer NOT NULL DEFAULT 0;
--separator
ALTER TABLE "set" ADD COLUMN "updatecount" integer NOT NULL DEFAULT 0;
--separator
ALTER TABLE "state" ADD COLUMN "updatecount" integer NOT NULL DEFAULT 0;

--separator
RESET search_path;