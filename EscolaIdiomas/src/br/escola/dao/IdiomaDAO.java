package br.escola.dao;

import br.escola.conexao.ConexaoBD;
import br.escola.util.TradutorErroBD;
import br.escola.modelo.Idioma;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.swing.JOptionPane;

public class IdiomaDAO {

    public void inserir(Idioma idioma) {
        String sql = "INSERT INTO idioma (nome_idioma, data_cadastro, situacao) VALUES (?, CURDATE(), ?)";
        try (Connection conn = ConexaoBD.obterConexao();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, idioma.getNomeIdioma());
            stmt.setString(2, idioma.getSituacao() != null ? idioma.getSituacao() : "Ativo");
            stmt.executeUpdate();
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(null, TradutorErroBD.traduzir(e), "Atenção", JOptionPane.WARNING_MESSAGE);
        }
    }

    public List<Idioma> listarIdiomas() {
        List<Idioma> lista = new ArrayList<>();
        String sql = "SELECT id_idioma, nome_idioma, data_cadastro, situacao FROM idioma ORDER BY nome_idioma";
        try (Connection conn = ConexaoBD.obterConexao();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Idioma idioma = new Idioma();
                idioma.setIdIdioma(rs.getInt("id_idioma"));
                idioma.setNomeIdioma(rs.getString("nome_idioma"));
                if (rs.getDate("data_cadastro") != null) {
                    idioma.setDataCadastro(rs.getDate("data_cadastro").toLocalDate());
                }
                idioma.setSituacao(rs.getString("situacao"));
                lista.add(idioma);
            }
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(null, TradutorErroBD.traduzir(e), "Atenção", JOptionPane.WARNING_MESSAGE);
        }
        return lista;
    }

    public List<Idioma> pesquisarPorNome(String nomeFiltro) {
        List<Idioma> lista = new ArrayList<>();
        String sql = "SELECT id_idioma, nome_idioma, data_cadastro, situacao FROM idioma WHERE nome_idioma LIKE ? ORDER BY nome_idioma";
        try (Connection conn = ConexaoBD.obterConexao();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + nomeFiltro + "%");
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Idioma idioma = new Idioma();
                    idioma.setIdIdioma(rs.getInt("id_idioma"));
                    idioma.setNomeIdioma(rs.getString("nome_idioma"));
                    if (rs.getDate("data_cadastro") != null) {
                        idioma.setDataCadastro(rs.getDate("data_cadastro").toLocalDate());
                    }
                    idioma.setSituacao(rs.getString("situacao"));
                    lista.add(idioma);
                }
            }
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(null, TradutorErroBD.traduzir(e), "Atenção", JOptionPane.WARNING_MESSAGE);
        }
        return lista;
    }

    public void alterar(Idioma idioma) {
        String sql = "UPDATE idioma SET nome_idioma = ?, situacao = ? WHERE id_idioma = ?";
        try (Connection conn = ConexaoBD.obterConexao();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, idioma.getNomeIdioma());
            stmt.setString(2, idioma.getSituacao());
            stmt.setInt(3, idioma.getIdIdioma());
            stmt.executeUpdate();
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(null, TradutorErroBD.traduzir(e), "Atenção", JOptionPane.WARNING_MESSAGE);
        }
    }

    public void excluir(int idIdioma) {
        String sql = "DELETE FROM idioma WHERE id_idioma = ?";
        try (Connection conn = ConexaoBD.obterConexao();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idIdioma);
            stmt.executeUpdate();
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(null, TradutorErroBD.traduzir(e), "Atenção", JOptionPane.WARNING_MESSAGE);
        }
    }
}