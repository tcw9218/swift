
//  Created by wu ted on 2022/1/5.
//

#ifndef AUTHTRONCORE_SELF_H
#define AUTHTRONCORE_SELF_H

#include <stdio.h>
int (*ATC_ecdsa_nonrkGenFunc)(uint8_t* credential, uint8_t* publicKey);
int (*ATC_ecdsa_rkGenFunc)(uint16_t keyId, uint8_t* publicKey);
int (*ATC_ecdsa_nonrkSignFunc)(uint8_t* credential,  uint8_t* digest, uint8_t* signature);
int (*ATC_ecdsa_rkSignFunc)(uint16_t keyId, uint8_t* digest, uint8_t* signature);
int (*ATC_ecdsa_rkState)(uint16_t keyId, uint8_t* state);
int (*ATC_ecdsa_rkDestroyFunc)(uint16_t keyId);

int (* ATC_attkeyState)(uint8_t* state);
int (* ATC_attkeySetFunc)(uint8_t* privateKey, uint8_t* publicKey);
int (* ATC_attkeyDestroyFunc)(void);
int (* ATC_attkeySignFunc)(uint8_t* digest, uint8_t* signature);


int (* ATC_rngFunc) (uint16_t len , uint8_t* random);
int(*ATC_maskeyGenFunc) (void);
int(*ATC_maskeyDesFunc) (void);
int(*ATC_maskeyState) (uint8_t* state);
int(*ATC_maskeyEncryptFunc) (uint16_t dataLen, uint8_t* dataIn, uint8_t* dataOut);
int(*ATC_maskeyDecryptFunc) (uint16_t dataLen, uint8_t* dataIn, uint8_t* dataOut);


int (* ATC_storageState)(uint16_t id , uint8_t* state);
int (* ATC_storageSetFunc)(uint16_t id, uint16_t dataInLen, uint8_t* dataIn);
int (* ATC_storageGetFunc)(uint16_t id, uint16_t* dataInLen, uint8_t* dataOut);
int (* ATC_storageDeleteFunc)(uint16_t id);

int (*ATC_ecdh_GenFunc)(uint8_t* credentialA, uint8_t* publicKeyA);
int (*ATC_ecdh_deriveFunc)(uint8_t* credentialA, uint8_t* publicKeyB, uint8_t* shared_secret);

 
int (*ATC_sha256Func)(uint16_t dataLen, uint8_t* dataIn, uint8_t* dataOut);
int (*ATC_hmac256Func) (uint8_t keyLen, uint8_t* key, uint16_t dataLen, uint8_t* dataIn, uint8_t* dataOut);
#endif
