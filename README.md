# 🟦 **README.md — iSH Ping Tools (ish-scripts Edition)**

## **iSH Ping Tools — Network Diagnostics & ASCII Graphs**

Sada pokročilých nástrojov pre **iSH Shell** na iOS**, optimalizovaná pre malé terminály a nízku spotrebu CPU.  
Obsahuje timestampované pingovanie, ASCII grafy, sliding‑window vizualizácie, farebné grafy, jitter a centrálny konfiguračný súbor.

Všetky skripty sú kompatibilné s Alpine Linux v iSH a nevyžadujú žiadne externé balíky.

---

## 🟦 Funkcie

- Timestampované logovanie pingov  
- Výpočet min / max / avg / packet‑loss  
- ASCII graf odozvy  
- Sliding‑window graf (posúva sa doprava)  
- Farebný sliding‑window graf  
- Sliding‑window graf s jitterom  
- Centrálna konfigurácia cez `ping.conf`  
- Automatický update cez `update.sh`  
- Automatický `chmod +x` po update  
- Optimalizované pre iSH terminál  

---

## 🟦 Požiadavky

- iSH Shell (iOS)
- Alpine Linux balíčky:

```
apk update
apk add git
```

---

## 🟦 Inštalácia

Naklonuj repozitár:

```
git clone https://github.com/martinkusnierik/ish-scripts.git
cd ish-scripts
```

Sprístupni skripty:

```
chmod +x *.sh
```

---

## 🟦 Konfiguračný súbor: `ping.conf`

Všetky skripty načítavajú tento súbor automaticky.

```
TARGET="sme.sk"
WINDOW=50
MAX_HEIGHT=20
SCALE=1

GREEN_LIMIT=40
YELLOW_LIMIT=80
```

---

## 🟦 Skripty

### **1. pingstats.sh**  
Timestampovaný ping + štatistiky po ukončení.

```
./pingstats.sh
```

---

### **2. pinggraph.sh**  
Jednoduchý vertikálny ASCII graf odozvy.

```
./pinggraph.sh
```

---

### **3. pingwindow.sh**  
Sliding‑window ASCII graf (posúva sa doprava).

```
./pingwindow.sh
```

---

### **4. pingwindow_color.sh**  
Farebný sliding‑window graf s farbami podľa odozvy.

```
./pingwindow_color.sh
```

---

### **5. pingwindow_jitter.sh**  
Sliding‑window graf + živý výpočet jitteru.

```
./pingwindow_jitter.sh
```

---

### **6. update.sh**  
Automatická aktualizácia skriptov + automatický `chmod +x`.

```
./update.sh
```

---

## 🟦 Porovnávacia tabuľka skriptov

| Skript | Funkcia | Graf | Farby | Sliding Window | Jitter | Config | Logovanie |
|-------|---------|-------|--------|----------------|--------|---------|-----------|
| **pingstats.sh** | Štatistiky po ukončení | ❌ | ❌ | ❌ | ❌ | ✔️ | ✔️ |
| **pinggraph.sh** | Jednoduchý ASCII graf | ✔️ vertikálny | ❌ | ❌ | ❌ | ✔️ | ✔️ |
| **pingwindow.sh** | Sliding‑window graf | ✔️ | ❌ | ✔️ | ❌ | ✔️ | ✔️ |
| **pingwindow_color.sh** | Farebný sliding‑window graf | ✔️ | ✔️ | ✔️ | ❌ | ✔️ | ✔️ |
| **pingwindow_jitter.sh** | Sliding‑window + jitter | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |
| **update.sh** | Auto‑update + chmod | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

---

## 🟦 Logovanie

Každý skript vytvára logy vo formáte:

```
pinglog_YYYY-MM-DD_HH-MM-SS.txt
```

Logy sú ignorované v `.gitignore`.

---

## 🟦 Aktualizácia skriptov

Najjednoduchšie:

```
./update.sh
```

Alebo ručne:

```
git pull
chmod +x *.sh
```

---

## 🟦 Štruktúra repozitára

```
/ish-scripts
 ├── ping.conf
 ├── pingstats.sh
 ├── pinggraph.sh
 ├── pingwindow.sh
 ├── pingwindow_color.sh
 ├── pingwindow_jitter.sh
 ├── update.sh
 ├── README.md
 ├── .gitignore
 └── LICENSE
```

---

## 🟦 Licencia

MIT License.

---
