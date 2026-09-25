# Evolução dos Modelos de Regressão Linear Múltipla
**Variável Alvo:** ADG (Average Daily Gain / Ganho de Peso Médio Diário)

Neste documento, descrevemos a evolução do planejamento do experimento preditivo, passando por três abordagens de modelagem até atingir o modelo parcimonioso ideal.

---

### Modelo 1: O "Vazamento de Dados" (Com Peso Final e Períodos)
* **Abordagem:** O modelo foi treinado com todas as variáveis disponíveis no dataset após o filtro de multicolinearidade (VIF), incluindo `FINAL_WEIGHT` (Peso Final), `AMOUNT_DAYS` e `PERIOD`.
* **Resultado:** $R^2_{ajustado}$ de **0.9713 (97,13%)**.
* **Diagnóstico:** Embora o R² parecesse excelente, o modelo sofreu de *Data Leakage* (Vazamento de Dados). Como o ADG é calculado matematicamente pela fórmula `(Peso Final - Peso Inicial) / Dias`, ao fornecer essas variáveis independentes, o algoritmo não previu o desempenho animal, mas apenas resolveu a equação matemática. O modelo não possuía utilidade preditiva real.

---

### Modelo 2: Correção de Vazamento (Sem Peso Final e Sem Períodos)
* **Abordagem:** Remoção estrita das variáveis que compõem a fórmula do ADG (`FINAL_WEIGHT`, `AMOUNT_DAYS`, `PERIOD`), forçando o modelo a prever o ganho de peso baseando-se exclusivamente no comportamento animal (turnos de alimentação), estações do ano e no Peso Inicial. Utilizou-se a seleção *Stepwise* (AIC) para selecionar as melhores características.
* **Resultado:** $R^2_{ajustado}$ de **0.2259 (22,59%)** com **10 variáveis preditoras**.
* **Diagnóstico:** Um modelo matematicamente honesto e biologicamente realista. Explicar 22,5% da variância em um sistema animal aberto apenas com dados ambientais e de cocho é um resultado zootécnico sólido. O modelo identificou tendências importantes de manejo (ex: alimentação noturna prejudicando o ADG) e a influência das estações (Primavera impulsionando e Inverno prejudicando o ganho).

---

### Modelo 3: O Modelo Parcimonioso (Mantendo o Período)
* **Abordagem:** Reintrodução da variável `PERIOD` (Tempo de permanência), mantendo o `FINAL_WEIGHT` oculto para evitar o vazamento de dados. A hipótese era de que o tempo total no sistema é um fator fisiológico limitante do ADG (devido à maturidade e deposição de gordura). O modelo foi novamente refinado pelo método *Stepwise* (AIC).
* **Resultado:** $R^2_{ajustado}$ de **0.2154 (21,54%)** com apenas **5 variáveis preditoras**.
* **Diagnóstico:** O modelo definitivo do experimento. Ao devolver a variável `PERIOD`, a regressão conseguiu atingir praticamente o mesmo poder de explicação do Modelo 2, mas utilizando metade das variáveis. O algoritmo filtrou o ruído e isolou as 5 leis fundamentais do ganho de peso no lote:
  1. `PERIOD` (Tempo de permanência)
  2. `START_WEIGHT` (Peso de entrada)
  3. `TOTAL_TIME..12.18h.` (Comportamento de cocho à tarde)
  4. `TOTAL_TIME_SPRING` (Impacto ambiental da Primavera)
  5. `TOTAL_DAYS_WINTER` (Impacto ambiental do Inverno)

**Conclusão:** O Modelo 3 representa a forma mais elegante e simplificada de explicar a variação do ganho de peso, unindo alto rigor estatístico (sem vazamento de dados) à alta interpretabilidade zootécnica.