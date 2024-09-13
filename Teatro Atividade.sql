CREATE SCHEMA teatro;
 
USE teatro;
 
CREATE TABLE pecas_teatro (
  id_peca INT PRIMARY KEY AUTO_INCREMENT,
  nome_peca VARCHAR(255) NOT NULL,
  descricao TEXT,
  duracao INT,
  data_estreia DATE,
  diretor VARCHAR(255),
  elenco TEXT,
  genero VARCHAR(100),
  idioma VARCHAR(50)
);
 
INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_estreia, diretor, elenco, genero, idioma)
VALUES
('Romeu e Julieta', 'Tragédia romântica de William Shakespeare', 120, '2023-05-01', 'João Silva', 'Maria, Pedro, Ana', 'Tragédia', 'Português'),
('Hamlet', 'Tragédia de William Shakespeare', 150, '2023-06-15', 'Carlos Souza', 'José, Clara, Paulo', 'Tragédia', 'Português'),
('O Auto da Compadecida', 'Comédia de Ariano Suassuna', 110, '2023-07-20', 'Fernanda Lima', 'Rafael, Bianca, Lucas', 'Comédia', 'Português'),
'A Megera Domada', 'Comédia de William Shakespeare', 130, '2023-08-10', 'Ricardo Alves', 'Juliana, Marcos, Fernanda', 'Comédia', 'Português'),
'Macbeth', 'Tragédia de William Shakespeare', 140, '2023-09-05', 'Patrícia Gomes', 'Roberto, Carla, Bruno', 'Tragédia', 'Português');
 
DELIMITER $$
 
CREATE FUNCTION calcular_media_duracao (p_id_peca INT) RETURNS DECIMAL(10, 2) BEGIN DECLARE media_duracao DECIMAL(10, 2);
 
SELECT
  AVG(duracao) INTO media_duracao
FROM
  pecas_teatro
WHERE
  id_peca = p_id_peca;
 
RETURN media_duracao;
 
END;$$
DELIMITER //
 
DELIMITER $$
 
CREATE FUNCTION verificar_disponibilidade (p_data_hora DATETIME) RETURNS BOOLEAN
BEGIN
  DECLARE disponibilidade BOOLEAN;
 
  SELECT
    CASE
      WHEN COUNT(*) > 0 THEN FALSE
      ELSE TRUE
    END INTO disponibilidade
  FROM
    pecas_teatro
  WHERE
    data_estreia = p_data_hora;
 
  RETURN disponibilidade;
END;$$
 
DELIMITER //
 
DELIMITER $$
 
CREATE PROCEDURE agendar_peca (
    IN p_nome_peca VARCHAR(255),
    IN p_descricao TEXT,
    IN p_duracao INT,
    IN p_data_estreia DATE,
    IN p_diretor VARCHAR(255),
    IN p_elenco TEXT,
    IN p_genero VARCHAR(100),
    IN p_idioma VARCHAR(50)
)
BEGIN
    DECLARE v_id_peca INT;
    DECLARE v_media_duracao DECIMAL(10, 2);
 
    -- Inserir a nova peça de teatro na tabela pecas_teatro
    INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_estreia, diretor, elenco, genero, idioma)
    VALUES (p_nome_peca, p_descricao, p_duracao, p_data_estreia, p_diretor, p_elenco, p_genero, p_idioma);
 
    -- Obter o ID da peça recém-inserida
    SET v_id_peca = LAST_INSERT_ID();
 
    -- Calcular a média de duração usando a função calcular_media_duracao
    SET v_media_duracao = calcular_media_duracao(v_id_peca);
 
    -- Imprimir informações sobre a peça agendada, incluindo a média de duração
    SELECT 
        nome_peca AS Nome,
        descricao AS Descricao,
        duracao AS Duracao,
        data_estreia AS Data_Estreia,
        diretor AS Diretor,
        elenco AS Elenco,
        genero AS Genero,
        idioma AS Idioma,
        v_media_duracao AS Media_Duracao
    FROM 
        pecas_teatro
    WHERE 
        id_peca = v_id_peca;
END;$$
 
DELIMITER //
 
CALL agendar_peca (
'Romeu e Julieta', 'Tragédia romântica de William Shakespeare', 120, '2020-09-01', 'João Silva', 'Maria, Pedro, Ana', 'Tragédia', 'Português'
);