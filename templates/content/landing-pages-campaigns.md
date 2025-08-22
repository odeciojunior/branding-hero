# Template: Landing Pages for Campaigns

## Landing Page Framework Overview

### Core Principles for HERO Landing Pages
1. **Single focused objective** per page
2. **Specific value proposition** for target audience  
3. **Clear pain point connection** to solution
4. **Immediate credibility** with guarantees
5. **Minimal friction** to conversion
6. **Mobile-first** design approach

### Standard Landing Page Structure
1. **Hero Section** (Value prop + CTA)
2. **Problem Agitation** (Connect with pain)
3. **Solution Presentation** (How HERO solves it)
4. **Social Proof** (Cases, testimonials, metrics)
5. **Offer Details** (What they get exactly)
6. **Risk Reversal** (Guarantees, no-risk trial)
7. **Urgency/Scarcity** (Limited time/spots)
8. **Final CTA** (Multiple options)

## Campaign Template 1: Quick Win Landing Pages

### Template: "Automatize [Specific Process] em 30 Dias"

#### Target: Companies with manual processes
#### Example: "Automatize Aprovações em 30 Dias"

**Hero Section:**
```html
<h1>Automatize Aprovações em 30 Dias ou Dinheiro de Volta</h1>
<h2>Transforme processos que demoram 5 dias em 30 minutos. 
Sem consultores júnior, sem PowerPoints, só software funcionando.</h2>

<div class="trust-indicators">
  ✅ 88% taxa de sucesso vs 30% do mercado
  ✅ ROI garantido em 90 dias  
  ✅ Implementação em 30 dias, não 18 meses
</div>

<button class="cta-primary">Automatizar Aprovações Agora</button>
<button class="cta-secondary">Calcular ROI em 2 Min</button>
```

**Problem Agitation:**
```html
<section class="problem-section">
  <h2>Aprovações lentas estão matando sua produtividade?</h2>
  
  <div class="problem-grid">
    <div class="problem-item">
      <h3>📧 Emails perdidos</h3>
      <p>Solicitações se perdem no inbox, geram retrabalho e frustração</p>
    </div>
    
    <div class="problem-item">
      <h3>⏰ Gargalos humanos</h3>
      <p>Processo para quando aprovador viaja ou está ocupado</p>
    </div>
    
    <div class="problem-item">
      <h3>👻 Falta de rastreabilidade</h3>
      <p>Ninguém sabe onde está cada solicitação</p>
    </div>
    
    <div class="problem-item">
      <h3>💰 Oportunidades perdidas</h3>
      <p>Vendas não fecham por demora na aprovação de desconto</p>
    </div>
  </div>
  
  <div class="cost-calculator">
    <h3>O custo real da demora:</h3>
    <p><strong>Empresa com 50 funcionários:</strong></p>
    <ul>
      <li>120 horas/mês perdidas em follow-up de aprovações</li>
      <li>R$ 6.000/mês em tempo improdutivo</li>
      <li>R$ 72.000/ano só em custo de oportunidade</li>
    </ul>
  </div>
</section>
```

**Solution Presentation:**
```html
<section class="solution-section">
  <h2>Nossa Automação de Aprovações</h2>
  
  <div class="before-after">
    <div class="before">
      <h3>❌ ANTES (Processo Manual)</h3>
      <ol>
        <li>Funcionário manda email para chefe</li>
        <li>Chefe demora para ver/responder</li>
        <li>Se valor alto, encaminha para diretor</li>
        <li>Diretor analisa quando tem tempo</li>
        <li>Resposta volta por email (ou não)</li>
        <li><strong>Tempo total: 3-7 dias</strong></li>
      </ol>
    </div>
    
    <div class="after">
      <h3>✅ DEPOIS (Workflow Automático)</h3>
      <ol>
        <li>Funcionário preenche formulário digital</li>
        <li>Sistema roteia automaticamente</li>
        <li>Aprovador recebe notificação no celular</li>
        <li>Aprovação em 1 clique via app</li>
        <li>Todos são notificados automaticamente</li>
        <li><strong>Tempo total: 30 minutos</strong></li>
      </ol>
    </div>
  </div>
  
  <div class="features-grid">
    <div class="feature">
      <h4>🔄 Roteamento Inteligente</h4>
      <p>Por valor, tipo, departamento - regras configuráveis</p>
    </div>
    
    <div class="feature">
      <h4>📱 Aprovação Mobile</h4>
      <p>WhatsApp, app ou email - aprovador escolhe</p>
    </div>
    
    <div class="feature">
      <h4>⏰ Escalonamento Automático</h4>
      <p>Se não responder em X horas, sobe para supervisor</p>
    </div>
    
    <div class="feature">
      <h4>📊 Dashboard Completo</h4>
      <p>Veja tudo que está pendente em tempo real</p>
    </div>
  </div>
</section>
```

