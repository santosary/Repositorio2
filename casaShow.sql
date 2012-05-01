create database casaShow

use casaShow

create table clientes (
	codigo int identity(1,1),
	nome varchar(50)
	primary key (codigo)
);

create table comandas (
	codigo int identity(1,1),
	cliente int,
	capacidade int,
	data date,
	situacao int,
	primary key (codigo),
	foreign key (cliente) references clientes (codigo)
);

----------------listar a quantidade de pessoas na boate------------------------
create view ListaLotacao
as
	select COUNT(*) as lotacao from comandas with(holdlock) where situacao = 1
	
select * from ListaLotacao


-- --------procedure para emitir comandas-------------------------------------
create procedure emitirComanda (@cliente varchar(50))
as
	--verifica se o cliente já está cadastrado
	if ((select nome from clientes where nome = @cliente) = @cliente)
		begin
			select 'cliente já está cadastrado'
		end
	else
		--cadastra o cliente, caso não esteja cadastrado e retorna o codigo
		begin
			insert into clientes (nome) values (@cliente)
			declare @cod int
			set @cod = (select codigo from clientes where nome = @cliente)
			select @cod as codigoCliente
		end
		
	declare @Id int
	declare @capacidade int	
	set @Id = (select codigo from clientes where nome = @cliente)
	set @capacidade = (select capacidade from comandas where codigo = 1)
	
	--inicio da transação--------------------------------------------------------------------------	
	set transaction isolation level repeatable read
	begin transaction		
	if ((select COUNT(*) from comandas where situacao = 1) < @capacidade)
		begin
			insert into comandas with (holdlock)(cliente, capacidade, data, situacao) values (@Id, @capacidade, GETDATE(), 1)
			if (@@ERROR <> 0 )
				begin 
					rollback
					select 'comanda não foi emitida'
				end
			else
				begin 
					commit
					select 'comanda foi emitida com sucesso'
				end
		end
	else
		begin	
			select  'boate está na sua capacidade limite' as capacidade
			rollback		
			
		end
		
exec emitirComanda 'Janaina'
drop procedure emitirComanda
select * from comandas
select * from clientes

--procedure para fechar as comandas-----------------------------------------------------
create procedure fecharComanda (@comanda int)
as	
	begin tran 
	if ((select situacao from comandas where codigo = @comanda) = 1)
		begin
			update comandas set situacao = 0 where codigo = @comanda
			if (@@ERROR = 0)
				begin
					commit
					select 'sucesso ' as StatusDaOperacao
				end
			else
				begin		
					rollback	
					select 'erro ' as StatusDaOperacao
				end
		end
	else
		begin
			rollback
			select 'comanda não está em aberto' as ComandaAtual
		end
	
	declare @cliente int
	declare @aberto int
	set @cliente = (select cliente from comandas where codigo = @comanda)
	set @aberto = (select COUNT(*) as ComandasAbertas from comandas where cliente = @cliente and situacao = 1)
	
	if (@aberto > 0)
		begin
			select @aberto as comandasEmAberto
		end
	else
		begin
			select 'cliente volte sempre' as Saudaoes
		end


exec fecharComanda 21
