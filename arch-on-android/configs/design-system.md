# Design System — Nord ArchDroid

Sistema de design unificado para o ambiente i3/Polybar/Rofi/Starship/Zsh.
Referência canônica: qualquer novo config ou ajuste futuro parte deste documento.

---

## Fundação — Paleta Nord

A paleta Nord é dividida em quatro grupos com papéis semânticos definidos.

### Polar Night — backgrounds e superfícies

| Token | Hex | Papel |
|---|---|---|
| `nord0` | `#2E3440` | Background mais profundo — base do ambiente, bordas invisíveis |
| `nord1` | `#3B4252` | Background principal — Polybar, Rofi window |
| `nord2` | `#434C5E` | Background elevado — inputs, hover sutil |
| `nord3` | `#4C566A` | Background secundário — módulos Polybar, elementos ocupados |

Regra: superfícies mais próximas do usuário usam tons mais claros dentro do grupo Polar Night. A progressão `nord0 → nord3` representa profundidade crescente.

### Snow Storm — textos e foregrounds

| Token | Hex | Papel |
|---|---|---|
| `nord4` | `#D8DEE9` | Texto principal |
| `nord5` | `#E5E9F0` | Texto sobre fundos escuros, foreground em segmentos ativos |
| `nord6` | `#ECEFF4` | Texto de máximo contraste — foreground em elementos urgentes/ativos |

### Frost — destaques e interação

| Token | Hex | Papel |
|---|---|---|
| `nord7` | `#8FBCBB` | Cyan suave — links, detalhes secundários |
| `nord8` | `#88C0D0` | Cyan principal — seleção ativa (Rofi), duração de comando (Starship) |
| `nord9` | `#81A1C1` | Azul médio — texto alternativo, Starship prompt, fzf highlights |
| `nord10` | `#5E81AC` | Azul escuro — segmento de identidade do Starship |

Regra: Frost é a cor de interação e destaque. Elementos clicáveis, estados ativos e foco primário usam tons deste grupo. `nord8` é o destaque primário; `nord10` é para fundos com texto escuro.

### Aurora — estados semânticos

| Token | Hex | Estado |
|---|---|---|
| `nord11` | `#BF616A` | Erro, janela focada (i3), estado crítico |
| `nord12` | `#D08770` | Aviso secundário, laranja |
| `nord13` | `#EBCB8B` | Aviso, janela urgente (i3) |
| `nord14` | `#A3BE8C` | Sucesso, cursor ok (Starship) |
| `nord15` | `#B48EAD` | Informação alternativa, roxo |

Regra: Aurora nunca é usada como background de superfície neutra — apenas como sinalização de estado. Usar com moderação.

---

## Tipografia

| Papel | Fonte | Tamanho |
|---|---|---|
| Terminal / Prompt | JetBrains Mono Nerd Font | 12–13pt |
| i3 (títulos, labels) | JetBrains Mono Medium | 10pt |
| Polybar | JetBrains Mono Medium | 9pt |
| Polybar (ícones) | Symbols Nerd Font | 10pt |
| Rofi | JetBrains Mono | 10pt |

Fonte única em todo o ambiente garante consistência de métricas e evita conflito de rendering entre aplicações.

---

## Ícones

Sistema: **Nerd Fonts** para ícones de interface (Starship, Polybar, terminal).
Tema de ícones de apps: **Nordzy** (preferencial) com fallback **Papirus-Dark**.

```bash
# Instalar Nordzy
yay -S nordzy-icon-theme
gtk-update-icon-cache ~/.local/share/icons/Nordzy

# Instalar Papirus-Dark (fallback)
sudo pacman -S papirus-icon-theme
```

Para trocar entre eles no Rofi: alterar `icon-theme` no `config.rasi`.

---

## Espaçamento e Geometria

### Gaps (i3)
```
gaps inner = 8px
gaps outer = 4px
```
Proporção 2:1 entre inner e outer. Respiração suficiente sem desperdiçar espaço de tela.

### Bordas (i3)
```
border pixel = 1px
```
Borda mínima. A cor carrega todo o peso semântico — espessura não precisa compensar.

### Padding (Polybar)
```
padding lateral da bar = 6
module-margin = 2
label-padding = 8 (workspaces) / 1 (módulos de info)
```

