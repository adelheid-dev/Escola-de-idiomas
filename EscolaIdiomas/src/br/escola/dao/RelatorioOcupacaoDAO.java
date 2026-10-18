package br.escola.dao;

import br.escola.conexao.ConexaoBD;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Lê a VIEW vw_relatorio_ocupacao (script sql/04_view_ocupacao.sql). */
public class RelatorioOcupacaoDAO {

    public static final String[] COLUNAS = {"Turma", "Idioma", "Nível", "Turno", "Sala", "Professor",
                                            "Vagas", "Ocupadas", "Livres", "Ocupação %"};

    public List<Object[]> listar() throws SQLException {
        List<Object[]> r = new ArrayList<>();
        String sql = "SELECT id_turma, idioma, nivel, turno, sala, professor, vagas_totais, "
                   + "matriculas_ativas, vagas_livres, ocupacao_pct FROM vw_relatorio_ocupacao ORDER BY id_turma";
        try (Connection c = ConexaoBD.obterConexao(); PreparedStatement s = c.prepareStatement(sql); ResultSet rs = s.executeQuery()) {
            while (rs.next()) {
                r.add(new Object[]{rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5),
                                   rs.getString(6), rs.getInt(7), rs.getInt(8), rs.getInt(9), rs.getDouble(10)});
            }
        }
        return r;
    }
}