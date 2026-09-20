USE escola_idiomas;

-- BLOCO 1: CONSULTAS BÁSICAS (5)


-- 1. Listar todas as pessoas com sobrenome Silva
SELECT
    id_pessoa,
    nome,
    cpf,
    email
FROM PESSOA
WHERE nome LIKE '%Silva%'
ORDER BY nome;

-- 2. Quais aulas aconteceram entre fevereiro e março de 2024?
-- RN11: aulas numeradas sequencialmente, com data própria
SELECT
    id_turma,
    numero_aula,
    data_aula,
    conteudo_ministrado,
    carga_horaria
FROM AULA
WHERE data_aula BETWEEN '2024-02-01' AND '2024-03-31'
ORDER BY data_aula;

-- 3. Quais turnos de aula a escola oferece?
-- RN05: cada turma tem turno definido
SELECT DISTINCT turno
FROM TURMA
WHERE turno IN ('Matutino', 'Vespertino', 'Noturno')
ORDER BY turno;

-- 4. Quais pessoas não têm telefone cadastrado?
-- telefone é atributo opcional (NULL permitido)
SELECT
    id_pessoa,
    nome,
    email,
    telefone
FROM PESSOA
WHERE telefone IS NULL
ORDER BY nome;

-- 5. Listar todos os níveis de estudo disponíveis
-- RN06: apenas 6 níveis reconhecidos (A1 a C2)
SELECT
    id_nivel,
    nome_nivel,
    descricao
FROM NIVEL
ORDER BY id_nivel;


-- BLOCO 2: CONSULTAS COM JUNÇÕES E AGREGAÇÃO (5)


-- 6. Mostrar aluno, turma e professor responsável de cada matrícula
-- RN05: cada turma tem um professor
-- Junção de 4 tabelas: MATRICULA -> ALUNO -> TURMA -> PROFESSOR -> PESSOA
SELECT
    m.id_aluno,
    m.id_turma,
    m.status_matricula,
    p.nome AS nome_professor
FROM MATRICULA m
INNER JOIN ALUNO a ON m.id_aluno = a.id_pessoa
INNER JOIN TURMA t ON m.id_turma = t.id_turma
INNER JOIN PROFESSOR pr ON t.id_professor = pr.id_pessoa
INNER JOIN PESSOA p ON pr.id_pessoa = p.id_pessoa
ORDER BY m.id_turma;

-- 7. Listar todas as turmas com contagem de matrículas (mesmo com zero)
-- RN07: controle de vagas por turma
SELECT
    t.id_turma,
    t.vagas_totais,
    COUNT(m.id_aluno) AS total_matriculas
FROM TURMA t
LEFT JOIN MATRICULA m ON t.id_turma = m.id_turma
GROUP BY t.id_turma, t.vagas_totais
ORDER BY t.id_turma;

-- 8. Quantos alunos estão em cada turma?
SELECT
    id_turma,
    COUNT(id_aluno) AS total_alunos
FROM MATRICULA
GROUP BY id_turma
ORDER BY id_turma;

-- 9. Quais competências tiveram mais de 5 avaliações?
SELECT
    c.nome_competencia,
    COUNT(av.id_avaliacao) AS total_avaliacoes
FROM AVALIACAO av
INNER JOIN COMPETENCIA c ON av.id_competencia = c.id_competencia
GROUP BY c.id_competencia, c.nome_competencia
HAVING COUNT(av.id_avaliacao) > 5
ORDER BY total_avaliacoes DESC;

-- 10. Qual é a nota média de cada aluno em suas avaliações?
-- RN14: notas entre 0 e 10
SELECT
    av.id_aluno,
    ROUND(AVG(av.nota), 2) AS media_notas,
    COUNT(av.id_avaliacao) AS total_avaliacoes
FROM AVALIACAO av
GROUP BY av.id_aluno
ORDER BY media_notas DESC;


-- BLOCO 3: CONSULTAS AVANÇADAS (6)


-- 11. Quais alunos estão presentes em TODAS as aulas de sua turma?
-- Subconsulta correlacionada compara presenças do aluno com o total de aulas da turma
SELECT DISTINCT
    f.id_aluno,
    f.id_turma
FROM FREQUENCIA f
WHERE f.presente = 1
GROUP BY f.id_aluno, f.id_turma
HAVING COUNT(f.id_aluno) = (
    SELECT COUNT(*)
    FROM AULA
    WHERE id_turma = f.id_turma
)
ORDER BY f.id_turma;

-- 12. Quais turmas têm avaliações registradas?
SELECT
    t.id_turma,
    t.turno
FROM TURMA t
WHERE EXISTS (
    SELECT 1
    FROM AVALIACAO av
    WHERE av.id_turma = t.id_turma
)
ORDER BY t.id_turma;

-- 13. Qual é a frequência (%) de cada aluno em suas turmas?
-- RN13/RN15: base para exigir 80% de presença na avaliação final
SELECT
    m.id_aluno,
    m.id_turma,
    COUNT(CASE WHEN f.presente = 1 THEN 1 END) AS presencas,
    COUNT(f.presente) AS total_aulas,
    ROUND(
        (COUNT(CASE WHEN f.presente = 1 THEN 1 END) / COUNT(f.presente)) * 100,
        1
    ) AS percentual_frequencia
FROM MATRICULA m
LEFT JOIN FREQUENCIA f ON m.id_aluno = f.id_aluno AND m.id_turma = f.id_turma
GROUP BY m.id_aluno, m.id_turma
ORDER BY m.id_turma;

-- 14. Quais alunos foram aprovados (nota final >= 6.0)?
-- RN16: aprovado se frequência >= 80% E nota >= 6.0
SELECT
    av.id_aluno,
    av.id_turma,
    av.nota
FROM AVALIACAO av
WHERE av.tipo = 'Final'
    AND av.nota >= 6.0
ORDER BY av.id_aluno;

-- 15. Quantos certificados foram emitidos por turma?
-- RN17/RN18: certificado só para aprovados, um por turma
SELECT
    id_turma,
    COUNT(id_certificado) AS total_certificados
FROM CERTIFICADO
GROUP BY id_turma
ORDER BY id_turma;

-- 16. Qual o histórico de mudanças de status de cada matrícula?
-- Consulta que valida a tabela HISTORICO_MATRICULA (entidade fraca de MATRICULA)
SELECT
    h.id_aluno,
    h.id_turma,
    h.numero_sequencia,
    h.status_anterior,
    h.status_novo,
    h.data_mudanca
FROM HISTORICO_MATRICULA h
ORDER BY h.id_aluno, h.id_turma, h.numero_sequencia;