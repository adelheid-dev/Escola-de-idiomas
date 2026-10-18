-- PROJETO FINAL - ESCOLA DE IDIOMAS
-- B3: Transações e concorrência

-- A operação que escolhemos é a matrícula de um aluno numa turma.
-- Ela mexe em duas tabelas: MATRICULA e HISTORICO_MATRICULA.
-- Antes de matricular, travamos a turma (FOR UPDATE) e conferimos se ainda tem vaga (RN07).
--
-- Precisa de duas conexões abertas no Workbench: Sessão A e Sessão B.
-- Antes de tudo, o 01_ddl.sql e o 02_carga.sql precisam ter sido rodados.
--
-- Partes:
--   Preparação - limpa os testes anteriores
--   Parte 0    - confere as duas sessões e o nível de isolamento
--   Parte 1    - matrícula que dá certo (COMMIT)
--   Parte 2    - matrícula que dá erro no meio (ROLLBACK)
--   Parte 3    - duas sessões disputando a última vaga (bloqueio e espera)

USE escola_idiomas;


-- PREPARAÇÃO (Sessão A)
-- Apaga as matrículas de teste de execuções anteriores e volta a turma 10 para 10 vagas.

DELETE FROM HISTORICO_MATRICULA WHERE id_turma = 10 AND id_aluno IN (12, 13);
DELETE FROM MATRICULA           WHERE id_turma = 10 AND id_aluno IN (12, 13);
UPDATE TURMA SET vagas_totais = 10 WHERE id_turma = 10;



-- PARTE 0 - AMBIENTE (rodar nas duas sessões)
-- Os IDs de conexão têm que ser diferentes, senão é a mesma sessão.
-- O nível de isolamento deve aparecer como REPEATABLE-READ, que é o padrão do MySQL.

SELECT CONNECTION_ID(), @@transaction_isolation, @@autocommit;



-- PARTE 1 - MATRÍCULA COM SUCESSO (Sessão A)
-- Aluno 12 (Luiz Barbosa) na turma 10, que tem 10 vagas e 6 ocupadas.

START TRANSACTION;

-- trava a turma 10: ninguém mais consegue matricular nela até o COMMIT
SELECT id_turma, vagas_totais FROM TURMA WHERE id_turma = 10 FOR UPDATE;

-- conta quantas vagas estão ocupadas (ativa e trancada ocupam vaga) 
SELECT COUNT(*) AS ocupadas FROM MATRICULA
WHERE id_turma = 10 AND status_matricula IN ('ativa', 'trancada');

-- tem vaga, então insere a matrícula
INSERT INTO MATRICULA (id_aluno, id_turma, data_matricula, status_matricula, forma_pagamento)
VALUES (12, 10, CURDATE(), 'ativa', 'PIX');

-- e registra o primeiro status no histórico
INSERT INTO HISTORICO_MATRICULA (id_aluno, id_turma, numero_sequencia, status_anterior, status_novo, data_mudanca)
VALUES (12, 10, 1, NULL, 'ativa', NOW());

-- confirma as duas inserções juntas
COMMIT;

-- conferindo: tem que aparecer uma linha em cada tabela
SELECT * FROM MATRICULA           WHERE id_aluno = 12 AND id_turma = 10;
SELECT * FROM HISTORICO_MATRICULA WHERE id_aluno = 12 AND id_turma = 10;



-- PARTE 2 - FALHA NO MEIO DA TRANSAÇÃO (Sessão A)
-- Aluno 13 (Marina Teixeira) na turma 10.
-- De propósito, colocamos um status que não existe ('aprovada') no histórico,
-- pra simular um erro da aplicação no meio da matrícula.

START TRANSACTION;

-- essa parte funciona normal
INSERT INTO MATRICULA (id_aluno, id_turma, data_matricula, status_matricula, forma_pagamento)
VALUES (13, 10, CURDATE(), 'ativa', 'PIX');

-- aqui dá erro: a constraint ck_historico_status_novo não aceita 'aprovada'
INSERT INTO HISTORICO_MATRICULA (id_aluno, id_turma, numero_sequencia, status_anterior, status_novo, data_mudanca)
VALUES (13, 10, 1, NULL, 'aprovada', NOW());

