{ stdenv, fetchurl, config
, alsaLib
, atk
, cairo
, cups
, dbus_glib
, dbus_libs
, fontconfig
, freetype
, gdk_pixbuf
, glib
, glibc
, gst_plugins_base
, gstreamer
, gtk
, libX11
, libXScrnSaver
, libXcomposite
, libXdamage
, libXext
, libXfixes
, libXinerama
, libXrender
, libXt
, libcanberra
, mesa
, nspr
, nss
, pango
, libheimdal
, libpulseaudio
, systemd
}:

assert stdenv.isLinux;

let
  version = "25.7.3";
  arch = if stdenv.system == "i686-linux"
    then "linux-i686"
    else "linux-x86_64";
in

stdenv.mkDerivation {
  name = "palemoon-bin-${version}";

  src = fetchurl {
    url = "https://linux.palemoon.org/files/${version}/palemoon-${version}.en-US.${arch}.tar.bz2";
    sha1 = if arch == "i686-linux" then
    "50976a513956005ce201624231e383e6611a9ad4" else
    "5022f5796c7089a5865a545213c8e420e4063503";
  };

  phases = "unpackPhase installPhase";

  libPath = stdenv.lib.makeLibraryPath
    [ stdenv.cc.cc
      alsaLib
      atk
      cairo
      cups
      dbus_glib
      dbus_libs
      fontconfig
      freetype
      gdk_pixbuf
      glib
      glibc
      gst_plugins_base
      gstreamer
      gtk
      libX11
      libXScrnSaver
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXinerama
      libXrender
      libXt
      libcanberra      
      mesa
      nspr
      nss
      pango
      libheimdal
      libpulseaudio
      systemd
    ] + ":" + stdenv.lib.makeSearchPath "lib64" [
      stdenv.cc.cc
    ];

  # "strip" after "patchelf" may break binaries.
  # See: https://github.com/NixOS/patchelf/issues/10
  dontStrip = 1;

  installPhase =
    ''
      mkdir -p "$prefix/usr/lib/palemoon-bin-${version}"
      cp -r * "$prefix/usr/lib/palemoon-bin-${version}"

      mkdir -p "$out/bin"
      ln -s "$prefix/usr/lib/palemoon-bin-${version}/palemoon" "$out/bin/"

      for executable in \
        palemoon palemoon-bin plugin-container
      do
        patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          "$out/usr/lib/palemoon-bin-${version}/$executable"
      done

      find . -executable -type f -exec \
        patchelf --set-rpath "$libPath" \
          "$out/usr/lib/palemoon-bin-${version}/{}" \;

      # Create a desktop item.
      mkdir -p $out/share/applications
      cat > $out/share/applications/palemoon.desktop <<EOF
      [Desktop Entry]
      Type=Application
      Exec=$out/bin/palemoon
      Icon=$out/usr/lib/palemoon-bin-${version}/browser/icons/mozicon128.png
      Name=Pale Moon
      GenericName=Web Browser
      Categories=Application;Network;
      EOF
    '';

  meta = with stdenv.lib; {
    description = "Open source web browser based on Firefox focusing on efficiency (binary package)";
    homepage = https://linux.palemoon.org/;
    license = {
      free = false;
      url = https://www.palemoon.org/redist.shtml;
    };
    platforms = platforms.linux;
  };
}
