package br.escola.visao;

import br.escola.dao.RelatorioOcupacaoDAO;
import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.sql.SQLException;
import java.util.List;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;

/** Relatório consolidado de ocupação das turmas, alimentado pela VIEW vw_relatorio_ocupacao (B1). */
public class RelatorioPanel extends JPanel {

    private final DefaultTableModel modelo = new DefaultTableModel(RelatorioOcupacaoDAO.COLUNAS, 0) {
        @Override public boolean isCellEditable(int r, int c) { return false; }
    };

    public RelatorioPanel() {
        setLayout(new BorderLayout());
        JButton btn = new JButton("Atualizar");
        btn.addActionListener(e -> carregar());
        JPanel topo = new JPanel(new FlowLayout(FlowLayout.LEFT));
        topo.add(btn);
        add(topo, BorderLayout.NORTH);
        add(new JScrollPane(new JTable(modelo)), BorderLayout.CENTER);
        carregar();
    }

    private void carregar() {
        try {
            List<Object[]> linhas = new RelatorioOcupacaoDAO().listar();
            modelo.setRowCount(0);
            for (Object[] l : linhas) modelo.addRow(l);
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(this,
                "Não foi possível carregar o relatório. Confira se a view vw_relatorio_ocupacao foi criada (sql/04_view_ocupacao.sql).",
                "Atenção", JOptionPane.WARNING_MESSAGE);
            ex.printStackTrace();
        }
    }
}