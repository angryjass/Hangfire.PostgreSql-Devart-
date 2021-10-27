SET search_path = 'hangfire';

--separator
DO
$$
BEGIN
  IF EXISTS (SELECT 1 FROM "schema" WHERE "version"::integer >= 12) THEN
    RAISE EXCEPTION 'version-already-applied';
  END IF;
END
$$;

--separator
ALTER TABLE "counter" ALTER COLUMN "key" TYPE TEXT;
--separator
ALTER TABLE "hash" ALTER COLUMN "key" TYPE TEXT;
--separator
ALTER TABLE "hash" ALTER COLUMN field TYPE TEXT;
--separator
ALTER TABLE "job" ALTER COLUMN statename TYPE TEXT;
--separator
ALTER TABLE "list" ALTER COLUMN "key" TYPE TEXT;
--separator
ALTER TABLE "server" ALTER COLUMN id TYPE TEXT;
--separator
ALTER TABLE "set" ALTER COLUMN "key" TYPE TEXT;
--separator
ALTER TABLE "jobparameter" ALTER COLUMN "name" TYPE TEXT;
--separator
ALTER TABLE "state" ALTER COLUMN "name" TYPE TEXT;
--separator
ALTER TABLE "state" ALTER COLUMN reason TYPE TEXT;

--separator
RESET search_path;