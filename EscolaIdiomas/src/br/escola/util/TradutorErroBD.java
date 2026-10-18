package br.escola.util;

import java.sql.SQLException;

/** Converte erros do MySQL em mensagens compreensíveis para o usuário (B1). */
public class TradutorErroBD {

    public static String traduzir(SQLException e) {
        String msg = e.getMessage() == null ? "" : e.getMessage();

        // Falhas de conexão geradas pela ConexaoBD já trazem texto amigável
        if ("08001".equals(e.getSQLState())) return msg;

        switch (e.getErrorCode()) {
            case 1062: // UNIQUE / PRIMARY
                if (msg.contains("uq_pessoa_cpf"))      return "Já existe uma pessoa cadastrada com este CPF.";
                if (msg.contains("uq_pessoa_email"))    return "Já existe uma pessoa cadastrada com este e-mail.";
                if (msg.contains("uq_idioma_nome"))     return "Já existe um idioma com este nome.";
                if (msg.contains("MATRICULA.PRIMARY"))  return "Este aluno já está matriculado nesta turma.";
                if (msg.contains("uq_turma_sala_turno_inicio")) return "Já existe uma turma nesta sala, turno e data de início.";
                return "Já existe um registro com estes dados.";
            case 1451: // FK ao excluir
                if (msg.contains("fk_pagamento_matricula")) return "Não é possível excluir: a matrícula possui pagamentos.";
                return "Não é possível excluir: o registro possui vínculos (matrículas, turmas, notas, frequências ou pagamentos).";
            case 1452: // FK ao inserir
                if (msg.contains("fk_matricula_aluno"))     return "Aluno não encontrado. Confira o ID do aluno.";
                if (msg.contains("fk_matricula_turma"))     return "Turma não encontrada. Confira o ID da turma.";
                if (msg.contains("fk_pagamento_matricula")) return "Matrícula não encontrada. Confira o ID da matrícula.";
                if (msg.contains("fk_turma_"))              return "Idioma, nível ou professor da turma não existe.";
                return "O registro relacionado informado não existe.";
            case 3819: // CHECK
                if (msg.contains("ck_pessoa_cpf"))       return "CPF inválido: informe exatamente 11 números.";
                if (msg.contains("ck_aluno_situacao"))   return "Situação do aluno inválida.";
                if (msg.contains("ck_pagamento_valor"))  return "O valor do pagamento deve ser maior que zero.";
                if (msg.contains("ck_pagamento_status")) return "Status do pagamento inválido.";
                if (msg.contains("ck_pagamento_forma"))  return "Forma de pagamento inválida.";
                if (msg.contains("ck_turma_vagas"))      return "O número de vagas deve ser maior que zero.";
                if (msg.contains("ck_matricula_status")) return "Status da matrícula inválido.";
                return "Algum valor informado não é permitido.";
            case 1048: // NOT NULL
                return "Há um campo obrigatório em branco.";
            case 1406: // texto maior que a coluna
                return "Algum texto informado é maior que o permitido.";
            case 1644: // SIGNAL das triggers (ex.: RN03)
                return msg;
            default:
                e.printStackTrace(); // detalhe técnico só no console
                return "Não foi possível concluir a operação no banco de dados.";
        }
    }
}
