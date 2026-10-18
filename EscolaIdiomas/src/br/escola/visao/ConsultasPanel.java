package br.escola.visao;

import br.escola.dao.ConsultaDAO;
import br.escola.util.TradutorErroBD;
import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.sql.SQLException;
import java.util.List;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;

/** Duas consultas parametrizadas (B1): usuário informa filtros, o banco faz JOIN + GROUP BY. */
public class ConsultasPanel extends JPanel {

    private final ConsultaDAO dao = new ConsultaDAO();

    public ConsultasPanel() {
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        add(montarConsulta1());
        add(montarConsulta2());
    }

    private JPanel montarConsulta1() {
        JTextField txtIdioma = new JTextField(12);
        JComboBox<String> cbTurno = new JComboBox<>(new String[]{"", "Matutino", "Vespertino", "Noturno"});
        JSpinner spMin = new JSpinner(new SpinnerNumberModel(0, 0, 999, 1));
        JButton btn = new JButton("Consultar");
        DefaultTableModel modelo = new DefaultTableModel(ConsultaDAO.COLS_TURMAS, 0) {
            @Override public boolean isCellEditable(int r, int c) { return false; }
        };
        btn.addActionListener(e -> executar(modelo, () ->
                dao.ocupacaoPorIdioma(txtIdioma.getText(), (String) cbTurno.getSelectedItem(), (Integer) spMin.getValue())));
        JPanel filtros = new JPanel(new FlowLayout(FlowLayout.LEFT));
        filtros.add(new JLabel("Idioma:")); filtros.add(txtIdioma);
        filtros.add(new JLabel("Turno:"));  filtros.add(cbTurno);
        filtros.add(new JLabel("Mín. matrículas ativas:")); filtros.add(spMin);
        filtros.add(btn);
        return painel("1) Ocupação das turmas por idioma e turno", filtros, modelo);
    }

    private JPanel montarConsulta2() {
        JTextField txtNome = new JTextField(14);
        JComboBox<String> cbStatus = new JComboBox<>(new String[]{"", "ativa", "trancada", "concluída", "cancelada"});
        JButton btn = new JButton("Consultar");
        DefaultTableModel modelo = new DefaultTableModel(ConsultaDAO.COLS_ALUNOS, 0) {
            @Override public boolean isCellEditable(int r, int c) { return false; }
        };
        btn.addActionListener(e -> executar(modelo, () ->
                dao.matriculasPorAluno(txtNome.getText(), (String) cbStatus.getSelectedItem())));
        JPanel filtros = new JPanel(new FlowLayout(FlowLayout.LEFT));
        filtros.add(new JLabel("Nome do aluno:")); filtros.add(txtNome);
        filtros.add(new JLabel("Status:")); filtros.add(cbStatus);
        filtros.add(btn);
        return painel("2) Matrículas por aluno", filtros, modelo);
    }

    private JPanel painel(String titulo, JPanel filtros, DefaultTableModel modelo) {
        JPanel p = new JPanel(new BorderLayout());
        p.setBorder(BorderFactory.createTitledBorder(titulo));
        p.add(filtros, BorderLayout.NORTH);
        p.add(new JScrollPane(new JTable(modelo)), BorderLayout.CENTER);
        return p;
    }

    private interface Busca { List<Object[]> run() throws SQLException; }

    private void executar(DefaultTableModel modelo, Busca b) {
        try {
            List<Object[]> linhas = b.run();
            modelo.setRowCount(0);
            for (Object[] l : linhas) modelo.addRow(l);
            if (linhas.isEmpty()) JOptionPane.showMessageDialog(this, "Nenhum resultado para esses filtros.");
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(this, TradutorErroBD.traduzir(ex), "Atenção", JOptionPane.WARNING_MESSAGE);
        }
    }
}