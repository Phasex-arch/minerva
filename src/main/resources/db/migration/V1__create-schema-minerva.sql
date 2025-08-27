-- noinspection SqlNoDataSourceInspectionForFile

-- =============================================
-- Postgres DDL — Sistema Minerva
-- Ambiente: PostgreSQL 15+
-- Convenções: nomes_em_portugues, snake_case, chaves surrogate (BIGSERIAL/UUID), created_at/updated_at
-- =============================================

-- 0) SCHEMA E EXTENSÕES
CREATE SCHEMA IF NOT EXISTS minerva;
SET search_path TO minerva, public;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";     -- para uuid_generate_v4()
CREATE EXTENSION IF NOT EXISTS pgcrypto;         -- opcional (hash/crypto)

-- 1) TIPOS ENUM (consistentes com o doc de requisitos)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_produto') THEN
CREATE TYPE tipo_produto AS ENUM ('TAPETE','PERSIANA','CORTINA','DECORACAO');
END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_orcamento') THEN
CREATE TYPE status_orcamento AS ENUM ('ABERTO','ENVIADO','APROVADO','CANCELADO');
END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_pedido') THEN
CREATE TYPE status_pedido AS ENUM ('ABERTO','PAGO','ENTREGUE','CANCELADO');
END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_preco_item') THEN
CREATE TYPE tipo_preco_item AS ENUM ('PECA','M2','UNIT');
END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_mov_estoque') THEN
CREATE TYPE tipo_mov_estoque AS ENUM ('ENTRADA','SAIDA','AJUSTE');
END IF;
END$$;

-- 2) TABELAS DE USUÁRIO / FUNÇÕES / PERFIS (para Spring Security)
-- Observação: Autenticação/Autorização implementadas na aplicação.
-- Estrutura relacional para suportar roles e agenda 1:N.

CREATE TABLE IF NOT EXISTS app_user (
                                        id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome            TEXT NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    telefone        TEXT,
    username        TEXT UNIQUE NOT NULL,
    senha_hash      TEXT NOT NULL,              -- armazenar hash (BCrypt/Argon2) gerado na aplicação
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em   TIMESTAMPTZ NOT NULL DEFAULT now()
    );

CREATE TABLE IF NOT EXISTS role (
                                    id          BIGSERIAL PRIMARY KEY,
                                    nome        TEXT UNIQUE NOT NULL            -- ex.: ROLE_MANAGER, ROLE_VENDEDOR
);

CREATE TABLE IF NOT EXISTS user_role (
                                         user_id     UUID REFERENCES app_user(id) ON DELETE CASCADE,
    role_id     BIGINT REFERENCES role(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
    );

-- 3) AGENDA (1 usuário → 1 agenda) e EVENTOS (1:N)
CREATE TABLE IF NOT EXISTS agenda (
                                      id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID UNIQUE NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    nome            TEXT DEFAULT 'Agenda Padrão',
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em   TIMESTAMPTZ NOT NULL DEFAULT now()
    );

CREATE TABLE IF NOT EXISTS agenda_evento (
                                             id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agenda_id       UUID NOT NULL REFERENCES agenda(id) ON DELETE CASCADE,
    titulo          TEXT NOT NULL,
    descricao       TEXT,
    inicio_em       TIMESTAMPTZ NOT NULL,
    fim_em          TIMESTAMPTZ NOT NULL,
    local           TEXT,
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (fim_em > inicio_em)
    );
CREATE INDEX IF NOT EXISTS idx_agenda_evento_agenda_tempo ON agenda_evento (agenda_id, inicio_em);

-- 4) CADASTROS PRINCIPAIS
CREATE TABLE IF NOT EXISTS fornecedor (
                                          id              BIGSERIAL PRIMARY KEY,
                                          nome            TEXT NOT NULL,
                                          contato         TEXT,
                                          lead_time_dias  INT,
                                          criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em   TIMESTAMPTZ NOT NULL DEFAULT now()
    );

CREATE TABLE IF NOT EXISTS cliente (
                                       id              BIGSERIAL PRIMARY KEY,
                                       nome            TEXT NOT NULL,
                                       telefone        TEXT,
                                       whatsapp        TEXT,
                                       observacoes     TEXT,
                                       criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em   TIMESTAMPTZ NOT NULL DEFAULT now()
    );