-- a matrícula ainda aparece, o erro só cancela o comando que falhou,
-- não a transação inteira. A matrícula fica pendente esperando um COMMIT ou ROLLBACK.
SELECT * FROM MATRICULA WHERE id_aluno = 13 AND id_turma = 10;

-- então desfazemos tudo
ROLLBACK;

-- conferindo: as duas consultas voltam vazias, o banco continua certinho
SELECT * FROM MATRICULA           WHERE id_aluno = 13 AND id_turma = 10;
SELECT * FROM HISTORICO_MATRICULA WHERE id_aluno = 13 AND id_turma = 10;



-- PARTE 3 - CONCORRÊNCIA (Sessão A e Sessão B)
-- Duas secretárias tentando matricular alguém na última vaga da turma 10 ao mesmo tempo.

-- [Sessão A] deixa a turma com 8 vagas. Como já tem 7 ocupadas, sobra só 1.
UPDATE TURMA SET vagas_totais = 8 WHERE id_turma = 10;

-- [Sessão A] começa a matrícula e trava a turma
START TRANSACTION;
SELECT id_turma, vagas_totais FROM TURMA WHERE id_turma = 10 FOR UPDATE;
SELECT COUNT(*) AS ocupadas FROM MATRICULA
WHERE id_turma = 10 AND status_matricula IN ('ativa', 'trancada');
-- deu 7 de 8, tem uma vaga. Ainda não dá COMMIT.

-- [Sessão B] tenta travar a mesma turma
START TRANSACTION;
SELECT id_turma, vagas_totais FROM TURMA WHERE id_turma = 10 FOR UPDATE;
-- a Sessão B fica parada esperando, porque a Sessão A está segurando a turma

-- [Sessão A] enquanto a B espera, dá pra ver quem está travando quem
-- waiting_pid é a Sessão B e blocking_pid é a Sessão A
SELECT waiting_pid, waiting_query, blocking_pid, wait_age
FROM sys.innodb_lock_waits;

-- [Sessão A] matricula o aluno 13 na última vaga e confirma
INSERT INTO MATRICULA (id_aluno, id_turma, data_matricula, status_matricula, forma_pagamento)
VALUES (13, 10, CURDATE(), 'ativa', 'PIX');
INSERT INTO HISTORICO_MATRICULA (id_aluno, id_turma, numero_sequencia, status_anterior, status_novo, data_mudanca)
VALUES (13, 10, 1, NULL, 'ativa', NOW());
COMMIT;
-- na hora do COMMIT a Sessão B destrava e mostra o resultado

-- [Sessão B] conta de novo e agora vê a turma cheia (8 de 8)
SELECT COUNT(*) AS ocupadas FROM MATRICULA
WHERE id_turma = 10 AND status_matricula IN ('ativa', 'trancada');
-- não tem mais vaga, então a B desiste
ROLLBACK;

-- conferindo: 8 vagas e 8 ocupadas, ninguém passou do limite
SELECT t.vagas_totais,
       (SELECT COUNT(*) FROM MATRICULA m
         WHERE m.id_turma = t.id_turma AND m.status_matricula IN ('ativa', 'trancada')) AS ocupadas
FROM TURMA t WHERE t.id_turma = 10;

-- [Sessão A] volta a turma para 10 vagas
UPDATE TURMA SET vagas_totais = 10 WHERE id_turma = 10;

-- Sem o FOR UPDATE, as duas sessões iam ler "7 ocupadas" ao mesmo tempo e as duas
-- iam matricular, ficando 9 alunos numa turma de 8 vagas.



-- NÍVEL DE ISOLAMENTO ESCOLHIDO: REPEATABLE READ (padrão do MySQL)
-- Ele já impede que uma transação leia dados que outra ainda não confirmou
-- e que a mesma leitura mude no meio da transação.
-- O ponto crítico do sistema é a última vaga da turma (RN07). Pra ele usamos
-- o FOR UPDATE só na linha da turma, em vez de deixar o banco inteiro em
-- SERIALIZABLE, que travaria até as consultas e relatórios sem necessidade.