-- PROJETO FINAL - ESCOLA DE IDIOMAS


USE escola_idiomas;

-- 1. PESSOAS (RN01, RN02, RN04)
INSERT INTO PESSOA (nome, cpf, email, telefone, data_nascimento) VALUES
('Ana Silva', '12345678901', 'ana.silva@email.com', '61987654321', '2000-05-15'),
('Bruno Costa', '23456789012', 'bruno.costa@email.com', '61987654322', '2001-08-20'),
('Carla Oliveira', '34567890123', 'carla.oliveira@email.com', '61987654323', '1999-12-10'),
('Diego Pereira', '45678901234', 'diego.pereira@email.com', '61987654324', '2002-03-25'),
('Elena Ferreira', '56789012345', 'elena.ferreira@email.com', '61987654325', '2000-07-08'),
('Felipe Martins', '67890123456', 'felipe.martins@email.com', '61987654326', '2001-11-30'),
('Gabriela Santos', '78901234567', 'gabriela.santos@email.com', '61987654327', '1999-04-18'),
('Henrique Alves', '89012345678', 'henrique.alves@email.com', '61987654328', '2002-09-12'),
('Iris Rocha', '90123456789', 'iris.rocha@email.com', '61987654329', '2000-01-22'),
('Juliana Gomes', '01234567890', 'juliana.gomes@email.com', '61987654330', '2001-06-14'),
('Prof. João Tavares', '11111111111', 'joao.tavares@email.com', '61999999901', '1985-02-10'),
('Prof. Maria Souza', '22222222222', 'maria.souza@email.com', '61999999902', '1987-08-15'),
('Prof. Carlos Mendes', '33333333333', 'carlos.mendes@email.com', '61999999903', '1980-11-22'),
('Prof. Patricia Luna', '44444444444', 'patricia.luna@email.com', '61999999904', '1988-05-18'),
('Prof. Roberto Silva', '55555555555', 'roberto.silva@email.com', '61999999905', '1982-09-30'),
('Karol Ribeiro', '12312312344', 'karol.ribeiro@email.com', '61987654331', '2000-10-05'),
('Luiz Barbosa', '12412412345', 'luiz.barbosa@email.com', '61987654332', '2002-02-28'),
('Marina Teixeira', '12512512346', 'marina.teixeira@email.com', '61987654333', '1999-09-11'),
('Nicolas Campos', '12612612347', 'nicolas.campos@email.com', '61987654334', '2001-12-19'),
('Olivia Correia', '12712712348', 'olivia.correia@email.com', NULL, '2000-04-07'),
('Patricia Duarte', '12812812349', 'patricia.duarte@email.com', '61987654335', '2002-07-23'),
('Quentin Moreira', '12912912350', 'quentin.moreira@email.com', '61987654336', '2000-11-02'),
('Rita Franco', '13013013351', 'rita.franco@email.com', '61987654337', '1999-03-16'),
('Samuel Neves', '13113113352', 'samuel.neves@email.com', NULL, '2001-08-29'),
('Tania Costa', '13213213353', 'tania.costa@email.com', '61987654338', '2000-06-12');

-- 2. ALUNOS (id_pessoa 1-10, 16-25)
INSERT INTO ALUNO (id_pessoa, data_matricula_inicial, situacao) VALUES
(1, '2024-01-15', 'Ativo'), (2, '2024-01-15', 'Ativo'), (3, '2024-02-10', 'Ativo'),
(4, '2024-02-10', 'Inativo'), (5, '2024-03-05', 'Ativo'), (6, '2024-01-20', 'Ativo'),
(7, '2024-03-15', 'Ativo'), (8, '2024-04-01', 'Ativo'), (9, '2024-02-20', 'Suspenso'),
(10, '2024-04-10', 'Ativo'), (16, '2024-01-25', 'Ativo'), (17, '2024-02-15', 'Ativo'),
(18, '2024-03-20', 'Inativo'), (19, '2024-04-05', 'Ativo'), (20, '2024-01-30', 'Ativo'),
(21, '2024-02-25', 'Ativo'), (22, '2024-03-10', 'Ativo'), (23, '2024-04-15', 'Ativo'),
(24, '2024-02-05', 'Ativo'), (25, '2024-03-25', 'Ativo');

-- 3. PROFESSORES (id_pessoa 11-15)
INSERT INTO PROFESSOR (id_pessoa, data_contratacao, carga_horaria_semanal, situacao) VALUES
(11, '2020-01-15', 20, 'Ativo'),
(12, '2021-03-10', 25, 'Ativo'),
(13, '2019-05-20', 30, 'Ativo'),
(14, '2022-02-01', 15, 'Ativo'),
(15, '2023-06-15', 20, 'Licenciado');

