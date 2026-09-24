# Dicionário de Dados — Coruja Surf

## 1. Identificação do projeto

| Informação | Dados |
|---|---|
| Empresa | Coruja Surf |
| Entrevistado | Antônio Gracia Ferreira Júnior |
| CNPJ | Não informado |
| Ramo | Comércio de roupas / vendas online |
| Principal meio de utilização | Celular |
| Usuários previstos | Proprietário e aproximadamente 4 pessoas da empresa |

---

## 2. Objetivo

Este dicionário de dados foi elaborado a partir da entrevista de levantamento de requisitos realizada com a empresa **Coruja Surf**.

A empresa atualmente realiza parte de seus controles manualmente, principalmente em papel, e não possui um sistema específico para gerenciamento de vendas, pedidos e estoque.

O dicionário apresenta os principais dados que **poderão ser armazenados pelo sistema proposto**, considerando as necessidades identificadas durante a entrevista.

> **Observação:** alguns dados e entidades abaixo são propostas derivadas dos requisitos levantados. Isso não significa que já existam ou sejam atualmente cadastrados pela empresa.

---

## 3. Convenções utilizadas

| Termo | Significado |
|---|---|
| PK | Chave primária, identificador único do registro |
| FK | Chave estrangeira, utilizada para relacionar registros |
| INT | Número inteiro |
| DECIMAL | Número decimal, utilizado principalmente para valores monetários |
| VARCHAR | Texto de tamanho variável |
| TEXT | Texto livre |
| DATE | Data |
| DATETIME | Data e hora |
| BOOLEAN | Valor lógico: verdadeiro ou falso |

---

# 4. Entidades e dados

## 4.1 Cliente

Representa a pessoa que realiza uma compra na Coruja Surf.

| Campo | Tipo | Chave | Obrigatório | Descrição |
|---|---|---|---|---|
| id_cliente | INT | PK | Sim | Identificador único do cliente |
| nome | VARCHAR(150) | — | Sim | Nome completo do cliente |
| telefone | VARCHAR(20) | — | Não | Telefone ou celular do cliente |
| email | VARCHAR(150) | — | Não | E-mail do cliente |
| endereco | VARCHAR(255) | — | Não | Endereço do cliente |
| data_cadastro | DATETIME | — | Sim | Data e hora do cadastro |

**Origem no levantamento:** atualmente a empresa não realiza cadastro de clientes, mas o histórico de clientes foi considerado importante pelo entrevistado.

---

## 4.2 Produto

Representa uma roupa fabricada e comercializada pela empresa.

| Campo | Tipo | Chave | Obrigatório | Descrição |
|---|---|---|---|---|
| id_produto | INT | PK | Sim | Identificador único do produto |
| nome | VARCHAR(150) | — | Sim | Nome do produto |
| descricao | TEXT | — | Não | Descrição e características do produto |
| categoria | VARCHAR(100) | — | Não | Categoria da roupa |
| tamanho | VARCHAR(20) | — | Não | Tamanho do produto |
| cor | VARCHAR(50) | — | Não | Cor do produto |
| preco | DECIMAL(10,2) | — | Sim | Preço de venda |
| quantidade_estoque | INT | — | Sim | Quantidade disponível em estoque |
| ativo | BOOLEAN | — | Sim | Indica se o produto está disponível para venda |

**Origem no levantamento:** a empresa comercializa roupas próprias e reconhece a necessidade de iniciar um controle adequado de estoque.

---

## 4.3 Estoque

Representa o controle das quantidades disponíveis dos produtos.

| Campo | Tipo | Chave | Obrigatório | Descrição |
|---|---|---|---|---|
| id_estoque | INT | PK | Sim | Identificador do registro de estoque |
| id_produto | INT | FK | Sim | Produto relacionado ao estoque |
| quantidade_atual | INT | — | Sim | Quantidade atualmente disponível |
| estoque_minimo | INT | — | Não | Quantidade mínima para gerar alerta |
| data_atualizacao | DATETIME | — | Sim | Data e hora da última atualização |

**Observação:** o controle de estoque não existe atualmente de forma adequada, mas foi identificado como uma necessidade de melhoria.

---

## 4.4 Venda

Representa uma venda realizada pela empresa.

