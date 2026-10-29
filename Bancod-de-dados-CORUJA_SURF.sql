-- ============================================================
-- PROJETO: CORUJA SURF
-- Banco de dados relacional para loja de roupas e vendas online
-- SGBD: MySQL 8.0+
-- Como usar: abra este arquivo no MySQL Workbench e execute-o.
-- ATENCAO: o comando DROP DATABASE apaga uma base com este nome.
-- Remova as duas linhas DROP/CREATE DATABASE se nao quiser recriar.
-- ============================================================

DROP DATABASE IF EXISTS coruja_surf;
CREATE DATABASE coruja_surf
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE coruja_surf;

-- 1. CLIENTES
CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    endereco VARCHAR(255),
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. USUARIOS DO SISTEMA
-- A aplicacao deve armazenar somente hash de senha, nunca senha em texto puro.
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    perfil ENUM('Proprietario', 'Funcionario') NOT NULL DEFAULT 'Funcionario',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. PRODUTOS
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT,
    categoria VARCHAR(100),
    tamanho VARCHAR(20),
    cor VARCHAR(50),
    preco DECIMAL(10,2) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_produto_preco CHECK (preco >= 0)
) ENGINE=InnoDB;

-- 4. ESTOQUE: um registro por produto
CREATE TABLE estoque (
    id_estoque INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL UNIQUE,
    quantidade_atual INT NOT NULL DEFAULT 0,
    estoque_minimo INT NOT NULL DEFAULT 5,
    data_atualizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_estoque_produto FOREIGN KEY (id_produto)
      REFERENCES produto(id_produto)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_estoque_quantidade CHECK (quantidade_atual >= 0),
    CONSTRAINT chk_estoque_minimo CHECK (estoque_minimo >= 0)
) ENGINE=InnoDB;

-- 5. VENDAS
CREATE TABLE venda (
    id_venda INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NULL,
    id_usuario INT NOT NULL,
    data_venda DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0,
    status ENUM('Pendente', 'Confirmada', 'Cancelada', 'Concluida')
      NOT NULL DEFAULT 'Pendente',
    CONSTRAINT fk_venda_cliente FOREIGN KEY (id_cliente)
      REFERENCES cliente(id_cliente)
      ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_venda_usuario FOREIGN KEY (id_usuario)
      REFERENCES usuario(id_usuario)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_venda_total CHECK (valor_total >= 0),
    INDEX idx_venda_data (data_venda),
    INDEX idx_venda_status (status)
) ENGINE=InnoDB;

-- 6. ITENS DA VENDA
CREATE TABLE item_venda (
    id_item_venda INT AUTO_INCREMENT PRIMARY KEY,
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS
      (quantidade * preco_unitario) STORED,
    CONSTRAINT fk_item_venda_venda FOREIGN KEY (id_venda)
      REFERENCES venda(id_venda)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_item_venda_produto FOREIGN KEY (id_produto)
      REFERENCES produto(id_produto)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_item_venda_quantidade CHECK (quantidade > 0),
    CONSTRAINT chk_item_venda_preco CHECK (preco_unitario >= 0),
    INDEX idx_item_venda_venda (id_venda),
    INDEX idx_item_venda_produto (id_produto)
) ENGINE=InnoDB;

-- 7. PEDIDOS ONLINE
CREATE TABLE pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NULL,
    data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0,
    status ENUM('Recebido', 'Pagamento pendente', 'Pago',
                'Em preparacao', 'Enviado', 'Concluido', 'Cancelado')
      NOT NULL DEFAULT 'Recebido',
    observacao TEXT,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
      REFERENCES cliente(id_cliente)
      ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_pedido_total CHECK (valor_total >= 0),
    INDEX idx_pedido_data (data_pedido),
    INDEX idx_pedido_status (status)
) ENGINE=InnoDB;