-- 4. IDIOMAS
INSERT INTO IDIOMA (nome_idioma) VALUES ('Inglês'), ('Espanhol'), ('Francês');

-- 5. NÍVEIS
-- RN06: A1 sem pré-requisito; cada nível seguinte aponta para o anterior
INSERT INTO NIVEL (nome_nivel, descricao, id_nivel_prerequisito) VALUES
('A1', 'Iniciante', NULL),
('A2', 'Elementar', 1),
('B1', 'Intermediário', 2),
('B2', 'Intermediário Superior', 3),
('C1', 'Avançado', 4),
('C2', 'Proficiente', 5);

-- 6. TURMAS
INSERT INTO TURMA (id_idioma, id_nivel, id_professor, turno, data_inicio, data_fim, vagas_totais, sala) VALUES
(1, 1, 11, 'Matutino', '2024-01-10', '2024-06-30', 20, '101'),
(1, 2, 11, 'Vespertino', '2024-01-10', '2024-06-30', 18, '102'),
(1, 3, 12, 'Noturno', '2024-01-10', NULL, 25, '103'),
(2, 1, 12, 'Matutino', '2024-01-15', '2024-07-15', 22, '201'),
(2, 2, 13, 'Vespertino', '2024-01-15', '2024-07-15', 20, '202'),
(3, 1, 13, 'Noturno', '2024-02-01', NULL, 15, '301'),
(1, 1, 14, 'Matutino', '2024-02-05', '2024-08-10', 20, '104'),
(3, 2, 14, 'Vespertino', '2024-02-05', NULL, 18, '302');

-- 7. AULAS (PK composta: id_turma + numero_aula)
INSERT INTO AULA (id_turma, numero_aula, data_aula, conteudo_ministrado, carga_horaria) VALUES
(1, 1, '2024-01-10', 'Apresentação e vocabulário básico', 1.5),
(1, 2, '2024-01-15', 'Números e cores', 1.5),
(1, 3, '2024-01-22', 'Cumprimentos e cortesia', 1.5),
(1, 4, '2024-01-29', 'Família e parentesco', 1.5),
(1, 5, '2024-02-05', 'Casa e móveis', 1.5),
(1, 6, '2024-02-12', 'Comida e bebidas', 1.5),
(1, 7, '2024-02-19', 'Roupas e acessórios', 1.5),
(1, 8, '2024-02-26', 'Revisão Unidade 1', 1.5),
(1, 9, '2024-03-05', 'Profissões', 1.5),
(1, 10, '2024-03-12', 'Hobbies e lazer', 1.5),
(1, 11, '2024-03-19', 'Viagens', 1.5),
(1, 12, '2024-03-26', 'Compras e comércio', 1.5),
(2, 1, '2024-01-11', 'Rotina diária', 1.5),
(2, 2, '2024-01-18', 'Tempo presente contínuo', 1.5),
(2, 3, '2024-01-25', 'Passado simples', 1.5),
(2, 4, '2024-02-01', 'Descrições de pessoas', 1.5),
(2, 5, '2024-02-08', 'Expressões de preferência', 1.5),
(3, 1, '2024-01-12', 'Phrasal verbs introdução', 2.0),
(3, 2, '2024-01-19', 'Narrativas no passado', 2.0),
(3, 3, '2024-01-26', 'Discussões sobre tópicos atuais', 2.0),
(4, 1, '2024-01-15', 'Saludos y presentaciones', 1.5),
(4, 2, '2024-01-22', 'Números y días', 1.5),
(6, 1, '2024-02-01', 'Bonjour et introductions', 1.5);

