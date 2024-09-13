create schema biblioteca;
 
use biblioteca;
 
create table autor (
    id integer primary key,
    nome varchar(50),
    sobrenome varchar(50)
);
 
create table livro (
    id integer primary key,
    titulo varchar(100),
    autor varchar(255),
    ano_publicacao integer,
    constraint id_autor foreign key (id) references autor(id)
);
 
create table usuario (
    id integer primary key,
    nome varchar(100),
    situacao boolean,
    dt_cod date
);
 
create table reserva (
    id integer primary key,
    constraint id_livro foreign key (id) references livro(id),
    constraint id_usuario foreign key (id) references usuario(id),
    dt_reserva date,
    dt_devolucao date,
    situacao varchar(50)
);
 
create table devolucoes (
    id int auto_increment primary key,
    id_livro int,
    id_usuario int,
    data_devolucao date,
    data_devolucao_esperada date,
    foreign key (id_livro) references livro(id),
    foreign key (id_usuario) references usuario(id)
);
 
create table multas (
    id int auto_increment primary key,
    id_usuario int,
    valor_multa decimal(10, 2),
    data_multa date,
    foreign key (id_usuario) references usuario(id)
);
 
delimiter $$
create trigger trigger_VerificarAtrasos
before insert on devolucoes
for each row 
begin
    declare atraso int;
    set atraso = datediff(new.data_devolucao_esperada, new.data_devolucao);
    if atraso > 0 then
        insert into mensagens (destinatario, assunto, corpo)
        values ('Bibliotecário', 'Alerta de Atraso', concat('O Livro com ID', new.id_livro, ' não foi devolvido na data de devolução esperada.'));
    end if;
end;$$
delimiter //
 
create table mensagens (
    id int auto_increment primary key,
    destinatario varchar(225) not null,
    assunto varchar(225) not null,
    corpo text,
    data_envio datetime default current_timestamp
);
 
delimiter $$
create trigger trigger_gerar_multa2
after insert on devolucoes
for each row
begin
    declare atraso int;
    declare valor_multa decimal(10, 2);
    set atraso = datediff(new.data_devolucao_esperada, new.data_devolucao);
    if atraso > 0 then
        set valor_multa = atraso * 2.00;
        insert into multas (id_usuario, valor_multa, data_multa)
        values (new.id_usuario, valor_multa, now());
    end if;
end;$$
delimiter //
 
create table emprestimo (
    id int auto_increment primary key,
    status_livro varchar(20),
    id_livro int,
    id_usuario int,
    foreign key (id_livro) references livro(id),
    foreign key (id_usuario) references usuario(id)
);
 
delimiter $$
create trigger trigger_atualizar_status_emprestado
after insert on emprestimo
for each row
begin
    update livro
    set status_livro = "Emprestado"
    where id = new.id_livro;
end;$$
delimiter //
 
delimiter $$
create trigger trigger_atualizar_total_exemplares
after insert on livro
for each row
begin
    update livro
    set total_exemplares = total_exemplares + 1
    where id = new.id;
end;$$
delimiter //
 
create table livros_atualizados (
    id int auto_increment primary key,
    id_livro int not null,
    titulo varchar(100) not null,
    autor varchar(100) not null,
    data_atualizacao datetime default current_timestamp,
    foreign key (id_livro) references livro(id)
);
 
create table autor_livro (
    id_livro int,
    id_autor int,
    foreign key (id_livro) references livro(id),
    foreign key (id_autor) references autor(id)
);
 
delimiter $$
create trigger trigger_registrar_atualizacao_livro
after update on livro
for each row
begin
    insert into livros_atualizados (id_livro, titulo, autor, data_atualizacao)
    values (old.id, old.titulo, old.autor, now());
end;$$
delimiter //
 
delimiter $$
create trigger trigger_registrar_exclusao_livro
after delete on livro
for each row
begin
    insert into livros_excluidos (id_livro, titulo, autor, data_exclusao)
    values (old.id, old.titulo, now());
end;$$
delimiter //
 
DELIMITER $$
 
CREATE FUNCTION contar_autores () RETURNS INT BEGIN DECLARE total INT;
 
SELECT
  COUNT(*) INTO total
FROM
  autor;
 
RETURN total;
 
END;$$
 
DELIMITER $$
 
CREATE FUNCTION contar_usuarios_ativos () RETURNS INT BEGIN DECLARE total INT;
 
SELECT
  COUNT(*) INTO total
FROM
  usuario
WHERE
  situacao = TRUE;
 
RETURN total;
 
END;$$
 
DELIMITER $$
 
CREATE FUNCTION obter_ultimo_emprestimo_usuario (id_usuario INT) RETURNS DATE BEGIN DECLARE ultima_data DATE;
 
SELECT
  MAX(dt_emprestimo) INTO ultima_data
FROM
  emprestimo
WHERE
  id_usuario = id_usuario;
 
RETURN ultima_data;
 
END;$$
 
DELIMITER $$
 
CREATE FUNCTION contar_livros_por_ano (ano INT) RETURNS INT BEGIN DECLARE total INT;
 
SELECT
  COUNT(*) INTO total
FROM
  livro
WHERE
  ano_publicacao = ano;
 
RETURN total;
 
END;$$
 
DELIMITER $$
 
CREATE FUNCTION obter_maior_multa_usuario (id_usuario INT) RETURNS DECIMAL(10, 2) BEGIN DECLARE maior_multa DECIMAL(10, 2);
 
SELECT
  MAX(valor_multa) INTO maior_multa
FROM
  multas
WHERE
  id_usuario = id_usuario;
 
RETURN maior_multa;
 
END;$$
 
DELIMITER $$
 
CREATE FUNCTION contar_reservas_periodo (data_inicio DATE, data_fim DATE) RETURNS INT BEGIN DECLARE total INT;
 
SELECT
  COUNT(*) INTO total
FROM
  reserva
WHERE
  dt_reserva BETWEEN data_inicio AND data_fim;
 
RETURN total;
 
END;$$
 
DELIMITER $$
 
CREATE FUNCTION obter_titulo_livro (id_livro INT) RETURNS VARCHAR(100) BEGIN DECLARE titulo VARCHAR(100);
 
SELECT
  titulo INTO titulo
FROM
  livro
WHERE
  id = id_livro;
 
RETURN titulo;
 
END;$$
 
DELIMITER $$
 
CREATE FUNCTION contar_livros_disponiveis () RETURNS INT BEGIN DECLARE total INT;
 
SELECT
  COUNT(*) INTO total
FROM
  livro
WHERE
  status_livro = 'Disponível';
 
RETURN total;
 
END;$$
 
DELIMITER $$
 
CREATE FUNCTION obter_autor_livro (id_livro INT) RETURNS VARCHAR(255) BEGIN DECLARE autor VARCHAR(255);
 
SELECT
  autor INTO autor
FROM
  livro
WHERE
  id = id_livro;
 
RETURN autor;
 
END;$$
 
DELIMITER $$
 
CREATE FUNCTION contar_livros_atualizados_periodo (data_inicio DATE, data_fim DATE) RETURNS INT BEGIN DECLARE total INT;
 
SELECT
  COUNT(*) INTO total
FROM
  livros_atualizados
WHERE
  data_atualizacao BETWEEN data_inicio AND data_fim;
 
RETURN total;
 
END;$$
 
DELIMITER //