**Social Proof:**
```html
<section class="social-proof">
  <h2>Não acredite só na nossa palavra</h2>
  
  <div class="testimonial-hero">
    <blockquote>
      "Aprovação de desconto que demorava 2 dias agora sai em 15 minutos. 
      Fechamos 40% mais vendas no primeiro mês."
    </blockquote>
    <cite>Carlos Mendez, Diretor Comercial - MetalTech</cite>
  </div>
  
  <div class="metrics-grid">
    <div class="metric">
      <h3>95%</h3>
      <p>Redução no tempo de aprovação</p>
    </div>
    
    <div class="metric">
      <h3>R$ 180K</h3>
      <p>Economia média anual por cliente</p>
    </div>
    
    <div class="metric">
      <h3>30 dias</h3>
      <p>Payback médio do investimento</p>
    </div>
  </div>
</section>
```

**Offer Details:**
```html
<section class="offer-details">
  <h2>O que você recebe:</h2>
  
  <div class="deliverables">
    <div class="week">
      <h3>Semana 1-2: Análise e Design</h3>
      <ul>
        <li>✅ Mapeamento de todos os processos de aprovação</li>
        <li>✅ Design de workflows otimizados</li>
        <li>✅ Definição de regras e alçadas</li>
        <li>✅ Validação com stakeholders</li>
      </ul>
    </div>
    
    <div class="week">
      <h3>Semana 3-4: Implementação e Testes</h3>
      <ul>
        <li>✅ Configuração do sistema de workflow</li>
        <li>✅ Integração com sistemas existentes</li>
        <li>✅ Testes com processos piloto</li>
        <li>✅ Treinamento da equipe</li>
      </ul>
    </div>
    
    <div class="bonus">
      <h3>🎁 Bônus Inclusos:</h3>
      <ul>
        <li>✅ App mobile personalizado</li>
        <li>✅ Dashboard executivo</li>
        <li>✅ Relatórios automáticos</li>
        <li>✅ Suporte 90 dias</li>
        <li>✅ Documentação completa</li>
      </ul>
    </div>
  </div>
  
  <div class="investment">
    <h3>Investimento:</h3>
    <p class="price">De R$ 85.000 por <span class="highlight">R$ 59.000</span></p>
    <p class="payment">Parcelado em até 3x sem juros</p>
  </div>
</section>
```

---

## Campaign Template 2: Industry-Specific Landing Pages

### Template: "[Industry] + Automação = Resultados"

#### Target: Specific industry verticals
#### Example: "Indústria: Automatize e Economize R$ 300K/ano"

**Hero Section:**
```html
<h1>Indústrias que Automatizam Crescem 40% Mais Rápido</h1>
<h2>Eliminamos gargalos de produção, integramos sistemas e 
transformamos dados em decisões que aumentam margem.</h2>

<div class="industry-stats">
  📈 Clientes industriais economizam em média R$ 280K/ano
  ⚡ Redução de 60% em tempo de setup de produção  
  🎯 Aumento de 25% na produtividade por operador
</div>

<button class="cta-primary">Automatizar Minha Indústria</button>
```

**Industry Pain Points:**
```html
<section class="industry-problems">
  <h2>Problemas que toda indústria enfrenta:</h2>
  
  <div class="problem-tabs">
    <div class="tab-content" id="producao">
      <h3>🏭 Produção</h3>
      <ul>
        <li>Setup manual demorado entre lotes</li>
        <li>Paradas não programadas por falta de manutenção preventiva</li>
        <li>Controle de qualidade reativo, não preditivo</li>
        <li>Falta de visibilidade real do OEE</li>
      </ul>
    </div>
    
    <div class="tab-content" id="estoque">
      <h3>📦 Estoque</h3>
      <ul>
        <li>Ruptura de matéria-prima que para produção</li>
        <li>Excesso de produto acabado parado</li>
        <li>Inventário manual sujeito a erros</li>
        <li>Previsão de demanda baseada em "achismo"</li>
      </ul>
    </div>
    
    <div class="tab-content" id="custos">
      <h3>💰 Custos</h3>
      <ul>
        <li>Custo real por produto só conhecido no final do mês</li>
        <li>Desperdício de material não identificado em tempo real</li>
        <li>Horas extras por falta de planejamento</li>
        <li>Retrabalho por problemas de qualidade</li>
      </ul>
    </div>
  </div>
</section>
```