-- 8. MATRÍCULAS (PK composta: id_aluno + id_turma, garante RN09)
INSERT INTO MATRICULA (id_aluno, id_turma, data_matricula, status_matricula, forma_pagamento) VALUES
(1, 1, '2024-01-08', 'ativa', 'Cartão'),
(2, 1, '2024-01-08', 'ativa', 'PIX'),
(3, 1, '2024-01-09', 'ativa', 'Boleto'),
(5, 1, '2024-01-08', 'ativa', 'Cartão'),
(6, 1, '2024-01-10', 'ativa', 'PIX'),
(7, 1, '2024-03-10', 'trancada', 'Cartão'),
(16, 1, '2024-01-08', 'ativa', NULL),
(17, 1, '2024-01-09', 'concluída', 'PIX'),
(21, 1, '2024-01-10', 'ativa', 'Cartão'),
(1, 2, '2024-01-10', 'ativa', 'Cartão'),
(4, 2, '2024-02-05', 'cancelada', 'PIX'),
(8, 2, '2024-01-10', 'ativa', 'Boleto'),
(9, 2, '2024-02-10', 'ativa', NULL),
(18, 2, '2024-02-10', 'ativa', 'Cartão'),
(22, 2, '2024-02-12', 'ativa', 'PIX'),
(2, 3, '2024-01-08', 'ativa', 'Cartão'),
(6, 3, '2024-01-09', 'ativa', 'PIX'),
(10, 3, '2024-04-08', 'ativa', NULL),
(19, 3, '2024-04-08', 'ativa', 'Cartão'),
(3, 4, '2024-01-12', 'ativa', 'Cartão'),
(5, 4, '2024-01-12', 'ativa', 'PIX'),
(16, 4, '2024-01-15', 'ativa', 'Boleto'),
(20, 4, '2024-01-15', 'ativa', 'Cartão'),
(23, 4, '2024-01-20', 'ativa', 'PIX'),
(2, 5, '2024-01-12', 'ativa', 'Cartão'),
(4, 5, '2024-01-15', 'ativa', 'PIX'),
(7, 5, '2024-01-15', 'ativa', NULL),
(24, 5, '2024-02-01', 'ativa', 'Cartão'),
(8, 6, '2024-01-30', 'ativa', 'Cartão'),
(17, 6, '2024-02-01', 'ativa', 'PIX'),
(25, 6, '2024-02-05', 'ativa', 'Cartão'),
(9, 7, '2024-02-03', 'ativa', 'Boleto'),
(16, 7, '2024-02-03', 'ativa', 'Cartão'),
(18, 7, '2024-02-03', 'ativa', 'PIX'),
(10, 8, '2024-02-03', 'ativa', 'Cartão'),
(19, 8, '2024-02-03', 'ativa', NULL);

-- 9. HISTÓRICO DE MATRÍCULA (PK composta: id_aluno + id_turma + numero_sequencia)
-- Mudanças de status registradas para as matrículas que não continuaram "ativa"
INSERT INTO HISTORICO_MATRICULA (id_aluno, id_turma, numero_sequencia, status_anterior, status_novo, data_mudanca) VALUES
(7, 1, 1, NULL, 'ativa', '2024-01-08 09:00:00'),
(7, 1, 2, 'ativa', 'trancada', '2024-03-10 14:30:00'),
(17, 1, 1, NULL, 'ativa', '2024-01-09 09:00:00'),
(17, 1, 2, 'ativa', 'concluída', '2024-06-30 18:00:00'),
(4, 2, 1, NULL, 'ativa', '2024-02-05 10:00:00'),
(4, 2, 2, 'ativa', 'cancelada', '2024-04-01 11:00:00');

