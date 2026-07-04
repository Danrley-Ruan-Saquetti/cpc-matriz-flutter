enum PersistenceSource { memory, sqlite, postgres }

class PersistenceConfig {
  const PersistenceConfig._();

  static const PersistenceSource source = PersistenceSource.sqlite;
}
