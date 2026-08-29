class UsbWakeupBlocker < Formula
  desc "Prevent USB devices from waking your system from sleep"
  homepage "https://github.com/nogunix/usb-wakeup-blocker"
  url "https://github.com/nogunix/usb-wakeup-blocker/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "a3f442b966ac54f37a9bfac864a1089b378f5ee553e1358366b2ad12bf2877e3"
  license "MIT"

  depends_on "bash" => :build
  depends_on :macos

  def install
    system "cc", "-framework", "IOKit", "-framework", "CoreFoundation",
           "-o", "usb-wakeup-helper", "helpers/macos/usb-wakeup-helper.c"

    bin.install "bin/usb-wakeup-blocker.sh"
    bin.install "usb-wakeup-helper"

    etc.install "etc/usb-wakeup-blocker.conf" => "usb-wakeup-blocker.conf"

    bash_completion.install "completions/bash/usb-wakeup-blocker"
    zsh_completion.install "completions/zsh/_usb-wakeup-blocker"
  end

  def caveats
    <<~EOS
      To start the daemon (blocks mice from waking the system by default):
        sudo brew services start usb-wakeup-blocker

      Edit the configuration at:
        #{etc}/usb-wakeup-blocker.conf
    EOS
  end

  service do
    run [opt_bin/"usb-wakeup-blocker.sh", "--daemon"]
    keep_alive true
    require_root true
    log_path var/"log/usb-wakeup-blocker.log"
    error_log_path var/"log/usb-wakeup-blocker.log"
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/usb-wakeup-blocker.sh -h")
    assert_match "Usage:", shell_output("#{bin}/usb-wakeup-helper 2>&1", 1)
  end
end