-- 10. FREQUÊNCIAS (PK composta: id_turma + numero_aula + id_aluno)
INSERT INTO FREQUENCIA (id_turma, numero_aula, id_aluno, presente, justificativa) VALUES
(1, 1, 1, 1, NULL), (1, 1, 2, 1, NULL), (1, 1, 3, 0, 'Doença'), (1, 1, 5, 1, NULL),
(1, 1, 6, 1, NULL), (1, 1, 7, 1, NULL), (1, 1, 16, 1, NULL), (1, 1, 17, 1, NULL),
(1, 1, 21, 0, NULL), (1, 2, 1, 1, NULL), (1, 2, 2, 0, 'Dentista'), (1, 2, 3, 1, NULL),
(1, 2, 5, 1, NULL), (1, 2, 6, 1, NULL), (1, 2, 7, 1, NULL), (1, 2, 16, 1, NULL),
(1, 2, 17, 1, NULL), (1, 2, 21, 1, NULL), (1, 3, 1, 1, NULL), (1, 3, 2, 1, NULL),
(1, 3, 3, 1, NULL), (1, 3, 5, 0, 'Viagem'), (1, 3, 6, 1, NULL), (1, 3, 7, 1, NULL),
(1, 3, 16, 1, NULL), (1, 3, 17, 0, NULL), (1, 3, 21, 1, NULL), (1, 4, 1, 1, NULL),
(1, 4, 2, 1, NULL), (1, 4, 3, 1, NULL), (1, 4, 5, 1, NULL), (1, 4, 6, 1, NULL),
(1, 4, 7, 1, NULL), (1, 4, 16, 1, NULL), (1, 4, 17, 1, NULL), (1, 4, 21, 1, NULL),
(1, 5, 1, 1, NULL), (1, 5, 2, 1, NULL), (1, 5, 3, 1, NULL), (1, 5, 5, 1, NULL),
(1, 5, 6, 0, NULL), (1, 5, 7, 1, NULL), (1, 5, 16, 1, NULL), (1, 5, 17, 1, NULL),
(1, 5, 21, 1, NULL), (1, 6, 1, 1, NULL), (1, 6, 2, 1, NULL), (1, 6, 3, 1, NULL),
(1, 6, 5, 1, NULL), (1, 6, 6, 1, NULL), (1, 6, 7, 1, NULL), (1, 6, 16, 1, NULL),
(1, 6, 17, 1, NULL), (1, 6, 21, 0, NULL), (1, 7, 1, 1, NULL), (1, 7, 2, 1, NULL),
(1, 7, 3, 1, NULL), (1, 7, 5, 1, NULL), (1, 7, 6, 1, NULL), (1, 7, 7, 1, NULL),
(1, 7, 16, 1, NULL), (1, 7, 17, 1, NULL), (1, 7, 21, 1, NULL), (1, 8, 1, 1, NULL),
(1, 8, 2, 1, NULL), (1, 8, 3, 1, NULL), (1, 8, 5, 1, NULL), (1, 8, 6, 1, NULL),
(1, 8, 7, 1, NULL), (1, 8, 16, 1, NULL), (1, 8, 17, 1, NULL), (1, 8, 21, 1, NULL),
(1, 9, 1, 1, NULL), (1, 9, 2, 1, NULL), (1, 9, 3, 1, NULL), (1, 9, 5, 1, NULL),
(1, 9, 6, 1, NULL), (1, 9, 7, 0, 'Trabalho'), (1, 9, 16, 1, NULL), (1, 9, 17, 1, NULL),
(1, 9, 21, 1, NULL), (1, 10, 1, 1, NULL), (1, 10, 2, 1, NULL), (1, 10, 3, 1, NULL),
(1, 10, 5, 1, NULL), (1, 10, 6, 1, NULL), (1, 10, 7, 1, NULL), (1, 10, 16, 0, NULL),
(1, 10, 17, 1, NULL), (1, 10, 21, 1, NULL), (1, 11, 1, 1, NULL), (1, 11, 2, 1, NULL),
(1, 11, 3, 1, NULL), (1, 11, 5, 1, NULL), (1, 11, 6, 1, NULL), (1, 11, 7, 1, NULL),
(1, 11, 16, 1, NULL), (1, 11, 17, 1, NULL), (1, 11, 21, 1, NULL), (1, 12, 1, 1, NULL),
(1, 12, 2, 1, NULL), (1, 12, 3, 1, NULL), (1, 12, 5, 1, NULL), (1, 12, 6, 1, NULL),
(1, 12, 7, 1, NULL), (1, 12, 16, 1, NULL), (1, 12, 17, 1, NULL), (1, 12, 21, 1, NULL),
(2, 1, 1, 1, NULL), (2, 1, 8, 1, NULL), (2, 1, 18, 1, NULL), (2, 1, 22, 1, NULL),
(2, 2, 1, 1, NULL), (2, 2, 8, 0, NULL), (2, 2, 18, 1, NULL), (2, 2, 22, 1, NULL),
(2, 3, 1, 1, NULL), (2, 3, 8, 1, NULL), (2, 3, 18, 1, NULL), (2, 3, 22, 0, NULL),
(2, 4, 1, 1, NULL), (2, 4, 8, 1, NULL), (2, 4, 18, 1, NULL), (2, 4, 22, 1, NULL),
(2, 5, 1, 1, NULL), (2, 5, 8, 1, NULL), (2, 5, 18, 1, NULL), (2, 5, 22, 1, NULL);

-- 11. COMPETÊNCIAS
INSERT INTO COMPETENCIA (nome_competencia, descricao) VALUES
('Leitura', 'Capacidade de ler e compreender textos'),
('Escrita', 'Capacidade de escrever textos coerentes'),
('Oralidade', 'Capacidade de falar e se comunicar oralmente'),
('Compreensão Auditiva', 'Capacidade de ouvir e entender');

