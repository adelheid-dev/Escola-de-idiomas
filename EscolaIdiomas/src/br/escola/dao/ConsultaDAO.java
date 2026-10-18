package br.escola.dao;

import br.escola.conexao.ConexaoBD;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Consultas parametrizadas (B1): junção + agregação, sempre com PreparedStatement. */
public class ConsultaDAO {

    public static final String[] COLS_TURMAS = {"Idioma", "Turno", "Turmas", "Matrículas ativas"};
    public static final String[] COLS_ALUNOS = {"ID", "Aluno", "Matrículas", "Idiomas distintos"};

    /** Ocupação por idioma/turno, só com grupos que tenham pelo menos minAtivas matrículas ativas. */
    public List<Object[]> ocupacaoPorIdioma(String idioma, String turno, int minAtivas) throws SQLException {
        String sql = "SELECT i.nome_idioma, t.turno, COUNT(DISTINCT t.id_turma) AS turmas, COUNT(m.id_aluno) AS ativas "
                   + "FROM turma t "
                   + "JOIN idioma i ON i.id_idioma = t.id_idioma "
                   + "LEFT JOIN matricula m ON m.id_turma = t.id_turma AND m.status_matricula = 'ativa' "
                   + "WHERE i.nome_idioma LIKE ? AND t.turno LIKE ? "
                   + "GROUP BY i.nome_idioma, t.turno "
                   + "HAVING COUNT(m.id_aluno) >= ? "
                   + "ORDER BY ativas DESC, i.nome_idioma";
        List<Object[]> r = new ArrayList<>();
        try (Connection c = ConexaoBD.obterConexao(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setString(1, "%" + idioma.trim() + "%");
            s.setString(2, turno == null || turno.isEmpty() ? "%" : turno);
            s.setInt(3, minAtivas);
            try (ResultSet rs = s.executeQuery()) {
                while (rs.next()) r.add(new Object[]{rs.getString(1), rs.getString(2), rs.getInt(3), rs.getInt(4)});
            }
        }
        return r;
    }

    /** Alunos (por trecho do nome) com a quantidade de matrículas de um status. */
    public List<Object[]> matriculasPorAluno(String nome, String status) throws SQLException {
        String sql = "SELECT p.id_pessoa, p.nome, COUNT(*) AS matriculas, COUNT(DISTINCT t.id_idioma) AS idiomas "
                   + "FROM pessoa p "
                   + "JOIN aluno a ON a.id_pessoa = p.id_pessoa "
                   + "JOIN matricula m ON m.id_aluno = a.id_pessoa "
                   + "JOIN turma t ON t.id_turma = m.id_turma "
                   + "WHERE p.nome LIKE ? AND m.status_matricula LIKE ? "
                   + "GROUP BY p.id_pessoa, p.nome "
                   + "ORDER BY matriculas DESC, p.nome";
        List<Object[]> r = new ArrayList<>();
        try (Connection c = ConexaoBD.obterConexao(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setString(1, "%" + nome.trim() + "%");
            s.setString(2, status == null || status.isEmpty() ? "%" : status);
            try (ResultSet rs = s.executeQuery()) {
                while (rs.next()) r.add(new Object[]{rs.getInt(1), rs.getString(2), rs.getInt(3), rs.getInt(4)});
            }
        }
        return r;
    }
}