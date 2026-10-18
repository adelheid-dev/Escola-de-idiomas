package br.escola.visao;

import br.escola.dao.TransacaoDAO;
import br.escola.util.TradutorErroBD;
import java.awt.FlowLayout;
import java.sql.SQLException;
import javax.swing.*;

/** Matricular aluno (matricula + historico_matricula numa transação). Marque "simular falha" para a demonstração do ROLLBACK. */
public class TransacaoPanel extends JPanel {

    private final JTextField txtAluno = new JTextField(6);
    private final JTextField txtTurma = new JTextField(6);
    private final JComboBox<String> cbForma = new JComboBox<>(new String[]{"", "PIX", "Cartão", "Boleto"});
    private final JCheckBox chkFalha = new JCheckBox("Simular falha no meio da transação");

    public TransacaoPanel() {
        setLayout(new FlowLayout(FlowLayout.LEFT));
        add(new JLabel("ID aluno:")); add(txtAluno);
        add(new JLabel("ID turma:")); add(txtTurma);
        add(new JLabel("Pagamento:")); add(cbForma);
        add(chkFalha);
        JButton btn = new JButton("Matricular");
        btn.addActionListener(e -> executar());
        add(btn);
    }

    private void executar() {
        try {
            int aluno = Integer.parseInt(txtAluno.getText().trim());
            int turma = Integer.parseInt(txtTurma.getText().trim());
            new TransacaoDAO().matricularComHistorico(aluno, turma, (String) cbForma.getSelectedItem(), chkFalha.isSelected());
            JOptionPane.showMessageDialog(this, "Matrícula e histórico gravados (COMMIT).");
        } catch (NumberFormatException ex) {
            aviso("Informe IDs numéricos válidos.");
        } catch (SQLException ex) {
            aviso(TradutorErroBD.traduzir(ex));
        } catch (IllegalArgumentException | IllegalStateException ex) {
            aviso(ex.getMessage());
        }
    }

    private void aviso(String t) { JOptionPane.showMessageDialog(this, t, "Atenção", JOptionPane.WARNING_MESSAGE); }
}