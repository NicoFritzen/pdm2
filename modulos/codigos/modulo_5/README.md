# Módulo 5 — Catálogo de livros com MongoDB

## Atividade: conexão e inclusão

1. **Onde o MongoDB será executado:** no MongoDB local instalado na máquina, ouvindo em `127.0.0.1:27017`. O banco usado pela API é `catalogo_livros`, com a coleção `books`.
2. **Caminho de comunicação:** Flutter → API REST Express/Node.js → MongoDB. O app não recebe nem armazena credenciais do banco. O backend lê `MONGODB_URI` e `MONGODB_DATABASE` de seu `.env`.
3. **Configuração necessária:** iniciar o serviço MongoDB local; copiar `backend/.env.example` para `backend/.env` e ajustar a URI apenas se a instalação usar outra porta; executar `npm install` e `npm start` dentro de `backend`. A API escuta na porta `3000`. No emulador Android, `10.0.2.2` aponta para o host; para navegador/Windows use `flutter run --dart-define=API_BASE_URL=http://localhost:3000`. Em aparelho físico, informe o IP da máquina na rede local e permita entrada TCP na porta 3000 no firewall. Para produção, use HTTPS e restrinja CORS/firewall. O Android já declara permissão INTERNET e permite HTTP para desenvolvimento local.
4. **Caminho completo da inclusão:** a pessoa toca em `+` no Flutter e preenche título, preço, nome e idade do autor. A validação local impede dados vazios ou inválidos. Ao salvar, Flutter serializa os campos como JSON e envia `POST /books` à API. O Express valida novamente os dados, acrescenta `createdAt` e `updatedAt`, e chama `insertOne` na coleção MongoDB. O MongoDB cria `_id` do tipo ObjectId. A API consulta o documento inserido e responde `201` em JSON com o campo `id` contendo a representação textual desse `_id`. O Flutter desserializa a resposta; ao atualizar a lista com `GET /books`, o registro persistido aparece. Na edição, o Flutter envia `PUT /books/:id`; a API converte o ID para ObjectId e atualiza o documento existente, preservando o mesmo ID.

### Documentos armazenados

```json
{
  "_id": "ObjectId gerado pelo MongoDB",
  "title": "Dear Mr. Henshaw",
  "price": 39.9,
  "author": { "name": "Beverly Cleary", "age": 84 },
  "createdAt": "data de criação",
  "updatedAt": "data da última alteração"
}
```

O backend também oferece `GET /books?author=...`, `GET /books/cheapest`, `GET /books/:id`, `PUT /books/:id` e `DELETE /books/:id`. O Flutter implementa listagem, filtro por autor, consulta do menor preço, inclusão, edição e exclusão.

## Subir o projeto

```powershell
# Terminal 1 — MongoDB deve estar iniciado no host
Set-Location modulos/codigos/modulo_5/backend
Copy-Item .env.example .env # somente na primeira execução
npm install
npm start

# Terminal 2 — emulador Android
Set-Location modulos/codigos/modulo_5/app_flutter
flutter pub get
flutter run
```

Não coloque credenciais reais em `.env.example` nem as envie ao Git; `.env` e `node_modules/` estão ignorados.
