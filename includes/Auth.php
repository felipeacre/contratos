<?php
// ============================================================
// includes/Auth.php
// ============================================================

class Auth {

    public static function login(string $email, string $senha): bool {
        $db   = Database::get();
        $stmt = $db->prepare('SELECT id, nome, senha_hash, nivel, ativo FROM usuarios WHERE email = ? LIMIT 1');
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if (!$user || !$user['ativo'] || !password_verify($senha, $user['senha_hash'])) {
            return false;
        }

        $_SESSION['usuario_id']   = $user['id'];
        $_SESSION['usuario_nome'] = $user['nome'];
        $_SESSION['usuario_nivel']= $user['nivel'];
        $_SESSION['login_time']   = time();

        // Atualiza último acesso
        $db->prepare('UPDATE usuarios SET ultimo_acesso = NOW() WHERE id = ?')
           ->execute([$user['id']]);

        return true;
    }

    public static function logout(): void {
        $_SESSION = [];
        session_destroy();
    }

    public static function check(): bool {
        if (empty($_SESSION['usuario_id'])) return false;
        // Timeout de sessão
        if (time() - ($_SESSION['login_time'] ?? 0) > SESSION_LIFETIME) {
            self::logout();
            return false;
        }
        return true;
    }

    public static function require_login(): void {
        if (!self::check()) {
            redirect(BASE_URL . '/login.php');
        }
    }

    public static function require_admin(): void {
        self::require_login();
        if ($_SESSION['usuario_nivel'] !== 'admin') {
            flash('danger', 'Acesso restrito a administradores.');
            redirect(BASE_URL . '/index.php');
        }
    }

    public static function is_admin(): bool {
        return ($_SESSION['usuario_nivel'] ?? '') === 'admin';
    }

    public static function usuario_nome(): string {
        return $_SESSION['usuario_nome'] ?? 'Desconhecido';
    }
}
