⚠️⚠️ AINDA É UM WORK IN PROGRESS ⚠️⚠️

# Rinha de Backend (serramatutu)

Este repositório contém minha submissão para a [Rinha de Backend (2024q1)](https://github.com/zanfranceschi/rinha-de-backend-2024-q1).




## Objetivos

Minha submissão para a Rinha de Backend tem alguns objetivos, todos centrados no pilar de APRENDIZADO:
- **Documentar o máximo possível** para aprendizado próprio e alheio. Adicionar contexto, motivação e link para documentação quando usar features obscuras ou não triviais de alguma das tecnologias.
- Apesar de achar divertido e interessantíssimo o que alguns estão fazendo para conseguir performance ou apenas se divertir ([submissões em Bash](https://github.com/zanfranceschi/rinha-de-backend-2024-q1/tree/main/participantes/canabrava), [application sharding com um SQLite por usuário](https://github.com/zanfranceschi/rinha-de-backend-2024-q1/tree/main/participantes/avalonbits), implementar um banco especializado direto em arquivos binários), pretendo **desenvolver um backend real**, que poderia ser utilizado em contexto profissional de acordo com padrões de mercado, sem invenções malucas ou decisões que comprometeriam desenvolvimento futuro (como assumir que nunca teremos mais usuários). 
- Aprender um pouco de [Zig](https://ziglang.org/).
- Aprender sobre **otimização de queries e schema no Postgres**, preferencialmente sem sacrificar consistência ou observabilidade.



## Tecnologias

[<img src="https://cdn.haproxy.com/wp-content/uploads/2015/10/HAProxy_Logo-2-1.png" alt="HAProxy Logo" height="100"/>](https://haproxy.com/)
[<img src="https://ziglang.org/zig-logo-light.svg" alt="Zig Logo" height="100"/>](https://ziglang.org/)
[<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Postgresql_elephant.svg/1985px-Postgresql_elephant.svg.png" alt="Postgres SQL Logo" height="100"/>](https://www.postgresql.org/)

Abaixo está uma breve lista de motivos para os quais escolhi as tecnologias usadas.

### HAProxy

O [HAProxy](https://www.haproxy.com/) é um reverse proxy como qualquer outro, e é propositalmente bem simples de usar sem muitas features além do esperado para um reverse proxy. Em vários benchmarks que vi [[1](https://github.com/NickMRamirez/Proxy-Benchmarks), [2](https://www.loggly.com/blog/benchmarking-5-popular-load-balancers-nginx-haproxy-envoy-traefik-and-alb/), [3](https://github.com/scalereal/loadbalancer-benchmark)], ele é o que melhor performa em termos de simples número de requisições por segundo.

Essa escolha foi feita puramente por que estamos tentando otimizar essa métrica para um sistema relativamente simples. No mundo real, essa escolha poderia ser diferente, e também tem seus tradeoffs (como tudo na vida!). Algumas diferenças do HAProxy em relação a outras tecnologias:
- [nginx](https://nginx.org/en/): O nginx não é apenas um reverse proxy, ele suporta algumas features a mais como ser um servidor de arquivos estáticos. Se você precisar fazer isso, talvez o nginx seja mais conveniente.
- [traefik](https://doc.traefik.io/traefik/): O traefik é um load balancer que surgiu no contexto de arquiteturas de microsserviços e cloud-native. Ele tem funcionalidades que permitem fazer service discovery e mudanças de topologia de forma mais dinâmica e fácil que os outros.
- [ALB](https://aws.amazon.com/elasticloadbalancing/application-load-balancer/): O ALB é o load balancer nativo da AWS. É muito bem integrado e fácil de usar com outras features da plataforma como EC2 e Fargate, além de ser configurável via CloudFormation. Se sua stack toda vive na AWS, é uma opção auto-gerenciada bem simples e conveniente.

Nenhuma das opções acima é de forma alguma uma escolha ruim. Tudo depende dos seus objetivos :)



### Zig

O [Zig](https://ziglang.org/) é uma linguagem de baixo nível relativamente recente e que está ganhando tração. Sendo muito honesto, escolhi o Zig só porque queria aprender mais sobre ele. Eu não usaria o Zig em nenhum projeto profissional ainda, visto que é uma linguagem nova, relativamente instável (não está nem na v1 ainda!) e que ainda não tem um ecossistema tão robusto. Caso queira uma linguagem mais baixo nível, escolha algo como Rust ou C++. Ainda assim, acho que em poucos anos o Zig vai amadurecer muito.


O microframework para a API HTTP que utilizei é o [Zap](https://github.com/zigzap/zap/), cuja performance é de impressionar (o negócio voa!). Como eu venho de uma linguagem mais alto nível (Python com Sanic ou FastAPI), senti falta algumas features de mais alto nível e syntax sugar como extração automática de path parameters. Apesar disso, foi bem fácil implementar isso na mão.


Aqui vão algumas coisas que notei sobre o Zig:
- Estão surgindo alguns projetos maiores que utilizam Zig como linguagem, como o [Bun (runtime de Javascript)](https://bun.sh/) ou o [Tigerbeetle](https://tigerbeetle.com/). 
- A performance dele para tarefas CPU-intensive é comparável à do C ou Rust (e às vezes superior).
- Não achei nenhum benchmark convincente e robusto o suficiente sobre a performance de I/O dele, e me parece haver bastante espaço para melhoria. Encontrei alguns repositórios com implementações de event loop alternativa [[1](https://github.com/mitchellh/libxev), [2](https://github.com/saltzm/async_io_uring), [3](https://github.com/mitchellh/zig-libuv)] (nenhum deles com muitas stars ou muito ativo no GitHub) e uma [issue no GitHub](https://github.com/ziglang/zig/issues/8224) reclamando da performance do event loop nativo. Isso não me passa a mesma confiaça de um ecossistema maduro como [Tokio (Rust)](https://tokio.rs/) ou [libuv (C, usado no NodeJS e Deno)](https://github.com/libuv/libuv).
- É bem fácil de aprender! Definitivamente é uma curva de aprendizado menor que Rust ou C++ (pelo menos foi pra mim).
- Ele [não implementa propositalmente](https://github.com/ziglang/zig/issues/229) algumas features que permitiriam um estilo de programação mais funcional, a fim de evitar complicações que afetariam performance. É uma escolha de design da linguagem, e você tem que lidar com ela.
- Muitas das ideias deles são bastante inovadoras ([expressões `comptime`](https://kristoff.it/blog/what-is-zig-comptime/), [código bloqueante e não bloqueante compatíveis](https://www.reddit.com/r/rust/comments/lwsqcc/what_do_you_guys_think_about_zigs_approach_to/), sintaxe de erros como valor melhor que a do Go e Rust, na minha opinião).



### Postgres

O [Postgres](https://www.postgresql.org/) é um banco de dados relacional bastante popular. O escolhi por ser um banco de dados general-purpose padrão de mercado e com muitas oportunidades bem razoáveis para otimização. A grande verdade é que (em 99% dos casos) a solução escalável para se ganhar performance é otimizar tecnologias estabelecidas direito ao invés de usar algo que ninguém conhece ou implementar o seu próprio. Deixo aqui esse [artigo](https://www.uber.com/en-BR/blog/how-uber-serves-over-40-million-reads-per-second-using-an-integrated-cache/) da Uber sobre como eles respondem a 40 milhões de queries por segundo com uma solução baseada em MySQL.

Existem outras opções especializadas como o [Tigerbeetle](https://tigerbeetle.com/), que é otimizado justo para transações financeiras. Como nesse projeto eu já havia feito uma escolha "hipster" com o Zig, não quis ter mais dor de cabeça ainda escolhendo um banco que ninguém conhece.