| Campo | Tipo | Chave | Obrigatório | Descrição |
|---|---|---|---|---|
| id_venda | INT | PK | Sim | Identificador único da venda |
| id_cliente | INT | FK | Não | Cliente relacionado à venda |
| id_usuario | INT | FK | Sim | Usuário responsável pelo registro |
| data_venda | DATETIME | — | Sim | Data e hora da venda |
| valor_total | DECIMAL(10,2) | — | Sim | Valor total da venda |
| status | VARCHAR(30) | — | Sim | Situação da venda |

**Exemplos de status:** Pendente, Confirmada, Cancelada ou Concluída.

**Origem no levantamento:** as vendas são uma das principais informações que precisam ser registradas e atualmente não existe um registro organizado.

---

## 4.5 Item_Venda

Representa cada produto incluído em uma venda.

| Campo | Tipo | Chave | Obrigatório | Descrição |
|---|---|---|---|---|
| id_item_venda | INT | PK | Sim | Identificador do item |
| id_venda | INT | FK | Sim | Venda à qual o item pertence |
| id_produto | INT | FK | Sim | Produto vendido |
| quantidade | INT | — | Sim | Quantidade do produto vendido |
| preco_unitario | DECIMAL(10,2) | — | Sim | Preço do produto no momento da venda |
| subtotal | DECIMAL(10,2) | — | Sim | Resultado da quantidade multiplicada pelo preço unitário |

**Observação:** esta entidade permite que uma venda contenha vários produtos.

---

## 4.6 Pedido

Representa o pedido realizado pelo cliente, especialmente no processo de vendas online.

| Campo | Tipo | Chave | Obrigatório | Descrição |
|---|---|---|---|---|
| id_pedido | INT | PK | Sim | Identificador único do pedido |
| id_cliente | INT | FK | Não | Cliente que realizou o pedido |
| data_pedido | DATETIME | — | Sim | Data e hora da realização do pedido |
| valor_total | DECIMAL(10,2) | — | Sim | Valor total do pedido |
| status | VARCHAR(30) | — | Sim | Situação atual do pedido |
| observacao | TEXT | — | Não | Informações adicionais sobre o pedido |

**Exemplos de status:** Recebido, Pagamento pendente, Pago, Em preparação, Enviado e Concluído.

**Origem no levantamento:** atualmente o cliente realiza o pedido e envia o comprovante de pagamento para a empresa.

---

## 4.7 Pagamento

Representa o pagamento relacionado a uma venda ou pedido.

| Campo | Tipo | Chave | Obrigatório | Descrição |
|---|---|---|---|---|
| id_pagamento | INT | PK | Sim | Identificador único do pagamento |
| id_venda | INT | FK | Não | Venda relacionada ao pagamento |
| id_pedido | INT | FK | Não | Pedido relacionado ao pagamento |
| valor | DECIMAL(10,2) | — | Sim | Valor pago |
| forma_pagamento | VARCHAR(50) | — | Sim | Forma utilizada para o pagamento |
| parcelas | INT | — | Sim | Quantidade de parcelas |
| status | VARCHAR(30) | — | Sim | Situação do pagamento |
| comprovante | VARCHAR(255) | — | Não | Referência ao comprovante enviado |
| data_pagamento | DATETIME | — | Não | Data e hora do pagamento |

**Origem no levantamento:** a empresa recebe comprovantes de pagamento dos pedidos. A empresa também permite parcelamento, sendo que as taxas do parcelamento ficam por conta do cliente devido à margem de lucro reduzida.

---

## 4.8 Usuário

Representa uma pessoa autorizada a utilizar o sistema.

| Campo | Tipo | Chave | Obrigatório | Descrição |
|---|---|---|---|---|
| id_usuario | INT | PK | Sim | Identificador único do usuário |
| nome | VARCHAR(150) | — | Sim | Nome do usuário |
| email | VARCHAR(150) | — | Sim | E-mail utilizado para acesso |
| senha | VARCHAR(255) | — | Sim | Senha armazenada de forma segura |
| perfil | VARCHAR(30) | — | Sim | Perfil de acesso do usuário |
| ativo | BOOLEAN | — | Sim | Indica se o usuário está autorizado a acessar o sistema |

**Perfis possíveis:** Proprietário e Funcionário.

**Origem no levantamento:** aproximadamente cinco pessoas poderão utilizar o sistema, incluindo o proprietário. Atualmente não existem níveis de acesso definidos, mas determinadas informações poderão ser restritas ao proprietário.

