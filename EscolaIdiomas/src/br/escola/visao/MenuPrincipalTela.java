package br.escola.visao;

import java.awt.Component;
import java.awt.Container;
import java.util.Arrays;
import java.util.List;
import javax.swing.JFrame;
import javax.swing.JTabbedPane;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;

/**
 * Janela principal. Reaproveita as 4 telas existentes SEM editá-las:
 * pega o contentPane de cada JFrame e remove as abas internas repetidas,
 * deixando só a aba que pertence àquela tela.
 */
public class MenuPrincipalTela extends JFrame {

    public MenuPrincipalTela() {
        super("Escola de Idiomas");
        setDefaultCloseOperation(EXIT_ON_CLOSE);

        JTabbedPane abas = new JTabbedPane();
        abas.addTab("Alunos",     soAbas(new AlunoTela(),     "Gerencia Alunos"));
        abas.addTab("Turmas",     soAbas(new TurmaTela(),     "Gerenciar Turmas"));
        abas.addTab("Idiomas",    soAbas(new IdiomaTela(),    "Idiomas"));
        abas.addTab("Matrículas", soAbas(new MatriculaTela(), "Matrículas"));
        abas.addTab("Consultas",  new ConsultasPanel());
        abas.addTab("Relatório",  new RelatorioPanel());
        abas.addTab("Transação",  new TransacaoPanel());

        setContentPane(abas);
        setSize(1100, 700);
        setLocationRelativeTo(null);
    }

    /** Remove as abas internas que não estão em 'manter'. Se sobrar uma só, devolve o painel dela (sem a barra de abas). */
    private static Component soAbas(JFrame tela, String... manter) {
        List<String> ficam = Arrays.asList(manter);
        JTabbedPane interna = acharAbas(tela.getContentPane(), ficam.get(0));
        if (interna == null) return tela.getContentPane();   // não achou: mostra a tela inteira, como veio
        for (int i = interna.getTabCount() - 1; i >= 0; i--) {
            if (!ficam.contains(interna.getTitleAt(i).trim())) interna.removeTabAt(i);
        }
        return interna.getTabCount() == 1 ? interna.getComponentAt(0) : tela.getContentPane();
    }

    /** Procura, em toda a árvore, o JTabbedPane que tem uma aba com o título dado. */
    private static JTabbedPane acharAbas(Container raiz, String titulo) {
        for (Component c : raiz.getComponents()) {
            if (c instanceof JTabbedPane) {
                JTabbedPane tp = (JTabbedPane) c;
                for (int i = 0; i < tp.getTabCount(); i++) {
                    if (tp.getTitleAt(i).trim().equals(titulo)) return tp;
                }
            }
            if (c instanceof Container) {
                JTabbedPane achou = acharAbas((Container) c, titulo);
                if (achou != null) return achou;
            }
        }
        return null;
    }

    public static void main(String[] args) {
        try { UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()); } catch (Exception ignored) { }
        SwingUtilities.invokeLater(() -> new MenuPrincipalTela().setVisible(true));
    }
}