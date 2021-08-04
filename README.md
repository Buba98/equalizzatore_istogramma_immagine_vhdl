Il progetto richiesto consiste nell'implementazione in VHDL dell metodo di equalizzazione dell’istogramma di una immagine.

Data un'immagine salvata in memoria viene chiesto al componente di:
- Accedere ad una memoria RAM per recuperare il numero di righe e colonne di pixel di cui è composta l'immagine
- Iterare nella memoria per trovare minimo e massimo dei valori dei pixel
- Applicare l'equalizzazione ad ogni pixel dell'immagine
- Salvare in memoria ogni pixel equalizzato a partire dalla posizione successiva rispetto all'ultimo pixel della matrice fornita

La massima grandezza della matrice dell' immagine è 128 * 128.
Inoltre, l'implementazione deve essere in grado di gestire un segnale di Reset. L'implementazione deve essere sintetizzata con target FPGA xc7a200tfbg484-1.
