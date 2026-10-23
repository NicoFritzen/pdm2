require('dotenv').config();

const cors = require('cors');
const express = require('express');
const { MongoClient, ObjectId } = require('mongodb');

const app = express();
const port = Number(process.env.PORT || 3000);
const mongoUri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017';
const databaseName = process.env.MONGODB_DATABASE || 'catalogo_livros';
const client = new MongoClient(mongoUri);

app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json({ limit: '32kb' }));

let books;

function serializeBook(book) {
  return {
    id: book._id.toString(),
    title: book.title,
    price: book.price,
    author: book.author,
    createdAt: book.createdAt,
    updatedAt: book.updatedAt,
  };
}

function parseBook(body) {
  const title = typeof body.title === 'string' ? body.title.trim() : '';
  const authorName = typeof body.author?.name === 'string'
    ? body.author.name.trim()
    : '';
  const price = Number(body.price);
  const age = Number(body.author?.age);

  if (!title || !authorName || !Number.isFinite(price) || price < 0 ||
      !Number.isInteger(age) || age < 0 || age > 150) {
    return null;
  }

  return { title, price, author: { name: authorName, age } };
}

function objectId(id) {
  return ObjectId.isValid(id) ? new ObjectId(id) : null;
}

app.get('/health', (_req, res) => res.json({ status: 'ok' }));

app.get('/books', async (req, res, next) => {
  try {
    const filter = {};
    const author = typeof req.query.author === 'string' ? req.query.author.trim() : '';
    if (author) filter['author.name'] = { $regex: author, $options: 'i' };

    const result = await books.find(filter).sort({ title: 1 }).toArray();
    res.json(result.map(serializeBook));
  } catch (error) {
    next(error);
  }
});

app.get('/books/cheapest', async (_req, res, next) => {
  try {
    const book = await books.find({}).sort({ price: 1, _id: 1 }).limit(1).next();
    res.json(book ? serializeBook(book) : null);
  } catch (error) {
    next(error);
  }
});

app.get('/books/:id', async (req, res, next) => {
  try {
    const id = objectId(req.params.id);
    if (!id) return res.status(400).json({ error: 'ID inválido.' });
    const book = await books.findOne({ _id: id });
    if (!book) return res.status(404).json({ error: 'Livro não encontrado.' });
    res.json(serializeBook(book));
  } catch (error) {
    next(error);
  }
});

app.post('/books', async (req, res, next) => {
  try {
    const input = parseBook(req.body);
    if (!input) return res.status(400).json({ error: 'Informe título, preço válido, nome e idade do autor.' });
    const now = new Date();
    const document = { ...input, createdAt: now, updatedAt: now };
    const result = await books.insertOne(document);
    const saved = await books.findOne({ _id: result.insertedId });
    res.status(201).json(serializeBook(saved));
  } catch (error) {
    next(error);
  }
});

app.put('/books/:id', async (req, res, next) => {
  try {
    const id = objectId(req.params.id);
    if (!id) return res.status(400).json({ error: 'ID inválido.' });
    const input = parseBook(req.body);
    if (!input) return res.status(400).json({ error: 'Informe título, preço válido, nome e idade do autor.' });
    const result = await books.updateOne(
      { _id: id },
      { $set: { ...input, updatedAt: new Date() } },
    );
    if (!result.matchedCount) return res.status(404).json({ error: 'Livro não encontrado.' });
    res.json(serializeBook(await books.findOne({ _id: id })));
  } catch (error) {
    next(error);
  }
});

app.delete('/books/:id', async (req, res, next) => {
  try {
    const id = objectId(req.params.id);
    if (!id) return res.status(400).json({ error: 'ID inválido.' });
    const result = await books.deleteOne({ _id: id });
    if (!result.deletedCount) return res.status(404).json({ error: 'Livro não encontrado.' });
    res.status(204).end();
  } catch (error) {
    next(error);
  }
});

app.use((error, _req, res, _next) => {
  console.error(error);
  res.status(500).json({ error: 'Erro interno ao acessar o catálogo.' });
});

async function start() {
  await client.connect();
  const database = client.db(databaseName);
  books = database.collection('books');
  await books.createIndex({ price: 1 });
  await books.createIndex({ 'author.name': 1 });
  app.listen(port, '0.0.0.0', () => {
    console.log(`API disponível na porta ${port}; banco ${databaseName}.`);
  });
}

start().catch((error) => {
  console.error('Não foi possível conectar ao MongoDB:', error.message);
  process.exit(1);
});
