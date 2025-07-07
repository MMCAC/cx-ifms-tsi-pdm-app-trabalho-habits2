const express = require('express'); // - Aqui você está **importando o módulo `express`**, que é um framework web para Node.js.
// - O `express` facilita a criação de servidores web e o gerenciamento de rotas, middlewares, etc.
const app = express(); // - Aqui você está **criando uma instância do aplicativo Express**.
const httpServer = require('http').createServer(app); // - Aqui você está **criando um servidor HTTP** usando a instância do aplicativo Express.
// - O `httpServer` será usado para escutar requisições HTTP e responder a elas.
const cors = require('cors'); // - Aqui você está **importando o módulo `cors`**, que é um middleware para habilitar o CORS (Cross-Origin Resource Sharing).
// - O CORS é uma política de segurança que permite ou restringe requisições de diferentes origens (domínios).
// - O `cors` é usado para permitir que o servidor aceite requisições de outros domínios, o que é útil em aplicações web onde o frontend e o backend podem estar hospedados em domínios diferentes.
// - O `cors` é frequentemente usado em APIs para permitir que clientes de diferentes origens acessem os recursos do servidor sem restrições de segurança que poderiam bloquear essas requisições.
const mongoose = require('mongoose'); // - Aqui você está **importando o módulo `mongoose`**, que é uma biblioteca para modelar objetos MongoDB e gerenciar conexões com o banco de dados.
// - O `mongoose` facilita a interação com o MongoDB, permitindo definir esquemas, modelos e realizar operações CRUD de forma mais intuitiva.
// - Ele também fornece funcionalidades como validação de dados, middlewares e hooks para manipulação de dados antes ou depois de operações específicas.
// - O `mongoose` é amplamente utilizado em aplicações Node.js que precisam interagir com bancos de dados MongoDB, oferecendo uma camada de abstração que simplifica o processo de desenvolvimento.
const { DateTime } = require("luxon"); // - Aqui você está **importando o módulo `luxon`**, que é uma biblioteca para manipulação de datas e horas.

const uri = "mongodb+srv://maiconcunha:12345@cluster0.tyygxox.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"; // - Aqui você está **definindo a URI de conexão com o MongoDB**.

app.use(cors()); // - Aqui você está **usando o middleware `cors`** para habilitar o CORS no seu aplicativo Express.
app.use(express.json({extended:false})); // - Aqui você está **configurando o Express para analisar requisições JSON**.
app.use(express.static('public',{})); // - Aqui você está **definindo o diretório `public` como estático**, permitindo que arquivos estáticos (como HTML, CSS, JS) sejam servidos diretamente pelo Express.

mongoose.connect(uri); // - Aqui você está **conectando ao MongoDB usando a URI definida anteriormente**.
mongoose.connection.on('error', function(e){
	console.log("Erro de conexão com o MongoDB: " + e);
}); // - Aqui você está **definindo um listener para erros de conexão com o MongoDB**.
mongoose.connection.on('connected', function(){
	console.log("Conectado ao MongoDB com sucesso!");
}); // - Aqui você está **definindo um listener para quando a conexão com o MongoDB for bem-sucedida**.

const Habito = mongoose.model('Habito', 
	{ 
		nome: {type: String, required: true},
		seg: {type: Boolean, required: true, default: false},
		ter: {type: Boolean, required: true, default: false},
		qua: {type: Boolean, required: true, default: false},
		qui: {type: Boolean, required: true, default: false},
		sex: {type: Boolean, required: true, default: false},
		sab: {type: Boolean, required: true, default: false},
		dom: {type: Boolean, required: true, default: false}			
	}
);

const HabitoConcluido = mongoose.model('HabitoConcluido', 
	{
		nome: {type: String},
		habitoId:{
			type: mongoose.Schema.Types.ObjectId,
			ref: 'Habito',
			required: true
		},
		dataConclusao: {type: Date, default: Date.now}
	}
);
// OK -> Consumido
app.get('/', function(req, res){
	return res.sendFile(__dirname+'/public/index.html');
});

// Ok -> Consumido
app.get('/habito', async function(req, res){
	try{
		const habitos = await Habito.find();
		return res.status(200).json(habitos);
	}catch(e){
		return res.status(500).json(e);
	}
});