-- 8. ITENS DO PEDIDO: necessario para saber quais produtos foram pedidos
CREATE TABLE item_pedido (
    id_item_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS
      (quantidade * preco_unitario) STORED,
    CONSTRAINT fk_item_pedido_pedido FOREIGN KEY (id_pedido)
      REFERENCES pedido(id_pedido)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_item_pedido_produto FOREIGN KEY (id_produto)
      REFERENCES produto(id_produto)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_item_pedido_quantidade CHECK (quantidade > 0),
    CONSTRAINT chk_item_pedido_preco CHECK (preco_unitario >= 0),
    INDEX idx_item_pedido_pedido (id_pedido)
) ENGINE=InnoDB;

-- 9. PAGAMENTOS
-- Cada pagamento deve pertencer a uma venda OU a um pedido, nunca aos dois.


CREATE TABLE pagamento (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_venda INT NULL,
    id_pedido INT NULL,
    valor DECIMAL(10,2) NOT NULL,
    forma_pagamento ENUM(
        'Pix',
        'Dinheiro',
        'Cartao de credito',
        'Cartao de debito',
        'Boleto',
        'Transferencia'
    ) NOT NULL,
    parcelas INT NOT NULL DEFAULT 1,
    status ENUM(
        'Pendente',
        'Aprovado',
        'Recusado',
        'Estornado'
    ) NOT NULL DEFAULT 'Pendente',
    comprovante VARCHAR(255),
    data_pagamento DATETIME NULL,

    INDEX idx_pagamento_status (status),

    CONSTRAINT fk_pagamento_venda
        FOREIGN KEY (id_venda)
        REFERENCES venda(id_venda)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_pagamento_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;


-- 10. NOTIFICACOES
CREATE TABLE notificacao (
    id_notificacao INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    tipo ENUM('Estoque baixo', 'Pagamento recebido', 'Novo pedido',
              'Aviso geral') NOT NULL,
    mensagem TEXT NOT NULL,
    data_envio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    lida BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_notificacao_usuario FOREIGN KEY (id_usuario)
      REFERENCES usuario(id_usuario)
      ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_notificacao_usuario_lida (id_usuario, lida)
) ENGINE=InnoDB;

-- TRIGGER: cria automaticamente o registro de estoque ao cadastrar produto.
DELIMITER $$
CREATE TRIGGER trg_produto_criar_estoque
AFTER INSERT ON produto
FOR EACH ROW
BEGIN
    INSERT INTO estoque (id_produto, quantidade_atual, estoque_minimo)
    VALUES (NEW.id_produto, 0, 5);
END$$

-- TRIGGER: atualiza o total da venda quando um item e incluido.
CREATE TRIGGER trg_item_venda_total_insert
AFTER INSERT ON item_venda
FOR EACH ROW
BEGIN
    UPDATE venda
       SET valor_total = (
         SELECT COALESCE(SUM(subtotal), 0)
         FROM item_venda
         WHERE id_venda = NEW.id_venda
       )
     WHERE id_venda = NEW.id_venda;
END$$

-- TRIGGER: recalcula o total quando um item e alterado.
CREATE TRIGGER trg_item_venda_total_update
AFTER UPDATE ON item_venda
FOR EACH ROW
BEGIN
    UPDATE venda
       SET valor_total = (
         SELECT COALESCE(SUM(subtotal), 0)
         FROM item_venda
         WHERE id_venda = NEW.id_venda
       )
     WHERE id_venda = NEW.id_venda;

    IF OLD.id_venda <> NEW.id_venda THEN
        UPDATE venda
           SET valor_total = (
             SELECT COALESCE(SUM(subtotal), 0)
             FROM item_venda
             WHERE id_venda = OLD.id_venda
           )
         WHERE id_venda = OLD.id_venda;
    END IF;
END$$

-- TRIGGER: recalcula o total quando um item e excluido.
CREATE TRIGGER trg_item_venda_total_delete
AFTER DELETE ON item_venda
FOR EACH ROW
BEGIN
    UPDATE venda
       SET valor_total = (
         SELECT COALESCE(SUM(subtotal), 0)
         FROM item_venda
         WHERE id_venda = OLD.id_venda
       )
     WHERE id_venda = OLD.id_venda;
END$$

-- TRIGGERS: recalculam o total do pedido ao inserir/alterar/excluir itens.
CREATE TRIGGER trg_item_pedido_total_insert
AFTER INSERT ON item_pedido
FOR EACH ROW
BEGIN
    UPDATE pedido
       SET valor_total = (
         SELECT COALESCE(SUM(subtotal), 0)
         FROM item_pedido
         WHERE id_pedido = NEW.id_pedido
       )
     WHERE id_pedido = NEW.id_pedido;
END$$

CREATE TRIGGER trg_item_pedido_total_update
AFTER UPDATE ON item_pedido
FOR EACH ROW
BEGIN
    UPDATE pedido
       SET valor_total = (
         SELECT COALESCE(SUM(subtotal), 0)
         FROM item_pedido
         WHERE id_pedido = NEW.id_pedido
       )
     WHERE id_pedido = NEW.id_pedido;

    IF OLD.id_pedido <> NEW.id_pedido THEN
        UPDATE pedido
           SET valor_total = (
             SELECT COALESCE(SUM(subtotal), 0)
             FROM item_pedido
             WHERE id_pedido = OLD.id_pedido
           )
         WHERE id_pedido = OLD.id_pedido;
    END IF;
END$$

CREATE TRIGGER trg_item_pedido_total_delete
AFTER DELETE ON item_pedido
FOR EACH ROW
BEGIN
    UPDATE pedido
       SET valor_total = (
         SELECT COALESCE(SUM(subtotal), 0)
         FROM item_pedido
         WHERE id_pedido = OLD.id_pedido
       )
     WHERE id_pedido = OLD.id_pedido;
END$$
DELIMITER ;

-- VIEWS: consultas prontas para uso no sistema.
CREATE VIEW vw_estoque_baixo AS
SELECT p.id_produto, p.nome, p.categoria, p.tamanho, p.cor,
       e.quantidade_atual, e.estoque_minimo
FROM produto p
JOIN estoque e ON e.id_produto = p.id_produto
WHERE e.quantidade_atual <= e.estoque_minimo
  AND p.ativo = TRUE;

CREATE VIEW vw_historico_vendas AS
SELECT v.id_venda, v.data_venda, v.status,
       c.nome AS cliente,
       u.nome AS usuario_responsavel,
       v.valor_total
FROM venda v
LEFT JOIN cliente c ON c.id_cliente = v.id_cliente
JOIN usuario u ON u.id_usuario = v.id_usuario;

CREATE VIEW vw_historico_pedidos AS
SELECT p.id_pedido, p.data_pedido, p.status, p.valor_total,
       c.nome AS cliente
FROM pedido p
LEFT JOIN cliente c ON c.id_cliente = p.id_cliente;

CREATE VIEW vw_total_vendas_por_mes AS
SELECT DATE_FORMAT(data_venda, '%Y-%m') AS mes,
       COUNT(*) AS quantidade_vendas,
       SUM(valor_total) AS faturamento
FROM venda
WHERE status IN ('Confirmada', 'Concluida')
GROUP BY DATE_FORMAT(data_venda, '%Y-%m');

-- ============================================================
-- DADOS DE EXEMPLO (ficticios)
-- ============================================================
INSERT INTO usuario (nome, email, senha_hash, perfil) VALUES
('Administrador Coruja', 'admin@corujasurf.example', 'SUBSTITUIR_POR_HASH_SEGURO', 'Proprietario'),
('Funcionario Exemplo', 'funcionario@corujasurf.example', 'SUBSTITUIR_POR_HASH_SEGURO', 'Funcionario');

INSERT INTO cliente (nome, telefone, email, endereco) VALUES
('Ana Souza', '(11) 90000-0001', 'ana@example.com', 'Sao Paulo - SP'),
('Bruno Lima', '(11) 90000-0002', 'bruno@example.com', 'Guarulhos - SP'),
('Carla Mendes', '(11) 90000-0003', 'carla@example.com', 'Osasco - SP');

-- O trigger cria automaticamente o estoque inicial com quantidade zero.
INSERT INTO produto (nome, descricao, categoria, tamanho, cor, preco) VALUES
('Camiseta Coruja Logo', 'Camiseta estampada da marca', 'Camiseta', 'M', 'Preta', 79.90),
('Camiseta Surf', 'Camiseta casual', 'Camiseta', 'G', 'Branca', 89.90),
('Moletom Coruja', 'Moletom com capuz', 'Moletom', 'G', 'Cinza', 159.90),
('Bermuda Surf', 'Bermuda casual', 'Bermuda', 'M', 'Azul', 119.90);

UPDATE estoque SET quantidade_atual = 20, estoque_minimo = 5 WHERE id_produto = 1;
UPDATE estoque SET quantidade_atual = 15, estoque_minimo = 5 WHERE id_produto = 2;
UPDATE estoque SET quantidade_atual = 4, estoque_minimo = 5 WHERE id_produto = 3;
UPDATE estoque SET quantidade_atual = 12, estoque_minimo = 3 WHERE id_produto = 4;

INSERT INTO venda (id_cliente, id_usuario, status) VALUES
(1, 1, 'Confirmada'),
(2, 2, 'Pendente');

INSERT INTO item_venda (id_venda, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 2, 79.90),
(1, 4, 1, 119.90),
(2, 2, 1, 89.90);

INSERT INTO pedido (id_cliente, status, observacao) VALUES
(3, 'Pagamento pendente', 'Pedido de exemplo feito online');

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1, 2, 2, 89.90),
(1, 3, 1, 159.90);

