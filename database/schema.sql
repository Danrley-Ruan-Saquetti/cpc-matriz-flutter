CREATE TABLE IF NOT EXISTS itens (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  categoria VARCHAR(60) NOT NULL,
  unidade VARCHAR(20) NOT NULL DEFAULT 'un',
  quantidade INTEGER NOT NULL DEFAULT 0 CHECK (quantidade >= 0),
  quantidade_minima INTEGER NOT NULL DEFAULT 0 CHECK (quantidade_minima >= 0),
  descricao TEXT,
  criado_em TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS movimentacoes (
  id SERIAL PRIMARY KEY,
  item_id INTEGER NOT NULL REFERENCES itens (id) ON DELETE CASCADE,
  tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('entrada', 'saida')),
  quantidade INTEGER NOT NULL CHECK (quantidade > 0),
  responsavel VARCHAR(120) NOT NULL,
  observacao TEXT,
  criado_em TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_mov_item ON movimentacoes (item_id);
CREATE INDEX IF NOT EXISTS idx_mov_data ON movimentacoes (criado_em);
CREATE TABLE IF NOT EXISTS tickets (
  id SERIAL PRIMARY KEY,
  codigo VARCHAR(20) NOT NULL UNIQUE,
  evento VARCHAR(120) NOT NULL,
  participante VARCHAR(120) NOT NULL,
  valor NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (valor >= 0),
  status VARCHAR(12) NOT NULL DEFAULT 'valido' CHECK (status IN ('valido', 'utilizado', 'cancelado')),
  criado_em TIMESTAMP NOT NULL DEFAULT NOW(),
  utilizado_em TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_ticket_evento ON tickets (evento);
CREATE INDEX IF NOT EXISTS idx_ticket_status ON tickets (status);
INSERT INTO itens (
    nome,
    categoria,
    unidade,
    quantidade,
    quantidade_minima,
    descricao
  )
VALUES (
    'Agua mineral 500ml',
    'Bebidas',
    'un',
    48,
    24,
    'Garrafas para eventos'
  ),
  (
    'Cafe em po 500g',
    'Alimentos',
    'pct',
    5,
    6,
    'Usado nos cultos da manha'
  ),
  (
    'Cadeira plastica',
    'Mobiliario',
    'un',
    120,
    50,
    'Cadeiras brancas empilhaveis'
  ) ON CONFLICT DO NOTHING;
