import UIKit



let a  =  UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
a[0] = 0x90
a[1] = 0x01
a[2] = 0x02
a[3] = 0x08



let b = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
b.initialize(from: a.advanced(by: 3), count: 1)

for i in 0..<1{
    let a = b[i]
    let st = String(format: "%02x", a)
    print(st)
}
a[0] = (UInt8((257 >> 0) & 0xFF))
a[1] = UInt8( (257 >> 8) & 0xFF);
for i in 0..<3{
    let at = a[i]
    let st = String(format: "%02x", at)
    print(st)
}

print(UInt16((a[0] & 0xFF)) << 8 | UInt16((a[1] & 0xFF)) )

//let jsonreps = {"ec0ddef5-451f-4957-bd9b-793ad81a7d65":{"Display Name":"TEST","ECDSApub":"MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEVs/o5+uQbTjL3chynL4wXgUg2R9q9UU8I5mEovUf86QZ7kOBIjJwqnzD1omageEHWwHdBO6B+dFabmdT9POxg==","ECDHpub":"MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEbgZPPWxUUQO74Bj3yBMt3Ov1DvXuPdp5KuBXeHfstCUbOx9QPyJcYk4vdxpwDsbJxtuEDxkIrPQ9peSjVKNsHA=="},"70cbf706-98f4-4bdf-8b0d-28d2d468ba6d":{"Display Name":"","ECDSApub":"MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEVs/o5+uQbTjL3chynL4wXgUg2R9q9UU8I5mEovUf86QZ7kOBIjJwqnzD1omageEHWwHdBO6B+dFabmdT9POxg==","ECDHpub":"MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEbgZPPWxUUQO74Bj3yBMt3Ov1DvXuPdp5KuBXeHfstCUbOx9QPyJcYk4vdxpwDsbJxtuEDxkIrPQ9peSjVKNsHA=="}}


print(UInt8((120 >> 8) & 0xFF))

print(0xA5 & 0x1F)
