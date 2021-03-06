SET search_path = 'hangfire';



--separator
DO
$$
BEGIN
  IF EXISTS (SELECT 1 FROM "schema" WHERE "version"::integer >= 13) THEN
    RAISE EXCEPTION 'version-already-applied';
  END IF;
END
$$;

--separator
CREATE INDEX IF NOT EXISTS jobqueue_queue_fetchat_jobId ON jobqueue USING btree (queue asc, fetchedat asc nulls last, jobid asc);

--separator
RESET search_path;