INSERT INTO pagamento
(id_venda, valor, forma_pagamento, parcelas, status, data_pagamento)
VALUES (1, 279.70, 'Pix', 1, 'Aprovado', CURRENT_TIMESTAMP);

INSERT INTO pagamento
(id_pedido, valor, forma_pagamento, parcelas, status)
VALUES (1, 339.70, 'Cartao de credito', 2, 'Pendente');

INSERT INTO notificacao (id_usuario, tipo, mensagem) VALUES
(1, 'Estoque baixo', 'O produto Moletom Coruja esta com estoque baixo.'),
(2, 'Novo pedido', 'Existe um novo pedido online para conferir.');

-- ============================================================
-- CONSULTAS DE DEMONSTRACAO
-- Execute separadamente depois da criacao:
-- ============================================================

-- 1. Listar produtos ativos e estoque disponivel:
SELECT p.nome, p.categoria, p.tamanho, p.cor, p.preco, e.quantidade_atual
FROM produto p 
JOIN estoque e ON e.id_produto = p.id_produto
WHERE p.ativo = TRUE 
ORDER BY p.nome;

-- 2. Ver produtos que precisam de reposicao:
-- SELECT * FROM vw_estoque_baixo;

-- 3. Consultar historico de vendas:
-- SELECT * FROM vw_historico_vendas ORDER BY data_venda DESC;

