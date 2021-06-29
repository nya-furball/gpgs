# gpgs
A user-friendly script to secure synchronous communications using ephemeral GPG keys.

### DISCLAIMER:
This tool is provided without any liability to the author or contributors of this project.</br>
This tool and GPG are NOT SILVER BULLETS. Understand your situation, what you are trying accomplish, who are you up against and what can your adversaries do. The author of the program is NOT a cryptographer, nor can they offer professional advice in situations where lives are endangered due to disclosure of information/metadata and/or compromises in operational security. </br>
This tool is intended to be used by users with:<br/>
- moderate experience in Linux system administration/security</br>
- detailed understanding of how GPG and the Web of Trust works</br>
A understanding more than just a high level overview of how to use GPG is required. You need to understand how to use GPG practically against your adversaries in order to prevent fuck-ups during your communications process. It is also recommended for you to have a solid understanding of public key cryptography before using the script. The cryptography used in the tool is NOT quantum-resistant.</br>

### Features and Limitations: (TODO!)

###### Limitations:
This script CANNOT: </br>
- Secure plaintext encrypted on a compromised client</br>
- Actually prove trust relations IF you do not establish trust securely beforehand </br>
- Protect against rubber-hose cryptanalysis against plaintext information if an adversary knows enough context to determine that said information was communicated in a past session </br>
- Protect your metadata </br>

###### Features:
If and only if both your client and the recipient's client are not compromised at runtime, the script CAN DO:</br>
(TODO)

###### Compromise Criterion</br>
A client is considered compromised in the scope of this project IF:</br>
- Your adversary can capture your plaintext before it's encrypted (eg malware or hardware key-logger)</br>
- Your adversary can RECOVER ephemeral key-pairs and the passphrase (eg. key material get stored onto non-volatile medium like Intel(R) Optane(tm) DCPMM modules or an admin gains access to the ephemeral GPG homedir on a multi-user system or VPS)

### Threat Model and Expectations:
(TODO)

### Improvements and Bug-fixes!
If you find any oversights or flaws in the overall threat model, cryptography or implementation, PLEASE FILE AN ISSUE! Everyone is welcome to audit this tool, no matter if you're a enthusiast, cipherpunk, or a professional cryptologist! I am very happy to discuss those shortfalls and improve the overall implementation! Also, feel free to file issues if you find bugs in the software or you would like to suggest improvements in the UI!

#### README TODO
- Features and Limitations
- Threat model and expectations 
- Practical Use Case
- Commands and Syntax