java.exe -jar .\revanced\revanced-cli.jar options --overwrite .\revanced\revanced-patches.jar

git --no-pager diff .\options.json

git add options.json && git commit -m "chore: Update Options" && git push