-- 12. AVALIAÇÕES
INSERT INTO AVALIACAO (id_aluno, id_turma, id_competencia, data_avaliacao, tipo, nota, observacao) VALUES
(1, 1, 1, '2024-02-20', 'Parcial', 8.50, 'Excelente desempenho'),
(1, 1, 2, '2024-02-20', 'Parcial', 8.00, 'Bom'),
(1, 1, 3, '2024-03-15', 'Parcial', 7.50, NULL),
(1, 1, 4, '2024-03-15', 'Parcial', 8.00, NULL),
(1, 1, 1, '2024-04-30', 'Final', 8.75, 'Muito bom'),
(1, 1, 2, '2024-04-30', 'Final', 8.50, NULL),
(1, 1, 3, '2024-04-30', 'Final', 8.00, NULL),
(1, 1, 4, '2024-04-30', 'Final', 8.25, NULL),
(2, 1, 1, '2024-02-20', 'Parcial', 7.50, NULL),
(2, 1, 2, '2024-02-20', 'Parcial', 7.00, NULL),
(2, 1, 3, '2024-03-15', 'Parcial', 6.50, NULL),
(2, 1, 4, '2024-03-15', 'Parcial', 7.00, NULL),
(2, 1, 1, '2024-04-30', 'Final', 8.00, NULL),
(2, 1, 2, '2024-04-30', 'Final', 7.50, NULL),
(2, 1, 3, '2024-04-30', 'Final', 7.00, NULL),
(2, 1, 4, '2024-04-30', 'Final', 7.50, NULL),
(3, 1, 1, '2024-02-20', 'Parcial', 6.50, 'Precisa melhorar'),
(3, 1, 2, '2024-02-20', 'Parcial', 6.00, NULL),
(3, 1, 3, '2024-03-15', 'Parcial', 5.50, NULL),
(3, 1, 4, '2024-03-15', 'Parcial', 6.00, NULL),
(3, 1, 1, '2024-04-30', 'Final', 7.00, 'Melhorou'),
(3, 1, 2, '2024-04-30', 'Final', 6.50, NULL),
(3, 1, 3, '2024-04-30', 'Final', 6.00, NULL),
(3, 1, 4, '2024-04-30', 'Final', 6.50, NULL),
(5, 1, 1, '2024-02-20', 'Parcial', 9.00, 'Destaque da turma'),
(5, 1, 2, '2024-02-20', 'Parcial', 9.00, NULL),
(5, 1, 3, '2024-03-15', 'Parcial', 8.50, NULL),
(5, 1, 4, '2024-03-15', 'Parcial', 9.00, NULL),
(5, 1, 1, '2024-04-30', 'Final', 9.25, 'Excelente'),
(5, 1, 2, '2024-04-30', 'Final', 9.00, NULL),
(5, 1, 3, '2024-04-30', 'Final', 8.75, NULL),
(5, 1, 4, '2024-04-30', 'Final', 9.00, NULL),
(1, 2, 1, '2024-03-10', 'Parcial', 8.00, NULL),
(1, 2, 2, '2024-03-10', 'Parcial', 7.50, NULL),
(8, 2, 1, '2024-03-10', 'Parcial', 7.00, NULL),
(8, 2, 2, '2024-03-10', 'Parcial', 6.50, NULL);

-- 13. MENTORIAS (PK composta: id_mentor + id_mentorado + id_idioma)
INSERT INTO MENTORIA (id_mentor, id_mentorado, id_idioma, horas_totais, avaliacao_mentoria, situacao) VALUES
(1, 2, 1, 15.5, 5, 'Concluída'),
(5, 3, 1, 20.0, 4, 'Concluída'),
(1, 8, 1, 12.5, NULL, 'Em andamento'),
(5, 6, 1, 25.0, 5, 'Concluída'),
(2, 4, 1, 18.0, 3, 'Concluída'),
(1, 7, 2, 30.0, 4, 'Concluída');

-- 14. CERTIFICADOS
INSERT INTO CERTIFICADO (id_aluno, id_turma, data_emissao, nota_final, codigo_verificacao) VALUES
(1, 1, '2024-06-30', 8.63, 'CERT-2024-001-001'),
(2, 1, '2024-06-30', 7.75, 'CERT-2024-001-002'),
(3, 1, '2024-06-30', 6.75, 'CERT-2024-001-003'),
(5, 1, '2024-06-30', 9.06, 'CERT-2024-001-005'),
(6, 1, '2024-06-30', 7.50, 'CERT-2024-001-006'),
(16, 1, '2024-06-30', 7.88, 'CERT-2024-001-016'),
(21, 1, '2024-06-30', 7.25, 'CERT-2024-001-021'),
(1, 2, '2024-07-15', 8.13, 'CERT-2024-002-001'),
(8, 2, '2024-07-15', 6.88, 'CERT-2024-002-008'),
(18, 2, '2024-07-15', 7.50, 'CERT-2024-002-018'),
(2, 3, '2024-08-30', 7.67, 'CERT-2024-003-002'),
(6, 3, '2024-08-30', 8.50, 'CERT-2024-003-006');