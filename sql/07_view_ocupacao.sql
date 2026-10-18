-- Etapa 2 · B1 — 
USE escola_idiomas;
-- Relatório consolidado de ocupação (B1): uma linha por turma, com dados que não estão na tela de Turmas.
-- Conta só matrículas que OCUPAM vaga (ativa e trancada, como no RN07 do 04_transacoes.sql).
-- A vw_relatorio_geral conta todas, inclusive canceladas e concluídas.
CREATE OR REPLACE VIEW vw_relatorio_ocupacao AS
SELECT t.id_turma,
       i.nome_idioma                                              AS idioma,
       n.nome_nivel                                               AS nivel,
       t.turno,
       t.sala,
       p.nome                                                     AS professor,
       t.vagas_totais,
       COUNT(CASE WHEN m.status_matricula IN ('ativa','trancada') THEN 1 END)   AS matriculas_ativas,
       t.vagas_totais - COUNT(CASE WHEN m.status_matricula IN ('ativa','trancada') THEN 1 END) AS vagas_livres,
       ROUND(100 * COUNT(CASE WHEN m.status_matricula IN ('ativa','trancada') THEN 1 END) / t.vagas_totais, 1) AS ocupacao_pct
FROM turma t
JOIN idioma    i  ON i.id_idioma    = t.id_idioma
JOIN nivel     n  ON n.id_nivel     = t.id_nivel
JOIN professor pr ON pr.id_pessoa   = t.id_professor
JOIN pessoa    p  ON p.id_pessoa    = pr.id_pessoa
LEFT JOIN matricula m ON m.id_turma = t.id_turma
GROUP BY t.id_turma, i.nome_idioma, n.nome_nivel, t.turno, t.sala, p.nome, t.vagas_totais;

-- Quem pode ver o relatório (perfis criados no 06_seguranca.sql)
GRANT SELECT ON escola_idiomas.vw_relatorio_ocupacao TO r_secretaria;
GRANT SELECT ON escola_idiomas.vw_relatorio_ocupacao TO r_coordenacao;