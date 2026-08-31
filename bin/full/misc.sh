# lightdm use fingerprint
sudo grep -q "pam_fprintd.so" /etc/pam.d/lightdm || sudo sed -i '/@include common-auth/i auth    optional      pam_fprintd.so' /etc/pam.d/lightdm