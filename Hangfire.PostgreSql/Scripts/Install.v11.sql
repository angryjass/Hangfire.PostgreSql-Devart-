SET search_path = 'hangfire';

--separator
DO
$$
BEGIN
  IF EXISTS (SELECT 1 FROM "schema" WHERE "version"::integer >= 11) THEN
    RAISE EXCEPTION 'version-already-applied';
  END IF;
END
$$;

--separator
ALTER TABLE "counter" ALTER COLUMN id TYPE BIGINT;
--separator
ALTER TABLE "hash" ALTER COLUMN id TYPE BIGINT;
--separator
ALTER TABLE "job" ALTER COLUMN id TYPE BIGINT;
--separator
ALTER TABLE "job" ALTER COLUMN stateid TYPE BIGINT;
--separator
ALTER TABLE "state" ALTER COLUMN id TYPE BIGINT;
--separator
ALTER TABLE "state" ALTER COLUMN jobid TYPE BIGINT;
--separator
ALTER TABLE "jobparameter" ALTER COLUMN id TYPE BIGINT;
--separator
ALTER TABLE "jobparameter" ALTER COLUMN jobid TYPE BIGINT;
--separator
ALTER TABLE "jobqueue" ALTER COLUMN id TYPE BIGINT;
--separator
ALTER TABLE "jobqueue" ALTER COLUMN jobid TYPE BIGINT;
--separator
ALTER TABLE "list" ALTER COLUMN id TYPE BIGINT;
--separator
ALTER TABLE "set" ALTER COLUMN id TYPE BIGINT;

--separator
RESET search_path;