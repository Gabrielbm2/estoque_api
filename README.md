# 📦 Estoque - API Ruby on Rails

Aplicação web com autenticação de usuários via JWT, cadastro de produtos associados ao usuário, integração com Amazon S3 para upload de imagens, documentação via Swagger e testes automatizados com RSpec.

---

## 🚀 Funcionalidades

- Cadastro e login de usuários (Devise + JWT)
- CRUD de produtos vinculados ao usuário autenticado
- Upload de imagens dos produtos com Amazon S3
- Testes automatizados com RSpec
- Documentação da API com Swagger (rswag)

---

## 🛠️ Tecnologias

- **Ruby on Rails** 7.x  
- **PostgreSQL**  
- **Devise + JWT** – Autenticação  
- **Active Storage** + **Amazon S3** – Upload de arquivos  
- **Rswag** – Documentação Swagger  
- **RSpec** – Testes  
- **FactoryBot** e **Faker** – Fixtures para testes  

---

## ⚙️ Instalação

```bash
# Clone o projeto
git clone git@github.com:Gabrielbm2/estoque_api.git
cd estoque_api

# Instale as dependências
bundle install
yarn install

# Configure o banco de dados
rails db:create db:migrate

# Inicie o servidor
rails s
