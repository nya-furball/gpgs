# gpgs
A script to easily create and use ephemeral GPG keys during synchronous communications sessions.

### DISCLAIMER:
This script and GPG are NOT A SILVER BULLETS. Understand your situation, what you are trying accomplish, who you are up against and what can your adversaries do. The author of the program is NOT a cryptologist nor can they offer professional advice in situations where lives are endangered due to disclosure of information/metadata and/or compromises in operational security. </br>
This software is intended to be used by users with:<br/>
- moderate experience in linux system administration/security</br> 
- somewhat more detailed understanding of how PGP/GPG works</br>
A non-high level overview understanding of how to use GPG practically is required in order to prevent fuckups during your communications process.</br>

### Features: (TODO!)
This script CANNOT:
- Protect your communications IF your client is already compromised while running the script
- Actually prove that you are talking with your intended recipient IF you do not establish trust beforehand
- Protect against rubberhose cryptanalysis against private information conveyed through a synchronous session
- Protect your metadata
This program CAN: (if your client is not compromised at while running script)

#### README TODO
- Features
- Script usage  
- Commands and usage  
- Threat model and expectations  
- Use case example  
- Call to action  
    - Cryptanalysis
    - File issues
        - Bugs/Security issues
        - Weaknesses in threat model, expectations and usage
