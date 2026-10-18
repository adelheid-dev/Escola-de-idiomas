package br.escola.controller;

import br.escola.dao.IdiomaDAO;
import br.escola.modelo.Idioma;
import java.time.format.DateTimeFormatter;
import java.util.List;
import javax.swing.JOptionPane;
import javax.swing.table.DefaultTableModel;

public class IdiomaController {
    
    private IdiomaDAO idiomaDAO;
    private DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    public IdiomaController() {
        this.idiomaDAO = new IdiomaDAO();
    }

    public void carregarTabela(DefaultTableModel modelo) {
        modelo.setNumRows(0);
        List<Idioma> lista = idiomaDAO.listarIdiomas();
        for (Idioma i : lista) {
            String dataFormatada = (i.getDataCadastro() != null) ? i.getDataCadastro().format(formatter) : "";
            modelo.addRow(new Object[]{
                i.getIdIdioma(),
                i.getNomeIdioma(),
                dataFormatada,
                i.getSituacao()
            });
        }
    }

    public void pesquisar(String nomeFiltro, DefaultTableModel modelo) {
        modelo.setNumRows(0);
        if (nomeFiltro.trim().isEmpty()) {
            carregarTabela(modelo);
            return;
        }
        List<Idioma> lista = idiomaDAO.pesquisarPorNome(nomeFiltro);
        for (Idioma i : lista) {
            String dataFormatada = (i.getDataCadastro() != null) ? i.getDataCadastro().format(formatter) : "";
            modelo.addRow(new Object[]{
                i.getIdIdioma(),
                i.getNomeIdioma(),
                dataFormatada,
                i.getSituacao()
            });
        }
    }

    public boolean salvar(String nome, String situacao) {
        if (nome.trim().isEmpty()) {
            JOptionPane.showMessageDialog(null, "O nome do idioma não pode estar vazio.");
            return false;
        }
        Idioma i = new Idioma();
        i.setNomeIdioma(nome);
        i.setSituacao(situacao);
        idiomaDAO.inserir(i);
        JOptionPane.showMessageDialog(null, "Idioma cadastrado com sucesso!");
        return true;
    }

    public boolean alterar(String idStr, String nome, String situacao) {
        if (idStr.trim().isEmpty() || nome.trim().isEmpty()) {
            JOptionPane.showMessageDialog(null, "Selecione um idioma e preencha o nome.");
            return false;
        }
        Idioma i = new Idioma();
        i.setIdIdioma(Integer.parseInt(idStr));
        i.setNomeIdioma(nome);
        i.setSituacao(situacao);
        idiomaDAO.alterar(i);
        JOptionPane.showMessageDialog(null, "Idioma alterado com sucesso!");
        return true;
    }

    public boolean excluir(String idStr) {
        if (idStr.trim().isEmpty()) {
            JOptionPane.showMessageDialog(null, "Selecione um idioma na tabela para excluir.");
            return false;
        }
        int confirm = JOptionPane.showConfirmDialog(null, "Deseja realmente excluir este idioma?", "Atenção", JOptionPane.YES_NO_OPTION);
        if (confirm == JOptionPane.YES_OPTION) {
            idiomaDAO.excluir(Integer.parseInt(idStr));
            JOptionPane.showMessageDialog(null, "Idioma excluído com sucesso!");
            return true;
        }
        return false;
    }
}