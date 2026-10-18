-- PROJETO FINAL - ESCOLA DE IDIOMAS
-- Consultas de verificação 

SET NAMES utf8mb4;
USE escola_idiomas;

-- BLOCO 1: CONSULTAS BÁSICAS (5) - projeção, WHERE, ORDER BY, LIKE, BETWEEN, IN, NULL

-- 1. Quais pessoas têm sobrenome Silva?
SELECT id_pessoa, nome, cpf, email
FROM PESSOA
WHERE nome LIKE '% Silva'
ORDER BY nome;

-- 2. Quais aulas aconteceram entre fevereiro e março de 2024? (RN11)
SELECT id_turma, numero_aula, data_aula, conteudo_ministrado, duracao_minutos
FROM AULA
WHERE data_aula BETWEEN '2024-02-01' AND '2024-03-31'
ORDER BY data_aula, id_turma;

-- 3. Quais turnos a escola oferece? (domínio de turno)
SELECT DISTINCT turno
FROM TURMA
WHERE turno IN ('Matutino', 'Vespertino', 'Noturno')
ORDER BY turno;

-- 4. Quais pessoas não têm telefone cadastrado? (telefone é opcional)
SELECT id_pessoa, nome, email
FROM PESSOA
WHERE telefone IS NULL
ORDER BY nome;

-- 5. Quais são os níveis e seus pré-requisitos? (RN06, autorrelacionamento)
SELECT n.nome_nivel, n.descricao, COALESCE(p.nome_nivel, '— (nível de entrada)') AS pre_requisito
FROM NIVEL n
LEFT JOIN NIVEL p ON n.id_nivel_prerequisito = p.id_nivel
ORDER BY n.id_nivel;



-- BLOCO 2: JUNÇÕES E AGREGAÇÃO (5) - 3+ tabelas, LEFT JOIN, GROUP BY e HAVING

-- 6. Aluno, idioma/nível da turma e professor responsável de cada matrícula (RN05)
SELECT pa.nome AS aluno,
       t.id_turma,
       i.nome_idioma, n.nome_nivel, t.turno,
       pp.nome AS professor,
       m.status_matricula
FROM MATRICULA m
INNER JOIN ALUNO a       ON m.id_aluno = a.id_pessoa
INNER JOIN PESSOA pa     ON a.id_pessoa = pa.id_pessoa
INNER JOIN TURMA t       ON m.id_turma = t.id_turma
INNER JOIN IDIOMA i      ON t.id_idioma = i.id_idioma
INNER JOIN NIVEL n       ON t.id_nivel = n.id_nivel
INNER JOIN PROFESSOR pr  ON t.id_professor = pr.id_pessoa
INNER JOIN PESSOA pp     ON pr.id_pessoa = pp.id_pessoa
ORDER BY t.id_turma, pa.nome;

-- 7. Ocupação de vagas por turma, incluindo turmas sem matrícula (RN07)
--    Ocupam vaga as matrículas 'ativa' e 'trancada'.
SELECT t.id_turma, i.nome_idioma, n.nome_nivel, t.vagas_totais,
       COALESCE(SUM(m.status_matricula IN ('ativa','trancada')), 0) AS vagas_ocupadas,
       t.vagas_totais - COALESCE(SUM(m.status_matricula IN ('ativa','trancada')), 0) AS vagas_livres,
       COUNT(m.id_aluno) AS total_historico_matriculas
FROM TURMA t
INNER JOIN IDIOMA i ON t.id_idioma = i.id_idioma
INNER JOIN NIVEL n  ON t.id_nivel = n.id_nivel
LEFT JOIN MATRICULA m ON t.id_turma = m.id_turma
GROUP BY t.id_turma, i.nome_idioma, n.nome_nivel, t.vagas_totais
ORDER BY t.id_turma;

-- 8. Quantas matrículas cada turma tem por status? (RN08)
SELECT id_turma,
       SUM(status_matricula = 'ativa')     AS ativas,
       SUM(status_matricula = 'trancada')  AS trancadas,
       SUM(status_matricula = 'concluída') AS concluidas,
       SUM(status_matricula = 'cancelada') AS canceladas,
       COUNT(*) AS total
FROM MATRICULA
GROUP BY id_turma
ORDER BY id_turma;

-- 9. Média das notas finais por competência e idioma (somente grupos com 3 ou mais notas finais)
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

-- 10. Média das notas finais de cada aluno, por turma (RN14)
SELECT p.nome AS aluno, av.id_turma,
       ROUND(AVG(av.nota), 2) AS media_final,
       COUNT(*) AS qtd_competencias
FROM AVALIACAO av
INNER JOIN PESSOA p ON av.id_aluno = p.id_pessoa
WHERE av.tipo = 'Final'
GROUP BY av.id_aluno, p.nome, av.id_turma
ORDER BY media_final DESC;



-- BLOCO 3: AVANÇADAS (5) - subconsulta correlacionada, EXISTS e perguntas de negócio não triviais


-- 11. Quem esteve presente em TODAS as aulas da turma? (assiduidade perfeita)
SELECT p.nome AS aluno, f.id_turma, COUNT(*) AS presencas
FROM FREQUENCIA f
INNER JOIN PESSOA p ON f.id_aluno = p.id_pessoa
WHERE f.presente = 1
GROUP BY f.id_aluno, p.nome, f.id_turma
HAVING COUNT(*) = (SELECT COUNT(*) FROM AULA a WHERE a.id_turma = f.id_turma)
ORDER BY f.id_turma, p.nome;

