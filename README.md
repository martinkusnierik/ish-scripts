# 🟦 **README.md (minimalistické core repo)**

```
# iSH Ping Tools — Core Edition

Minimalistická sada nástrojov pre diagnostiku siete v iSH (iOS).  
Obsahuje iba to, čo je potrebné pre každodennú prácu: rýchly Cisco‑style ping a jednoduchý update mechanizmus.

## Obsah

- `pingstream.sh` — hlavný nástroj, farebný Cisco‑style ping s MTU/payload, sekvenčným číslovaním, štatistikami a histogramom.
- `shared_stats.sh` — spoločná knižnica pre štatistiky a histogram.
- `ping.conf` — konfiguračný súbor (target, MTU, prahy farieb).
- `update.sh` — aktualizácia repozitára cez Git.

## Použitie

### Spustenie hlavného nástroja

```
./pingstream.sh
```

Výstup:
- `!` — úspešný ping (zelený)
- `.` — timeout (červený)
- `U` — host unreachable
- `N` — network unreachable
- `?` — DNS / bad address
- automatické logovanie do `pinglog_*.txt`
- štatistiky a histogram po stlačení CTRL+C

### Konfigurácia

Uprav v `ping.conf`:

```
TARGET="sme.sk"
MTU=1500
GREEN_LIMIT=40
YELLOW_LIMIT=80
```

### Aktualizácia nástrojov

```
./update.sh
```

Skript:
- skontroluje Git repozitár
- uloží lokálne zmeny (stash)
- stiahne najnovšiu verziu
- obnoví executable bity

## Licencia

MIT License — viď `LICENSE`.
```

