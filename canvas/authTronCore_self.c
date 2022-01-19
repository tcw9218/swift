//
//  authTronCore_self.c
//  ATC
//
//  Created by wu ted on 2022/1/5.
//

//#include "authTronCore_self.h"

#include <stdio.h>
#include "hmac.h"
#include "hash.h"
#include "block_cipher.h"
#include "authTronCore_adapter.h"
#include "authTronCore_self.h"



//MARK: - storage
int (* ATC_storageState)(uint16_t id , uint8_t* state);
int (* ATC_storageSetFunc)(uint16_t id, uint16_t dataInLen, uint8_t* dataIn);
int (* ATC_storageGetFunc)(uint16_t id, uint16_t* dataInLen, uint8_t* dataOut);
int (* ATC_storageDeleteFunc)(uint16_t id);




int ATC_ADP_store_state(uint16_t id, uint8_t *state){
    return ATC_storageState(id,state);};    // state 1: SET, 0: NOT SET
int ATC_ADP_store_set(uint16_t id, uint16_t dataInLen,   uint8_t *dataIn){
    return ATC_storageSetFunc(id,dataInLen,dataIn);};
int ATC_ADP_store_get(uint16_t id, uint16_t* dataOutLen, uint8_t *dataOut){
    return ATC_storageGetFunc(id,dataOutLen,dataOut);};
int ATC_ADP_store_destroy(uint16_t id){
    return ATC_storageDeleteFunc(id);};

//MARK: - MAsterkey
int (* ATC_rng) (uint16_t len , uint8_t* random);
int(*ATC_maskeyGenFunc) (void);
int(*ATC_maskeyDesFunc) (void);
int(*ATC_maskeyState) (uint8_t* state);
int(*ATC_maskeyEncryptFunc) (uint16_t dataLen, uint8_t* dataIn, uint8_t* dataOut);
int(*ATC_maskeyDecryptFunc) (uint16_t dataLen, uint8_t* dataIn, uint8_t* dataOut);

int ATC_ADP_rng_generate        (uint16_t len, uint8_t* random){
    return ATC_rngFunc(len ,random);
};

int ATC_ADP_master_key_state    (uint8_t* state){
    return ATC_maskeyState(state);
};
int ATC_ADP_master_key_generate    (void){
    return ATC_maskeyGenFunc();
};
int ATC_ADP_master_key_destroy  (void){
    return ATC_maskeyDesFunc();
};
int ATC_ADP_master_key_encrypt  (uint16_t dataLen, uint8_t* dataIn, uint8_t* dataOut){

    return ATC_maskeyEncryptFunc(dataLen ,dataIn ,dataOut);
};
int ATC_ADP_master_key_decrypt  (uint16_t dataLen, uint8_t* dataIn, uint8_t* dataOut){
    return ATC_maskeyDecryptFunc(dataLen ,dataIn ,dataOut);
};

//MARK: - ATTKEY

int (* ATC_attkeyState)(uint8_t* state);
int (* ATC_attkeySetFunc)(uint8_t* privateKey, uint8_t* publicKey);
int (* ATC_attkeyDestroyFunc)(void);
int (* ATC_attkeySignFunc)(uint8_t* digest, uint8_t* signature);


int ATC_ADP_ecdsa256_attkey_state(uint8_t* state){
    return ATC_attkeyState(state);
};
int ATC_ADP_ecdsa256_attkey_set(uint8_t* privateKey, uint8_t* publicKey){
    return  ATC_attkeySetFunc(privateKey , publicKey);
};
int ATC_ADP_ecdsa256_attkey_destroy(void){
    return ATC_attkeyDestroyFunc();
};
int ATC_ADP_ecdsa256_attkey_sign(uint8_t* digest, uint8_t* signature){
    return ATC_attkeySignFunc(digest , signature);
};

//MARK: - ECDSA
int (*ATC_ecdsa_nonrkGenFunc)(uint8_t* credential, uint8_t* publicKey);
int (*ATC_ecdsa_rkGenFunc)(uint16_t keyId, uint8_t* publicKey);
int (*ATC_ecdsa_nonrkSignFunc)(uint8_t* credential,  uint8_t* digest, uint8_t* signature);
int (*ATC_ecdsa_rkSignFunc)(uint16_t keyId, uint8_t* digest, uint8_t* signature);
int (*ATC_ecdsa_rkState)(uint16_t keyId, uint8_t* state);
int (*ATC_ecdsa_rkDestroyFunc)(uint16_t keyId);


int ATC_ADP_ecdsa256_nonrk_generate(uint8_t* credential, uint8_t* publicKey){
    return ATC_ecdsa_nonrkGenFunc(credential , publicKey);
};
int ATC_ADP_ecdsa256_nonrk_sign(uint8_t* credential, uint8_t* digest, uint8_t* signature){
    return ATC_ecdsa_nonrkSignFunc(credential , digest ,signature);
};


int ATC_ADP_ecdsa256_rk_state(uint16_t keyId, uint8_t* state){
    return ATC_ecdsa_rkState(keyId , state) ;
};
int ATC_ADP_ecdsa256_rk_generate(uint16_t keyId, uint8_t* publicKey){
    return ATC_ecdsa_rkGenFunc(keyId ,publicKey);
};
int ATC_ADP_ecdsa256_rk_destroy(uint16_t keyId){
    return ATC_ecdsa_rkDestroyFunc(keyId);
};
int ATC_ADP_ecdsa256_rk_sign(uint16_t keyId, uint8_t* digest, uint8_t* signature){
    return ATC_ecdsa_rkSignFunc(keyId ,digest ,signature);
};


//MARK: - ECDH
int (*ATC_ecdh_GenFunc)(uint8_t* credentialA, uint8_t* publicKeyA);
int (*ATC_ecdh_deriveFunc)(uint8_t* credentialA, uint8_t* publicKeyB, uint8_t* shared_secret);


int ATC_ADP_ecdh256_generate(uint8_t* credentialA, uint8_t* publicKeyA){
    return ATC_ecdh_GenFunc(credentialA , publicKeyA);
};
int ATC_ADP_ecdh256_derive(uint8_t* credentialA, uint8_t* publicKeyB, uint8_t* shared_secret){
    return ATC_ecdh_deriveFunc(credentialA , publicKeyB ,shared_secret);
};




//MARK: - AESSHA
int ATC_ADP_sha256              (uint16_t dataLen, uint8_t* dataIn, uint8_t* dataOut){

    return ATC_sha256Func(dataLen,dataIn,dataOut);
   

};
int ATC_ADP_hmacsha256          (uint8_t keyLen, uint8_t* key, uint16_t dataLen, uint8_t* dataIn, uint8_t* dataOut){
    

    return  ATC_hmac256Func(keyLen ,key ,dataLen ,dataIn ,dataOut);
};
int ATC_ADP_aes256cbc           (uint8_t* key, uint8_t* iv, uint8_t dir,
                                 uint16_t dataLen, uint8_t* dataIn, uint8_t* dataOut){

   return blockcipher_onestep(CIPHER_AES256, MODE_CBC, dir, 0, 32, key, 16, iv, dataLen, dataIn, dataOut); //dir {1 :en , 0:de}

};