-- 12. Turmas com e sem avaliação final registrada (EXISTS / NOT EXISTS)
SELECT t.id_turma, i.nome_idioma, n.nome_nivel,
       CASE WHEN EXISTS (SELECT 1 FROM AVALIACAO av
                         WHERE av.id_turma = t.id_turma AND av.tipo = 'Final')
            THEN 'Com avaliação final' ELSE 'Sem avaliação final (em andamento)' END AS situacao_avaliacao
FROM TURMA t
INNER JOIN IDIOMA i ON t.id_idioma = i.id_idioma
INNER JOIN NIVEL n  ON t.id_nivel = n.id_nivel
ORDER BY t.id_turma;

-- 13. Elegibilidade à avaliação final (RN15): quem tem 80% ou mais de presença?
--     Considera matrículas ativas ou concluídas.
SELECT p.nome AS aluno, m.id_turma, m.status_matricula,
       ROUND(SUM(f.presente) / ta.total_aulas * 100, 1) AS percentual_frequencia,
       CASE WHEN SUM(f.presente) / ta.total_aulas >= 0.80
            THEN 'ELEGÍVEL' ELSE 'NÃO ELEGÍVEL (frequência < 80%)' END AS situacao_final,
       EXISTS (SELECT 1 FROM AVALIACAO av
               WHERE av.id_aluno = m.id_aluno AND av.id_turma = m.id_turma
                 AND av.tipo = 'Final') AS fez_avaliacao_final
FROM MATRICULA m
INNER JOIN PESSOA p ON m.id_aluno = p.id_pessoa
INNER JOIN (SELECT id_turma, COUNT(*) AS total_aulas FROM AULA GROUP BY id_turma) ta
        ON ta.id_turma = m.id_turma
INNER JOIN FREQUENCIA f ON f.id_aluno = m.id_aluno AND f.id_turma = m.id_turma
WHERE m.status_matricula IN ('ativa', 'concluída')
GROUP BY m.id_aluno, p.nome, m.id_turma, m.status_matricula, ta.total_aulas
ORDER BY m.id_turma, percentual_frequencia DESC;

-- 14. Resultado final de cada matrícula concluída (RN16): aprovado, reprovado por frequência
--     ou reprovado por nota, e se há certificado emitido.
SELECT p.nome AS aluno, m.id_turma,
       ROUND(SUM(f.presente) / ta.total_aulas * 100, 1) AS percentual_frequencia,
       (SELECT ROUND(AVG(av.nota), 2) FROM AVALIACAO av
         WHERE av.id_aluno = m.id_aluno AND av.id_turma = m.id_turma AND av.tipo = 'Final') AS nota_final,
       CASE
         WHEN SUM(f.presente) / ta.total_aulas < 0.80 THEN 'Reprovado por frequência'
         WHEN (SELECT AVG(av.nota) FROM AVALIACAO av
                WHERE av.id_aluno = m.id_aluno AND av.id_turma = m.id_turma AND av.tipo = 'Final') < 6.0
              THEN 'Reprovado por nota'
         ELSE 'Aprovado'
       END AS resultado,
       EXISTS (SELECT 1 FROM CERTIFICADO c
               WHERE c.id_aluno = m.id_aluno AND c.id_turma = m.id_turma) AS possui_certificado
FROM MATRICULA m
INNER JOIN PESSOA p ON m.id_aluno = p.id_pessoa
INNER JOIN (SELECT id_turma, COUNT(*) AS total_aulas FROM AULA GROUP BY id_turma) ta
        ON ta.id_turma = m.id_turma
INNER JOIN FREQUENCIA f ON f.id_aluno = m.id_aluno AND f.id_turma = m.id_turma
WHERE m.status_matricula = 'concluída'
GROUP BY m.id_aluno, p.nome, m.id_turma, ta.total_aulas
ORDER BY m.id_turma, resultado, p.nome;

-- 15. Mentores elegíveis (RN19/RN20): alunos com nota final >= 7,0 por idioma,
--     quantos mentorados já acompanham (situação diferente de Cancelada) e vagas restantes (limite 5).
SELECT p.nome AS possivel_mentor, i.nome_idioma, MAX(c.nota_final) AS melhor_nota,
       (SELECT COUNT(*) FROM MENTORIA me
         WHERE me.id_mentor = c.id_aluno AND me.id_idioma = i.id_idioma
           AND me.situacao <> 'Cancelada') AS mentorados_atuais,
       5 - (SELECT COUNT(*) FROM MENTORIA me
             WHERE me.id_mentor = c.id_aluno AND me.id_idioma = i.id_idioma
               AND me.situacao <> 'Cancelada') AS vagas_restantes
FROM CERTIFICADO c
INNER JOIN TURMA t  ON c.id_turma = t.id_turma
INNER JOIN IDIOMA i ON t.id_idioma = i.id_idioma
INNER JOIN PESSOA p ON c.id_aluno = p.id_pessoa
WHERE c.nota_final >= 7.0
GROUP BY c.id_aluno, p.nome, i.id_idioma, i.nome_idioma
ORDER BY i.nome_idioma, melhor_nota DESC;