# gpgs

A user-friendly script to secure synchronous communications using ephemeral GPG keys.


### DISCLAIMER:

This tool is provided without any liability to the author or contributors of this project. </br>This tool and GPG are NOT SILVER BULLETS. Understand your situation, what you are trying accomplish, who are you up against and what can your adversaries do. The author of the program is NOT a cryptographer, nor can they offer professional advice in situations where lives are endangered due to disclosure of information/metadata and/or compromises in operational security. 

This tool is intended to be used by users with:

- moderate experience in Linux system administration/security
- detailed understanding of how GPG and the Web of Trust works

A understanding more than just a high level overview of how to use GPG is required. You need to understand how to use GPG practically against your adversaries in order to prevent fuck-ups during your communications process. It is also recommended for you to have a solid understanding of public key cryptography before using the script. The cryptography used in the tool is NOT quantum-resistant.


### Features and Limitations:

##### Limitations:
This script CANNOT: 

- Secure messages encrypted on a compromised client
- Protect you against untrustworthy recipients
- Prevent you from getting [MITMed](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) IF you do not establish trust securely prior to using the script 
- Protect you AND/OR your recipient against being [rubber-hosed](https://en.wikipedia.org/wiki/Rubber-hose_cryptanalysis) for specific message contents if an adversary knows enough context to determine what might be sent in the past 
- Protect against adversaries using quantum computers to recover captured past encrypted messages
- Protect your metadata

##### Features:
IF AND ONLY IF both clients (sender/receiver) are not compromised AND you are not being [MITMed](https://en.wikipedia.org/wiki/Man-in-the-middle_attack), this script CAN:

- Prevent recovery of your messages against conventional computers
- Protect messages against client compromise in the future
- Prevent you and your recipient against being [compelled to give up key material](https://en.wikipedia.org/wiki/Key_disclosure_law) (key pairs are in DRAM and passphrase is not exposed to user)

##### Compromise Criterion
A client is considered compromised in the scope of this project IF:

- Your adversary can capture your messages before it's encrypted, eg:
  - Malware running on OS
  - Hardware key-logger
  - [TEMPEST](https://en.wikipedia.org/wiki/Tempest_\(codename\)) attacks against a wireless keyboard
- Your adversary can recover the key-pairs and passphrase, eg:
  - key-pairs and/or passphrase get stored onto non-volatile medium, eg:
     - Intel(R) Optane(tm) DCPMM modules configured as system memory
     - Swapfile/partition on HDD or SSD
  - Admins gain access to the ephemeral GPG homedir on a multi-user system
  - Your VPS provider dumps the memory content and performs memory forensics



### Threat Model and Expectations:
(TODO)

### Example Case Study:
(TODO)

### Improvements and Bug-fixes!
If you find any oversights or flaws in the overall threat model, cryptography or implementation, PLEASE FILE AN ISSUE! Everyone is welcome to audit this tool, no matter if you're a enthusiast, cipherpunk, or a professional cryptologist! I am very happy to discuss those shortfalls and improve the overall implementation! Also, feel free to file issues if you find bugs in the software or you would like to suggest improvements in the UI!

#### README TODO
- Threat model and expectations 
- Practical Use Case
- Commands and Syntax