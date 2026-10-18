package br.escola.dao;

import br.escola.conexao.ConexaoBD;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Operação de negócio multitabela (B1/B3): matricular um aluno em uma turma.
 * Na MESMA transação: (1) confere vagas com bloqueio, (2) INSERT em matricula,
 * (3) INSERT em historico_matricula. Qualquer falha => ROLLBACK.
 */
public class TransacaoDAO {

    public void matricularComHistorico(int idAluno, int idTurma, String formaPagamento, boolean simularFalha) throws SQLException {
        try (Connection c = ConexaoBD.obterConexao()) {
            c.setAutoCommit(false);                                   // BEGIN
            // c.setTransactionIsolation(Connection.TRANSACTION_REPEATABLE_READ); // padrão do InnoDB; justifique no relatório
            try {
                int vagas, ocupadas;
                try (PreparedStatement s = c.prepareStatement("SELECT vagas_totais FROM turma WHERE id_turma = ? FOR UPDATE")) {
                    s.setInt(1, idTurma);
                    try (ResultSet rs = s.executeQuery()) {
                        if (!rs.next()) throw new IllegalArgumentException("Turma não encontrada.");
                        vagas = rs.getInt(1);
                    }
                }
                try (PreparedStatement s = c.prepareStatement(
                        "SELECT COUNT(*) FROM matricula WHERE id_turma = ? AND status_matricula IN ('ativa', 'trancada')")) {
                    s.setInt(1, idTurma);
                    try (ResultSet rs = s.executeQuery()) { rs.next(); ocupadas = rs.getInt(1); }
                }
                if (ocupadas >= vagas) throw new IllegalStateException("A turma não tem vagas disponíveis.");

                try (PreparedStatement s = c.prepareStatement(
                        "INSERT INTO matricula (id_aluno, id_turma, data_matricula, status_matricula, forma_pagamento) "
                      + "VALUES (?, ?, CURDATE(), 'ativa', ?)")) {
                    s.setInt(1, idAluno); s.setInt(2, idTurma);
                    if (formaPagamento == null || formaPagamento.isEmpty()) s.setNull(3, java.sql.Types.VARCHAR);
                    else s.setString(3, formaPagamento);
                    s.executeUpdate();
                }

                if (simularFalha) throw new IllegalStateException("Falha simulada no meio da transação: a matrícula foi desfeita (ROLLBACK).");

                try (PreparedStatement s = c.prepareStatement(
                        "INSERT INTO historico_matricula (id_aluno, id_turma, numero_sequencia, status_anterior, status_novo, data_mudanca) "
                      + "VALUES (?, ?, 1, NULL, 'ativa', NOW())")) {
                    s.setInt(1, idAluno); s.setInt(2, idTurma); s.executeUpdate();
                }
                c.commit();                                           // COMMIT
            } catch (SQLException | RuntimeException e) {
                c.rollback();                                         // ROLLBACK
                throw e;
            }
        }
    }
}