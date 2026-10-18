package br.escola.dao;

import br.escola.conexao.ConexaoBD;
import br.escola.modelo.Turma;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * CRUD de TURMA com os valores reais da tela (idioma, professor, turno e sala).
 * Na classe Turma, o campo nomeTurma guarda a SALA (a tabela turma não tem coluna de nome).
 * Idioma e professor chegam pelo nome e são convertidos em id por subconsulta (parametrizada).
 * Todos os métodos lançam SQLException; quem chama traduz o erro com TradutorErroBD.
 */
public class TurmaDAO {

    private static final String ID_IDIOMA    = "(SELECT id_idioma FROM idioma WHERE nome_idioma = ?)";
    private static final String ID_NIVEL     = "(SELECT id_nivel FROM nivel WHERE nome_nivel = ?)";
    private static final String ID_PROFESSOR = "(SELECT p.id_pessoa FROM pessoa p "
                                             + "JOIN professor pr ON pr.id_pessoa = p.id_pessoa WHERE p.nome = ? LIMIT 1)";

    public void inserir(Turma t, String nivel, int vagas) throws SQLException {
        String sql = "INSERT INTO turma (id_idioma, id_nivel, id_professor, turno, data_inicio, data_fim, vagas_totais, sala) "
                   + "VALUES (" + ID_IDIOMA + ", " + ID_NIVEL + ", " + ID_PROFESSOR + ", ?, CURDATE(), "
                   + "DATE_ADD(CURDATE(), INTERVAL 6 MONTH), ?, ?)";
        try (Connection c = ConexaoBD.obterConexao(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setString(1, t.getIdioma());
            s.setString(2, nivel);
            s.setString(3, t.getProfessor());
            s.setString(4, t.getHorario());      // turno
            s.setInt(5, vagas);
            s.setString(6, t.getNomeTurma());    // sala
            s.executeUpdate();
        }
    }

    public List<Turma> listarTodos() throws SQLException {
        String sql = "SELECT t.id_turma, t.sala, i.nome_idioma, t.turno, p.nome AS professor, "
                   + "(SELECT COUNT(*) FROM matricula m WHERE m.id_turma = t.id_turma "
                   + " AND m.status_matricula IN ('ativa','trancada')) AS ocupadas "
                   + "FROM turma t "
                   + "JOIN idioma i ON i.id_idioma = t.id_idioma "
                   + "JOIN professor pr ON pr.id_pessoa = t.id_professor "
                   + "JOIN pessoa p ON p.id_pessoa = pr.id_pessoa "
                   + "ORDER BY t.id_turma";
        List<Turma> lista = new ArrayList<>();
        try (Connection c = ConexaoBD.obterConexao(); PreparedStatement s = c.prepareStatement(sql); ResultSet rs = s.executeQuery()) {
            while (rs.next()) {
                Turma t = new Turma();
                t.setIdTurma(rs.getInt("id_turma"));
                t.setNomeTurma(rs.getString("sala") == null ? "" : rs.getString("sala"));
                t.setIdioma(rs.getString("nome_idioma"));
                t.setHorario(rs.getString("turno"));
                t.setProfessor(rs.getString("professor"));
                t.setAlunosMatriculados(rs.getInt("ocupadas"));
                lista.add(t);
            }
        }
        return lista;
    }

    /** Altera idioma, professor, turno e sala. Nível, vagas e datas não mudam por aqui. */
    public void alterar(Turma t) throws SQLException {
        String sql = "UPDATE turma SET id_idioma = " + ID_IDIOMA + ", id_professor = " + ID_PROFESSOR
                   + ", turno = ?, sala = ? WHERE id_turma = ?";
        try (Connection c = ConexaoBD.obterConexao(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setString(1, t.getIdioma());
            s.setString(2, t.getProfessor());
            s.setString(3, t.getHorario());
            s.setString(4, t.getNomeTurma());
            s.setInt(5, t.getIdTurma());
            if (s.executeUpdate() == 0) throw new IllegalArgumentException("Turma não encontrada.");
        }
    }

    public void excluir(int idTurma) throws SQLException {
        try (Connection c = ConexaoBD.obterConexao(); PreparedStatement s = c.prepareStatement("DELETE FROM turma WHERE id_turma = ?")) {
            s.setInt(1, idTurma);
            if (s.executeUpdate() == 0) throw new IllegalArgumentException("Turma não encontrada.");
        }
    }

    // ---- listas para os campos da tela ----

    public List<String> listarNomesIdiomas() throws SQLException {
        return lista("SELECT nome_idioma FROM idioma ORDER BY nome_idioma");
    }

    public List<String> listarNomesProfessores() throws SQLException {
        return lista("SELECT p.nome FROM professor pr JOIN pessoa p ON p.id_pessoa = pr.id_pessoa "
                   + "WHERE pr.situacao = 'Ativo' ORDER BY p.nome");
    }

    public List<String> listarNiveis() throws SQLException {
        return lista("SELECT nome_nivel FROM nivel ORDER BY id_nivel");
    }

    private List<String> lista(String sql) throws SQLException {
        List<String> r = new ArrayList<>();
        try (Connection c = ConexaoBD.obterConexao(); PreparedStatement s = c.prepareStatement(sql); ResultSet rs = s.executeQuery()) {
            while (rs.next()) r.add(rs.getString(1));
        }
        return r;
    }
}