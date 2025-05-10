# JP Learning

JP Learning 是一個使用 Flutter 開發的應用程式，旨在協助使用者透過新聞、翻譯、單字學習等功能，學習日文。

## 主要功能
- **新聞與文章**  
  瀏覽 NHK Easy 新聞列表與推薦文章，提供即時新聞資訊。
- **翻譯功能**  
  支援日文與其他語言間的互譯。
- **字典與例句**  
  提供單字查詢、假名讀音及例句解析，方便學習與複習。
- **筆記與群組**  
  用戶可建立筆記群組與筆記本，記錄學習歷程與心得。
- **用戶帳戶管理**  
  使用 Firebase 驗證管理用戶登入與資料。
- **主題切換**  
  提供暗黑模式與亮色模式，根據使用者喜好隨時切換。

## 快速開始
1. **前置需求：**  
   - 安裝 [Flutter SDK](https://flutter.dev/docs/get-started/install)
   - 安裝必要的 IDE 插件（例如 VS Code 的 Flutter 與 Dart 插件）
2. **依賴套件安裝：**  
   在專案根目錄執行：
   ```sh
   flutter pub get
   ```
3. **啟動應用程式：**
    連接設備或啟動模擬器，然後執行：
    ```sh
    flutter run
    ```
## 專案結構
```
.flutter-plugins
.flutter-plugins-dependencies
.gitignore
metadata & 設定檔
android/
ios/
lib/
    ├── screens/ // 各頁面介面，如首頁、翻譯、設定等
    ├── models/ // 資料模型，如 NewsArticle、DictionaryEntry 等
    ├── services/ // API 服務，如 NewsService、NoteService 等
    ├── utils/ // 工具函式，如 TextParser 等
    └── widgets/ // 自訂 widget 與 UI 元件
web/
windows/
macos/
linux/
```
## Firebase 設定
此專案採用 Firebase 進行使用者認證與資料存取，但因安全考量，專案未包含 `google_service.json`（此檔案已被加入 `.gitignore`）。  
請參考 [FlutterFire 文件](https://firebase.flutter.dev/docs/cli) 使用 `flutterfire configure` 來產生並配置您專屬的 `google_service.json` 與其他必要檔案。

## 偵錯執行
目前只支援andriod，device可以從andriod studio 設定或新增想要使用的機種。


