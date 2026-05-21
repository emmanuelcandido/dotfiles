# ArchDroid Design System — Nord

Referência visual para manter consistência entre i3, polybar, rofi, dunst, ulauncher e qualquer outro componente do desktop.

## Paleta Nord

```
nord0  #2E3440  — background base (i3 bg, ulauncher bg)
nord1  #3B4252  — background elevado (polybar bg, ulauncher border, item hover)
nord2  #434C5E  — highlight sutil
nord3  #4C566A  — background secundário (módulos polybar, input focus)
nord4  #D8DEE9  — foreground primário (texto, labels)
nord5  #E5E9F0  — foreground input
nord6  #ECEFF4  — foreground selecionado
nord7  #8FBCBB  — links
nord8  #88C0D0  — destaque (workspace focused, dunst frame, polybar cyan)
nord9  #81A1C1
nord10 #5E81AC  — accent secundário (shortcut ulauncher)
nord11 #BF616A  — red (urgente, alerts)
nord12 #D08770  — orange
nord13 #EBCB8B  — yellow
nord14 #A3BE8C  — green
nord15 #B48EAD  — magenta
```

## Formas

| Token | Valor | Aplica-se a |
|-------|-------|-------------|
| `border-radius` | `0` | **Todo componente.** Janelas, inputs, menus, notificações. Sem cantos arredondados. |
| `border-width` | `1px` (i3), `2px` (dunst frame) | Borda externa de containers |
| `border-color` | `nord1` (#3B4252) | Borda padrão |

## Tipografia

| Uso | Família | Tamanho |
|-----|---------|---------|
| Títulos/i3 | `JetBrains Mono Medium` | `10` |
| UI geral | `Noto Sans` | `10` |
| Ícones | `Symbols Nerd Font` | `10` |
| Barra (polybar) | `Symbols Nerd Font:size=10` + `Roboto:size=9:weight=medium` |

## Espaçamento

| Token | Valor | Onde |
|-------|-------|------|
| `gaps inner` | `8` | i3 — entre janelas |
| `gaps outer` | `4` | i3 — borda da tela |
| polybar height | `28` | Altura da barra |
| polybar offset-y | `4` | Margem superior |
| módulo padding | `1-2` | Polybar modules |
| rofi padding | `16` | Espaçamento interno |
| rofi spacing | `8` | Entre itens |
| dunst padding | `8` | Notificação interna |

## Componentes

### i3
- **Bg:** nord0 (#2E3440)
- **Border:** nord1 (#3B4252)
- **Focused:** nord8 (#88C0D0)
- **Font:** JetBrains Mono Medium 10
- **Workspace icons:** Nerd Font symbols com `strip-wsnumbers`

### Polybar
- **Bg:** nord1 (#3B4252) — levemente mais claro que o fundo i3
- **Modules bg:** nord3 (#4C566A)
- **Fg:** nord4 (#D8DEE9)
- **Destaque:** nord8 (#88C0D0)

### Rofi
- **Bg:** nord0
- **Selected:** nord1
- **Font:** Noto Sans 10
- **Icons:** Papirus

### Dunst
- **Frame:** nord8 (#88C0D0), 2px
- **Bg:** nord0
- **Fg:** nord4
- **Font:** Noto Sans 10
- **Posição:** top-right

### Ulauncher
- **Bg:** nord0, border-radius: 0
- **Border:** nord1
- **Selected item:** nord1
- **Input:** nord4
- **Shortcut:** nord10

## Alçadas visuais (elevation)

```
i3 desktop bg     → nord0  (#2E3440)  — fundo
i3 windows        → nord0              — mesclado com o fundo
polybar           → nord1  (#3B4252)  — 1 nível acima
dunst/dialogs     → nord0              — sobreposição
ulauncher         → nord0 + borda      — overlay
```

## Regras gerais

1. **Nunca usar `border-radius`.** Tudo deve ser quadrado.
2. **Nunca usar sombras.** Sem drop-shadows, sem `box-shadow`.
3. **Bg sempre nord0 ou nord1.** Nunca branco (#FFFFFF) ou preto (#000000).
4. **Ícones sempre Nerd Font.** Evitar emoji nativo ou ícones bitmap.

## Alternativas futuras

- **[linux_notification_center](https://github.com/phuhl/linux_notification_center)** — substituto futuro para dunst. Mesmo design system se aplica.
