# 🟦 **README.md — iSH Ping Tools (Complete Edition)**

## **iSH Ping Tools — Network Diagnostics & ASCII Graphs**

Sada pokročilých nástrojov pre **iSH Shell** na iOS.  
Obsahuje skripty na timestampované pingovanie, výpočet štatistík, ASCII grafy, sliding‑window vizualizácie, farebné grafy a živý výpočet jitteru.

Všetky skripty sú kompatibilné s Alpine Linux v iSH a nevyžadujú žiadne externé balíky.

---

## 🟦 Funkcie

- Timestampované logovanie pingov  
- Výpočet min / max / avg / packet‑loss  
- ASCII graf odozvy  
- Sliding‑window graf (posúva sa doprava)  
- Farebný sliding‑window graf  
- Sliding‑window graf s jitterom  
- Logovanie do súborov s dátumom a časom  
- Optimalizované pre iSH terminál  
- Jednoduché spustenie a aktualizácia cez GitHub

---

## 🟦 Požiadavky

- iSH Shell (iOS)
- Alpine Linux balíčky:

```sh
apk update
apk add git
```

---

## 🟦 Inštalácia

Naklonuj repozitár:

```sh
git clone https://github.com/martinkusnierik/ish-scripts.git
cd ish-scripts
```

Sprístupni skripty:

```sh
chmod +x *.sh
```

---

## 🟦 Skripty

### **1. pingstats.sh**  
Klasický timestampovaný ping s výpočtom štatistík po ukončení.

```sh
./pingstats.sh
```

---

### **2. pinggraph.sh**  
Jednoduchý vertikálny ASCII graf odozvy.

```sh
./pinggraph.sh
```

---

### **3. pingwindow.sh**  
Sliding‑window ASCII graf (posúva sa doprava).

```sh
./pingwindow.sh
```

---

### **4. pingwindow_color.sh**  
Farebný sliding‑window graf s farbami podľa odozvy:

- zelená < 40 ms  
- žltá 40–80 ms  
- červená > 80 ms  
- šedá = timeout  

```sh
./pingwindow_color.sh
```

---

### **5. pingwindow_jitter.sh**  
Sliding‑window graf + živý výpočet jitteru (|current – previous|).

```sh
./pingwindow_jitter.sh
```

---

## 🟦 Porovnávacia tabuľka skriptov

| Skript | Funkcia | Graf | Farby | Sliding Window | Jitter | Logovanie |
|-------|---------|-------|--------|----------------|--------|-----------|
| **pingstats.sh** | Štatistiky po ukončení | ❌ | ❌ | ❌ | ❌ | ✔️ |
| **pinggraph.sh** | Jednoduchý ASCII graf | ✔️ vertikálny | ❌ | ❌ | ❌ | ✔️ |
| **pingwindow.sh** | Sliding‑window graf | ✔️ | ❌ | ✔️ | ❌ | ✔️ |
| **pingwindow_color.sh** | Farebný sliding‑window graf | ✔️ | ✔️ | ✔️ | ❌ | ✔️ |
| **pingwindow_jitter.sh** | Sliding‑window + jitter | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |

---

## 🟦 Logovanie

Každý skript vytvára logy vo formáte:

```
pinglog_YYYY-MM-DD_HH-MM-SS.txt
```

Logy sú ignorované v `.gitignore`.

---

## 🟦 Aktualizácia skriptov

Ak skripty upravíš na GitHube, v iSH ich aktualizuješ:

```sh
git pull
```

---

## 🟦 Štruktúra repozitára

```
/ish-scripts
 ├── pingstats.sh
 ├── pinggraph.sh
 ├── pingwindow.sh
 ├── pingwindow_color.sh
 ├── pingwindow_jitter.sh
 ├── README.md
 ├── .gitignore
 └── LICENSE
```

---

## 🟦 Licencia

MIT License.

---
