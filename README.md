# CPC - Estoque e Tickets

Aplicativo Flutter para **gerenciamento de estoque e tickets da Igreja da Nossa Sra. das Graças**.

# Instruções de uso

## Pre-requisitos

- Flutter 3.41+ / Dart 3.11+
- PostgreSQL 13+ em execucao

## Configuracao do banco

1. Crie o banco e as tabelas:

    ```bash
    createdb cpc_matriz
    psql -d cpc_matriz -f database/schema.sql
    ```

2. Ajuste as credenciais em [`lib/core/config/db_config.dart`](lib/core/config/db_config.dart).

    > Em **emulador Android**, use `host = '10.0.2.2'` para acessar o `localhost`
    > da maquina host. Em desktop/web use `localhost`.

## Executando

```bash
flutter pub get
flutter run
```

