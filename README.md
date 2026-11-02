# SANGROYA FAMILY TREE

Early Android prototype for family genealogy records.

## Prototype features
- Add member records manually.
- Import Excel `.xlsx` / `.xls` with a header row.
- Save records locally on the Android device.
- Record name, father, village/place, occupation, life partner, generation and notes.

## Excel headers
Use: `Name`, `Father`, `Village`, `Occupation`, `Spouse`, `Generation`, `Notes`. Rows without a name are skipped.

## Build
GitHub Actions runs on pushes to `main` or can be started manually. Download the APK from the workflow run's Artifacts.

## Limitations
This is an early prototype, not a production family-data service. Login/invitations, cloud sync, admin roles, true relationship-based family tree, translation/transliteration and backup/export are not included yet. Hinglish text is saved as typed. Do not store private family data in this public source repository.
