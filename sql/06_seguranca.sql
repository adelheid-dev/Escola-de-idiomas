-- PROJETO FINAL - ESCOLA DE IDIOMAS
-- B5 - Segurança e controle de acesso
-- Rodar como root, depois do 01_ddl.sql e do 02_carga.sql

SET NAMES utf8mb4;
USE escola_idiomas;


-- 0. LIMPEZA (para poder rodar o script de novo)

DROP USER IF EXISTS 'ana.secretaria'@'localhost', 'joao.professor'@'localhost', 'carla.coordenacao'@'localhost';
DROP ROLE IF EXISTS r_secretaria, r_professor, r_coordenacao;
DROP VIEW IF EXISTS vw_alunos_professor, vw_resumo_turmas;
DROP TABLE IF EXISTS USUARIO_SISTEMA;


-- 1. VISÕES (restringem o que cada perfil enxerga)

-- Professor vê os alunos das turmas, mas SEM CPF, telefone e data de nascimento
CREATE VIEW vw_alunos_professor AS
SELECT m.id_turma, p.id_pessoa AS id_aluno, p.nome, p.email, m.status_matricula
FROM MATRICULA m
INNER JOIN PESSOA p ON p.id_pessoa = m.id_aluno;

-- Coordenação vê só números por turma, sem nenhum dado pessoal
CREATE VIEW vw_resumo_turmas AS
SELECT t.id_turma, i.nome_idioma, n.nome_nivel, t.vagas_totais,
       COUNT(m.id_aluno) AS total_matriculas,
       SUM(m.status_matricula = 'ativa') AS matriculas_ativas
FROM TURMA t
INNER JOIN IDIOMA i ON t.id_idioma = i.id_idioma
INNER JOIN NIVEL n  ON t.id_nivel  = n.id_nivel
LEFT JOIN MATRICULA m ON m.id_turma = t.id_turma
GROUP BY t.id_turma, i.nome_idioma, n.nome_nivel, t.vagas_totais;


-- 2. PERFIS DE ACESSO (roles)

CREATE ROLE r_secretaria, r_professor, r_coordenacao;

-- 2.1 SECRETARIA: cadastra pessoas, turmas e matrículas. Não lança nota nem frequência.
GRANT SELECT, INSERT, UPDATE ON escola_idiomas.PESSOA    TO r_secretaria;
GRANT SELECT, INSERT, UPDATE ON escola_idiomas.ALUNO     TO r_secretaria;
GRANT SELECT, INSERT, UPDATE ON escola_idiomas.PROFESSOR TO r_secretaria;
GRANT SELECT, INSERT, UPDATE ON escola_idiomas.TURMA     TO r_secretaria;
GRANT SELECT, INSERT, UPDATE, DELETE ON escola_idiomas.MATRICULA TO r_secretaria;
GRANT SELECT, INSERT ON escola_idiomas.HISTORICO_MATRICULA TO r_secretaria;
GRANT SELECT, INSERT ON escola_idiomas.CERTIFICADO         TO r_secretaria;
GRANT SELECT ON escola_idiomas.IDIOMA TO r_secretaria;
GRANT SELECT ON escola_idiomas.NIVEL  TO r_secretaria;

-- 2.2 PROFESSOR: registra aula, frequência e avaliação.
--     Não acessa a tabela PESSOA; vê os alunos pela visão (sem CPF).
GRANT SELECT, INSERT, UPDATE ON escola_idiomas.AULA       TO r_professor;
GRANT SELECT, INSERT, UPDATE ON escola_idiomas.FREQUENCIA TO r_professor;
GRANT SELECT, INSERT, UPDATE ON escola_idiomas.AVALIACAO  TO r_professor;
GRANT SELECT ON escola_idiomas.TURMA       TO r_professor;
GRANT SELECT ON escola_idiomas.COMPETENCIA TO r_professor;
GRANT SELECT ON escola_idiomas.vw_alunos_professor TO r_professor;

-- 2.3 COORDENAÇÃO: só consulta, e só pela visão de resumo.
GRANT SELECT ON escola_idiomas.vw_resumo_turmas TO r_coordenacao;


-- 3. REVOKE (retirando o que não deveria ter sido dado)

-- Matrícula não se apaga: cancelar é mudar o status para 'cancelada' (RN07)
REVOKE DELETE ON escola_idiomas.MATRICULA FROM r_secretaria;

-- Depois de lançada, a nota não é alterada pelo professor (correção passa pela secretaria/coordenação)
REVOKE UPDATE ON escola_idiomas.AVALIACAO FROM r_professor;


-- 4. USUÁRIOS DO MYSQL (um por perfil) - senhas fictícias só para teste

