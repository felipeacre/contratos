-- ============================================================
-- fix_controles_unique.sql
-- Corrige o módulo Controles que não salvava nada.
--
-- Causa: a tabela `controles` só tinha PRIMARY KEY (id).
-- Sem UNIQUE em `user_id`, o "INSERT ... ON DUPLICATE KEY UPDATE"
-- nunca disparava — cada clique em Salvar inseria uma linha NOVA,
-- e a tela continuava lendo a linha mais antiga (id = 1).
-- ============================================================

-- 1) Descarta linhas órfãs sem dono
DELETE FROM `controles` WHERE `user_id` IS NULL;

-- 2) Remove duplicatas, mantendo a de MAIOR id (a mais recente,
--    ou seja, a última tentativa de salvar do usuário)
DELETE c1 FROM `controles` c1
INNER JOIN `controles` c2
    ON c1.`user_id` = c2.`user_id`
   AND c1.`id` < c2.`id`;

-- 3) Trava: user_id passa a ser obrigatório e único
ALTER TABLE `controles`
    MODIFY `user_id` INT NOT NULL;

ALTER TABLE `controles`
    ADD UNIQUE KEY `uk_controles_user` (`user_id`);

-- 4) Conferência
SELECT * FROM `controles`;
SHOW INDEX FROM `controles`;
