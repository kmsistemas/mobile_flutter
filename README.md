# KM Industrial

Aplicativo Flutter para operacoes da KM Industrial (passagens, OS em terceiros, coleta, estoque e inventario), com suporte a web, desktop e mobile.

## Requisitos
- Flutter SDK compativel com Dart 2.17 (<3.0.0), conforme `pubspec.yaml`.
- Chrome/Edge para web; Visual Studio com "Desktop development with C++" para Windows desktop; SDKs padrao para Android/iOS se necessario.
- Permissoes de camera (mobile_scanner) nos alvos moveis.

## Como rodar
- Windows (PowerShell):
```powershell
flutter clean
flutter pub get
# escolha o alvo
flutter run -d chrome      # web
flutter run -d windows     # desktop
flutter run -d android     # mobile
```

- macOS / Linux:
```bash
flutter clean
flutter pub get
# escolha o alvo
flutter run -d chrome      # web
flutter run -d macos       # desktop (macOS)
flutter run -d linux       # desktop (Linux)
flutter run -d android     # mobile
```

### Login e hosts
- Informe IP:PORTA no primeiro host (ou use o segundo como fallback). Os valores ficam salvos em SharedPreferences.
- Login e senha sao os mesmos usados pela API backend. Sem token valido o app nao navega.

## Build de producao
- Windows (PowerShell):
```powershell
flutter build web --release --base-href /kmindustrial/ --pwa-strategy=none
```
- macOS / Linux:
```bash
flutter build web --release --base-href /kmindustrial/ --pwa-strategy=none
```
# Para mobile/desktop, use os alvos padrao (apk, appbundle, ipa, exe).

## Deploy no GitHub Pages (gh-pages)
Worktree dedicada: `..\KMindustrial-gh-pages` (irma da pasta do codigo).

1) Gerar build web (ver comando acima).
2) Copiar build para a worktree do Pages:
- Windows (PowerShell):
```powershell
robocopy build\web ..\KMindustrial-gh-pages /MIR /XD .git /XF .git
```
- macOS / Linux:
```bash
rsync -av --delete --exclude='.git' build/web/ ../KMindustrial-gh-pages/
```
3) Publicar:
- Windows (PowerShell):
```powershell
cd ..\KMindustrial-gh-pages
git add .
git commit -m "Deploy web"
git push origin gh-pages
cd ..\KMindustrial
```
- macOS / Linux:
```bash
cd ../KMindustrial-gh-pages
git add .
git commit -m "Deploy web"
git push origin gh-pages
cd ../KMindustrial
```
Site: https://docs.kmsistemas.com.br/kmindustrial/ (branch `gh-pages`, raiz).

## Estrutura rapida
- `lib/screens/*`: telas (login, home e fluxos Passagem, OS Terceiros, Coleta, Estoque, Inventario).
- `lib/services/api_service.dart`: chamadas de API (login/token).
- `assets/km_ind_1024.png`: base dos icones e favicon.
- `web/`: icones/manifest usados na build web.

## Dicas e solucao de problemas
- Tela em branco no Pages: confirme `<base href="/kmindustrial/">`, faca hard refresh (Ctrl+F5) ou limpe o service worker.
- Logout web/desktop: volta para a tela de login; mobile fecha app.
- Se o push pedir login, use usuario GitHub e PAT com permissao de repo (HTTPS).