CREATE INDEX IF NOT EXISTS idx_cliente_nome ON cliente (nome);

CREATE TABLE IF NOT EXISTS produto (
                                       id              BIGSERIAL PRIMARY KEY,
                                       sku             TEXT UNIQUE NOT NULL,
                                       nome            TEXT NOT NULL,
                                       tipo            tipo_produto NOT NULL,
                                       categoria       TEXT,
                                       material        TEXT,
                                       cor             TEXT,
                                       largura_cm      NUMERIC(10,2),          -- opcional, usado p/ padrão
    comprimento_cm  NUMERIC(10,2),
    altura_cm       NUMERIC(10,2),          -- relevante p/ persianas/cortinas
    preco_por_peca  NUMERIC(12,2),
    preco_por_m2    NUMERIC(12,2),
    sob_medida      BOOLEAN NOT NULL DEFAULT FALSE,
    observacoes     TEXT,
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (preco_por_peca IS NOT NULL OR preco_por_m2 IS NOT NULL)
    );
CREATE INDEX IF NOT EXISTS idx_produto_nome ON produto (nome);

-- 5) ESTOQUE (1 registro por produto por local opcional)
CREATE TABLE IF NOT EXISTS estoque (
                                       id              BIGSERIAL PRIMARY KEY,
                                       produto_id      BIGINT NOT NULL REFERENCES produto(id) ON DELETE RESTRICT,
    quantidade      INTEGER NOT NULL DEFAULT 0,
    localizacao     TEXT,
    alerta_minimo   INTEGER NOT NULL DEFAULT 0,
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (quantidade >= 0)
    );
CREATE UNIQUE INDEX IF NOT EXISTS ux_estoque_produto_local ON estoque (produto_id, COALESCE(localizacao,'#default'));
CREATE INDEX IF NOT EXISTS idx_estoque_alerta ON estoque (quantidade, alerta_minimo);

-- 6) ORÇAMENTO E ITENS
CREATE TABLE IF NOT EXISTS orcamento (
                                         id              BIGSERIAL PRIMARY KEY,
                                         cliente_id      BIGINT NOT NULL REFERENCES cliente(id) ON DELETE RESTRICT,
    criado_por      UUID REFERENCES app_user(id) ON DELETE SET NULL,
    data            DATE NOT NULL DEFAULT CURRENT_DATE,
    status          status_orcamento NOT NULL DEFAULT 'ABERTO',
    desconto_total  NUMERIC(12,2) DEFAULT 0,
    observacoes     TEXT,
    validade_dias   INT DEFAULT 7,
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em   TIMESTAMPTZ NOT NULL DEFAULT now()
    );
CREATE INDEX IF NOT EXISTS idx_orcamento_cliente ON orcamento (cliente_id);

CREATE TABLE IF NOT EXISTS item_orcamento (
                                              id                  BIGSERIAL PRIMARY KEY,
                                              orcamento_id        BIGINT NOT NULL REFERENCES orcamento(id) ON DELETE CASCADE,
    produto_id          BIGINT NOT NULL REFERENCES produto(id) ON DELETE RESTRICT,
    tipo_preco          tipo_preco_item NOT NULL,
    largura_cm          NUMERIC(10,2),
    comprimento_cm      NUMERIC(10,2),
    altura_cm           NUMERIC(10,2),
    coeficiente_onda    NUMERIC(4,2),            -- {0.55, 0.65} quando cortina
    quantidade          INTEGER NOT NULL DEFAULT 1,
    preco_unitario      NUMERIC(12,2) NOT NULL,  -- já calculado conforme regra
    desconto_item       NUMERIC(12,2) DEFAULT 0,
    observacoes         TEXT,
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (quantidade > 0),
    CHECK (coeficiente_onda IS NULL OR coeficiente_onda IN (0.55, 0.65))
    );
CREATE INDEX IF NOT EXISTS idx_item_orcamento_orc ON item_orcamento (orcamento_id);

-- 7) PEDIDO (derivado de orçamento)
CREATE TABLE IF NOT EXISTS pedido (
                                      id              BIGSERIAL PRIMARY KEY,
                                      orcamento_id    BIGINT UNIQUE NOT NULL REFERENCES orcamento(id) ON DELETE RESTRICT,
    criado_por      UUID REFERENCES app_user(id) ON DELETE SET NULL,
    data            DATE NOT NULL DEFAULT CURRENT_DATE,
    status          status_pedido NOT NULL DEFAULT 'ABERTO',
    forma_pagamento TEXT,
    observacoes     TEXT,
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em   TIMESTAMPTZ NOT NULL DEFAULT now()
    );
