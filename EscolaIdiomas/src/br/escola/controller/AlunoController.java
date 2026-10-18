package br.escola.controller;

import br.escola.dao.AlunoDAO;
import br.escola.modelo.Aluno;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import javax.swing.table.DefaultTableModel;

public class AlunoController {

    private AlunoDAO alunoDAO;
    private DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    public AlunoController() {
        this.alunoDAO = new AlunoDAO();
    }

    // Validações e padronização antes de gravar (RN01, RN02, RN03 e NOT NULL do DDL)
    private void validarEPadronizar(Aluno a) {
        if (a.getNome() == null || a.getNome().trim().isEmpty())
            throw new IllegalArgumentException("Informe o nome do aluno.");
        a.setNome(a.getNome().trim());

        String cpf = a.getCpf() == null ? "" : a.getCpf().replaceAll("[^0-9]", "");
        if (cpf.length() != 11)
            throw new IllegalArgumentException("O CPF deve ter exatamente 11 números.");
        a.setCpf(cpf);

        String email = a.getEmail() == null ? "" : a.getEmail().trim();
        if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$"))
            throw new IllegalArgumentException("Informe um e-mail válido.");
        a.setEmail(email);

        if (a.getDataNascimento() == null)
            throw new IllegalArgumentException("Informe a data de nascimento (dd/MM/aaaa).");
        if (a.getDataNascimento().isAfter(java.time.LocalDate.now()))
            throw new IllegalArgumentException("A data de nascimento não pode ser futura.");

        if (a.getTelefone() != null && a.getTelefone().trim().isEmpty())
            a.setTelefone(null); // telefone é opcional: grava NULL, não texto vazio
    }

    public void cadastrarAluno(Aluno aluno) throws SQLException {
        validarEPadronizar(aluno);
        alunoDAO.inserir(aluno);
    }

    public void atualizarAluno(Aluno aluno) throws SQLException {
        if (aluno.getIdPessoa() <= 0)
            throw new IllegalArgumentException("Selecione um aluno na tabela.");
        validarEPadronizar(aluno);
        alunoDAO.alterar(aluno);
    }

    public void excluirAluno(int idPessoa) throws SQLException {
        if (idPessoa <= 0)
            throw new IllegalArgumentException("Selecione um aluno na tabela.");
        alunoDAO.excluir(idPessoa);
    }

    // Listar todos os Alunos
    public List<Aluno> listarAlunos() throws SQLException {
        return alunoDAO.listarTodos();
    }

    // Pesquisar por filtro (Nome, CPF ou ID)
    public List<Aluno> pesquisarAlunos(String termo) throws SQLException {
        if (termo == null || termo.trim().isEmpty() || termo.equalsIgnoreCase("Busca por Nome, CPF ou ID..")) {
            return alunoDAO.listarTodos();
        }
        return alunoDAO.pesquisar(termo.trim());
    }

    // Método para preencher diretamente a JTable no Swing
    public void carregarTabela(DefaultTableModel modelo) throws SQLException {
        modelo.setRowCount(0);
        List<Aluno> lista = alunoDAO.listarTodos();
        for (Aluno a : lista) {
            String dataMatriculaStr = (a.getDataMatriculaInicial() != null) ? a.getDataMatriculaInicial().format(formatter) : "";
            modelo.addRow(new Object[]{
                a.getIdPessoa(),
                a.getCpf(),
                a.getEmail(),
                a.getTelefone(),
                dataMatriculaStr,
                a.getSituacao()
            });
        }
    }
}