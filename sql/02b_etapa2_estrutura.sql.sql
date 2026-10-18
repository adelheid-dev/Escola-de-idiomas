-- PROJETO FINAL - ESCOLA DE IDIOMAS
-- Etapa 2: ajustes e objetos exigidos pela aplicação (B1 a B6)
-- Ordem de execução em base limpa: 01_ddl.sql -> 02_carga.sql -> 04_etapa2.sql
-- Pode ser executado mais de uma vez? NÃO: rode sempre após recriar o banco com o 01_ddl.sql.

SET NAMES utf8mb4;
USE escola_idiomas;

-- 1. IDIOMA: colunas usadas pela tela de Idiomas
ALTER TABLE IDIOMA
    ADD COLUMN data_cadastro DATE NULL,
    ADD COLUMN situacao VARCHAR(20) NOT NULL DEFAULT 'Ativo',
    ADD CONSTRAINT ck_idioma_situacao CHECK (situacao IN ('Ativo', 'Inativo'));

UPDATE IDIOMA SET data_cadastro = CURDATE() WHERE data_cadastro IS NULL;

-- 2. MATRICULA: chave substituta para o financeiro e para a tela de matrículas.
--    A PK composta (id_aluno, id_turma) continua sendo a chave primária;
--    id_matricula é uma chave alternativa (UNIQUE) gerada automaticamente.
ALTER TABLE MATRICULA
    ADD COLUMN id_matricula INT NOT NULL AUTO_INCREMENT UNIQUE FIRST;

-- 3. PAGAMENTO (financeiro). Antes não tinha FK nem CHECK.
CREATE TABLE PAGAMENTO (
    id_pagamento INT AUTO_INCREMENT,
    id_aluno INT NOT NULL,
    id_turma INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_pagamento DATE,                                   
    forma_pagamento VARCHAR(30),
    status VARCHAR(20) NOT NULL DEFAULT 'Pendente',

    CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento),
    CONSTRAINT ck_pagamento_valor CHECK (valor > 0),
    CONSTRAINT ck_pagamento_status CHECK (status IN ('Pago', 'Pendente', 'Atrasado')),
    CONSTRAINT ck_pagamento_forma CHECK (forma_pagamento IS NULL
        OR forma_pagamento IN ('Dinheiro', 'Cartão', 'Pix', 'Boleto')),

    -- RESTRICT: pagamento é registro financeiro e não some junto com a matrícula
    CONSTRAINT fk_pagamento_matricula FOREIGN KEY (id_aluno, id_turma)
        REFERENCES MATRICULA(id_aluno, id_turma) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_pagamento_matricula ON PAGAMENTO(id_aluno, id_turma);

INSERT INTO PAGAMENTO (id_aluno, id_turma, valor, data_pagamento, forma_pagamento, status)
SELECT id_aluno, id_turma, 150.00, data_matricula, 'Pix', 'Pago'
FROM MATRICULA WHERE status_matricula = 'ativa' ORDER BY id_aluno, id_turma LIMIT 10;

INSERT INTO PAGAMENTO (id_aluno, id_turma, valor, data_pagamento, forma_pagamento, status)
SELECT id_aluno, id_turma, 150.00, NULL, NULL, 'Pendente'
FROM MATRICULA WHERE status_matricula = 'ativa' ORDER BY id_aluno DESC, id_turma DESC LIMIT 3;

-- 4. VISÃO do relatório consolidado (B1)
CREATE OR REPLACE VIEW vw_relatorio_geral AS
SELECT t.id_turma, t.turno, t.sala, i.nome_idioma AS idioma,
       COUNT(m.id_aluno) AS total_alunos
FROM TURMA t
LEFT JOIN IDIOMA i    ON t.id_idioma = i.id_idioma
LEFT JOIN MATRICULA m ON t.id_turma = m.id_turma
GROUP BY t.id_turma, t.turno, t.sala, i.nome_idioma;

-- Visão que esconde CPF, e-mail e telefone (B5: princípio do menor privilégio)
CREATE OR REPLACE VIEW vw_aluno_publico AS
SELECT a.id_pessoa, p.nome, a.situacao
FROM ALUNO a INNER JOIN PESSOA p ON p.id_pessoa = a.id_pessoa;

-- 5. AUDITORIA (B6): quem, quando, valor anterior e novo
CREATE TABLE AUDITORIA (
    id_auditoria INT AUTO_INCREMENT,
    tabela VARCHAR(30) NOT NULL,
    chave_registro VARCHAR(50) NOT NULL,
    campo VARCHAR(30) NOT NULL,
    valor_anterior VARCHAR(100),
    valor_novo VARCHAR(100),
    autor VARCHAR(100) NOT NULL,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_auditoria PRIMARY KEY (id_auditoria)
);

