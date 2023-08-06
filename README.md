# ECE 222 ARM Assembly Projects Repo
Repository containing completed ARM Assembly projects of interest in ECE 222 course

---
## Project 2 - Assembly Morse Code Transmitter
An LED on the board is used as a Morse code transmitter which blinks the Morse code of a string at 1Hz. Fetches characters from the Input LUT which stores the string to be blinked in Morse Code. Obtains the index for the Morse LUT from the ASCII value of the character. Blinks the corresponding Morse Code obtained from the Morse LUT by calling subroutines LED_ON, LED_OFF, and DELAY for turning on and off the LED and holding each state for 0.5 seconds. The string is blinked with 1.5 second LED on representing a dash, 0.5 second LED on representing a dot, 0.5 seconds LED off in between dashes and dots, 1.5 seconds LED off between letters, and 2 seconds LED off between strings. Utilized subroutines and parameter passing. 

---
## Project 3 - Assembly Counter & Reflex-Meter
8 LEDs on the board counts from 0-255 (0x0 - 0xFF) at 10Hz from the simple counter subroutine for correctness of output interfacing. For the reflex-meter, a pseudorandom number generator subroutine is called for a random delay within the range of 2 to 10 seconds +/- 0.25%. P1.29 LED will turn on after the random amount of delay and the increment subroutine polls P2.10 push button every 0.1ms for user input. Once pressed, the 8 LEDs displays from the least significant 8 bits to the most significant 8 bits in increments, resulting in a 32-bit number (max. 429496.7296s = 119.3hrs) shown as the resulting reaction time of the user in units of 0.1 ms (divide result by 10000 for result in seconds).
