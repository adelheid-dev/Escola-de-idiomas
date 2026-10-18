package br.escola.controller;

import br.escola.dao.TurmaDAO;
import br.escola.modelo.Turma;
import br.escola.util.TradutorErroBD;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.swing.JComboBox;
import javax.swing.JOptionPane;
import javax.swing.JSpinner;
import javax.swing.SpinnerNumberModel;

/**
 * Na tela de turmas, o campo "Nome da Turma" passou a ser a SALA e o combo "Horário" passou a ser o TURNO,
 * porque são essas as colunas que existem na tabela turma.
 */
public class TurmaController {

    private final TurmaDAO turmaDAO = new TurmaDAO();

    private void aviso(String t) { JOptionPane.showMessageDialog(null, t, "Atenção", JOptionPane.WARNING_MESSAGE); }

    private void tratar(Exception e) {
        if (e instanceof SQLException)               aviso(TradutorErroBD.traduzir((SQLException) e));
        else if (e instanceof NumberFormatException) aviso("O ID da turma deve ser um número.");
        else if (e instanceof IllegalArgumentException) aviso(e.getMessage());
        else { e.printStackTrace(); aviso("Ocorreu um erro inesperado."); }
    }

    // ---- listas dos combos (vêm do banco) ----

    public String[] nomesIdiomas() {
        try { return turmaDAO.listarNomesIdiomas().toArray(new String[0]); }
        catch (SQLException e) { tratar(e); return new String[0]; }
    }

    public String[] nomesProfessores() {
        try { return turmaDAO.listarNomesProfessores().toArray(new String[0]); }
        catch (SQLException e) { tratar(e); return new String[0]; }
    }

    public String[] turnos() { return new String[]{"Matutino", "Vespertino", "Noturno"}; }

    // ---- CRUD ----

    private Turma montar(String sala, String idioma, String turno, String professor) {
        if (sala == null || sala.trim().isEmpty()) throw new IllegalArgumentException("Informe a sala da turma.");
        if (sala.trim().length() > 20)             throw new IllegalArgumentException("A sala pode ter no máximo 20 caracteres.");
        if (idioma == null || idioma.trim().isEmpty())       throw new IllegalArgumentException("Selecione o idioma.");
        if (professor == null || professor.trim().isEmpty()) throw new IllegalArgumentException("Selecione o professor.");
        if (turno == null || turno.trim().isEmpty())         throw new IllegalArgumentException("Selecione o turno.");
        Turma t = new Turma();
        t.setNomeTurma(sala.trim());       // sala
        t.setIdioma(idioma.trim());
        t.setHorario(turno.trim());        // turno
        t.setProfessor(professor.trim());
        return t;
    }

    public boolean inserirTurma(String sala, String idioma, String turno, String professor) {
        try {
            Turma t = montar(sala, idioma, turno, professor);

            // Nível e vagas não estão no formulário: são perguntados aqui
            JComboBox<String> cbNivel = new JComboBox<>(turmaDAO.listarNiveis().toArray(new String[0]));
            JSpinner spVagas = new JSpinner(new SpinnerNumberModel(10, 1, 100, 1));
            Object[] campos = {"Nível:", cbNivel, "Vagas:", spVagas};
            int r = JOptionPane.showConfirmDialog(null, campos, "Dados complementares da turma",
                    JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
            if (r != JOptionPane.OK_OPTION) return false;

            turmaDAO.inserir(t, (String) cbNivel.getSelectedItem(), (Integer) spVagas.getValue());
            JOptionPane.showMessageDialog(null, "Turma cadastrada com sucesso!");
            return true;
        } catch (Exception e) { tratar(e); return false; }
    }

    public List<Turma> listarTurmas() {
        try { return turmaDAO.listarTodos(); }
        catch (SQLException e) { tratar(e); return new ArrayList<>(); }
    }

    public boolean alterarTurma(String idStr, String sala, String idioma, String turno, String professor) {
        try {
            if (idStr == null || idStr.trim().isEmpty()) { aviso("Selecione uma turma na tabela para atualizar."); return false; }
            Turma t = montar(sala, idioma, turno, professor);
            t.setIdTurma(Integer.parseInt(idStr.trim()));
            turmaDAO.alterar(t);
            JOptionPane.showMessageDialog(null, "Turma atualizada com sucesso!");
            return true;
        } catch (Exception e) { tratar(e); return false; }
    }

    public boolean excluirTurma(String idStr) {
        try {
            if (idStr == null || idStr.trim().isEmpty()) { aviso("Selecione uma turma na tabela para excluir."); return false; }
            if (JOptionPane.showConfirmDialog(null, "Deseja realmente excluir esta turma?", "Confirmação",
                    JOptionPane.YES_NO_OPTION) != JOptionPane.YES_OPTION) return false;
            turmaDAO.excluir(Integer.parseInt(idStr.trim()));
            JOptionPane.showMessageDialog(null, "Turma excluída com sucesso!");
            return true;
        } catch (Exception e) { tratar(e); return false; }
    }
}