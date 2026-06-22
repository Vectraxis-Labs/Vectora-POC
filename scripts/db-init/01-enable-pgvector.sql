-- The extension registers under the name "vector", NOT "pgvector".
-- `CREATE EXTENSION pgvector` fails with "could not open extension control file".
CREATE EXTENSION IF NOT EXISTS vector;