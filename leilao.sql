create database leilao

use leilao

create table usuarios (
	codigo int identity(1,1) primary key,
	nome varchar (50),
	qtLances int
);

create table ofertas (
	codigo int identity(1,1) primary key,
	descricao varchar (50),
	data datetime,
	valor float
);

create table lances (
	usuario int,
	oferta int,
	valorLance float,
	data datetime,
	primary key (usuario, oferta),
	foreign key (usuario) references usuarios (codigo),
	foreign key (oferta) references ofertas (codigo)
);
select * from lances

--procedimento para inserir usuarios------------
create procedure inserirUsuario (@nome varchar(50), @qt int)
as
	insert into usuarios (nome, qtLances) values (@nome, @qt)

inserirUsuario 'joana', 5
inserirUsuario 'Maria', 3
select * from usuarios

--procedimento par inserir ofertas no leilão---------
create procedure inserirOferta (@descricao varchar(50), @data datetime, @valor float)
as
	insert into ofertas (descricao, data, valor) values (@descricao, @data, @valor)

inserirOferta 'comutador', '10/05/2012 13:00:00', 50
select * from ofertas

-----procedimento para efetuar lances ------------

create procedure efetuarLances (@usuario int, @oferta int, @valor float)
as	
	if ((select qtLances from usuarios where codigo = @usuario) > 0)
		begin
			begin tran
			if ((select data from ofertas where codigo = @oferta) < GETDATE())
			begin
				
					declare @temp float
					set @temp = (select valorLance 
								 from lances with (holdlock) 
								 where oferta = @oferta 
								 group by valorLance 
								 having MAX(valorLance) > 0)
					insert into lances (usuario, oferta, valorLance, data) values (@usuario, @oferta, @temp+@valor, GETDATE())
					if (@@ERROR = 0)
						begin
							update usuarios with (rowlock) set qtLances = qtLances - 1 where codigo = @usuario
							if (@@ERROR = 0)
								begin
									commit
									select 'sucesso na operação'
								end
							else
								begin
									rollback
									select 'ERRO no update'
								end
						end
					else
						begin
							rollback
							select 'ERRO na inserção'
						end
				end
			else
				begin
					rollback
					select 'não há mais tempo para novos lances'
				end
		end
	else
		begin
			select 'você não tem saldo para novos lances'
		end
		
efetuarLances 1, 1, 0.01
select * from lances