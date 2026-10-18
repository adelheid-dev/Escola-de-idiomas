-- PROJETO FINAL - ESCOLA DE IDIOMAS
-- Script Físico (DDL)

SET NAMES utf8mb4;
DROP DATABASE IF EXISTS escola_idiomas;
CREATE DATABASE escola_idiomas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE escola_idiomas;
 

-- TABELA PESSOA

CREATE TABLE PESSOA (
    id_pessoa INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    data_nascimento DATE NOT NULL,
 
    CONSTRAINT pk_pessoa PRIMARY KEY (id_pessoa),
 
    -- RN02: CPF não pode se repetir
    CONSTRAINT uq_pessoa_cpf UNIQUE (cpf),
 
    -- RN04: e-mail não pode se repetir
    CONSTRAINT uq_pessoa_email UNIQUE (email),
 
    -- RN01: CPF com exatamente 11 dígitos numéricos
    CONSTRAINT ck_pessoa_cpf CHECK (cpf REGEXP '^[0-9]{11}$')
);
 
-- RN03: data de nascimento não pode ser futura.
-- CHECK não aceita funções não determinísticas.
DELIMITER $$
CREATE TRIGGER trg_pessoa_nasc_ins BEFORE INSERT ON PESSOA
FOR EACH ROW
BEGIN
    IF NEW.data_nascimento > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN03: data de nascimento não pode ser futura';
    END IF;
END$$
 
CREATE TRIGGER trg_pessoa_nasc_upd BEFORE UPDATE ON PESSOA
FOR EACH ROW
BEGIN
    IF NEW.data_nascimento > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN03: data de nascimento não pode ser futura';
    END IF;
END$$
DELIMITER ;

-- TABELA ALUNO (especialização de PESSOA)

CREATE TABLE ALUNO (
    id_pessoa INT,
    data_matricula_inicial DATE NOT NULL,
    situacao VARCHAR(20) NOT NULL,
 
    CONSTRAINT pk_aluno PRIMARY KEY (id_pessoa),
    CONSTRAINT ck_aluno_situacao CHECK (situacao IN ('Ativo', 'Inativo', 'Suspenso')),
    CONSTRAINT fk_aluno_pessoa FOREIGN KEY (id_pessoa)
        REFERENCES PESSOA(id_pessoa) ON DELETE CASCADE ON UPDATE CASCADE
);
 

-- TABELA PROFESSOR (especialização de PESSOA)

CREATE TABLE PROFESSOR (
    id_pessoa INT,
    data_contratacao DATE NOT NULL,
    carga_horaria_semanal INT NOT NULL,
    situacao VARCHAR(20) NOT NULL,
 
    CONSTRAINT pk_professor PRIMARY KEY (id_pessoa),
    CONSTRAINT ck_professor_carga CHECK (carga_horaria_semanal > 0),
    CONSTRAINT ck_professor_situacao CHECK (situacao IN ('Ativo', 'Licenciado', 'Desligado')),
    CONSTRAINT fk_professor_pessoa FOREIGN KEY (id_pessoa)
        REFERENCES PESSOA(id_pessoa) ON DELETE CASCADE ON UPDATE CASCADE
);
 

-- TABELA IDIOMA

CREATE TABLE IDIOMA (
    id_idioma INT AUTO_INCREMENT,
    nome_idioma VARCHAR(50) NOT NULL,
 
    CONSTRAINT pk_idioma PRIMARY KEY (id_idioma),
    CONSTRAINT uq_idioma_nome UNIQUE (nome_idioma)
);
 

-- TABELA NIVEL

