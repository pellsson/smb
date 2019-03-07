cat intro/smb.chr intro/megaman.chr intro/kosmic.chr intro/somewes.chr intro/roylt.chr intro/andrewg.chr intro/kappa.chr intro/custom.chr > /tmp/intro_flat.chr && \
truncate --size 4096 /tmp/intro_flat.chr  && \
python ../scripts/chr2copylayout.py /tmp/intro_flat.chr intro/intro.chr && \
cat intro/intro.chr intro/intro.chr > intro.chr && \
python ../scripts/chr2copylayout.py smb/smborg-sprites.chr /tmp/org-sprites.chr && \
python ../scripts/chr2copylayout.py smb/smborg-back.chr /tmp/org-back.chr && \
cat /tmp/org-sprites.chr /tmp/org-back.chr > org.chr
python ../scripts/chr2copylayout.py smb/smblost-sprites.chr /tmp/lost-sprites.chr && \
python ../scripts/chr2copylayout.py smb/smblost-back.chr /tmp/lost-back.chr && \
cat /tmp/lost-sprites.chr /tmp/lost-back.chr > lost.chr