// Ok - Verificar depois ###############
app.get('/habito/id/:id', async function(req, res){
	try{
		const id = req.params.id;
		const habito = await Habito.findOne({_id:id});
		return res.status(200).json(habito);
	}catch(e){
		return res.status(500).json(e);
	}
});

// Ok -> Consumido
app.get('/habito/hoje', async function(req, res){
	try{
		const diaSemana = DateTime.now().weekday - 1;
		console.log(diaSemana);
		
		switch (diaSemana){
			case 0: 
				habitos = await Habito.find({seg:true});
				break;
			case 1: 
				habitos = await Habito.find({ter:true});
				break;
			case 2: 
				habitos = await Habito.find({qua:true});
				break;
			case 3: 
				habitos = await Habito.find({qui:true});
				break;
			case 4: 
				habitos = await Habito.find({sex:true});
				break;
			case 5: 
				habitos = await Habito.find({sab:true});
				break;
			case 6: 
				habitos = await Habito.find({dom: true});
				break;			
		}
		return res.status(200).json(habitos);
	}catch(e){
		return res.status(500).json(e);
	}
});

// Ok -> Consumido
app.get('/habito/diaDaSemana/:diaSemana', async function(req, res){
	try{
		const diaSemana = Number(req.params.diaSemana);
		let habitos = [];
		
		switch (diaSemana){
			case 0: 
				habitos = await Habito.find({seg:true});
				break;
			case 1: 
				habitos = await Habito.find({ter:true});
				break;
			case 2: 
				habitos = await Habito.find({qua:true});
				break;
			case 3: 
				habitos = await Habito.find({qui:true});
				break;
			case 4: 
				habitos = await Habito.find({sex:true});
				break;
			case 5: 
				habitos = await Habito.find({sab:true});
				break;
			case 6: 
				habitos = await Habito.find({dom: true});
				break;			
		}
		return res.status(200).json(habitos);
	}catch(e){
		return res.status(500).json(e);
	}
});

//Ok -> Consumido
app.post('/habito', async function(req, res){
	try{
		const body = req.body;
		console.log(body);
		const habito = new Habito(body);
		await habito.save();
		return res.status(200).send();
	}catch(e){
		return res.status(500).json(e);
	}
});

//Ok -> Consumido
app.put('/habito', async function(req, res){
	try{
		const body = req.body;
		console.log(body);
		const habito = await Habito.findOne({_id: body.id});
		
		if(!habito){
			throw "Habito não encontrado";
		}
		
		habito.nome = body.nome;
		habito.seg = body.seg;
		habito.ter = body.ter;
		habito.qua = body.qua;
		habito.qui = body.qui;
		habito.sex = body.sex;
		habito.sab = body.sab;
		habito.dom = body.dom;
		
		await habito.save();
	
		return res.status(200).send();
	}catch(e){
		return res.status(500).json(e);
	}
});

//Ok -> Consumido
app.delete('/habito/id/:id', async function(req, res){
	try{
		const id = req.params.id;	
		
		console.log(id);
		await Habito.findOneAndDelete({_id:id});
		return res.status(200).send();
	}catch(e){
		return res.status(500).send(e);
	}
});

//Ok -> Consumido
app.get('/concluido', async function(req, res){
	try{
		const habitosConcluidos = await HabitoConcluido.find();
		return res.status(200).json(habitosConcluidos);
	}catch(e){
		return res.status(500).json(e);
	}
});

//Ok -> Consumido
app.get('/concluido/:ano/:mes', async function(req, res){
	try{
		const ano = req.params.ano;
		const mes = req.params.mes;
		
		console.log(ano);
		console.log(mes);

		const inicio = DateTime.fromObject({ year: ano, month: mes, day: 1 }).startOf("month").toJSDate();
		const fim = DateTime.fromObject({ year: ano, month: mes, day: 1 }).endOf("month").toJSDate();

		console.log(inicio);
		console.log(fim);

		const habitosConcluidos = await HabitoConcluido.find({
			dataConclusao: {
				$gte: inicio,
				$lt: fim,
			},
		});
		
		return res.status(200).json(habitosConcluidos);
	}catch(e){
		return res.status(500).json(e);
	}
});

