package br.escola.dao;

import br.escola.conexao.ConexaoBD;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.swing.JOptionPane;

public class RelatorioDAO {

    public List<Object[]> obterRelatorioConsolidado() {
        List<Object[]> lista = new ArrayList<>();
        String sql = "SELECT * FROM vw_relatorio_geral";
        
        try (Connection conn = ConexaoBD.obterConexao();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Object[] linha = new Object[]{
                    rs.getInt("id_turma"),
                    rs.getString("turno"),
                    rs.getString("sala"),
                    rs.getString("idioma"),
                    rs.getInt("total_alunos")
                };
                lista.add(linha);
            }
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(null, "Erro ao carregar dados da VIEW: " + br.escola.util.TradutorErroBD.traduzir(e));
        }
        return lista;
    }
}