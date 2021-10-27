SET search_path = 'hangfire';

--separator
DO
$$
BEGIN
  IF EXISTS (SELECT 1 FROM "schema" WHERE "version"::integer >= 15) THEN
    RAISE EXCEPTION 'version-already-applied';
  END IF;
END
$$;

--separator
CREATE INDEX ix_hangfire_job_expireat ON "job" (expireat);
--separator
CREATE INDEX ix_hangfire_list_expireat ON "list" (expireat);
--separator
CREATE INDEX ix_hangfire_set_expireat ON "set" (expireat);
--separator
CREATE INDEX ix_hangfire_hash_expireat ON "hash" (expireat);

--separator
RESET search_path;
