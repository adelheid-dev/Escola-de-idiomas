package br.escola.modelo;

import java.time.LocalDate;

public class Financeiro {

    private int idPagamento;
    private int idAluno;   // a matrícula é identificada pela chave composta (id_aluno, id_turma)
    private int idTurma;
    private double valor;
    private LocalDate dataPagamento;
    private String formaPagamento;
    private String status;

    // Construtor Vazio
    public Financeiro() {
    }

    // Construtor Completo
    public Financeiro(int idPagamento, int idAluno, int idTurma, double valor, LocalDate dataPagamento, String formaPagamento, String status) {
        this.idPagamento = idPagamento;
        this.idAluno = idAluno;
        this.idTurma = idTurma;
        this.valor = valor;
        this.dataPagamento = dataPagamento;
        this.formaPagamento = formaPagamento;
        this.status = status;
    }

    // Getters e Setters
    public int getIdPagamento() {
        return idPagamento;
    }

    public void setIdPagamento(int idPagamento) {
        this.idPagamento = idPagamento;
    }

    public int getIdAluno() {
        return idAluno;
    }

    public void setIdAluno(int idAluno) {
        this.idAluno = idAluno;
    }

    public int getIdTurma() {
        return idTurma;
    }

    public void setIdTurma(int idTurma) {
        this.idTurma = idTurma;
    }

    public double getValor() {
        return valor;
    }

    public void setValor(double valor) {
        this.valor = valor;
    }

    public LocalDate getDataPagamento() {
        return dataPagamento;
    }

    public void setDataPagamento(LocalDate dataPagamento) {
        this.dataPagamento = dataPagamento;
    }

    public String getFormaPagamento() {
        return formaPagamento;
    }

    public void setFormaPagamento(String formaPagamento) {
        this.formaPagamento = formaPagamento;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}