CREATE TABLE NIVEL (
    id_nivel INT AUTO_INCREMENT,
    nome_nivel VARCHAR(10) NOT NULL,
    descricao VARCHAR(255),
    id_nivel_prerequisito INT,
 
    CONSTRAINT pk_nivel PRIMARY KEY (id_nivel),
    CONSTRAINT uq_nivel_nome UNIQUE (nome_nivel),
    CONSTRAINT ck_nivel_nome CHECK (nome_nivel IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
 
    -- A1 fica com pré-requisito NULL; os demais apontam para o nível anterior
    CONSTRAINT fk_nivel_prereq FOREIGN KEY (id_nivel_prerequisito)
        REFERENCES NIVEL(id_nivel) ON DELETE SET NULL ON UPDATE CASCADE
);
 

-- TABELA TURMA

CREATE TABLE TURMA (
    id_turma INT AUTO_INCREMENT,
    id_idioma INT NOT NULL,
    id_nivel INT NOT NULL,
    id_professor INT NOT NULL,
    turno VARCHAR(20) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    vagas_totais INT NOT NULL,
    sala VARCHAR(20),
 
    CONSTRAINT pk_turma PRIMARY KEY (id_turma),
 
    -- Chave candidata: uma sala só abriga uma turma por turno e período de início
    CONSTRAINT uq_turma_sala_turno_inicio UNIQUE (sala, turno, data_inicio),
 
    -- RN07: vagas sempre positivas
    CONSTRAINT ck_turma_vagas CHECK (vagas_totais > 0),
    -- Domínio de turno
    CONSTRAINT ck_turma_turno CHECK (turno IN ('Matutino', 'Vespertino', 'Noturno')),
    -- Coerência de datas
    CONSTRAINT ck_turma_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio),
 
    CONSTRAINT fk_turma_idioma FOREIGN KEY (id_idioma)
        REFERENCES IDIOMA(id_idioma) ON DELETE RESTRICT ON UPDATE CASCADE,
 
    CONSTRAINT fk_turma_nivel FOREIGN KEY (id_nivel)
        REFERENCES NIVEL(id_nivel) ON DELETE RESTRICT ON UPDATE CASCADE,
 
    CONSTRAINT fk_turma_professor FOREIGN KEY (id_professor)
        REFERENCES PROFESSOR(id_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE
);
 

-- TABELA AULA (entidade fraca de TURMA)

CREATE TABLE AULA (
    id_turma INT NOT NULL,
    numero_aula INT NOT NULL,
    data_aula DATE NOT NULL,
    conteudo_ministrado VARCHAR(255),
    duracao_minutos INT NOT NULL,
 
    -- PK composta: AULA não existe sem TURMA
    CONSTRAINT pk_aula PRIMARY KEY (id_turma, numero_aula),
 
    -- Chave candidata: no máximo uma aula por turma em cada data
    CONSTRAINT uq_aula_turma_data UNIQUE (id_turma, data_aula),
 
    CONSTRAINT ck_aula_numero CHECK (numero_aula > 0),
    CONSTRAINT ck_aula_duracao CHECK (duracao_minutos > 0),
 
    -- Aula é parte da turma: apagar a turma apaga suas aulas (dependência de existência)
    CONSTRAINT fk_aula_turma FOREIGN KEY (id_turma)
        REFERENCES TURMA(id_turma) ON DELETE CASCADE ON UPDATE CASCADE
);
 

-- TABELA MATRICULA (entidade associativa entre ALUNO e TURMA)

CREATE TABLE MATRICULA (
    id_aluno INT NOT NULL,
    id_turma INT NOT NULL,
    data_matricula DATE NOT NULL,
    status_matricula VARCHAR(20) NOT NULL,
    forma_pagamento VARCHAR(30),
 
    CONSTRAINT pk_matricula PRIMARY KEY (id_aluno, id_turma),
 
    CONSTRAINT ck_matricula_status CHECK (status_matricula IN ('ativa', 'trancada', 'concluída', 'cancelada')),
 
    -- RESTRICT: matrícula é registro acadêmico e não pode sumir junto com aluno/turma
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (id_aluno)
        REFERENCES ALUNO(id_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE,
 
    CONSTRAINT fk_matricula_turma FOREIGN KEY (id_turma)
        REFERENCES TURMA(id_turma) ON DELETE RESTRICT ON UPDATE CASCADE
);
 

-- TABELA HISTORICO_MATRICULA (entidade fraca de MATRICULA)

CREATE TABLE HISTORICO_MATRICULA (
    id_aluno INT NOT NULL,
    id_turma INT NOT NULL,
    numero_sequencia INT NOT NULL,
    status_anterior VARCHAR(20),
    status_novo VARCHAR(20) NOT NULL,
    data_mudanca DATETIME NOT NULL,
 
    CONSTRAINT pk_historico_matricula PRIMARY KEY (id_aluno, id_turma, numero_sequencia),
 
    CONSTRAINT ck_historico_numero CHECK (numero_sequencia > 0),
    CONSTRAINT ck_historico_status_anterior CHECK (status_anterior IS NULL OR status_anterior IN ('ativa', 'trancada', 'concluída', 'cancelada')),
    CONSTRAINT ck_historico_status_novo CHECK (status_novo IN ('ativa', 'trancada', 'concluída', 'cancelada')),
 
    CONSTRAINT fk_historico_matricula FOREIGN KEY (id_aluno, id_turma)
        REFERENCES MATRICULA(id_aluno, id_turma) ON DELETE RESTRICT ON UPDATE CASCADE
);
 
 
-- TABELA FREQUENCIA (entidade fraca de AULA e ALUNO)

CREATE TABLE FREQUENCIA (
    id_turma INT NOT NULL,
    numero_aula INT NOT NULL,
    id_aluno INT NOT NULL,
    presente TINYINT NOT NULL,
    justificativa VARCHAR(255),
 
    CONSTRAINT pk_frequencia PRIMARY KEY (id_turma, numero_aula, id_aluno),
 
    CONSTRAINT ck_frequencia_presente CHECK (presente IN (0, 1)),
 
    -- Frequência é parte da aula: some junto com ela
    CONSTRAINT fk_frequencia_aula FOREIGN KEY (id_turma, numero_aula)
        REFERENCES AULA(id_turma, numero_aula) ON DELETE CASCADE ON UPDATE CASCADE,
 
    -- Mas não some junto com o aluno
    CONSTRAINT fk_frequencia_aluno FOREIGN KEY (id_aluno)
        REFERENCES ALUNO(id_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE
);
 

-- TABELA COMPETENCIA

CREATE TABLE COMPETENCIA (
    id_competencia INT AUTO_INCREMENT,
    nome_competencia VARCHAR(100) NOT NULL,
    descricao VARCHAR(500),
 
    CONSTRAINT pk_competencia PRIMARY KEY (id_competencia),
    CONSTRAINT uq_competencia_nome UNIQUE (nome_competencia)
);
 

-- TABELA AVALIACAO

CREATE TABLE AVALIACAO (
    id_avaliacao INT AUTO_INCREMENT,
    id_aluno INT NOT NULL,
    id_turma INT NOT NULL,
    id_competencia INT NOT NULL,
    data_avaliacao DATE NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    nota DECIMAL(4,2) NOT NULL,
    observacao VARCHAR(255),
 
    CONSTRAINT pk_avaliacao PRIMARY KEY (id_avaliacao),
 
    -- Chave candidata: uma avaliação de cada tipo por aluno, turma e competência
    CONSTRAINT uq_avaliacao_natural UNIQUE (id_aluno, id_turma, id_competencia, tipo),
 
    CONSTRAINT ck_avaliacao_nota CHECK (nota >= 0 AND nota <= 10),
    CONSTRAINT ck_avaliacao_tipo CHECK (tipo IN ('Parcial', 'Final')),
 
    -- RESTRICT: nota é histórico acadêmico
    CONSTRAINT fk_avaliacao_aluno FOREIGN KEY (id_aluno)
        REFERENCES ALUNO(id_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE,
 
    CONSTRAINT fk_avaliacao_turma FOREIGN KEY (id_turma)
        REFERENCES TURMA(id_turma) ON DELETE RESTRICT ON UPDATE CASCADE,
 
    CONSTRAINT fk_avaliacao_competencia FOREIGN KEY (id_competencia)
        REFERENCES COMPETENCIA(id_competencia) ON DELETE RESTRICT ON UPDATE CASCADE
);
 

-- TABELA MENTORIA

CREATE TABLE MENTORIA (
    id_mentor INT NOT NULL,
    id_mentorado INT NOT NULL,
    id_idioma INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    horas_totais DECIMAL(5,1) NOT NULL,
    avaliacao_mentoria INT,
    situacao VARCHAR(20) NOT NULL,
 
    CONSTRAINT pk_mentoria PRIMARY KEY (id_mentor, id_mentorado, id_idioma),
 
    -- RN20: ninguém é mentor de si mesmo
    CONSTRAINT ck_mentoria_distintos CHECK (id_mentor <> id_mentorado),
    -- RN20: entre 10 e 40 horas
    CONSTRAINT ck_mentoria_horas CHECK (horas_totais >= 10 AND horas_totais <= 40),
    -- RN21: 1 a 5 estrelas
    CONSTRAINT ck_mentoria_avaliacao CHECK (avaliacao_mentoria IS NULL OR (avaliacao_mentoria BETWEEN 1 AND 5)),
    CONSTRAINT ck_mentoria_situacao CHECK (situacao IN ('Em andamento', 'Concluída', 'Cancelada')),
    CONSTRAINT ck_mentoria_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio),
 
    CONSTRAINT fk_mentoria_mentor FOREIGN KEY (id_mentor)
        REFERENCES ALUNO(id_pessoa) ON DELETE RESTRICT ON UPDATE RESTRICT,
 
    CONSTRAINT fk_mentoria_mentorado FOREIGN KEY (id_mentorado)
        REFERENCES ALUNO(id_pessoa) ON DELETE RESTRICT ON UPDATE RESTRICT,
 
    CONSTRAINT fk_mentoria_idioma FOREIGN KEY (id_idioma)
        REFERENCES IDIOMA(id_idioma) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- TABELA CERTIFICADO

CREATE TABLE CERTIFICADO (
    id_certificado INT AUTO_INCREMENT,
    id_aluno INT NOT NULL,
    id_turma INT NOT NULL,
    data_emissao DATE NOT NULL,
    nota_final DECIMAL(4,2) NOT NULL,
    codigo_verificacao VARCHAR(50) NOT NULL,
 
    CONSTRAINT pk_certificado PRIMARY KEY (id_certificado),
    CONSTRAINT uq_certificado_aluno_turma UNIQUE (id_aluno, id_turma),
    CONSTRAINT uq_certificado_codigo UNIQUE (codigo_verificacao),
    CONSTRAINT ck_certificado_nota CHECK (nota_final >= 6.0 AND nota_final <= 10),
 
    -- RESTRICT
    CONSTRAINT fk_certificado_aluno FOREIGN KEY (id_aluno)
        REFERENCES ALUNO(id_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE,
 
    CONSTRAINT fk_certificado_turma FOREIGN KEY (id_turma)
        REFERENCES TURMA(id_turma) ON DELETE RESTRICT ON UPDATE CASCADE
);
 

-- ÍNDICES 

CREATE INDEX idx_turma_professor ON TURMA(id_professor);
CREATE INDEX idx_turma_idioma ON TURMA(id_idioma);
CREATE INDEX idx_turma_nivel ON TURMA(id_nivel);
CREATE INDEX idx_matricula_aluno ON MATRICULA(id_aluno);
CREATE INDEX idx_frequencia_aluno ON FREQUENCIA(id_aluno);
CREATE INDEX idx_avaliacao_turma ON AVALIACAO(id_turma);
CREATE INDEX idx_avaliacao_competencia ON AVALIACAO(id_competencia);
CREATE INDEX idx_mentoria_mentor ON MENTORIA(id_mentor);
CREATE INDEX idx_mentoria_mentorado ON MENTORIA(id_mentorado);
CREATE INDEX idx_certificado_turma ON CERTIFICADO(id_turma);
