# civitas-env

- `docker-compose up -d`
- `docker exec -it civitas /bin/bash`
- `cd civitas-0.7.1`
- `experiments/src/coordinator.pl experiments/sample1.exp`

see the juicy details print to console, and check out the logs.


# Things to note:

## Agents:

### supervisor
 - specifies the ballot design
 - specifies the tellers
 - start and stop the election
 - selects policy for re-votes

### registrar
 - authorizes voters
 
### registration tellers
 - Generates credentials voters use to cast their votes
 - Each teller holds a piece of each voter credential
 - private voter credential can only be leaked through collusion of each teller

### tabulation tellers
 - tally votes

### Voters
 - have a Registration key (used to identify themselves to the registration teller)
 - have a Designation key (used to generate their credential)
 - After registration, will have a credential used to cast votes
 - Can create fake credentials which, if used to vote, will be quietly eliminated from the tally to hand to a coercer
 
## Election cycle

### Registration
 - Registrar
    - posts a list of all valid voters along with the public registration keys
 - Registration tellers
    - generate voter credentials used to authenticate votes anonymously. Each credential is associated with a single voter.
    - public part of each voter credential is posted
    - Each teller stores a distinct piece of the private voter credential, to be released to the voter in the next step
 - Registration tellers + voter
    - voter identifies themselves to reg teller with Registration key
    - voter uses designation key to run protocol with reg teller to release piece of their private credential
 - Voter
    - combines credential pieces from each reg teller to create their complete credential

### Setup
 - Supervisor
    - posts ballot
    - identifies tellers by public keys
    - selects a policy on how to tally re-votes
 - Tabulation tellers
    - collectively generate a public key and post it
      (Data encrypted with the collective tabulation key can only be decrypted with the participation of all tabulation tellers)

### voting phase
  - voter's private credential and choice are encrypted and posted along with a proof that the vote is well-formed to some or all ballot boxes
  - voter may subit more that one vote per credential (If revotes are allowed, then the voter must include a proof in later votes to indicate which earlier votes are being replaced. This proof must demonstrate knowledge of the credential and choice used in both votes, preventing an adversary from revoting on behalf of a voter.)
  
### tabulation phase
  - Tabulation tellers
    - Verify proof of well-formed votes
    - eliminate duplicates in line with revoting policy (TODO: who verifies revoting policy was followed??)
    - Anonymize. Tellers run steps of randomized mix-net in turn to anonymize pub credentials and votes 
    - Eliminate unauthorized votes by comparing anonymized votes and credentials (TODO: Why does this happen after previous step?)
    - choices decrypted (credentials not decrypted) and posted
    - tab tellers post proofs that they are following the protocol

### Verification
  - Anyone can uses tab teller proofs to verify outcome follows from votes
  - voter can verify their vote is present in the tab-teller set

### Resisting coercion:
  - voter may use private designation key to produce fake private credential shares

## Security Assumptions of Civitas:

### Availability
Of both voting system and tabulation results.

### Corrupt election authorities
 - Each voter trusts at least one registration teller
 - At least 1 honest tabulation teller

### Coercer access to voter
 - adversary may not control a voter throughout the entire election
 - voter can register without being controlled by an adversary (A voter cannot sell their registration key before they register) (adversary cannot simulate a voter during registration)

### Secure Channels
 - an anonymous channel, on which the adversary cannot identify the sender, for the sender to submit their vote
 - An untappable channel between each voter and their trusted registration teller
 
### No ranked-choice or write-in vulnerabilities:
 A voter must not be able to encode arbitrary information into their vote to identify themselves (see CCM08) on how to do ranked choice properly
 
### At least one ballot box submits all of its accepted votes to all tabulation tellers

### A voter trusts their client is not compromised

### Crypto is not broken
 - DDH and RSA assumptions hold, and SHA256 is a random oracle
 
### Escalation processes
 - a voter has an arbiter that they can interact with to try to "re-register" to identify a registration teller giving a voter an invalid credential piece.

# References:
 - [CCM08](https://ecommons.cornell.edu/bitstream/handle/1813/7875/civitas-tr.pdf)
