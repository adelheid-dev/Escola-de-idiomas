package br.escola.dao;

import br.escola.conexao.ConexaoBD;
import br.escola.modelo.Matricula;
import br.escola.util.TradutorErroBD;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.swing.JOptionPane;

/** MATRICULA tem PK composta (id_aluno, id_turma); coluna de status = status_matricula (minúsculas). */
public class MatriculaDAO {

    public void inserir(Matricula m) throws SQLException {
        String sql = "INSERT INTO matricula (id_aluno, id_turma, data_matricula, status_matricula) VALUES (?, ?, CURDATE(), ?)";
        String status = m.getStatusMatricula() == null ? "ativa" : m.getStatusMatricula().trim().toLowerCase();
        try (Connection c = ConexaoBD.obterConexao(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setInt(1, m.getIdAluno());
            s.setInt(2, m.getIdTurma());
            s.setString(3, status);
            s.executeUpdate();
        }
    }

    public List<Matricula> listarTodos() {
        List<Matricula> lista = new ArrayList<>();
        String sql = "SELECT id_aluno, id_turma, data_matricula, status_matricula FROM matricula ORDER BY id_aluno, id_turma";
        try (Connection c = ConexaoBD.obterConexao(); PreparedStatement s = c.prepareStatement(sql); ResultSet rs = s.executeQuery()) {
            while (rs.next()) {
                Matricula m = new Matricula();
                m.setIdAluno(rs.getInt("id_aluno"));
                m.setIdTurma(rs.getInt("id_turma"));
                m.setDataMatricula(rs.getString("data_matricula"));
                m.setStatusMatricula(rs.getString("status_matricula"));
                lista.add(m);
            }
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(null, TradutorErroBD.traduzir(e));
        }
        return lista;
    }

    /** Cancela (não apaga) e registra o evento em historico_matricula, na mesma transação. */
    public void cancelar(int idAluno, int idTurma) throws SQLException {
        try (Connection c = ConexaoBD.obterConexao()) {
            c.setAutoCommit(false);
            try {
                String anterior;
                try (PreparedStatement s = c.prepareStatement(
                        "SELECT status_matricula FROM matricula WHERE id_aluno = ? AND id_turma = ? FOR UPDATE")) {
                    s.setInt(1, idAluno); s.setInt(2, idTurma);
                    try (ResultSet rs = s.executeQuery()) {
                        if (!rs.next()) throw new IllegalArgumentException("Matrícula não encontrada.");
                        anterior = rs.getString(1);
                    }
                }
                try (PreparedStatement s = c.prepareStatement(
                        "UPDATE matricula SET status_matricula = 'cancelada' WHERE id_aluno = ? AND id_turma = ?")) {
                    s.setInt(1, idAluno); s.setInt(2, idTurma); s.executeUpdate();
                }
                try (PreparedStatement s = c.prepareStatement(
                        "INSERT INTO historico_matricula (id_aluno, id_turma, numero_sequencia, status_anterior, status_novo, data_mudanca) "
                      + "SELECT ?, ?, COALESCE(MAX(numero_sequencia), 0) + 1, ?, 'cancelada', NOW() "
                      + "FROM historico_matricula WHERE id_aluno = ? AND id_turma = ?")) {
                    s.setInt(1, idAluno); s.setInt(2, idTurma); s.setString(3, anterior);
                    s.setInt(4, idAluno); s.setInt(5, idTurma); s.executeUpdate();
                }
                c.commit();
            } catch (SQLException | RuntimeException e) {
                c.rollback();
                throw e;
            }
        }
    }
}