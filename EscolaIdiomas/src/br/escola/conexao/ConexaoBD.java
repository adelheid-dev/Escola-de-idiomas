package br.escola.conexao;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

/**
 * Abre conexões com o MySQL. As credenciais NÃO ficam no código (B2):
 * vêm do arquivo conexao.properties (pasta do projeto, fora do Git) ou das
 * variáveis de ambiente ESCOLA_DB_URL, ESCOLA_DB_USER e ESCOLA_DB_PASSWORD.
 * O arquivo é procurado na pasta de trabalho e nas pastas acima de onde o programa está rodando
 * (build/classes, build, pasta do projeto), então funciona no NetBeans e fora dele.
 * Em caso de falha lança SQLException com mensagem compreensível; quem chama decide como exibir.
 */
public class ConexaoBD {

    private static final String ARQUIVO = "conexao.properties";
    private static Properties config;

    /** Procura o conexao.properties na pasta de trabalho e subindo a partir do local das classes. */
    private static File localizar() {
        List<File> bases = new ArrayList<>();
        bases.add(new File(System.getProperty("user.dir")));
        try {
            File f = new File(ConexaoBD.class.getProtectionDomain().getCodeSource().getLocation().toURI());
            for (int i = 0; i < 4 && f != null; i++) {
                bases.add(f.isDirectory() ? f : f.getParentFile());
                f = f.getParentFile();
            }
        } catch (Exception e) {
            // sem como descobrir o local das classes: fica só a pasta de trabalho
        }
        for (File b : bases) {
            if (b == null) continue;
            File candidato = new File(b, ARQUIVO);
            if (candidato.isFile()) return candidato;
        }
        return null;
    }

    private static synchronized Properties carregar() {
        if (config == null) {
            Properties p = new Properties();
            File arquivo = localizar();
            if (arquivo != null) {
                try (InputStream in = new FileInputStream(arquivo)) {
                    p.load(in);
                } catch (IOException e) {
                    // arquivo ilegível: ainda é possível usar variáveis de ambiente
                }
            }
            config = p;
        }
        return config;
    }

    private static String ler(String chave, String variavelAmbiente) {
        String env = System.getenv(variavelAmbiente);
        if (env != null && !env.isEmpty()) return env;
        String v = carregar().getProperty(chave);
        return v == null ? null : v.trim();
    }

    public static Connection obterConexao() throws SQLException {
        String url   = ler("db.url", "ESCOLA_DB_URL");
        String user  = ler("db.user", "ESCOLA_DB_USER");
        String senha = ler("db.password", "ESCOLA_DB_PASSWORD");

        if (url == null || user == null || senha == null) {
            throw new SQLException("Configuração do banco não encontrada. Crie o arquivo conexao.properties "
                    + "(modelo em conexao.properties.example) na pasta " + System.getProperty("user.dir")
                    + " com as chaves db.url, db.user e db.password, ou defina ESCOLA_DB_URL, ESCOLA_DB_USER e ESCOLA_DB_PASSWORD.",
                    "08001");
        }
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver do MySQL não encontrado. Adicione o mysql-connector-j às bibliotecas do projeto.", "08001", e);
        }
        try {
            return DriverManager.getConnection(url, user, senha);
        } catch (SQLException e) {
            throw new SQLException("Não foi possível conectar ao banco de dados. Verifique se o MySQL está ligado "
                    + "e se o usuário e a senha do conexao.properties estão corretos.", "08001", e);
        }
    }
}