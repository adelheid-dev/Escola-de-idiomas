package br.escola.dao;

import br.escola.conexao.ConexaoBD; 
import br.escola.modelo.Financeiro;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class FinanceiroDAO {

    // 1. INSERIR REGISTRO FINANCEIRO (Transação / Gravação)
    public void inserir(Financeiro f) throws SQLException {
        String sql = "INSERT INTO PAGAMENTO (id_aluno, id_turma, valor, data_pagamento, forma_pagamento, status) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = ConexaoBD.obterConexao();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, f.getIdAluno());
            stmt.setInt(2, f.getIdTurma());
            stmt.setDouble(3, f.getValor());
            
            if (f.getDataPagamento() != null) {
                stmt.setDate(4, Date.valueOf(f.getDataPagamento()));
            } else {
                stmt.setNull(4, java.sql.Types.DATE);
            }
            
            stmt.setString(5, f.getFormaPagamento() == null ? null : f.getFormaPagamento().trim());
            stmt.setString(6, f.getStatus() == null ? null : f.getStatus().trim());

            stmt.executeUpdate();

        } catch (SQLException e) {
            throw e;
        }
    }

    // 2. LISTAR TODOS OS REGISTROS FINANCEIROS
    public List<Financeiro> listarTodos() throws SQLException {
        List<Financeiro> lista = new ArrayList<>();
        String sql = "SELECT * FROM PAGAMENTO ORDER BY id_pagamento DESC";

        try (Connection conn = ConexaoBD.obterConexao();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Financeiro f = new Financeiro();
                f.setIdPagamento(rs.getInt("id_pagamento"));
                f.setIdAluno(rs.getInt("id_aluno"));
                f.setIdTurma(rs.getInt("id_turma"));
                f.setValor(rs.getDouble("valor"));
                
                Date data = rs.getDate("data_pagamento");
                if (data != null) {
                    f.setDataPagamento(data.toLocalDate());
                }
                
                f.setFormaPagamento(rs.getString("forma_pagamento"));
                f.setStatus(rs.getString("status"));

                lista.add(f);
            }

        } catch (SQLException e) {
            throw e;
        }

        return lista;
    }

    // 3. ATUALIZAR REGISTRO FINANCEIRO
    public void atualizar(Financeiro f) throws SQLException {
        String sql = "UPDATE PAGAMENTO SET id_aluno = ?, id_turma = ?, valor = ?, data_pagamento = ?, forma_pagamento = ?, status = ? WHERE id_pagamento = ?";

        try (Connection conn = ConexaoBD.obterConexao();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, f.getIdAluno());
            stmt.setInt(2, f.getIdTurma());
            stmt.setDouble(3, f.getValor());
            
            if (f.getDataPagamento() != null) {
                stmt.setDate(4, Date.valueOf(f.getDataPagamento()));
            } else {
                stmt.setNull(4, java.sql.Types.DATE);
            }
            
            stmt.setString(5, f.getFormaPagamento() == null ? null : f.getFormaPagamento().trim());
            stmt.setString(6, f.getStatus() == null ? null : f.getStatus().trim());
            stmt.setInt(7, f.getIdPagamento());

            stmt.executeUpdate();

        } catch (SQLException e) {
            throw e;
        }
    }

    // 4. EXCLUIR REGISTRO FINANCEIRO
    public void excluir(int idPagamento) throws SQLException {
        String sql = "DELETE FROM PAGAMENTO WHERE id_pagamento = ?";

        try (Connection conn = ConexaoBD.obterConexao();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idPagamento);
            stmt.executeUpdate();

        } catch (SQLException e) {
            throw e;
        }
    }
}