CREATE INDEX IF NOT EXISTS idx_pedido_status ON pedido (status);

-- Itens do pedido (snapshot do preço / não dependem do produto após fechamento)
CREATE TABLE IF NOT EXISTS item_pedido (
                                           id                  BIGSERIAL PRIMARY KEY,
                                           pedido_id           BIGINT NOT NULL REFERENCES pedido(id) ON DELETE CASCADE,
    produto_id          BIGINT NOT NULL REFERENCES produto(id) ON DELETE RESTRICT,
    tipo_preco          tipo_preco_item NOT NULL,
    largura_cm          NUMERIC(10,2),
    comprimento_cm      NUMERIC(10,2),
    altura_cm           NUMERIC(10,2),
    coeficiente_onda    NUMERIC(4,2),
    quantidade          INTEGER NOT NULL,
    preco_unitario      NUMERIC(12,2) NOT NULL,
    desconto_item       NUMERIC(12,2) DEFAULT 0,
    observacoes         TEXT,
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em       TIMESTAMPTZ NOT NULL DEFAULT now()
    );
CREATE INDEX IF NOT EXISTS idx_item_pedido_ped ON item_pedido (pedido_id);

-- 8) MOVIMENTOS DE ESTOQUE (auditoria)
CREATE TABLE IF NOT EXISTS movimento_estoque (
                                                 id              BIGSERIAL PRIMARY KEY,
                                                 produto_id      BIGINT NOT NULL REFERENCES produto(id) ON DELETE RESTRICT,
    tipo            tipo_mov_estoque NOT NULL,
    quantidade      INTEGER NOT NULL CHECK (quantidade > 0),
    motivo          TEXT,
    referencia_tabela TEXT,                     -- 'pedido', 'orcamento', 'ajuste', etc
    referencia_id   BIGINT,                     -- id na tabela de referência, quando existir
    realizado_por   UUID REFERENCES app_user(id) ON DELETE SET NULL,
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now()
    );
CREATE INDEX IF NOT EXISTS idx_mov_produto_tempo ON movimento_estoque (produto_id, criado_em DESC);

-- 9) RELAÇÕES COM FORNECEDOR (entradas)
CREATE TABLE IF NOT EXISTS entrada_fornecedor (
                                                  id              BIGSERIAL PRIMARY KEY,
                                                  fornecedor_id   BIGINT REFERENCES fornecedor(id) ON DELETE SET NULL,
    nota_ref        TEXT,
    criado_por      UUID REFERENCES app_user(id) ON DELETE SET NULL,
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now()
    );

CREATE TABLE IF NOT EXISTS entrada_item (
                                            id              BIGSERIAL PRIMARY KEY,
                                            entrada_id      BIGINT NOT NULL REFERENCES entrada_fornecedor(id) ON DELETE CASCADE,
    produto_id      BIGINT NOT NULL REFERENCES produto(id) ON DELETE RESTRICT,
    quantidade      INTEGER NOT NULL CHECK (quantidade > 0)
    );

-- 10) FUNÇÕES/TRIGGERS utilitárias
-- 10.1) Atualizar updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.atualizado_em := now();
RETURN NEW;
END; $$ LANGUAGE plpgsql;

-- 10.2) Impedir estoque negativo (em operações diretas na tabela estoque)
CREATE OR REPLACE FUNCTION check_estoque_nao_negativo()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.quantidade < 0 THEN
    RAISE EXCEPTION 'Estoque não pode ser negativo para produto_id=%', NEW.produto_id;
END IF;
RETURN NEW;
END; $$ LANGUAGE plpgsql;

-- 10.3) (Opcional) Aplicar entrada_fornecedor → atualiza estoque e registra movimento
CREATE OR REPLACE FUNCTION apply_entrada_item()
RETURNS TRIGGER AS $$
BEGIN
UPDATE estoque SET quantidade = quantidade + NEW.quantidade, atualizado_em = now()
WHERE produto_id = NEW.produto_id;
INSERT INTO movimento_estoque (produto_id, tipo, quantidade, motivo, referencia_tabela, referencia_id)
VALUES (NEW.produto_id, 'ENTRADA', NEW.quantidade, 'Entrada fornecedor', 'entrada_fornecedor', NEW.entrada_id);
RETURN NEW;
END; $$ LANGUAGE plpgsql;

