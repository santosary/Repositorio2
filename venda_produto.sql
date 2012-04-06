create database venda_produto

use venda_produto

create table vendas (
	codigo int identity(1,1),
	data date
	primary key (codigo)
);
insert into vendas (data) values ('16/02/2012')
insert into vendas (data) values ('17/02/2012')
select * from vendas

create table produtos (
	codigo int identity(1,1),
	descricao varchar(60),
	valor decimal(6,2),
	peso float,
	estoque int
	primary key (codigo)
);
insert into produtos (descricao, valor, peso, estoque) values ('feijao', 10, 2, 10)
insert into produtos (descricao, valor, peso, estoque) values ('arroz', 10, 5, 15)
update produtos set estoque=10 where codigo=1
select * from produtos

create table itensVendas (
	codigo int identity(1,1),
	venda int,
	produto int,
	quantidade int,
	primary key (codigo),
	foreign key (venda) references vendas (codigo),
	foreign key (produto) references produtos (codigo)
);
select * from itensVendas


-----------------cria transação segura----------------------------------------------------

create procedure addItem2 (@venda int, @produto int, @qt int)
as
	if ((select estoque from produtos with (holdlock) where codigo = @produto) - @qt >= 0)
		begin transaction
			insert into itensVendas (venda, produto, quantidade) values (@venda, @produto, @qt)
			if (@@ERROR = 0)
				begin
					update produtos with (rowlock) set estoque = estoque - @qt where codigo = @produto
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
						select 'ERRO no insert into'
					end
		end
	else
		begin
			select 'estoque insuficiente'
		end
		
		
		Petrônio meu carissimo não estou conseguindo resolver este erro de sintaxe, dá uma força aí
		
		Mensagem
		Mensagem 156, Nível 15, Estado 1, Procedimento addItem2, Linha 26
        Sintaxe incorreta próxima à palavra-chave 'else'.
	
		COMO QUE EU FAÇO PARA LOCALIZAR OS CODIGOS POSTADOS POR V.EXCELÊNCIA