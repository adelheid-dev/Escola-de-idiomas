package br.escola.dao;

import br.escola.conexao.ConexaoBD;
import br.escola.modelo.Aluno;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AlunoDAO {

    private Connection conectar() throws SQLException {
        Connection c = ConexaoBD.obterConexao();
        if (c == null) throw new SQLException("Não foi possível conectar ao banco de dados.");
        return c;
    }

    public void inserir(Aluno aluno) throws SQLException {
        String sqlPessoa = "INSERT INTO PESSOA (nome, cpf, email, telefone, data_nascimento) VALUES (?, ?, ?, ?, ?)";
        String sqlAluno = "INSERT INTO ALUNO (id_pessoa, data_matricula_inicial, situacao) VALUES (?, ?, ?)";
        
        Connection conn = null;
        try {
            conn = ConexaoBD.obterConexao();
            if (conn == null) throw new SQLException("Não foi possível conectar ao banco de dados.");
            conn.setAutoCommit(false);
            
            int idPessoaGerado;
            try (PreparedStatement stmtPessoa = conn.prepareStatement(sqlPessoa, PreparedStatement.RETURN_GENERATED_KEYS)) {
                stmtPessoa.setString(1, aluno.getNome());
                stmtPessoa.setString(2, aluno.getCpf());
                stmtPessoa.setString(3, aluno.getEmail());
                stmtPessoa.setString(4, aluno.getTelefone());
                stmtPessoa.setDate(5, aluno.getDataNascimento() != null ? java.sql.Date.valueOf(aluno.getDataNascimento()) : null);
                
                stmtPessoa.executeUpdate();
                
                try (ResultSet rsKeys = stmtPessoa.getGeneratedKeys()) {
                    if (rsKeys.next()) {
                        idPessoaGerado = rsKeys.getInt(1);
                    } else {
                        throw new SQLException("Falha ao obter o ID gerado para a pessoa.");
                    }
                }
            }
            
            try (PreparedStatement stmtAluno = conn.prepareStatement(sqlAluno)) {
                stmtAluno.setInt(1, idPessoaGerado);
                stmtAluno.setDate(2, aluno.getDataMatriculaInicial() != null ? java.sql.Date.valueOf(aluno.getDataMatriculaInicial()) : java.sql.Date.valueOf(java.time.LocalDate.now()));
                stmtAluno.setString(3, aluno.getSituacao() != null ? aluno.getSituacao() : "Ativo");
                stmtAluno.executeUpdate();
            }
            
            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    public List<Aluno> listarTodos() throws SQLException {
        List<Aluno> lista = new ArrayList<>();
        String sql = "SELECT p.id_pessoa, p.nome, p.cpf, p.email, p.telefone, p.data_nascimento, " +
                     "a.data_matricula_inicial, a.situacao " +
                     "FROM ALUNO a INNER JOIN PESSOA p ON a.id_pessoa = p.id_pessoa ORDER BY p.nome";
        
        try (Connection conn = conectar();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Aluno aluno = new Aluno();
                aluno.setIdPessoa(rs.getInt("id_pessoa"));
                aluno.setNome(rs.getString("nome"));
                aluno.setCpf(rs.getString("cpf"));
                aluno.setEmail(rs.getString("email"));
                aluno.setTelefone(rs.getString("telefone"));
                
                if (rs.getDate("data_nascimento") != null) {
                    aluno.setDataNascimento(rs.getDate("data_nascimento").toLocalDate());
                }
                if (rs.getDate("data_matricula_inicial") != null) {
                    aluno.setDataMatriculaInicial(rs.getDate("data_matricula_inicial").toLocalDate());
                }
                aluno.setSituacao(rs.getString("situacao"));
                lista.add(aluno);
            }
        } catch (SQLException e) {
            throw e;
        }
        return lista;
    }

    // Método universal de pesquisa (Atende tanto a 'pesquisar' quanto a 'buscarPorTermo')
    public List<Aluno> pesquisar(String termo) throws SQLException {
        List<Aluno> lista = new ArrayList<>();
        String sql = "SELECT p.id_pessoa, p.nome, p.cpf, p.email, p.telefone, p.data_nascimento, " +
                     "a.data_matricula_inicial, a.situacao " +
                     "FROM ALUNO a INNER JOIN PESSOA p ON a.id_pessoa = p.id_pessoa " +
                     "WHERE p.nome LIKE ? OR p.cpf LIKE ? OR CAST(p.id_pessoa AS CHAR) LIKE ? " +
                     "ORDER BY p.nome";
        
        try (Connection conn = conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String filtro = "%" + termo + "%";
            stmt.setString(1, filtro);
            stmt.setString(2, filtro);
            stmt.setString(3, filtro);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Aluno aluno = new Aluno();
                    aluno.setIdPessoa(rs.getInt("id_pessoa"));
                    aluno.setNome(rs.getString("nome"));
                    aluno.setCpf(rs.getString("cpf"));
                    aluno.setEmail(rs.getString("email"));
                    aluno.setTelefone(rs.getString("telefone"));
                    
                    if (rs.getDate("data_nascimento") != null) {
                        aluno.setDataNascimento(rs.getDate("data_nascimento").toLocalDate());
                    }
                    if (rs.getDate("data_matricula_inicial") != null) {
                        aluno.setDataMatriculaInicial(rs.getDate("data_matricula_inicial").toLocalDate());
                    }
                    aluno.setSituacao(rs.getString("situacao"));
                    lista.add(aluno);
                }
            }
        } catch (SQLException e) {
            throw e;
        }
        return lista;
    }

    // Atalho para compatibilidade com a tela
    public List<Aluno> buscarPorTermo(String termo) throws SQLException {
        return pesquisar(termo);
    }

    // Buscar aluno por ID específico
    public Aluno buscarPorId(int id) throws SQLException {
        String sql = "SELECT p.id_pessoa, p.nome, p.cpf, p.email, p.telefone, p.data_nascimento, " +
                     "a.data_matricula_inicial, a.situacao " +
                     "FROM ALUNO a INNER JOIN PESSOA p ON a.id_pessoa = p.id_pessoa " +
                     "WHERE p.id_pessoa = ?";
        
        try (Connection conn = conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Aluno aluno = new Aluno();
                    aluno.setIdPessoa(rs.getInt("id_pessoa"));
                    aluno.setNome(rs.getString("nome"));
                    aluno.setCpf(rs.getString("cpf"));
                    aluno.setEmail(rs.getString("email"));
                    aluno.setTelefone(rs.getString("telefone"));
                    
                    if (rs.getDate("data_nascimento") != null) {
                        aluno.setDataNascimento(rs.getDate("data_nascimento").toLocalDate());
                    }
                    if (rs.getDate("data_matricula_inicial") != null) {
                        aluno.setDataMatriculaInicial(rs.getDate("data_matricula_inicial").toLocalDate());
                    }
                    aluno.setSituacao(rs.getString("situacao"));
                    return aluno;
                }
            }
        } catch (SQLException e) {
            throw e;
        }
        return null;
    }

    public void alterar(Aluno aluno) throws SQLException {
        String sqlPessoa = "UPDATE PESSOA SET nome = ?, cpf = ?, email = ?, telefone = ?, data_nascimento = ? WHERE id_pessoa = ?";
        String sqlAluno = "UPDATE ALUNO SET situacao = ? WHERE id_pessoa = ?";

        Connection conn = null;
        try {
            conn = ConexaoBD.obterConexao();
            if (conn == null) throw new SQLException("Não foi possível conectar ao banco de dados.");
            conn.setAutoCommit(false);

            try (PreparedStatement stmtPessoa = conn.prepareStatement(sqlPessoa)) {
                stmtPessoa.setString(1, aluno.getNome());
                stmtPessoa.setString(2, aluno.getCpf());
                stmtPessoa.setString(3, aluno.getEmail());
                stmtPessoa.setString(4, aluno.getTelefone());
                stmtPessoa.setDate(5, aluno.getDataNascimento() != null ? java.sql.Date.valueOf(aluno.getDataNascimento()) : null);
                stmtPessoa.setInt(6, aluno.getIdPessoa());
                stmtPessoa.executeUpdate();
            }

            try (PreparedStatement stmtAluno = conn.prepareStatement(sqlAluno)) {
                stmtAluno.setString(1, aluno.getSituacao());
                stmtAluno.setInt(2, aluno.getIdPessoa());
                stmtAluno.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    // Atalho para compatibilidade com botões de atualizar
    public void atualizar(Aluno aluno) throws SQLException {
        alterar(aluno);
    }

    public void excluir(int idPessoa) throws SQLException {
        String sqlAluno = "DELETE FROM ALUNO WHERE id_pessoa = ?";
        String sqlPessoa = "DELETE FROM PESSOA WHERE id_pessoa = ?";

        Connection conn = null;
        try {
            conn = ConexaoBD.obterConexao();
            if (conn == null) throw new SQLException("Não foi possível conectar ao banco de dados.");
            conn.setAutoCommit(false);

            try (PreparedStatement stmtAluno = conn.prepareStatement(sqlAluno)) {
                stmtAluno.setInt(1, idPessoa);
                stmtAluno.executeUpdate();
            }

            try (PreparedStatement stmtPessoa = conn.prepareStatement(sqlPessoa)) {
                stmtPessoa.setInt(1, idPessoa);
                stmtPessoa.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}