-- Triggers de updated_at
CREATE TRIGGER tg_updated_app_user       BEFORE UPDATE ON app_user       FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER tg_updated_agenda         BEFORE UPDATE ON agenda         FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER tg_updated_agenda_evento  BEFORE UPDATE ON agenda_evento  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER tg_updated_fornecedor     BEFORE UPDATE ON fornecedor     FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER tg_updated_cliente        BEFORE UPDATE ON cliente        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER tg_updated_produto        BEFORE UPDATE ON produto        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER tg_updated_estoque        BEFORE UPDATE ON estoque        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER tg_updated_orcamento      BEFORE UPDATE ON orcamento      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER tg_updated_item_orc       BEFORE UPDATE ON item_orcamento FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER tg_updated_pedido         BEFORE UPDATE ON pedido         FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER tg_updated_item_ped       BEFORE UPDATE ON item_pedido    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Trigger de integridade no estoque
CREATE TRIGGER tg_check_estoque_nao_neg BEFORE INSERT OR UPDATE ON estoque
                                                             FOR EACH ROW EXECUTE FUNCTION check_estoque_nao_negativo();

-- Aplica entradas de fornecedor automaticamente (opcional; ative se quiser efeito colateral via DML)
-- CREATE TRIGGER tg_apply_entrada_item AFTER INSERT ON entrada_item
--     FOR EACH ROW EXECUTE FUNCTION apply_entrada_item();

-- 11) VISÕES PARA ANÁLISE (consumo Python)
-- Vendas por mês (quantidade e faturamento) — considera itens de pedido com status PAGO/ENTREGUE
CREATE OR REPLACE VIEW vw_vendas_mensal AS
SELECT
    date_trunc('month', p.data)::date AS mes,
    ip.produto_id,
    sum(ip.quantidade) AS qtd_vendida,
    sum((ip.preco_unitario - COALESCE(ip.desconto_item,0)) * ip.quantidade) AS faturamento
FROM pedido p
         JOIN item_pedido ip ON ip.pedido_id = p.id
WHERE p.status IN ('PAGO','ENTREGUE')
GROUP BY mes, ip.produto_id;

-- Top produtos do mês corrente (por quantidade)
CREATE OR REPLACE VIEW vw_top_produtos_mes_corrente AS
SELECT
    ip.produto_id,
    sum(ip.quantidade) AS qtd_vendida
FROM pedido p
         JOIN item_pedido ip ON ip.pedido_id = p.id
WHERE p.status IN ('PAGO','ENTREGUE')
  AND date_trunc('month', p.data) = date_trunc('month', CURRENT_DATE)
GROUP BY ip.produto_id
ORDER BY qtd_vendida DESC;

-- Estoque com alerta
CREATE OR REPLACE VIEW vw_estoque_alerta AS
SELECT e.*, p.nome, p.sku
FROM estoque e
         JOIN produto p ON p.id = e.produto_id
WHERE e.quantidade <= e.alerta_minimo;

-- 12) ÍNDICES ADICIONAIS ÚTEIS
CREATE INDEX IF NOT EXISTS idx_pedido_data ON pedido (data);
CREATE INDEX IF NOT EXISTS idx_item_pedido_produto ON item_pedido (produto_id);
CREATE INDEX IF NOT EXISTS idx_orcamento_status ON orcamento (status);

-- 13) SEEDS MÍNIMOS (opcional / ambiente dev)
-- INSERT INTO role (nome) VALUES ('ROLE_MANAGER'), ('ROLE_VENDEDOR') ON CONFLICT DO NOTHING;

-- 14) POLÍTICAS DE INTEGRIDADE (regras de negócio delegadas ao app)
-- - Verificação de disponibilidade de estoque na conversão Orcamento→Pedido.
-- - Estornos em cancelamentos devem gerar movimento_estoque com tipo 'AJUSTE' ou 'ENTRADA'.
-- - Regras de arredondamento/área mínima aplicadas pela aplicação ao gravar item_orcamento/pedido.

-- FIM DO DDL
