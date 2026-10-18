package br.escola.controller;

import br.escola.dao.MatriculaDAO;
import br.escola.modelo.Matricula;
import br.escola.util.TradutorErroBD;
import java.sql.SQLException;
import java.util.List;
import javax.swing.JOptionPane;

public class MatriculaController {

    private final MatriculaDAO matriculaDAO = new MatriculaDAO();

    private void aviso(String t) { JOptionPane.showMessageDialog(null, t, "Atenção", JOptionPane.WARNING_MESSAGE); }

    private void tratar(Exception e) {
        if (e instanceof SQLException)               aviso(TradutorErroBD.traduzir((SQLException) e));
        else if (e instanceof NumberFormatException) aviso("Os IDs devem ser números válidos.");
        else if (e instanceof IllegalArgumentException || e instanceof IllegalStateException) aviso(e.getMessage());
        else { e.printStackTrace(); aviso("Ocorreu um erro inesperado."); }
    }

    public boolean cadastrarMatricula(String idAlunoStr, String idTurmaStr, String status) {
        try {
            if (idAlunoStr == null || idAlunoStr.trim().isEmpty() || idTurmaStr == null || idTurmaStr.trim().isEmpty()) {
                aviso("Informe o ID do Aluno e o ID da Turma.");
                return false;
            }
            Matricula m = new Matricula();
            m.setIdAluno(Integer.parseInt(idAlunoStr.trim()));
            m.setIdTurma(Integer.parseInt(idTurmaStr.trim()));
            m.setStatusMatricula(status);
            matriculaDAO.inserir(m);
            JOptionPane.showMessageDialog(null, "Matrícula realizada com sucesso!");
            return true;
        } catch (Exception e) { tratar(e); return false; }
    }

    public List<Matricula> listarMatriculas() { return matriculaDAO.listarTodos(); }

    /** Recebe "idAluno-idTurma" (a PK composta). */
    public boolean cancelarMatricula(String chave) {
        try {
            if (chave == null || !chave.contains("-")) { aviso("Selecione uma matrícula na tabela para cancelar."); return false; }
            String[] p = chave.split("-");
            int idAluno = Integer.parseInt(p[0].trim());
            int idTurma = Integer.parseInt(p[1].trim());
            if (JOptionPane.showConfirmDialog(null, "Deseja realmente cancelar esta matrícula?", "Confirmação",
                    JOptionPane.YES_NO_OPTION) != JOptionPane.YES_OPTION) return false;
            matriculaDAO.cancelar(idAluno, idTurma);
            JOptionPane.showMessageDialog(null, "Matrícula cancelada com sucesso!");
            return true;
        } catch (Exception e) { tratar(e); return false; }
    }
}