-- PROJETO FINAL - ESCOLA DE IDIOMAS
-- B4: Otimização de consultas

-- Três consultas: vagas ocupadas da turma, aulas por período e média das notas finais.
-- Em cada uma: EXPLAIN antes, cria o índice e EXPLAIN depois.
-- O EXPLAIN ANALYZE executa a consulta e mostra o tempo (actual time, em ms).
--
-- Antes de tudo, o 01_ddl.sql e o 02_carga.sql precisam ser rodados de novo,
-- senão os índices já vão existir.

USE escola_idiomas;

-- atualiza as estatísticas das tabelas
ANALYZE TABLE MATRICULA, AULA, AVALIACAO;

-- volume usado nos testes
SELECT 'MATRICULA' AS tabela, COUNT(*) AS linhas FROM MATRICULA
UNION ALL SELECT 'AULA', COUNT(*) FROM AULA
UNION ALL SELECT 'AVALIACAO', COUNT(*) FROM AVALIACAO;



-- CONSULTA 1 - VAGAS OCUPADAS DA TURMA (RN07)
-- É a contagem usada na matrícula do 04_transacoes.sql.

-- resultado esperado: 6
SELECT COUNT(*) AS ocupadas FROM MATRICULA
WHERE id_turma = 10 AND status_matricula IN ('ativa', 'trancada');

SHOW INDEX FROM MATRICULA;

-- ANTES
EXPLAIN
SELECT COUNT(*) AS ocupadas FROM MATRICULA
WHERE id_turma = 10 AND status_matricula IN ('ativa', 'trancada');

EXPLAIN ANALYZE
SELECT COUNT(*) AS ocupadas FROM MATRICULA
WHERE id_turma = 10 AND status_matricula IN ('ativa', 'trancada');

-- ÍNDICE: id_turma primeiro porque separa a turma e também serve pra FK
CREATE INDEX idx_matricula_turma_status ON MATRICULA (id_turma, status_matricula);

-- DEPOIS
EXPLAIN
SELECT COUNT(*) AS ocupadas FROM MATRICULA
WHERE id_turma = 10 AND status_matricula IN ('ativa', 'trancada');

EXPLAIN ANALYZE
SELECT COUNT(*) AS ocupadas FROM MATRICULA
WHERE id_turma = 10 AND status_matricula IN ('ativa', 'trancada');

-- continua dando 6
SELECT COUNT(*) AS ocupadas FROM MATRICULA
WHERE id_turma = 10 AND status_matricula IN ('ativa', 'trancada');

-- o fk_matricula_turma sumiu: o MySQL passou a usar o índice novo pra FK
SHOW INDEX FROM MATRICULA;



-- CONSULTA 2 - AULAS DADAS EM UM PERÍODO (RN11)

-- resultado esperado: 12 aulas
SELECT id_turma, numero_aula, data_aula, conteudo_ministrado, duracao_minutos
FROM AULA
WHERE data_aula BETWEEN '2024-02-01' AND '2024-03-31'
ORDER BY data_aula, id_turma;

SHOW INDEX FROM AULA;

-- ANTES
EXPLAIN
SELECT id_turma, numero_aula, data_aula, conteudo_ministrado, duracao_minutos
FROM AULA
WHERE data_aula BETWEEN '2024-02-01' AND '2024-03-31'
ORDER BY data_aula, id_turma;

EXPLAIN ANALYZE
SELECT id_turma, numero_aula, data_aula, conteudo_ministrado, duracao_minutos
FROM AULA
WHERE data_aula BETWEEN '2024-02-01' AND '2024-03-31'
ORDER BY data_aula, id_turma;

-- ÍNDICE: só data_aula, que é a coluna do BETWEEN
CREATE INDEX idx_aula_data ON AULA (data_aula);

-- DEPOIS
EXPLAIN
SELECT id_turma, numero_aula, data_aula, conteudo_ministrado, duracao_minutos
FROM AULA
WHERE data_aula BETWEEN '2024-02-01' AND '2024-03-31'
ORDER BY data_aula, id_turma;

EXPLAIN ANALYZE
SELECT id_turma, numero_aula, data_aula, conteudo_ministrado, duracao_minutos
FROM AULA
WHERE data_aula BETWEEN '2024-02-01' AND '2024-03-31'
ORDER BY data_aula, id_turma;

-- continua dando as mesmas 12 aulas
SELECT id_turma, numero_aula, data_aula, conteudo_ministrado, duracao_minutos
FROM AULA
WHERE data_aula BETWEEN '2024-02-01' AND '2024-03-31'
ORDER BY data_aula, id_turma;



-- CONSULTA 3 - MÉDIA DAS NOTAS FINAIS POR COMPETÊNCIA E IDIOMA

