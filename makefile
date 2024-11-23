list-versions:
	java -jar .\revanced\revanced-cli.jar list-versions $(if $(f),-f $(f),) .\revanced\revanced-patches.rvp

list-patches:
	java -jar .\revanced\revanced-cli.jar list-patches --with-descriptions --index=false --with-options --with-packages --with-versions $(if $(f),-f $(f),) .\revanced\revanced-patches.rvp