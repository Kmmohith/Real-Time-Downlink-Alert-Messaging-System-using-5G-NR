<h1 align="center">📡 Real-Time Downlink Alert Messaging System using 5G NR (MATLAB)</h1>

<p align="center">
  <img src="https://img.shields.io/badge/MATLAB-R2024a-orange?logo=mathworks&logoColor=white" />
  <img src="https://img.shields.io/badge/Modulation-16QAM%20|%2064QAM-blue" />
  <img src="https://img.shields.io/badge/Technology-5G%20NR-green" />
  <img src="https://img.shields.io/badge/System-OFDM%20Downlink-purple" />
</p>

---

### 🚀 Overview
This project implements a **5G NR-based downlink alert messaging system** that demonstrates **real-time message transmission and recovery** using **OFDM** and **QAM** modulation in MATLAB.  
It showcases how modern wireless systems enable **reliable digital communication** for **smart city and disaster management** applications.

---

### 🧩 System Architecture
Message → Binary Mapping → 16-QAM Modulation
→ OFDM (IFFT + Cyclic Prefix)
→ AWGN Channel (SNR 0–25 dB)
→ FFT Demodulation + QAM Demapping
→ Message Recovery


---

### ⚙️ Key Features
✅ Real-time message transmission & decoding  
✅ OFDM modulation with 64-point IFFT and cyclic prefix  
✅ 16-QAM / 64-QAM signal mapping  
✅ AWGN channel with adjustable SNR (0–25 dB)  
✅ GUI for live downlink visualization  
✅ BER vs SNR performance analysis  
✅ Frequency-domain and constellation visualization  

---

### 💻 Demo Preview
<p align="center">
  <img src="assets/screenshots/gui_overview.png" alt="GUI Screenshot" width="80%" />
  <br/>
  <em>MATLAB GUI showing real-time waveform, FFT magnitude, and constellation plots</em>
</p>

---

### 📊 Example Simulation Results
| Parameter | Value / Observation |
|------------|--------------------|
| FFT Size | 64 |
| Cyclic Prefix | 16 samples |
| Modulation | 16-QAM (Downlink) |
| Channel | AWGN |
| SNR Range | 0–25 dB |
| BER @ 10 dB | ≈ 0 |
| Message | “Earthquake Detected – Evacuate!” |

<p align="center">
  <img src="assets/screenshots/constellation_plot.png" width="45%"/>
  <img src="assets/screenshots/fft_plot.png" width="45%"/>
</p>

---

### 🧠 Conceptual Summary
> The system models a simplified **5G NR downlink physical layer**.  
> The transmitter encodes and modulates an alert message, sends it through a simulated **AWGN channel**, and the receiver demodulates and reconstructs the original text.  
> As SNR increases, constellation points cluster tightly and BER approaches zero, validating reliable communication.

---

### 🧪 How to Run
In MATLAB Command Window:
```matlab
>> dcs_gui_demo

Then:

Adjust the SNR slider to vary channel noise (0–25 dB).

Click “Run Downlink Demo” to visualize the full transmission chain.

Observe waveform, FFT, constellation, and recovered message outputs.