//Ok -> Consumido
app.get('/concluido/:ano/:mes/:dia', async function(req, res){
	try{
		const ano = req.params.ano;
		const mes = Number(req.params.mes);
		const dia = req.params.dia;
		
		const inicio = DateTime.fromObject({ year: ano, month: mes, day: dia }).startOf("day").toJSDate();
		const fim = DateTime.fromObject({ year: ano, month: mes, day: dia }).endOf("day").toJSDate();
		
		const habitosConcluidos = await HabitoConcluido.find({
			dataConclusao: {
				$gte: inicio,
				$lt: fim,
			},
		});
		return res.status(200).json(habitosConcluidos);
	}catch(e){
		return res.status(500).json(e);
	}
});

//Ok -> Consumido
app.get('/concluido/hoje', async function(req, res){
	try{
		const inicio = DateTime.now().startOf("day").toJSDate(); 
		const fim = DateTime.now().endOf("day").toJSDate();

		const habitosConcluidos = await HabitoConcluido.find({
			dataConclusao: {
				$gte: inicio,
				$lt: fim,
			},
		});
		return res.status(200).json(habitosConcluidos);
	}catch(e){
		return res.status(500).json(e);
	}
});

//Ok -> COnsumido
app.get('/concluido/nestaSemana', async function(req, res){
	try{
		const inicioDaSemana = DateTime.now().startOf("week").toJSDate(); 
		const fimDaSemana = DateTime.now().endOf("week").toJSDate();

		const habitosConcluidos = await HabitoConcluido.find({
			dataConclusao: {
				$gte: inicioDaSemana,
				$lt: fimDaSemana,
			},
		});
		return res.status(200).json(habitosConcluidos);
	}catch(e){
		return res.status(500).json(e);
	}
});

//Ok -> Consumido
app.get('/concluido/nesteMes', async function(req, res){
	try{
		const inicioDoMes= DateTime.now().startOf("month").toJSDate();
		const fimDoMes = DateTime.now().endOf("month").toJSDate();

		const habitosConcluidos = await HabitoConcluido.find({
			dataConclusao: {
				$gte: inicioDoMes,
				$lt: fimDoMes,
			},
		});
		return res.status(200).json(habitosConcluidos);
	}catch(e){
		return res.status(500).json(e);
	}
});

//Ok -> Consumido
app.get('/concluido/nesteAno', async function(req, res){
	try{
		const inicioDoAno= DateTime.now().startOf("year").toJSDate();
		const fimDoAno = DateTime.now().endOf("year").toJSDate();

		const habitosConcluidos = await HabitoConcluido.find({
			dataConclusao: {
				$gte: inicioDoAno,
				$lt: fimDoAno,
			},
		});
		return res.status(200).json(habitosConcluidos);
	}catch(e){
		return res.status(500).json(e);
	}
}); 

//Ok -> Consumido
app.post('/concluido', async function(req, res){
	try{
		const body = req.body;
		const habitoConcluido = new HabitoConcluido(body);
		const habito = await Habito.findOne({_id: habitoConcluido.habitoId});
		habitoConcluido.dataConclusao = new Date();
		habitoConcluido.nome = habito.nome;
		await habitoConcluido.save();
		return res.status(200).send();
	}catch(e){
		return res.status(500).json(e);
	}
});

//Ok - Verificar depois  ###################
app.put('/concluido', async function(req, res){
	try{
		const body = req.body;
		const habitoConcluido = await HabitoConcluido.findOne({_id: body.id});
		
		if(!habitoConcluido){
			throw "Habito Concluído não encontrado"
		}
		
		habitoConcluido.dataConclusao = new Date(body.dataConclusao);
		console.log(habitoConcluido);
		await habitoConcluido.save();
	
		return res.status(200).send();
	}catch(e){
		return res.status(500).json(e);
	}
});

//Ok -> Consumido
app.delete('/concluido/:id', async function(req, res){
	try{
		const id = req.params.id;	
		await HabitoConcluido.findOneAndDelete({_id:id});
		return res.status(200).send();
	}catch(e){
		return res.status(404).send();
	}
});

httpServer.listen(8080, function(){
	console.log("Servidor HTTP no ar!");
});