**Industry-Specific Solutions:**
```html
<section class="industrial-solutions">
  <h2>Soluções HERO para Indústria:</h2>
  
  <div class="solutions-grid">
    <div class="solution-card">
      <h3>🤖 Automação de Produção</h3>
      <p><strong>Problema:</strong> Setup manual de 2 horas entre lotes</p>
      <p><strong>Solução:</strong> Sistema que configura máquinas automaticamente</p>
      <p><strong>Resultado:</strong> Setup reduzido para 15 minutos</p>
      <div class="roi">ROI: 340% no primeiro ano</div>
    </div>
    
    <div class="solution-card">
      <h3>📊 BI Operacional</h3>
      <p><strong>Problema:</strong> Relatórios de produção com 24h de atraso</p>
      <p><strong>Solução:</strong> Dashboard em tempo real do chão de fábrica</p>
      <p><strong>Resultado:</strong> Decisões imediatas baseadas em dados</p>
      <div class="roi">ROI: 280% no primeiro ano</div>
    </div>
    
    <div class="solution-card">
      <h3>🔮 Manutenção Preditiva</h3>
      <p><strong>Problema:</strong> Paradas não programadas custam R$ 50K/dia</p>
      <p><strong>Solução:</strong> IoT + IA preveem falhas antes que aconteçam</p>
      <p><strong>Resultado:</strong> 90% redução em paradas não programadas</p>
      <div class="roi">ROI: 450% no primeiro ano</div>
    </div>
  </div>
</section>
```

---

## Campaign Template 3: Objection-Based Landing Pages

### Template: "Superando [Common Objection]"

#### Target: Prospects with specific concerns
#### Example: "Automação Sem Demitir Ninguém"

**Objection Addressing Hero:**
```html
<h1>Automação que Potencializa Pessoas, Não Substitui</h1>
<h2>Libere sua equipe das tarefas chatas para focar no que humanos fazem melhor: 
criar, relacionar e inovar.</h2>

<div class="reassurance-badges">
  ✅ 100% dos nossos clientes mantiveram ou aumentaram o quadro
  ✅ Funcionários mais satisfeitos com trabalho mais estratégico
  ✅ Crescimento da empresa financia novas contratações
</div>
```

**Objection Breakdown:**
```html
<section class="objection-breakdown">
  <h2>A verdade sobre automação e empregos:</h2>
  
  <div class="myth-vs-reality">
    <div class="myth">
      <h3>❌ MITO</h3>
      <p>"Automação elimina postos de trabalho"</p>
    </div>
    
    <div class="reality">
      <h3>✅ REALIDADE</h3>
      <p>"Automação elimina tarefas repetitivas e libera pessoas para atividades de maior valor"</p>
    </div>
  </div>
  
  <div class="evidence">
    <h3>Evidências dos nossos clientes:</h3>
    <ul>
      <li><strong>MetalTech:</strong> Automatizou orçamentos, vendas aumentaram 40%, contratou 3 vendedores</li>
      <li><strong>LogiTrans:</strong> Automatizou relatórios, analista virou gerente de BI</li>
      <li><strong>InnovaTech:</strong> Automatizou aprovações, RH passou a focar em desenvolvimento de pessoas</li>
    </ul>
  </div>
</section>
```

---

## Campaign Template 4: Competitive Displacement

### Template: "Deixe de Ser Refém de [Competitor]"

#### Target: Prospects unhappy with current providers
#### Example: "Deixe de Ser Refém de Consultoria Cara e Lenta"

