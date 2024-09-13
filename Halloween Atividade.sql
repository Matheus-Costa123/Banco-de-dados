create schema halloween;
 
use halloween;
 
CREATE TABLE usuario (
nome VARCHAR(100),
email VARCHAR(100),
idade INT
);
 
DELIMITER $$
 
CREATE PROCEDURE insere_usuarios_aleatorios()
BEGIN
	DECLARE i INT DEFAULT 0;
    WHILE i < 10000 DO
		SET @nome := CONCAT('usuario',i);
		SET @email := CONCAT('usuario',i,'@exemplo.com');
		SET @idade := FLOOR(RAND()*80) + 19;
		INSERT INTO usuario (nome, email, idade) VALUES (@nome, @email, @idade);
        SET i = i +1;
	END WHILE;
END;$$
 
DELIMITER //
 
select count(*) from usuario;