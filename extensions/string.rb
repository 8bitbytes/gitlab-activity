require 'openssl'

# adds encrypt and decrypt methods to String class. This is used for adding some obfuscation to the
# settings file.
class String
  def encrypt
    cipher = OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt
    cipher.key = 'd66bea2b7d9d650bde9c1aac'
    s = cipher.update(self) + cipher.final

    s.unpack('H*')[0].upcase
  end

  def decrypt
    cipher = OpenSSL::Cipher.new('DES-EDE3-CBC').decrypt
    cipher.key = 'd66bea2b7d9d650bde9c1aac'
    s = [self].pack("H*").unpack("C*").pack("c*")

    cipher.update(s) + cipher.final
  end
end