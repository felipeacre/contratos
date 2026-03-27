<?php
// ============================================================
// config/Database.php — Singleton PDO
// ============================================================

class Database {
    private static ?PDO $instance = null;

    public static function get(): PDO {
        if (self::$instance === null) {
            $dsn = sprintf('mysql:host=%s;dbname=%s;charset=%s', DB_HOST, DB_NAME, DB_CHARSET);
            try {
                self::$instance = new PDO($dsn, DB_USER, DB_PASS, [
                    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES   => false,
                ]);
            } catch (PDOException $e) {
                // Em produção, logar e exibir mensagem genérica
                error_log('Erro de conexão: ' . $e->getMessage());
                die(json_encode(['erro' => 'Falha na conexão com o banco de dados.']));
            }
        }
        return self::$instance;
    }

    // Previne clonagem e unserialize
    private function __clone() {}
    public function __wakeup() {}
}