---

## 4.9 Notificação

Representa avisos que podem ser apresentados aos usuários do sistema.

| Campo | Tipo | Chave | Obrigatório | Descrição |
|---|---|---|---|---|
| id_notificacao | INT | PK | Sim | Identificador da notificação |
| id_usuario | INT | FK | Sim | Usuário que receberá a notificação |
| tipo | VARCHAR(50) | — | Sim | Tipo do aviso |
| mensagem | TEXT | — | Sim | Conteúdo da notificação |
| data_envio | DATETIME | — | Sim | Data e hora da notificação |
| lida | BOOLEAN | — | Sim | Indica se a notificação foi visualizada |

**Exemplos de tipos:** Estoque baixo, Pagamento recebido e Novo pedido.

**Origem no levantamento:** o entrevistado considerou útil o envio de avisos relacionados ao estoque, pagamentos e pedidos.

---

# 5. Relacionamentos principais

| Relacionamento | Descrição |
|---|---|
| Cliente → Pedido | Um cliente pode realizar vários pedidos |
| Cliente → Venda | Um cliente pode realizar várias vendas |
| Pedido → Pagamento | Um pedido pode possuir um ou mais registros de pagamento |
| Venda → Pagamento | Uma venda pode possuir um ou mais registros de pagamento |
| Venda → Item_Venda | Uma venda pode possuir vários itens |
| Produto → Item_Venda | Um produto pode aparecer em vários itens de venda |
| Produto → Estoque | Um produto possui seu controle de estoque |
| Usuário → Venda | Um usuário pode registrar várias vendas |
| Usuário → Notificação | Um usuário pode receber várias notificações |

---

# 6. Regras de negócio identificadas

1. A empresa comercializa roupas fabricadas por ela própria, não dependendo de fornecedor externo para os produtos.
2. As vendas online são uma atividade importante da empresa.
3. As vendas e saídas de produtos devem ser registradas.
4. O sistema deve permitir consulta ao histórico de vendas, clientes e pedidos.
5. O controle de estoque deve ser implementado, pois atualmente não existe um controle adequado.
6. O sistema poderá emitir avisos relacionados a estoque, pagamentos e pedidos.
7. A empresa permite parcelamento das compras.
8. As taxas referentes ao parcelamento ficam por conta do cliente.
9. O sistema será utilizado principalmente por celular.
10. O proprietário poderá possuir acesso a informações que não precisam estar disponíveis para todos os funcionários.
11. Aproximadamente quatro funcionários, além do proprietário, poderão utilizar o sistema.
12. Não foi identificada, neste momento, uma necessidade específica de emissão de relatórios.
13. Atualmente não existem níveis de acesso definidos, portanto os perfis apresentados neste documento são uma proposta derivada da necessidade de restringir determinadas informações ao proprietário.

---

# 7. Dados que não foram definidos na entrevista

Algumas informações necessárias para o desenvolvimento do sistema não foram especificadas durante a entrevista. Entre elas:

- CNPJ da empresa;
- Campos obrigatórios para o cadastro de clientes;
- Campos obrigatórios para o cadastro de funcionários;
- Formas de pagamento aceitas;
- Percentuais ou regras das taxas de parcelamento;
- Quantidade máxima de parcelas;
- Regras detalhadas para atualização do estoque;
- Critérios para geração de alertas de estoque;
- Ferramentas externas que deverão ser integradas ao sistema;
- As três funções consideradas essenciais pelo entrevistado;
- Indicadores utilizados para medir se o sistema melhorou o trabalho da empresa;
- Regras detalhadas de permissão para cada usuário.

Esses pontos deverão ser validados posteriormente com a empresa antes da implementação definitiva.

---

# 8. Resumo das oportunidades identificadas

A entrevista indica que as principais oportunidades de informatização estão relacionadas a:

- **Cadastro e organização de clientes;**
- **Cadastro e controle de produtos;**
- **Controle de estoque;**
- **Registro de vendas;**
- **Organização de pedidos online;**
- **Registro e acompanhamento de pagamentos;**
- **Consulta ao histórico de vendas e pedidos;**
- **Controle de acesso dos usuários;**
- **Notificações sobre estoque, pagamentos e pedidos.**

O sistema proposto deve considerar principalmente o uso por celular e a necessidade de substituir controles manuais por informações organizadas e facilmente consultáveis.
