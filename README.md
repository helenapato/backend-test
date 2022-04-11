# ApiBlogs

## Instalação
Instruções para instalar e configurar o projeto em seu computador.
1. Seguir o [passo a passo](https://hexdocs.pm/phoenix/installation.html) de instalação do Phoenix e suas dependências
2. Clonar o repositório na pasta em que será criado o projeto

		git clone https://github.com/helenapato/backend-test.git
3. Caso necessário, no arquivo `config/dev.exs`, configurar a base de dados, mudando o nome de usuário e senha
4. Instalar as dependências

		mix deps.get
5. Criar a base de dados

		mix ecto.create 
6. Rodar as migrations

		mix ecto.migrate
## Testando
Para rodar os testes do user controller, use o comando abaixo

	mix test test\api_blogs_web\controllers\user_controller_test.exs

Para rodar os testes do post controller, use o comando abaixo

	mix test test\api_blogs_web\controllers\post_controller_test.exs
Para rodar todos os testes, use o comando abaixo

	mix test
Para testar manualmente, inicie o servidor com 

	mix phx.server
e use o Postman para enviar as requisições, lembrando que alguns endpoints precisam de um token JWT no header para serem aceitos. O token é gerado ao adicionar um usuário na base ou fazer login, e deve ser inserido no header manualmente como mostrado abaixo.

![Exemplo de inserção do token JWT no Postman](https://miro.medium.com/max/1400/1*iEe9LDRGZleHCcFZrKGrYg.png "Inserindo token JWT no header do Postman")

Exemplos de requisições podem ser conferidos no [readme](https://github.com/betrybe/backend-test/blob/master/README.md) do projeto original.