CREATE USER 'ana.secretaria'@'localhost'    IDENTIFIED BY 'Secretaria@2026';
CREATE USER 'joao.professor'@'localhost'    IDENTIFIED BY 'Professor@2026';
CREATE USER 'carla.coordenacao'@'localhost' IDENTIFIED BY 'Coordenacao@2026';

GRANT r_secretaria  TO 'ana.secretaria'@'localhost';
GRANT r_professor   TO 'joao.professor'@'localhost';
GRANT r_coordenacao TO 'carla.coordenacao'@'localhost';

-- Ativa o perfil automaticamente quando o usuário faz login
SET DEFAULT ROLE r_secretaria  TO 'ana.secretaria'@'localhost';
SET DEFAULT ROLE r_professor   TO 'joao.professor'@'localhost';
SET DEFAULT ROLE r_coordenacao TO 'carla.coordenacao'@'localhost';


-- 5. USUÁRIOS DA APLICAÇÃO: senha com hash + sal (nunca em texto claro)

CREATE TABLE USUARIO_SISTEMA (
    id_usuario INT AUTO_INCREMENT,
    login      VARCHAR(50) NOT NULL,
    perfil     VARCHAR(20) NOT NULL,
    sal        CHAR(32)    NOT NULL,   -- valor aleatório, diferente para cada usuário
    senha_hash CHAR(64)    NOT NULL,   -- SHA-256 de (sal + senha)

    CONSTRAINT pk_usuario_sistema PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_login UNIQUE (login),
    CONSTRAINT ck_usuario_perfil CHECK (perfil IN ('secretaria', 'professor', 'coordenacao'))
);

-- Para cada usuário: gera um sal aleatório e grava o hash de (sal + senha)
SET @sal = HEX(RANDOM_BYTES(16));
INSERT INTO USUARIO_SISTEMA (login, perfil, sal, senha_hash)
VALUES ('ana.secretaria', 'secretaria', @sal, SHA2(CONCAT(@sal, 'Secretaria@2026'), 256));

SET @sal = HEX(RANDOM_BYTES(16));
INSERT INTO USUARIO_SISTEMA (login, perfil, sal, senha_hash)
VALUES ('joao.professor', 'professor', @sal, SHA2(CONCAT(@sal, 'Professor@2026'), 256));

SET @sal = HEX(RANDOM_BYTES(16));
INSERT INTO USUARIO_SISTEMA (login, perfil, sal, senha_hash)
VALUES ('carla.coordenacao', 'coordenacao', @sal, SHA2(CONCAT(@sal, 'Coordenacao@2026'), 256));

-- O que fica gravado: só sal e hash, a senha não aparece
SELECT login, perfil, sal, senha_hash FROM USUARIO_SISTEMA;

-- Como a aplicação confere o login: calcula o hash com o sal guardado e compara.
-- (Na aplicação Java, login e senha entram como parâmetros "?" do PreparedStatement.)
SELECT login, perfil
FROM USUARIO_SISTEMA
WHERE login = 'joao.professor'
  AND senha_hash = SHA2(CONCAT(sal, 'Professor@2026'), 256);   -- senha certa: retorna 1 linha

SELECT login, perfil
FROM USUARIO_SISTEMA
WHERE login = 'joao.professor'
  AND senha_hash = SHA2(CONCAT(sal, 'senhaErrada'), 256);      -- senha errada: retorna 0 linhas


-- 6. CONFERÊNCIA DOS PRIVILÉGIOS

SHOW GRANTS FOR r_secretaria;
SHOW GRANTS FOR r_professor;
SHOW GRANTS FOR r_coordenacao;


-- 7. TESTES COM LOGIN REAL (rodar em outra conexão, logado com cada usuário)
--
-- Logado como ana.secretaria:
--   UPDATE PESSOA SET telefone = '61999990000' WHERE id_pessoa = 15;   -- funciona
--   DELETE FROM MATRICULA WHERE id_aluno = 1;                            -- negado (REVOKE)
--   INSERT INTO AVALIACAO (id_aluno, id_turma, id_competencia, data_avaliacao, tipo, nota)
--   VALUES (1, 1, 1, '2024-06-01', 'Parcial', 10);                       -- negado
--
-- Logado como joao.professor:
--   SELECT * FROM vw_alunos_professor WHERE id_turma = 1;                -- funciona, sem CPF
--   SELECT nome, cpf FROM PESSOA;                                        -- negado
--   UPDATE AVALIACAO SET nota = 10 WHERE id_avaliacao = 1;               -- negado (REVOKE)
--
-- Logado como carla.coordenacao:
--   SELECT * FROM vw_resumo_turmas;                                      -- funciona
--   SELECT * FROM MATRICULA;                                             -- negado
--   SELECT * FROM USUARIO_SISTEMA;                                       -- negado
