cat smb.chr megaman.chr kosmic.chr somewes.chr darbian.chr andrewg.chr kappa.chr custom.chr > intro_flat.chr && \
truncate --size 4096 intro_flat.chr  && \
python ../../scripts/chr2copylayout.py intro_flat.chr intro.chr && \
cat intro.chr intro.chr > ../intro.chr

