require 'formula'
require File.expand_path("../../Requirements/php-meta-requirement", __FILE__)
require File.expand_path("../../Requirements/phar-requirement", __FILE__)
require File.expand_path("../../Requirements/phar-building-requirement", __FILE__)

class Gush < Formula
  homepage 'http://gushphp.org/'
  url 'https://github.com/gushphp/gush/archive/1.8.0.tar.gz'
  sha1 'ae8e1aafa5498731350e6b5ebcae94ad8651263d'
  head 'https://github.com/gushphp/gush.git'

  def self.init
    depends_on PhpMetaRequirement
    depends_on PharRequirement
    depends_on PharBuildingRequirement
    depends_on "composer"
    depends_on "php54" if Formula['php54'].linked_keg.exist?
    depends_on "php55" if Formula['php55'].linked_keg.exist?
    depends_on "php56" if Formula['php56'].linked_keg.exist?
  end

  init

  def install
    File.open("genphar.php", 'w') {|f| f.write(phar_stub) }

    [
      "/usr/bin/env php -d allow_url_fopen=On -d detect_unicode=Off  #{Formula['composer'].libexec}/composer.phar install",
      "sed -i '' '1d' bin/gush",
      "php -f genphar.php",
    ].each { |c| `#{c}` }

    libexec.install "gush.phar"
    sh = libexec + "gush"
    sh.write("#!/bin/sh\n\n/usr/bin/env php -d allow_url_fopen=On -d detect_unicode=Off #{libexec}/gush.phar $*")
    chmod 0755, sh
    bin.install_symlink sh
  end

  def test
    system 'gush --version'
  end

  def phar_stub
    <<-EOS.undent
      <?php
      $stub =<<<STUB
      <?php
      /** This was auto-built from source (https://github.com/gushphp/gush) via Homebrew **/
      Phar::mapPhar('gush.phar'); require 'phar://gush.phar/bin/gush'; __HALT_COMPILER(); ?>";
      STUB;
      $phar = new Phar('gush.phar');
      $phar->setAlias('gush.phar');
      $phar->buildFromDirectory('.');
      $phar->setStub($stub);
    EOS
  end

  def caveats; <<-EOS.undent
    Verify your installation by running:
      "gush --version".

    You can read more about gush by running:
      "brew home gush".

    You may want to start by configuring it:
      "gush core:configure".
    EOS
  end
end