**Competitor Problem:**
```html
<h1>Cansado de Pagar Milhões para Consultorias que Não Entregam?</h1>
<h2>Enquanto big4 cobra R$ 2M por 18 meses de PowerPoint, 
a HERO entrega resultados reais em 90 dias por R$ 200K.</h2>

<div class="comparison-table">
  <table>
    <tr>
      <th></th>
      <th>Big4/Grandes Consultorias</th>
      <th>HERO</th>
    </tr>
    <tr>
      <td>Diagnóstico</td>
      <td>4-6 meses de reuniões</td>
      <td>7-15 dias no seu chão de fábrica</td>
    </tr>
    <tr>
      <td>Equipe</td>
      <td>Consultores júnior supervisionados</td>
      <td>Especialistas sêniores dedicados</td>
    </tr>
    <tr>
      <td>Entrega</td>
      <td>PowerPoints e documentos</td>
      <td>Software funcionando</td>
    </tr>
    <tr>
      <td>Timeline</td>
      <td>18-24 meses para "resultados"</td>
      <td>90 dias para ROI comprovado</td>
    </tr>
    <tr>
      <td>Garantia</td>
      <td>Extensão de contrato</td>
      <td>Dinheiro de volta</td>
    </tr>
    <tr>
      <td>Suporte</td>
      <td>Acaba quando contrato acaba</td>
      <td>Parceria de longo prazo</td>
    </tr>
  </table>
</div>
```

---

## Standard Landing Page Components

### Trust Signals Template
```html
<div class="trust-signals">
  <div class="guarantee">
    <h3>🛡️ Garantia Total de Resultados</h3>
    <p>ROI em 90 dias ou 100% do dinheiro de volta</p>
  </div>
  
  <div class="expertise">
    <h3>👨‍💼 Especialistas Sêniores</h3>
    <p>Acesso direto ao CEO e CTO, não intermediários</p>
  </div>
  
  <div class="speed">
    <h3>⚡ Implementação Rápida</h3>
    <p>Resultados em 30-90 dias, não anos</p>
  </div>
  
  <div class="support">
    <h3>📱 Suporte Real</h3>
    <p>WhatsApp direto, resposta em até 2 horas</p>
  </div>
</div>
```

### Urgency/Scarcity Template
```html
<div class="urgency-section">
  <h3>⏰ Vagas Limitadas</h3>
  <p>Atendemos apenas 3 novos clientes por mês para garantir qualidade máxima</p>
  
  <div class="availability">
    <span class="spots-left">2 vagas restantes para [Month]</span>
    <span class="next-available">Próxima disponibilidade: [Next Month]</span>
  </div>
  
  <div class="bonus-expiry">
    <h4>🎁 Bônus por tempo limitado:</h4>
    <ul>
      <li>Dashboard executivo personalizado (valor R$ 15K)</li>
      <li>Suporte estendido por 6 meses (valor R$ 20K)</li>
      <li>Treinamento avançado da equipe (valor R$ 10K)</li>
    </ul>
    <p class="expiry">Válido apenas para contratos fechados até [Date]</p>
  </div>
</div>
```

### Multi-Step CTA Template
```html
<div class="cta-progression">
  <div class="primary-ctas">
    <button class="cta-main">Quero Automatizar Agora</button>
    <button class="cta-secondary">Calcular ROI Específico</button>
  </div>
  
  <div class="alternative-ctas">
    <a href="#" class="cta-soft">Download: Guia de Automação (PDF)</a>
    <a href="#" class="cta-soft">Ver Cases de Sucesso Similares</a>
    <a href="#" class="cta-soft">Agendar Demo de 15 Minutos</a>
  </div>
  
  <div class="contact-options">
    <p>Prefere falar direto?</p>
    <a href="tel:+5527999999999" class="phone-cta">📞 (27) 99999-9999</a>
    <a href="https://wa.me/5527999999999" class="whatsapp-cta">💬 WhatsApp</a>
  </div>
</div>
```

## Technical Implementation

### Mobile-First Responsive Design
- **Single-column layout** on mobile
- **Touch-friendly buttons** (minimum 44px)
- **Fast loading** (< 3 seconds)
- **Progressive enhancement** for desktop

### Conversion Tracking
- **Form submission** events
- **Scroll depth** milestones (25%, 50%, 75%, 100%)
- **Time on page** thresholds
- **CTA click rates** by position
- **Exit intent** triggers

### A/B Testing Framework
- **Headlines:** Test different value propositions
- **Hero images/videos:** Test emotional vs. rational appeal
- **CTA copy:** Test action vs. benefit-focused language
- **Social proof placement:** Test different positions
- **Form length:** Test minimal vs. detailed capture

### SEO Optimization
- **Title tag:** [Primary Keyword] | [Unique Value Prop] | HERO
- **Meta description:** Include target keyword + benefit + CTA
- **H1 tag:** Match title tag intent
- **Schema markup:** Service, Organization, LocalBusiness
- **Page speed:** Target < 3s load time
- **Mobile-friendly:** Google Mobile-Friendly Test approved