-- resultado esperado: 12 linhas
SELECT c.nome_competencia, i.nome_idioma,
       COUNT(*) AS qtd_notas, ROUND(AVG(av.nota), 2) AS media
FROM AVALIACAO av
INNER JOIN COMPETENCIA c ON av.id_competencia = c.id_competencia
INNER JOIN TURMA t       ON av.id_turma = t.id_turma
INNER JOIN IDIOMA i      ON t.id_idioma = i.id_idioma
WHERE av.tipo = 'Final'
GROUP BY c.id_competencia, c.nome_competencia, i.id_idioma, i.nome_idioma
HAVING COUNT(*) >= 3
ORDER BY media DESC;

SHOW INDEX FROM AVALIACAO;

-- ANTES
EXPLAIN
SELECT c.nome_competencia, i.nome_idioma,
       COUNT(*) AS qtd_notas, ROUND(AVG(av.nota), 2) AS media
FROM AVALIACAO av
INNER JOIN COMPETENCIA c ON av.id_competencia = c.id_competencia
INNER JOIN TURMA t       ON av.id_turma = t.id_turma
INNER JOIN IDIOMA i      ON t.id_idioma = i.id_idioma
WHERE av.tipo = 'Final'
GROUP BY c.id_competencia, c.nome_competencia, i.id_idioma, i.nome_idioma
HAVING COUNT(*) >= 3
ORDER BY media DESC;

EXPLAIN ANALYZE
SELECT c.nome_competencia, i.nome_idioma,
       COUNT(*) AS qtd_notas, ROUND(AVG(av.nota), 2) AS media
FROM AVALIACAO av
INNER JOIN COMPETENCIA c ON av.id_competencia = c.id_competencia
INNER JOIN TURMA t       ON av.id_turma = t.id_turma
INNER JOIN IDIOMA i      ON t.id_idioma = i.id_idioma
WHERE av.tipo = 'Final'
GROUP BY c.id_competencia, c.nome_competencia, i.id_idioma, i.nome_idioma
HAVING COUNT(*) >= 3
ORDER BY media DESC;

-- quantas avaliações são finais (96 de 308)
SELECT tipo, COUNT(*) AS qtd FROM AVALIACAO GROUP BY tipo;

-- ÍNDICE: tipo, que é a coluna do WHERE
CREATE INDEX idx_avaliacao_tipo ON AVALIACAO (tipo);

-- DEPOIS (o índice aparece em possible_keys, mas não em key)
EXPLAIN
SELECT c.nome_competencia, i.nome_idioma,
       COUNT(*) AS qtd_notas, ROUND(AVG(av.nota), 2) AS media
FROM AVALIACAO av
INNER JOIN COMPETENCIA c ON av.id_competencia = c.id_competencia
INNER JOIN TURMA t       ON av.id_turma = t.id_turma
INNER JOIN IDIOMA i      ON t.id_idioma = i.id_idioma
WHERE av.tipo = 'Final'
GROUP BY c.id_competencia, c.nome_competencia, i.id_idioma, i.nome_idioma
HAVING COUNT(*) >= 3
ORDER BY media DESC;

EXPLAIN ANALYZE
SELECT c.nome_competencia, i.nome_idioma,
       COUNT(*) AS qtd_notas, ROUND(AVG(av.nota), 2) AS media
FROM AVALIACAO av
INNER JOIN COMPETENCIA c ON av.id_competencia = c.id_competencia
INNER JOIN TURMA t       ON av.id_turma = t.id_turma
INNER JOIN IDIOMA i      ON t.id_idioma = i.id_idioma
WHERE av.tipo = 'Final'
GROUP BY c.id_competencia, c.nome_competencia, i.id_idioma, i.nome_idioma
HAVING COUNT(*) >= 3
ORDER BY media DESC;

-- forçando o índice: lê as 96 finais uma vez pra cada turma e fica mais lento
EXPLAIN ANALYZE
SELECT c.nome_competencia, i.nome_idioma,
       COUNT(*) AS qtd_notas, ROUND(AVG(av.nota), 2) AS media
FROM AVALIACAO av FORCE INDEX (idx_avaliacao_tipo)
INNER JOIN COMPETENCIA c ON av.id_competencia = c.id_competencia
INNER JOIN TURMA t       ON av.id_turma = t.id_turma
INNER JOIN IDIOMA i      ON t.id_idioma = i.id_idioma
WHERE av.tipo = 'Final'
GROUP BY c.id_competencia, c.nome_competencia, i.id_idioma, i.nome_idioma
HAVING COUNT(*) >= 3
ORDER BY media DESC;

-- o índice não ajudou (tipo só tem 2 valores), então removemos
DROP INDEX idx_avaliacao_tipo ON AVALIACAO;