-- 4. Consultar itens de uma venda:
-- SELECT iv.id_venda, p.nome, iv.quantidade, iv.preco_unitario, iv.subtotal
-- FROM item_venda iv JOIN produto p ON p.id_produto = iv.id_produto
-- WHERE iv.id_venda = 1;

-- 5. Consultar pedidos e seus itens:
-- SELECT pe.id_pedido, pe.status, pe.valor_total, pr.nome,
--        ip.quantidade, ip.subtotal
-- FROM pedido pe
-- JOIN item_pedido ip ON ip.id_pedido = pe.id_pedido
-- JOIN produto pr ON pr.id_produto = ip.id_produto
-- ORDER BY pe.id_pedido;

-- 6. Faturamento por mes (vendas confirmadas/concluidas):
-- SELECT * FROM vw_total_vendas_por_mes ORDER BY mes;

-- 7. Pagamentos pendentes:
-- SELECT id_pagamento, id_venda, id_pedido, valor, forma_pagamento
-- FROM pagamento WHERE status = 'Pendente';

-- 8. Notificacoes ainda nao lidas:
-- SELECT * FROM notificacao WHERE lida = FALSE ORDER BY data_envio DESC;

-- Observacao importante:
-- Este script cria a estrutura e dados de demonstracao. O controle de estoque
-- esta disponivel na tabela estoque, mas a baixa automatica de estoque ao
-- concluir vendas/pedidos deve ser feita pela camada da aplicacao ou por uma
-- procedure transacional antes de usar em operacao real.