### Polybar height
```
height = 28px
offset-y = 4px
```
Pequena margem superior cria separação visual da borda do monitor sem precisar de gaps extras.

---

## Mapeamento de Estados — i3 Window Borders

| Estado | Border | Background | Texto |
|---|---|---|---|
| Focada | `nord11` `#BF616A` | `nord11` | `nord6` |
| Inativa / Unfocused | `nord0` `#2E3440` | `nord0` | `nord3` |
| Urgente | `nord13` `#EBCB8B` | `nord13` | `nord0` |

Janelas inativas têm border na cor do background — desaparecem visualmente sem desativar o protocolo de border. Foco em `nord11` (vermelho Aurora) cria contraste imediato sem ser agressivo.

---

## Mapeamento de Estados — Polybar Workspaces

| Estado | Foreground | Background |
|---|---|---|
| Focado | `nord1` (background) | `nord8` (cyan) |
| Ocupado | `nord4` (texto) | `nord3` (secondary-bg) |
| Urgente | `nord4` | `nord11` (vermelho) |
| Vazio | `#A8ACB3` (dimmed) | transparente |

---

## Mapeamento de Estados — Starship Prompt

| Segmento | Background | Foreground |
|---|---|---|
| OS + usuário + hostname | `nord10` `#5E81AC` | `nord0` |
| Diretório | `nord9` `#81A1C1` | `nord0` |
| Git branch + status | `nord8` `#88C0D0` | `nord0` |
| Hora | `nord3` `#4C566A` | `nord4` |
| Duração | `nord1` `#3B4252` | `nord8` |
| Cursor — sucesso | — | `nord14` `#A3BE8C` |
| Cursor — erro | — | `nord11` `#BF616A` |

Progressão de temperatura de cor da esquerda para a direita: Frost (quente/ativo) → Polar Night (frio/passivo). Informação mais relevante fica mais saturada.

---

## Mapeamento de Estados — Rofi

| Elemento | Background | Foreground |
|---|---|---|
| Window | `nord1` | — |
| Input | `nord2` | `nord4` |
| Prompt | `nord8` | `nord1` |
| Item normal | `transparent` (herda `nord1` da window) | `nord4` |
| Item selecionado | `nord8` | `nord1` |
| Item urgente | `nord11` | `nord6` |
| Scrollbar | `nord0` | handle `nord3` |

---

## Regras de Consistência

**1. Texto sobre fundo Frost usa sempre Polar Night**
`nord8`/`nord9`/`nord10` como background → foreground sempre `nord0` ou `nord1`. Nunca Snow Storm sobre Frost — contraste insuficiente.

**2. Aurora é semântica, não decorativa**
`nord11`–`nord15` sinalizam estados (erro, sucesso, urgência). Não usar como cor de superfície neutra ou decoração.

**3. Uma cor de destaque primária por contexto**
Cada aplicação tem um Frost como cor de destaque principal: Polybar usa `nord8`, Starship usa `nord8`/`nord10`, Rofi usa `nord8`. Consistência no destaque cria coerência visual entre apps.

**4. Tipografia única**
JetBrains Mono em todo o ambiente. Não misturar com outras fontes sans-serif exceto onde Nerd Font é necessário para ícones.

**5. Gradiente de escurecimento = gradiente de passividade**
Elementos mais escuros (Polar Night mais fundo) = menos ativos, menos importantes. Elementos mais claros ou com Frost = ativos, focados, relevantes.

---

## Aplicar em Novos Configs

Para qualquer nova ferramenta ou config que entrar no ambiente:

1. Usar os tokens deste documento — não inventar novos hex values Nord
2. Background de superfície → Polar Night (`nord0`–`nord3`)
3. Texto → Snow Storm (`nord4`–`nord6`)
4. Destaque/interação → Frost (`nord7`–`nord10`), preferindo `nord8` como primário
5. Estado semântico → Aurora (`nord11`–`nord15`)
6. Fonte → JetBrains Mono na variante adequada ao contexto

---

## Arquivos do Sistema

| Arquivo | Destino |
|---|---|
| `starship.toml` | `~/.config/starship.toml` |
| `.zshrc` | `~/.zshrc` |
| `i3-config` | `~/.config/i3/config` |
| `polybar-config` | `~/.config/polybar/config.ini` |
| `rofi-config` | `~/.config/rofi/config.rasi` |
