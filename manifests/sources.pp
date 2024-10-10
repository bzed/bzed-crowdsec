# @summary configure crowdsec repositories
#
# setup apt sources lists and necessary keys.
#
# @param keyring_source
# Source of the keyring to install into apt
#
# @param include_sources
# If true, a src apt source will be added
# @example
#   include crowdsec::sources
class crowdsec::sources (
  String $keyring_source = 'puppet:///modules/crowdsec/crowdsec-archive-keyring.gpg',
  Boolean $include_sources = false,
) {
  $distro = $facts['os']['distro']['id'].downcase()
  apt::source { 'crowdsec':
    location => "https://packagecloud.io/crowdsec/crowdsec/${distro}",
    include  => {
      'src' => $include_sources,
      'deb' => true,
    },
    repos    => 'main',
    release  => $facts['os']['distro']['codename'],
    key      => {
      name   => 'crowdsec-archive-keyring.gpg',
      source => $keyring_source,
    },
  }
}