DELIMITER $$
-- Muda o status de uma matrícula: é o dado acadêmico mais sensível do domínio
CREATE TRIGGER trg_aud_matricula_status AFTER UPDATE ON MATRICULA
FOR EACH ROW
BEGIN
    IF NOT (OLD.status_matricula <=> NEW.status_matricula) THEN
        INSERT INTO AUDITORIA (tabela, chave_registro, campo, valor_anterior, valor_novo, autor)
        VALUES ('MATRICULA', CONCAT(OLD.id_aluno, '-', OLD.id_turma), 'status_matricula',
                OLD.status_matricula, NEW.status_matricula, USER());
    END IF;
END$$

-- Alteração de valor ou status de um pagamento: dado financeiro
CREATE TRIGGER trg_aud_pagamento_upd AFTER UPDATE ON PAGAMENTO
FOR EACH ROW
BEGIN
    IF NOT (OLD.valor <=> NEW.valor) THEN
        INSERT INTO AUDITORIA (tabela, chave_registro, campo, valor_anterior, valor_novo, autor)
        VALUES ('PAGAMENTO', OLD.id_pagamento, 'valor', OLD.valor, NEW.valor, USER());
    END IF;
    IF NOT (OLD.status <=> NEW.status) THEN
        INSERT INTO AUDITORIA (tabela, chave_registro, campo, valor_anterior, valor_novo, autor)
        VALUES ('PAGAMENTO', OLD.id_pagamento, 'status', OLD.status, NEW.status, USER());
    END IF;
END$$
DELIMITER ;

-- 6. USUÁRIOS DA APLICAÇÃO com senha em hash + sal (B5)
CREATE TABLE USUARIO_APP (
    id_usuario INT AUTO_INCREMENT,
    login VARCHAR(30) NOT NULL,
    sal CHAR(32) NOT NULL,
    senha_hash CHAR(64) NOT NULL,
    perfil VARCHAR(20) NOT NULL,
    CONSTRAINT pk_usuario_app PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_login UNIQUE (login),
    CONSTRAINT ck_usuario_perfil CHECK (perfil IN ('admin', 'secretaria', 'professor'))
);

-- Senha de exemplo 'Trocar@2026' (apenas para teste; troque antes de apresentar)
INSERT INTO USUARIO_APP (login, sal, senha_hash, perfil)
SELECT 'admin', @s := MD5(RAND()), SHA2(CONCAT(@s, 'Trocar@2026'), 256), 'admin';

-- 7. PERFIS DE ACESSO NO MYSQL (B5). Troque as senhas e não versione as reais.
CREATE USER IF NOT EXISTS 'app_secretaria'@'localhost' IDENTIFIED BY 'Trocar#Secretaria1';
CREATE USER IF NOT EXISTS 'app_professor'@'localhost'  IDENTIFIED BY 'Trocar#Professor1';
CREATE USER IF NOT EXISTS 'app_consulta'@'localhost'   IDENTIFIED BY 'Trocar#Consulta1';

-- Secretaria: cadastro, matrícula e financeiro (sem apagar histórico acadêmico)
GRANT SELECT, INSERT, UPDATE, DELETE ON escola_idiomas.PESSOA    TO 'app_secretaria'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON escola_idiomas.ALUNO     TO 'app_secretaria'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON escola_idiomas.IDIOMA    TO 'app_secretaria'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON escola_idiomas.TURMA     TO 'app_secretaria'@'localhost';
GRANT SELECT, INSERT, UPDATE         ON escola_idiomas.MATRICULA TO 'app_secretaria'@'localhost';
GRANT SELECT, INSERT                 ON escola_idiomas.HISTORICO_MATRICULA TO 'app_secretaria'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON escola_idiomas.PAGAMENTO TO 'app_secretaria'@'localhost';
GRANT SELECT ON escola_idiomas.NIVEL     TO 'app_secretaria'@'localhost';
GRANT SELECT ON escola_idiomas.PROFESSOR TO 'app_secretaria'@'localhost';
GRANT SELECT ON escola_idiomas.vw_relatorio_geral TO 'app_secretaria'@'localhost';
GRANT INSERT ON escola_idiomas.AUDITORIA TO 'app_secretaria'@'localhost';

-- Professor: lê turmas e lança frequência/avaliação; só vê alunos pela visão sem dados pessoais
GRANT SELECT ON escola_idiomas.TURMA            TO 'app_professor'@'localhost';
GRANT SELECT ON escola_idiomas.AULA             TO 'app_professor'@'localhost';
GRANT SELECT ON escola_idiomas.vw_aluno_publico TO 'app_professor'@'localhost';
GRANT SELECT, INSERT, UPDATE ON escola_idiomas.FREQUENCIA TO 'app_professor'@'localhost';
GRANT SELECT, INSERT, UPDATE ON escola_idiomas.AVALIACAO  TO 'app_professor'@'localhost';

-- Consulta: somente leitura do relatório
GRANT SELECT ON escola_idiomas.vw_relatorio_geral TO 'app_consulta'@'localhost';
