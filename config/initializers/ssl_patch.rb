# iGNORE unexpected EOF error with Vault's SSL cert and OpenSSL gem v.3+
# https://stackoverflow.com/questions/76183622/since-a-ruby-container-upgrade-we-expirience-a-lot-of-opensslsslsslerror
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.merge(
  options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options] | OpenSSL::SSL::OP_IGNORE_UNEXPECTED_EOF
).freeze