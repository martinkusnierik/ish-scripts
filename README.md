# 🟦 **README.md – iSH Ping Logger & Network Tools**

> Tento text môžeš priamo vložiť do svojho `README.md`.

---

## **iSH Ping Logger & Network Diagnostics Tools**

Sada skriptov určených pre aplikáciu **iSH Shell** na iOS.  
Umožňujú timestampované logovanie pingov, generovanie štatistík a jednoduché monitorovanie sieťovej odozvy priamo na iPhone alebo iPade.

---

## **Funkcie**

- Timestampované logovanie pingov  
- Ukladanie logov do súborov s dátumom a časom v názve  
- Zobrazenie výstupu v reálnom čase  
- Automatický výpočet štatistík po ukončení merania:
  - počet odoslaných paketov  
  - počet prijatých paketov  
  - percento strát  
  - min / max / avg čas odozvy  
- Kompatibilné s iSH (Alpine Linux)  
- Jednoduché spustenie a aktualizácia cez GitHub

---

## **Požiadavky**

- iSH Shell (iOS)  
- Alpine Linux balíčky:

```sh
apk update
apk add git
```

---

## **Inštalácia**

Naklonuj repository do iSH:

```sh
git clone https://github.com/TVOJ_USERNAME/TVOJE_REPO.git
cd TVOJE_REPO
chmod +x pingstats.sh
```

---

## **Použitie**

Spusti hlavný skript:

```sh
./pingstats.sh
```

Skript:

- začne pingovať cieľ (default: google.com)  
- zapisuje každý riadok s časovou značkou  
- po stlačení **CTRL+C** vypočíta štatistiky a zobrazí ich na obrazovke  

Log súbor sa uloží ako:

```
pinglog_YYYY-MM-DD_HH-MM-SS.txt
```

---

## **Príklad výstupu**

```
----- Ping Statistics -----
Target: google.com
Packets sent: 120
Packets received: 118
Packet loss: 1%
Min time: 21.3 ms
Max time: 28.7 ms
Avg time: 23.9 ms
---------------------------
```

---

## **Aktualizácia skriptov**

Ak skripty upravíš na GitHube, v iSH ich aktualizuješ:

```sh
git pull
```

---

## **Súbory**

- `pingstats.sh` — hlavný skript s timestampovaným pingom a štatistikami  
- ďalšie utility podľa potreby

---

## **Licencia**

MIT License.
